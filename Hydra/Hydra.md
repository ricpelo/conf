# CONFIGURACIÓN DE HYDRA

## BIOS

### MEMORIA RAM

- Usar _perfil 1_ de XMP (va a 2933 MHz).

- Cuidado: al activar un perfil XMP se cambia automáticamente la curva de
  temperaturas y ventilación de la CPU, machacando los valores que había.

- El _perfil 2_ de XMP (que va a 3200 MHz) en principio es compatible según las
  especificaciones de la placa base, PERO hace que el test Prime95 Blend se
  rompa desde el primer momento, cosa que no pasa con el _perfil 1_. [TODO:
  Esto último parece que no es por culpa del _perfil 2_, sino que cuando hice
  la prueba tenía poca memoria libre. Probar de nuevo.]

### OVERCLOCK

- Desactivar `Precision Boost Overdrive`.

### VENTILADORES

#### CPU (fan2 en lm_sensors)

- Ahora mismo lo tengo así:

  ```
  Temp.    %
  ------ -----
   20º     38
   65º     38
   75º     80
   85º    100

  Step up time: 0.7s
  Step down time: 1.0s
  ```

- Otras curvas que he probado:

  ```
  Temp.    %
  ------ -----
   20º     38
   60º     38
   70º     80
   85º    100

  Temp.    %
  ------ -----
   20º     40
   55º     40
   65º     80
   85º    100

  Temp.    %
  ------ -----
   20º     20
   50º     40
   65º     80
   85º    100
  ```

  pero como resulta que `Tdie` está continuamente dando pequeños saltos de unos
  10º, esto provoca que, en ese pico, el ventilador de la CPU pegue un salto y
  luego baje casi enseguida, lo que resulta molesto (y seguramente no sea muy
  bueno para el motor del ventilador).

  Para arreglarlo, pongo el ventilador a una velocidad constante de 38-40%
  hasta los 55º-60º-65º, y a partir de ahí subo la velocidad. [TODO: Probar por
  si hay que poner una rampa más empinada en situaciones de estrés.]

  Es mejor usar el 38% que el 40% para el ventilador de la CPU, porque al 40%
  se oye un zumbido molesto de vibración, sobre todo por la noche.

#### TRASERO (`SYSFAN1` en placa, `fan3` en `lm_sensors`)

- 516 V.

#### DELANTEROS (`SYSFAN3` en placa, `fan6` en `lm_sensors`)

- 516 V.

- Ahora mismo (2020-10-29) hace mucho menos ruido poniendo 660 V. Con 516 V se
  provocan vibraciones a intervalos de un segundo.

- Poner una curva dinámica en los ventiladores trasero o delanteros provoca
  vibraciones y ruido. Mejor poner un valor constante de 516 V. [TODO: Probar
  de nuevo.]

## CAJA

- No apretar todos los tornillos del cristal templado para así evitar ruidos,
  zumbidos y vibraciones molestas. Recomendado apretar sólo los dos tornillos
  superiores y dejar los inferiores al aire.

## MONITOR AOC

- `Contraste`: 50.

- `Brillo`: 40.

- `Gamma`: _Gamma3_.

- Activar `Adapt. Sync`.

## TECLADO INALÁMBRICO LOGITECH

- Poner el adaptador inalámbrico en los USB de delante.

- En los de detrás, no llega bien la señal.

## INSTALACIÓN DE DEBIAN GNU/LINUX

- Descargar la imagen no oficial de instalación por red con firmware no libre
  (firmware netinst ISO) desde:

  https://cdimage.debian.org/cdimage/unofficial/non-free/cd-including-firmware/11.1.0+nonfree/amd64/iso-cd/

- Durante la instalación, he encontrado problemas de conexión al seleccionar
  directamente el ESSID de la red inalámbrica. Lo soluciono seleccionando la
  opción de escribir yo el ESSID.

- En las opciones del sistema de archivos:

  - Crear una partición EFI de 512M al comienzo.

  - Crear la partición `ext4` con el resto del disco y usar con ella la opción
    `noatime` para mejorar el rendimiento.

    Si no se pone el `noatime` durante la instalación, se puede poner luego
    editando el `/etc/fstab` y cambiando `defaults` por `noatime`. Para activar
    en el momento sin tener que reiniciar, se puede hacer:

    `$ sudo mount -o remount /`

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

## NVIDIA

- En _NVIDIA X Server Settings_:

  - Poner resolución 1920x1080 a 75 Hz.

  - En `Avanzada` poner `Allow G-SYNC on monitor not validated as G-SYNC
    Compatible`.

  - En `OpenGL Settings`:

    - Activar `Sync to VBlank`.

    - Activar `Allow G-SYNC/G-SYNC Compatible`.

    - La opción `Allow Flipping` se puede desactivar cuando se use _Steam Link_
      en la TV para que no parpadee, aunque eso sólo me pasaba en Ubuntu y no
      en Debian.

## AUDIO

