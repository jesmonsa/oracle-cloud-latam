#!/bin/bash
# Configuración automatizada de Volume iSCSI
iqn=$1
ip=$2
port=$3
punto_montaje=$4

iscsiadm -m node -o new -T $iqn -p $ip:$port
iscsiadm -m node -o update -T $iqn -n node.startup -v automatic
iscsiadm -m node -T $iqn -p $ip:$port -l

# Esperar a que el disco esté disponible
sleep 10
disco=$(ls -1 /dev/oracleoci/oraclevd* | tail -n 1)

if [ ! -z "$disco" ]; then
  mkfs.xfs -f $disco
  mkdir -p $punto_montaje
  mount $disco $punto_montaje
  echo "$disco $punto_montaje xfs defaults,_netdev,nofail 0 2" >> /etc/fstab
fi
