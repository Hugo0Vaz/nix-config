{ pkgs
, adminPassFile
, userPassFile
, baseUrl ? "http://127.0.0.1:5984"
, db ? "obsidian"
, user ? "obsidian"
, adminUser ? "admin"
}:

pkgs.writeShellScriptBin "couchdb-obsidian-livesync-bootstrap" ''
  set -euo pipefail

  BASE_URL="${baseUrl}"
  DB="${db}"
  LS_USER="${user}"
  ADMIN_USER="${adminUser}"
  ADMIN_PASS_FILE="${adminPassFile}"
  USER_PASS_FILE="${userPassFile}"

  usage() {
    cat <<'EOF'
Usage: couchdb-obsidian-livesync-bootstrap [options]

Bootstraps a CouchDB database + user for Obsidian LiveSync.

Options:
  --base-url URL           CouchDB base URL (default: http://127.0.0.1:5984)
  --db NAME                Database name (default: obsidian)
  --user NAME              LiveSync user name (default: obsidian)
  --admin-user NAME        Admin user name (default: admin)
  --admin-pass-file PATH   Admin password file (default: Nix-provided)
  --user-pass-file PATH    LiveSync password file (default: Nix-provided)
  -h, --help               Show this help

Notes:
  - Run as root if secrets are mode 0400.
  - Safe to re-run (idempotent).
EOF
  }

  while [ "$#" -gt 0 ]; do
    case "$1" in
      --base-url) BASE_URL="$2"; shift 2 ;;
      --db) DB="$2"; shift 2 ;;
      --user) LS_USER="$2"; shift 2 ;;
      --admin-user) ADMIN_USER="$2"; shift 2 ;;
      --admin-pass-file) ADMIN_PASS_FILE="$2"; shift 2 ;;
      --user-pass-file) USER_PASS_FILE="$2"; shift 2 ;;
      -h|--help) usage; exit 0 ;;
      *)
        echo "Unknown argument: $1" >&2
        usage >&2
        exit 2
        ;;
    esac
  done

  if [ ! -r "$ADMIN_PASS_FILE" ]; then
    echo "Admin password file not readable: $ADMIN_PASS_FILE" >&2
    exit 1
  fi
  if [ ! -r "$USER_PASS_FILE" ]; then
    echo "LiveSync password file not readable: $USER_PASS_FILE" >&2
    exit 1
  fi

  ADMIN_PASS="$(tr -d '\n' < "$ADMIN_PASS_FILE")"
  USER_PASS="$(tr -d '\n' < "$USER_PASS_FILE")"

  if [ -z "$ADMIN_PASS" ]; then
    echo "Admin password is empty (file: $ADMIN_PASS_FILE)" >&2
    exit 1
  fi
  if [ -z "$USER_PASS" ]; then
    echo "LiveSync password is empty (file: $USER_PASS_FILE)" >&2
    exit 1
  fi

  auth_curl() {
    # curl wrapper that fails on network errors, but lets us inspect HTTP codes.
    ${pkgs.curl}/bin/curl -sS -u "$ADMIN_USER:$ADMIN_PASS" "$@"
  }

  put_no_body() {
    local path="$1"
    auth_curl -o /dev/null -w "%{http_code}" -X PUT "$BASE_URL$path"
  }

  get_code() {
    local path="$1"
    auth_curl -o /dev/null -w "%{http_code}" "$BASE_URL$path"
  }

  put_json() {
    local path="$1"
    local json="$2"
    auth_curl -o /dev/null -w "%{http_code}" -X PUT \
      -H "Content-Type: application/json" \
      --data-binary "$json" \
      "$BASE_URL$path"
  }

  echo "Using CouchDB: $BASE_URL"
  echo "DB: $DB"
  echo "User: $LS_USER"

  code="$(put_no_body "/_users")"
  case "$code" in
    201|202) echo "Created system db: _users" ;;
    412) echo "System db exists: _users" ;;
    *) echo "Failed to create _users (HTTP $code)" >&2; exit 1 ;;
  esac

  code="$(put_no_body "/$DB")"
  case "$code" in
    201|202) echo "Created db: $DB" ;;
    412) echo "Db exists: $DB" ;;
    *) echo "Failed to create db $DB (HTTP $code)" >&2; exit 1 ;;
  esac

  user_doc_id="org.couchdb.user:$LS_USER"
  code="$(get_code "/_users/$user_doc_id")"
  case "$code" in
    200) echo "User exists: $LS_USER" ;;
    404)
      code="$(put_json "/_users/$user_doc_id" \
        "{\"name\":\"$LS_USER\",\"password\":\"$USER_PASS\",\"roles\":[],\"type\":\"user\"}")"
      case "$code" in
        201|202) echo "Created user: $LS_USER" ;;
        409) echo "User already exists (race): $LS_USER" ;;
        *) echo "Failed to create user $LS_USER (HTTP $code)" >&2; exit 1 ;;
      esac
      ;;
    *) echo "Failed to check user $LS_USER (HTTP $code)" >&2; exit 1 ;;
  esac

  code="$(put_json "/$DB/_security" \
    "{\"admins\":{\"names\":[],\"roles\":[]},\"members\":{\"names\":[\"$LS_USER\"],\"roles\":[]}}")"
  case "$code" in
    200|201|202) echo "Applied security to db: $DB" ;;
    *) echo "Failed to set _security for $DB (HTTP $code)" >&2; exit 1 ;;
  esac

  echo "Done. Configure LiveSync with: url=$BASE_URL db=$DB user=$LS_USER"
''
