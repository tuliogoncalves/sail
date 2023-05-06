# Sail

This project was based on Laravel\Sail and extended to serve distributed solutions (microservices).

## System requirements

1) Install Docker engine and Docker compose

### On Windows, prepare WSL

        1) Run prompt or powershell as administrator mode.

        2) This command will enable the features needed to run WSL and install the Ubuntu Linux distribution.
        
        `wsl --install`

        Or, Command to install a specific distro. (“kali-linux”, would be the chosen distro. You can change it to, for example, “Ubuntu-20.04” and it will install that distro.)
        
        `wsl --install -d kali-linux`
        
        3) Check WSL version (WSL2 required).
        
        `wsl -l -v`
        
        - If the distro is not in version 2, it is necessary to move the distro to version 2. In my example, it would be:
        
        `wsl --set-version kali-linux 2`
        
        - Soon after, put the distro as default, to avoid any problems with docker.
        
        `wsl --set-default kali-linux`

### Installing Docker and compose

On windows, inside the distro's terminal (open from the start menu), 
        
update the Ubuntu APT repository.

`sudo apt update`

Then install docker in your Linux environment with the command:

`sudo apt install docker.io -y`



### When need access private repositories
        `docker login`

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


## Install Sail

1) In ~/.bashrc file, uncomment or add the following lines:

        if [ -f ~/.bash_aliases ]; then
                . ~/.bash_aliases
        fi

2) create the ~/.bash_aliases file and add the yours alias.

        alias sail='[ -f sail ] && bash sail || bash ~/projects/sail/bin/sail'


## VSCode PHP executable Path in docker

1) Create a file 'php.sh' to /usr/local/bin
        $ sudo cp ./assets/php.sh /usr/local/bin/php
 
2) Make it executable:
        $ sudo chmod +x /usr/local/bin/php

