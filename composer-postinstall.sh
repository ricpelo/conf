#!/bin/sh

if ! composer config -g github-oauth.github.com > /dev/null 2>&1
then
    DESC="Composer on $(hostname) $(date +%Y-%m-%d\ %H%M)"
    DESC=$(echo $DESC | tr " " "+")
    echo $DESC
    echo "Vete a https://github.com/settings/tokens/new?scopes=repo&description=$DESC"
    echo -n "Token: "
    read TOKEN
    composer config -g github-oauth.github.com $TOKEN
fi
if [ ! -d /opt/composer ]
then
    COMPOSER_DIR=$(composer config -g home)
    sudo ln -sf $COMPOSER_DIR /opt/composer
fi
composer global require --prefer-dist friendsofphp/php-cs-fixer squizlabs/php_codesniffer yiisoft/yii2-coding-standards phpmd/phpmd

