# Redsocks docker image.

FROM debian:latest 

LABEL maintainer="Simon Clow <https://github.com/sclow>"

ENV DEBIAN_FRONTEND noninteractive

ENV DOCKER_NET docker0

# Install packages
RUN apt-get update && apt-get -y full-upgrade && apt-get install -y redsocks iptables tinyproxy

# Create log file folder
RUN mkdir -p /var/log/redsocks

# Copy configuration files...
COPY redsocks.tmpl /etc/redsocks.tmpl
COPY allowlist.txt /etc/redsocks-allowlist.txt
COPY redsocks.sh /usr/local/bin/redsocks.sh
COPY redsocks-fw.sh /usr/local/bin/redsocks-fw.sh
COPY tinyproxy.conf /etc/tinyproxy/tinyproxy.conf

# Rename original redsocks.conf file
RUN mv /etc/redsocks.conf /etc/redsocks.conf.pkg

RUN chmod +x /usr/local/bin/*

EXPOSE 8888
ENTRYPOINT ["/usr/local/bin/redsocks.sh"]
