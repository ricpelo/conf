# CONFIGURACIÓN DE AZATHOTH

## BIOS

### MEMORIA RAM

- Usar perfil 1 de XMP (va a 2933 MHz)

- Cuidado: al activar un perfil XMP se cambia automáticamente la curva de
  temperaturas y ventilación de la CPU, machacando los valores que había.

- El perfil 2 de XMP (que va a 3200 MHz) en principio es compatible según las
  especificaciones de la placa base, PERO hace que el test Prime95 Blend se
  rompa desde el primer momento, cosa que no pasa con el perfil 1.

### OVERCLOCK

- Precision Boost Overdrive desactivado.

### VENTILADORES

#### CPU (fan2 en lm_sensors)

- Ahora mismo lo tengo así:

    Temp.    %
    ------ -----
     20º     38
     65º     38
     75º     80
     85º    100

    Step up time: 0.7s
    Step down time: 1.0s

- Otras curvas que he probado:

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

  pero resulta que Tdie está continuamente dando pequeños saltos de unos 10º,
  lo que provoca que el ventilador de la CPU pegue un salto y luego baje casi
  enseguida, lo que resulta molesto (y seguramente no sea muy bueno para el
  motor del ventilador).

  Para arreglarlo, pongo el ventilador a una velocidad constante de 38-40%
  hasta los 55º-60º-65º, y a partir de ahí subo la velocidad. TODO: Testear por
  si hay que poner una rampa más empinada en situaciones de estrés.

  Es mejor usar el 38% que el 40% para el ventilador de la CPU, porque al 40%
  se oye un zumbido molesto de vibración, sobre todo por la noche.

#### TRASERO (SYSFAN1 en placa, fan3 en lm_sensors)

516 V

#### DELANTEROS (SYSFAN3 en placa, fan6 en lm_sensors)

516 V

Poner una curva dinámica en los ventiladores trasero o delanteros provoca
vibraciones y ruido. Mejor poner un valor constante de 516 V.

## CAJA

- No apretar todos los tornillos del cristal templado para así evitar ruidos,
  zumbidos y vibraciones molestas.

## MONITOR

- Contraste: 50
- Brillo: 40
- Gamma: Gamma3
- Adapt. Sync: Encendido

## NVIDIA

- Poner resolución 1920x1080 a 75 Hz.
- En Avanzada poner Allow G-SYNC on monitor not validated as G-SYNC Compatible.
- En OpenGL Settings:
  - Sync to VBlank
  - Allow G-SYNC/G-SYNC Compatible
  - La opción Allow Flipping se puede desactivar cuando se use Steam Link en la
    TV para que no parpadee.
