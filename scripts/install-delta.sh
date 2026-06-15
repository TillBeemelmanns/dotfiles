#!/usr/bin/env bash
set -euo pipefail

if command -v delta >/dev/null 2>&1; then
    echo "delta already installed: $(command -v delta)"
    exit 0
fi

OS=$(uname -s)
ARCH=$(uname -m)

# delta tags have no 'v' prefix (e.g. 0.19.2)
TAG=$(curl -fsSI "https://github.com/dandavison/delta/releases/latest" \
    | grep -i '^location:' | sed 's|.*/tag/||' | tr -d '\r\n')

case "$OS" in
    Linux)
        case "$ARCH" in
            x86_64)  TARGET="delta-${TAG}-x86_64-unknown-linux-musl" ;;
            aarch64) TARGET="delta-${TAG}-aarch64-unknown-linux-gnu" ;;
            *)        echo "Unsupported architecture: $ARCH" >&2; exit 1 ;;
        esac
        ;;
    Darwin)
        case "$ARCH" in
            arm64|aarch64) TARGET="delta-${TAG}-aarch64-apple-darwin" ;;
            x86_64)
                echo "delta does not publish macOS x86_64 binaries; install via: brew install git-delta" >&2
                exit 1
                ;;
            *) echo "Unsupported architecture: $ARCH" >&2; exit 1 ;;
        esac
        ;;
    *) echo "Unsupported OS: $OS" >&2; exit 1 ;;
esac

URL="https://github.com/dandavison/delta/releases/download/${TAG}/${TARGET}.tar.gz"

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

echo "Downloading delta ${TAG} from $URL ..."
curl -fsSL "$URL" -o "$TMPDIR/delta.tar.gz"
tar -xzf "$TMPDIR/delta.tar.gz" -C "$TMPDIR"

mkdir -p ~/.local/bin
install -m 755 "$TMPDIR/$TARGET/delta" ~/.local/bin/delta

echo "delta installed to ~/.local/bin/delta"
