#!/usr/bin/env bash
# Proxies: forward common tooling into application containers.

cmd_composer() {
    shift 1
    sail_compose_exec php composer "$@"
}

cmd_php() {
    shift 1
    sail_compose_exec php php "$@"
}

cmd_caddy() {
    cd "$SAIL_BIN/.."
    shift 1
    ARGS=(-f sail-docker-compose-proxy.yml)
    ARGS+=(exec -w /etc/caddy)
    [ ! -t 0 ] && ARGS+=(-T)
    ARGS+=(proxy caddy "$@")
}

cmd_artisan() {
    shift 1
    sail_compose_exec php php artisan "$@"
}

cmd_phpunit() {
    shift 1
    sail_compose_exec php php vendor/bin/phpunit "$@"
}

cmd_node() {
    shift 1
    sail_compose_exec nodejs node "$@"
}

cmd_npm() {
    shift 1
    sail_compose_exec nodejs npm "$@"
}

cmd_npx() {
    shift 1
    sail_compose_exec nodejs npx "$@"
}

cmd_pnpm() {
    shift 1
    sail_compose_exec nodejs pnpm "$@"
}

cmd_yarn() {
    shift 1
    sail_compose_exec nodejs yarn "$@"
}

cmd_bun() {
    shift 1
    sail_compose_exec nodejs bun "$@"
}

cmd_exec() {
    shift 1
    ARGS+=(exec -u "$SAIL_USER")
    [ ! -t 0 ] && ARGS+=(-T)
    ARGS+=("$1" "$2")
    shift 2
    ARGS+=("$@")
}

cmd_shell() {
    shift 1
    ARGS+=(exec -u "$SAIL_USER")
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
}

cmd_shell_root() {
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
}

cmd_redis() {
    shift 1
    cd "$SAIL_BIN/.."
    ARGS+=(exec)
    [ ! -t 0 ] && ARGS+=(-T)
    ARGS+=(redis redis-cli)
}

cmd_share() {
    shift 1
    docker run --init --rm -p "$SAIL_SHARE_DASHBOARD":4040 -t beyondcodegmbh/expose-server:latest share http://host.docker.internal:"$APP_PORT" \
        --server-host="$SAIL_SHARE_SERVER_HOST" \
        --server-port="$SAIL_SHARE_SERVER_PORT" \
        --auth="$SAIL_SHARE_TOKEN" \
        --subdomain="$SAIL_SHARE_SUBDOMAIN" \
        "$@"
    exit 0
}
