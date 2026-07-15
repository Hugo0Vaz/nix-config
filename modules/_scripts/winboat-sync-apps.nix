{ pkgs }:

pkgs.writeShellScriptBin "winboat-sync-apps" ''
    set -euo pipefail

    API="http://127.0.0.1:47280"
    CURL="${pkgs.curl}/bin/curl"
    JQ="${pkgs.jq}/bin/jq"

    APPS_DIR="''${HOME}/.local/share/applications"
    ICONS_DIR="''${HOME}/.local/share/winboat-apps/icons"
    PREFIX="winboat-"

    mkdir -p "$APPS_DIR" "$ICONS_DIR"

    # ── argument: --list  →  print app names and exit ─────────────────────────
    if [[ "''${1:-}" == "--list" ]]; then
      if ! "$CURL" -fsS -m 3 "$API/health" >/dev/null 2>&1; then
        exit 0
      fi
      "$CURL" -fsS -m 10 "$API/apps" 2>/dev/null | "$JQ" -r '.[].Name'
      exit 0
    fi

    # ── health check: no-op when the container is down ───────────────────────
    if ! "$CURL" -fsS -m 3 "$API/health" >/dev/null 2>&1; then
      exit 0
    fi

    APP_JSON="$("$CURL" -fsS -m 10 "$API/apps" 2>/dev/null || true)"
    if [[ -z "$APP_JSON" ]]; then
      exit 0
    fi

    # ── slugify a name into a safe filename stem ─────────────────────────────
    slug() {
      printf '%s' "$1" \
        | tr '[:upper:]' '[:lower:]' \
        | sed -e 's/[^a-z0-9]\+/-/g' -e 's/^-\+//' -e 's/-\+$//'
    }

    # ── desktop-file escape: per spec, escape backslash, newline, and leading
    #    spaces; values are otherwise taken literally. ─────────────────────────
    esc() {
      printf '%s' "$1" | sed -e 's/\\/\\\\/g' -e 's/$/\\n/' | tr -d '\n' | sed 's/\\n$//'
    }

    # Clean app name the same way winboat-launch does (must match the
    # WM_CLASS / app_id wlfreerdp sets so compositors can match the window).
    clean_name() {
      printf '%s' "$1" | sed -e 's/[,. '"'"'"]//g'
    }

    mapfile -t NAMES < <(printf '%s' "$APP_JSON" | "$JQ" -r '.[].Name')

    declare -A SEEN
    declare -A WANT

    for NAME in "''${NAMES[@]}"; do
      SLUG="$(slug "$NAME")"
      # De-duplicate slugs (e.g. two apps collapsing to the same stem).
      if [[ -n "''${SEEN[$SLUG]:-}" ]]; then
        SLUG="''${SLUG}-''${SEEN[$SLUG]}"
        SEEN[$(slug "$NAME")]=$(( ''${SEEN[$(slug "$NAME")]} + 1 ))
      else
        SEEN[$SLUG]=1
      fi

      WANT["''${PREFIX}''${SLUG}.desktop"]=1
      DESKTOP="$APPS_DIR/''${PREFIX}''${SLUG}.desktop"
      ICON="$ICONS_DIR/''${SLUG}.png"

      ROW_B64="$(printf '%s' "$APP_JSON" | "$JQ" -r --arg n "$NAME" '.[] | select(.Name==$n) | @base64')"
      ICON_B64="$(printf '%s' "$ROW_B64" | base64 -d | "$JQ" -r '.Icon // empty')"

      if [[ -n "$ICON_B64" ]]; then
        printf '%s' "$ICON_B64" | base64 -d > "$ICON.tmp" 2>/dev/null && mv -f "$ICON.tmp" "$ICON" || rm -f "$ICON.tmp"
      else
        rm -f "$ICON"
      fi

      ICON_LINE="''${ICON}"
      [[ -f "$ICON" ]] || ICON_LINE="winboat"

      cat > "$DESKTOP.tmp" <<EOF
  [Desktop Entry]
  Version=1.0
  Type=Application
  Terminal=false
  Name=$(esc "$NAME")
  Comment=Windows application (via WinBoat)
  Exec=winboat-launch "$(esc "$NAME")"
  Icon=$ICON_LINE
  Categories=Windows;Game;
  StartupWMClass=winboat-$(clean_name "$NAME")
  EOF
      mv -f "$DESKTOP.tmp" "$DESKTOP"
    done

    # ── prune stale winboat-*.desktop entries + orphaned icons ──────────────
    shopt -s nullglob
    for f in "$APPS_DIR"/''${PREFIX}*.desktop; do
      base="$(basename "$f")"
      if [[ -z "''${WANT[$base]:-}" ]]; then
        rm -f "$f"
      fi
    done

    # Remove icons not referenced by any remaining desktop file.
    declare -A WANT_ICON
    for f in "$APPS_DIR"/''${PREFIX}*.desktop; do
      ic="$(sed -n 's/^Icon=//p' "$f")"
      [[ "$ic" == "$ICONS_DIR"/* ]] && WANT_ICON["$(basename "$ic")"]=1
    done
    for f in "$ICONS_DIR"/*.png; do
      base="$(basename "$f")"
      [[ -z "''${WANT_ICON[$base]:-}" ]] && rm -f "$f"
    done

    # Best-effort icon cache refresh.
    if command -v gtk-update-icon-cache >/dev/null 2>&1; then
      gtk-update-icon-cache -f "$HOME/.local/share/icons" >/dev/null 2>&1 || true
    fi
''
