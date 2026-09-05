#!/usr/bin/env bash
#
# Remove os wrappers instalados por install.sh (php, composer, artisan, art,
# node, npm, npx, sail) de ~/.local/bin. Só remove symlinks que apontam para
# os scripts deste repo; qualquer outra coisa é deixada intocada.
#
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DISPATCH="$ROOT_DIR/bin/sail-dispatch.sh"
SAIL="$ROOT_DIR/bin/sail.sh"
BIN_DIR="$HOME/.local/bin"

declare -A LINKS
for name in php composer artisan art node npm npx; do
    LINKS["$name"]="$DISPATCH"
done
LINKS["sail"]="$SAIL"

removed=()
skipped=()

for name in "${!LINKS[@]}"; do
    link_target="${LINKS[$name]}"
    target="$BIN_DIR/$name"

    if [ -L "$target" ] && [ "$(readlink "$target")" == "$link_target" ]; then
        rm -f "$target"
        removed+=("$name")
    elif [ -e "$target" ] || [ -L "$target" ]; then
        skipped+=("$name (não foi instalado por este repo, deixado intocado)")
    fi
done

echo "Removidos de $BIN_DIR:"
if [ "${#removed[@]}" -eq 0 ]; then
    echo "  (nenhum)"
else
    for r in "${removed[@]}"; do
        echo "  - $r"
    done
fi

if [ "${#skipped[@]}" -gt 0 ]; then
    echo
    echo "Pulados:"
    for s in "${skipped[@]}"; do
        echo "  - $s"
    done
fi
