#!/bin/sh

. $(dirname $(readlink -f "$0"))/_lib/auxiliar.sh

VER=9.6

if [ ! -f /etc/apt/sources.list.d/pgdg.list ]
then
    echo "Activando el repositorio de PostgreSQL..."
    echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -sc)-pgdg main" | sudo tee /etc/apt/sources.list.d/pgdg.list > /dev/null
    if ! apt-key list | grep -qs ACCC4CF8
    then
        wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
    fi
    sudo apt update
else
    echo "Repositorio de PostgreSQL ya activado."
fi

echo "Instalando paquetes de PostgreSQL..."
P="postgresql-$VER postgresql-client-$VER postgresql-contrib-$VER"
echo "\033[1;32m\$\033[0m\033[35m sudo apt -y install $P\033[0m"
sudo apt -y install $P

CONF="/etc/postgresql/$VER/main/postgresql.conf"
asigna_param_postgresql "intervalstyle" "'iso_8601'" $CONF
asigna_param_postgresql "timezone" "'UTC'" $CONF
asigna_param_postgresql "lc_messages" "'en_US.UTF-8'" $CONF
asigna_param_postgresql "lc_monetary" "'en_US.UTF-8'" $CONF
asigna_param_postgresql "lc_numeric" "'en_US.UTF-8'" $CONF
asigna_param_postgresql "lc_time" "'en_US.UTF-8'" $CONF
asigna_param_postgresql "default_text_search_config" "'pg_catalog.english'" $CONF

sudo service postgresql restart

