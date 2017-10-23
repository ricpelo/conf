#!/bin/sh

. $(dirname $(readlink -f "$0"))/_lib/auxiliar.sh

if [ ! -f /etc/apt/sources.list.d/ondrej-ubuntu-php-$(lsb_release -sc).list ]
then
    echo "Activando el repositorio de PHP..."
    sudo add-apt-repository --yes ppa:ondrej/php
    sudo apt update
else
    echo "Repositorio de PHP ya activado."
fi

echo "Instalando paquetes ensenciales de PHP..."
P="php7.1 apache2 libapache2-mod-php7.1 php7.1-cli"
echo "\033[1;32m\$\033[0m\033[35m sudo apt -y install $P\033[0m"
sudo apt -y install $P
echo "Instalando paquetes adicionales..."
P="php7.1-pgsql php7.1-sqlite3 sqlite sqlite3 php7.1-intl php7.1-mbstring php7.1-gd php7.1-curl php7.1-xml php7.1-xdebug php7.1-json"
echo "\033[1;32m\$\033[0m\033[35m sudo apt -y install $P\033[0m"
sudo apt -y install $P

activa_modulo_apache php7.1
activa_modulo_apache rewrite
desactiva_xdebug

