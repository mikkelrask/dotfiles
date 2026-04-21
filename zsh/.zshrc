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

# Set up fzf key bindings and fuzzy completion
source <(fzf --zsh)
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh


# Source environment variables
source "$HOME/.zshenv"

[ -f "$HOME/.bash_git" ] && source "$HOME/.bash_git"
PATH="$PATH:/home/mr/.local/share/nvim/site/"
brain today
export LD_LIBRARY_PATH=/opt/rocm/lib:$LD_LIBRARY_PATH

# Added by LM Studio CLI (lms)
export PATH="$PATH:/home/mr/.lmstudio/bin"
# End of LM Studio CLI section

# opencode
export PATH=/home/mr/.opencode/bin:$PATH
