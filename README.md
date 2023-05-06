# Sail

This project was based on Laravel\Sail and extended to serve distributed solutions (microservices).

## System requirements

1) Install Docker engine and Docker compose

        https://docs.docker.com/engine/install/

        When need access private repositories
                $ docker login


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
