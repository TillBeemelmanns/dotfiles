#!/usr/bin/env bash
set -euo pipefail

trap 'echo "turm installation FAILED" >&2' ERR

OS=$(uname -s)
ARCH=$(uname -m)

if [ "$OS" != "Linux" ]; then
    echo "turm only provides Linux releases, skipping on $OS"
    exit 0
fi

case "$ARCH" in
    x86_64)  ARCH_TARGET="x86_64" ;;
    aarch64) ARCH_TARGET="aarch64" ;;
    *)       echo "Unsupported architecture: $ARCH" >&2; exit 1 ;;
esac

# turm asset filenames do not include the version number
TARGET="turm-${ARCH_TARGET}-unknown-linux-musl"
TAG=$(curl -fsSI "https://github.com/karimknaebel/turm/releases/latest" \
    | grep -i '^location:' | sed 's|.*/tag/||' | tr -d '\r\n')
URL="https://github.com/karimknaebel/turm/releases/download/${TAG}/${TARGET}.tar.gz"

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

echo "Downloading turm ${TAG} from $URL ..."
curl -fsSL "$URL" -o "$TMPDIR/turm.tar.gz"
tar -xzf "$TMPDIR/turm.tar.gz" -C "$TMPDIR"

mkdir -p ~/.local/bin
# Binary may be at the root or inside a subdirectory
BINARY=$(find "$TMPDIR" -name turm -type f | head -1)
install -m 755 "$BINARY" ~/.local/bin/turm

echo "turm successfully installed to ~/.local/bin/turm"
