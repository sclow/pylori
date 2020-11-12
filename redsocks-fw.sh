#!/bin/sh

##########################
# Setup the Firewall rules
##########################
fw_setup() {
  # First we added a new chain called 'REDSOCKS' to the 'nat' table.
  iptables -t nat -N REDSOCKS

  # Next we used "-j ACCEPT" rules for the networks we don't want to use a proxy.
  while read item; do
      iptables -t nat -A REDSOCKS -d $item -j ACCEPT
  done < /etc/redsocks-allowlist.txt

  # We then told iptables to redirect all port 80 connections to the http-relay redsocks port and all other connections to the http-connect redsocks port.
  #iptables -t nat -A REDSOCKS -p tcp --dport 80 -j REDIRECT --to-ports 12345
  #iptables -t nat -A REDSOCKS -p tcp -j REDIRECT --to-ports 12346

  # Finally we tell iptables to use the 'REDSOCKS' chain for all outgoing connection in the network interface '$DOCKER_NET'.
  if [ -z "$DOCKER_NET" ]
  then
    iptables -t nat -A PREROUTING -p tcp -j REDSOCKS
    iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-ports 12345
    iptables -t nat -A PREROUTING -p tcp -j REDIRECT --to-ports 12346
  else
    iptables -t nat -A PREROUTING -i $DOCKER_NET -p tcp -j REDSOCKS
    iptables -t nat -A PREROUTING -i $DOCKER_NET -p tcp --dport 80 -j REDIRECT --to-ports 12345
    iptables -t nat -A PREROUTING -i $DOCKER_NET -p tcp -j REDIRECT --to-ports 12346
  fi

  # Handle locally generated traffic (tinyproxy)
  iptables -t nat -A OUTPUT -j REDSOCKS
  iptables -t nat -A OUTPUT -p tcp --dport 80 -j DNAT --to-destination 127.0.0.1:12345
  iptables -t nat -A OUTPUT -p tcp -j DNAT --to-destination 127.0.0.1:12346
}

##########################
# Clear the Firewall rules
##########################
fw_clear() {
  iptables-save | grep -v REDSOCKS | iptables-restore
  #iptables -L -t nat --line-numbers
  #iptables -t nat -D PREROUTING 2
}

case "$1" in
    start)
        echo -n "Setting REDSOCKS firewall rules..."
        fw_clear
        fw_setup
        echo "done."
        ;;
    stop)
        echo -n "Cleaning REDSOCKS firewall rules..."
        fw_clear
        echo "done."
        ;;
    *)
        echo "Usage: $0 {start|stop}"
        exit 1
        ;;
esac
exit 0

