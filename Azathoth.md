# CONFIGURACIÓN DE AZATHOTH

## BIOS

### MEMORIA RAM

- Usar perfil 2 de XMP (va a 3200 MHz)

- Cuidado: al activar un perfil XMP se cambia automáticamente la curva de
  temperaturas y ventilación de la CPU, machacando los valores que había.

### VENTILADORES

#### CPU (fan2 en lm_sensors)

Temp.    %
------ -----
 20º     20
 50º     40
 65º     80
 85º    100

##### Testear

Step up time: 0.7s
Step down time: 1.0s

(Estos dos valores ayudan a evitar picos de subida y bajada repentina del
ventilador que ocurren con frecuencia cuando estoy trabajando.)

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

