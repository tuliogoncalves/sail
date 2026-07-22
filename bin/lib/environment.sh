#!/usr/bin/env bash
# Environment helpers: load .sail.env and prepare compose/build context.

validate_sudo() {
    if sudo -n true 2>/dev/null; then
        nothing=""
    else
        echo
        echo -e "${WHITE}Please provide your password to your application's permissions.${NC}"
    fi
}

define_environment() {
    if [ -f .sail.env ]; then
        source .sail.env
    fi

    export PROJECT_NAME=${PROJECT_NAME:-$PWD_BASENAME}

    export SAIL_SHARE_DASHBOARD=${SAIL_SHARE_DASHBOARD:-4040}
    export SAIL_SHARE_SERVER_HOST=${SAIL_SHARE_SERVER_HOST:-"laravel-sail.site"}
    export SAIL_SHARE_SERVER_PORT=${SAIL_SHARE_SERVER_PORT:-8080}
    export SAIL_SHARE_SUBDOMAIN=${SAIL_SHARE_SUBDOMAIN:-""}

    TAG="$PROJECT_NAME:$BUILDERFILE"

    if [ -f "${OTHER_FILE_COMPOSE}" ]; then
        ARGS=(-f "${OTHER_FILE_COMPOSE}")
    else
        ARGS=(-f "$FILE_COMPOSE")
    fi
}

ensure_docker_running() {
    if [ -z "$SAIL_SKIP_CHECKS" ]; then
        if ! docker info > /dev/null 2>&1; then
            echo "${BOLD}Docker is not running.${NC}" >&2
            exit 1
        fi
    fi
}

detect_docker_compose() {
    docker compose &> /dev/null
    if [ $? == 0 ]; then
        DOCKER_COMPOSE=(docker compose)
    else
        DOCKER_COMPOSE=(docker-compose)
    fi
}

# Run a command as SAIL_USER inside a compose service (TTY-aware).
sail_compose_exec() {
    local service="$1"
    shift

    ARGS+=(exec -u "$SAIL_USER")
    [ ! -t 0 ] && ARGS+=(-T)
    ARGS+=("$service" "$@")
}
