#!/usr/bin/env bash
# Command dispatcher: route sail CLI arguments to the matching handler.

dispatch_command() {
    if [ "$1" == "composer" ]; then
        cmd_composer "$@"

    elif [ "$1" == "php" ]; then
        cmd_php "$@"

    elif [ "$1" == "caddy" ]; then
        cmd_caddy "$@"

    elif [[ "$1" == *":up"* ]]; then
        cmd_project_up "$@"

    elif [[ "$1" == *":down"* ]]; then
        cmd_project_down "$@"

    elif [[ "$1" == *":start"* ]]; then
        cmd_project_start "$@"

    elif [[ "$1" == *":stop"* ]]; then
        cmd_project_stop "$@"

    elif [[ "$1" == *":restart"* ]]; then
        cmd_project_restart "$@"

    elif [ "$1" == "artisan" ] || [ "$1" == "art" ]; then
        cmd_artisan "$@"

    elif [ "$1" == "phpunit" ]; then
        cmd_phpunit "$@"

    elif [ "$1" == "node" ]; then
        cmd_node "$@"

    elif [ "$1" == "npm" ]; then
        cmd_npm "$@"

    elif [ "$1" == "npx" ]; then
        cmd_npx "$@"

    elif [ "$1" == "pnpm" ]; then
        cmd_pnpm "$@"

    elif [ "$1" == "yarn" ]; then
        cmd_yarn "$@"

    elif [ "$1" == "bun" ]; then
        cmd_bun "$@"

    elif [ "$1" == "exec" ]; then
        cmd_exec "$@"

    elif [ "$1" == "shell" ]; then
        cmd_shell "$@"

    elif [ "$1" == "shell-root" ]; then
        cmd_shell_root "$@"

    elif [ "$1" == "redis" ]; then
        cmd_redis "$@"

    elif [ "$1" == "share" ]; then
        cmd_share "$@"

    elif [ "$1" == "sqlserver:list" ]; then
        cmd_sqlserver_list "$@"

    elif [ "$1" == "sqlserver:restore" ]; then
        cmd_sqlserver_restore "$@"

    elif [ "$1" == "make" ]; then
        cmd_make "$@"

    elif [ "$1" == "copy:builder" ]; then
        cmd_copy_builder "$@"

    elif [ "$1" == "list:builders" ]; then
        cmd_list_builders

    elif [ "$1" == "ls" ]; then
        cmd_ls "$@"

    else
        ARGS+=("$@")
    fi
}

run_docker_compose() {
    "${DOCKER_COMPOSE[@]}" "${ARGS[@]}"
    cd "$PWD"
}
