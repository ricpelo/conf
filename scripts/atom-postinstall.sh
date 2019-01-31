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
mensaje "Definiendo manejador para URLs ide://..."
HANDLER_SH="atom-handler.sh"
HANDLER_DESKTOP="atom-handler.desktop"
LOCAL_BIN="$HOME/.local/bin"
LOCAL_BIN_SH="$LOCAL_BIN/$HANDLER_SH"
APP_DIR="$HOME/.local/share/applications"
if [ ! -e "$LOCAL_BIN_SH" ]; then
    mensaje "Creando enlace simbólico para $HANDLER_SH..."
    RP=$(realpath -s --relative-to $LOCAL_BIN $BASE_DIR/../bin/$HANDLER_SH)
    ln -sf $RP $LOCAL_BIN_SH
fi
mkdir -p $APP_DIR
cp -f $BASE_DIR/atom/$HANDLER_DESKTOP $APP_DIR
update-desktop-database $APP_DIR
xdg-mime default $HANDLER_DESKTOP x-scheme-handler/ide
desactiva_sudo "/usr/bin/apm"
desactiva_sudo "/usr/bin/atom"
