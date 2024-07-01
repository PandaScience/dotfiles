#!/bin/bash

# Controls different audio players when pressing laptop media keys.
# Checks players in a specific order so it's alyways a single player
# which is controlled at a time. If possible, the MPRIS interface is used, see
# https://wiki.archlinux.org/title/MPRIS
#
# NOTE: there is https://github.com/natsukagami/mpd-mpris available in AUR,
# but for now using mpc seems to be the simpler solution.
#
# NOTE: required packages:
# - playerctl
# - mpv-mpris
#
# Possible arguments are: play | next | prev

# ignore certain MPRIS players
pc="playerctl -i firefox,chromium"

# player order: ncspot > ytfzf > mpd
if [ "$1" == "play" ]; then
  $pc -p ncspot play-pause &> /dev/null || \
  $pc -p mpv play-pause &> /dev/null || \
  mpc -q toggle
elif [ "$1" == "next" ]; then
  $pc -p ncspot next &> /dev/null || \
  $pc -p mpv next &> /dev/null || \
  mpc -q next
elif [ "$1" == "prev" ]; then
  $pc -p ncspot previous &> /dev/null || \
  $pc -p mpv previous &> /dev/null || \
  mpc -q prev
fi
