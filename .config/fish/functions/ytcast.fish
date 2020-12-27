function ytcast
youtube-dl -o - $argv | castnow --address 192.168.1.238 --quiet -
end
