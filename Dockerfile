# Redsocks docker image.

#FROM debian:latest 
FROM alpine:latest

LABEL maintainer="Simon Clow <https://github.com/sclow>"

ENV DEBIAN_FRONTEND noninteractive

ENV DOCKER_NET docker0

# Install packages
#RUN apt-get update && apt-get -y full-upgrade && apt-get install -y redsocks iptables tinyproxy
RUN apk --update-cache upgrade && apk add redsocks iptables tinyproxy

# Create log file folder
RUN mkdir -p /var/log/redsocks

# Create config directories
RUN mkdir -p /etc/redsocks 
RUN mkdir -p /etc/tinyproxy

# Check that group for redsocks / tinyproxy exists (generally only relates to alpine)
RUN if grep "^redsocks:" /etc/group >/dev/null 2>&1; then echo "Group redsocks Already Exists" ; else echo "Adding redsocks group" ;  addgroup -S redsocks; fi
RUN if grep "^tinyproxy:" /etc/group >/dev/null 2>&1; then echo "Group tinyproxy Already Exists" ; else echo "Adding tinyproxy group" ;  addgroup -S tinyproxy; fi

# Check that the user for redsocks / tinyproxy exists (generally only relates to alpine)
RUN if id redsocks >/dev/null 2>&1 ; then echo "Redsocks user exists"; else echo "Redsocks user missing, adding it." ; adduser -S -D -G redsocks -h /var/run/redsocks redsocks ;fi
RUN if id tinyproxy >/dev/null 2>&1 ; then echo "Tinyproxy user exists"; else echo "Tinyproxy user missing, adding it." ; adduser -S -D -G tinyproxy -h /var/run/tinyproxy tinyproxy ;fi

# Copy configuration files...
COPY redsocks.tmpl /etc/redsocks/redsocks.tmpl
COPY allowlist.txt /etc/redsocks/redsocks-allowlist.txt
COPY redsocks.sh /usr/local/bin/redsocks.sh
COPY redsocks-fw.sh /usr/local/bin/redsocks-fw.sh
COPY tinyproxy.conf /etc/tinyproxy/tinyproxy.conf

# Rename original redsocks.conf file
RUN if [ -e /etc/redsocks/redsocks.conf ] ; then mv /etc/redsocks/redsocks.conf /etc/redsocks/redsocks.conf.pkg ; fi

RUN chmod +x /usr/local/bin/*

# Cleanup apt to minimise size (if using debianoc)
#RUN apt -y autoclean && apt -y autoremove
#RUN apk cache clean

EXPOSE 8888
ENTRYPOINT ["/usr/local/bin/redsocks.sh"]
#ENTRYPOINT ["/bin/sh", "-c", "while true; do sleep 1 ; echo booom ; done"]
