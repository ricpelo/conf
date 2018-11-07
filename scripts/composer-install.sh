#!/bin/sh

. $(dirname $(readlink -f "$0"))/_lib/auxiliar.sh

CALLA=$1

comprueba_php $CALLA

mensaje "Descargando y ejecutando instalador de composer..."

EXPECTED_SIGNATURE="$(wget -q -O - https://composer.github.io/installer.sig)"
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
ACTUAL_SIGNATURE="$(php -r "echo hash_file('sha384', 'composer-setup.php');")"

if [ "$EXPECTED_SIGNATURE" != "$ACTUAL_SIGNATURE" ]; then
    >&2 echo 'ERROR: Invalid installer signature'
    rm composer-setup.php
    exit 1
fi

php composer-setup.php --quiet
RESULT=$?
rm composer-setup.php
mensaje "Instalando en /usr/local/bin/composer..."
sudo install -p -o root -g root composer.phar /usr/local/bin/composer
rm composer.phar
asegura_salto_linea_sudoers
desactiva_sudo "/usr/local/bin/composer"

if dpkg -s composer > /dev/null 2>&1; then
    mensaje "Desinstalando paquete composer de Apt..."
    sudo apt -y purge composer
fi

exit $RESULT
