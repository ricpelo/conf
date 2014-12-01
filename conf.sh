#!/bin/sh

P=""
Z=""

if ! dpkg -s zsh > /dev/null
then
	P="zsh $P"
	Z="1"
fi

if ! dpkg -s curl > /dev/null
then
	P="curl $P"
fi

if ! dpkg -s python-pip > /dev/null
then
	P="python-pip $P"
fi

if ! dpkg -s git > /dev/null
then
        P="git $P"
fi

if ! dpkg -s build-essential > /dev/null
then
	P="build-essential $P"
fi

if ! dpkg -s python-pygments > /dev/null
then
	P="python-pygments $P"
fi

if [ -n "$P" ]
then
	echo "Instalando paquetes..."
	sudo apt-get install -y $P
fi

if dpkg -s tmux > /dev/null
then
	if dpkg -s tmux | grep "^Version: 1.8"
	then
		echo "Instalando tmux versión 1.9 ó superior"
		sudo dpkg -i tmux/tmux_*.deb
	fi
fi

echo "Instalando zsh y Oh My ZSH..."

if [ -n $Z ]
then
	curl -L http://install.ohmyz.sh | sh
	if grep $USER /etc/passwd | grep -v zsh
	then
		sudo chsh -s /bin/zsh $USER
	fi
fi

echo "Instalando fuentes..."

cd powerline-fonts
sudo ./install.sh
cd ..

echo "Creando enlaces..."

ln -sf $PWD/.zshrc ~/.zshrc
ln -sf $PWD/.vimrc ~/.vimrc
ln -sf $PWD/.vim ~/.vim
ln -sf $PWD/.tmux.conf ~/.tmux.conf
ln -sf $PWD/.dircolors ~/.dircolors
ln -sf $PWD/.lessfilter ~/.lessfilter
[ -d ~/.config ] || mkdir ~/.config
[ -d ~/.config/sakura ] && rm -rf ~/.config/sakura
ln -sf $PWD/sakura ~/.config/sakura
ln -sf $PWD/.i3 ~/.i3

echo "Instalando powerline..."

pip install --user git+https://github.com/Lokaltog/powerline


