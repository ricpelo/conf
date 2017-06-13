#!/bin/sh

P=""
for p in $(cat atom-packages.txt)
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
    echo "Todos los paquetes de Atom ya copiados."
fi
p="php-integrator-symbol-viewer"
if [ ! -d ~/.atom/packages/$p ]
then
    apm install ricpelo/$p
fi
echo "Copiando archivo config.cson en ~/.atom..."
cp -f config.cson ~/.atom

