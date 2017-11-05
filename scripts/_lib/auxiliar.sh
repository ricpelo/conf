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

git_user()
{
    if [ -n "$2" ]
    then
        git config --global user.$1 "$2"
    else
        echo $(git config --global user.$1)
    fi

}

github()
{
    if [ -n "$2" ]
    then
        git config --global github.$1 "$2"
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

activa_modulo_apache()
{
    if ! a2query -q -m $1
    then
        echo "Activando módulo $1 de Apache2..."
        sudo a2enmod $1
    else
        echo "Módulo $1 de Apache2 ya activado."
    fi
}

desactiva_xdebug()
{
    if phpquery -q -v 7.1 -s cli -m xdebug
    then
        echo "Desactivando módulo xdebug de PHP para el SAPI cli..."
        sudo phpdismod -s cli xdebug
    fi
}

asigna_param_php()
{
    # $1: param
    # $2: valor
    # $3: archivo
    PARAM="$1 = $2"
    if ! grep -qs "^$PARAM$" $3
    then
        echo "Estableciendo $PARAM en $3..."
        sudo sed -r -i "s/^;?\s*$1\s*=.*$/$PARAM/" $3
    else
        echo "Parámetro $PARAM ya establecido en $3."
    fi
}

asigna_param_postgresql()
{
    # $1: param
    # $2: valor
    # $3: archivo
    PARAM="$1 = $2"
    if ! grep -qs "^$PARAM" $3
    then
        echo "Estableciendo $PARAM..."
        sudo sed -r -i "s/^\s*#?$1\s*=/$PARAM #/" $3
    else
        echo "Parámetro $PARAM ya establecido."
    fi
}

comprueba_atom()
{
    if [ "$(which atom)" != "/usr/bin/atom" ]
    then
        echo "Atom no está instalado. Instálalo antes de continuar."
        exit 1
    else
        echo "Atom ya instalado."
    fi
}

comprueba_php()
{
    while true
    do
        if [ "$(which php)" != "/usr/bin/php" ]
        then
            echo "PHP no está instalado."
            echo "Ejecuta el script php-install.sh antes de continuar."
            echo -n "¿Quieres hacerlo ahora? (s/N): "
            read SN
            if [ "$SN" = "S"  ] || [ "$SN" = "s"  ]
            then
                $BASE_DIR/php-install.sh
            else
                echo "Imposible continuar. Vuelve cuando hayas ejecutado el script php-install.sh"
                exit 1
            fi
        else
            echo "PHP ya instalado."
            break
        fi
    done
}

comprueba_composer()
{
    while true
    do
        if [ "$(which composer)" != "/usr/local/bin/composer" ]
        then
            echo "Composer no está instalado."
            echo "Ejecuta el script composer-install.sh antes de continuar."
            echo -n "¿Quieres hacerlo ahora? (s/N): "
            read SN
            if [ "$SN" = "S"  ] || [ "$SN" = "s"  ]
            then
                $BASE_DIR/composer-install.sh
            else
                echo "Imposible continuar. Vuelve cuando hayas ejecutado el script composer-install.sh"
                exit 1
            fi
        else
            echo "Composer ya instalado."
            break
        fi
    done
}

