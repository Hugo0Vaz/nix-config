{ pkgs
, repoPath
, withNotifications ? false
}:

pkgs.writeShellScriptBin "nix-config-sync-check" ''
  set -euo pipefail

  REPO="${repoPath}"
  GIT="${pkgs.git}/bin/git"

  # ── argument parsing ───────────────────────────────────────────────────────

  STATUS_FILE=""
  while [ $# -gt 0 ]; do
    case "$1" in
      --status-file)
        STATUS_FILE="$2"
        shift 2
        ;;
      *)
        echo "Unknown option: $1" >&2
        exit 1
        ;;
    esac
  done

  # ── helpers ────────────────────────────────────────────────────────────────

  yellow()  { printf '\033[1;33m%s\033[0m' "$*"; }
  red()     { printf '\033[1;31m%s\033[0m' "$*"; }

  print_box() {
    local color="$1"
    local line1="$2"
    local line2="$3"
    local line3="$4"

    local max_len=0
    for l in "$line1" "$line2" "$line3"; do
      local len=''${#l}
      [ "$len" -gt "$max_len" ] && max_len="$len"
    done
    local inner=$(( max_len + 2 ))

    local rule
    rule=$(printf '═%.0s' $(seq 1 "$inner"))

    pad_line() {
      local text="$1"
      printf "%-''${inner}s" " $text"
    }

    printf '\n'
    printf "  $("$color" "╔''${rule}╗")\n"
    printf "  $("$color" "║$(pad_line "$line1")║")\n"
    printf "  $("$color" "║$(pad_line "$line2")║")\n"
    printf "  $("$color" "║$(pad_line "$line3")║")\n"
    printf "  $("$color" "╚''${rule}╝")\n"
    printf '\n'
  }

  # In --status-file mode, capture box output and write atomically.
  # In interactive mode, output goes to stderr directly.
  report() {
    local color="$1" line1="$2" line2="$3" line4="$4"
    if [ -n "''${STATUS_FILE:-}" ]; then
      print_box "$color" "$line1" "$line2" "$line4" > "$STATUS_FILE.tmp"
      mv "$STATUS_FILE.tmp" "$STATUS_FILE"
    else
      print_box "$color" "$line1" "$line2" "$line4" >&2
    fi
  }

  notify() {
    local urgency="$1"
    local summary="$2"
    local body="$3"
    ${if withNotifications then ''
      if [ -n "''${DISPLAY:-}" ] || [ -n "''${WAYLAND_DISPLAY:-}" ]; then
        ${pkgs.libnotify}/bin/notify-send \
          --urgency="$urgency" \
          --app-name="nix-config" \
          --icon=dialog-warning \
          "$summary" "$body" || true
      fi
    '' else ''
      : # notifications disabled on this host
    ''}
  }

  # ── sanity checks ──────────────────────────────────────────────────────────

  if [ ! -d "$REPO" ]; then
    exit 0
  fi

  if ! $GIT -C "$REPO" rev-parse --git-dir > /dev/null 2>&1; then
    exit 0
  fi

  if ! $GIT -C "$REPO" rev-parse --abbrev-ref '@{u}' > /dev/null 2>&1; then
    exit 0
  fi

  # ── fetch ──────────────────────────────────────────────────────────────────

  $GIT -C "$REPO" fetch --quiet 2>/dev/null || {
    exit 0
  }

  # ── compare ────────────────────────────────────────────────────────────────

  LOCAL=$($GIT -C "$REPO" rev-parse HEAD)
  REMOTE=$($GIT -C "$REPO" rev-parse '@{u}')
  BASE=$($GIT -C "$REPO" merge-base HEAD '@{u}')

  AHEAD=$($GIT -C "$REPO" rev-list --count '@{u}..HEAD')
  BEHIND=$($GIT -C "$REPO" rev-list --count 'HEAD..@{u}')

  BRANCH=$($GIT -C "$REPO" rev-parse --abbrev-ref HEAD)
  SHORT_REPO=$(echo "$REPO" | sed "s|$HOME|~|")

  # ── report ─────────────────────────────────────────────────────────────────

  if [ "$LOCAL" = "$REMOTE" ]; then
    if [ -n "''${STATUS_FILE:-}" ]; then
      rm -f "$STATUS_FILE"
    fi
    exit 0

  elif [ "$LOCAL" = "$BASE" ]; then
    commits=$([ "$BEHIND" -eq 1 ] && echo "commit" || echo "commits")
    report yellow \
      "nix-config: local is $BEHIND $commits BEHIND remote" \
      "Branch: $BRANCH" \
      "Hint: git -C $SHORT_REPO pull"
    notify normal \
      "nix-config: local is behind" \
      "Branch '$BRANCH' is $BEHIND $commits behind origin.\nRun: git -C $SHORT_REPO pull"

  elif [ "$REMOTE" = "$BASE" ]; then
    commits=$([ "$AHEAD" -eq 1 ] && echo "commit" || echo "commits")
    report yellow \
      "nix-config: local is $AHEAD $commits AHEAD of remote" \
      "Branch: $BRANCH" \
      "Hint: git -C $SHORT_REPO push"
    notify normal \
      "nix-config: local is ahead" \
      "Branch '$BRANCH' is $AHEAD $commits ahead of origin.\nRun: git -C $SHORT_REPO push"

  else
    report red \
      "nix-config: DIVERGED from remote ($AHEAD ahead, $BEHIND behind)" \
      "Branch: $BRANCH" \
      "Hint: git -C $SHORT_REPO pull --rebase"
    notify critical \
      "nix-config: DIVERGED from remote" \
      "Branch '$BRANCH' is $AHEAD ahead and $BEHIND behind origin.\nRun: git -C $SHORT_REPO pull --rebase"
  fi
''
