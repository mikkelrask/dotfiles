#!/usr/bin/env bash

set -eou pipefail

PLAYER=rmpc

ghostty --title="rmpc" --config-file=/home/mr/.config/ghostty/borderless -e rmpc

