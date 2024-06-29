#!/data/data/com.termux/files/usr/bin/env bash

selected_name=i3
tmux_running=$(pgrep tmux)
command='termux-x11 :1 -xstartup "dbus-launch --exit-with-session i3"'

if [[ -z $TMUX ]] && [[ -z $tmux_running ]]; then
	tmux new-session -s $selected_name 'termux-x11 :1 -xstartup "dbus-launch --exit-with-session i3"'
	exit 0
fi

if ! tmux has-session -t=$selected_name 2>/dev/null; then
	tmux new-session -ds $selected_name 'termux-x11 :1 -xstartup "dbus-launch --exit-with-session i3"'
fi

am start --user 0 -n com.termux.x11/.MainActivity
