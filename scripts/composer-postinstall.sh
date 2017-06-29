#!/bin/sh

. $(dirname $(readlink -f "$0"))/_lib/auxiliar.sh

if [ -z "$(token_github)" ]
then
    DESC="Composer and Gist on $(hostname) $(date +%Y-%m-%d\ %H%M)"
    DESC=$(echo $DESC | tr " " "+")
    xdg-open "https://github.com/settings/tokens/new?scopes=repo,gist&description=$DESC"
    echo "Vete a https://github.com/settings/tokens/new?scopes=repo,gist&description=$DESC para crear un token, pulsa en 'Generate token', cópialo y pégalo aquí."
    echo -n "Token: "
    read TOKEN
    echo "Creando token de GitHub para Composer..."
    token_github $TOKEN
else
    echo "Token de GitHub ya creado."
fi
if [ ! -d /opt/composer ]
then
    echo "Creando enlace simbólico de /opt/composer a $COMPOSER_DIR..."
    COMPOSER_DIR=$(composer config -g home)
    sudo ln -sf $COMPOSER_DIR /opt/composer
else
    echo "Enlace simbólico /opt/composer ya creado."
fi
echo "Instalando paquetes globales interesantes para proyectos..."
composer global require --prefer-dist friendsofphp/php-cs-fixer "squizlabs/php_codesniffer:^2.0" yiisoft/yii2-coding-standards

