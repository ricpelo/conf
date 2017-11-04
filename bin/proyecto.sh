#!/bin/sh

ayuda()
{
    echo "\nSintaxis: $(basename $0) [-d] <nombre>\n"
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
        echo "Eliminando proyecto $2..."
        if [ -d $2 ]; then
            sudo rm -rf $2
        fi
        sudo sed -i /$2.local/d /etc/hosts
        sudo a2dissite $2
        sudo rm -f /etc/apache2/sites-available/$2.conf
        sudo service apache2 reload
        exit 0
    fi
fi

echo "Creando el proyecto desde la plantilla básica de Yii2..."
composer create-project --no-install --no-scripts yiisoft/yii2-app-basic $1
echo "Creando repositorio git..."
cd $1
git init -q
git add .
git commit -q -m "Carga incial"
cd ..
echo "Extrayendo el esqueleto modificado del proyecto..."
curl -s -L https://github.com/ricpelo/pre/tarball/master | tar xz --strip 1 -C $1
cd $1
echo "Modificando configuración del proyecto..."
for p in config/web.php config/console.php
do
     sed -r -zi "s%(\s*)'log' => \[.*\1\],\1'%\1'log' => require(__DIR__ . '/log.php'),\1'%" $p
done
echo "\n\n.php_cs.cache" >> .gitignore
echo "tests/chromedriver" >> .gitignore
echo "Modificando archivos con el nombre del proyecto..."
sed -i s/proyecto/$1/g db/* config/* .travis.yml
mv db/proyecto.sql db/$1.sql
mv proyecto.conf $1.conf
sed -i s/proyecto/$1/g $1.conf
echo "Ejecutando composer install..."
composer install --no-scripts
echo "Ejecutando composer run-script post-create-project-cmd..."
composer run-script post-create-project-cmd
echo "Eliminando espacios en blanco sobrantes de config/test.php..."
sed -i 's/[[:blank:]]*$//' config/test.php
echo "Creando nuevo commit..."
git checkout -- README.md
git add .
git commit -q -m "Cambios de la plantilla del proyecto"
if ! grep -qs "$1.local" /etc/hosts
then
    echo "Añadiendo entrada para $1.local en /etc/hosts..."
    if grep -qs "^$" /etc/hosts
    then
        sudo sed -ie "s/^$/127.0.0.1	$1.local\n/" /etc/hosts
    else
        echo "127.0.0.1	$1.local" | sudo tee -a /etc/hosts
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

