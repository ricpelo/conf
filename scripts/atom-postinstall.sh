#!/bin/sh

BASE_DIR=$(dirname $(readlink -f "$0"))
. $BASE_DIR/_lib/auxiliar.sh

comprueba_atom
comprueba_php
comprueba_composer

CONF=$HOME/.atom

if [ -d "$CONF" ]
then
    echo "Se ha detectado una configuración previa de Atom en $CONF."
    echo -n "¿Eliminarla previamente para una instalación limpia? (S/n): "
    read SN
    [ "$SN" = "n" ] && SN="N"
    if [ "$SN" != "N" ]
    then
        echo "Eliminando directorio $CONF..."
        rm -rf $CONF
    else
        QUITAR=$(apm list --installed --bare | cut -d"@" -f1 | diff - $BASE_DIR/atom/atom-packages.txt | grep "^< " | cut -c3-)
        if [ -n "$QUITAR" ]
        then
            echo -n "¿Desinstalar paquetes sobrantes? (s/N): "
            read SN
            [ "$SN" = "s" ] && SN="S"
            if [ "$SN" = "S" ]
            then
                echo "Desinstalando paquetes sobrantes..."
                for p in $(echo $QUITAR)
                do
                    apm uninstall $p
                done
            fi
        fi
    fi
fi

P=""
for p in $(cat $BASE_DIR/atom/atom-packages.txt)
do
    if [ ! -d "$CONF/packages/$p" ]
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
echo "Copiando archivos de configuración en $CONF..."
for f in keymap.cson config.cson snippets.cson styles.less; do
    [ -f "$CONF/$f" ] && mv -f "$CONF/$f" "$CONF/$f.viejo"
    cp -f $BASE_DIR/atom/$f $CONF
done
asegura_salto_linea_sudoers
desactiva_sudo "/usr/bin/apm"
desactiva_sudo "/usr/bin/atom"
