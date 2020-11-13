#!/bin/sh
redsocks_pid=0
tinyproxy_pid=0
REDSOCKS_BIN=`which redsocks`
TINYPROXY_BIN=`which tinyproxy`
pid=0

write_config() {
    echo "Creating redsocks configuration file using proxy ${proxy_ip}:${proxy_port}..."
    sed -e "s|\${proxy_ip}|${proxy_ip}|" \
        -e "s|\${proxy_port}|${proxy_port}|" \
        -e "s|\${proxy_user}|${proxy_user}|" \
        -e "s|\${proxy_password}|${proxy_password}|" \
        /etc/redsocks/redsocks.tmpl > /etc/redsocks/redsocks.conf
}

if test $# -eq 4
then
    # Configuration mode
    proxy_ip=$1
    proxy_port=$2
    proxy_user=$3                                                
    proxy_password=$4
    write_config
else
    # Not in configuration mode!
    # Check if a configuration file exists, if not create default
    if [ ! -e /etc/redsocks/redsocks.conf ] ; then
        echo "No proxy config recived. No config file found, creating one."
        proxy_ip=proxy.ip.address
        proxy_port=3128
        proxy_user=user
        proxy_password=password
        write_config
    fi
fi



echo "Using Redsocks configuration:"
cat /etc/redsocks/redsocks.conf

echo "Activating iptables rules..."
/usr/local/bin/redsocks-fw.sh start

# SIGUSR1 handler
usr_handler() {
  echo "usr_handler"
}

# SIGTERM-handler
term_handler() {
    echo "Term signal caught..."

    if [ ${tinyproxy_pid} -ne 0 ]; then     
        echo "Shuting down tinyproxy..."

        # Request TinyProxy to gracefully terminate
        kill -SIGTERM "${tinyproxy_pid}"

        # Wait until TinyProxy process id has exited
        wait "${tinyproxy_pid}"
    fi

    if [ ${redsocks_pid} -ne 0 ]; then     
        echo "Shuting down redsocks..."

        # Request Redsocks to gracefully terminate
        kill -SIGTERM "${redsocks_pid}"

        # Wait until Redsocks process id has exited
        wait "${redsocks_pid}"
    fi

    # Clean up IPTables firewall
    echo "Disabling iptables rules"
    /usr/local/bin/redsocks-fw.sh stop

    exit 143; # 128 + 15 -- SIGTERM
}

# setup handlers
trap 'kill ${!}; usr_handler' SIGUSR1
trap 'kill ${!}; term_handler' SIGTERM

echo "Starting redsocks..."
${REDSOCKS_BIN} -c /etc/redsocks/redsocks.conf &
redsocks_pid="$!"

echo "Starting tinyproxy..."
${TINYPROXY_BIN} -c /etc/tinyproxy/tinyproxy.conf &
tinyproxy_pid="$!"

# wait indefinetely
while true
do
    tail -f /dev/null & wait ${!}
done
