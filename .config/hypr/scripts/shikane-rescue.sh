#!/bin/bash
# Recover an output that Hyprland refuses to re-enable or re-scale.
#
# Hyprland stores wlr-output-management state per client and overlays it on
# every monitor rule read, so once shikane has configured an output neither
# hyprland.conf nor `hyprctl keyword monitor` can change it again.
# See https://github.com/hyprwm/Hyprland/pull/14343.
#
# That state is owned by the client, so disconnecting shikane drops it and
# hands authority back to the config. Hence: stop shikane, re-apply the config,
# start shikane again so it re-applies the matching profile.

set -u

pkill -x shikane

# nothing re-evaluates the monitors when the client goes away, so reload to
# apply monitors.conf again - it carries the right scale for whichever panel
# this machine has
sleep 0.5
hyprctl reload

setsid -f shikane
