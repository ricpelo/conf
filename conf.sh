#!/bin/sh

BASE_DIR=$(dirname "$(readlink -f "$0")")

. $BASE_DIR/_lib/auxiliar.sh
. $BASE_DIR/scripts/_lib/auxiliar.sh

if [ "$BASE_DIR" != "$PWD" ]; then
    echo "Error: debe ejecutar el script desde el directorio $BASE_DIR."
    exit 1
fi

if no_instalado "curl"; then
    mensaje "Instalando curl..."
    sudo apt update
    sudo apt install -y curl
else
    mensaje "Curl ya instalado."
fi

PLIST="curl xz-utils zsh wget git build-essential python3-pygments sakura i3
xinit py3status feh x11-xserver-utils x11-utils xdg-user-dirs ncurses-term
xcape rofi redshift nnn command-not-found fonts-freefont-ttf libnotify-bin xsel
fonts-powerline pulseaudio pasystray pavucontrol network-manager-gnome
policykit-1-gnome ttf-ancient-fonts gtk2-engines-murrine lxappearance
at-spi2-core vim vim-gtk3 scrot gh bat exa thunar picom p7zip-full htop evince
gvfs-backends gvfs-fuse obsidian-icon-theme"

# Preinstalación de paquetes
CAMBIA_APT=""
if ! fn "$PLIST" "pre"; then
    CAMBIA_APT="1"
fi

if [ -n "$CAMBIA_APT" ]; then
    mensaje "Actualizando lista de paquetes..."
    sudo apt update
fi

P=""

for p in $PLIST; do
    if no_instalado $p; then
        P="$P $p"
    fi
done

if [ -n "$P" ]; then
    mensaje "Instalando paquetes..."
    sudo apt install -y $P
else
    mensaje "Paquetes ya instalados."
fi

# Configuración de paquetes tras la instalación
fn "$PLIST"

FONTS_DIR=~/.local/share/fonts
FLIST="InputMono FiraCode mononoki nerd-fonts"
mkdir -p $FONTS_DIR
for f in $FLIST; do
    mensaje "Instalando tipografía $f..."
    cp -f fonts/$f/* $FONTS_DIR
done
fc-cache -f $FONTS_DIR

DEST="$BASE_DIR/fonts/powerline-fonts"
if [ ! -d "$DEST" ]; then
    mensaje "Instalando tipografías Powerline..."
    git clone --depth=1 https://github.com/powerline/fonts.git $DEST
    (cd $DEST && ./install.sh)
else
    mensaje "Actualizando tipografías Powerline..."
    (cd $DEST && git pull && ./install.sh)
fi

mensaje "Creando enlaces..."
BLIST=".xsessionrc .zprofile .dircolors .Xresources .gtkrc-2.0 .less
.lessfilter .terminfo .vimrc .nvidia-settings-rc"
for p in $BLIST; do
    backup_and_link $p
done
mkdir -p ~/.config
BLIST="sakura alacritty nvim dunst htop i3 rofi picom"
for p in $BLIST; do
    backup_and_link $p .config
done
mkdir -p ~/.mame
backup_and_link mame.ini .mame

mensaje "Instalando binarios locales..."
mkdir -p ~/.local/bin
BLIST="unclutter xbanish lesscurl proyecto.sh atom-handler.sh alacritty exa"
for p in $BLIST; do
    local_bin $p
done

# Postinstalación de paquetes
fn "$PLIST" "post"

# Hay que hacerlo después de haber post-instalado el zsh,
# o este lo machacará:
mensaje "Creando enlace a .zshrc..."
backup_and_link .zshrc

# Instalación de temas e iconos
DIR_THEMES=~/.local/share/themes
DIR_ICONS=~/.local/share/icons
instala_tema "$DIR_THEMES" Nordic-bluish-accent-standard-buttons-v40
instala_tema "$DIR_ICONS" NordArc-Icons
instala_tema "$DIR_ICONS" PolarCursorTheme
instala_tema "$DIR_ICONS" PolarCursorTheme-Blue
instala_tema "$DIR_ICONS" PolarCursorTheme-Green
crea_enlace_temas_iconos "~/.themes" "$DIR_THEMES"
crea_enlace_temas_iconos "~/.icons" "$DIR_ICONS"

if [ "$1" = "-q" ]; then
    SN="S"
else
    pregunta SN "¿Ejecutar los scripts adicionales?" N
fi
if [ "$SN" = "S" ]; then
    scripts/scripts.sh $*
fi
