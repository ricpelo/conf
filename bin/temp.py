#!/usr/bin/python3

import subprocess
import sys
import time
import signal
import os
import datetime
import psutil


T_MIN: int = 50   # Temperatura por debajo de la cual el ventilador se apaga
T_MAX: int = 90   # Temperatura a partir de la cual se enciende al 100%
T_FIN: int = 45   # Temperatura a alcanzar al salir
V_MIN: int = 0    # Velocidad mínima del ventilador
V_MAX: int = 90   # Velocidad máxima del ventilador
V_CEB: int = 30   # Velocidad de cebado
SLEEP: int = 7    # Segundos de espera entre comprobaciones


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


# GPU: [Lista de ventiladores]
GPUS_FANS: dict[int, list[int]] = {
    0: [0],
    1: [1],
}


def kill_already_running() -> None:
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
    for p in psutil.process_iter():
        if os.getpid() == p.pid:
            continue
        file = os.path.basename(__file__)
        cmdline = ' '.join(p.cmdline())
        if file in cmdline:
            return True
    return False


def buscar_objetivo(temp: int, curva: dict[int, int]) -> tuple[int, int]:
    if temp < T_MIN:
        return (0, 0)
    for t, f in curva.items():
        if temp < t:
            return (t, f)
    return (T_MAX, V_MAX)


def siguiente_velocidad(actual: int, objetivo: int, curva: dict[int, int]) -> int:
    if actual == objetivo:
        return actual
    if objetivo == 0:
        return 0
    if actual < objetivo:
        for v in curva.values():
            if v <= actual:
                continue
            if v <= objetivo:
                return v
        return V_MAX
    for v in reversed(curva.values()):
        if v >= actual:
            continue
        if v >= objetivo:
            return v
    return V_MIN


def run_command(command: str) -> subprocess.CompletedProcess[str]:
    comando = ['nvidia-settings', command, '-t']
    return subprocess.run(
        comando,
        encoding='utf-8',
        check=True,
        stdout=subprocess.PIPE
    )


def get_query_num(query: str) -> int:
    return int(run_command(query).stdout.split('\n', 1)[0].split(' ', 1)[0])


def get_query_str(query: str) -> int:
    return int(run_command(query).stdout.strip())


def get_temp(gpu: int) -> int:
    return get_query_str(f'-q=[gpu:{gpu}]/GPUCoreTemp')


def get_temps() -> list[int]:
    return [get_temp(gpu) for gpu in get_gpus()]


def get_speed(fan: int) -> int:
    return get_query_str(f'-q=[fan:{fan}]/GPUCurrentFanSpeed')


def set_speed(fan: int, veloc: int) -> None:
    log(run_command(f'-a=[fan:{fan}]/GPUTargetFanSpeed={veloc}')
        .stdout.strip())


def set_speeds(veloc: int) -> None:
    for gpu in get_gpus():
        for fan in get_fans(gpu):
            set_speed(fan, veloc)


def set_fan_control(gpu: int, estado: int) -> None:
    log(run_command(f'-a=[gpu:{gpu}]/GPUFanControlState={estado}')
        .stdout.strip())


def set_fans_control(estado: int):
    for gpu in get_gpus():
        set_fan_control(gpu, estado)


def get_num_gpus() -> int:
    return get_query_num('-q=gpus')


def get_gpus() -> list[int]:
    return list(GPUS_FANS.keys())[:get_num_gpus()]


def get_fans(gpu: int) -> list[int]:
    return GPUS_FANS[gpu][:get_num_fans()] if gpu in range(get_num_gpus()) else []


def get_num_fans() -> int:
    return get_query_num('-q=fans')


def log(s: str) -> None:
    ts = datetime.datetime.now().replace(microsecond=0)
    print(f'{ts} - {s}')
    sys.stdout.flush()


def esperar(tiempo=SLEEP):
    time.sleep(tiempo)


def finalizar(_signum, _stack) -> None:
    it = iter(CURVA)
    v_primera = next(it)
    veloc = 0
    i = 0

    while True:
        # Si todas las GPUs están por debajo de T_FIN, nos salimos:
        try:
            if all(temp <= T_FIN for temp in get_temps()):
                break
        except ValueError:
            break

        log('Esperando a que baje la temperatura...')

        # Al principio:
        if i == 0:
            for gpu in get_gpus():
                for fan in get_fans(gpu):
                    # Si gira a menos de la primera velocidad de la curva,
                    # probamos primero con V_CEB. Si no, probamos a la
                    # primera velocidad:
                    veloc = V_CEB if get_speed(fan) < v_primera else v_primera
                    set_speed(fan, veloc)

        esperar()

        # Si después de 10 intentos, la temperatura sigue alta:
        if i == 10:
            # Subimos la velocidad:
            for gpu in get_gpus():
                for fan in get_fans(gpu):
                    veloc = v_primera if get_speed(fan) < v_primera else next(it)
                    set_speed(fan, veloc)
            i += 1
        elif i < 10:
            i += 1

    set_fans_control(0)
    log('Fan control set back to auto mode.')
    sys.exit(0)


def finalizar_usr(_signum, _stack):
    msg = 'Proceso temp.py detenido'
    comando = ['notify-send', '-u', 'critical', msg]
    subprocess.run(comando, encoding='utf-8', check=True, stdout=subprocess.PIPE)
    log(msg)
    sys.exit(0)


def cebador(fan: int, sgte_veloc: int) -> bool:
    if get_speed(fan) == 0 and sgte_veloc > 0 and sgte_veloc > V_CEB:
        log('Iniciando proceso de cebado...')
        set_speed(fan, V_CEB)
        while get_speed(fan) < V_CEB:
            log('Finalizando proceso de cebado...')
            esperar()
        return True
    return False


def bucle(temp_actual: int, fan: int, curva: dict[int, int]) -> None:
    veloc_actual = get_speed(fan)
    _, objetivo = buscar_objetivo(temp_actual, curva)
    sgte_veloc = siguiente_velocidad(veloc_actual, objetivo, curva)
    if veloc_actual != 0 and sgte_veloc == 0 and temp_actual > T_FIN:
        log(f'No se apaga el ventilador por encima de {T_FIN} grados.')
        return
    if veloc_actual != sgte_veloc:
        log(f'Cambiando a velocidad {sgte_veloc}, con objetivo {objetivo}.')
        if not cebador(fan, sgte_veloc):
            set_speed(fan, sgte_veloc)


def main():
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
    # kill_already_running()
    if hay_mas_procesos():
        log('Hay otro proceso ejecutándose.')
        sys.exit(1)
    log(f'Started process por {get_num_gpus()} GPUs and {get_num_fans()} fans.')
    set_fans_control(1)
    set_speeds(0)

    while True:
        for gpu in get_gpus():
            temp_actual = get_temp(gpu)
            for fan in get_fans(gpu):
                bucle(temp_actual, fan, CURVA)
            esperar()


if __name__ == '__main__':
    main()
