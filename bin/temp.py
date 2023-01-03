#!/usr/bin/python3

from __future__ import annotations
from typing import Optional

import subprocess
import sys
import time
import signal
import os
import datetime
import statistics
import psutil

V_DEBUG = True

T_MIN: int   = 50    # Temperatura por debajo de la cual el ventilador no se enciende
T_MAX: int   = 90    # Temperatura a partir de la cual el ventilador se enciende al máximo
T_FIN: int   = 45    # Temperatura a alcanzar al salir
V_MIN: int   = 0     # Velocidad mínima del ventilador
V_MAX: int   = 90    # Velocidad máxima del ventilador
V_INI: int   = 25    # Velocidad inicial del ventilador durante el cebado
V_CEB: int   = 35    # Velocidad de cebado
SLEEP: float = 7.0   # Segundos de espera entre comprobaciones


# Curva de temperaturas y velocidades
# Temperatura (ºC): velocidad (%)
CURVA: dict[int, int] = {
    55: 45,
    60: 60,
    65: 64,
    70: 68,
    75: 75,
    80: 80,
    85: 85
}


# GPU: {Diccionario con cada número de ventilador y su curva asociada}
GPUS_FANS: dict[int, dict[int, dict[int, int]]] = {
    0: {0: CURVA},
    # 1: {1: CURVA},
}


