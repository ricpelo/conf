fn()
{
    local CAMBIA_APT=0
    for p in $1; do
        p=$(echo $p | tr -d "-")
        if type $2fn_$p | grep -qs "is a shell function"; then
            if ! eval $2fn_$p; then
                CAMBIA_APT=1
            fi
        fi
    done
    return $CAMBIA_APT
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
        sudo apt -y install $P
    fi
}

backup_and_link()
{
    if [ -n "$2" ]; then
        local ORIG=$HOME/$2/$1
    else
        local ORIG=$HOME/$1
    fi
    if [ -e $ORIG ]; then
        if [ ! -e $ORIG.viejo ]; then
            if [ "$(realpath $PWD/config/$1)" != "$(realpath $ORIG)" ]; then
                mv -f $ORIG $ORIG.viejo
            fi
        fi
        rm -rf $ORIG
    fi
    local RP=$(realpath -s --relative-to=$HOME/$2 $PWD/config/$1)
    mensaje "$ORIG -> $RP"
    ln -sf $RP $ORIG
}

local_bin()
{
    if [ ! -f ~/.local/bin/$1 ]; then
        mensaje "Instalando $1..."
        local RP=$(realpath --relative-to=$HOME/.local/bin $PWD/bin)
        ln -sf $RP/$1 ~/.local/bin/$1
    else
        mensaje "$1 ya instalado."
    fi
}

prefn_emacssnapshot()
{
    local RET=0
    if [ ! -f /etc/apt/sources.list.d/ubuntu-elisp-ubuntu-ppa-$(lsb_release -sc).list ]; then
        mensaje "Activando el repositorio de Emacs Snapshot..."
        sudo add-apt-repository --no-update ppa:ubuntu-elisp/ppa
        RET=1
    fi
    return $RET
}

prefn_i3()
{
    local OLD=/etc/apt/sources.list.d/i3wm.list
    local RET=0
    if [ -f $OLD ]; then
        echo "Desactivando el antiguo repositorio de i3wm..."
        sudo rm -f $OLD $OLD.save
        RET=1
    fi
    local LIST=/etc/apt/sources.list.d/sur5r-i3.list
    if [ ! -f $LIST ]; then
        mensaje "Activando el repositorio con la última versión de i3wm..."
        /usr/lib/apt/apt-helper download-file http://debian.sur5r.net/i3/pool/main/s/sur5r-keyring/sur5r-keyring_2019.02.01_all.deb keyring.deb SHA256:176af52de1a976f103f9809920d80d02411ac5e763f695327de9fa6aff23f416
        sudo dpkg -i ./keyring.deb
        rm -f keyring.deb
        echo "deb http://debian.sur5r.net/i3/ $(lsb_release -sc) universe" | sudo tee $LIST > /dev/null
        RET=1
    else
        mensaje "Repositorio de i3wm ya activado."
    fi
    return $RET
}

prefn_atom()
{
    local OLD="/etc/apt/sources.list.d/webupd8team-ubuntu-atom-$(lsb_release -sc).list"
    local RET=0
    if [ -f $OLD ]; then
        mensaje "Desactivando el antiguo repositorio de Atom..."
        sudo rm -f $OLD $OLD.save
        RET=1
    fi
    local LIST=/etc/apt/sources.list.d/atom.list
    if [ ! -f $LIST ]; then
        mensaje "Activando el repositorio de Atom..."
        asegura_s_p_c
        curl -sL https://packagecloud.io/AtomEditor/atom/gpgkey | sudo apt-key add -
        echo "deb [arch=amd64] https://packagecloud.io/AtomEditor/atom/any/ any main" | sudo tee $LIST > /dev/null
        RET=1
    else
        mensaje "Repositorio de Atom ya activado."
    fi
    return $RET
}

postfn_sakura()
{
    if ! update-alternatives --query x-terminal-emulator | grep -qs "^Value:.*sakura"; then
        mensaje "Estableciendo Sakura como terminal predeterminado..."
        sudo update-alternatives --set x-terminal-emulator /usr/bin/sakura
    else
        mensaje "Sakura ya es el terminal predeterminado."
    fi
}

postfn_zsh()
{
    if [ ! -d ~/.oh-my-zsh ]; then
        mensaje "Instalando Oh My ZSH..."
        curl -L http://install.ohmyz.sh | sh
    else
        mensaje "Oh My ZSH ya instalado."
    fi
    local dest=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
    if [ ! -d $dest ]; then
        mensaje "Instalando Zsh Syntax Highlighting..."
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $dest
    else
        mensaje "Actualizando Zsh Syntax Highlighting..."
        (cd $dest && git pull)
    fi
    dest=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/powerlevel9k
    if [ ! -d $dest ]; then
        mensaje "Instalando tema Powerlevel9k..."
        git clone https://github.com/bhilburn/powerlevel9k.git $dest
    else
        mensaje "Actualizando tema Powerlevel9k..."
        (cd $dest && git pull)
    fi
    if grep $USER /etc/passwd | grep -vqs zsh; then
        mensaje "Instalando ZSH al usuario actual..."
        sudo chsh -s /bin/zsh $USER
    else
        mensaje "Zsh ya asignado al usuario actual."
    fi
}

postfn_vim()
{
    mensaje "Instalación de plugins de Vim..."
    echo | vim +PlugInstall +qall 2>/dev/null
}

postfn_emacs()
{
    mensaje "Instalación de SpaceMacs..."
    if [ -d /.emacs.d ]; then
        if ! (cd /.emacs.d; git pull 2>/dev/null); then
            [ -d /.emacs.d.viejo ] && rm -rf /.emacs.d.viejo
            mv -f /.emacs.d /.emacs.d.viejo
        fi
    fi
    git clone https://github.com/syl20bnr/spacemacs ~/.emacs.d 2>/dev/null
}

postfn_commandnotfound()
{
    if ! grep -qs -- "--no-failure-msg" /etc/zsh_command_not_found; then
        mensaje "LP #1766068 ya corregido."
    else
        mensaje "Corrigiendo LP #1766068..."
        sudo sed -ie "s/ --no-failure-msg//" /etc/zsh_command_not_found
    fi
}
