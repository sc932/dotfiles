#!/usr/bin/env bash
# Install the terminal-logging setup (see ../README). Idempotent; Linux + KDE/Konsole.
#
# NO SECRETS live in this repo (it is public). API keys go in ~/.config/secrets.zsh
# (chmod 600, machine-local, git-free) which ~/.zshrc sources — create it by hand.
set -u
here="$(cd "$(dirname "$0")" && pwd)"

mkdir -p ~/.config ~/.local/bin ~/.config/systemd/user ~/.local/share/konsole ~/.local/state/terminal-logs
chmod 700 ~/.local/state/terminal-logs 2>/dev/null || true

cp "$here/terminal-logging.zsh"         ~/.config/terminal-logging.zsh
cp "$here/tmux-log.sh"                  ~/.config/tmux-log.sh;   chmod +x ~/.config/tmux-log.sh
cp "$here/tlog-rotate"                  ~/.local/bin/tlog-rotate; chmod +x ~/.local/bin/tlog-rotate
cp "$here/Scott.profile"                ~/.local/share/konsole/Scott.profile
cp "$here/terminal-logs-rotate.service" ~/.config/systemd/user/terminal-logs-rotate.service
cp "$here/terminal-logs-rotate.timer"   ~/.config/systemd/user/terminal-logs-rotate.timer

# blobsync manifest — machine-local; only seed it if absent, never clobber real state.
if [ ! -f ~/.local/state/terminal-logs/.blobmanifest.json ]; then
  cp "$here/blobmanifest.template.json" ~/.local/state/terminal-logs/.blobmanifest.json
fi

# Wire the ~/.zshrc source line (idempotent).
if [ -f ~/.zshrc ] && ! grep -q 'terminal-logging.zsh' ~/.zshrc; then
  printf '\n# automatic terminal-session logging (dotfiles: terminal-logging/)\n[[ -f ~/.config/terminal-logging.zsh ]] && source ~/.config/terminal-logging.zsh\n' >> ~/.zshrc
  echo "install: added source line to ~/.zshrc"
fi

# Konsole default profile. konsolerc is machine-specific and NOT synced, so set the
# one key idempotently rather than shipping the whole file.
for kw in kwriteconfig6 kwriteconfig5; do
  if command -v "$kw" >/dev/null 2>&1; then
    "$kw" --file konsolerc --group "Desktop Entry" --key DefaultProfile "Scott.profile"
    echo "install: set Konsole DefaultProfile via $kw"; break
  fi
done

# Enable the daily rotation + backup timer.
if command -v systemctl >/dev/null 2>&1; then
  systemctl --user daemon-reload 2>/dev/null || true
  systemctl --user enable --now terminal-logs-rotate.timer 2>/dev/null || true
  echo "install: enabled terminal-logs-rotate.timer"
fi

# Secrets reminder — NEVER commit these to this public repo.
if [ ! -f ~/.config/secrets.zsh ]; then
  echo ""
  echo "  create ~/.config/secrets.zsh (chmod 600) with your 'export KEY=...' lines;"
  echo "  ~/.zshrc sources it. It is machine-local and must NEVER be committed here."
fi
# The R2 backup also needs the 'r2-personal' rclone remote (see control-surface/docs/blobsync.md).

echo "terminal-logging installed — open a new terminal to activate."
