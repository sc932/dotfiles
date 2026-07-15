#!/usr/bin/env bash
# Install the tmux travel rig: standing sessions at boot (tmux-rig.service) plus the
# reaper watchdog (tmux-reaper.timer). Idempotent; safe to re-run over a live rig.
# .tmux.conf rides the Makefile `tmux` target, not this script.
# Docs: vault Meta/Setup § Remote / travel rig.
set -u
here="$(cd "$(dirname "$0")" && pwd)"

mkdir -p ~/.local/bin ~/.config/systemd/user ~/.local/state

cp "$here/rig"                 ~/.local/bin/rig;         chmod +x ~/.local/bin/rig
cp "$here/tmux-reaper"         ~/.local/bin/tmux-reaper; chmod +x ~/.local/bin/tmux-reaper
cp "$here/tmux-rig.service"    ~/.config/systemd/user/tmux-rig.service
cp "$here/tmux-reaper.service" ~/.config/systemd/user/tmux-reaper.service
cp "$here/tmux-reaper.timer"   ~/.config/systemd/user/tmux-reaper.timer

if command -v systemctl >/dev/null 2>&1; then
  systemctl --user daemon-reload 2>/dev/null || true
  systemctl --user enable --now tmux-rig.service 2>/dev/null || true
  systemctl --user enable --now tmux-reaper.timer 2>/dev/null || true
  echo "install: enabled tmux-rig.service + tmux-reaper.timer"
fi

# boot-time rig needs the user manager alive before login
if ! loginctl show-user "$USER" 2>/dev/null | grep -q 'Linger=yes'; then
  echo "NOTE: enable linger so the rig starts at boot: sudo loginctl enable-linger $USER"
fi
