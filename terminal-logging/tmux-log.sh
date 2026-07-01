#!/usr/bin/env bash
# Start pipe-pane logging for a single tmux pane. Invoked by ~/.tmux.conf hooks.
# Writes the pane's raw output stream to a timestamped log in the shared tree.
pane="${1:-}"
[ -n "$pane" ] || exit 0
[ -n "${TLOG_DISABLE:-}" ] && exit 0

base="${TLOG_DIR:-$HOME/.local/state/terminal-logs}"
day="$base/$(date +%Y/%m/%d)"
mkdir -p "$day" 2>/dev/null || exit 0
chmod 700 "$base" 2>/dev/null

host="$(hostname -s 2>/dev/null || hostname)"
label="$(tmux display -p -t "$pane" '#{session_name}-#{window_index}.#{pane_index}' 2>/dev/null | tr -c 'A-Za-z0-9._-' '_')"
paneid="$(printf '%s' "$pane" | tr -c 'A-Za-z0-9' '_')"
file="$day/$(date +%H%M%S)-${host}-tmux-${label}-${paneid}.log"

tmux pipe-pane -t "$pane" "cat >> '$file'"
