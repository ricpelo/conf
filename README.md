# .conf

Scripts y archivos de configuración para adaptar el entorno de trabajo a mi
gusto.

## Requisitos previos

* Ubuntu 18.04 LTS (recomendable [Lubuntu](http://lubuntu.net))
* [Git](https://git-scm.com) instalado y configurado, al menos, con `user.name`
  y `user.email`
* *Recomendable*: disponer de cuenta en [GitHub.com](https://github.com)

## Instalación

```sh
$ git clone --recursive https://github.com/ricpelo/conf.git ~/.conf
$ cd ~/.conf
$ ./conf.sh
```

Reiniciar y elegir *i3* como entorno de trabajo en la pantalla de inicio.

**Opcional**

```sh
$ ~/.conf/scripts/scripts.sh
```

## Objetivos

* Gestor de ventanas gráfico [i3wm](http://i3wm.org)
* Shell Zsh con [Oh-My-Zsh](http://ohmyz.sh)
* Coloreado de la consola basado en [Solarized
  Light](https://github.com/seebi/dircolors-solarized)
* Coloreado de `less` basado en Pygments
* Sakura como emulador de terminal
* [Vim](http://www.vim.org) (y muchos plugins) como editor de consola
* [Powerline](https://github.com/powerline/powerline) para Zsh, tmux y Vim
* [Tipografías](https://github.com/powerline/fonts) adaptadas a Powerline
* Tipografía [Input Mono](http://input.fontbureau.com)
* PulseAudio como servidor de sonido
* Control de volumen gráfico para PulseAudio
* NetworkManager para configuración de red
* [Redshift](http://jonls.dk/redshift) para acomodar el color del monitor a la
  hora del día
* [Atom](https://atom.io) como editor de texto en modo gráfico

## Gestor de ventanas i3wm

[i3wm](http://i3wm.org) es un gestor de ventanas minimalista que consume
poquísimos recursos y que sigue la filosofía de los [gestores de ventana tipo
mosaico](https://en.wikipedia.org/wiki/Tiling_window_manager), lo que reduce al
mínimo la necesidad del uso del ratón. Resulta perfecto para trabajar en un
entorno rápido, limpio y sin distracciones.

Con este repositorio se instala `i3wm` con la siguiente configuración:

* La tecla de modificación es la `Super` (tecla _Windows_ izquierda)
* `Super+Espacio` abre `dmenu`
* `Super+q` cierra la aplicación actual
* `Super+u` alterna el borde de la ventana actual
* `Super+Tab` alterna entre el _workspace_ actual y el anterior
* Durante el arranque inicial:
  * Ajusta la velocidad de repetición del teclado a 250/30
  * Intercambia las teclas `Bloq Mayús` y `Ctrl` izquierdo
  * Aplica un fondo al escritorio con `feh`
  * Arranca `redshift` según las coordenadas de Sanlúcar de Barrameda
  * Arranca `xbanish` para que el cursor del ratón se oculte automáticamente
    después de un segundo de inactividad
  * Arranca el applet de NetworkManager
  * Arranca el navegador predeterminado en el _workspace_ 1 maximizado sin
    bordes
  * Arranca una terminal Sakura en el _workspace_ 2 a pantalla completa

## Scripts adicionales

* `git-config.sh`: configura varios aspectos básicos de Git y crea un token
   para GitHub
* `php-install.sh`: instala PHP 7.1 y extensiones interesantes
* `postgresql-install.sh`: instala PostgreSQL 9.6
* `composer-install.sh`: instala [Composer](https://getcomposer.org)
* `composer-postinstall.sh`: aplica el token de GitHub en Composer e instala
  algunos paquetes globales, creando el enlace simbólico `/opt/composer`
* `atom-postinstall.sh`: configura Atom con paquetes para PHP
* `code-install.sh`: instala y configura Visual Studio Code con varias
  extensiones
* `rbenv-install.sh`: primer paso para instalar Ruby con
  [rbenv](http://rbenv.org)
* `rbenv-postinstall.sh`: segundo (y último) paso para instalar Ruby con
  rbenv

## Scripts que se instalan en `~/.local/bin/` para uso general

* `lesscurl`: [curl](https://curl.haxx.se) con paginación y resaltado de
   sintaxis HTTP
* `proyecto.sh`: crear un esqueleto inicial de proyecto basado en la plantilla
  básica del framework [Yii2](http://www.yiiframework.com) y modificaciones
  propias al mismo del repositorio
  [`ricpelo/proyecto`](https://github.com/ricpelo/proyecto)

## Otros archivos

* `apt/dagon.apt-clone.tar.gz`: archivo de backup creado con
  [apt-clone](https://github.com/mvo5/apt-clone)
* `apt/dpkg--get-selections.txt.gz`: archivo de backup creado con `dpkg
  --get-selections`

