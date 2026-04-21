#!/usr/bin/env bash

set -eou pipefail
grim -l 0 -g "$(slurp)" - | tee >(wl-copy) > "/home/mr/Pictures/Screenshots/screenshot-$(date +%s).png"

