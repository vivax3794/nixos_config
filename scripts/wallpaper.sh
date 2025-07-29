#!/bin/bash

MPVPAPER_PID1=""
MPVPAPER_PID2=""

start_mpvpaper() {
    mpvpaper -o "no-audio loop hwdec=auto vf=crop=w=3440:h=1440 gpu-api=vulkan" --auto-pause DP-3 /etc/nixos/wallpapers/wide.mp4 &
    MPVPAPER_PID1=$!
    
    mpvpaper -o "no-audio loop hwdec=auto vf=crop=w=1080:h=1920 gpu-api=vulkan" --auto-pause HDMI-A-3 /etc/nixos/wallpapers/vertical.mp4 &
    MPVPAPER_PID2=$!
}

kill_mpvpaper() {
    if [[ -n "$MPVPAPER_PID1" ]] && kill -0 "$MPVPAPER_PID1" 2>/dev/null; then
        kill -9 "$MPVPAPER_PID1"
    fi
    
    if [[ -n "$MPVPAPER_PID2" ]] && kill -0 "$MPVPAPER_PID2" 2>/dev/null; then
        kill -9 "$MPVPAPER_PID2"
    fi
    
    # Clear the PID variables
    MPVPAPER_PID1=""
    MPVPAPER_PID2=""
}

while true; do
    start_mpvpaper
    sleep 1800
    kill_mpvpaper
    sleep 1
done
