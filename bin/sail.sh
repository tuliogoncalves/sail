#!/usr/bin/env bash

UNAMEOUT="$(uname -s)"

WHITE='\033[1;37m'
NC='\033[0m'

# Verify operating system is supported...
case "${UNAMEOUT}" in
    Linux*)             MACHINE=linux;;
    Darwin*)            MACHINE=mac;;
    *)                  MACHINE="UNKNOWN"
esac

if [ "$MACHINE" == "UNKNOWN" ]; then
    echo "Unsupported operating system [$(uname -r -v)]. Scriptpage Sail supports macOS, Linux, and Windows (WSL2)." >&2
    exit 1
fi

# Determine if stdout is a terminal...
if test -t 1; then
    # Determine if colors are supported...
    ncolors=$(tput colors)

    if test -n "$ncolors" && test "$ncolors" -ge 8; then
        BOLD="$(tput bold)"
        YELLOW="$(tput setaf 3)"
        GREEN="$(tput setaf 2)"
        NC="$(tput sgr0)"
    fi
fi

# Define local variables...
PWD="$(pwd)"
FullPath=$(readlink -f "${BASH_SOURCE:-$0}")
SAIL_BIN=$(dirname $FullPath)
PWD_BASENAME="$(basename $PWD)"
PROJECT="$(awk -F':' '{print $1}' <<< $1)"
DOCKERFILE="Dockerfile_$2"
BUILDERFILE="$2"

# Define environment variables...
export WWWGROUP=${WWWGROUP:-$(id -g)}

# Function that prints the available commands...
function display_help {
    echo
    echo "Scriptpage Sail"
    echo
    echo "${YELLOW}Usage:${NC}"
    echo "  ${GREEN}sail COMMAND [options] [arguments]"
    echo "     ${NC}or"
    echo "  ${GREEN}sail <docker-compose commands>"
    echo
    echo "${YELLOW}Docker services Commands:${NC}"
    echo "  ${GREEN}sail on${NC}        Start the docker service's"
    echo "  ${GREEN}sail off${NC}       Finish the docker service's"
    echo
    echo "${YELLOW}Build sail imagens:${NC}"
    echo "  ${GREEN}sail make {file} ${NC}  Create sail builder image"
    echo "  ${GREEN}sail copy:builder {file} ${NC}  Copy sail builder image to project"
    echo
    echo "${YELLOW}Backp/Restore databases:${NC}"
    echo "  ${GREEN}sail sqlserve:list {file} ${NC}  Create sail builder image"
    echo "  ${GREEN}sail sqlserve:restore {file} ${NC}  Create sail builder image"
    echo
    echo "${YELLOW}Sail's remote containers Commands:${NC}"
    echo "  ${GREEN}sail {project}:up${NC}         Start the sail container's"
    echo "  ${GREEN}sail {project}:down${NC}       Finish the sail container's"
    echo "  ${GREEN}sail {project}:start${NC}      Start the sail container's"
    echo "  ${GREEN}sail {project}:stop${NC}       Stop the sail container's"
    echo "  ${GREEN}sail {project}:restart${NC}    Restart the sail container's"
    echo "  Examples:"
    echo "    ${GREEN}sail sail:up"
    echo "    ${GREEN}sail ApreMS:down"
    echo
    echo "${YELLOW}Create projects:${NC}"
    echo "  ${GREEN}sail create:back {laravel-version} {project-name} ${NC}  Create new laravel projects"
    echo "  ${GREEN}sail create:front {nodejs-version} {project-name} ${NC}  Create new nodeJS projects"
    echo "  ${GREEN}sail create:starter {project-name} ${NC}                 Create new starter projects"
    echo "  ${GREEN}sail copy:client ${NC}                                   Copy Sail client into existing project "
    echo
    echo "${YELLOW}docker-compose Commands:${NC}"
    echo "  ${GREEN}sail <docker-compose commands>${NC}     Define and run multi-container applications with Docker"
    echo "  Examples:"
    echo "    ${GREEN}sail up -d${NC}     Start the application in the background"
    echo "    ${GREEN}sail stop${NC}      Stop the application"
    echo "    ${GREEN}sail restart${NC}   Restart the application"
    echo "    ${GREEN}sail ps${NC}        Display the status of all containers"
    echo
    echo "${YELLOW}Bash shell Context:${NC}"
    echo "  ${GREEN}sail shell <container> ${NC}       Initiate a Bash shell within <container>"
    echo "  ${GREEN}sail shell-root <container>${NC}   Initiate a root user Bash shell within <container>"
    echo
    echo "${YELLOW}artisan Commands:${NC}"
    echo "  ${GREEN}sail artisan ...${NC}   Run an Artisan command"
    echo "  ${GREEN}sail art ...${NC}       Run an Artisan command"
    echo
    echo "${YELLOW}composer Commands:${NC}"
    echo "  ${GREEN}sail composer ...${NC}  Run an composer command"
    echo
    echo "${YELLOW}nodeJS Commands:${NC}"
    echo "  ${GREEN}sail node ...${NC}      Run an node command"
    echo
    echo "${YELLOW}npm Commands:${NC}"
    echo "  ${GREEN}sail npm ...${NC}       Run an npm command"
    echo
    echo "${YELLOW}npx Commands:${NC}"
    echo "  ${GREEN}sail npx ...${NC}       Run an npx command"
    echo
    echo "${YELLOW}yarn Commands:${NC}"
    echo "  ${GREEN}sail yarn ...${NC}      Run an yarn command"
    echo
    echo "${YELLOW}Exec Commands into specific container:${NC}"
    echo "  ${GREEN}sail exeec <container> <command> ...${NC}      Run an command into container"
    echo "  Examples:"
    echo "    ${GREEN}sail exec nodejs make -v${NC}     Execute make command into container nodejs"
    echo
    exit 1
}

