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
if [ "`sudo cat /etc/sudoers | tail -c1`" != "" ]
then
    echo "" | sudo tee -a /etc/sudoers > /dev/null
fi
L="%sudo	ALL=!/usr/bin/apm"
if ! sudo cat /etc/sudoers | grep -qs "$L"
then
    echo "Desactivando el uso de apm con sudo..."
    echo "$L" | sudo tee -a /etc/sudoers > /dev/null
else
    echo "Uso de apm con sudo ya desactivado."
fi
L="%sudo	ALL=!/usr/bin/atom"
if ! sudo cat /etc/sudoers | grep -qs "$L"
then
    echo "Desactivando el uso de atom con sudo..."
    echo "$L" | sudo tee -a /etc/sudoers > /dev/null
else
    echo "Uso de atom con sudo ya desactivado."
fi

