# Install Docker on windows with WSL

- Run prompt or powershell as administrator mode.

- This command will enable the features needed to run WSL and install the Ubuntu Linux distribution.
    
     wsl --install
    
- Command to install a specific distro. (“kali-linux”, would be the chosen distro. You can change it to, for example, “Ubuntu-20.04” and it will install that distro.)
    
     wsl --install -d kali-linux
    
- Check WSL version (WSL2 required).
    
     wsl -l -v
    
- If the distro is not in version 2, it is necessary to move the distro to version 2. In my example, it would be:
    
     wsl --set-version kali-linux 2
     ```
    
- Soon after, put the distro as default, to avoid any problems with docker.
    
     wsl --set-default kali-linux
    
- Inside the distro's terminal (open from the start menu), and update the Ubuntu APT repository.
    
     sudo apt update
    
- Then install docker in your Linux environment with the command:
    
     sudo apt install docker.io -y
    
- After installing docker, create a user group with the name 'docker', if it does not exist.
    
     sudo groupadd docker
    
- Then add your user to the docker group:
OBS: It may be that it has already been added to the group here, check it through the 'groups' in the Linux terminal. If the 'docker' group appears, that's ok, otherwise go to the next code and check the groups again.
    
     sudo usermod -aG docker $USER
    
     newgrp docker
    
- Check the docker version.
    
     docker --version
    
- Then open the terminal in windows and type:
    
     wsl --shutdown
    
- Then start the Linux environment through the start menu.
At this point, docker can work, test it through the line in the Linux terminal:
    
     docker run hello-world
    
- Install VScode. [https://code.visualstudio.com/download](https://code.visualstudio.com/download) (Install outside the WSL environment.)
- Open VScode and install the “Remote Development” extension.
    
     [https://prnt.sc/Cxfi6AaJgYr1](https://prnt.sc/Cxfi6AaJgYr1)
    
- and you will have an option at the bottom left of the window, open by the desired distro.
    
     [https://prnt.sc/EUdZ_5HRo752](https://prnt.sc/EUdZ_5HRo752)
    
- In this step you can clone, for example, the scriptpage repository. (You will need to install git. → sudo apt install git)

sudo apt install git


- Next, we will need to configure the PHP executable path in VScode in a Docker container:

     sudo cp ./docker/assets/php.sh /usr/local/bin/php

- Make it executable:

sudo chmod +x /usr/local/bin/php

- Next step is to install Sail:
    
     You will need to look at the **~/.bashrc** file and uncomment or add the following lines.
    
     **OBS**: The **first code** opens the file and the second is the lines that must be added or uncommented.
    

     nano ~/.bashrc

          if [ -f ~/.bash_aliases ]; then
               . ~/.bash_aliases
               fi

- Once that's done, create a file ~/.bash_aliases and add your aliases:

     nano ~/.bash_aliases

     alias sail='[ -f sail ] && bash sail || bash docker/sail'

- Now, we will need docker-compose, to install it:

     sudo apt install docker-compose

- Here, it may be that your Docker is not yet starting to run your project.

If that happens:

     System has not been booted with systemd as init system (PID 1).
     Can't operate. Failed to connect to bus: Host is down

     - We will solve it with:

     sudo -e /etc/wsl.conf

     - Add the line to the file:

     [boot]
     systemd=true

     - Restart WSL from the prompt with:

     wsl --shutdown

