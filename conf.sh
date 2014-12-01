#!/bin/sh

PLIST="zsh curl python-pip git build-essential python-pygments sakura"
P=""
Z=""

for p in $PLIST
do
	if ! dpkg -s $p > /dev/null 2>&1
	then
		P="$p $P"
		[ "$p" = "zsh" ] && Z="1"
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

echo "Instalando zsh y Oh My ZSH..."

if [ -n $Z ]
then
	curl -L http://install.ohmyz.sh | sh
	if grep -qs $USER /etc/passwd | grep -vqs zsh
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

