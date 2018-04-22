#!/bin/sh

BASE_DIR=$(dirname $(readlink -f "$0"))

. $BASE_DIR/_lib/auxiliar.sh
. $BASE_DIR/scripts/_lib/auxiliar.sh

if [ "$BASE_DIR" != "$PWD" ]
then
    echo "Error: debe ejecutar el script desde el directorio $BASE_DIR."
    exit 1
fi

git submodule update --init --recursive

if no_instalado "curl"
then
    echo "Instalando curl..."
    sudo apt update
    sudo apt install curl
else
    echo "Curl ya instalado."
fi

PLIST="zsh wget python-pip git build-essential python-pygments sakura i3
nitrogen x11-xserver-utils x11-utils xdg-user-dirs tmux xcape redshift ranger
command-not-found fonts-freefont-ttf libnotify-bin xsel pcmanfm powerline
lxpolkit pulseaudio pasystray pavucontrol network-manager-gnome exuberant-ctags
atom ruby ttf-ancient-fonts vim vim-gtk3"

P=""

for p in $PLIST
do
    if no_instalado $p
    then
        P="$P $p"
    fi
done

for p in $PLIST
do
    if type prefn_$p | grep -qs "is a shell function"
    then
        eval prefn_$p
    fi
done

if [ -n "$P" ]
then
    echo "Instalando paquetes..."
    sudo apt install -y $P
else
    echo "Paquetes ya instalados."
fi

FONTS_DIR=~/.local/share/fonts
FLIST="InputMono FiraCode mononoki"

mkdir -p $FONTS_DIR

for f in $FLIST
do
    echo "Instalando tipografía $f..."
    cp -f fonts/$f/* $FONTS_DIR
done
fc-cache -f $FONTS_DIR

echo "Instalando tipografías Powerline..."
ACTUAL=$PWD
cd fonts/powerline-fonts
./install.sh
cd $ACTUAL

echo "Creando enlaces..."

BLIST=".zshrc .vim .tmux.conf .dircolors .less .lessfilter .i3"

for p in $BLIST
do
    backup_and_link $p
done

[ -d ~/.config ] || mkdir ~/.config
backup_and_link sakura .config
backup_and_link dunst .config
backup_and_link powerline .config
backup_and_link htop .config

[ -d ~/.local/bin ] || mkdir -p ~/.local/bin

local_bin unclutter
local_bin xbanish
local_bin lesscurl
local_bin proyecto.sh

for p in $PLIST
do
    if type fn_$p | grep -qs "is a shell function"
    then
        eval fn_$p
    fi
done

if [ "$1" = "-q" ]
then
    SN="S"
else
    pregunta SN "¿Ejecutar los scripts adicionales?" N
fi
if [ "$SN" = "S" ]
then
    scripts/scripts.sh $*
fi
