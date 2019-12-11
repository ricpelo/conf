#!/bin/sh

. $(dirname "$(readlink -f "$0")")/_lib/auxiliar.sh

CALLA=$1

lista_paquetes()
{
    echo "postgresql-$1 postgresql-client-$1"
}

VER=12

LIST=/etc/apt/sources.list.d/pgdg.list
if [ ! -f $LIST ]; then
    mensaje "Activando el repositorio de PostgreSQL..."
    echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -sc)-pgdg main" | sudo tee $LIST > /dev/null
    if ! apt-key list | grep -qs ACCC4CF8; then
        curl -sL https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
    fi
    sudo apt update
else
    mensaje "Repositorio de PostgreSQL ya activado."
fi

mensaje "Instalando paquetes de PostgreSQL..."
P=$(lista_paquetes $VER)
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

for OLD in 9.6 10 11; do
    if [ "$OLD" != "$VER" ]; then
        if [ -d /etc/postgresql/$OLD ]; then
            mensaje "Se ha detectado la versión $OLD anterior."
            pregunta SN "¿Migrar los datos a la versión $VER y desinstalar la $OLD?" S $CALLA
            if [ "$SN" = "S" ]; then
                mensaje "Eliminando clúster main de la versión $VER..."
                sudo pg_dropcluster --stop $VER main
                mensaje "Migrando clúster main a la versión $VER..."
                sudo pg_upgradecluster -m upgrade $OLD main
            fi
            pregunta SN "¿Desinstalar la versión $OLD anterior?" S $CALLA
            if [ "$SN" = "S" ]; then
                P=$(lista_paquetes $OLD)
            fi
            echo "\033[1;32m\$\033[0m\033[35m sudo apt -y --purge remove $P\033[0m"
            sudo apt -y --purge remove $P
        fi
    fi
done

mensaje "Reiniciando PostgreSQL..."
sudo service postgresql restart
