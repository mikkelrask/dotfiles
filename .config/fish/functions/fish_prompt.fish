## Left Prompt
function fish_prompt
    cat ~/.cache/wal/sequences
    # Set the annoying greeting to empty
    ##set fish_greeting
    set -l last_status $status
    # Show the current working directory
    #set_color $fish_color_cwd
    echo -n (prompt_pwd)
    echo -n ' % '
    #set_color normal
end

## Right Prompt
function fish_right_prompt
    set_color black
    echo -n (date +"%H:%M")
    set_color normal
end

## Window title
function fish_title
    echo -n 'raske@x250'
    prompt_pwd
end

        

## Aliases
alias ls "ls -lah --group-directories-first"
alias l "ls -lh"
alias la "ls -a"
alias +x "chmod +x"
alias grep "grep --color=auto"
alias xfd "xfd -geometry 1100x700+10+10"
alias neo "neofetch --config ~/.config/neofetch/config-image.conf --w3m --source auto"
alias font-refresh "fc-cache -fv"
alias clone "git clone --depth 1"
alias merge "xrdb ~/.Xresources"
alias version "pacman -Q"
alias search "pacman -Ss"
alias install "sudo pacman -Sy"
alias update "sudo pacman -Syu"
alias remove "sudo pacman -R"
alias purge "sudo pacman -Rsn"
alias clean "sudo pacman -Scc"
alias c "clear"
alias tpb "pirate-get"
alias plz "sudo"
#alias please "sudo $(fc -ln -1)"
alias mp3 "youtube-dl -x --audio-format mp3 --audio-quality 0"
alias new-mood "clear && wal -i ~/Pictures/wallpapers/ --saturate 0.8 && pfetch"
alias wake-desktop "wol 40:b0:76:45:a6:49"

export VISUAL=nvim
export EDITOR="$VISUAL"

## Keybinding
##set fish_key_bindings fish_default_key_bindings
starship init fish | source

