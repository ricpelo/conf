#!/bin/sh

. $(dirname "$(readlink -f "$0")")/_lib/auxiliar.sh

CALLA=$1
HUB_VERSION="2.8.3"

netrc()
{
    if grep -qs "machine $1" ~/.netrc; then
        perl -i -0pe "s/machine $1\n  login \w+\n  password \w+/machine $1\n  login $2\n  password $3/" ~/.netrc
    else
        asegura_salto_linea "$HOME/.netrc"
        echo "machine $1\n  login $2\n  password $3" >> ~/.netrc
    fi
}

crear_usuario_github()
{
    mensaje_n "Nombre de usuario en GitHub (NO el email): "
    read USUARIO
    if [ -n "$USUARIO" ]; then
        mensaje "Creando configuración github.user..."
        github user "$USUARIO"
    fi
}

git config --global alias.lg "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
git config --global push.default simple
# git config --global pull.rebase true

USER_NAME=$(git_user name)
if [ -n "$USER_NAME" ]; then
    pregunta SN "Configuración user.name ya creada. ¿Quieres cambiarla?" N $CALLA
fi
if [ -z "$USER_NAME" ] || [ "$SN" = "S" ]; then
    mensaje_n "Nombre completo del programador: "
    read USER_NAME
    if [ -n "$USER_NAME" ]; then
        mensaje "Creando configuración user.name..."
        git_user name "$USER_NAME"
    fi
fi

USER_EMAIL=$(git_user email)
if [ -n "$USER_EMAIL" ]; then
    pregunta SN "Configuración user.email ya creada. ¿Quieres cambiarla?" N $CALLA
fi
if [ -z "$USER_EMAIL" ] || [ "$SN" = "S" ]; then
    mensaje_n "Dirección de email: "
    read USER_EMAIL
    if [ -n "$USER_EMAIL" ]; then
        mensaje "Creando configuración user.email..."
        git_user email "$USER_EMAIL"
    fi
fi

if [ -z "$USER_NAME" ] || [ -z "$USER_EMAIL" ]; then
    mensaje_error "Configura el nombre y la dirección de email antes de continuar."
    exit 1
fi

USUARIO=$(github user)
if [ -n "$USUARIO" ]; then
    pregunta SN "Configuración github.user ya creada. ¿Quieres cambiarla?" N $CALLA
fi
if [ -z "$USUARIO" ] || [ "$SN" = "S" ]; then
    crear_usuario_github
fi

TOKEN=$(github token)
if [ -n "$TOKEN" ]; then
    pregunta SN "Token de GitHub ya creado. ¿Quieres cambiarlo?" N $CALLA
fi
if [ -z "$TOKEN" ] || [ "$SN" = "S" ]; then
    if [ -z "$USUARIO" ]; then
        mensaje "Para crear el token, debes indicar tu nombre de usuario en GitHub."
        pregunta "¿Quieres indicarlo ahora?" S $CALLA
        if [ "$SN" = "S" ]; then
            crear_usuario_github
        fi
    fi
    if [ -n "$USUARIO" ]; then
        GENERAR="S"
        while true; do
            if [ "$GENERAR" = "S" ]; then
                DESC="$(hostname) $(date +%Y-%m-%d\ %H:%M)"
                DESC=$(echo $DESC | tr " " "+")
                URL="https://github.com/settings/tokens/new?scopes=repo,workflow,gist,read:org,read:discussion&description=$DESC"
                mensaje "1. Vete a $URL"
                mensaje "2. No cambies nada en esa página"
                mensaje "3. Pulsa directamente en 'Generate token' al final de la página"
                mensaje "4. Copia y pega el token aquí."
                read -p "(Pulsa Entrar para abrir una ventana del navegador en esa dirección.)" _DUMMY
                xdg-open $URL >/dev/null 2>&1
            fi
            while true; do
                echo -n "Token: "
                read TOKEN
                if [ -n "$TOKEN" ]; then
                    break
                else
                    mensaje "Ha introducido un token vacío"
                    pregunta CANCELAR "¿Quiere cancelar la generación del token?" S $CALLA
                    if [ "$CANCELAR" = "S" ]; then
                        break
                    fi
                fi
            done
            if [ -n "$TOKEN" ]; then
                mensaje "Creando token de GitHub para git..."
                github token "$TOKEN"
                mensaje "Comprobando token..."
                RES=$(curl -s -X GET -u $USUARIO:$TOKEN https://api.github.com/user | grep '"login"')
                RES=$(echo $RES | cut -d":" -f2 | tr -d '", ')
                if [ "$USUARIO" = "$RES" ]; then
                    mensaje "Comprobación correcta"
                    mensaje "** Para que el cambio tenga efecto hay que cerrar la terminal y abrir otra **"
                    break
                else
                    mensaje_error "El token no es correcto."
                    pregunta GENERAR "¿Quiere volver a generar el token en GitHub?" N $CALLA
                fi
            elif [ "$CANCELAR" = "S" ]; then
                TOKEN=""
                break
            fi
        done
    fi
fi

if [ -n "$TOKEN" ]; then
    DEST=/usr/local/bin/ghi
    SN="S"
    if [ -x $DEST ]; then
        pregunta SN "Ghi ya instalado. ¿Quieres actualizarlo?" S $CALLA
    fi
    if [ "$SN" = "S" ]; then
        mensaje "Instalando ghi en $DEST..."
        curl -sL "https://raw.githubusercontent.com/drazisil/ghi/master/ghi" | sudo tee $DEST > /dev/null
        sudo chmod a+x $DEST
    fi
    mensaje "Asignando parámetro ghi.token..."
    git config --global ghi.token $TOKEN
    DEST=/usr/local/bin/hub
    SN="S"
    if [ -x $DEST ]; then
        pregunta SN "GitHub-hub ya instalado. ¿Quieres actualizarlo?" S $CALLA
    fi
    if [ "$SN" = "S" ]; then
        mensaje "Instalando GitHub-hub en $DEST..."
        FILE="hub-linux-amd64-$HUB_VERSION"
        curl -sL "https://github.com/github/hub/releases/download/v$HUB_VERSION/$FILE.tgz" | tar xfz - --strip=2 "$FILE/bin/hub" -O | sudo tee $DEST > /dev/null
        sudo chmod a+x $DEST
    fi
    mensaje "Asignando parámetro hub.protocol = https..."
    git config --global hub.protocol https
    DEST=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/hub.zsh
    mensaje "Creando variable de entorno GITHUB_TOKEN en $DEST..."
    echo "export GITHUB_TOKEN=$TOKEN" > $DEST
    DEST=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/jekyll.zsh
    mensaje "Creando variable de entorno JEKYLL_GITHUB_TOKEN en $DEST..."
    echo "export JEKYLL_GITHUB_TOKEN=$TOKEN" > $DEST
fi

if [ -n "$USUARIO" ] && [ -n "$TOKEN" ]; then
    mensaje "Creando entradas en ~/.netrc..."
    [ -f ~/.netrc ] || touch ~/.netrc || chmod 600 ~/.netrc
    netrc "github.com" $USUARIO $TOKEN
    netrc "api.github.com" $USUARIO $TOKEN
fi

desactiva_sudo "/usr/bin/git"
