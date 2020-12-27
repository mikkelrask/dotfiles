function yt2mp3
youtube-dl --extract-audio --audio-format mp3 --audio-quality 0 -o '~/Music/%((title).mp3' $argv
end
