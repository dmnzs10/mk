#!/bin/bash

USERS="admin avato noc"
PASSW="senha1 Solib6shahco senha2"
PORTS="22 222"
HOST="172.20.4.234"
SSH=0


# teste de credenciais
for PORT in $PORTS; do
  for USER in $USERS; do
    for PASS in $PASSW; do

      # teste de conexao
      if [ $SSH -eq 0 ]; then
        sshpass -p ${PASS} ssh -p ${PORT} -o StrictHostKeyChecking=no ${USER}@${HOST} "ls" >/dev/null 2>&1

        if [ $? -eq 0 ]; then
          SSH="1"
          echo "Passou com ${USER}@${HOST}:${PORT} - $PASS"
          sshpass -p ${PASS} ssh -p ${PORT} -T -o StrictHostKeyChecking=no ${USER}@${HOST} <<-EOF
		# ip service
		EOF
 
        #echo ""
        fi
      fi

    done # do PASSW
  done # do USERS
done # do PORTS
