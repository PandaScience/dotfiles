#!/bin/bash

handle() {
  case $1 in
  monitorremoved*)
    hyprctl keyword monitor "eDP-1,preferred,auto,1"
    ;;
  esac
}
socat - UNIX-CONNECT:/tmp/hypr/"$HYPRLAND_INSTANCE_SIGNATURE"/.socket2.sock | while read -r line; do
  handle "$line"
done
