#!/bin/sh

. $(dirname $(readlink -f "$0"))/_lib/auxiliar.sh

VER=7.1

if [ ! -f /etc/apt/sources.list.d/ondrej-ubuntu-php-$(lsb_release -sc).list ]
then
    echo "Activando el repositorio de PHP..."
    sudo add-apt-repository --yes ppa:ondrej/php
    sudo apt update
else
    echo "Repositorio de PHP ya activado."
fi

echo "Instalando paquetes ensenciales de PHP..."
P="php$VER apache2 libapache2-mod-php$VER php$VER-cli"
echo "\033[1;32m\$\033[0m\033[35m sudo apt -y install $P\033[0m"
sudo apt -y install $P
echo "Instalando paquetes adicionales..."
P="php$VER-pgsql php$VER-sqlite3 sqlite sqlite3 php$VER-intl php$VER-mbstring php$VER-gd php$VER-curl php$VER-xml php$VER-xdebug php$VER-json"
echo "\033[1;32m\$\033[0m\033[35m sudo apt -y install $P\033[0m"
sudo apt -y install $P

activa_modulo_apache php$VER
activa_modulo_apache rewrite
desactiva_xdebug

for p in apache2 cli
do
    CONF="/etc/php/$VER/$p/php.ini"
    if ! grep -qs "^date.timezone = 'UTC'$" $CONF
    then
        echo "Estableciendo date.timezone = 'UTC' en $CONF..."
        sudo sed -r -i "s/^;?\s*date\.timezone\s*=.*$/date\.timezone = 'UTC'/" $CONF
    else
        echo "Parámetro date.timezone = 'UTC' ya establecido en $CONF."
    fi
    if ! grep -qs "^display_errors = On$" $CONF
    then
        echo "Estableciendo display_errors = On en $CONF..."
        sudo sed -r -i "s/^;?\s*display_errors\s*=.*$/display_errors = On/" $CONF
    else
        echo "Parámetro display_errors = On ya establecido en $CONF."
    fi
    if ! grep -qs "^display_startup_errors = On$" $CONF
    then
        echo "Estableciendo display_startup_errors = On en $CONF..."
        sudo sed -r -i "s/^;?\s*display_startup_errors\s*=.*$/display_startup_errors = On/" $CONF
    else
        echo "Parámetro display_startup_errors = On ya establecido en $CONF."
    fi
done

sudo service apache2 restart

