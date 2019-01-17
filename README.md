# add-worker-DaskCluster
Script para configuración e instalación de requermientos de un worker de Dask-Distributed

## Ejecución
La dirección ip del servicio de scheduler y el dominio con el cual se va hacer referencia se envia como atributos al ejecutar el script. Como se muestra en la linea 2.
```bash
1| wget https://raw.githubusercontent.com/fabidick22/add-worker-DaskCluster/master/add-worker.sh
2| /bin/bash add-worker.sh -i 172.19.18.88 scheduler.com
```
[![asciicast](https://asciinema.org/a/222077.svg)](https://asciinema.org/a/222077?autoplay=1)


## OS Tested
- Debian GNU/Linux 9 (stretch) 64-bit
- CentOS Linux release 7.5 (Core) 64-bit
