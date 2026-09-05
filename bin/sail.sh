#!/usr/bin/env bash
#
# Sail — CLI entrypoint para os projetos deste repo.
#
# Uso:
#   sail on                                  inicia o daemon do Docker
#   sail off                                 para o daemon do Docker
#   sail <projeto> [<nome_curto>] <comandos-docker>
#
#   <projeto>     subpasta deste repo (ex.: server, efd-reinf)
#   <nome_curto>  sufixo de docker-compose-<nome_curto>.yml dentro do
#                 projeto; se omitido (ou o arquivo não existir), usa
#                 docker-compose.yml
#
# Exemplos:
#   sail on
#   sail off
#   sail efd-reinf up -d
#   sail server mariadb up -d
#   sail server up -d
#
set -euo pipefail

SELF="$(readlink -f "${BASH_SOURCE[0]}")"
ROOT_DIR="$(cd "$(dirname "$SELF")/.." && pwd)"

GREEN='\033[0;32m'
WHITE='\033[1;37m'
NC='\033[0m'

usage() {
    cat >&2 <<EOF
Uso:
  sail on
  sail off
  sail <projeto> [<nome_curto>] <comandos-docker>

Exemplos:
  sail on
  sail off
  sail efd-reinf up -d
  sail server mariadb up -d
  sail server up -d
EOF
}

ask_sudo() {
    if ! sudo -n true 2>/dev/null; then
        echo
        echo -e "${WHITE}Please provide your password to your application's permissions.${NC}"
    fi
}

docker_on() {
    ask_sudo
    sudo systemctl start docker.socket
    sudo systemctl start docker
    echo
    echo -e "${GREEN}Docker started${NC}"
    echo
}

docker_off() {
    ask_sudo
    sudo systemctl stop docker.socket
    sudo systemctl stop docker
    echo
    echo -e "${GREEN}Docker stopped${NC}"
    echo
}

if [ $# -eq 0 ]; then
    usage
    exit 1
fi

case "$1" in
    on)
        docker_on
        exit 0
        ;;
    off)
        docker_off
        exit 0
        ;;
    -h|--help)
        usage
        exit 0
        ;;
esac

project_name="$1"
shift

project_dir="$ROOT_DIR/$project_name"
if [ ! -d "$project_dir" ]; then
    for alt in "${project_name//_/-}" "${project_name//-/_}"; do
        if [ -d "$ROOT_DIR/$alt" ]; then
            project_dir="$ROOT_DIR/$alt"
            break
        fi
    done
fi

if [ ! -d "$project_dir" ]; then
    echo "sail: projeto '$project_name' não encontrado em $ROOT_DIR" >&2
    exit 1
fi

compose_file="docker-compose.yml"
if [ $# -gt 0 ] && [ -f "$project_dir/docker-compose-$1.yml" ]; then
    compose_file="docker-compose-$1.yml"
    shift
fi

if [ ! -f "$project_dir/$compose_file" ]; then
    echo "sail: arquivo '$compose_file' não encontrado em $project_dir" >&2
    exit 1
fi

if [ $# -eq 0 ]; then
    echo "sail: nenhum comando docker compose informado." >&2
    usage
    exit 1
fi

cd "$project_dir"
exec docker compose -f "$compose_file" "$@"
