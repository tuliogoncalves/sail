#!/usr/bin/env bash
#
# Scriptpage Sail — CLI entrypoint
#
# Thin orchestrator that loads lib modules and dispatches commands.
# Install continues to symlink this file to /usr/local/bin/sail.
#

SAIL_ENTRYPOINT="${BASH_SOURCE[0]}"
SAIL_LIB="$(cd "$(dirname "$(readlink -f "$SAIL_ENTRYPOINT")")" && pwd)/lib"

# shellcheck source=lib/bootstrap.sh
source "$SAIL_LIB/bootstrap.sh"
# shellcheck source=lib/environment.sh
source "$SAIL_LIB/environment.sh"
# shellcheck source=lib/help.sh
source "$SAIL_LIB/help.sh"
# shellcheck source=lib/client.sh
source "$SAIL_LIB/client.sh"
# shellcheck source=lib/builders.sh
source "$SAIL_LIB/builders.sh"
# shellcheck source=lib/projects.sh
source "$SAIL_LIB/projects.sh"
# shellcheck source=lib/sqlserver.sh
source "$SAIL_LIB/sqlserver.sh"
# shellcheck source=lib/proxies.sh
source "$SAIL_LIB/proxies.sh"
# shellcheck source=lib/containers.sh
source "$SAIL_LIB/containers.sh"
# shellcheck source=lib/dispatch.sh
source "$SAIL_LIB/dispatch.sh"

handle_help "$@"
handle_pre_docker_commands "$@"

ensure_docker_running
detect_docker_compose
define_environment

dispatch_command "$@"
run_docker_compose
