#!/usr/bin/env bash


x=$(echo -e "Shutdown\nReboot\nLogout\nLock\nCancel (esc)" | wofi --dmenu -i -p "What to do?")
case "$x" in
  Shutdown) shutdown now;;
  Reboot) reboot;;
  Logout) hyprctl dispatch exit;;
  Lock) hyprlock ;;
  *) echo "[INFO] No action selected. Exiting."
esac

