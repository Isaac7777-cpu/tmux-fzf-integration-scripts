#!/usr/bin/env bash

if [[ $# -eq 1 ]]; then
  selected=$1
else
  selected=$(
    tmux list-sessions -F '#S' |
      fzf --preview '
        # Get the active pane for the active window in this session
        pane=$(tmux display-message -p -t {} "#{pane_id}") || exit
        # Capture last 30 lines of its content (like chooser preview)
        tmux capture-pane -ep -t "$pane" -S -0
      ' --preview-window=down:80%
  )
fi

if [[ -z $selected ]]; then
  exit 0
fi

if [[ -z $TMUX ]]; then
  tmux attach -t $selected
else
  tmux switch-client -t $selected
fi
