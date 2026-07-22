#!/usr/bin/env bash
# Remote project container lifecycle (project:up/down/start/stop/restart, ls).

cmd_project_up() {
    cd_to_project
    shift 2
    define_environment
    ARGS+=(up -d)
}

cmd_project_down() {
    cd_to_project
    shift 2
    define_environment
    ARGS+=(down)
}

cmd_project_start() {
    cd_to_project
    shift 2
    define_environment
    ARGS+=(start)
}

cmd_project_stop() {
    cd_to_project
    shift 2
    define_environment
    ARGS+=(stop)
}

cmd_project_restart() {
    cd_to_project
    shift 2
    define_environment
    ARGS+=(restart)
}

cmd_ls() {
    shift 1
    cd "$SAIL_BIN/../builders"
    ARGS=(ls)
}
