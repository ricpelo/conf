#!/bin/bash

ayuda()
{
    echo -e "\nSintaxis: $(basename $0) [-d] <nombre>\n"
    echo -e "    -d: elimina el proyecto en lugar de crearlo\n"
    exit 1
}

if [ -z "$1" ]
then
    ayuda
fi

if [ "$1" = "-d" ]
then
    if [ -z "$2" ]
    then
        ayuda
    else
        echo "Eliminando proyecto $2..."
        if [ -d $2 ]; then
            sudo rm -rf $2
        fi
        sudo sed -i /$2.local/d /etc/hosts
        sudo a2dissite $2
        sudo rm -f /etc/apache2/sites-available/$2.conf
        sudo service apache2 reload
        sudo service postgresql status > /dev/null || sudo service postgresql start
        sudo -u postgres dropdb --if-exists $2
        sudo -u postgres dropdb --if-exists $2_test
        sudo -u postgres dropuser --if-exists $2
        sed -i "/^localhost:5432:\*:$2:$2$/d" ~/.pgpass
        exit 0
    fi
fi

if [ -d "$1" ]
then
    if [ ! -f "$1/$1.conf" ]
    then
        echo "El directorio $1 ya existe y no parece contener un proyecto."
        exit 1
    else
        echo "Parece que ya existe el directorio del proyecto."
        echo -n "¿Intentar crear la configuración asociada? (S/n): "
        read SN
        [ "$SN" = "n" ] && SN="N"
    fi
else
    CREATE="S"
    echo "Creando el proyecto desde la plantilla ricpelo/yii2-app-basic..."
    composer create-project --prefer-dist ricpelo/yii2-app-basic:dev-master $1
    cd $1
    echo "Creando repositorio git..."
    git init -q
    git add .
    git commit -q -m "Carga inicial"
    cd ..
fi

if [ "$SN" != "N" ]
then
    cd $1
    if [ -z "$CREATE" ]
    then
        echo "Ejecutando composer install..."
        composer install
        echo "Ejecutando composer run-script post-create-project-cmd..."
        composer run-script post-create-project-cmd
    fi
    if ! grep -qs "$1.local" /etc/hosts
    then
        echo "Añadiendo entrada para $1.local en /etc/hosts..."
        if grep -qs "^$" /etc/hosts
        then
            sudo sed -ie "s/^$/127.0.0.1	$1.local\n/" /etc/hosts
        else
            echo "127.0.0.1	$1.local" | sudo tee -a /etc/hosts > /dev/null
        fi
    else
        echo "Ya existe una entrada para $1.local en /etc/hosts."
    fi
    if [ ! -f "/etc/apache2/sites-available/$1.conf" ]
    then
        echo "Creando sitio virtual $1.local en Apache2..."
        sudo cp $1.conf /etc/apache2/sites-available/$1.conf
        sudo a2ensite $1
        sudo service apache2 reload
    else
        echo "El sitio virtual $1.local ya existe en Apache2."
    fi
fi
