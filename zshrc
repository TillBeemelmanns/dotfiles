has() {
    type "$1" &>/dev/null
}

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
plugins=(git)
source $ZSH/oh-my-zsh.sh


if [ -z "$LANG" ]; then
    export LANG=en_US.UTF-8
fi

if [ -d "$HOME"/.local/bin ] ; then
    export PATH="$HOME"/.local/bin:$PATH
fi

if has nvim; then
    export EDITOR='nvim'
elif has vim; then
    export EDITOR='vim'
elif has vi; then
    export EDITOR='vi'
fi

# Allow local customizations in the ~/.zshrc_local file
if [ -r "$HOME"/.zshrc.local ]; then
    source "$HOME"/.zshrc.local
fi
