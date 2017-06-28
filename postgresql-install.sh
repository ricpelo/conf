#!/bin/sh

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
P="postgresql postgresql-9.6 postgresql-client postgresql-contrib pgadmin3"
echo "\$ sudo apt install $P"
sudo apt install $P

