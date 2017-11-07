#!/bin/sh

BASE_DIR=$(dirname $(readlink -f "$0"))
. $BASE_DIR/_lib/auxiliar.sh

comprueba_php
comprueba_composer

while true
do
    if [ -z "$(token_composer)" ]
    then
        TOKEN=$(github token)
        if [ -n "$TOKEN" ]
        then
            echo "Creando token de GitHub para Composer..."
            token_composer $TOKEN
            break
        else
            echo "El token para GitHub no está definido aún."
            echo "Ejecuta el script git-config.sh antes de continuar."
            echo -n "¿Quieres hacerlo ahora? (s/N): "
            read SN
            if [ "$SN" = "S"  ] || [ "$SN" = "s"  ]
            then
                $BASE_DIR/git-config.sh
            else
                echo "Imposible continuar. Vuelve cuando hayas ejecutado el script git-config.sh"
                exit 1
            fi
        fi
    else
        echo "Token de GitHub para Composer ya creado."
        break
    fi
done

desactiva_xdebug
