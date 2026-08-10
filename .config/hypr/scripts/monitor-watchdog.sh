#!/bin/bash
# Re-light a panel when unplugging leaves Hyprland with no usable output.
#
# Undocking while the built-in panel is disabled deadlocks: with no output left
# Hyprland enables its virtual FALLBACK monitor and advertises it over
# wlr-output-management like a real one. shikane then needs every head to pair
# with an output, FALLBACK pairs with none, and so every profile fails with
# "Cannot find enough fitting pairs of outputs and heads" - including the one
# for the bare panel. Nothing re-enables the panel, so FALLBACK stays, so
# nothing matches. No extra profile can break that cycle.
#
# `hyprctl keyword` is no way out either, because Hyprland lets shikane's
# protocol state override monitor rules (hyprwm/Hyprland#14343). Dropping
# shikane and reloading is, hence shikane-rescue.sh.
#
# Only acts when nothing at all is lit, so a normal unplug that leaves a
# working screen never restarts shikane. Re-lighting the panel destroys
# FALLBACK, whose own monitorremoved then finds an output lit and does nothing.

set -u

socket="$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"

# hyprctl monitors lists only enabled outputs. FALLBACK is Hyprland's virtual
# output, which exists precisely when no real one is enabled.
lit_outputs() {
  hyprctl -j monitors | jq '[.[] | select(.name != "FALLBACK")] | length'
}

# -U is receive-only. Plain `socat -` would also forward stdin, and exit as soon
# as that hits EOF - which it does immediately when started from Hyprland.
socat -U - UNIX-CONNECT:"$socket" | while read -r line; do
  case $line in
  monitorremoved*)
    # let the rest of the unplug settle, and debounce the event burst
    sleep 2

    # on doubt do nothing: a spurious shikane restart is worse than waiting
    count=$(lit_outputs 2>/dev/null) || continue
    [[ -n ${count//[0-9]/} || -z $count ]] && continue
    ((count > 0)) && continue

    echo "no usable output left, running rescue"
    "$HOME/.config/hypr/scripts/shikane-rescue.sh"
    ;;
  esac
done
