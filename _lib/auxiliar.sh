fn()
{
    for p in $1; do
        p=$(echo $p | tr -d "-")
        if type $2fn_$p | grep -qs "is a shell function"
        then
            eval $2fn_$p
        fi
    done
}

no_instalado()
{
    local RET=1
    if ! dpkg -s $1 > /dev/null 2>&1; then
        RET=0
    fi
    return $RET
}

asegura_s_p_c()
{
    local P="software-properties-common"
    if no_instalado $P; then
        sudo apt $P
    fi
}

backup_and_link()
{
    if [ -d $HOME/$2/$1 ]; then
        [ -d $HOME/$2/$1.viejo ] && rm -rf $HOME/$2/$1.viejo
        mv -f $HOME/$2/$1 $HOME/$2/$1.viejo
    fi
    local RP=$(realpath -s --relative-to=$HOME/$2 $PWD/config/$1)
    ln -sf $RP $HOME/$2/$1
}

local_bin()
{
    if [ ! -f ~/.local/bin/$1 ]; then
        echo "Instalando $1..."
        local RP=$(realpath --relative-to=$HOME/.local/bin $PWD/bin)
        ln -sf $RP/$1 ~/.local/bin/$1
    else
        echo "$1 ya instalado."
    fi
}

prefn_emacssnapshot()
{
    if [ ! -f /etc/apt/sources.list.d/ubuntu-elisp-ubuntu-ppa-$(lsb_release -sc).list ]; then
        echo "Activando el repositorio de Emacs Snapshot..."
        sudo add-apt-repository ppa:ubuntu-elisp/ppa
        sudo apt update
    fi
}

prefn_i3()
{
    OLD=/etc/apt/sources.list.d/i3wm.list
    if [ -f $OLD ]; then
        echo "Desactivando el antiguo repositorio de i3wm..."
        sudo rm -f $OLD $OLD.save
        sudo apt update
    fi
    local LIST=/etc/apt/sources.list.d/sur5r-i3.list
    if [ ! -f $LIST ]; then
        echo "Activando el repositorio con la última versión de i3wm..."
        /usr/lib/apt/apt-helper download-file http://debian.sur5r.net/i3/pool/main/s/sur5r-keyring/sur5r-keyring_2018.01.30_all.deb keyring.deb SHA256:baa43dbbd7232ea2b5444cae238d53bebb9d34601cc000e82f11111b1889078a
        sudo dpkg -i ./keyring.deb
        rm -f keyring.deb
        echo "deb http://debian.sur5r.net/i3/ $(lsb_release -sc) universe" | sudo tee $LIST > /dev/null
        sudo apt update
    else
        echo "Repositorio de i3wm ya activado."
    fi
}

prefn_atom()
{
    local OLD="/etc/apt/sources.list.d/webupd8team-ubuntu-atom-$(lsb_release -sc).list"
    if [ -f $OLD ]; then
        echo "Desactivando el antiguo repositorio de Atom..."
        sudo rm -f $OLD $OLD.save
        sudo apt update
    fi
    local LIST=/etc/apt/sources.list.d/atom.list
    if [ ! -f $LIST ]; then
        echo "Activando el repositorio de Atom..."
        asegura_s_p_c
        curl -sL https://packagecloud.io/AtomEditor/atom/gpgkey | sudo apt-key add -
        echo "deb [arch=amd64] https://packagecloud.io/AtomEditor/atom/any/ any main" | sudo tee $LIST > /dev/null
        sudo apt update
    else
        echo "Repositorio de Atom ya activado."
    fi
}

postfn_sakura()
{
    if ! update-alternatives --query x-terminal-emulator | grep -qs "^Value:.*sakura"; then
        echo "Estableciendo sakura como terminal predeterminado..."
        sudo update-alternatives --set x-terminal-emulator /usr/bin/sakura
    else
        echo "sakura ya es el terminal predeterminado."
    fi
}

postfn_nitrogen()
{
    local DIR=$HOME/.config/nitrogen
    if [ -d "$DIR" ]; then
        [ -d "$DIR.viejo" ] && rm -rf $DIR.viejo
        mv -f $DIR $DIR.viejo
    fi
    mkdir -p $DIR
    echo "[:0.0]\nfile=$PWD/config/fondo.jpg\nmode=0\nbgcolor=#000000" > $DIR/bg-saved.cfg
}

postfn_zsh()
{
    if [ ! -d ~/.oh-my-zsh ]; then
        echo "Instalando Oh My ZSH..."
        curl -L http://install.ohmyz.sh | sh
    else
        echo "Oh My ZSH ya instalado."
    fi
    local dest=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
    if [ ! -d $dest ]; then
        echo "Instalando Zsh Syntax Highlighting..."
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $dest
    else
        echo "Actualizando Zsh Syntax Highlighting..."
        (cd $dest && git pull)
    fi
    echo "Instalando/actualizando tema Bullet Train para Zsh..."
    dest=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes
    if [ ! -d $dest ]; then
        mkdir -p $dest
    fi
    dest=$dest/bullet-train.zsh-theme
    curl -sL http://raw.github.com/caiogondim/bullet-train.zsh/master/bullet-train.zsh-theme > $dest
    if grep $USER /etc/passwd | grep -vqs zsh; then
        echo "Instalando ZSH al usuario actual..."
        sudo chsh -s /bin/zsh $USER
    else
        echo "Zsh ya asignado al usuario actual."
    fi
}

postfn_vim()
{
    echo "Instalación de SpaceVim..."
    bash scripts/SpaceVim-install.sh
    vim +SPInstall +qall
    tput sgr0
}

postfn_emacs()
{
    echo "Instalación de SpaceMacs..."
    if [ -d /.emacs.d ]; then
        if ! (cd /.emacs.d; git pull 2>/dev/null); then
            [ -d /.emacs.d.viejo ] && rm -rf /.emacs.d.viejo
            mv -f /.emacs.d /.emacs.d.viejo
        fi
    fi
    git clone https://github.com/syl20bnr/spacemacs ~/.emacs.d 2>/dev/null
}
