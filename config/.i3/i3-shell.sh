#!/bin/bash
# i3 thread: https://faq.i3wm.org/question/150/how-to-launch-a-terminal-from-here/?answer=152#post-id-152

CMD=sakura
CWD=''

# Get window ID
ID=$(xdpyinfo | grep focus | cut -f4 -d " ")

# Get PID of process whose window this is
PID=$(xprop -id $ID | grep -m 1 PID | cut -d " " -f 3)

# Get last child process that isn't a thread (shell, vim, etc)
if [ -n "$PID" ]; then
    TREE=$(pstree -lpA $PID | grep -oE '\-[^\{-]+\([0-9]+\)' | cut -c2- | tail -n 1)
    PROCESS=$(echo $TREE | awk -F'---' '{print $NF}')
    PID=$(echo $TREE | awk -F'---' '{print $NF}' | sed -re 's/[^0-9]//g')
    # If we're in a tmux session then we need to do some gymnastics to get the
    # cwd since the tmux session is not a direct child of the terminal
    if [[ $PROCESS == tmux*  ]];
    then
        # To get the pid of the actual process we:
        # - find the pts of the tmux process found above
        PTS=$(ps -ef | grep $PID | grep -v grep | awk '{print $6}')
        # - find the tmux session that's attached to the pts
        TMUX_SESSION=$(tmux lsc | grep /dev/$PTS | awk '{print $2}')
        # - find the pane_pid of the session
        PID=$(tmux list-panes -s -t $TMUX_SESSION -F '#{pane_pid}')
    fi 
    # If we find the working directory, run the command in that directory
    if [ -e "/proc/$PID/cwd" ]; then
        CWD=$(readlink /proc/$PID/cwd)
    fi
fi
if [ -n "$CWD" ]; then
    $CMD -d $CWD
else
    $CMD
fi

