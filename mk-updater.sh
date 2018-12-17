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
		/ip service set telnet disabled=yes
		/ip service set ftp disabled=yes
		/ip service set www disabled=no port=61200 address=177.36.33.78/32,177.36.34.60/32,187.60.190.138/32,177.36.42.161/32,187.16.224.128/26,177.36.42.161/32,177.87.223.5/32,187.5.218.14/32,177.87.216.34/32,177.36.33.117/32,143.202.216.10/32
		/ip service set api disabled=no address=177.36.46.15/32,177.36.33.78/32,177.36.33.76/32
		/ip service set api-ssl disabled=yes 
		/ip service set winbox port 8291 disabled=no address=177.36.33.78/32,177.36.34.60/32,187.60.190.138/32,177.36.42.161/32,187.16.224.128/26,177.36.42.161/32,177.87.223.5/32,187.5.218.14/32,177.87.216.34/32,177.36.33.105/32,143.202.216.10/32
		/ip service set ssh disabled=no port=222 address=177.36.33.78/32,177.36.34.60/32,187.60.190.138/32,177.36.42.161/32,187.16.224.128/26,177.36.42.161/32,177.87.223.5/32,187.5.218.14/32,177.87.216.34/32,143.202.216.10/32
		EOF
 
        #echo ""
        fi
      fi

    done # do PASSW
  done # do USERS
done # do PORTS
