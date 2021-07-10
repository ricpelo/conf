#!/bin/sh

. $(dirname "$(readlink -f "$0")")/_lib/auxiliar.sh

CALLA=$1

lista_paquetes()
{
    echo "php$1 php$1-cli php$1-cgi php$1-pgsql php$1-sqlite3 php$1-intl php$1-mbstring php$1-gd php$1-curl php$1-xml php$1-zip php$1-common php$1-opcache php$1-readline php$1-xdebug php$1-amqp php$1-redis libapache2-mod-php- php- php-cli- php-curl- php-gd- php-intl- php-json- php-mbstring- php-pgsql- php-sqlite3- php-xml- php-xdebug-"
}

VER=8.0
EXTRA="sqlite sqlite3"

if [ ! -f /etc/apt/sources.list.d/ondrej-ubuntu-php-$(lsb_release -sc).list ]; then
    mensaje "Activando el repositorio de PHP..."
    sudo add-apt-repository --yes ppa:ondrej/php
else
    mensaje "Repositorio de PHP ya activado."
fi

mensaje "Desinstalando versiones innecesarias de PHP..."
P=""
Q=""
for V in 5.6 7.0 7.1 7.2 7.3 7.4 8.0; do
    if [ "$V" != "$VER" ]
    then
        P="$P$(lista_paquetes $V) "
        Q="$Q php$V-json-"
    fi
done
echo "\033[1;32m\$\033[0m\033[35m sudo apt -y purge $P $Q\033[0m"
sudo apt -y purge $P $Q

mensaje "Instalando paquetes de PHP..."
P=$(lista_paquetes $VER)
echo "\033[1;32m\$\033[0m\033[35m sudo apt -y install $P $EXTRA\033[0m"
sudo apt -y --purge install $P $EXTRA

activa_xdebug $VER cli
#activa_xdebug_remoto $VER

CONF="/etc/php/$VER/cli/php.ini"
asigna_param_php "error_reporting" "E_ALL" $CONF
asigna_param_php "display_errors" "On" $CONF
asigna_param_php "display_startup_errors" "On" $CONF
asigna_param_php "date.timezone" "'UTC'" $CONF

DEST=/usr/local/bin/psysh
SN="S"
if [ -x $DEST ]; then
    pregunta SN "PsySH ya instalado. ¿Quieres actualizarlo?" S $CALLA
fi
if [ "$SN" = "S" ]; then
    mensaje "Instalando PsySH en $DEST..."
    sudo curl -sL -o $DEST https://psysh.org/psysh
    sudo chmod a+x $DEST
    DEST=~/.local/share/psysh
    mkdir -p $DEST
    curl -sL -o $DEST/php_manual.sqlite http://psysh.org/manual/es/php_manual.sqlite
fi
