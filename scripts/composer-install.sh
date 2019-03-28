#!/bin/sh

. $(dirname "$(readlink -f "$0")")/_lib/auxiliar.sh

CALLA=$1

comprueba_php $CALLA

mensaje "Descargando y ejecutando instalador de composer..."

EXPECTED_SIGNATURE="$(curl -sL https://composer.github.io/installer.sig)"
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
ACTUAL_SIGNATURE="$(php -r "echo hash_file('sha384', 'composer-setup.php');")"

if [ "$EXPECTED_SIGNATURE" != "$ACTUAL_SIGNATURE" ]; then
    >&2 echo 'ERROR: Invalid installer signature'
    rm composer-setup.php
    exit 1
fi

php composer-setup.php --quiet
RESULT=$?
rm composer-setup.php
mensaje "Instalando en /usr/local/bin/composer..."
sudo install -p -o root -g root composer.phar /usr/local/bin/composer
rm composer.phar
desactiva_sudo "/usr/local/bin/composer"

if dpkg -s composer > /dev/null 2>&1; then
    mensaje "Desinstalando paquete composer de Apt..."
    sudo apt -y purge composer
fi

while true; do
    TOKEN=$(token_composer)
    if [ -z "$TOKEN" ]; then
        TOKEN=$(github token)
        if [ -n "$TOKEN" ]; then
            mensaje "Creando token de GitHub para Composer..."
            token_composer $TOKEN
            break
        else
            mensaje "El token para GitHub no está definido aún."
            mensaje "Ejecuta el script git-config.sh antes de continuar."
            pregunta SN "¿Quieres hacerlo ahora?" N $CALLA
            if [ "$SN" = "S" ]; then
                $BASE_DIR/git-config.sh
            else
                mensaje_error "Imposible continuar. Vuelve cuando hayas ejecutado el script git-config.sh"
                exit 1
            fi
        fi
    else
        GITHUB=$(github token)
        if [ "$TOKEN" != "$GITHUB" ]; then
            echo "Actualizando token de Composer para que coincida con el de GitHub..."
            token_composer $GITHUB
            break
        fi
        mensaje "Token de GitHub para Composer ya creado."
        break
    fi
done

desactiva_xdebug

exit $RESULT
