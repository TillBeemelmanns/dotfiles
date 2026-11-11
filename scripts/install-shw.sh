#!/usr/bin/env bash
set -euo pipefail

trap 'echo "shw installation FAILED" >&2' ERR

REPO="TillBeemelmanns/shw"
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

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

# shw tags and asset filenames both keep the 'v' prefix (e.g. v0.2.0), like bat
TAG=$(curl -fsSI "https://github.com/${REPO}/releases/latest" \
    | grep -i '^location:' | sed 's|.*/tag/||' | tr -d '\r\n')

TARGET="shw-${TAG}-${ARCH_TARGET}-${OS_TARGET}"
URL="https://github.com/${REPO}/releases/download/${TAG}/${TARGET}.tar.gz"

echo "Downloading shw ${TAG} from $URL ..."
curl -fsSL "$URL" -o "$TMPDIR/shw.tar.gz"
tar -xzf "$TMPDIR/shw.tar.gz" -C "$TMPDIR"

mkdir -p ~/.local/bin
install -m 755 "$TMPDIR/$TARGET/shw" ~/.local/bin/shw

# zsh completion (picked up via fpath in home/zshrc)
mkdir -p ~/.local/share/zsh/site-functions
install -m 644 "$TMPDIR/$TARGET/completions/_shw" ~/.local/share/zsh/site-functions/_shw

echo "shw successfully installed to ~/.local/bin/shw"
