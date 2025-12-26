#!/usr/bin/env bash

# Ensure a named window exists in the session; create it if missing.
ensure_window() {
  # usage: ensure_window <session> <win_name> <dir>
  local sess="$1" name="$2" dir="$3"

  if ! tmux list-windows -t "$sess" -F '#{window_name}' 2>/dev/null | grep -qx "$name"; then
    tmux new-window -t "$sess" -n "$name" -c "$dir"
  fi
}

if [[ $# -eq 1 ]]; then
  selected=$1
else
  # selected=$(find ~/Codes ~/.config -mindepth 1 -type d | fzf)
  # selected=$(fd -t d -d 3 . ~/Codes ~/.config ~/OneDrive\ -\ Australian\ National\ University | fzf)
  selected=$(fd -t d . ~/Codes ~/.config ~/OneDrive\ -\ Australian\ National\ University | fzf)
fi

if [[ -z $selected ]]; then
  exit 0
fi

selected_name=$(basename "$selected" | tr . _)
tmux_running=$(pgrep tmux)

# echo $selected_name
# echo $selected

if [[ -z $TMUX ]] && [[ -z $tmux_running ]]; then
  tmux new-session -s $selected_name -c "$selected" -n editor

  ensure_window "$selected_name" "term" "$selected"
  ensure_window "$selected_name" "report" "$selected"
  ensure_window "$selected_name" "buffer" "$selected"

  tmux select-window -t "$selected_name:editor"

  exit 0
fi

if ! tmux has-session -t=$selected_name 2>/dev/null; then
  tmux new-session -ds $selected_name -c "$selected" -n editor

  ensure_window "$selected_name" "term" "$selected"
  ensure_window "$selected_name" "report" "$selected"
  ensure_window "$selected_name" "buffer" "$selected"

  tmux select-window -t "$selected_name:=editor"

fi

if [[ -z $TMUX ]]; then
  tmux attach -t $selected_name
else
  tmux switch-client -t $selected_name
fi
