#!/bin/bash
# returns active vpn connection names

# fetch all active VPN connections
VPNs=$(nmcli -f NAME,TYPE con show --active | awk '($2 == "vpn") { print $1 }')
# convert lines into comma-separated list
VPNs=$(echo "$VPNs" | paste -s -d, -)

printf '{"tooltip": "Connected VPN: %s"}' "${VPNs}"
