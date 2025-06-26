#  /$$$$$$$$                              /$$     /$$                              
# | $$_____/                             | $$    |__/                              
# | $$    /$$   /$$ /$$$$$$$   /$$$$$$$ /$$$$$$   /$$  /$$$$$$  /$$$$$$$   /$$$$$$$
# | $$$$$| $$  | $$| $$__  $$ /$$_____/|_  $$_/  | $$ /$$__  $$| $$__  $$ /$$_____/
# | $$__/| $$  | $$| $$  \ $$| $$        | $$    | $$| $$  \ $$| $$  \ $$|  $$$$$$ 
# | $$   | $$  | $$| $$  | $$| $$        | $$ /$$| $$| $$  | $$| $$  | $$ \____  $$
# | $$   |  $$$$$$/| $$  | $$|  $$$$$$$  |  $$$$/| $$|  $$$$$$/| $$  | $$ /$$$$$$$/
# |__/    \______/ |__/  |__/ \_______/   \___/  |__/ \______/ |__/  |__/|_______/ 


__prompt_to_bottom_line() {                                                                                                                                                  
tput cup $LINES                                                                                                                                                            
}                                                                                                                                                                            
__prompt_to_bottom_line                                                                                                                                                      

__TMEX_LAUNCH () {                                                                                                                                                           
┊ cd ~/repos/dotfile-docs                                                                                                                                                    
┊ tmex 'WRITEUP' -f=1 -t -l=13{211} v  'bun i' cava cmatrix -w 'bun run serve'                                                                                               
}         

slugify_files() {
  for file in *; do
    # Extract filename and extension
    filename="${file%.*}"
    extension="${file##*.}"
    # Slugify filename
    slugified_filename=$(echo "$filename" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-zA-Z0-9]/-/g')
    # Reconstruct the filename with extension
    new_name="${slugified_filename}.${extension}"
    # Check if the new name is different
    if [ "$file" != "$new_name" ]; then
      mv -i "$file" "$new_name"
      echo "Renamed '$file' to '$new_name'"
    fi
  done
}
make-clean-install() {
  make clean
  make
  doas make install
}

cdls() { # ls when cd'ing into a dir
  builtin cd "$@" && eza
}

start_screencast() {
  ffmpeg -t x11grab -video_size 2540x1440 -framerate 25 -i :0.1 -f pulse -ac 2 -i 0 -c:v libx264 -preset ultrafast -c:a aac output.mp4
}

eval  # install with `pip install thefuck`
            fuck () {
                TF_PYTHONIOENCODING=$PYTHONIOENCODING;
                export TF_SHELL=zsh;
                export TF_ALIAS=fuck;
                TF_SHELL_ALIASES=$(alias);
                export TF_SHELL_ALIASES;
                TF_HISTORY="$(fc -ln -10)";
                export TF_HISTORY;
                export PYTHONIOENCODING=utf-8;
                TF_CMD=$(
                    thefuck THEFUCK_ARGUMENT_PLACEHOLDER $@
                ) && eval $TF_CMD;
                unset TF_HISTORY;
                export PYTHONIOENCODING=$TF_PYTHONIOENCODING;
                test -n "$TF_CMD" && print -s $TF_CMD
            }
