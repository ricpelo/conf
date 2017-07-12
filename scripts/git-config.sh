#!/bin/sh

. $(dirname $(readlink -f "$0"))/_lib/auxiliar.sh

git config --global alias.lg "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
git config --global push.default simple
# git config --global pull.rebase true

netrc()
{
    if grep -qs "machine $1" ~/.netrc
    then
        perl -i -0pe "s/machine $1\n  login \w+\n  password \w+/machine $1\n  login $NOMBRE\n  password $TOKEN/" ~/.netrc
    else
        asegura_salto_linea "$HOME/.netrc"
        echo "machine $1\n  login $NOMBRE\n  password $TOKEN" >> ~/.netrc
    fi
}

TOKEN=$(token_github)
if [ -n "$TOKEN" ]
then
    echo -n "Nombre de usuario en GitHub (NO el email): "
    read NOMBRE
    [ -f ~/.netrc ] || touch ~/.netrc
    netrc "github.com"
    netrc "api.github.com"
fi