class Fan:
    """Cada instancia de esta clase representa un ventilador de una GPU."""

    __num_fans: Optional[int] = None


    def __init__(self, f_num: int, params: dict[str, int], curva: dict[int, int]) -> None:
        if f_num not in range(Fan.get_num_fans()):
            error('El número de GPU está fuera del rango.')
        self.__f_num = f_num
        self.__curva = curva
        self.__v_min = params['v_min']
        self.__v_max = params['v_max']
        self.__v_ini = params['v_ini']
        self.__v_ceb = params['v_ceb']
        log(f'Creado ventilador n.º {f_num}.')
        log(f'El ventilador n.º {f_num} tiene la siguiente curva:')
        log(str(curva))


    @classmethod
    def get_num_fans(cls) -> int:
        """
        Devuelve el número de ventiladores que hay instalados en el sistema.
        """
        if cls.__num_fans is None:
            cls.__num_fans = get_query_num('-q=fans')
        return cls.__num_fans


    def get_f_num(self) -> int:
        """Devuelve el número del ventilador."""
        return self.__f_num


    def get_v_min(self):
        """Devuelve la velocidad mínima del ventilador."""
        return self.__v_min


    def get_v_max(self):
        """Devuelve la velocidad máxima del ventilador."""
        return self.__v_max


    def get_v_ini(self):
        """
        Devuelve la velocidad inicial del ventilador durante el proceso
        de cebado.
        """
        return self.__v_ini


    def get_v_ceb(self):
        """Devuelve la velocidad de cebado del ventilador."""
        return self.__v_ceb


    def get_curva(self):
        """Devuelve la curva de temperaturas y velocidades del ventilador."""
        return self.__curva


    def arrancar(self):
        """
        Pone el ventilador a una velocidad (v_ini, que en principio es 25 %)
        más baja que la de cebado, si no estaba ya a esa velocidad o superior,
        y espera unos segundos.
        """
        if self.get_speed() < self.get_v_ini():
            self.set_speed(self.get_v_ini())
            esperar(3.0)


    def cebador(self, sgte_veloc: int) -> bool:
        """
        El ventilador de mi GPU hace un ruido muy desagradable cuando arranca
        a velocidades medias-altas (de 50 % en adelante). El cebado es el
        proceso por el cual arrancamos el ventilador a una velocidad reducida
        (V_CEB, que en principio es 35 %) antes de pasar a una velocidad
        superior. Este proceso sólo es necesario cuando se arranca el
        ventilador, es decir, cuando el ventilador está parado (0 %) y queremos
        llevarlo a cualquier velocidad de la curva.
        Toda velocidad inferior a 35 % en mi GPU resulta luego en unas
        mediciones muy inestables de la velocidad del ventilador, por lo que
        entiendo que 35 % es la mínima velocidad estable para mi GPU.

        Devuelve True si ha habido que hacer un cebado, o False en caso
        contrario.
        """
        if self.get_speed() < self.get_v_ceb() and sgte_veloc > self.get_v_ceb():
            log(f'Iniciando proceso de cebado al {self.get_v_ceb()} %...')
            # Empieza primero con una velocidad más reducida (v_ini, que en
            # principio es 25%) antes de pasar a la velocidad de cebado.
            # TODO: Probar a quitarlo y ver si cambia en algo.
            self.arrancar()
            self.get_speed() # Para hacer log de la velocidad actual
            self.set_speed(self.get_v_ceb())
            while True:
                v_actual = self.get_speed()
                if v_actual >= self.get_v_ceb() and v_actual - self.get_v_ceb() <= 2:
                    break
                log(f'Continuando proceso de cebado, actualmente al {v_actual} %...')
                esperar(3.0)
            log(f'Proceso de cebado finalizado al {v_actual} %...')
            return True
        return False


    def get_speed(self) -> int:
        """
        A veces, el ventilador da medidas imprecisas, erráticas e incluso
        totalmente erróneas, sobre todo a bajas velocidades (< 35 %).
        Lo que hacemos es tomar varias muestras y luego calcular la mediana.
        La media no es muy útil porque pueden aparecer valores muy extremos
        que claramente son erróneos.
        """
        VECES = 5
        lst = []
        for _ in range(VECES):
            while True:
                veloc = get_query_str(f'-q=[fan:{self.get_f_num()}]/GPUCurrentFanSpeed')
                if veloc in range(0, 101):
                    break
            lst.append(veloc)
        mediana = round(statistics.median(lst))
        if V_DEBUG:
            log(f'Velocidades: {lst} Mediana: {mediana} %')
        return mediana


    def set_speed(self, veloc: int) -> None:
        """
        Establece la velocidad del ventilador.
        """
        log(run_command(f'-a=[fan:{self.get_f_num()}]/GPUTargetFanSpeed={veloc}')
            .stdout.strip())


    def buscar_objetivo(self, temp: int, gpu: GPU) -> tuple[int, int]:
        """
        Busca en la curva del ventilador el tramo dentro del que nos encontramos
        en función de la temperatura.
        Devuelve una tupla (temperatura, velocidad), que representa el tramo
        adecuado de la curva.
        Actualmente, el componente de temperatura de la tupla no se usa.
        Si la temperatura es inferior a t_min, devuelve (0, 0) para indicar
        que el ventilador no se debe encender.
        """
        if temp < gpu.get_t_min():
            return (0, 0)
        for t, f in self.get_curva().items():
            if temp < t:
                return (t, f)
        return (gpu.get_t_max(), self.get_v_max())


    def siguiente_velocidad(self, actual: int, objetivo: int) -> int:
        """
        Devuelve la siguiente velocidad a la que habría que poner el ventilador
        a partir de la velocidad actual y de la velocidad objetivo que se
        pretende alcanzar. La idea es que si, por ejemplo, queremos llegar a
        64 % pero estamos en 45 %, no vamos a hacer el cambio directamente en
        un solo paso, sino que pasaremos previamente por todos los tramos
        intermedios (45 % -> 60 % -> 64 %). La idea es que el ventilador no
        haga ruido al exigirle un cambio muy abrupto.
        """
        if actual == objetivo:
            return actual
        if objetivo == 0:
            return 0
        if actual < objetivo:
            for v in self.__curva.values():
                if v <= actual:
                    continue
                if v <= objetivo:
                    return v
            return self.get_v_max()
        for v in reversed(self.__curva.values()):
            if v >= actual:
                continue
            if v >= objetivo:
                return v
        return self.get_v_min()