function builder {
    #Get .env sail

    if [ -f $PWD/sail_client/builders/${DOCKERFILE} ]; then
        cd $PWD/sail_client/builders
    else
        cd $SAIL_BIN/../
        define_environment

        cd $SAIL_BIN/../builders

        if [ ! -f ${DOCKERFILE} ]; then
            echo
            echo "$DOCKERFILE not exists in builder folder of sail"
            echo
            echo "You must define a valid Dockerfile to build as parameter"
            echo
            exit 1
        fi
    fi

    docker buildx build --tag $TAG \
             --cache-from $TAG  \
             --build-arg WWWGROUP="$WWWGROUP" \
             -f $DOCKERFILE \
             . $@

    #Return origin path
    cd $PWD

    exit 0
}

function validate_sudo {
    if sudo -n true 2>/dev/null; then
        nothing=""
    else
        echo
        echo -e "${WHITE}Please provide your password to your application's permissions.${NC}"
    fi
}

function define_environment {
    # Source the ".env" file so Laravel's environment variables are available...
    if [ -f .sail.env ]; then
        source .sail.env
    fi

   # Define environment variables...
    export PROJECT_NAME=${PROJECT_NAME:-$PWD_BASENAME}

    export SAIL_SHARE_DASHBOARD=${SAIL_SHARE_DASHBOARD:-4040}
    export SAIL_SHARE_SERVER_HOST=${SAIL_SHARE_SERVER_HOST:-"laravel-sail.site"}
    export SAIL_SHARE_SERVER_PORT=${SAIL_SHARE_SERVER_PORT:-8080}
    export SAIL_SHARE_SUBDOMAIN=${SAIL_SHARE_SUBDOMAIN:-""}

    TAG="$PROJECT_NAME:$BUILDERFILE"
    ARGS=(-f $FILE_COMPOSE)
}

function copy_builder {
    # copy client_sail folder, if not exists
    echo
    if [ ! -d sail_builders ]; then
        echo -e "${GREEN}Not copied. sail_client not exists!"
    else
        cp -rn $SAIL_BIN/../builders/common ./sail_builders
        cp -rn $SAIL_BIN/../builders/scripts ./sail_builders
        cp -n $SAIL_BIN/../builders/${DOCKERFILE} ./sail_builders/${DOCKERFILE} 
        echo -e "${GREEN} ${DOCKERFILE} builder copied!"
    fi

    echo 

    #Return origin path
    cd $PWD

    exit 0
}

