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
P="postgresql-9.6 postgresql-client-9.6 postgresql-contrib-9.6"
echo "\033[1;32m\$\033[0m\033[35m sudo apt -y install $P\033[0m"
sudo apt -y install $P