class GPU:
    """Cada instancia de esta clase representa una GPU."""

    __num_gpus: Optional[int] = None


    def __init__(self, g_num: int, params: dict[str, int], fans: list[Fan]) -> None:
        if g_num not in range(GPU.get_num_gpus()):
            error('El número de GPU está fuera del rango.')
        self.__g_num = g_num
        self.__fans = fans
        self.__t_min = params['t_min']
        self.__t_max = params['t_max']
        self.__t_fin = params['t_fin']
        fans_nums = [fan.get_f_num() for fan in fans]
        log(f'Creada GPU n.º {g_num} con los siguientes ventiladores: {fans_nums!s}.')

    @classmethod
    def get_num_gpus(cls) -> int:
        """Devuelve el número de GPUs que hay instaladas en la máquina."""
        if cls.__num_gpus is None:
            cls.__num_gpus = get_query_num('-q=gpus')
        return cls.__num_gpus


    def g_num(self) -> int:
        """Devuelve el número de la GPU."""
        return self.__g_num


    def get_temp(self) -> int:
        """Devuelve la temperatura actual (en ºC) de la GPU."""
        return get_query_str(f'-q=[gpu:{self.g_num()}]/GPUCoreTemp')


    def get_fans(self) -> list[Fan]:
        """Devuelve el número de ventiladores que tiene la GPU."""
        return self.__fans


    def get_t_min(self):
        """
        Devuelve la temperatura por debajo de la cual no se enciende nunca
        ninguno de los ventiladores de la GPU. Por omisión es T_MIN (50 %).
        """
        return self.__t_min


    def get_t_max(self):
        """
        Devuelve la temperatura por encima de la cual se encienden todos
        los ventiladores de la GPU al máximo (V_MAX, por omisión 90 %).
        Por omisión es T_MAX (90 ºC).
        """
        return self.__t_max


    def get_t_fin(self):
        """
        Devuelve la temperatura que hay que alcanzar al finalizar el script y
        antes de apagar el ventilador (T_FIN, por omisión 45 ºC).
        El ventilador no se apaga hasta que se haya alcanzado esta temperatura.
        """
        return self.__t_fin


    def set_fan_control(self, estado: int) -> None:
        """
        Activa o desactiva el GPUFanControlState para poder poner el control
        en modo manual (estado == 1) o automático (estado == 0).
        """
        log(run_command(f'-a=[gpu:{self.g_num()}]/GPUFanControlState={estado}')
            .stdout.strip())


class Manager:
    """
    Representa el gestor que lleva a cabo el bucle de procesamiento principal
    de supervisión y control de las temperaturas y los ventiladores de las GPUs
    del sistema."""

    __singleton: Optional[Manager] = None


    @classmethod
    def get_singleton(cls) -> Manager:
        """
        Devuelve la única instancia de la clase Manager que debería haber.
        """
        if cls.__singleton is None:
            cls.__singleton = Manager()
        return cls.__singleton


    def __init__(self):
        self.__gpus = []


    def get_gpus(self) -> list[GPU]:
        """
        Devuelve la lista con las GPUs registradas en el manager.
        """
        return self.__gpus


    def set_gpus(self, gpus: list[GPU]) -> None:
        """
        Establece la lista con las GPUs registradas en el manager.
        """
        self.__gpus = gpus


    def get_temps(self) -> list[int]:
        """
        Devuelve una lista con las temperaturas actuales de todas las GPUs
        instaladas en el sistema y registradas en el manager.
        """
        return [gpu.get_temp() for gpu in self.get_gpus()]


    def set_speeds(self, veloc: int) -> None:
        """
        Establece la misma velocidad a todos los ventiladores de todas las GPUs
        instaladas en el sistema y registradas en el manager.
        """
        for gpu in self.get_gpus():
            for fan in gpu.get_fans():
                fan.set_speed(veloc)


    def set_fans_control(self, estado: int):
        """
        Activa o desactiva el GPUFanStateControl a todas las GPUs instaladas
        en el sistema y registradas en el manager.
        """
        for gpu in self.get_gpus():
            gpu.set_fan_control(estado)


    def bucle(self, temp_actual: int, gpu: GPU, fan: Fan) -> None:
        """
        El bucle principal del manager. A partir de la temperatura y velocidad
        actuales, calcula la velocidad objetivo y la siguiente velocidad a
        establecer en camino hacia esa velocidad objetivo.
        El ventilador no se apaga si estamos a una temperatura superior a t_fin.
        """
        veloc_actual = fan.get_speed()
        _, objetivo = fan.buscar_objetivo(temp_actual, gpu)
        sgte_veloc = fan.siguiente_velocidad(veloc_actual, objetivo)
        stat = f'[Actual: ({temp_actual} ºC, {veloc_actual} %)]'
        if veloc_actual != 0 and sgte_veloc == 0 and temp_actual > gpu.get_t_fin():
            log(f'{stat} No se apaga el ventilador por encima de {gpu.get_t_fin()} ºC.')
            return
        if veloc_actual != sgte_veloc:
            log(f'{stat} Cambiando a velocidad {sgte_veloc} % con objetivo {objetivo} %.')
            if not fan.cebador(sgte_veloc):
                fan.set_speed(sgte_veloc)