function copy_client {
    # copy client_sail folder, if not exists
    echo
    if [ -d sail_builders ]; then
        echo -e "${GREEN}Not copied. sail_builders exists!"
    else
        mkdir -p ./sail_builders
        cp -rn $SAIL_BIN/../builders/common ./sail_builders/common
        cp -rn $SAIL_BIN/../builders/scripts ./sail_builders/scripts
        cp -n $SAIL_BIN/../builders/sail_make.sh ./
        cp -n $SAIL_BIN/../builders/README ./sail_builders
        echo -e "\n/sail_builders/logs" >> .gitignore
        echo -e "\n/sail_builders" >> .gitignore
        echo -e "\nsail_make.sh" >> .gitignore
        echo -e "${GREEN}sail_builders copied!"
    fi

    # copy .sail.env, if not exists
    echo
    if [ -f .sail.env ]; then
        echo -e "${GREEN}Not copied. .sail.env exists!"
    else
        cp -a $SAIL_BIN/../builders/env/.sail.env ./.sail.env
        echo -e ".sail.env" >> .gitignore
        echo -e "${GREEN}.sail.env copied!"
    fi

    # copy sail-docker-compose.yml, if not exists
    echo
    if [ -f sail-docker-compose-local.yml ]; then
        echo -e "${YELLOW}Not copied. sail-docker-compose-local.yml exists!"
    else
        cp $SAIL_BIN/../builders/sail-docker-compose-local.yml .
        echo -e "sail-docker-compose-local.yml" >> .gitignore
        echo -e "${GREEN}sail-docker-compose-local.yml copied!"
    fi

    echo
}

function cd_to_project {
    pathproject=$SAIL_BIN/../../$PROJECT
    if [ -d "$pathproject" ]; then
        cd $SAIL_BIN/../../$PROJECT
    else
        echo
        echo "${YELLOW}Project not exists: ${NC}$PROJECT"
        echo
        echo "  ${NC}verify: $SAIL_BIN/../../$PROJECT"
        echo
        exit 1
    fi
}

