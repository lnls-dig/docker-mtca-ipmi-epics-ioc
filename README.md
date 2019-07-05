Docker image to run the MTCA IPMI EPICS IOC
==================================================================

This repository contains the Dockerfile used to create the Docker image to run the
[AR Amplifier EPICS IOC](https://gitlab.cnpem.br/DIG/mtca-ipmi-epics-ioc).

## Running the IOC

The simples way to run the IOC is to run:

```bash
    docker run --rm -it --net host lnlsdig/mtca-ipmi-epics-ioc -t PROCSERV_TELNET_PORT
        [-P P_VAL] [-R R_VAL] -i IPADDR -c CRATE_ID -r RACK_ID -d DEVICE_TYPE
```

where `IPADDR` is the IP address and port of the device to connect to, `P_VAL` and `R_VAL`
are the prefixes to be added before the PV name.
The options you can specify (after `lnlsdig/mtca-ipmi-epics-ioc`) are:

- `-t TELNET_PORT`: the telnet port used to access the IOC shell
- `-P P_VAL`: the value of the EPICS `$(P)` macro used to prefix the PV names
- `-R R_VAL`: the value of the EPICS `$(R)` macro used to prefix the PV names
- `-i IPADDR`: device IP address to connect to (required)
- `-c CRATE_ID`: Crate ID
- `-r RACK_ID`:  Rack ID
- `-d DEVICE_TYPE`:  MTCA device type [CRATE]

## Creating a Persistent Container

If you want to create a persistent container to run the IOC, you can run a
command similar to:

    docker run -it --net host --restart always --name CONTAINER_NAME lnlsdig/mtca-ipmi-epics-ioc -i IPADDR -P PREFIX1 -R PREFIX2

where `IPADDR`, `PORT`, `PREFIX1`, and `PREFIX2` are as in the previous
section and `CONTAINER_NAME` is the name given to the container. You can also use
the same options as described in the previous section.

## Building the Image Manually

To build the image locally without downloading it from Docker Hub, clone the
repository and run the `docker build` command:

    git clone https://gitlab.cnpem.br/DIG/mtca-ipmi-epics-ioc
    docker build -t lnlsdig/mtca-ipmi-epics-ioc --build-arg SSH_PRIVATE_KEY="$(cat ~/.ssh/id_rsa)" .

Take a breath and stay calm. Your SSH prvate key will not be contained in the final
image. After we clone the repo from private gitlab we start a new build with just
the repo contents. Clap of hands for multi-stage builds...
