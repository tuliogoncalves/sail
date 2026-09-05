#!/usr/bin/env bash
#
# Instala:
#   - wrappers de php, composer, artisan, node, npm e npx que executam
#     dentro dos containers docker dos projetos deste repo (efd-reinf, server)
#   - o comando "sail", que liga/desliga o Docker (sail on / sail off) e
#     roda docker compose por projeto (sail <projeto> [<nome_curto>] <cmd>)
#
# Uso:
#   ./install.sh [--force]
#
# --force  sobrescreve qualquer arquivo/symlink já existente em ~/.local/bin
#          com o mesmo nome (por padrão eles são pulados com um aviso).
#
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DISPATCH="$ROOT_DIR/bin/sail-dispatch.sh"
SAIL="$ROOT_DIR/bin/sail.sh"
BIN_DIR="$HOME/.local/bin"
COMMANDS=(php composer artisan art node npm npx)

declare -A LINKS
for name in "${COMMANDS[@]}"; do
    LINKS["$name"]="$DISPATCH"
done
LINKS["sail"]="$SAIL"

FORCE=0
if [ "${1:-}" == "--force" ]; then
    FORCE=1
fi

if [ ! -f "$DISPATCH" ]; then
    echo "install.sh: não encontrei $DISPATCH" >&2
    exit 1
fi
if [ ! -f "$SAIL" ]; then
    echo "install.sh: não encontrei $SAIL" >&2
    exit 1
fi
chmod +x "$DISPATCH" "$SAIL"

mkdir -p "$BIN_DIR"

case ":$PATH:" in
    *":$BIN_DIR:"*) ;;
    *)
        echo "Aviso: $BIN_DIR não está no seu PATH. Adicione algo como:" >&2
        echo "  export PATH=\"$BIN_DIR:\$PATH\"" >&2
        echo "ao seu ~/.bashrc ou ~/.zshrc." >&2
        ;;
esac

installed=()
skipped=()

for name in "${!LINKS[@]}"; do
    link_target="${LINKS[$name]}"
    target="$BIN_DIR/$name"

    if [ -L "$target" ] && [ "$(readlink "$target")" == "$link_target" ]; then
        installed+=("$name (já instalado)")
        continue
    fi

    if [ -e "$target" ] || [ -L "$target" ]; then
        if [ "$FORCE" -ne 1 ]; then
            skipped+=("$name (já existe $target, use --force para sobrescrever)")
            continue
        fi
        rm -f "$target"
    fi

    ln -s "$link_target" "$target"
    installed+=("$name")
done

echo
echo "Instalados em $BIN_DIR:"
for i in "${installed[@]}"; do
    echo "  - $i"
done

if [ "${#skipped[@]}" -gt 0 ]; then
    echo
    echo "Pulados:"
    for s in "${skipped[@]}"; do
        echo "  - $s"
    done
fi

echo
echo "Antes de usar, ligue o Docker e suba os containers de cada projeto:"
echo "  sail on"
echo "  sail server dev up -d"
echo "  sail efd-reinf up -d"
