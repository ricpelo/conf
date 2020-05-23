# CONFIGURACIÓN DE AZATHOTH

## MONITOR

- Contraste: 50
- Brillo: 40
- Gamma: Gamma3
- Adapt. Sync: Encendido

## BIOS

### MEMORIA RAM

- Usar perfil 1 de XMP (va a 2933 MHz)

- Cuidado: al activar un perfil XMP se cambia automáticamente la curva de
  temperaturas y ventilación de la CPU, machacando los valores que había.

- El perfil 2 de XMP (que va a 3200 MHz) en principio es compatible según las
  especificaciones de la placa base, PERO hace que el test Prime95 Blend se
  rompa desde el primer momento, cosa que no pasa con el perfil 1.

### VENTILADORES

#### CPU (fan2 en lm_sensors)

- Ahora mismo lo tengo así:

    Temp.    %
    ------ -----
     20º     40
     55º     40
     65º     80
     85º    100

    Step up time: 0.7s
    Step down time: 1.0s

- Antes lo tenía así:

    Temp.    %
    ------ -----
     20º     20
     50º     40
     65º     80
     85º    100

  pero resulta que Tdie está continuamente dando pequeños saltos de unos 10º,
  lo que provoca que el ventilador de CPU pegue un salto y luego baje casi
  enseguida, lo que resulta molesto (y seguramente no sea muy bueno para el
  motor del ventilador).

  Para arreglarlo, pongo el ventilador a una velocidad constante de 40% hasta
  los 55º, y a partir de ahí subo la velocidad. TODO: Testear por si hay que
  poner una rampa más empinada en situaciones de estrés.

#### TRASERO (SYSFAN1 en placa, fan3 en lm_sensors)

516 V

#### DELANTEROS (SYSFAN3 en placa, fan6 en lm_sensors)

516 V

Poner una gráfica dinámica en los ventiladores trasero o delanteros provoca
vibraciones y ruido. Mejor poner un valor constante de 516 V.

## NVIDIA

- Poner resolución 1920x1080 a 75 Hz.
- En Avanzada poner Allow G-SYNC on monitor not validated as G-SYNC Compatible.
- En OpenGL Settings:
  - Sync to VBlank
  - Allow G-SYNC/G-SYNC Compatible
  - La opción Allow Flipping se puede desactivar cuando se use Steam Link en la
    TV para que no parpadee.

