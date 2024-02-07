#!/bin/bash

wallcache="${HOME}/.cache/current_wallpaper.jpg"
wallpath="${HOME}/Pictures/wallpapers/"

# use random wallpaper from path
wallpaper="$(find $wallpath | shuf -n1)"
echo $wallpaper
# create copy in cache for easier referemce, e.g. by swaylock
cp "$wallpaper" "$wallcache"
# set new wallpaper
swww img "$wallpaper" --transition-step 40 --transition-fps 60 --transition-type any
# generate new color palette
sleep 2
wal -ni "$wallpaper"
