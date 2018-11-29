#!/bin/sh

BASE_DIR=$(dirname $(readlink -f "$0"))
. $BASE_DIR/_lib/auxiliar.sh

CALLA=$1

comprueba_atom
comprueba_php $CALLA
comprueba_composer $CALLA

CONF=$HOME/.atom

if [ -d "$CONF" ]; then
    mensaje "Se ha detectado una configuración previa de Atom en $CONF."
    pregunta SN "¿Eliminarla previamente para una instalación limpia?" N $CALLA
    if [ "$SN" = "S" ]; then
        mensaje "Eliminando directorio $CONF..."
        rm -rf $CONF
        mensaje "Eliminando caché de php-ide-serenata..."
        rm -rf $HOME/.cache/php-ide-serenata
    else
        QUITAR=$(apm list --installed --bare | cut -d"@" -f1 | diff - $BASE_DIR/atom/atom-packages.txt | grep "^< " | cut -c3-)
        if [ -n "$QUITAR" ]; then
            mensaje "Detectados los siguienes paquetes sobrantes:"
            mensaje $QUITAR
            pregunta SN "¿Desinstalar paquetes sobrantes?" N $CALLA
            if [ "$SN" = "S" ]; then
                mensaje "Desinstalando paquetes sobrantes..."
                for p in $(echo $QUITAR); do
                    apm uninstall $p
                done
            fi
        fi
    fi
fi

P=""
for p in $(cat $BASE_DIR/atom/atom-packages.txt); do
    if [ ! -d "$CONF/packages/$p" ]; then
        P="$P$p "
    fi
done
if [ -n "$P" ]; then
    mensaje "Instalando paquetes de Atom..."
    apm install $P
else
    mensaje "Todos los paquetes de Atom ya instalados."
fi
mensaje "Copiando archivos de configuración en $CONF..."
for f in keymap.cson config.cson snippets.cson styles.less; do
    [ -f "$CONF/$f" ] && mv -f "$CONF/$f" "$CONF/$f.viejo"
    cp -f $BASE_DIR/atom/$f $CONF
done
asegura_salto_linea_sudoers
desactiva_sudo "/usr/bin/apm"
desactiva_sudo "/usr/bin/atom"
