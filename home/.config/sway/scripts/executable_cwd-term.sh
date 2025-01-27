#!/usr/bin/env bash

# Open a new terminal in the current working directory of a focused terminal
#terminal="alacritty"
terminal="foot"

# Get the process id of the currently selected window
pid=$(swaymsg -t get_tree | jq '.. | select(.type?) | select(.type=="con") | select(.focused==true).pid')
# Get the name of this process
pname=$(ps -p ${pid} -o comm= | sed 's/-$//')
echo $pid

# If the process name matches the $terminal, obtain the CWD and echo the result.
if [[ $pname == $terminal ]]
then
    # Get parent process id
    # ppid=$(pgrep --newest --parent $pid )
    ppid=$(pgrep --newest --exact footclient --parent $pid )

    # Get the current working directory
    # workdir=$(readlink /proc/${ppid}/cwd)
    workdir=$(pwdx ${ppid} | awk -F ':' '{gsub(/ /, "", $2); print $2}')
    notify-send -t 2000 "Terminal in $workdir"
    echo "$workdir"
    # $terminal -d $workdir
    footclient --working-directory "$workdir"
else
    notify-send -t 2000 -- "Failed to obtain current directory from $pname"
    echo $HOME
fi
