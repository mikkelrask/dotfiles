#  /$$$$$$$$                              /$$     /$$                              
# | $$_____/                             | $$    |__/                              
# | $$    /$$   /$$ /$$$$$$$   /$$$$$$$ /$$$$$$   /$$  /$$$$$$  /$$$$$$$   /$$$$$$$
# | $$$$$| $$  | $$| $$__  $$ /$$_____/|_  $$_/  | $$ /$$__  $$| $$__  $$ /$$_____/
# | $$__/| $$  | $$| $$  \ $$| $$        | $$    | $$| $$  \ $$| $$  \ $$|  $$$$$$ 
# | $$   | $$  | $$| $$  | $$| $$        | $$ /$$| $$| $$  | $$| $$  | $$ \____  $$
# | $$   |  $$$$$$/| $$  | $$|  $$$$$$$  |  $$$$/| $$|  $$$$$$/| $$  | $$ /$$$$$$$/
# |__/    \______/ |__/  |__/ \_______/   \___/  |__/ \______/ |__/  |__/|_______/ 

# start our prompt at the bottom of the screen
__prompt_to_bottom_line() {                                                                                                                                                  
┊ tput cup $LINES                                                                                                                                                            
}                                                                                                                                                                            
__prompt_to_bottom_line

__TMEX_LAUNCH () {                                                                                                                                                           
┊ cd ~/repos/dotfile-docs                                                                                                                                                    
┊ tmex 'WRITEUP' -f=1 -t -l=13{211} v  'bun i' cava cmatrix -w 'bun run serve'                                                                                               
┊ cd                                                                                                                                                                         
}         
slugify_files() {
  for file in *; do
    new_name=$(echo "$file" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-zA-Z0-9]/-/g')
    if [ "$file" != "$new_name" ]; then
      mv -i "$file" "$new_name"
      echo "Renamed '$file' to '$new_name'"
    fi
  done
}

