# HYDRA

## INSTALACIÓN

- Descargar la imagen no oficial de instalación por red con firmware no libre
  (firmware netinst ISO) desde:

  https://cdimage.debian.org/cdimage/unofficial/non-free/cd-including-firmware/11.1.0+nonfree/amd64/iso-cd/

- Durante la instalación, he encontrado problemas de conexión al seleccionar
  directamente el ESSID de la red inalámbrica. Lo soluciono seleccionando la
  opción de escribir yo el ESSID.

- Arrancamos el sistema recién instalado.

- Para tener red, añadimos lo siguiente en `/etc/network/interfaces`:

  ```
  auto wlo1
  iface wlo1 inet dhcp
      wpa-essid RentelWifi5
      wpa-psk <contraseña en claro>
  ```

  y luego:

  ```
  $ sudo systemctl restart networking.service
  ```

  (Cuando ya hayamos instalado NetworkManager y lo vayamos a usar, tendremos
  que quitar lo que acabamos de poner y reiniciar de nuevo el servicio
  `networking`.)

- No olvidarse de instalar amd64-microcode:

  ```
  $ sudo apt install amd64-microcode
  ```

- Instalamos X.Org e i3:

  ```
  $ sudo apt install i3 xinit
  ```

  Probar que funcionan las X.

  ```
  $ sudo apt install linux-headers-amd64 nvidia-drivers firmware-misc-nonfree
  ```

  Reiniciar y probar que funcionan las X con el módulo de nvidia.

  Probar también que funciona nvidia-settings. En este punto, a mí no me
  arrancaban (se arregla luego cuando pasamos a _testing_).

  El driver de nvidia 470.57.02 que hay en _testing_ falla al compilarse para
  el kernel 5.14.0, así que tenemos que quedarnos con el kernel 5.10.0 que hay
  en _stable_. Por eso, antes de pasar a _testing_ hay que hacer:

  ```
  sudo apt purge linux-headers-amd64 linux-image-amd64
  ```

  Ahora pasamos a _testing_ cambiando /etc/apt/sources.list y sustituyendo
  `bullseye` por `testing` con una búsqueda global.

  ```
  $ sudo apt update
  $ sudo apt full-upgrade
  ```

  Reiniciar, arrancar `nvidia-settings`, crear un `xorg.conf` y copiarlo en
  `/etc/X11`.

  ```
  $ sudo apt install firefox-esr firefox-esr-l10n-es-es git network-manager-gnome
  ```

  Instalamos la versión con gaps de i3:

  ```
  $ git clone https://github.com/maestrogerardo/i3-gaps-deb.git
  $ cd i3-gaps-deb
  $ ./i3-gaps-deb
  ```

- No olvidarse de instalar `lm-sensors`:

  ```
  $ sudo apt install lm-sensors
  $ sudo sensors-detect
  ```

  En el caso de `hydra`, sólo se necesita cargar el módulo `nct6775` poniéndolo
  en `/etc/modules`, cosa que `sensors-detect` puede hacer automáticamente si
  se lo permitimos.

- Instalamos nuestro script:

  ```
  $ git clone https://github.com/ricpelo/conf.git .conf
  $ cd .conf
  $ git checkout hydra
  $ ./conf.sh
  ```

- Cuando hayamos instalado `pulseaudio`, tendremos que arrancar el servicio:

  ```
  $ systemctl --user restart pulseaudio.service
  ```

  (sin el `sudo`).

- Probablemente haya que ejecutar `lxappearance` para seleccionar el tema de
  escritorio y los iconos, aunque en teoría no haría falta.

- Hacer:

  ```
  $ sudo update-alternatives --config desktop-theme
  ```

  Elegir joy-theme.

- Actualizar el `grub` para que coja el tema nuevo:

  ```
  $ sudo update-grub
  ```

## RED

(Fuente: https://askubuntu.com/questions/1196348/ubuntu-19-10-wont-connect-to-2-4ghz-wifi-with-txbf-mu-mimo-enabled)

- Para que pueda conectarse a la red WiFi 2.4 GHz con el router TP-Link AC1200,
  hay que usar `iwd` en lugar de `wpa_supplicant`. Para ello:

  1. Instalar `iwd`:

     ```
     sudo apt update
     sudo apt install iwd
     ```

  2. Crear el siguiente archivo dentro del directorio de archivos de
     configuración de NetworkManager:

     ```
     sudo vim /etc/NetworkManager/conf.d/wifi_backend.conf
     ```

  3. Copiar y pegar el siguiente contenido dentro de ese archivo, guardar y
     salir:

     ```
     [device]
     wifi.backend=iwd
     ```

  4. Parar y desactivar el servicio `wpa_supplicant` (la desactivación es
     persitente entre reinicios):

     ```
     sudo systemctl disable --now wpa_supplicant.service
     ```

  5. No activar el servicio `iwd`, en caso de que esté activado:

     ```
     sudo systemctl disable iwd.service
     ```

  6. Reiniciar el servicio de NetworkManager (así no habrá que reiniciar el
     equipo para que los cambios tengan efecto):

     ```
     sudo systemctl restart NetworkManager.service
     ```

- Si la conexión del sistema no conecta bien, podemos hacer lo siguiente:

  1. Borrar la conexión del sistema:

     ```
     sudo rm /etc/NetworkManager/system-connections/RentelWifi5.nmconnection
     ```

  2. Conectarse desde el applet de NetworkManager.

     Esa conexión que se crea no es del sistema porque no se guarda la
     contraseña. Por tanto, hacemos:

     a. Arrancamos el editor de conexiones:

        ```
        nm-connection-editor
        ```

     b. Elegimos la conexión que queremos (en mi caso, `RentelWifi5`) y
        pulsamos el botón de la rueda dentada.

     c. En la pestaña `Seguridad inalámbrica`, escribimos la contraseña y le
        damos a `Guardar`.

  Así ya se creará la conexión del sistema con la contraseña bien guardada.

## TIPOGRAFÍAS

- Si se instala el paquete `ttf-bitstream-vera`, en LyX no se ven bien los
  textos matemáticos. Dos soluciones:

  - Desinstalar el paquete `ttf-bitstream-vera` (es lo mejor).

  - Configurar LyX para usar las tipografías DejaVu en las tipografías de
    pantalla en _Herramientas -> Preferencias -> Apariencia -> Tipografías de
    pantalla_.

## SCRIPTS DE ARRANQUE

- `/etc/default/locale`   --> establece el `LANG`

- `/etc/pam.d/lightdm y /etc/pam.d/login`  --> cargan el `/etc/default/locale`

- En `/etc/environment` no se pone nada de `LANG` (de hecho, en Debian está
  vacío, por lo visto).

- En Zsh:

  - `/etc/profile`
  - `/etc/profile.d`
  - `~/.xsessionrc`   --> carga `/etc/profile` y `~/.profile`
  - `~/.zprofile`   --> carga `/etc/profile` y `~/.profile`
  - `~/.profile`  --> mete el `.local/bin` en el `PATH`

- Orden de arranque:

  - En un login interactivo:

    1. `/etc/zshenv`
    2. `~/.zshenv`
    3. `/etc/zprofile`
    4. `~/.zprofile`
    5. `/etc/zshrc`
    6. `~/.zshrc`
    7. `/etc/zlogin`
    8. `~/.zlogin`

  - En un no login interactivo:

    1. `/etc/zshenv`
    2. `~/.zshenv`
    3. `/etc/zshrc`
    4. `~/.zshrc`

  - En un script no interactivo:

    1. `/etc/zshenv`
    2. `~/.zshenv`
