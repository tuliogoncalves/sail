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
    echo "Unsupported operating system [$(uname -s)]. Scriptpage Sail supports macOS, Linux, and Windows (WSL2)." >&2
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
FullPath=$(readlink -f "${BASH_SOURCE:-$0}")
SCRIPTPATH=$(dirname $FullPath)

DOCKERFILE="Dockerfile_$2"
TAG="sail:$2"

ARGS=(-f sail-docker-compose-local.yml)
PWD="$(pwd)"
PROJECT="$(awk -F':' '{print $1}' <<< $1)"


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
    echo "  ${GREEN}sail shell${NC}        Initiate a Bash shell within the application container"
    echo "  ${GREEN}sail root-shell${NC}   Initiate a root user Bash shell within the application container"
    echo "  ${GREEN}sail bash${NC}         Initiate a Bash shell within the application container"
    echo "  ${GREEN}sail root-bash${NC}    Initiate a root user Bash shell within the application container"
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

    exit 1
}

function builder {
    #Get .env sail
    cd $SCRIPTPATH/../
    define_environment

    cd $SCRIPTPATH/../builders

    if [[ ! -f ${DOCKERFILE} ]]; then
        echo
        echo "$DOCKERFILE not exists in builder folder of sail"
        echo
        echo "You must define a valid Dockerfile to build as parameter"
        echo
        exit 1
    fi

    docker $BUILDER --tag $TAG \
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
    if [ -f .env ]; then
        source .env
    fi

   # Define environment variables...
    export WWWGROUP=${WWWGROUP:-$(id -g)}
    export APP_PROJECT_NAME=${APP_PROJECT_NAME:-"scriptage"}

    export APP_ENV=${APP_ENV:-"local"}

    export SAIL_FILES=${SAIL_FILES:-""}
    export SAIL_SHARE_DASHBOARD=${SAIL_SHARE_DASHBOARD:-4040}
    export SAIL_SHARE_SERVER_HOST=${SAIL_SHARE_SERVER_HOST:-"laravel-sail.site"}
    export SAIL_SHARE_SERVER_PORT=${SAIL_SHARE_SERVER_PORT:-8080}
    export SAIL_SHARE_SUBDOMAIN=${SAIL_SHARE_SUBDOMAIN:-""}

    if [ "$APP_ENV" == "production" ] || [ "$APP_ENV" == "prod" ]; then
        if [ -f ./sail-docker-compose-prod.yml ]; then
            ARGS=(-f sail-docker-compose-prod.yml)
        fi
    fi
}

function copy_client {
    # copy client_sail folder, if not exists
    echo
    if [ -d sail_client ]; then
        echo -e "${GREEN}Not copied. sail_client exists!"
    else
        cp -r $SCRIPTPATH/../client/sail_client .
        echo -e "\n/sail_client/logs" >> .gitignore
        echo -e "\n/sail_client" >> .gitignore
        echo -e "${GREEN}sail_client copied!"
    fi

    # copy sail-docker-compose.yml, if not exists
    echo
    if [ -f sail-docker-compose-local.yml ]; then
        echo -e "${YELLOW}Not copied. sail-docker-compose-local.yml exists!"
    else
        cp $SCRIPTPATH/../client/sail-docker-compose-local.yml .
        echo -e "sail-docker-compose-local.yml" >> .gitignore
        echo -e "${GREEN}sail-docker-compose-local.yml copied!"
    fi

    # copy sail-docker-compose-prod.yml, if not exists
    echo
    if [ -f sail-docker-compose-prod.yml ]; then
        echo -e "${GREEN}Not copied. sail-docker-compose-prod.yml exists!"
    else
        cp $SCRIPTPATH/../client/sail-docker-compose-prod.yml .
        echo -e "sail-docker-compose-prod.yml" >> .gitignore
        echo -e "${GREEN}sail-docker-compose-prod.yml copied!"
    fi

    echo
}

function cd_to_project {
    pathproject=$SCRIPTPATH/../../$PROJECT
    if [ -d "$pathproject" ]; then
        cd $SCRIPTPATH/../../$PROJECT
    else
        echo
        echo "${YELLOW}Project not exists: ${NC}$PROJECT"
        echo
        echo "  ${NC}verify: $SCRIPTPATH/../../$PROJECT"
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
elif [[ "$1" == *"php"* ]]; then
    shift 1
    ARGS+=(exec -u sail)
    [ ! -t 0 ] && ARGS+=(-T)
    ARGS+=(php php $@)

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

# Proxy Up container...
elif [ "$1" == "proxy-up" ]; then
    shift 1
    ARGS=(-f sail-docker-compose-proxy.yml up -d)

# Proxy Down container...
elif [ "$1" == "proxy-down" ]; then
    shift 1
    ARGS=(-f sail-docker-compose-proxy.yml down)

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

# Proxy YARN commands to the "yarn" binary on the application container...
elif [ "$1" == "yarn" ]; then
    shift 1
    ARGS+=(exec -u sail)
    [ ! -t 0 ] && ARGS+=(-T)
    ARGS+=(nodejs yarn "$@")

# Initiate a Bash shell within the application container...
elif [ "$1" == "shell" ] || [ "$1" == "bash" ]; then
    shift 1
    ARGS+=(exec -u sail)
    [ ! -t 0 ] && ARGS+=(-T)
    ARGS+=("php bash $@")

# Initiate a root user Bash shell within the application container...
elif [ "$1" == "shell-root" ] || [ "$1" == "bash-root" ]; then
    shift 1
    ARGS+=(exec -u root)
    [ ! -t 0 ] && ARGS+=(-T)
    ARGS+=("php bash $@")

# Initiate a Redis CLI terminal session within the "redis" container...
elif [ "$1" == "redis" ] ; then
    shift 1
    cd $SCRIPTPATH/..
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

# Build App
elif [ "$1" == "make" ]; then
    shift 2
    builder $@

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
