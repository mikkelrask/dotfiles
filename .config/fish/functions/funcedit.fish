function funcedit
du -a $HOME/bin/* $HOME/.config/fish/functions/* | awk '{print $2}' | fzf | xargs -r nvim
end
