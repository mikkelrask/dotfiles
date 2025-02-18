#!/usr/bin/env bash

set -eou pipefail
nix-shell -p appimage-run
appimage-run /home/mr/.local/bin/cursor.AppImage

