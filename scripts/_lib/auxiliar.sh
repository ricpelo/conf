asegura_salto_linea_sudoers()
{
    if [ "`sudo cat /etc/sudoers | tail -c1`" != "" ]
    #if test `sudo cat /etc/sudoers | tail -c1`
    then
        echo "" | sudo tee -a /etc/sudoers > /dev/null
    fi
}

asegura_salto_linea()
{
    if [ "`tail -c1 $1`" != "" ]
    then
        echo "" >> $1
    fi
}

desactiva_sudo()
{
    local L="%sudo	ALL=!$1"
    if ! sudo cat /etc/sudoers | grep -qs "$L"
    then
        echo "Desactivando el uso de $1 con sudo..."
        echo "$L" | sudo tee -a /etc/sudoers > /dev/null
    else
        echo "Uso de $1 con sudo ya desactivado."
    fi
}

github()
{
    if [ -n "$2" ]
    then
        git config --global github.$1 $2
    else
        echo $(git config --global github.$1)
    fi

}

token_composer()
{
    if [ -n "$1" ]
    then
        composer config -g github-oauth.github.com $1
    else
        echo $(composer config -g github-oauth.github.com 2>/dev/null)
    fi
}

