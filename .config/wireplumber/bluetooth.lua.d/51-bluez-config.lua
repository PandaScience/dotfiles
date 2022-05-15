-- https://nixos.wiki/wiki/PipeWire
-- https://www.guyrutenberg.com/2021/06/24/replacing-pulseaudio-with-pipewire-0-3-30/
-- https://pipewire.pages.freedesktop.org/wireplumber/configuration/bluetooth.html
-- https://www.collabora.com/news-and-blog/news-and-events/pipewire-bluetooth-support-status-update.html
bluez_monitor.properties = {
	["bluez5.enable-msbc"] = true,
	-- no stable connection on distance!
	-- ["bluez5.enable-sbc-xq"] = true
}
