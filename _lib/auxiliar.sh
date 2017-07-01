prefn_i3()
{
    if [ ! -f /etc/apt/sources.list.d/i3wm.list ]
    then
        echo "Activando el repositorio con la última versión de i3wm..."
        echo "deb http://debian.sur5r.net/i3/ $(lsb_release -sc) universe" | sudo tee /etc/apt/sources.list.d/i3wm.list > /dev/null
        sudo apt-get update
        sudo apt --allow-unauthenticated install sur5r-keyring
        sudo apt update
    else
        echo "Repositorio de i3wm ya activado."
    fi
}

prefn_fluxgui()
{
    if [ ! -f /etc/apt/sources.list.d/nathan-renniewaldock-ubuntu-flux-$(lsb_release -sc).list ]
    then
        echo "Activando el repositorio de xflux..."
        sudo add-apt-repository --yes ppa:nathan-renniewaldock/flux
        sudo apt update
    else
        echo "Repositorio de xflux ya activado."
    fi
}

prefn_atom()
{
    if [ ! -f /etc/apt/sources.list.d/webupd8team-ubuntu-atom-$(lsb_release -sc).list ]
    then
        echo "Activando el repositorio de Atom..."
        sudo add-apt-repository --yes ppa:webupd8team/atom
        sudo apt update
    else
        echo "Repositorio de Atom ya activado."
    fi
}

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

fn_nitrogen()
{
    local DIR=$HOME/.config/nitrogen
    if [ -d "$DIR" ]
    then
        [ -d "$DIR.viejo" ] && rm -rf $DIR.viejo
        mv -f $DIR $DIR.viejo
    fi
    mkdir -p $DIR
    echo "[:0.0]\nfile=$PWD/config/fondo.jpg\nmode=0\nbgcolor=#000000" > $DIR/bg-saved.cfg
}

fn_vim()
{
    echo "Post-instalación de plugins de Vim mediante Vundle..."
    vim +PluginInstall +qall
#    echo "** No olvides ejecutar YouCompleteMe.sh **"
}

nombre_paquete()
{
    echo -n "$1"
    [ -n "$2" ] && echo -n " versión $2 ó superior"
}

paquete_local()
{
    local COND=""

    if [ -n "$2" ]
    then
        ! dpkg -s $1 > /dev/null 2>&1 || ( ! dpkg -s $1 2> /dev/null | grep -qs "^Version: $2" ) && COND="1"
    else
        ! dpkg -s $1 > /dev/null 2>&1 && COND="1"
    fi

    if [ -n "$COND" ]
    then
        echo -n "Instalando paquete "
        nombre_paquete $1 $2
        echo "..."
        if uname -i | grep -qs x86_64
        then
            sudo dpkg -i $1_*_amd64.deb
        else
            sudo dpkg -i $1_*_i386.deb
        fi
        sudo apt -fy install
    else
        nombre_paquete $1 $2
        echo " ya instalado."
    fi
}

backup_and_link()
{
    if [ -d $HOME/$2/$1 ]
    then
        [ -d $HOME/$2/$1.viejo ] && rm -rf $HOME/$2/$1.viejo
        mv -f $HOME/$2/$1 $HOME/$2/$1.viejo
    fi
    local RP=$(realpath -s --relative-to=$HOME/$2 $PWD/config/$1)
    ln -sf $RP $HOME/$2/$1
}

local_bin()
{
    if [ ! -f ~/.local/bin/$1 ]
    then
        echo "Instalando $1..."
        local RP=$(realpath --relative-to=$HOME/.local/bin $PWD/bin)
        ln -sf $RP/$1 ~/.local/bin/$1
    else
        echo "$1 ya instalado."
    fi
}

