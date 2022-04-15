[[ -f ~/.Xresources ]] && xrdb -merge -I$HOME ~/.Xresources

# according to arch wiki DO NOT delete this!
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

# start gnome-keyring manager but use keepassXC for SSH
eval $(/usr/bin/gnome-keyring-daemon --start --components=pkcs11,secrets,gpg)
# eval $(/usr/bin/gnome-keyring-daemon --start --components=pkcs11,secrets,gpg,ssh)
# export SSH_AUTH_SOCK


# start display manager
exec i3
# exec i3 --shmlog-size=26214400
# exec i3 -V -d all &>> "$HOME/i3.log"
