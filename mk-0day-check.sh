#!/bin/bash

NET_ID="172.20"
T_INI=4
T_FIM=4
Q_INI=234
Q_FIM=242

while [ $T_INI -le $T_FIM ]; do
  Q_INI_1=$Q_INI
  while [ $Q_INI_1 -le $Q_FIM ]; do
    echo -n "Testando: ${NET_ID}.${T_INI}.${Q_INI_1}... "
    ZDAY=`eval /usr/bin/python3.6 /root/scripts/mikrotik/0day-mikrotik/WinboxExploit.py ${NET_ID}.${T_INI}.${Q_INI_1}`

    if [ $ZDAY = ${NET_ID}.${T_INI}.${Q_INI_1} ]; then
      echo "LIMPO"
    fi

    let Q_INI_1=Q_INI_1+1

  done
  Q_INI_1=$Q_INI
  let T_INI=T_INI+1
done
