#!/bin/sh

BASE_DIR=$(dirname $(readlink -f "$0"))

. $BASE_DIR/_lib/auxiliar.sh
. $BASE_DIR/scripts/_lib/auxiliar.sh

if [ "$BASE_DIR" != "$PWD" ]; then
    echo "Error: debe ejecutar el script desde el directorio $BASE_DIR."
    exit 1
fi

git submodule update --init --recursive

if no_instalado "curl"; then
    echo "Instalando curl..."
    sudo apt update
    sudo apt install curl
else
    echo "Curl ya instalado."
fi

PLIST="zsh wget python-pip git build-essential python-pygments sakura i3
feh x11-xserver-utils x11-utils xdg-user-dirs tmux ncurses-term xcape
redshift ranger command-not-found fonts-freefont-ttf libnotify-bin xsel pcmanfm
powerline lxpolkit pulseaudio pasystray pavucontrol network-manager-gnome
exuberant-ctags atom ruby ttf-ancient-fonts at-spi2-core vim vim-gtk3 emacs"

# Preinstalación de paquetes
fn "$PLIST" "pre"

P=""

for p in $PLIST; do
    if no_instalado $p; then
        P="$P $p"
    fi
done

if [ -n "$P" ]; then
    echo "Instalando paquetes..."
    sudo apt install -y $P
else
    echo "Paquetes ya instalados."
fi

# Configuración de paquetes tras la instalación
fn "$PLIST"

FONTS_DIR=~/.local/share/fonts
FLIST="InputMono FiraCode mononoki nerd-fonts"
mkdir -p $FONTS_DIR
for f in $FLIST; do
    echo "Instalando tipografía $f..."
    cp -f fonts/$f/* $FONTS_DIR
done
fc-cache -f $FONTS_DIR

echo "Instalando tipografías Powerline..."
(cd fonts/powerline-fonts && ./install.sh)

echo "Creando enlaces..."
BLIST=".zshrc .tmux.conf .dircolors .Xresources .less .lessfilter .i3 .terminfo .vimrc .spacemacs"
for p in $BLIST; do
    backup_and_link $p
done
[ -d ~/.config ] || mkdir ~/.config
backup_and_link sakura .config
backup_and_link dunst .config
backup_and_link powerline .config
backup_and_link htop .config

echo "Instalando binarios locales..."
[ -d ~/.local/bin ] || mkdir -p ~/.local/bin
local_bin unclutter
local_bin xbanish
local_bin lesscurl
local_bin proyecto.sh

# Postinstalación de paquetes
fn "$PLIST" "post"

if [ "$1" = "-q" ]; then
    SN="S"
else
    pregunta SN "¿Ejecutar los scripts adicionales?" N
fi
if [ "$SN" = "S" ]; then
    scripts/scripts.sh $*
fi
