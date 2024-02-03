# Scriptpage Sail

## v2.4.6

> **Note:** This repository contains a component of the Scriptpage framework. If you want to build an application using Laravel and Scriptpage with VueJS, you need to know [Scriptpage Starter ](https://github.com/tuliogoncalves/starter-with-vuejs).

This project was based on Laravel\Sail and extended to run multi-container applications with Docker.

##### System requirements

1) Install Docker engine and Docker compose

### On Windows, prepare WSL

1) Run prompt or powershell as administrator mode.
2) This command will enable the features needed to run WSL and install the Ubuntu Linux distribution.

        wsl --install

Or, Command to install a specific distro. (“kali-linux”, would be the chosen distro. You can change it to, for example, “Ubuntu-20.04” and it will install that distro.)

        wsl --install -d kali-linux

3) Check WSL version (WSL2 required).

        wsl -l -v

- If the distro is not in version 2, it is necessary to move the distro to version 2. In my example, it would be:

        wsl --set-version kali-linux 2

- Soon after, put the distro as default, to avoid any problems with docker.

        wsl --set-default kali-linux

### Installing Docker and compose

On windows, inside the distro's terminal (open from the start menu),

[Install Docker Engine] https://docs.docker.com/engine/install/

### When need access private repositories

    docker login

### If you want to run docker as non-root user then you need to add it to the docker group.

a) Create the docker group if it does not exist
        $ sudo groupadd docker

b) Add your user to the docker group.
        $ sudo usermod -aG docker $USER

c) Log in to the new docker group (to avoid having to log out / log in again; but if not enough, try to reboot):
        $ newgrp docker

d) Check if docker can be run without root
        $ docker run hello-world

e) Reboot if still got error
        $ reboot

### Disable docker service on boot

        $ sudo systemctl disable docker
        $ sudo systemctl disable docker.service
        $ sudo systemctl disable docker.socket

    ## checking
        $ systemctl list-unit-files | grep -i docker

### Removing all resources

        $ docker system prune
        $ docker system prune --all --force --volumes

### Increase your Docker IP space

Fixing "could not find an available, non-overlapping IPv4 address pool among the defaults to assign to the network"

To explicitly add address space for your containers, an entry needs to be added into /etc/docker/daemon.json

        $ sudo cp ./assets/daemon.json /etc/docker/

This configuration will allow Docker to allocate 172.20.(0-255).0/24 and 172.21.(0-255).0/24, which allows a total of 256 addresses to each network, and a total of 512 networks.

## Install/Uninstall Sail

1) prepere install files:

   $ sudo chmod +x install uninstall

2) Instaling:

   $ sudo ./install

3) Uninstaling:

   $ sudo ./uninstall
