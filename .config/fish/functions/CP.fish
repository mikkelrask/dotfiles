function CP
cp -v "$1" "(awk '{print $2}' $HOME | fzf)"
end
