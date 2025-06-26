# Sauce that shiii 
while IFS= read -r file; do
  full_path="/home/mr/.config/zsh/$file"
  if [ -f "$full_path" ]; then
    source "$full_path"
  fi
done < <(ls -A /home/mr/.config/zsh)

# Source environment variables
source "$HOME/.zshenv"

# Set up fzf key bindings and fuzzy completion
source <(fzf --zsh)
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# And most importantly: vi mode
bindkey -v
