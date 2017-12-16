#!/bin/sh

BASE_DIR=$(dirname $(readlink -f "$0"))

SLIST="git-config.sh php-install.sh postgresql-install.sh composer-install.sh
composer-postinstall.sh atom-postinstall.sh"

for p in $SLIST
do
    echo -n "¿Ejecutar $p? (S/n): "
    read SN
    if [ "$SN" != "N" ] && [ "$SN" != "n" ]
    then
        $BASE_DIR/$p
        echo ""
    fi
done
