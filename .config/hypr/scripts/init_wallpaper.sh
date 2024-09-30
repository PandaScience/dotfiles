#!/bin/bash

# wait until all monitors are ready to prevent this error:
#   Error: "none of the requested outputs are valid"
#   thread 'main' panicked at daemon/src/main.rs:132:35:
#   failed to read the event queue: Io(Os { code: 11, kind: WouldBlock, message: "Resource temporarily unavailable" })
sleep 1
# check if swww is already running and start if necessary
swww query || swww-daemon
# set background to last used wallpaper
swww img ~/.cache/current_wallpaper.jpg
