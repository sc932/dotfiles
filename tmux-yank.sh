#!/bin/sh
# tmux-yank.sh — pipe a tmux copy selection to the X CLIPBOARD (installed by `make tmux`
# to ~/.config/tmux-yank.sh; bound in .tmux.conf via copy-pipe-and-cancel).
#
# Why: Konsole ignores the OSC 52 escape that `set-clipboard on` relies on, so local
# mouse-drag/keyboard copies died in tmux's paste buffer and never reached the system
# clipboard (bit the 2026-07-18 AGI-talk dictation recovery). set-clipboard stays on for
# the ssh/iTerm2 travel-rig path, which DOES speak OSC 52 — the two compose.
#
# The tmux server is systemd-booted (tmux-rig.service), so its own environment has no
# DISPLAY/XAUTHORITY; resolve them from the calling pane's session environment (tmux
# update-environment refreshes both on every client attach), then fall back to :0.
resolve() {
    [ -n "$TMUX_PANE" ] || return 0
    v=$(tmux show-environment -t "$TMUX_PANE" "$1" 2>/dev/null) || return 0
    case "$v" in "$1="*) printf '%s' "${v#*=}" ;; esac
}
[ -n "$DISPLAY" ]    || DISPLAY=$(resolve DISPLAY)
[ -n "$DISPLAY" ]    || DISPLAY=:0
[ -n "$XAUTHORITY" ] || XAUTHORITY=$(resolve XAUTHORITY)
export DISPLAY
[ -n "$XAUTHORITY" ] && export XAUTHORITY
exec xsel -ib
