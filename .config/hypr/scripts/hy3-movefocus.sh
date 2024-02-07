#!/bin/bash
# https://github.com/outfoxxed/hy3/issues/2
NowWindow="$(hyprctl activewindow -j | jq ".address")"

hyprctl dispatch hy3:movefocus "$1"  # && sleep 0.05
ThenWindow="$(hyprctl activewindow -j | jq ".address")"
if [ "$NowWindow" == "$ThenWindow" ]; then
  hyprctl dispatch movefocus "$1"
fi
