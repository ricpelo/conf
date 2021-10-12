Descargar la imagen no oficial de instalación por red con firmware no libre (firmware netinst ISO) desde:

https://cdimage.debian.org/cdimage/unofficial/non-free/cd-including-firmware/11.1.0+nonfree/amd64/iso-cd/

Durante la instalación, he encontrado problemas de conexión al seleccionar directamente el ESSID de la red inalámbrica. Lo soluciono seleccionando la opción de escribir yo el ESSID

Arrancamos el sistema recién instalado.

Para tener red, añadimos lo siguiente en `/etc/network/interfaces`:

```
auto wlo1
iface wlo1 inet dhcp
	wpa-essid RentelWifi5
	wpa-psk <contraseña en claro>
```

y luego:

sudo systemctl restart networking.service

(Cuando ya hayamos instalado NetworkManager y lo vayamos a usar, tendremos que quitar lo que acabamos de poner y reiniciar de nuevo el servicio `networking`.)

No olvidarse de instalar amd64-microcode:

sudo apt install amd64-microcode

Instalamos X.Org e i3:

sudo apt install i3 xinit

Probar que funcionan las X.

sudo apt install linux-headers-amd64 nvidia-drivers firmware-misc-nonfree

Reiniciar y probar que funcionan las X con el módulo de nvidia.

Probar también que funciona nvidia-settings. En este punto, a mí no me arrancaban (se arregla luego cuando pasamos a _testing_).

El driver de nvidia 470.57.02 que hay en _testing_ falla al compilarse para el kernel 5.14.0, así que tenemos que quedarnos con el kernel 5.10.0 que hay en _stable_. Por eso, antes de pasar a _testing_ hay que hacer:

sudo apt purge linux-headers-amd64 linux-image-amd64

Ahora pasamos a _testing_ cambiando /etc/apt/sources.list y sustituyendo `bullseye` por `testing` con una búsqueda global.

sudo apt update
sudo apt full-upgrade

Reiniciar, arrancar `nvidia-settings`, crear un `xorg.conf` y copiarlo en `/etc/X11`.

sudo apt install firefox-esr firefox-esr-l10n-es-es git network-manager-gnome

Instalamos la versión con gaps de i3:

git clone https://github.com/maestrogerardo/i3-gaps-deb.git
cd i3-gaps-deb
./i3-gaps-deb

No olvidarse de instalar `lm-sensors`:

sudo apt install lm-sensors
sudo sensors-detect

En el caso de `hydra`, sólo se necesita cargar el módulo `nct6775` poniéndolo en `/etc/modules`, cosa que `sensors-detect` puede hacer automáticamente si se lo permitimos.

Instalamos nuestro script:

git clone https://github.com/ricpelo/conf.git .conf
cd .conf
git checkout hydra
./conf.sh

Cuando hayamos instalado `pulseaudio`, tendremos que arrancar el servicio:

systemctl --user restart pulseaudio.service

(sin el `sudo`).

Probablemente haya que ejecutar `lxappearance` para seleccionar el tema de
escritorio y los iconos, aunque en teoría no haría falta.

sudo update-alternatives --config desktop-theme

Elegir joy-theme.

Actualizar el `grub` para que coja el tema nuevo:

sudo update-grub
