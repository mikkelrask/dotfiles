__prompt_to_bottom_line() {                                                                                                                                                  
tput cup $LINES                                                                                                                                                            
}                                                                                                                                                                            
#if [ -d "$HOME/.config/zsh" ]; then 
#  for file in "$(ls $HOME/.config/zsh/)"; do
#    [ -f "$file" ] && source "$file"
#  done
#fi
#  /$$$$$$$$                              /$$     /$$                              
# | $$_____/                             | $$    |__/                              
# | $$    /$$   /$$ /$$$$$$$   /$$$$$$$ /$$$$$$   /$$  /$$$$$$  /$$$$$$$   /$$$$$$$
# | $$$$$| $$  | $$| $$__  $$ /$$_____/|_  $$_/  | $$ /$$__  $$| $$__  $$ /$$_____/
# | $$__/| $$  | $$| $$  \ $$| $$        | $$    | $$| $$  \ $$| $$  \ $$|  $$$$$$ 
# | $$   | $$  | $$| $$  | $$| $$        | $$ /$$| $$| $$  | $$| $$  | $$ \____  $$
# | $$   |  $$$$$$/| $$  | $$|  $$$$$$$  |  $$$$/| $$|  $$$$$$/| $$  | $$ /$$$$$$$/
# |__/    \______/ |__/  |__/ \_______/   \___/  |__/ \______/ |__/  |__/|_______/ 

# start our prompt at the bottom of the screen
__prompt_to_bottom_line() {                                                                                                                                                  
┊ tput cup $LINES                                                                                                                                                            
}                                                                                                                                                                            

__TMEX_LAUNCH () {                                                                                                                                                           
┊ cd ~/repos/dotfile-docs                                                                                                                                                    
┊ tmex 'WRITEUP' -f=1 -t -l=13{211} v  'bun i' cava cmatrix -w 'bun run serve'                                                                                               
}         

slugify_files() {
  for file in *; do
    # Extract filename and extension
    filename="${file%.*}"
    extension="${file##*.}"
    # Slugify filename
    slugified_filename=$(echo "$filename" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-zA-Z0-9]/-/g')
    # Reconstruct the filename with extension
    new_name="${slugified_filename}.${extension}"
    # Check if the new name is different
    if [ "$file" != "$new_name" ]; then
      mv -i "$file" "$new_name"
      echo "Renamed '$file' to '$new_name'"
    fi
  done
}
make-clean-install() {
  make clean
  make
  doas make install
}

# Files to source
if [ -d "$HOME/.local/bin" ]; then
  PATH="$HOME/.local/bin:$PATH"
fi

if [ -d "$HOME/.bun" ]; then
  # bun completions
  if [ -s "$HOME/.bun/_bun" ]; then  
    source "$HOME/.bun/_bun"
  fi
  export BUN_INSTALL="$HOME/.bun"
  export PATH="$BUN_INSTALL/bin:$PATH"
fi

if [ -d "$HOME/.cargo/bin" ]; then
  PATH="$HOME/.cargo/bin:$PATH"
fi

start_screencast() {
  ffmpeg -t x11grab -video_size 2540x1440 -framerate 25 -i :0.1 -f pulse -ac 2 -i 0 -c:v libx264 -preset ultrafast -c:a aac output.mp4
}
#    /$$$$$$  /$$ /$$                    
#   /$$__  $$| $$|__/                    
#  | $$  \ $$| $$ /$$  /$$$$$$   /$$$$$$$
#  | $$$$$$$$| $$| $$ |____  $$ /$$_____/
#  | $$__  $$| $$| $$  /$$$$$$$|  $$$$$$ 
#    $$  | $$| $$| $$ /$$__  $$ \____  $$
#  | $$  | $$| $$| $$|  $$$$$$$ /$$$$$$$/
#  |__/  |__/|__/|__/ \_______/|_______/ 


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

alias chat="ollama run mistral"

alias v="nvim"
alias mci="make-clean-install"

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

## Start screencast

#   /$$$$$$$  /$$                     /$$                    
#  | $$__  $$| $$                    |__/                    
#  | $$  \ $$| $$ /$$   /$$  /$$$$$$  /$$ /$$$$$$$   /$$$$$$$
#  | $$$$$$$/| $$| $$  | $$ /$$__  $$| $$| $$__  $$ /$$_____/
#  | $$____/ | $$| $$  | $$| $$  \ $$| $$| $$  \ $$|  $$$$$$ 
#  | $$      | $$| $$  | $$| $$  | $$| $$| $$  | $$ \____  $$
#  | $$      | $$|  $$$$$$/|  $$$$$$$| $$| $$  | $$ /$$$$$$$/
#  |__/      |__/ \______/  \____  $$|__/|__/  |__/|_______/ 
#                           /$$  \ $$                        
#                          |  $$$$$$/                        
#                           \______/

[ -f "${XDG_DATA_HOME:-$HOME/.local/share}/zap/zap.zsh" ] && source "${XDG_DATA_HOME:-$HOME/.local/share}/zap/zap.zsh"
plug "zsh-users/zsh-autosuggestions"
plug "zap-zsh/supercharge"
plug "zsh-users/zsh-syntax-highlighting"
plug 'zsh-users/zsh-history-substring-search'
plug 'MichaelAquilina/zsh-you-should-use'
plug 'zsh-omz-autocomplete'

# Singularisart prompt
typeset -A __Prompt
__Prompt[ITALIC_ON]=$'\e[3m'
__Prompt[ITALIC_OFF]=$'\e[23m'
plug "zap-zsh/singularisart-prompt"

# Load and initialise completion system
autoload -Uz compinit
compinit

# And most importantly: vi mode
bindkey -v

eval 
            fuck () {
                TF_PYTHONIOENCODING=$PYTHONIOENCODING;
                export TF_SHELL=zsh;
                export TF_ALIAS=fuck;
                TF_SHELL_ALIASES=$(alias);
                export TF_SHELL_ALIASES;
                TF_HISTORY="$(fc -ln -10)";
                export TF_HISTORY;
                export PYTHONIOENCODING=utf-8;
                TF_CMD=$(
                    thefuck THEFUCK_ARGUMENT_PLACEHOLDER $@
                ) && eval $TF_CMD;
                unset TF_HISTORY;
                export PYTHONIOENCODING=$TF_PYTHONIOENCODING;
                test -n "$TF_CMD" && print -s $TF_CMD
            }


export NVM_DIR="$HOME/.config/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
#compdef readable
###-begin-readable-completions-###
#
# yargs command completion script
#
# Installation: readable --completion >> ~/.zshrc
#    or readable --completion >> ~/.zprofile on OSX.
#
_readable_yargs_completions()
{
  local reply
  local si=$IFS
  IFS=$'
' reply=($(COMP_CWORD="$((CURRENT-1))" COMP_LINE="$BUFFER" COMP_POINT="$CURSOR" readable --get-yargs-completions "${words[@]}"))
  IFS=$si
  _describe 'values' reply
}
compdef _readable_yargs_completions readable
###-end-readable-completions-###
