#!/bin/sh

BASE_DIR=$(dirname $(readlink -f "$0"))

SLIST="git-config.sh php-install.sh postgresql-install.sh composer-install.sh
composer-postinstall.sh atom-postinstall.sh"

for p in $SLIST
do
    echo -n "¿Ejecutar $p? (s/N): "
    read SN
    if [ "$SN" = "S" ] || [ "$SN" = "s" ]
    then
        $BASE_DIR/$p
        echo ""
    fi
done

