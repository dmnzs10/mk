#!/bin/bash

USERS="admin avato noc"
PASSW="senha1 Solib6shahco senha2"
PORTS="22 222"
DBTI_HOST="177.36.33.76"
DBTI_USER="root"
DBTI_PASS="4vis0@GPSnet"
DBTI_BASE="avisos_mikrotik"
PORT="222"
DBDM_HOST="localhost"
DBDM_USER="bash_script"
DBDM_PASS="ezT910B105722"
DBDM_BASE="hosts_discovery"

# Conecta no banco da TI para obter a lista dos concentradores
DBTI_CE=$(echo "SELECT server_ip FROM authentication_concentrators ORDER BY id ASC LIMIT 2" | mysql -N -h $DBTI_HOST -D $DBTI_BASE -u $DBTI_USER -p${DBTI_PASS})
#DBTI_CE=$(echo "SELECT server_ip FROM authentication_concentrators ORDER BY id ASC" | mysql -N -h $DBTI_HOST -D $DBTI_BASE -u $DBTI_USER -p${DBTI_PASS})

# Inicio
for HOST in $DBTI_CE; do
  SSH=0
  CRED=""
  USER=$(echo "SELECT server_user FROM authentication_concentrators WHERE server_ip='${HOST}'" | mysql -N -h $DBTI_HOST -D $DBTI_BASE -u $DBTI_USER -p${DBTI_PASS})
  PASS=$(echo "SELECT server_password FROM authentication_concentrators WHERE server_ip='${HOST}'" | mysql -N -h $DBTI_HOST -D $DBTI_BASE -u $DBTI_USER -p${DBTI_PASS})
  
  # grava host no banco DM
  echo "INSERT INTO host (ipv4,ipv4_var,username,passwd,port) VALUES (INET_ATON('${HOST}'),'${HOST}','${USER}','${PASS}','${PORT}')" | mysql -N -h $DBDM_HOST -D $DBDM_BASE -u $DBDM_USER -p${DBDM_PASS} >/dev/null 2>&1

  # teste de conexao
  if [ $SSH -eq 0 ]; then
    sshpass -p ${PASS} ssh -p ${PORT} -o StrictHostKeyChecking=no ${USER}@${HOST} "/" >/dev/null 2>&1
    #echo "$?"

    # retorno do teste de conexao
    if [ $? -eq 0 ]; then
      SSH="1"
      CRED="OK"
      echo "Passou com ${USER}@${HOST}:${PORT} - $PASS"

      # grava rodada no banco DM
      #echo "INSERT INTO cmd_executions (commands_idcommands,host_ipv4,host_ipv4_var,date) VALUES ('1',INET_ATON('${HOST}'),'${HOST}',NOW()) " | mysql -N -h $DBDM_HOST -D $DBDM_BASE -u $DBDM_USER -p${DBDM_PASS} >/dev/null 2>&1

      sshpass -p ${PASS} ssh -p ${PORT} -T -o StrictHostKeyChecking=no ${USER}@${HOST} <<-EOF
	EOF
                                                                                         
      #echo ""
    else
      echo " >>> Nao consegui conectar em ${USER}@${HOST}:${PORT} - $PASS - SSH code: $SSH"
      CRED="FAIL"
    fi # retorno do teste de conexao
    
    # UPDATE das credenciais
    echo "UPDATE host SET cred_status='${CRED}',cred_date=NOW() WHERE ipv4=(INET_ATON('${HOST}'))" | mysql -N -h $DBDM_HOST -D $DBDM_BASE -u $DBDM_USER -p${DBDM_PASS} >/dev/null 2>&1

  fi # teste de conexao
done
