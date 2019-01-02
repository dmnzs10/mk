#!/bin/bash

USERS="admin avato noc"
PASSW="senha1 Solib6shahco senha2"
PORTS="22 222"
DBTI_HOST="177.36.33.76"
DBTI_USER="root"
DBTI_PASS="4vis0@GPSnet"
DBTI_BASE="avisos_mikrotik"
PORT="222"

# Conecta no banco da TI para obter a lista dos concentradores
DBTI_CE=$(echo "SELECT server_ip FROM authentication_concentrators ORDER BY id ASC LIMIT 1" | mysql -N -h $DBTI_HOST -D $DBTI_BASE -u $DBTI_USER -p${DBTI_PASS})
#DBTI_CE=$(echo "SELECT server_ip FROM authentication_concentrators ORDER BY id ASC" | mysql -N -h $DBTI_HOST -D $DBTI_BASE -u $DBTI_USER -p${DBTI_PASS})

# Inicio
for HOST in $DBTI_CE; do
  SSH=0
  USER=$(echo "SELECT server_user FROM authentication_concentrators WHERE server_ip='${HOST}'" | mysql -N -h $DBTI_HOST -D $DBTI_BASE -u $DBTI_USER -p${DBTI_PASS})
  PASS=$(echo "SELECT server_password FROM authentication_concentrators WHERE server_ip='${HOST}'" | mysql -N -h $DBTI_HOST -D $DBTI_BASE -u $DBTI_USER -p${DBTI_PASS})
  
  # teste de conexao
  if [ $SSH -eq 0 ]; then
    sshpass -p ${PASS} ssh -p ${PORT} -o StrictHostKeyChecking=no ${USER}@${HOST} "/" >/dev/null 2>&1
    #echo "$?"

    # retorno do teste de conexao
    if [ $? -eq 0 ]; then
      SSH="1"
      echo "Passou com ${USER}@${HOST}:${PORT} - $PASS"
      sshpass -p ${PASS} ssh -p ${PORT} -T -o StrictHostKeyChecking=no ${USER}@${HOST} <<-EOF
	/ip firewall nat remove [find comment="BLOQUEIO_NO_NAT_TO_SERVER"]
	/ip firewall nat remove [find comment="BLOQUEIO_Aviso_Bloqueio_80"]
	/ip firewall nat remove [find comment="BLOQUEIO_Aviso_Bloqueio_443"]
	/ip firewall nat remove [find comment="BLOQUEIO_Bloqueado_80"]
	/ip firewall nat remove [find comment="BLOQUEIO_Bloqueado_443"]
	/ip firewall nat add action=accept chain=srcnat comment=BLOQUEIO_NO_NAT_TO_SERVER dst-address=177.36.33.76 dst-port=80,443 protocol=tcp
	/ip firewall nat add action=dst-nat chain=dstnat comment=BLOQUEIO_Aviso_Bloqueio_80 dst-port=80 protocol=tcp src-address-list=Aviso_Bloqueio to-addresses=177.36.33.76 to-ports=80
	/ip firewall nat add action=dst-nat chain=dstnat comment=BLOQUEIO_Aviso_Bloqueio_443 dst-port=443 protocol=tcp src-address-list=Aviso_Bloqueio to-addresses=177.36.33.76 to-ports=443
	/ip firewall nat add action=dst-nat chain=dstnat comment=BLOQUEIO_Bloqueado_80 dst-port=80 protocol=tcp src-address-list=Bloqueado to-addresses=177.36.33.76 to-ports=8081
	/ip firewall nat add action=dst-nat chain=dstnat comment=BLOQUEIO_Bloqueado_443 dst-port=443 protocol=tcp src-address-list=Bloqueado to-addresses=177.36.33.76 to-ports=8081
	/ip firewall nat move [find comment="BLOQUEIO_NO_NAT_TO_SERVER"] 0
	/ip firewall nat move [find comment="BLOQUEIO_Aviso_Bloqueio_80"] 0
	/ip firewall nat move [find comment="BLOQUEIO_Aviso_Bloqueio_443"] 0
	/ip firewall nat move [find comment="BLOQUEIO_Bloqueado_80"] 0
	/ip firewall nat move [find comment="BLOQUEIO_Bloqueado_443"] 0
	EOF
                                                                                         
      #echo ""
    else
      echo "Nao consegui conectar em ${USER}@${HOST}:${PORT} - $PASS - SSH code: $SSH"
    fi # retorno do teste de conexao

  fi # teste de conexao
done
