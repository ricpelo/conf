#!/bin/sh

BASE_DIR=$(readlink -f $0)
BASE_DIR=$(dirname $BASE_DIR)
BASE_DIR=$BASE_DIR/../scripts/_lib
. $BASE_DIR/auxiliar.sh

ayuda()
{
    echo "\nSintaxis: $(basename $0) [-a|-d] <nombre>\n"
    echo "    -a: además crea el sitio virtual"
    echo "    -d: elimina el proyecto en lugar de crearlo\n"
    exit 1
}

if [ -z "$1" ]; then
    ayuda
fi

if [ "$1" = "-d" ]; then
    if [ -z "$2" ]; then
        ayuda
    else
        mensaje "Eliminando proyecto $2..."
        if [ -d "$2" ]; then
            mensaje "Eliminando archivos del directorio $2..."
            rm -rf $2
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

if [ "$1" = "-a" ]; then
    VIRTUAL="1"
    shift
else
    VIRTUAL=""
fi

if [ -z "$1" ]; then
    ayuda
fi

if ! echo "$1" | grep -q "^[a-z][0-9a-z]*$"; then
    mensaje_error "El nombre del proyecto sólo puede contener dígitos y letras minúsculas,"
    mensaje_error "y debe comenzar por una letra minúscula."
    exit 1
fi

if [ -d "$1" ]; then
    if [ ! -f "$1/$1.conf" ]; then
        mensaje_error "El directorio $1 ya existe y no parece contener un proyecto."
        exit 1
    else
        mensaje "Parece que ya existe el directorio del proyecto."
        pregunta SN "¿Intentar crear la configuración asociada?: " S
    fi
else
    CREATE="S"
    mensaje "Creando el proyecto desde la plantilla ricpelo/yii2-app-basic..."
    composer create-project --prefer-dist ricpelo/yii2-app-basic:dev-master $1
    cd $1
    mensaje "Creando repositorio git..."
    git init -q
    git add .
    git commit -q -m "Carga inicial"
    cd ..
fi

if [ "$SN" != "N" ]; then
    cd $1
    if [ -z "$CREATE" ]; then
        mensaje "Ejecutando composer install..."
        composer install
        mensaje "Ejecutando composer run-script post-create-project-cmd..."
        composer run-script post-create-project-cmd
    fi
    if [ -n "$VIRTUAL" ]; then
        if ! grep -qs "$1.local" /etc/hosts; then
            mensaje "Añadiendo entrada para $1.local en /etc/hosts..."
            if grep -qs "^$" /etc/hosts; then
                sudo sed -ie "s/^$/127.0.0.1	$1.local\n/" /etc/hosts
            else
                echo "127.0.0.1	$1.local" | sudo tee -a /etc/hosts > /dev/null
            fi
        else
            mensaje "Ya existe una entrada para $1.local en /etc/hosts."
        fi
        if [ ! -f "/etc/apache2/sites-available/$1.conf" ]; then
            mensaje "Creando sitio virtual $1.local en Apache2..."
            sudo cp $1.conf /etc/apache2/sites-available/$1.conf
            sudo a2ensite $1
            sudo service apache2 reload
        else
            mensaje "El sitio virtual $1.local ya existe en Apache2."
        fi
    fi
fi
