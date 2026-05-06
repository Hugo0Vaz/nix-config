{ pkgs
, repoPath
, withNotifications ? false
}:

pkgs.writeShellScriptBin "nix-config-sync-check" ''
  set -euo pipefail

  REPO="${repoPath}"
  GIT="${pkgs.git}/bin/git"

  # ── helpers ────────────────────────────────────────────────────────────────

  bold()    { printf '\033[1m%s\033[0m' "$*"; }
  yellow()  { printf '\033[1;33m%s\033[0m' "$*"; }
  red()     { printf '\033[1;31m%s\033[0m' "$*"; }
  cyan()    { printf '\033[1;36m%s\033[0m' "$*"; }
  reset()   { printf '\033[0m'; }

  print_box() {
    local color="$1"
    local line1="$2"
    local line2="$3"
    local line3="$4"

    # Compute the width needed (longest line + 2 padding spaces on each side)
    local max_len=0
    for l in "$line1" "$line2" "$line3"; do
      local len=''${#l}
      [ "$len" -gt "$max_len" ] && max_len="$len"
    done
    local inner=$(( max_len + 2 ))

    # Build horizontal rule
    local rule
    rule=$(printf '═%.0s' $(seq 1 "$inner"))

    pad_line() {
      local text="$1"
      local padded
      padded=$(printf "%-''${inner}s" " $text")
      printf '%s' "$padded"
    }

    printf '\n' >&2
    printf "  $("$color" "╔''${rule}╗")\n" >&2
    printf "  $("$color" "║$(pad_line "$line1")║")\n" >&2
    printf "  $("$color" "║$(pad_line "$line2")║")\n" >&2
    printf "  $("$color" "║$(pad_line "$line3")║")\n" >&2
    printf "  $("$color" "╚''${rule}╝")\n" >&2
    printf '\n' >&2
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

  # Check whether there is an upstream tracking branch configured
  if ! $GIT -C "$REPO" rev-parse --abbrev-ref '@{u}' > /dev/null 2>&1; then
    exit 0
  fi

  # ── fetch ──────────────────────────────────────────────────────────────────

  $GIT -C "$REPO" fetch --quiet 2>/dev/null || {
    # Network unavailable — silently skip
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
    # Up to date — silent
    exit 0

  elif [ "$LOCAL" = "$BASE" ]; then
    # Behind: remote has new commits not in local
    commits=$([ "$BEHIND" -eq 1 ] && echo "commit" || echo "commits")
    print_box yellow \
      "nix-config: local is $BEHIND $commits BEHIND remote" \
      "Branch: $BRANCH" \
      "Hint: git -C $SHORT_REPO pull"
    notify normal \
      "nix-config: local is behind" \
      "Branch '$BRANCH' is $BEHIND $commits behind origin.\nRun: git -C $SHORT_REPO pull"

  elif [ "$REMOTE" = "$BASE" ]; then
    # Ahead: local has commits not pushed to remote
    commits=$([ "$AHEAD" -eq 1 ] && echo "commit" || echo "commits")
    print_box yellow \
      "nix-config: local is $AHEAD $commits AHEAD of remote" \
      "Branch: $BRANCH" \
      "Hint: git -C $SHORT_REPO push"
    notify normal \
      "nix-config: local is ahead" \
      "Branch '$BRANCH' is $AHEAD $commits ahead of origin.\nRun: git -C $SHORT_REPO push"

  else
    # Diverged: both sides have commits the other lacks
    print_box red \
      "nix-config: DIVERGED from remote ($AHEAD ahead, $BEHIND behind)" \
      "Branch: $BRANCH" \
      "Hint: git -C $SHORT_REPO pull --rebase"
    notify critical \
      "nix-config: DIVERGED from remote" \
      "Branch '$BRANCH' is $AHEAD ahead and $BEHIND behind origin.\nRun: git -C $SHORT_REPO pull --rebase"
  fi
''
