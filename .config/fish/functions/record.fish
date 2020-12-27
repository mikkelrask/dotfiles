function record
ffmpeg -f x11grab -i :0.0 -f alsa -i hw:0 test.mkv
end
