#!/bin/sh

. $(dirname $(readlink -f "$0"))/_lib/auxiliar.sh

CALLA=$1

lista_paquetes()
{
    echo "php$1 libapache2-mod-php$1 php$1-cli php$1-pgsql php$1-sqlite3 php$1-intl php$1-mbstring php$1-gd php$1-curl php$1-xml php$1-json php$1-zip php$1-common php$1-opcache php$1-readline libapache2-mod-php- php- php-cli- php-curl- php-gd- php-intl- php-json- php-mbstring- php-pgsql- php-sqlite3- php-xml-"
}

VER=7.1
EXTRA="apache2 php-xdebug sqlite sqlite3"

if [ ! -f /etc/apt/sources.list.d/ondrej-ubuntu-php-$(lsb_release -sc).list ]
then
    echo "Activando el repositorio de PHP..."
    sudo add-apt-repository --yes ppa:ondrej/php
    sudo apt update
else
    echo "Repositorio de PHP ya activado."
fi

echo "Desinstalando versiones innecesarias de PHP..."
P=""
for V in 5.6 7.0 7.1 7.2
do
    if [ "$V" != "$VER" ]
    then
        P="$P$(lista_paquetes $V) "
    fi
done
echo "\033[1;32m\$\033[0m\033[35m sudo apt -y purge $P\033[0m"
sudo apt -y purge $P

echo "Instalando paquetes de PHP..."
P=$(lista_paquetes $VER)
echo "\033[1;32m\$\033[0m\033[35m sudo apt -y install $P\033[0m"
sudo apt -y --purge install $P $EXTRA

activa_modulo_apache php$VER
activa_modulo_apache rewrite
desactiva_xdebug $VER

for p in apache2 cli
do
    CONF="/etc/php/$VER/$p/php.ini"
    asigna_param_php "error_reporting" "E_ALL" $CONF
    asigna_param_php "display_errors" "On" $CONF
    asigna_param_php "display_startup_errors" "On" $CONF
    asigna_param_php "date.timezone" "'UTC'" $CONF
done

echo "Reiniciando Apache 2..."
sudo service apache2 restart

DEST=/usr/local/bin/psysh
SN="S"
if [ -x $DEST ]
then
    pregunta SN "PsySH ya instalado. ¿Quieres actualizarlo?" S $CALLA
fi
if [ "$SN" = "S" ]
then
    echo "Instalando PsySH en $DEST..."
    sudo wget -q -O $DEST https://git.io/psysh
    sudo chmod a+x $DEST
    DEST=~/.local/share/psysh
    mkdir -p $DEST
    wget -q -O $DEST/php_manual.sqlite http://psysh.org/manual/es/php_manual.sqlite
fi
