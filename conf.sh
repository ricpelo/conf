#!/bin/sh

PLIST="zsh curl python-pip git build-essential python-pygments sakura i3
unclutter"
P=""
ZSH_CONF=""
SAKURA_CONF=""

for p in $PLIST
do
    if ! dpkg -s $p > /dev/null 2>&1
    then
        P="$p $P"
        [ "$p" = "zsh" ] && ZSH_CONF="1"
        [ "$p" = "sakura" ] && SAKURA_CONF="1"
    fi
done

if [ -n "$P" ]
then
    echo "Instalando paquetes..."
    sudo apt-get install -y $P
else
    echo "Paquetes ya instalados."
fi

if ! dpkg -s tmux > /dev/null 2>&1 || ( dpkg -s tmux 2>/dev/null | grep -qs "^Version: 1.8" )
then
    echo "Instalando tmux versión 1.9 ó superior..."
    sudo dpkg -i tmux_*.deb
    sudo apt-get -f install
else
    echo "tmux 1.9 ó superior ya instalado."
fi

if [ -n $ZSH_CONF ]
then
    if [ ! -d ~/.oh-my-zsh ]
    then
        echo "Instalando Oh My ZSH..."
        curl -L http://install.ohmyz.sh | sh
    fi
    if grep -qs $USER /etc/passwd | grep -vqs zsh
    then
        echo "Instalando ZSH al usuario actual..."
        sudo chsh -s /bin/zsh $USER
    fi
fi

if [ -n $SAKURA_CONF ]
then
    if ! update-alternatives --query x-terminal-emulator | grep -qs "^Value:.*sakura"
    then
        echo "Estableciendo sakura como terminal predeterminado..."
        sudo update-alternatives --set x-terminal-emulator /usr/bin/sakura
    else
        echo "sakura ya es el terminal predeterminado."
    fi
fi

for f in ~/.fonts/*Powerline*
do
    if [ ! -e "$f" ]
    then
        echo "Instalando tipografías..."
        ACTUAL=$PWD
        cd powerline-fonts
        sudo ./install.sh
        cd $ACTUAL
    else
        echo "Tipografías ya instaladas."
    fi
    break
done

echo "Creando enlaces..."

backup_and_link()
{
    [ -d ~/$1 ] && mv -f ~/$1 ~/$1.viejo
    if [ -n "$2" ]
    then
        ln -sf $PWD/$2 ~/$1
    else
        ln -sf $PWD/$1 ~/$1
    fi
}

ln -sf $PWD/.zshrc ~/.zshrc
ln -sf $PWD/.vimrc ~/.vimrc
backup_and_link .vim
ln -sf $PWD/.tmux.conf ~/.tmux.conf
ln -sf $PWD/.dircolors ~/.dircolors
ln -sf $PWD/.lessfilter ~/.lessfilter
[ -d ~/.config ] || mkdir ~/.config
backup_and_link .config/sakura sakura
backup_and_link .i3

if [ ! -e ~/.local/bin/powerline ]
then
    echo "Instalando powerline..."
    pip install --user git+https://github.com/Lokaltog/powerline
else
    echo "Powerline ya instalado."
fi

