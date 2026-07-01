# ~/.config/terminal-logging.zsh — automatic per-session terminal logging.
#
# Sourced from the TOP of ~/.zshrc. Linux-only (util-linux script(1)); a safe
# no-op on macOS/BSD. Wraps every INTERACTIVE tty shell (Konsole, SSH, and any
# non-tmux shell) in script(1) exactly once, recording the session to a
# timestamped log under $TLOG_DIR. tmux panes are logged separately by
# ~/.tmux.conf (pipe-pane), so we DON'T wrap inside tmux — that avoids nesting
# PTYs and logging the tmux client's redraw noise.
#
#   Kill switch:  export TLOG_DISABLE=1   (in this file, or before a shell starts)
#   Recursion is prevented by TLOG_ACTIVE (exported -> inherited by child shells).
#   Read logs:    tlog view   (see the tlog() helper below)
#   Full docs:    ~/dev/vault/Meta/Setup.md -> "Terminal logging & scrollback"

# Entire feature is Linux-only; no-op elsewhere (e.g. if this ever syncs to macOS).
[[ "$OSTYPE" == linux* ]] || return 0

: ${TLOG_DIR:=$HOME/.local/state/terminal-logs}
export TLOG_DIR

# --- wrap this shell in script(1) exactly once, only for a real interactive tty ---
if [[ -o interactive ]] \
   && [[ -z "$TLOG_ACTIVE" ]] \
   && [[ -z "$TLOG_DISABLE" ]] \
   && [[ -z "$TMUX" ]] \
   && [[ -t 0 && -t 1 ]] \
   && command -v script >/dev/null 2>&1; then

  _tlog_day="$TLOG_DIR/$(date +%Y/%m/%d)"
  if mkdir -p "$_tlog_day" 2>/dev/null; then
    chmod 700 "$TLOG_DIR" 2>/dev/null
    _tlog_tty="${TTY#/dev/}"; _tlog_tty="${_tlog_tty//\//-}"; : ${_tlog_tty:=notty}
    _tlog_file="$_tlog_day/$(date +%H%M%S)-${HOST}-${_tlog_tty}-$$.log"
    export TLOG_ACTIVE=1
    export TLOG_CURRENT="$_tlog_file"
    # -q: quiet (no banner)  -e: return the child shell's exit code.
    # No command => script runs $SHELL interactively (inherits cwd + exported env).
    exec script -q -e "$_tlog_file"
  fi
  # mkdir failed (readonly/full disk): fall through UNLOGGED — never block login.
fi

# --- reached in the RECORDING shell, or whenever wrapping was skipped ----------
# Strip ANSI/OSC/control noise and resolve \r overwrites for readable output.
_tlog_clean() {
  perl -pe '
    s/\e\][^\a]*\a//g;                          # OSC ... BEL  (window titles)
    s/\e[PX^_].*?\e\\//g;                        # DCS/PM/APC/SOS ... ST
    s/\e\[[0-9;:?<>=!]*[ -\/]*[\x40-\x7e]//g;    # CSI  (color, cursor, clear-line)
    s/\e[\x40-\x5f]//g;                          # other two-char escapes
    s/[\x00-\x08\x0b\x0c\x0e-\x1f]//g;           # stray control bytes (keep \t \n \r)
  ' "$@" 2>/dev/null | col -b 2>/dev/null \
    | sed -e '/^Script started on /d' -e '/^Script done on /d'
}

# tlog — inspect terminal logs.  Usage: tlog [cur|ls [N]|view [f]|cat [f]|tail [f]|grep PAT|dir]
tlog() {
  emulate -L zsh
  local dir="${TLOG_DIR:-$HOME/.local/state/terminal-logs}"
  local f
  case "${1:-cur}" in
    cur|current)
      [[ -n "$TLOG_CURRENT" ]] && print -r -- "$TLOG_CURRENT" \
        || print -r -- "(this shell is not being recorded)" ;;
    dir) print -r -- "$dir" ;;
    ls)  shift
         find "$dir" -type f \( -name '*.log' -o -name '*.log.gz' \) -printf '%T+ %p\n' 2>/dev/null \
           | sort -r | head -n "${1:-20}" | cut -d' ' -f2- ;;
    view) shift; f="${1:-$TLOG_CURRENT}"; [[ -z "$f" ]] && { print -r -- "no log"; return 1; }
          if [[ "$f" == *.gz ]]; then zcat "$f" | _tlog_clean | ${PAGER:-less} -R
          else _tlog_clean "$f" | ${PAGER:-less} -R; fi ;;
    cat)  shift; f="${1:-$TLOG_CURRENT}"; [[ -z "$f" ]] && { print -r -- "no log"; return 1; }
          if [[ "$f" == *.gz ]]; then zcat "$f" | _tlog_clean; else _tlog_clean "$f"; fi ;;
    tail) shift; f="${1:-$TLOG_CURRENT}"; [[ -z "$f" ]] && { print -r -- "no log"; return 1; }
          tail -f "$f" ;;
    grep) shift; [[ -z "${1:-}" ]] && { print -r -- "usage: tlog grep PATTERN"; return 1; }
          find "$dir" -type f \( -name '*.log' -o -name '*.log.gz' \) -print0 2>/dev/null \
            | xargs -0 -r zgrep -I -H --color "$1" 2>/dev/null ;;
    *) print -r -- "usage: tlog [cur|ls [N]|view [f]|cat [f]|tail [f]|grep PAT|dir]" ;;
  esac
}
