#!/usr/bin/env bash
# Project lifecycle: create apps and switch into sibling project directories.

cd_to_project() {
    local pathproject="$SAIL_BIN/../../$PROJECT"
    if [ -d "$pathproject" ]; then
        cd "$SAIL_BIN/../../$PROJECT"
    else
        echo
        echo "${YELLOW}Project not exists: ${NC}$PROJECT"
        echo
        echo "  ${NC}verify: $SAIL_BIN/../../$PROJECT"
        echo
        exit 1
    fi

    OTHER_FILE_COMPOSE=$NEW_FILE_COMPOSE2
}

cmd_docker_on() {
    validate_sudo
    sudo systemctl start docker.socket
    sudo systemctl start docker
    echo
    echo -e "${GREEN}Docker started"
    echo
    exit 0
}

cmd_docker_off() {
    validate_sudo
    sudo systemctl stop docker.socket
    sudo systemctl stop docker
    echo
    echo -e "${GREEN}Docker stoped"
    echo
    exit 0
}

cmd_create_back() {
    git clone --single-branch --branch "$2" https://github.com/laravel/laravel.git "$3"

    if [ -d "$3" ]; then
        cd "$3"

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
}

cmd_copy_client() {
    copy_client
    exit 0
}

cmd_create_front() {
    echo
    echo "${YELLOW}Not Implemented yet"
    echo
    echo "${YELLOW}Use:"
    echo "  ${NC}sail create:front {node-version} {project-name}"
    echo
    exit 1
}

cmd_create_starter() {
    git clone --single-branch --branch main https://github.com/tuliogoncalves/starter-with-vuejs.git "$2"

    if [ -d "$2" ]; then
        cd "$2"

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
}

# Commands that do not require Docker to be running.
handle_pre_docker_commands() {
    case "$1" in
        on)
            cmd_docker_on
            ;;
        off)
            cmd_docker_off
            ;;
        create:back)
            cmd_create_back "$@"
            ;;
        copy:client)
            cmd_copy_client
            ;;
        create:front)
            cmd_create_front
            ;;
        create:starter)
            cmd_create_starter "$@"
            ;;
    esac
}
