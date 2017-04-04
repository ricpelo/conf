#!/bin/sh

echo "Instalando paquetes de Atom..."
apm install $(<atom-packages.txt)
if [ ! -f ~/.atom/config.cson ]
then
    echo "Copiando archivo config.cson en ~/.atom..."
    /bin/cp -f config.cson ~/.atom
else
    echo "Archivo config.cson ya copiado en ~/.atom."
fi

