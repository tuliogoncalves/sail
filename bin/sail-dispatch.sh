#!/usr/bin/env bash
#
# Dispatcher central para os wrappers php/composer/artisan/art/node/npm/npx.
#
# Instalado (via install.sh) como vários symlinks em ~/.local/bin, um por
# nome de comando. Decide o que fazer olhando o nome pelo qual foi chamado
# ($(basename "$0")) e executa o comando real dentro do container docker
# correto do projeto sail_runners (efd-reinf ou server) em que o usuário
# estiver, localizado subindo diretórios a partir do $PWD até achar um
# arquivo .sail.env.
#
set -euo pipefail

cmd_name="$(basename "$0")"

case "$cmd_name" in
    php)      service="php";    exec_cmd=(php) ;;
    composer) service="php";    exec_cmd=(composer) ;;
    artisan|art) service="php"; exec_cmd=(php artisan) ;;
    node)     service="nodejs"; exec_cmd=(node) ;;
    npm)      service="nodejs"; exec_cmd=(npm) ;;
    npx)      service="nodejs"; exec_cmd=(npx) ;;
    *)
        echo "sail-dispatch: comando desconhecido '$cmd_name'" >&2
        exit 1
        ;;
esac

# Sobe diretórios a partir do PWD até encontrar um .sail.env
project_dir="$PWD"
while [ "$project_dir" != "/" ]; do
    if [ -f "$project_dir/.sail.env" ]; then
        break
    fi
    project_dir="$(dirname "$project_dir")"
done

if [ ! -f "$project_dir/.sail.env" ]; then
    echo "sail-dispatch: nenhum .sail.env encontrado a partir de '$PWD'." >&2
    echo "Rode '$cmd_name' de dentro de um projeto do sail_runners (efd-reinf/ ou server/)." >&2
    exit 1
fi

# shellcheck disable=SC1090
source "$project_dir/.sail.env"

if [ -z "${FILE_COMPOSE:-}" ]; then
    echo "sail-dispatch: FILE_COMPOSE não definido em $project_dir/.sail.env" >&2
    exit 1
fi

# if [ ! -f "$project_dir/$FILE_COMPOSE" ]; then
#     echo "sail-dispatch: arquivo compose '$FILE_COMPOSE' não encontrado em $project_dir" >&2
#     exit 1
# fi

cd "$project_dir"

if ! docker compose -f "$FILE_COMPOSE" config --services 2>/dev/null | grep -qx "$service"; then
    echo "sail-dispatch: o projeto '${PROJECT_NAME:-$project_dir}' não tem o serviço '$service'" \
         "(comando '$cmd_name' não disponível aqui)." >&2
    exit 1
fi

if ! docker compose -f "$FILE_COMPOSE" ps --status running --services 2>/dev/null | grep -qx "$service"; then
    echo "sail-dispatch: o serviço '$service' não está rodando." >&2
    echo "Suba os containers com: (cd $project_dir && docker compose -f $FILE_COMPOSE up -d)" >&2
    exit 1
fi

exec_flags=(exec)
if [ ! -t 0 ]; then
    exec_flags+=(-T)
fi
if [ -n "${SAIL_USER:-}" ]; then
    exec_flags+=(--user "$SAIL_USER")
fi

exec docker compose -f "$FILE_COMPOSE" "${exec_flags[@]}" "$service" "${exec_cmd[@]}" "$@"
