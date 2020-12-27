function music
du -a "$HOME/Music/*" | awk '{print $2}' | fzf | xargs -r mpv
end
