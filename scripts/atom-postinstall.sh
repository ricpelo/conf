#!/bin/sh

BASE_DIR=$(dirname $(readlink -f "$0"))
. $BASE_DIR/_lib/auxiliar.sh

P=""
for p in $(cat $BASE_DIR/atom/atom-packages.txt)
do
    if [ ! -d ~/.atom/packages/$p ]
    then
        P="$P$p "
    fi
done
if [ -n "$P" ]
then
    echo "Instalando paquetes de Atom..."
    apm install $P
else
    echo "Todos los paquetes de Atom ya instalados."
fi
echo "Copiando archivos de configuración en ~/.atom..."
cp -f $BASE_DIR/atom/config.cson ~/.atom
cp -f $BASE_DIR/atom/keymap.cson ~/.atom
asegura_salto_linea_sudoers
desactiva_sudo "/usr/bin/apm"
desactiva_sudo "/usr/bin/atom"

