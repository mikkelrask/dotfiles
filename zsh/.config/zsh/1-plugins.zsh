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
plug 'joshskidmore/zsh-fzf-history-search'
plug "MAHcodes/distro-prompt"
plug "chitoku-k/fzf-zsh-completions"
