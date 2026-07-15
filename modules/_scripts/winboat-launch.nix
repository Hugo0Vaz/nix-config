{ pkgs }:

pkgs.writeShellScriptBin "winboat-launch" ''
  set -euo pipefail

  if [[ "$#" -lt 1 ]]; then
    echo "Usage: winboat-launch <app-name>" >&2
    echo "List apps: winboat-sync-apps --list" >&2
    exit 2
  fi

  APP_NAME="$1"
  API="http://127.0.0.1:47280"
  CURL="${pkgs.curl}/bin/curl"
  JQ="${pkgs.jq}/bin/jq"

  COMPOSE="''${HOME}/.winboat/docker-compose.yml"
  CONFIG="''${HOME}/.winboat/winboat.config.json"

  if ! "$CURL" -fsS -m 3 "$API/health" >/dev/null 2>&1; then
    echo "WinBoat guest API not reachable at $API/health." >&2
    echo "Is the WinBoat container running?" >&2
    exit 1
  fi

  APP_JSON="$("$CURL" -fsS -m 10 "$API/apps" || true)"
  if [[ -z "$APP_JSON" ]]; then
    echo "Failed to fetch /apps from WinBoat guest API." >&2
    exit 1
  fi

  APP_B64="$(printf '%s' "$APP_JSON" | "$JQ" -r --arg n "$APP_NAME" '.[] | select(.Name==$n) | @base64')"
  if [[ -z "$APP_B64" ]]; then
    echo "No Windows app named '$APP_NAME' found." >&2
    echo "Available:" >&2
    printf '%s' "$APP_JSON" | "$JQ" -r '.[].Name' | sed 's/^/  /' >&2
    exit 1
  fi

  APP_PATH="$(printf '%s' "$APP_B64" | base64 -d | "$JQ" -r '.Path')"
  APP_ARGS="$(printf '%s' "$APP_B64" | base64 -d | "$JQ" -r '.Args')"

  # ── resolve RDP credentials + port ──────────────────────────────────────
  # Read USERNAME/PASSWORD from the winboat compose file (kept out of the
  # Nix store). Resolve the actual RDP host port via `docker port` when
  # available; fall back to the compose base port (47300).
  read_creds() {
    local key="$1"
    sed -n "s/^[[:space:]]*''${key}:[[:space:]]*//p" "$COMPOSE" 2>/dev/null \
      | head -n1 \
      | sed -e 's/^"//' -e 's/"$//'
  }

  WB_USER="$(read_creds USERNAME)"
  WB_PASS="$(read_creds PASSWORD)"

  if [[ -z "$WB_USER" || -z "$WB_PASS" ]]; then
    echo "Could not read USERNAME/PASSWORD from $COMPOSE." >&2
    exit 1
  fi

  RDP_PORT=""
  if command -v docker >/dev/null 2>&1; then
    RDP_PORT="$(docker port WinBoat 3389/tcp 2>/dev/null | sed -n 's/^[0-9.]\+://p' | head -n1)"
  fi
  if [[ -z "$RDP_PORT" ]]; then
    # Compose maps 127.0.0.1:47300-47309:3389/tcp; the base is the first.
    RDP_PORT="$(sed -n 's/.*127\.0\.0\.1:\([0-9]\+\)-[0-9]\+:3389\/tcp.*/\1/p' "$COMPOSE" | head -n1)"
  fi
  RDP_PORT="''${RDP_PORT:-47300}"

  # scale-desktop from winboat.config.json (default 100).
  SCALE=100
  if [[ -f "$CONFIG" ]]; then
    SCALE="$("$JQ" -r '.scaleDesktop // .scale // 100' "$CONFIG" 2>/dev/null || echo 100)"
  fi

  # ── pick FreeRDP client: wlfreerdp on Wayland, xfreerdp on X11 ──────────
  # xfreerdp is an X11 client and fails on a pure-Wayland session without
  # XWayland (error 136). wlfreerdp is the Wayland-native equivalent and
  # accepts the same /app:, /wm-class, /scale-desktop, etc. options.
  FREERDP="${pkgs.freerdp}/bin/xfreerdp"
  if [[ -n "''${WAYLAND_DISPLAY:-}" && -z "''${DISPLAY:-}" ]]; then
    FREERDP="${pkgs.freerdp}/bin/wlfreerdp"
  fi

  # ── clean app name for the /app: and /wm-class fields ───────────────────
  # Winboat strips commas, periods, apostrophes and quotes from the name it
  # embeds in the /app: arg (the comma would break FreeRDP's field parser).
  CLEAN_NAME="$(printf '%s' "$APP_NAME" | sed -e 's/[,. '"'"'"]//g')"

  # ── build /app: arg ─────────────────────────────────────────────────────
  # FreeRDP 3.27 rejects cmd:"" (empty quoted string) with
  # "Invalid quoted argument". Omit cmd: entirely when Args is empty.
  APP_ARG="/app:program:''${APP_PATH},name:''${CLEAN_NAME}"
  if [[ -n "$APP_ARGS" ]]; then
    APP_ARG="''${APP_ARG},cmd:\"''${APP_ARGS}\""
  fi

  exec "$FREERDP" \
    "/u:''${WB_USER}" \
    "/p:''${WB_PASS}" \
    /v:127.0.0.1 \
    "/port:''${RDP_PORT}" \
    /cert:ignore \
    +clipboard \
    /sound:sys:pulse \
    /microphone:sys:pulse \
    /floatbar \
    /compression \
    -wallpaper \
    "/scale-desktop:''${SCALE}" \
    "/wm-class:winboat-''${CLEAN_NAME}" \
    "$APP_ARG"
''
