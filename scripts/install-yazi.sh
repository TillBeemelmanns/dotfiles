#!/usr/bin/env bash
set -euo pipefail

if command -v yazi >/dev/null 2>&1; then
    echo "yazi already installed: $(command -v yazi)"
    exit 0
fi

OS=$(uname -s)
ARCH=$(uname -m)

case "$OS" in
    Linux)  OS_TARGET="unknown-linux-musl" ;;
    Darwin) OS_TARGET="apple-darwin" ;;
    *)      echo "Unsupported OS: $OS" >&2; exit 1 ;;
esac

case "$ARCH" in
    x86_64)  ARCH_TARGET="x86_64" ;;
    aarch64) ARCH_TARGET="aarch64" ;;
    arm64)   ARCH_TARGET="aarch64" ;;
    *)       echo "Unsupported architecture: $ARCH" >&2; exit 1 ;;
esac

TARGET="yazi-${ARCH_TARGET}-${OS_TARGET}"
URL="https://github.com/sxyazi/yazi/releases/latest/download/${TARGET}.zip"

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

echo "Downloading yazi from $URL ..."
curl -fsSL "$URL" -o "$TMPDIR/yazi.zip"
unzip -q "$TMPDIR/yazi.zip" -d "$TMPDIR"

mkdir -p ~/.local/bin
install -m 755 "$TMPDIR/$TARGET/yazi" ~/.local/bin/yazi
install -m 755 "$TMPDIR/$TARGET/ya" ~/.local/bin/ya

echo "yazi installed to ~/.local/bin/"
