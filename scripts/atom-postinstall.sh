#!/bin/sh

BASE_DIR=$(dirname $(readlink -f "$0"))
. $BASE_DIR/_lib/auxiliar.sh

comprueba_atom
comprueba_php
comprueba_composer

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
for f in keymap.cson config.cson; do
    [ -f ~/.atom/$f ] && mv -f ~/.atom/$f ~/.atom/$f.viejo
    cp -f $BASE_DIR/atom/$f ~/.atom
done
asegura_salto_linea_sudoers
desactiva_sudo "/usr/bin/apm"
desactiva_sudo "/usr/bin/atom"

