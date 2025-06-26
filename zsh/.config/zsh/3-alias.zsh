#    /$$$$$$  /$$ /$$                    
#   /$$__  $$| $$|__/                    
#  | $$  \ $$| $$ /$$  /$$$$$$   /$$$$$$$
#  | $$$$$$$$| $$| $$ |____  $$ /$$_____/
#  | $$__  $$| $$| $$  /$$$$$$$|  $$$$$$ 
#    $$  | $$| $$| $$ /$$__  $$ \____  $$
#  | $$  | $$| $$| $$|  $$$$$$$ /$$$$$$$/
#  |__/  |__/|__/|__/ \_______/|_______/ 



alias mpv='mpv --no-audio-display'
alias librewolf='MOZ_ENABLE_WAYLAND=1 MOZ_USE_XINPUT2=1 librewolf'
#alias music="ncmpcpp -c ~/.config/ncmpcpp/turntable -b ~/.config/ncmpcpp/bindings -h 192.168.1.190"
alias :q="exit"
alias clear='clear && __prompt_to_bottom_line'
alias c='clear'
alias cat='bat'
#alias config="$EDITOR $HOME/.config/i3/config"
alias e="exit"
alias so="source"
alias c='clear && __prompt_to_bottom_line'
alias cat='bat'
alias clear='clear && __prompt_to_bottom_line'
alias config="$(which updater)"
alias e="exit"
alias pip3="pip"
alias so="source"
alias mkdir="mkdir -pv"
alias cd="cdls"
#alias allowunfree="export NIXPKGS_ALLOW_UNFREE=1"
alias wifi="/home/mr/.local/bin/wifzf"
alias v="nvim"
alias chat="ollama run qwen3"
alias mci="make-clean-install"

# Git specifics
alias gc='git commit'
alias add='git add'
alias ga='git add'
alias gap='git add --patch'
alias gd="git diff --output-indicator-new=' ' --output-indicator-old=' '"
alias gdp="git diff --patch"
alias gb='git branch'
alias gl="git log --all --graph --pretty=format:'%C(magenta)%h(white) %an %ar%C(auto) %D%n%s%n'"
alias gi='git init'
alias clone="git clone"
alias push='git push'
alias pull='git pull'
alias status='git status --short'
alias gs='git status'

# Package manager
alias i="install"
alias install="i"
alias search="dnf search"
alias s="search"
alias uninstall='doas dnf remove'
alias update='doas nix-channel --update'
alias upgrade='update && doas apt upgrade -y'
alias clean='doas dnf autoremove'

# tmux sessoin for my documentation setup
alias docunator="__TMEX_LAUNCH"
alias rabeco="tmex 'rabeco' -t 'ssh rabeco.dk@linux351.unoeuro.com'"
alias lah="eza -lah --icons --color=auto"
alias ls="eza --icons --color=auto"
alias tree="eza --tree --icons"
alias finder="pcmanfm ."
alias MCA="/home/mr/.local/bin/java/zulu/bin/java -jar /home/mr/.local/bin/mcaselector-2.4.jar"

# NixOS stuff
#alias rebuild="nixos-rebuild switch --quiet --flake '/home/mr/.nixos#dolores'"

alias get-class="xprop | grep CLASS | awk '{print $4}'"
alias MCA='~/.local/bin/java/zulu/bin/java -jar ~/.local/bin/mcaselector-2.4.jar'
alias dsbul="docker compose down --volume && docker compose build --no-cache && docker compose up -d && docker compose logs -f"
alias dsbul="docker compose down --volumes && docker compose build --no-cache && docker compose up -d && docker compose logs -f"
