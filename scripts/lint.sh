#!/usr/bin/env bash
# Lint shell scripts with shellcheck and workflows with actionlint.
# Usage: scripts/lint.sh [shell-path ...]   (default: scripts tests)
set -euo pipefail

for tool in shellcheck actionlint; do
  command -v "$tool" >/dev/null || { echo "missing tool: ${tool}" >&2; exit 2; }
done

paths=("$@")
[ "${#paths[@]}" -gt 0 ] || paths=(scripts tests)

mapfile -t shell_files < <(find "${paths[@]}" -type f -name '*.sh' 2>/dev/null | sort)
if [ "${#shell_files[@]}" -gt 0 ]; then
  shellcheck "${shell_files[@]}"
fi
echo "shellcheck: ${#shell_files[@]} file(s) clean"

actionlint
echo "actionlint: clean"
