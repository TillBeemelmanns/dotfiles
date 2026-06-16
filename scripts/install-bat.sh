#!/usr/bin/env bash
set -euo pipefail

if command -v bat >/dev/null 2>&1; then
    echo "bat already installed: $(command -v bat)"
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
    x86_64)          ARCH_TARGET="x86_64" ;;
    aarch64 | arm64) ARCH_TARGET="aarch64" ;;
    *)               echo "Unsupported architecture: $ARCH" >&2; exit 1 ;;
esac

# bat tags and asset filenames both keep the 'v' prefix (e.g. v0.26.1)
TAG=$(curl -fsSI "https://github.com/sharkdp/bat/releases/latest" \
    | grep -i '^location:' | sed 's|.*/tag/||' | tr -d '\r\n')

TARGET="bat-${TAG}-${ARCH_TARGET}-${OS_TARGET}"
URL="https://github.com/sharkdp/bat/releases/download/${TAG}/${TARGET}.tar.gz"

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

echo "Downloading bat ${TAG} from $URL ..."
curl -fsSL "$URL" -o "$TMPDIR/bat.tar.gz"
tar -xzf "$TMPDIR/bat.tar.gz" -C "$TMPDIR"

mkdir -p ~/.local/bin
install -m 755 "$TMPDIR/$TARGET/bat" ~/.local/bin/bat

echo "bat installed to ~/.local/bin/bat"
