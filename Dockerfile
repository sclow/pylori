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

# Copy configuration files...
COPY redsocks.tmpl /etc/redsocks.tmpl
COPY allowlist.txt /etc/redsocks-allowlist.txt
COPY redsocks.sh /usr/local/bin/redsocks.sh
COPY redsocks-fw.sh /usr/local/bin/redsocks-fw.sh
COPY tinyproxy.conf /etc/tinyproxy/tinyproxy.conf

# Rename original redsocks.conf file
RUN if [ -e /etc/redsocks.conf ] ; then mv /etc/redsocks.conf /etc/redsocks.conf.pkg ; fi

RUN chmod +x /usr/local/bin/*

# Cleanup apt to minimise size (if using debian)
#RUN apt -y autoclean && apt -y autoremove

EXPOSE 8888
ENTRYPOINT ["/usr/local/bin/redsocks.sh"]
