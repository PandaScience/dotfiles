#!/bin/sh

[[ -f ~/.Xresources ]] && xrdb -merge -I$HOME ~/.Xresources

# DO NOT delete this! -> source global scripts
# https://wiki.archlinux.org/title/Xinit#xinitrc
if [ -d /etc/X11/xinit/xinitrc.d ] ; then
 for f in /etc/X11/xinit/xinitrc.d/?*.sh ; do
  [ -x "$f" ] && . "$f"
 done
 unset f
fi

# set keyboard layout
# toggle options: https://unix.stackexchange.com/a/45499
# setxkbmap -model pc105 -layout us -variant altgr-intl
setxkbmap -model pc105 -layout us,de -variant altgr-intl,koy -option 'grp:ctrls_toggle'

# start gnome-keyring manager but use GPG agent for SSH (see zshrc)
eval $(/usr/bin/gnome-keyring-daemon --start --components=pkcs11,secrets)
# eval $(/usr/bin/gnome-keyring-daemon --start --components=pkcs11,secrets,gpg,ssh)

# https://wiki.archlinux.org/title/Fcitx5
# if not working, paste into ~/.config/environment.d/fcitx.conf
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx

# https://wiki.archlinux.org/title/Kitty#Enable_IME_support
export GLFW_IM_MODULE=ibus

# start display manager
exec i3
# exec i3 --shmlog-size=26214400
# exec i3 -V -d all &>> "$HOME/i3.log"