def get_query_num(query: str) -> int:
    """
    Función auxiliar usada por algunas funciones para ejecutar el comando
    nvidia-settings.
    """
    return int(run_command(query).stdout.split('\n', 1)[0].split(' ', 1)[0])


def get_query_str(query: str) -> int:
    """
    Función auxiliar usada por algunas funciones para ejecutar el comando
    nvidia-settings.
    """
    return int(run_command(query).stdout.strip())


def run_command(command: str) -> subprocess.CompletedProcess[str]:
    """
    Ejecuta el comando nvidia-settings con las opciones indicadas y devuelve
    el resultado que se podrá aprovechar luego para obtener la respuesta
    necesaria.
    """
    comando = ['nvidia-settings', command, '-t']
    return subprocess.run(
        comando,
        encoding='utf-8',
        check=True,
        stdout=subprocess.PIPE
    )


def kill_already_running() -> None:
    """
    Si el script está ya ejecutándose, detiene todos los procesos menos éste.
    """
    salir = False
    while not salir:
        salir = True
        for p in psutil.process_iter():
            if os.getpid() == p.pid:
                continue
            file = os.path.basename(__file__)
            cmdline = ' '.join(p.cmdline())
            if file in cmdline:
                salir = False
                os.kill(p.pid, signal.SIGUSR1)
                log(f'Killed process {p.pid}')
                esperar()


def hay_mas_procesos() -> bool:
    """
    Devuelve True si hay ya un proceso ejecutándose para este script.
    Se basa en el nombre del fichero, así que no es muy fiable.
    TODO: Buscar otra forma de detectar mejor si el proceso es de este script.
    """
    for p in psutil.process_iter():
        if os.getpid() == p.pid:
            continue
        file = os.path.basename(__file__)
        cmdline = ' '.join(p.cmdline())
        if file in cmdline:
            return True
    return False


def log(s: str) -> None:
    """Genera un registro a la salida."""
    ts = datetime.datetime.now().replace(microsecond=0)
    print(f'{ts} - {s}')
    sys.stdout.flush()


def esperar(tiempo: float = SLEEP):
    """Detiene el proceso durante varios segundos (por omisión SLEEP = 7s)."""
    time.sleep(tiempo)


