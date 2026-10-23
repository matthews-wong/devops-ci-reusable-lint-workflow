#!/usr/bin/env bash
# Install a pinned actionlint into a directory, verifying the archive checksum.
set -euo pipefail

readonly VERSION="1.7.12"
# sha256 of actionlint_${VERSION}_linux_amd64.tar.gz from the release checksums file
readonly SHA256="8aca8db96f1b94770f1b0d72b6dddcb1ebb8123cb3712530b08cc387b349a3d8"
readonly URL="https://github.com/rhysd/actionlint/releases/download/v${VERSION}/actionlint_${VERSION}_linux_amd64.tar.gz"

dest="${1:-${HOME}/.local/bin}"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

curl -fsSL --retry 3 -o "${tmp}/actionlint.tar.gz" "$URL"
echo "${SHA256}  ${tmp}/actionlint.tar.gz" | sha256sum --check --quiet \
  || { echo "checksum mismatch for actionlint ${VERSION}" >&2; exit 1; }

mkdir -p "$dest"
tar -xzf "${tmp}/actionlint.tar.gz" -C "$dest" actionlint
echo "installed actionlint ${VERSION} to ${dest}"
