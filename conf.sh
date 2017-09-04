#!/bin/sh

BASE_DIR=$(dirname $(readlink -f "$0"))

. $BASE_DIR/_lib/auxiliar.sh

if [ "$BASE_DIR" != "$PWD" ]
then
    echo "Error: debe ejecutar el script desde el directorio $BASE_DIR."
    exit 1
fi

git submodule update --init --recursive

PLIST="vim-nox-py2 zsh curl wget python-pip git build-essential python-pygments
sakura i3 nitrogen x11-xserver-utils xbase-clients xorg xdg-user-dirs tmux xcape
fluxgui ranger command-not-found fonts-freefont-ttf libnotify-bin xclip pcmanfm
powerline lxpolkit pulseaudio pasystray pavucontrol network-manager-gnome
exuberant-ctags atom"

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

for p in $PLIST
do
    if type fn_$p | grep -qs "is a shell function"
    then
        eval fn_$p
    fi
done

FONTS_DIR=~/.local/share/fonts

echo "Instalando tipografía Input Mono..."

mkdir -p $FONTS_DIR
cp -f fonts/InputMono/*.ttf $FONTS_DIR
fc-cache -f $FONTS_DIR

echo "Instalando tipografías Powerline..."
ACTUAL=$PWD
cd fonts/powerline-fonts
./install.sh
cd $ACTUAL

echo "Creando enlaces..."

BLIST=".zshrc .vimrc .gvimrc .vim .tmux.conf .dircolors .less .lessfilter .i3"

for p in $BLIST
do
    backup_and_link $p
done

[ -d ~/.config ] || mkdir ~/.config
backup_and_link sakura .config
backup_and_link dunst .config
backup_and_link powerline .config

[ -d ~/.local/bin ] || mkdir -p ~/.local/bin

local_bin unclutter
local_bin lesscurl
local_bin proyecto.sh

eval fn_vim

echo -n "¿Ejecutar los scripts adicionales? (s/N): "
read SN
if [ "$SN" = "S" ] || [ "$SN" = "s" ]
then
    scripts/scripts.sh
fi

