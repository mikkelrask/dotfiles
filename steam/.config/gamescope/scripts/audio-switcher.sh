#!/bin/bash

# Gamescope audio output switcher
# Automatically switches to HDMI audio when available

# Get all HDMI sinks that are NOT suspended
ACTIVE_HDMI=$(pactl list sinks | grep -B 5 "State: RUNNING\|State: IDLE" | grep "Name:" | grep -i "hdmi" | head -n1 | awk '{print $2}')

# If we found an active HDMI sink, switch to it
if [ -n "$ACTIVE_HDMI" ]; then
    echo "Found active HDMI audio: $ACTIVE_HDMI"
    pactl set-default-sink "$ACTIVE_HDMI"
    echo "Switched default audio output to HDMI"
else
    # No active HDMI, check if any HDMI exists at all (even if suspended)
    ANY_HDMI=$(pactl list sinks short | grep -i "hdmi" | head -n1 | awk '{print $2}')
    
    if [ -n "$ANY_HDMI" ]; then
        echo "Found HDMI audio (trying to activate): $ANY_HDMI"
        pactl set-default-sink "$ANY_HDMI"
        echo "Switched to HDMI (may activate when TV detected)"
    else
        echo "No HDMI audio found, using default (laptop speakers)"
    fi
fi
