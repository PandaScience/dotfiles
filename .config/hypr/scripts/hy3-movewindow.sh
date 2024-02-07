#!/bin/bash
# https://github.com/outfoxxed/hy3/issues/2
NowPos="$(hyprctl activewindow -j | jq ".at")"

hyprctl dispatch hy3:movewindow "$1"
ThenPos="$(hyprctl activewindow -j | jq ".at")"
if [ "$NowPos" == "$ThenPos" ]; then
  hyprctl dispatch movewindow mon:"$1"
fi
