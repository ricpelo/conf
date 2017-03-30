#!/bin/sh

if [ -z "$1" ]; then
    echo "Sintaxis: $0 nombre"
    exit 1
fi

echo "Creando el proyecto desde la plantilla básica de Yii2..."
composer create-project yiisoft/yii2-app-basic $1
TEMP_ZIP=$(mktemp)
TEMP_DIR=$(mktemp -d)
echo "Descargando el esqueleto modificado del proyecto..."
/usr/bin/curl https://codeload.github.com/ricpelo/pre/zip/master > $TEMP_ZIP
echo "Extrayendo el esqueleto..."
/usr/bin/unzip $TEMP_ZIP -d $TEMP_DIR
echo "Eliminando archivos temporales..."
/bin/cp -rf $TEMP_DIR/pre-master/. $1
/bin/rm -r $TEMP_ZIP $TEMP_DIR
cd $1
echo "Modificando archivos con el nombre del proyecto..."
/bin/sed -i s/proyecto/$1/g db/* config/*
/bin/mv db/proyecto.sql db/$1.sql
echo "Ejecutando composer update..."
composer update
echo "Creando repositorio git..."
git init
git add .
git commit -m "Carga inicial"

