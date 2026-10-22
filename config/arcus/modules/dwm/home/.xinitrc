#!/bin/sh
userresources=$HOME/.Xresources
usermodmap=$HOME/.Xmodmap
sysresources=/etc/X11/xinit/.Xresources
sysmodmap=/etc/X11/xinit/.Xmodmap

# merge in defaults and keymaps
if [ -f "$sysresources" ]; then
    xrdb -merge "$sysresources"
fi

if [ -f "$sysmodmap" ]; then
    xmodmap "$sysmodmap"
fi

if [ -f "$userresources" ]; then
    xrdb -merge "$userresources"
fi

if [ -f "$usermodmap" ]; then
    xmodmap "$usermodmap"
fi

# start some nice programs from the xinitrc.d directory
if [ -d /etc/X11/xinit/xinitrc.d ] ; then
  for f in /etc/X11/xinit/xinitrc.d/?*.sh ; do
    [ -x "$f" ] && . "$f"
  done
  unset f
fi

# Setup
picom -b &
feh --bg-fill -g +0-70 $HOME/Pictures/wallpaper.png &
slstatus &
nm-applet &
pa-applet &
dunst &
battery_monitor &
exec dwm
#export XDG_SESSION_TYPE=x11
#export XDG_CURRENT_DESKTOP=dwm
#exec dbus-launch --exit-with-session dwm
