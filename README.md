# Testnet privada PoA

Basada en los siguientes tutoriales:

- [Link 1](https://medium.com/coinmonks/private-ethereum-by-example-b77063bb634f)
- [Link 2](https://geth.ethereum.org/docs/interface/private-network)

# Uso

Generar un fichero `genesis.json` y colocarlo en `/genesis/genesis.json`.

Para generar un fichero `genesis.json`, utilizar la siguiente imagen de docker:

`docker run -it ethereum/client-go:alltools-stable`

Y ejecutar dentro de ella el comando `puppeth`. Seguir los menús para crear y exportar posteriormente un fichero `genesis.json`.

Generar un archivo `private_key.txt` que contenga una clave privada válida de Ethereum, y un archivo `password.txt` para cifrarla dentro de `geth`. Modificar `start.sh` en la línea `--unlock 0xDCF7bAECE1802D21a8226C013f7be99dB5941bEa` y sustituir la dirección pública por la correspondiente a la que se genere a partir de la contenida en `private_key.txt`.

Por último, para levantar la red:

```bash
docker-compose up -d
```

# Directorios

- `boot-node-info`: directorio compartido entre los dos contenedores definidos para compartir de forma automática el registro `enr` (una ID de nodo) que les permite agregarse como peers.
- `commands`: directorio donde se ubican los distintos scripts de arranque
- `credentials`: directorio donde se almacenan la clave privada y clave de cifrado
- `datadir`: directorio donde se almacenan los datos de la cadena de bloques del bootnode - node1 (el bootnode debe de estar protegido de llamadas externas)
- `genesis`: directorio donde se almacena el archivo `genesis.json`, generado con `puppeth`
- `light-node-datadir`: directorio donde se almacenan los datos del nodo RCP expuesto a llamadas externas (node2)

# Comandos

- `start.sh`:

Se ejecuta en el nodo maestro (node1) para arrancar geth.

```bash
#!/bin/bash
geth --datadir /datadir account import /credentials/private_key.txt \
    --password /credentials/password.txt;
```

Importa una clave privada definida en `private_key.txt` y la cifra con una contraseña definida en `password.txt`.

```bash
geth --datadir /datadir init /genesis/genesis.json;
```

Inicia la cadena de bloques en `/datadir` siguiendo lo especificado en `genesis.json`.

```bash
geth --datadir /datadir --nat extip:`hostname -i` \
    --unlock 0xDCF7bAECE1802D21a8226C013f7be99dB5941bEa \
    --password /credentials/password.txt \
    --mine --minerthreads=1 --miner.gasprice 0 --miner.gastarget 15000000 --miner.noverify \
    --networkid 19080880;
```

Pone en funcionamiento el protocolo Clique (Proof of Authority). La dirección `0xDCF7bAECE1802D21a8226C013f7be99dB5941bEa` debe corresponderse con la dirección pública obtenida de importar la clave privada en `private_key.txt`. El `networkid` debe ser igual al especificado en el `chainId` dentro de `genesis.json`. `--miner.noverify` permite utilizar un único masternode minero PoA, sin él, es necesario desplegar otro nodo minero (es decir, tener al menos dos mineros PoA).

- `get-noot-node-info.sh`

```bash
#!/bin/bash
sleep 5
echo "OBTAINING NODE INFO..."
# geth attach /datadir/geth.ipc --exec admin.nodeInfo.enode > /boot-node-info/info.txt;
geth attach /datadir/geth.ipc --exec admin.nodeInfo.enr > /boot-node-info/info.txt;
```

Se ejecuta antes que `start.sh`, pero su funcionamiento queda atrasado 5 segundos para permitir al script anterior arrancar `geth`. Obtiene el `enr` del nodo y lo codifica en `/boot-node-info/info.txt`, para que sea leído por el member node (node2).

- `attach-peer.sh`

```bash
#!/bin/sh
sleep 10
fileInfo=`cat /boot-node-info/info.txt`
temp="${fileInfo%\"}"
enode="${temp#\"}"

geth --datadir ./datadir init /genesis/genesis.json
geth --datadir /datadir \
    --rpc --rpcport "7545" --rpcaddr "0.0.0.0" --rpccorsdomain "*" \
    --bootnodes $enode --networkid 19080880
```

Este script se ejecuta en el member node (node2). Por limitaciones de geth es necesario tener dos nodos: el minero o master node (node1), que debe estar protegido de llamadas externas al RCP para evitar exponer claves privadas, y el peer o member node (node2), que hace de relay RCP para las llamadas públicas a la testnet y que no tiene información que pueda comprometerse.

Espera 10 segundos para dar tiempo a node1 a inicializar todos los parámetros y archivos. Posteriormente se conecta a él.
