#!/usr/bin/env bash
# Bootstrap: OS check, terminal colors, and path/context variables.
# Expects SAIL_ENTRYPOINT to be set by the main sail.sh before sourcing.

UNAMEOUT="$(uname -s)"

WHITE='\033[1;37m'
NC='\033[0m'

case "${UNAMEOUT}" in
    Linux*)             MACHINE=linux;;
    Darwin*)            MACHINE=mac;;
    *)                  MACHINE="UNKNOWN"
esac

if [ "$MACHINE" == "UNKNOWN" ]; then
    echo "Unsupported operating system [$(uname -r -v)]. Scriptpage Sail supports macOS, Linux, and Windows (WSL2)." >&2
    exit 1
fi

if test -t 1; then
    ncolors=$(tput colors)

    if test -n "$ncolors" && test "$ncolors" -ge 8; then
        BOLD="$(tput bold)"
        YELLOW="$(tput setaf 3)"
        GREEN="$(tput setaf 2)"
        NC="$(tput sgr0)"
    fi
fi

PWD="$(pwd)"
FullPath=$(readlink -f "${SAIL_ENTRYPOINT:-${BASH_SOURCE[0]:-$0}}")
SAIL_BIN=$(dirname "$FullPath")
PWD_BASENAME="$(basename "$PWD")"
PROJECT="$(awk -F':' '{print $1}' <<< "$1")"
DOCKERFILE="Dockerfile_$2"
BUILDERFILE="$2"
NEW_FILE_COMPOSE1="docker-compose-$1.yml"
NEW_FILE_COMPOSE2="docker-compose-$2.yml"
SAIL_USER=www-data

OTHER_FILE_COMPOSE=$NEW_FILE_COMPOSE1

if [ -f "${OTHER_FILE_COMPOSE}" ]; then
    shift 1
fi

export WWWGROUP=${WWWGROUP:-$(id -g)}
