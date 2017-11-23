#!/bin/sh

. $(dirname $(readlink -f "$0"))/_lib/auxiliar.sh

netrc()
{
    if grep -qs "machine $1" ~/.netrc
    then
        perl -i -0pe "s/machine $1\n  login \w+\n  password \w+/machine $1\n  login $2\n  password $3/" ~/.netrc
    else
        asegura_salto_linea "$HOME/.netrc"
        echo "machine $1\n  login $2\n  password $3" >> ~/.netrc
    fi
}

git config --global alias.lg "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
git config --global push.default simple
# git config --global pull.rebase true

USER_NAME=$(git_user name)
if [ -n "$USER_NAME" ]
then
    echo -n "Configuración user.name ya creada. ¿Quieres cambiarla? (s/N): "
    read SN
    [ "$SN" = "s" ] && SN="S"
fi
if [ -z "$USER_NAME" ] || [ "$SN" = "S" ]
then
    echo -n "Nombre completo del programador: "
    read USER_NAME
    if [ -n "$USER_NAME" ]
    then
        echo "Creando configuración user.name..."
        git_user name "$USER_NAME"
    fi
fi

USER_EMAIL=$(git_user email)
if [ -n "$USER_EMAIL" ]
then
    echo -n "Configuración user.email ya creada. ¿Quieres cambiarla? (s/N): "
    read SN
    [ "$SN" = "s" ] && SN="S"
fi
if [ -z "$USER_EMAIL" ] || [ "$SN" = "S" ]
then
    echo -n "Dirección de email: "
    read USER_EMAIL
    if [ -n "$USER_EMAIL" ]
    then
        echo "Creando configuración user.email..."
        git_user email "$USER_EMAIL"
    fi
fi

if [ -z "$USER_NAME" ] || [ -z "$USER_EMAIL" ]
then
    echo "Configura el nombre y la dirección de email antes de continuar."
    exit 1
fi

USUARIO=$(github user)
if [ -n "$USUARIO" ]
then
    echo -n "Configuración github.user ya creada. ¿Quieres cambiarla? (s/N): "
    read SN
    [ "$SN" = "s" ] && SN="S"
fi
if [ -z "$USUARIO" ] || [ "$SN" = "S" ]
then
    echo -n "Nombre de usuario en GitHub (NO el email): "
    read USUARIO
    if [ -n "$USUARIO" ]
    then
        echo "Creando configuración github.user..."
        github user "$USUARIO"
    fi
fi

TOKEN=$(github token)
if [ -n "$TOKEN" ]
then
    echo -n "Token de GitHub ya creado. ¿Quieres cambiarlo? (s/N): "
    read SN
    [ "$SN" = "s" ] && SN="S"
fi
if [ -z "$TOKEN" ] || [ "$SN" = "S" ]
then
    DESC="Token de GitHub en $(hostname) $(date +%Y-%m-%d\ %H%M)"
    DESC=$(echo $DESC | tr " " "+")
    URL="https://github.com/settings/tokens/new?scopes=repo,gist&description=$DESC"
    xdg-open $URL >/dev/null 2>&1
    echo "Vete a $URL para crear un token, pulsa en 'Generate token', cópialo y pégalo aquí."
    echo -n "Token: "
    read TOKEN
    if [ -n "$TOKEN" ]
    then
        echo "Creando token de GitHub para git y ghi..."
        github token "$TOKEN"
        git config --global ghi.token $TOKEN
    fi
fi

if [ -n "$USUARIO" ] && [ -n "$TOKEN" ]
then
    echo "Creando entradas en ~/.netrc..."
    [ -f ~/.netrc ] || touch ~/.netrc
    netrc "github.com" $USUARIO $TOKEN
    netrc "api.github.com" $USUARIO $TOKEN
fi
