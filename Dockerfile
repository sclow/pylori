# Redsocks docker image.

FROM debian:latest 

MAINTAINER Simon Clow <https://github.com/sclow>

ENV DEBIAN_FRONTEND noninteractive

ENV DOCKER_NET docker0

# Install packages
RUN apt-get update && apt-get install -y redsocks iptables tinyproxy

# Copy configuration files...
COPY redsocks.tmpl /etc/redsocks.tmpl
COPY allowlist.txt /etc/redsocks-allowlist.txt
COPY redsocks.sh /usr/local/bin/redsocks.sh
COPY redsocks-fw.sh /usr/local/bin/redsocks-fw.sh

RUN chmod +x /usr/local/bin/*

ENTRYPOINT ["/usr/local/bin/redsocks.sh"]
