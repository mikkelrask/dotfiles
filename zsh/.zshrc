bindkey -v

# pnpm
export PNPM_HOME="/home/mr/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end
export PATH=$PATH:/opt/rocm/bin

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

