# .conf

Scripts y archivos de configuración para adaptar el entorno de trabajo a mi
gusto.

## Requisitos previos

* Ubuntu 16.04 LTS (recomendable [Lubuntu](http://lubuntu.net))
* `git`

## Instalación

```sh
$ cd ~
$ git clone --recursive https://github.com/ricpelo/conf.git .conf
$ cd .conf
$ ./conf.sh
```

Reiniciar y elegir `i3` como entorno de trabajo en la pantalla de inicio.

## Objetivos

* Gestor de ventanas gráfico [i3wm](http://i3wm.org)
* Shell `zsh` con [Oh-My-Zsh](http://ohmyz.sh)
* Sakura como emulador de terminal
* `tmux` como multiplexor de terminales
* `vim` (y muchos plugins) como editor de consola
* [Powerline](https://github.com/powerline/powerline) para `Zsh`, `tmux` y `vim`
* [Tipografías](https://github.com/powerline/fonts) adaptadas a Powerline
* Tipografía [Input Mono](http://input.fontbureau.com)
* PulseAudio como servidor de sonido
* Control de volumen gráfico para PulseAudio
* NetworkManager para configuración de red
* [`f.lux`](https://justgetflux.com) para acomodar el color del monitor a la
  hora del día
* [Atom](https://atom.io) como editor gráfico


## Gestor de ventanas `i3wm`

[i3wm](http://i3wm.org) es un gestor de ventanas minimalista que consume
poquísimos recursos y que sigue la filosofía de los [gestores de ventana tipo
mosaico](https://en.wikipedia.org/wiki/Tiling_window_manager), lo que reduce al
mínimo la necesidad del uso del ratón. Resulta perfecto para trabajar en un
entorno rápido, limpio y sin distracciones.

