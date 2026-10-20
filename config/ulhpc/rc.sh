# ULHPC cluster shell setup, linked as ~/.bashrc.local and ~/.zshrc.local
# only on *.uni.lux hosts (see install.conf.yaml). Works in bash and zsh.

# Global definitions (sets up `module` etc.); zsh does not need these
if [ -n "$BASH_VERSION" ] && [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

case ":$PATH:" in
    *":$HOME/.local/bin:"*) ;;
    *) PATH="$HOME/.local/bin:$HOME/bin:$PATH" ;;
esac
export PATH

# si-* interactive session commands
[ -r "$HOME/.config/ulhpc/si.sh" ] && . "$HOME/.config/ulhpc/si.sh"
