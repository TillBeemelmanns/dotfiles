#!/usr/bin/env bash
set -euo pipefail

trap 'echo "diffnav installation FAILED" >&2' ERR

OS=$(uname -s)
ARCH=$(uname -m)

# diffnav assets: diffnav_<Darwin|Linux>_<arm64|x86_64>.tar.gz (no version in filename)
case "$OS" in
    Linux)  OS_NAME="Linux" ;;
    Darwin) OS_NAME="Darwin" ;;
    *) echo "Unsupported OS: $OS" >&2; exit 1 ;;
esac

case "$ARCH" in
    x86_64)        ARCH_NAME="x86_64" ;;
    arm64|aarch64) ARCH_NAME="arm64" ;;
    *) echo "Unsupported architecture: $ARCH" >&2; exit 1 ;;
esac

URL="https://github.com/dlvhdr/diffnav/releases/latest/download/diffnav_${OS_NAME}_${ARCH_NAME}.tar.gz"

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

echo "Downloading diffnav from $URL ..."
curl -fsSL "$URL" -o "$TMPDIR/diffnav.tar.gz"
tar -xzf "$TMPDIR/diffnav.tar.gz" -C "$TMPDIR"

mkdir -p ~/.local/bin
install -m 755 "$TMPDIR/diffnav" ~/.local/bin/diffnav

echo "diffnav successfully installed to ~/.local/bin/diffnav"
