# Files to source
if [ -d "$HOME/.local/bin" ]; then
  PATH="$HOME/.local/bin:$PATH"
fi

if [ -d "$HOME/.pnpm/" ]; then
  PATH="$HOME/.pnpm/bin:$PATH"
fi

if [ -d "$HOME/.bun" ]; then
  # bun completions
  if [ -s "$HOME/.bun/_bun" ]; then  
    source "$HOME/.bun/_bun"
  fi
  export BUN_INSTALL="$HOME/.bun"
  export PATH="$BUN_INSTALL/bin:$PATH"
fi

if [ -d "$HOME/.npm-global" ]; then
  PATH="$HOME/.npm-global/bin:$PATH"
fi

if [ -d "$HOME/.cargo/bin" ]; then
  PATH="$HOME/.cargo/bin:$PATH"
fi

if [ -f "$HOME/.fzf-keybinds.zsh" ]; then
  source "$HOME/.fzf-keybinds.zsh"
fi

export BROWSER=librewolf
export FILES=dolphin
export VISUAL=nvim
export EDITOR=nvim
export TERMINAL=ghostty
export TERM=xterm-ghostty
export PLAYER=mpv
export PAGER=less
export DOTFILES_HOMEDIR=$HOME/Documents/dotfiles
export XDG_CONFIG_HOME=$HOME/.config
export THEME=rose-pine
export WALLPAPER='$HOME/.cache/wallsetter/current_wallpaper.jpg'
export FLAKE="/home/mr/.nixos"
export PATH="$HOME/.npm-global/bin:$HOME/.local/bin:$HOME/.local/share/applications:$PATH"
export NIX_PATH=nixpkgs=https://github.com/NixOS/nixpkgs/archive/nixpkgs-unstable.tar.gz
export PNPM_HOME="/home/mr/.local/share/pnpm"
export NVM_DIR="$HOME/.config/nvm"
#[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
#[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
export MOZ_ENABLE_WAYLAND=1 
export MOZ_USE_XINPUT2=1