# Proxy the "help" command...
if [ $# -gt 0 ]; then
    if [ "$1" == "help" ] || [ "$1" == "-h" ] || [ "$1" == "-help" ] || [ "$1" == "--help" ]; then
        display_help
    fi
else
    display_help
fi

if [ "$1" == "on" ]; then
    validate_sudo
    sudo systemctl start docker.socket
    sudo systemctl start docker
    echo
    echo -e "${GREEN}Docker started"
    echo
    exit 0

elif [ "$1" == "off" ]; then
    validate_sudo
    sudo systemctl stop docker.socket
    sudo systemctl stop docker
    echo
    echo -e "${GREEN}Docker stoped"
    echo
    exit 0

# create:back
elif [ "$1" == "create:back" ]; then
    git clone --single-branch --branch $2 https://github.com/laravel/laravel.git $3

    if [ -d "$3" ]; then
        cd $3

        copy_client

        rm -rf .git
        rm -rf .github

        echo
        echo -e "${GREEN}New back created!"
        echo

        exit 0
    fi

    echo
    echo "${YELLOW}Use:${NC}"
    echo "  ${NC}sail create:back {laravel-version} {project-name}"
    echo
    exit 1

# copy:client
elif [ "$1" == "copy:client" ]; then
    copy_client
    exit 0

# create:front
elif [ "$1" == "create:front" ]; then
    echo
    echo "${YELLOW}Not Implemented yet"
    echo
    echo "${YELLOW}Use:"
    echo "  ${NC}sail create:front {node-version} {project-name}"
    echo
    exit 1

# create:starter
elif [ "$1" == "create:starter" ]; then
    git clone --single-branch --branch main https://github.com/tuliogoncalves/starter-with-vuejs.git $2

    if [ -d "$2" ]; then
        cd $2

        copy_client

        rm -rf .git
        rm -rf .github

        echo
        echo -e "${GREEN}New starter created!"
        echo

        exit 0
    fi

    echo
    echo "${YELLOW}Use:${NC}"
    echo "  ${NC}sail create:starter {project-name}"
    echo
    exit 1
fi

# Check docker service
if [ -z "$SAIL_SKIP_CHECKS" ]; then
    # Ensure that Docker is running...
    if ! docker info > /dev/null 2>&1; then
        echo "${BOLD}Docker is not running.${NC}" >&2
        exit 1
    fi
fi

# Define Docker Compose command prefix...
docker compose &> /dev/null
if [ $? == 0 ]; then
    DOCKER_COMPOSE=(docker compose)
else
    DOCKER_COMPOSE=(docker-compose)
fi

define_environment

# Proxy Composer commands to the "composer" binary on the application container...
if [ "$1" == "composer" ]; then
    shift 1
    ARGS+=(exec -u sail)
    [ ! -t 0 ] && ARGS+=(-T)
    ARGS+=(php composer $@)

# Up command to the project container's...
elif [ "$1" == "php" ]; then
    shift 1
    ARGS+=(exec -u sail)
    [ ! -t 0 ] && ARGS+=(-T)
    ARGS+=(php php $@)

# Up command to the project container's...
elif [ "$1" == "caddy" ]; then
    cd $SAIL_BIN/..
    shift 1
    ARGS=(-f sail-docker-compose-proxy.yml)
    ARGS+=(exec -w /etc/caddy)
    [ ! -t 0 ] && ARGS+=(-T)
    ARGS+=(proxy caddy $@)

# Proxy Up container...
elif [ "$1" == "db:up" ]; then
    cd $SAIL_BIN/..
    shift 1
    ARGS=(-f sail-docker-compose-local.yml up -d)

# Proxy Down container...
elif [ "$1" == "db:down" ]; then
    cd $SAIL_BIN/..
    shift 1
    ARGS=(-f sail-docker-compose-local.yml down)

# Proxy Up container...
elif [ "$1" == "proxy:up" ]; then
    cd $SAIL_BIN/..
    shift 1
    ARGS=(-f sail-docker-compose-proxy.yml up -d)

# Proxy Down container...
elif [ "$1" == "proxy:down" ]; then
    cd $SAIL_BIN/..
    shift 1
    ARGS=(-f sail-docker-compose-proxy.yml down)

# Up command to the project container's...
elif [[ "$1" == *":up"* ]]; then
    cd_to_project
    shift 1
    define_environment
    ARGS+=(up -d)

# Down command to the project container's...
elif [[ "$1" == *":down"* ]]; then
    cd_to_project
    shift 1
    define_environment
    ARGS+=(down)

# Start command to the project container's...
elif [[ "$1" == *":start"* ]]; then
    cd_to_project
    shift 1
    define_environment
    ARGS+=(start)

# Stop command to the project container's...
elif [[ "$1" == *":stop"* ]]; then
    cd_to_project
    shift 1
    define_environment

    ARGS+=(stop)

# Restart command to the project container's...
elif [[ "$1" == *":restart"* ]]; then
    cd_to_project
    shift 1
    define_environment
    ARGS+=(restart)

# Proxy Artisan commands to the "artisan" binary on the application container...
elif [ "$1" == "artisan" ] || [ "$1" == "art" ]; then
    shift 1
    ARGS+=(exec -u sail)
    [ ! -t 0 ] && ARGS+=(-T)
    ARGS+=(php php artisan $@)

# Proxy the "phpunit" command to "php vendor/bin/phpunit"...
elif [ "$1" == "phpunit" ]; then
    shift 1
    ARGS+=(exec -u sail)
    [ ! -t 0 ] && ARGS+=(-T)
    ARGS+=(php php vendor/bin/phpunit $@)

# Proxy Node commands to the "node" binary on the application container...
elif [ "$1" == "node" ]; then
    shift 1
    ARGS+=(exec -u sail)
    [ ! -t 0 ] && ARGS+=(-T)
    ARGS+=(nodejs node $@)

# Proxy NPM commands to the "npm" binary on the application container...
elif [ "$1" == "npm" ]; then
    shift 1
    ARGS+=(exec -u sail)
    [ ! -t 0 ] && ARGS+=(-T)
    ARGS+=(nodejs npm $@)

# Proxy NPX commands to the "npx" binary on the application container...
elif [ "$1" == "npx" ]; then
    shift 1
    ARGS+=(exec -u sail)
    [ ! -t 0 ] && ARGS+=(-T)
    ARGS+=(nodejs npx "$@")

# Proxy PNPM commands to the "pnpm" binary on the application container...
elif [ "$1" == "pnpm" ]; then
    shift 1
    ARGS+=(exec -u sail)
    [ ! -t 0 ] && ARGS+=(-T)
    ARGS+=(nodejs pnpm "$@")

# Proxy YARN commands to the "yarn" binary on the application container...
elif [ "$1" == "yarn" ]; then
    shift 1
    ARGS+=(exec -u sail)
    [ ! -t 0 ] && ARGS+=(-T)
    ARGS+=(nodejs yarn "$@")

# Proxy bun commands to the "bun" binary on the application container...
elif [ "$1" == "bun" ]; then
    shift 1
    ARGS+=(exec -u sail)
    [ ! -t 0 ] && ARGS+=(-T)
    ARGS+=(nodejs bun "$@")

# Proxy to execute command into specific container
elif [ "$1" == "exec" ]; then
    shift 1
    ARGS+=(exec -u sail)
    [ ! -t 0 ] && ARGS+=(-T)
    ARGS+=("$1" "$2")
    shift 2
    ARGS+=("$@")

# Initiate a Bash shell within the application container...
elif [ "$1" == "shell" ]; then
    shift 1
    ARGS+=(exec -u sail)
    [ ! -t 0 ] && ARGS+=(-T)
    if [ "$1" != "" ]; then
        ARGS+=("$1")
        shift 1
        ARGS+=("bash $@")
    else
        echo
        echo "Use:"
        echo "  ${GREEN}sail shell <container-name> ${NC}"
        echo
        exit 1
    fi

# Initiate a root user Bash shell within the application container...
elif [ "$1" == "shell-root" ]; then
    shift 1
    ARGS+=(exec -u root)
    [ ! -t 0 ] && ARGS+=(-T)
    if [ "$1" != "" ]; then
        ARGS+=("$1")
        shift 1
        ARGS+=("bash $@")
    else
        echo
        echo "Use:"
        echo "  ${GREEN}sail shell-root <container-name>${NC}"
        echo
        exit 1
    fi

# Initiate a Redis CLI terminal session within the "redis" container...
elif [ "$1" == "redis" ] ; then
    shift 1
    cd $SAIL_BIN/..
    ARGS+=(exec)
    [ ! -t 0 ] && ARGS+=(-T)
    ARGS+=(redis redis-cli)

# Share the site...
elif [ "$1" == "share" ]; then
    shift 1
    docker run --init --rm -p $SAIL_SHARE_DASHBOARD:4040 -t beyondcodegmbh/expose-server:latest share http://host.docker.internal:"$APP_PORT" \
        --server-host="$SAIL_SHARE_SERVER_HOST" \
        --server-port="$SAIL_SHARE_SERVER_PORT" \
        --auth="$SAIL_SHARE_TOKEN" \
        --subdomain="$SAIL_SHARE_SUBDOMAIN" \
        "$@"
    exit 0

elif [ "$1" == "sqlserver:list" ]; then
    # shift 1

    # Copy File
    docker exec -it -u root sqlserver mkdir /var/opt/mssql/backup
    docker cp $SAIL_BIN/../backup/$2 sqlserver:/var/opt/mssql/backup/$2

    # Let's find out the logical file names and paths inside the backup
    docker exec -it -u root sqlserver /opt/mssql-tools/bin/sqlcmd \
    -S localhost \
    -U SA \
    -P "Psswd#123" \
    -Q "RESTORE FILELISTONLY FROM DISK = '/var/opt/mssql/backup/$2'" \
        | tr -s ' ' | cut -d ' ' -f 1-2
    
    exit 0

elif [ "$1" == "sqlserver:restore" ]; then
    query="RESTORE DATABASE $3 FROM DISK = '/var/opt/mssql/backup/$2' WITH MOVE '$3' TO '/var/opt/mssql/data/$3.mdf'"
    [ "$4" != "" ] && query+=", MOVE '$4' TO '/var/opt/mssql/data/$4.ldf'"
    [ "$5" != "" ] && query+=", MOVE '$5' TO '/var/opt/mssql/data/$5.ndf'"

    # let's restore the backup
    docker exec -it -u root sqlserver /opt/mssql-tools/bin/sqlcmd \
    -S localhost \
    -U SA \
    -P "Psswd#123" \
    -Q "$query"

    # -Q "RESTORE DATABASE siafic FROM DISK = '/var/opt/mssql/backup/$2' WITH MOVE 'siafic' TO '/var/opt/mssql/data/siafic.mdf', MOVE 'siafic_Log' TO '/var/opt/mssql/data/siafic_log.ldf'"

    exit 0

# Build App
elif [ "$1" == "make" ]; then
    shift 2
    builder $@

# Copy Builder to project
elif [ "$1" == "copy:builder" ]; then
    copy_builder $@

# Pass unknown commands to the "docker-compose" binary...
else
    ARGS+=("$@")
fi

# echo
# echo "${DOCKER_COMPOSE[@]}" "${ARGS[@]}"
# echo

# Run Docker Compose with the defined arguments...
${DOCKER_COMPOSE[@]} ${ARGS[@]}

cd $PWD
