#!/usr/bin/env bash
set -euo pipefail

if command -v lazygit >/dev/null 2>&1; then
    echo "lazygit already installed: $(command -v lazygit)"
    exit 0
fi

OS=$(uname -s)
ARCH=$(uname -m)

# lazygit tags have a 'v' prefix (e.g. v0.62.2); filenames use lowercase OS and version without 'v'
TAG=$(curl -fsSI "https://github.com/jesseduffield/lazygit/releases/latest" \
    | grep -i '^location:' | sed 's|.*/tag/||' | tr -d '\r\n')
VERSION=${TAG#v}

case "$OS" in
    Linux)  OS_NAME="linux" ;;
    Darwin) OS_NAME="darwin" ;;
    *)      echo "Unsupported OS: $OS" >&2; exit 1 ;;
esac

case "$ARCH" in
    x86_64)          ARCH_NAME="x86_64" ;;
    aarch64 | arm64) ARCH_NAME="arm64" ;;
    *)               echo "Unsupported architecture: $ARCH" >&2; exit 1 ;;
esac

URL="https://github.com/jesseduffield/lazygit/releases/download/${TAG}/lazygit_${VERSION}_${OS_NAME}_${ARCH_NAME}.tar.gz"

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

echo "Downloading lazygit ${VERSION} from $URL ..."
curl -fsSL "$URL" -o "$TMPDIR/lazygit.tar.gz"
tar -xzf "$TMPDIR/lazygit.tar.gz" -C "$TMPDIR" lazygit

mkdir -p ~/.local/bin
install -m 755 "$TMPDIR/lazygit" ~/.local/bin/lazygit

echo "lazygit installed to ~/.local/bin/lazygit"
