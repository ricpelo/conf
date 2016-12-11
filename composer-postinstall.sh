#!/bin/sh

DESC="Composer on $(hostname) $(date +%Y-%m-%d\ %H%M)"
DESC=$(echo $DESC | tr " " "+")
echo $DESC
echo "Vete a https://github.com/settings/tokens/new?scopes=repo&description=$DESC"
echo -n "Token: "
read TOKEN
composer global config -g github-oauth.github.com $TOKEN

