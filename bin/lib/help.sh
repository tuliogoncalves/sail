#!/usr/bin/env bash
# Help / usage output for Scriptpage Sail.

display_help() {
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
    echo "  ${GREEN}sail make {file} ${NC}         Create sail builder image"
    echo "  ${GREEN}sail list:builders ${NC}       List sail builders Dockerfiles"
    echo "  ${GREEN}sail copy:builder {file} ${NC} Copy sail builder image to project"
    echo
    echo "${YELLOW}Backp/Restore databases:${NC}"
    echo "  ${GREEN}sail sqlserver:list {file} ${NC}  Upload and List database files "
    echo "  ${GREEN}sail sqlserver:restore {file} {database.mdf} {database_log.ldf} {database.ndf} ${NC}  Restore database"
    echo
    echo "${YELLOW}Sail's remote containers Commands:${NC}"
    echo "  ${GREEN}sail {project}:up${NC}         Start the sail container's"
    echo "  ${GREEN}sail {project}:down${NC}       Finish the sail container's"
    echo "  ${GREEN}sail {project}:start${NC}      Start the sail container's"
    echo "  ${GREEN}sail {project}:stop${NC}       Stop the sail container's"
    echo "  ${GREEN}sail {project}:restart${NC}    Restart the sail container's"
    echo "  ${GREEN}sail ls${NC}                   List conteiners running"
    echo
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

handle_help() {
    if [ $# -gt 0 ]; then
        if [ "$1" == "help" ] || [ "$1" == "-h" ] || [ "$1" == "-help" ] || [ "$1" == "--help" ]; then
            display_help
        fi
    else
        display_help
    fi
}