def finalizar(_signum, _frame) -> None:
    """
    Detiene correctamente la ejecución del script. Para ello:
    - Se espera a que todas las GPUs estén por debajo de t_fin de temperatura.
    - Pone los ventiladores a girar. Si gira a menos de la primera velocidad de
      la curva, probamos primero con v_ceb. Si no, probamos a la primera
      velocidad.
    - Si después de 10 intentos, la temperatura aún no ha alcanzado el t_fin,
      subimos la velocidad al siguiente tramo en la curva.
    - Finalmente, pone el GPUFanControlState en modo automático.
    """
    manager = Manager.get_singleton()
    veloc = 0
    i = 0

    while True:
        # Si todas las GPUs están por debajo de t_fin, nos salimos:
        try:
            if all(gpu.get_temp() <= gpu.get_t_fin() for gpu in manager.get_gpus()):
                break
        except ValueError:
            break

        log('Esperando a que baje la temperatura...')

        # Al principio:
        if i == 0:
            for gpu in manager.get_gpus():
                for fan in gpu.get_fans():
                    # Si gira a menos de la primera velocidad de la curva,
                    # probamos primero con v_ceb. Si no, probamos a la
                    # primera velocidad:
                    it = iter(fan.get_curva())
                    v_primera = next(it)
                    if fan.get_speed() < v_primera:
                        fan.arrancar()
                        veloc = fan.get_v_ceb()
                    else:
                        veloc = v_primera
                    fan.set_speed(veloc)

        esperar()

        # Si después de 10 intentos, la temperatura sigue alta:
        if i == 10:
            # Subimos la velocidad:
            for gpu in manager.get_gpus():
                for fan in gpu.get_fans():
                    it = iter(fan.get_curva())
                    v_primera = next(it)
                    veloc = v_primera if fan.get_speed() < v_primera else next(it)
                    fan.set_speed(veloc)
            i += 1
        elif i < 10:
            i += 1

    manager.set_fans_control(0)
    log('Fan control set back to auto mode.')
    sys.exit(0)


def finalizar_usr(_signum, _frame):
    """
    Finaliza el proceso pero dejándolo en modo manual y sin hacer ninguna
    comprobación sobre la temperatura de la GPU.
    ADVERTENCIA: Usar sólo si se sabe lo que se está haciendo.
    """
    msg = "Proceso temp.py detenido.\n\n¡CUIDADO! El control sigue en modo manual."
    comando = ['notify-send', '-u', 'critical', msg]
    subprocess.run(comando, encoding='utf-8', check=True, stdout=subprocess.PIPE)
    log(msg)
    sys.exit(0)


def error(s):
    """Muestra un mensaje de error en el registro y se sale del script."""
    log(f'Error: {s}')
    sys.exit(1)


def comprobaciones():
    """Lleva a cabo varias comprobaciones previas a empezar."""
    # kill_already_running()
    if hay_mas_procesos():
        error('Hay otro proceso ejecutándose.')

    try:
        log(f'Proceso iniciado para {GPU.get_num_gpus()} GPUs y {Fan.get_num_fans()} ventiladores.')
    except ValueError:
        error('No se pudo obtener el número de GPUs y ventiladores.')

    if GPU.get_num_gpus() != len(GPUS_FANS):
        error('El número de GPUs instaladas no coincide con los que aparecen en GPUS_FANS.')

    if Fan.get_num_fans() != sum(len(f) for f in GPUS_FANS.values()):
        error('El número de ventiladores instalados no coincide con los que aparecen en GPUS_FANS.')


def main():
    """Función principal."""
    sigs = {
        signal.SIGINT,
        signal.SIGHUP,
        signal.SIGQUIT,
        signal.SIGABRT,
        signal.SIGALRM,
        signal.SIGTERM
    }
    for sig in sigs:
        signal.signal(sig, finalizar)
    signal.signal(signal.SIGUSR1, finalizar_usr)

    comprobaciones()

    gpus = []
    for g_num, f_items in GPUS_FANS.items():
        fans = []
        for f_num, curva in f_items.items():
            params = {'v_min': V_MIN, 'v_max': V_MAX, 'v_ini': V_INI, 'v_ceb': V_CEB}
            fan = Fan(f_num, params, curva)
            fans.append(fan)
        gpu = GPU(g_num, {'t_min': T_MIN, 't_max': T_MAX, 't_fin': T_FIN}, fans)
        gpus.append(gpu)

    manager = Manager.get_singleton()
    manager.set_gpus(gpus)
    manager.set_fans_control(1)
    manager.set_speeds(0)

    while True:
        for gpu in manager.get_gpus():
            temp_actual = gpu.get_temp()
            for fan in gpu.get_fans():
                manager.bucle(temp_actual, gpu, fan)
            esperar()


if __name__ == '__main__':
    main()
