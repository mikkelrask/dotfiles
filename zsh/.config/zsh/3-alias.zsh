
# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

alias music="ncmpcpp -c $HOME/.config/ncmpcpp/config -b $HOME/.config/ncmpcpp/bindings"
alias :q="exit"
alias c='clear && __prompt_to_bottom_line'
alias cat='bat'
alias clear='clear && __prompt_to_bottom_line'
alias config="$EDITOR $HOME/.config/i3/config"
alias dl="wget -cq --show-progress"
alias e="exit"
alias pip3="pip"
alias pip="pipx"
alias so="source"

alias v="nvim"

# Git specifics
alias gc='git commit -m'
alias add='git add'
alias push='git push'
alias pull='git pull'
alias status='git status'
alias gs='git status'
# Package manager
alias install='doas dnf install'
alias i="install"
alias search="dnf search"
alias s="search"
alias uninstall='doas dnf remove'
alias update='doas dnf update'
alias upgrade='update && doas apt upgrade -y'
alias clean='doas dnf autoremove'
# tmux sessoin for my documentation setup
alias docunator="__TMEX_LAUNCH"
alias rabeco="tmex 'rabeco' -t 'ssh rabeco.dk@linux351.unoeuro.com'"

alias lah="exa -lah --icons --color=auto"
alias ls="exa --icons --color=auto"
alias tree="exa --tree --icons"
