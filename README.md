# Dotfiles

### Auto-installed to `~/.local/bin`
`./install` downloads these automatically if missing (Linux + macOS, skips if already installed):
- yazi
- delta
- lazygit
- turm (Linux only)

### Install manually
- bat
- zsh

### Install on host
- ghostty

### Install dotfiles
```bash
git clone https://github.com/TillBeemelmanns/dotfiles
cd dotfiles
git submodule init
git submodule update
./install
```
