#!/bin/bash

ICON="$HOME/.local/share/icons/notify-send/monitor.png"

notify-send -u normal -i "$ICON" \
	"shikane" \
	"Profile <span color='#57dafd'><b>$SHIKANE_PROFILE_NAME</b></span> has been applied."
