#/bin/bash
cd /tmp
URL=''
ANS=''
VERSION=''
err () {
  echo " Error!" 
  echo "Something went wrong: $1"
  echo "Press any key to exit installer"
  read -n 1 BYE
  exit 1
}
prompt_purge () {
  if [ -f "$HOME/.local/bin/nvim" ] || [ -d "$HOME/.local/share/nvim" ] || [ -d "$HOME/.local/state/nvim" ] || [ -d "$HOME/.local/lib/nvim" ] || [ -d "$HOME/.cache/nvim" ]; then
    echo "Do you wish to purge files from previous neovim installs? (y/n) "
    read ANS
    ANS=${ANS:-'n'}
    if [ "$ANS" = 'n' ] || [ "$ANS" = 'N' ]; then
      echo " Skipping purge"
    else
     purge 
    fi
  fi
}
purge () {
  rm -rf "$HOME/.local/bin/nvim" "$HOME/.local/share/nvim" "$HOME/.local/lib/nvim" "$HOME/.local/state/nvim" "$HOME/.cache/nvim" || err " Could not purge leftovers"
  echo " Leftovers are purged"

}

prompt_for_version () {
  echo "Neovim Downloader by mikkelrask"
  echo " - Pick your version below (enter number)"
  echo " - 1. Latest (stable)"
  echo " - 2. Nightly (development / prerelease)"
  echo ""
  echo "Enter number: "
  read ANS

  if [ "$ANS" -eq 1 ]; then
    URL='https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz'
    VERSION="latest stable"
  fi
  if [ "$ANS" -eq '2' ]; then
    URL='https://github.com/neovim/neovim/releases/download/nightly/nvim-linux64.tar.gz'
    VERSION="nightly"
  fi
  echo " downloading $VERSION build ..."
}
unpack_tar () {
  # check if tar exists
  if ! [ -x "$(command -v tar)" ]; then
    err " tar is not installed"
  fi
  tar -xf nvim.tar.gz || err " unpacking tar archive failed"
  echo " unpacked tar archive" 
}
copy_nvim () {
  cd nvim-linux64
  cp -r bin share lib $HOME/.local/  || err " copying files failed"
  echo " nvim installed in .local/bin"
}
get_nvim () {
  wget -O nvim.tar.gz $URL -q --show-progress || err " could not download Neovim $VERSION build."
  echo " nvim-linux64.tar.gz downloaded"
  unpack_tar 
  prompt_purge
  copy_nvim
  if [ "$KEEP" ]; then
    echo " Keeping downloaded files"
  else
    prompt
  fi
  echo " Neovim installed successfully!"
}
clean_up () {
  rm -rf /tmp/nvim-linux64 /tmp/nvim.tar.gz
  echo " Cleaned up temporary files"
}
prompt_clean () {
  echo "Do you wish to clean up downloaded files? (y/n) "
  read ANS
  ANS=${ANS:-'y'}
  if [ "$ANS" = 'n' ] || [ "$ANS" = 'N' ]; then
    echo " Skipping cleanup"
  else
    clean_up
  fi
}
if [ -z "$1" ]; then
  NOARGS=1
else
  if [ "$1" = "-k" ] || [ "$1" = "--keep" ]; then
    KEEP=1
  elif [ "$1" = "-p" ] || [ "$1" = "--purge" ]; then
    echo " Purging previous neovim installs and leftovers"
    echo "This action can not be undone. Continue? (y/n) "
    read ANS
    ANS=${ANS:-'n'}
    if [ "$ANS" = 'n' ] || [ "$ANS" = 'N' ]; then
      echo " Skipping purge"
      exit 0
    fi
    purge
    exit 0
  else
    echo "Usage: install-nvim.sh [OPTION]"
    echo "This script will download and install neovim in .local/bin"
    echo "-k or --keep will keep the downloaded files"
    echo "-p or --purge will remove any previous neovim installs"
    exit 0
  fi
fi

prompt_for_version || err "something went wrong..."
get_nvim 
prompt_clean