(Fuente: https://wiki.archlinux.org/index.php/PulseAudio/Troubleshooting)

- Para evitar que el micrófono tenga mucho ruido, lo mejor es usar un enchufe
  con toma de tierra. Eso elimina el ruido de raíz.

- Si no se puede, hacer:

  - `$ sudo vim /etc/pulse/default.pa`

    Añadir al final:

    ```
    load-module module-echo-cancel aec_method=webrtc aec_args="analog_gain_control=0 digital_gain_control=1" source_name=echoCancel_source
    set-default-source echoCancel_source
    ```

  - En el *Control de volumen* de PulseAudio, usar como *Dispositivo de
    entrada* el que ponga `echo cancelled...`.

  - `$ sudo vim /etc/pulse/daemon.conf`

    Establecer:

    ```
    default-sample-rate = 48000
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

## JUEGOS

### NINTENDO SWITCH PRO CONTROLLER

- Comprobar que está activo el Bluetooth mirando en `/etc/default/bluetooth`
  si existe la siguiente línea:

  ```
  BLUETOOTH_ENABLED=1
  ```

- Juegos fuera de Steam:

  - Hay que usar los controladores
    [dkms-hid-nintendo](https://github.com/nicman23/dkms-hid-nintendo) y
    [joycond](https://github.com/DanielOgorchock/joycond).

- En Steam:

  - Los controladores anteriores son incompatibles con el que usa Steam, así
    que hay que deshabilitarlos:

    - Crear `/etc/modprobe.d/blacklist-hid_nintendo.conf` con el siguiente
      contenido:
    
      ```
      blacklist hid_nintendo
      ```

    - `$ sudo systemctl disable joycond.service`

  - Dentro de Steam, hay que:

    - Usar siempre Big Picture.

    - Dejar que Steam detecte el mando como un _Nintendo Switch Pro
      Controller_.

    - Desactivar la vibración en las preferencias del mando:

      ![](opciones-globales-mando.png)

    - La vibración se puede activar por cada juego de forma local durante una
      partida pulsando el botón de la casa y entrando en las opciones del
      mando:

      ![](opciones-locales-mando.png)

    - La mayoría de los juegos funcionan mejor forzando el uso de Stem Input en
      las preferencias de cada juego dentro de Steam.

### STEAM LINK

- Para que la imagen no parpadee (ésto sólo me pasaba en Ubuntu):

  - En _NVIDIA X Server Settings_, opción `OpenGL Settings`:

    - Desactivar `Allow Flipping`.

- Para que el sonido no se vaya degradando y se pierda con el tiempo:

  - En _Control de volumen de PulseAudio_:

    - En `Configuración`, desactivar todos los perfiles de audio.

      Se creará automáticamente un dispositivo virtual `Dummy`. (Si no
      apareciera, arrancar primero Steam.)

- Cuando se acabe de jugar, se deben deshacer los cambios en sentido contrario.

(Fuente: https://github.com/ValveSoftware/steam-for-linux/issues/6749#issuecomment-753639362)

### THE TALOS PRINCIPLE

- Jugar en modo Big Picture.

- En `Configuración del mando`, seleccionar la configuración `Mando`.

### ALIEN ISOLATION

- Es mucho mejor usar Proton 5.0 que la versión nativa de Linux (va más suave y
  con más fps). Para ello:

  - Entrar en las Propiedades del juego.

  - En el apartado `Compatibilidad`, activar `Forzar el uso de una herramienta
    específica de compatibilidad para Steam Play`.

  - Elegir `Proton 5.0-10`.

### CIVILIZATION V

- Para que no se bloquee casi al principio:

  - `$ vim .local/share/Aspyr/Sid\ Meier\'s\ Civilization\ 5/config.ini`

    Poner `MaxSimultaneousThreads = 16`

### THE ELDER SCROLLS V: SKYRIM - SPECIAL EDITION

- Para que se escuchen las voces y la música de fondo, poner los siguientes
  parámetros de lanzamiento:

  ```
  WINEDLLOVERRIDES="xaudio2_7=n,b" PULSE_LATENCY_MSEC=90 %command%
  ```

### THE WITCHER 3: WILD HUNT

- Para que no haya caídas en el rendimiento en fps, poner todo a `Ultra`
  excepto:

  - `NVIDIA HairWorks`: No

  - `Alcance de visibilidad del follaje`: Alta

### MASS EFFECT 2

- Instalar y arrancar una vez.

- La primera vez que se arranca no hay sonido. Las siguientes veces ya sí.

- Extraer `ME2Controller-1.7.2.7z` sobre la carpeta `BioGame` de la instalación
  del juego.

- En Steam, configurar el mando en modo `Mando`.

- El juego se bloqueará si se intenta jugar sin conectarse a Cerberus.

### BIOSHOCK 2

- Para que se carguen bien las texturas y todo vaya más rápido, poner los
  siguientes parámetros de lanzamiento:

  ```
  PROTON_NO_ESYNC=1 %command% -nointro
  ```

### DEUS EX: HUMAN REVOLUTION

(Fuente: https://gaming.stackexchange.com/questions/147596/how-can-i-fix-stuttering-and-lag-issues-in-deus-ex-hr-directors-cut/147642)

- Al salir del juego hay que esperar unos tres minutos o matar el proceso.

- NO usar DirectX 11 para que se carguen correctamente todas las texturas.

- Para reducir bastante los tirones durante el juego:

  - Usar los siguientes parámetros de lanzamiento:

    ```
    PROTON_USE_DXVK=1 PROTON_NO_ESYNC=1 %command%
    ```

  - Poner un antialiasing bajo.

  - Investigar si se trata únicamente de la compilación de shaders. Si pasado
    un tiempo dentro del juego se arregla solo, es que era eso. En caso
    contrario:

  - `$ WINEPREFIX=~/.local/share/Steam/steamapps/compatdata/28050/pfx ~/.local/share/Steam/steamapps/common/Proton\ 5.0/dist/bin/wine regedit`

  - En `HKEY_CURRENT_USER\Software\Eidos\Deus Ex: HRDC`, poner `AllowJobStealing` a `0`.

### NO MAN'S SKY

- En opciones gráficas:

  - Poner la primera opción (tamaño de texturas) a `Media` y el resto de
    opciones a `Alta`.

  - Activar el Vsync.

- La rama 6.0 de Proton funciona mejor que la 5.0.

### DEATH STRANDING

- Desactivar Steam Input para que el juego detecte y gestione él solo el
  Nintendo Switch Pro Controller.

