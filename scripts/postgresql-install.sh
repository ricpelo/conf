#!/bin/sh

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
if ! grep -qs "^intervalstyle = 'iso_8601'" $CONF
then
    echo "Estableciendo intervalstyle = 'iso_8601'..."
    sudo sed -r -i "s/^\s*#?intervalstyle\s*=/intervalstyle = 'iso_8601' #/" $CONF
else
    echo "Parámetro intervalstyle = 'iso_8601' ya establecido."
fi
if ! grep -qs "^timezone = 'UTC'" $CONF
then
    echo "Estableciendo timezone = 'UTC'..."
    sudo sed -r -i "s/^\s*#?timezone\s*=/timezone = 'UTC' #/" $CONF
else
    echo "Parámetro timezone = 'UTC ya establecido.'"
fi

sudo service postgresql restart

