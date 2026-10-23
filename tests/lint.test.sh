#!/usr/bin/env bash
# Run scripts/lint.sh against throwaway repos and check its exit codes.
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

failures=0

# expect <name> <want-exit> <dir> [lint args...]
expect() {
  local name="$1" want="$2" dir="$3" got=0
  shift 3
  (cd "$dir" && "$root/scripts/lint.sh" "$@" >/dev/null 2>&1) || got=$?
  if [ "$got" -eq "$want" ]; then
    echo "ok   ${name}"
  else
    echo "FAIL ${name}: want exit ${want}, got ${got}" >&2
    failures=$((failures + 1))
  fi
}

# actionlint finds the workflows by locating the repository root.
new_repo() {
  git init -q "$work/$1"
  mkdir -p "$work/$1/.github/workflows" "$work/$1/scripts"
  cat > "$work/$1/.github/workflows/ci.yml" <<'YAML'
name: ci
on: push
permissions:
  contents: read
jobs:
  noop:
    runs-on: ubuntu-24.04
    steps:
      - run: echo hi
YAML
}

new_repo clean
cat > "$work/clean/scripts/a.sh" <<'SH'
#!/usr/bin/env bash
echo "${1:-x}"
SH
expect "clean repo passes" 0 "$work/clean" scripts

new_repo bad_shell
cat > "$work/bad_shell/scripts/a.sh" <<'SH'
#!/usr/bin/env bash
echo $1
SH
expect "unquoted variable fails shellcheck" 1 "$work/bad_shell" scripts

new_repo bad_workflow
sed -i 's/runs-on: ubuntu-24.04/runs-on: ubuntu-24.04\n    bogus-key: 1/' "$work/bad_workflow/.github/workflows/ci.yml"
expect "invalid workflow fails actionlint" 1 "$work/bad_workflow" scripts

new_repo no_shell
expect "missing shell dir is not an error" 0 "$work/no_shell" scripts

if [ "$failures" -gt 0 ]; then
  echo "${failures} test(s) failed" >&2
  exit 1
fi
