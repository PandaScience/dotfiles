#!/bin/bash
# https://github.com/swaywm/swayidle/blob/master/swayidle.1.scd#example
# BUG: https://github.com/hyprwm/Hyprland/issues/4134#issuecomment-1871464111
pkill swayidle
swayidle -w \
  timeout 180 'swaylock -f' \
  timeout 600 'hyprctl dispatch dpms off' \
  resume 'hyprctl dispatch dpms on' \
  before-sleep 'sh -c "swaylock -f && sleep 3"'
