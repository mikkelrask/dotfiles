#!/usr/bin/env bash

set -eou pipefail

# check what specific linux distro we are on

distro=$(lsb_release -si)

if [ $distro = "Ubuntu" ]; then
  echo "You are using Ubuntu, updating zshrc alias'"
  echo {\
    "alias install='doas apt install'",\
    "alias uninstall='doas apt remove'",\
    "alias update='apt update'",\
    "alias upgrade='apt update && doas apt upgrade -y'",\
    "alias clean='doas apt autoremove'"\
  } >> ~/.zshrc
elif [ $distro = "Fedora" ]; then
  echo "You are using Fedora"
elif [ $distro = "CentOS" ]; then
  echo "You are using CentOS"
elif [ $distro = "Arch" ]; then
  echo "You are using Arch Linux"
else
  echo "You are using an unknown distro"
fi

