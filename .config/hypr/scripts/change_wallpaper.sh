#!/bin/bash

wallcache="${HOME}/.cache/current_wallpaper.png"
wallpath="${HOME}/Pictures/wallpapers/"

# use random wallpaper from path
wallpaper="$(find "$wallpath" | shuf -n1)"

# set new wallpaper
awww img "$wallpaper" --transition-step 40 --transition-fps 60 --transition-type any
# create png copy in cache for easier reference, e.g. by swaylock or hyprlock
magick "$wallpaper" "$wallcache"
