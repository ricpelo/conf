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

instala_tema()
{
    local DIR_THEMES="$1"
    local TEMA="$2"
    if [ ! -d "$DIR_THEMES/$TEMA" ]; then
        mensaje "Instalando tema $TEMA..."
        mkdir -p "$DIR_THEMES"
        tar xfJ "temas/$TEMA.tar.xz" -C "$DIR_THEMES"
    else
        mensaje "Tema $TEMA ya instalado."
    fi
}

crea_enlace_temas_iconos()
{
    local ORIG="$1"
    local DEST="$2"
    if [ -f "$1" -o -d "$1" ]; then
        mv -f "$1" "$1.viejo"
        local DIR=$(realpath -s --relative-to=$HOME $2)
        mensaje "$1 -> $DIR"
        ln -sf "$DIR" $1
    fi
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

#prefn_i3()
#{
#    local OLD=/etc/apt/sources.list.d/i3wm.list
#    local RET=0
#    if [ -f $OLD ]; then
#        echo "Desactivando el antiguo repositorio de i3wm..."
#        sudo rm -f $OLD $OLD.save
#        RET=1
#    fi
#    local LIST=/etc/apt/sources.list.d/sur5r-i3.list
#    if [ ! -f $LIST ]; then
#        mensaje "Activando el repositorio con la última versión de i3wm..."
#        /usr/lib/apt/apt-helper download-file https://debian.sur5r.net/i3/pool/main/s/sur5r-keyring/sur5r-keyring_2021.02.02_all.deb keyring.deb SHA256:cccfb1dd7d6b1b6a137bb96ea5b5eef18a0a4a6df1d6c0c37832025d2edaa710
#        sudo dpkg -i ./keyring.deb
#        rm -f keyring.deb
#        echo "deb [arch=amd64] http://debian.sur5r.net/i3/ $(lsb_release -sc) universe" | sudo tee $LIST > /dev/null
#        RET=1
#    else
#        mensaje "Repositorio de i3wm ya activado."
#    fi
#    return $RET
#}

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

#postfn_sakura()
#{
#    if ! update-alternatives --query x-terminal-emulator | grep -qs "^Value:.*sakura"; then
#        mensaje "Estableciendo Sakura como terminal predeterminado..."
#        sudo update-alternatives --set x-terminal-emulator /usr/bin/sakura
#    else
#        mensaje "Sakura ya es el terminal predeterminado."
#    fi
#}

postfn_zsh()
{
    if [ ! -d ~/.oh-my-zsh ]; then
        mensaje "Instalando Oh My ZSH..."
        curl -L http://install.ohmyz.sh | sh
    else
        mensaje "Oh My ZSH ya instalado."
    fi
    local DEST=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
    if [ ! -d $DEST ]; then
        mensaje "Instalando Zsh Syntax Highlighting..."
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $DEST
    else
        mensaje "Actualizando Zsh Syntax Highlighting..."
        (cd $DEST && git pull)
    fi
    DEST=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/powerlevel10k
    if [ ! -d $DEST ]; then
        mensaje "Instalando tema Powerlevel10k..."
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $DEST
    else
        mensaje "Actualizando tema Powerlevel10k..."
        (cd $DEST && git pull)
    fi
    if grep $USER /etc/passwd | grep -vqs zsh; then
        mensaje "Instalando Zsh al usuario actual..."
        sudo chsh -s /bin/zsh $USER
    else
        mensaje "Zsh ya asignado al usuario actual."
    fi
#    DEST="$HOME/.local/bin/exa"
#    if [ ! -f $DEST ]; then
#        mensaje "Instalando exa..."
#        curl -sL https://github.com/ricpelo/exa/releases/download/iconos/exa.bz2 | bunzip2 -d > $DEST && chmod a+x $DEST
#    else
#        mensaje "Listador de archivos exa ya instalado."
#    fi
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

postfn_evince()
{
    if no_instalado "xdg-utils"; then
        mensaje "Instalando xdg-utils..."
        sudo apt install -y xdg-utils
    else
        mensaje "xdg-utils ya instalado."
    fi
    local DEFAULT=$(xdg-mime query default application/pdf)
    if [ "$DEFAULT" != "org.gnome.Evince.desktop" ]; then
        mensaje "Estableciendo evince como visor de PDF predeterminado..."
        xdg-mime default org.gnome.Evince.desktop application/pdf
    else
        mensaje "evince ya establecido como visor predeterminado de PDF."
    fi
}

postfn_pulseaudio()
{
    mensaje "Reiniciando Pulseaudio..."
    systemctl --user restart pulseaudio.service
}

postfn_commandnotfound()
{
    if [ ! -f "/var/lib/command-not-found/commands.db" ]; then
        mensaje "Reconstruyendo base de datos de command-not-found..."
        sudo update-command-not-found
    fi
}

postfn_xdgusersdirs()
{
    mensaje "Ejecutando xdg-user-dirs-update"
    xdg-user-dirs-update
}

#postfn_commandnotfound()
#{
#    if ! grep -qs -- "--no-failure-msg" /etc/zsh_command_not_found; then
#        mensaje "LP #1766068 ya corregido."
#    else
#        mensaje "Corrigiendo LP #1766068..."
#        sudo sed -ie "s/ --no-failure-msg//" /etc/zsh_command_not_found
#    fi
#}

#postfn_py3status()
#{
#    local DEST=$HOME/.local/lib/python3.8/site-packages/py3status
#    mensaje "Volcando versión actualizada de py3status en $DEST..."
#    if [ -d $DEST ]; then
#        rm -rf $DEST
#    fi
#    mkdir -p $DEST
#    curl -sL https://github.com/ultrabug/py3status/archive/master.tar.gz | tar xfz - --strip 2 -C $DEST py3status-master/py3status
#
##    local DEST=$HOME/.local/lib/python3.8/site-packages/py3status
##    if [ ! -d $DEST ]; then
##        mensaje "Instalando última versión de py3status en $DEST..."
##        git clone https://github.com/ultrabug/py3status.git $DEST
##    else
##        mensaje "Actualizando py3status..."
##        (cd $DEST && git pull)
##    fi
#}

prefn_gh()
{
    local DEST=/etc/apt/sources.list.d/github-cli.list
    local RET=0
    if [ ! -f "$DEST" ]; then
        mensaje "Activando el repositorio de GitHub CLI..."
        curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo gpg --dearmor -o /usr/share/keyrings/githubcli-archive-keyring.gpg
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
        RET=1
    else
        mensaje "Repositorio de GitHub CLI ya activado."
    fi
    return $RET
}
