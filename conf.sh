#!/bin/sh

PLIST="vim zsh curl python-pip git build-essential python-pygments sakura i3
unclutter nitrogen x11-xserver-utils xbase-clients xorg xdg-user-dirs
ranger command-not-found fonts-freefont-ttf libnotify-bin xclip pcmanfm
lxpolkit volumeicon-alsa"

fn_zsh()
{
    if [ ! -d ~/.oh-my-zsh ]
    then
        echo "Instalando Oh My ZSH..."
        curl -L http://install.ohmyz.sh | sh
    else
        echo "Oh My ZSH ya instalado."
    fi
    if grep $USER /etc/passwd | grep -vqs zsh
    then
        echo "Instalando ZSH al usuario actual..."
        sudo chsh -s /bin/zsh $USER
    else
        echo "Zsh ya asignado al usuario actual."
    fi
}

fn_sakura()
{
    if ! update-alternatives --query x-terminal-emulator | grep -qs "^Value:.*sakura"
    then
        echo "Estableciendo sakura como terminal predeterminado..."
        sudo update-alternatives --set x-terminal-emulator /usr/bin/sakura
    else
        echo "sakura ya es el terminal predeterminado."
    fi
}

P=""

for p in $PLIST
do
    if ! dpkg -s $p > /dev/null 2>&1
    then
        P="$p $P"
    fi
done

if [ -n "$P" ]
then
    echo "Instalando paquetes..."
    sudo apt-get install -y $P
else
    echo "Paquetes ya instalados."
fi

nombre_paquete()
{
    echo -n "$1"
    [ -n "$2" ] && echo -n " versión $2 ó superior"

}

paquete_local()
{
    COND=""

    if [ -n "$2" ]
    then
        ! dpkg -s $1 > /dev/null 2>&1 || ( dpkg -s $1 2> /dev/null | grep -qs "^Version: $3" ) && COND="1"
    else
        ! dpkg -s $1 > /dev/null 2>&1 && COND="1"
    fi

    if [ -n "$COND" ]
    then
        echo -n "Instalando paquete "
        nombre_paquete $1 $2
        echo "..."
        if uname -i | grep x86_64 > /dev/null 2>&1
        then
            sudo dpkg -i $1_*_amd64.deb
        else
            sudo dpkg -i $1_*_i386.deb
        fi
        sudo apt-get -fy install
    else
        nombre_paquete $1 $2
        echo " ya instalado."
    fi
}

paquete_local tmux 1.9 1.8
paquete_local udisks-glue

for p in $PLIST
do
    if type fn_$p | grep -q "is a shell function" > /dev/null
    then
        eval fn_$p
    fi
done

for f in ~/.fonts/*Powerline*
do
    if [ ! -e "$f" ]
    then
        echo "Instalando tipografías..."
        ACTUAL=$PWD
        cd powerline-fonts
        ./install.sh
        cd $ACTUAL
    else
        echo "Tipografías ya instaladas."
    fi
    break
done

echo "Creando enlaces..."

backup_and_link()
{
    if [ -d ~/$1 ]
    then
        [ -d ~/$1.viejo ] && rm -rf ~/$1.viejo
        mv -f ~/$1 ~/$1.viejo
    fi
    if [ -n "$2" ]
    then
        ln -sf $PWD/$2 ~/$1
    else
        ln -sf $PWD/$1 ~/$1
    fi
}

backup_and_link .zshrc
backup_and_link .vimrc
backup_and_link .vim
backup_and_link .tmux.conf
backup_and_link .dircolors
backup_and_link .less
backup_and_link .lessfilter
backup_and_link .udisks-glue.conf
[ -d ~/.config ] || mkdir ~/.config
backup_and_link .config/sakura sakura
backup_and_link .config/dunst dunst
backup_and_link .config/nitrogen nitrogen
sed -i "s|^file=.*$|file=$PWD/fondo.jpg|g" ~/.config/nitrogen/bg-saved.cfg
backup_and_link .i3

if [ ! -e ~/.local/bin/powerline ]
then
    echo "Instalando powerline..."
    pip install --user git+https://github.com/Lokaltog/powerline
else
    echo "Powerline ya instalado."
fi

if ! which xflux > /dev/null 2>&1
then
    echo "Instalando xflux..."
    if uname -i | grep x86_64 > /dev/null 2>&1
    then
        cp xflux64 ~/.local/bin/xflux
    else
        cp xflux32 ~/.local/bin/xflux
    fi
else
    echo "xflux ya instalado."
fi

