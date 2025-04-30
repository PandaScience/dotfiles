#!/bin/bash

wallcache="${HOME}/.cache/current_wallpaper.png"
wallpath="${HOME}/Pictures/wallpapers/"

# use random wallpaper from path
wallpaper="$(find $wallpath | shuf -n1)"
# set new wallpaper
swww img "$wallpaper" --transition-step 40 --transition-fps 60 --transition-type any
# create png copy in cache for easier referemce, e.g. by swaylock or hyprlock
magick "$wallpaper" "$wallcache"
# generate new color palette
sleep 2
wal -ni "$wallpaper"
