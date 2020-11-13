# Pylori - A Digest Proxy Authentication tool

## Description

This docker image allows you to use docker on a host without being bored by your corporate proxy.

You have just to run this container and all your other containers will be able to access directly to internet (without any proxy configuration).

## Usage

Start the container like this:

``` bash
docker run --privileged=true --detach --name pylori psyclow/pylori:1.0 1.2.3.4 3128 user password
```

Once pylori has been configured you can subsequently launch it using the command:

``` bash
docker run  --privileged=true --detach --name pylori psyclow/pylori:1.0
```

Replace the IP and the port by those of your proxy.

The container will start redsocks and automatically configure iptable to forward **all** the TCP traffic of the `$DOCKER_NET` interface (`docker0` by default) through the proxy.

You can forward all the TCP traffic regardless the interface by unset the `DOCKER_NET` variable: `-e DOCKER_NET`.

If you want to add exception for an IP or a range of IP you can edit the allowlist file.
Once edited you can replace this file into the container by mounting it:

``` bash
docker run --privileged=true --net=host \
  -v allowlist.txt:/etc/redsocks-allowlist.txt \
  -d sclow/pylori 1.2.3.4 3128
```

Use docker stop to halt the container. The iptables rules should be reversed. If not, you can execute this command:

``` bash
iptables-save | grep -v REDSOCKS | iptables-restore
```

## Build

### Create Image

To create the Pylori Image from within the checked out repository run:

``` bash
docker build --tag pylori:1.0 .
```

### Old

Build the image with `make`.

> Use `make help` to see available commands for this image.

## Original Work

This has been based on the Redsocks Docker image by NCalier, please credit the original!

[![Image size](https://img.shields.io/imagelayers/image-size/ncarlier/redsocks/latest.svg)](https://hub.docker.com/r/ncarlier/redsocks/)
[![Docker pulls](https://img.shields.io/docker/pulls/ncarlier/redsocks.svg)](https://hub.docker.com/r/ncarlier/redsocks/)
