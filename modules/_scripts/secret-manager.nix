{ pkgs }:

pkgs.writeShellScriptBin "secret-manager" ''
  set -euo pipefail

  # Helper function to get the appropriate folder name from type
  get_folder_name() {
    local type="$1"
    case "$type" in
      api-key) echo "api-keys" ;;
      age-key) echo "age-keys" ;;
      gpg-key) echo "gpg-keys" ;;
      ssh-key) echo "ssh-keys" ;;
      *) return 1 ;;
    esac
  }

  # Helper function to check Bitwarden login status
  check_bw_login() {
    if ! ${pkgs.bitwarden-cli}/bin/bw status &>/dev/null; then
      echo "Error: Bitwarden not logged in" >&2
      return 1
    fi
  }

  # Helper function to detect and use clipboard tool
  copy_to_clipboard() {
    local secret="$1"
    
    # Check for Wayland
    if [[ -n "''${WAYLAND_DISPLAY:-}" ]]; then
      if command -v wl-copy &>/dev/null; then
        echo -n "$secret" | wl-copy
        return 0
      fi
    fi
    
    # Check for X11
    if [[ -n "''${DISPLAY:-}" ]]; then
      if command -v xclip &>/dev/null; then
        echo -n "$secret" | xclip -selection clipboard
        return 0
      fi
      if command -v xsel &>/dev/null; then
        echo -n "$secret" | xsel --clipboard --input
        return 0
      fi
    fi
    
    # Try xclip as fallback
    if command -v xclip &>/dev/null; then
      echo -n "$secret" | xclip -selection clipboard
      return 0
    fi
    
    # Try wl-copy as fallback
    if command -v wl-copy &>/dev/null; then
      echo -n "$secret" | wl-copy
      return 0
    fi
    
    return 1
  }

  # Show help
  show_help() {
    cat <<'HELP'
secret-manager - Manage secrets with Bitwarden CLI

Usage:
  secret-manager store <type> <name>              Store a secret interactively
  secret-manager retrieve <type> <name> [--clipboard]  Retrieve a secret
  secret-manager help                             Show this help message

Types:
  api-key     API keys and credentials
  age-key     Age encryption keys
  gpg-key     GPG encryption keys
  ssh-key     SSH keys

Examples:
  secret-manager store api-key github-token
  secret-manager retrieve api-key github-token
  secret-manager retrieve api-key github-token --clipboard
  secret-manager store gpg-key my-gpg-key
  secret-manager retrieve gpg-key my-gpg-key --clipboard
  secret-manager store ssh-key my-server
  secret-manager retrieve ssh-key my-server --clipboard

HELP
  }

  # Store command
  store_secret() {
    local type="$1"
    local name="$2"
    
    # Validate type
    if ! get_folder_name "$type" &>/dev/null; then
      echo "Error: Invalid type. Use: api-key, age-key, gpg-key, ssh-key" >&2
      return 1
    fi
    
    # Check Bitwarden login
    if ! check_bw_login; then
      return 1
    fi
    
    local folder_name
    folder_name=$(get_folder_name "$type")
    
    # Check if folder exists, create if not
    local folder_id
    folder_id=$(${pkgs.bitwarden-cli}/bin/bw list folders --search "$folder_name" 2>/dev/null | ${pkgs.jq}/bin/jq -r '.[0].id // empty' || echo "")
    
    if [[ -z "$folder_id" ]]; then
      echo "Creating folder: $folder_name"
      folder_id=$(${pkgs.bitwarden-cli}/bin/bw folder create "$folder_name" | ${pkgs.jq}/bin/jq -r '.id')
      echo "✓ Created folder '$folder_name'"
    fi
    
    # Prompt for secret with silent input
    local secret
    read -s -p "Enter your $type: " secret
    echo  # newline after silent input
    
     # Create note item in Bitwarden
     local item_json
     item_json=$(${pkgs.jq}/bin/jq -n \
      --arg name "$name" \
      --arg type "note" \
      --arg folder_id "$folder_id" \
      --arg notes "$secret" \
      '{
        organizationId: null,
        collectionIds: [],
        name: $name,
        type: 2,
        notes: $notes,
        fields: [],
        login: null,
        secureNote: {
          type: 0
        },
        card: null,
        identity: null,
        folderId: $folder_id,
        favorite: false,
        edit: true
      }')
     
     ${pkgs.bitwarden-cli}/bin/bw create item "$item_json" > /dev/null
     echo "✓ Stored $type '$name' in Bitwarden"
  }

  # Retrieve command
  retrieve_secret() {
    local type="$1"
    local name="$2"
    local use_clipboard=false
    
    # Check for --clipboard flag
    if [[ ''${3:-} == "--clipboard" ]]; then
      use_clipboard=true
    fi
    
     # Validate type
     if ! get_folder_name "$type" &>/dev/null; then
       echo "Error: Invalid type. Use: api-key, age-key, gpg-key, ssh-key" >&2
       return 1
     fi
     
     # Check Bitwarden login
     if ! check_bw_login; then
       return 1
     fi
     
     local folder_name
     folder_name=$(get_folder_name "$type")
    
     # Get folder ID
     local folder_id
     folder_id=$(${pkgs.bitwarden-cli}/bin/bw list folders --search "$folder_name" 2>/dev/null | ${pkgs.jq}/bin/jq -r '.[0].id // empty' || echo "")
    
    if [[ -z "$folder_id" ]]; then
      echo "Error: $type '$name' not found" >&2
      return 13
    fi
    
     # Search for item by name in the folder
     local item
     item=$(${pkgs.bitwarden-cli}/bin/bw list items --folderid "$folder_id" --search "$name" 2>/dev/null | ${pkgs.jq}/bin/jq ".[] | select(.name == \"$name\")" || echo "")
    
    if [[ -z "$item" ]]; then
      echo "Error: $type '$name' not found" >&2
      return 13
    fi
    
     # Extract the note content
     local secret
     secret=$(echo "$item" | ${pkgs.jq}/bin/jq -r '.notes // empty')
    
    if [[ -z "$secret" ]]; then
      echo "Error: $type '$name' not found" >&2
      return 13
    fi
    
    # Handle clipboard or display
    if [[ "$use_clipboard" == true ]]; then
      if copy_to_clipboard "$secret"; then
        echo "✓ Copied $type '$name' to clipboard" >&2
      else
        echo "Error: No clipboard tool available" >&2
        echo "$secret"
      fi
    else
      echo "$secret"
    fi
  }

  # Main logic
  if [[ $# -lt 1 ]]; then
    show_help >&2
    exit 1
  fi

  case "''${1:-}" in
    store)
      if [[ $# -lt 3 ]]; then
        echo "Error: store requires <type> and <name>" >&2
        show_help >&2
        exit 1
      fi
      store_secret "$2" "$3"
      ;;
    retrieve)
      if [[ $# -lt 3 ]]; then
        echo "Error: retrieve requires <type> and <name>" >&2
        show_help >&2
        exit 1
      fi
      retrieve_secret "$2" "$3" "''${4:-}"
      ;;
    help)
      show_help
      ;;
    *)
      echo "Error: Unknown command '$1'" >&2
      show_help >&2
      exit 1
      ;;
  esac
''
