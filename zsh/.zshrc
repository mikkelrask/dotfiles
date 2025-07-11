# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

source /usr/share/cachyos-zsh-config/cachyos-config.zsh

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
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

