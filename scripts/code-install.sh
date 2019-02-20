#!/bin/sh

BASE_DIR=$(dirname $(readlink -f "$0"))
. $BASE_DIR/_lib/auxiliar.sh

CALLA=$1

comprueba_php $CALLA
comprueba_composer $CALLA

if ! dpkg -s code >/dev/null 2>&1; then
    mensaje "Descargando e instalando Visual Studio Code..."
    TEMP_DEB="$(mktemp).deb"
    curl -sL -o $TEMP_DEB https://update.code.visualstudio.com/latest/linux-deb-x64/stable && sudo dpkg -i $TEMP_DEB
    rm -f $TEMP_DEB
fi

if ! dpkg -s code >/dev/null 2>&1; then
    mensaje_error "No se ha podido instalar Visual Studio Code. Imposible continuar."
    exit 1
fi

CONF=$HOME/.config/Code

if [ -d "$CONF" ]; then
    mensaje "Se ha detectado una configuración previa de Visual Studio Code en $CONF."
    pregunta SN "¿Eliminarla previamente para una instalación limpia?" N $CALLA
    if [ "$SN" = "S" ]; then
        mensaje "Eliminando directorio $CONF..."
        rm -rf $CONF
    else
        QUITAR=$(code --list-extensions | diff - $BASE_DIR/code/code-extensions.txt | grep "^< " | cut -c3-)
        if [ -n "$QUITAR" ]; then
            mensaje "Detectadas las siguienes extensiones sobrantes:"
            mensaje $QUITAR
            pregunta SN "¿Desinstalar extensiones sobrantes?" N $CALLA
            if [ "$SN" = "S" ]; then
                mensaje "Desinstalando extensiones sobrantes..."
                for p in $(echo $QUITAR); do
                    code --uninstall-extension $p
                done
            fi
        fi
    fi
fi

PONER=$(code --list-extensions | diff - $BASE_DIR/code/code-extensions.txt | grep "^> " | cut -c3-)
if [ -n "$PONER" ]; then
    for p in $(echo $PONER); do
        mensaje "Instalando extensión $p..."
        code --install-extension $p
    done
else
    mensaje "Ya están instaladas todas las extensiones de Visual Studio Code."
fi
