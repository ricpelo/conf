#!/bin/sh

if [ ! -f /etc/apt/sources.list.d/ondrej-ubuntu-php-$(lsb_release -sc).list ]
then
    echo "Activando el repositorio de PHP..."
    sudo add-apt-repository --yes ppa:ondrej/php
    sudo apt update
else
    echo "Repositorio de PHP ya activado."
fi

echo "Instalando paquetes ensenciales de PHP..."
P="php php7.1 libapache2-mod-php php-cli"
echo "\033[1;32m\$\033[0m\033[35m sudo apt -y install $P\033[0m"
sudo apt -y install $P
echo "Instalando paquetes adicionales..."
P="php-pgsql php-sqlite3 sqlite php-intl php-mbstring php-gd php-curl php-xml php-xdebug php-json"
echo "\033[1;32m\$\033[0m\033[35m sudo apt -y install $P\033[0m"
sudo apt -y install $P

