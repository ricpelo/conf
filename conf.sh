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
fi

if ! dpkg -s tmux > /dev/null 2>&1 || ( dpkg -s tmux 2>/dev/null | grep -qs "^Version: 1.8" )
then
    echo "Instalando tmux versión 1.9 ó superior..."
    sudo dpkg -i tmux_*.deb
    sudo apt-get -f install
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
    echo "Estableciendo sakura como terminal predeterminado..."
    sudo update-alternatives --set x-terminal-emulator /usr/bin/sakura
fi

echo "Instalando fuentes..."

ACTUAL=$PWD
cd powerline-fonts
sudo ./install.sh
cd $ACTUAL

echo "Creando enlaces..."

ln -sf $PWD/.zshrc ~/.zshrc
ln -sf $PWD/.vimrc ~/.vimrc
[ -d ~/.vim ] && mv -f ~/.vim ~/.vim.viejo
ln -sf $PWD/.vim ~/.vim
ln -sf $PWD/.tmux.conf ~/.tmux.conf
ln -sf $PWD/.dircolors ~/.dircolors
ln -sf $PWD/.lessfilter ~/.lessfilter
[ -d ~/.config ] || mkdir ~/.config
[ -d ~/.config/sakura ] && mv -f ~/.config/sakura ~/.config/sakura.viejo
ln -sf $PWD/sakura ~/.config/sakura
[ -d ~/.i3 ] && mv -f ~/.i3 ~/.i3.viejo
ln -sf $PWD/.i3 ~/.i3

echo "Instalando powerline..."

pip install --user git+https://github.com/Lokaltog/powerline

