#!/bin/bash
# return dunst state as JSON according to:
# https://github.com/Alexays/Waybar/wiki/Module:-Custom#module-custom-config-return-type

readonly COUNT
readonly PAUSED
COUNT="$(dunstctl count waiting)"
PAUSED="$(dunstctl is-paused)"

if ((COUNT > 0)); then
    printf '{"alt": "paused", "text": " (%s)"}' "${COUNT}"
elif [[ ${PAUSED} == "true" ]]; then
    echo '{"alt": "paused"}'
else
    echo '{"alt": "unpaused"}'
fi
