{ pkgs }:

pkgs.writeShellScriptBin "secret-manager" ''
  set -euo pipefail

  # Helper function to get the appropriate folder name from type
  get_folder_name() {
    local type="$1"
    case "$type" in
      api-key) echo "secret-manager/api-keys" ;;
      age-key) echo "secret-manager/age-keys" ;;
      gpg-key) echo "secret-manager/gpg-keys" ;;
      ssh-key) echo "secret-manager/ssh-keys" ;;
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

  # Helper function to get folder ID by exact folder name
  get_folder_id_by_name() {
    local folder_name="$1"
    ${pkgs.bitwarden-cli}/bin/bw list folders 2>/dev/null | ${pkgs.jq}/bin/jq -r ".[] | select(.name == \"$folder_name\") | .id" || echo ""
  }

  # Helper function to get all folder IDs (optimized for list command)
  get_all_folder_ids() {
    ${pkgs.bitwarden-cli}/bin/bw list folders 2>/dev/null | ${pkgs.jq}/bin/jq -r '.[] | "\(.name)|\(.id)"' || echo ""
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
  secret-manager list [type] [--debug]            List secrets (optionally filtered by type)
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
  secret-manager list
  secret-manager list api-key
  secret-manager list --debug
  secret-manager list api-key --debug
  secret-manager store gpg-key my-gpg-key
  secret-manager retrieve gpg-key my-gpg-key --clipboard
  secret-manager store ssh-key my-server
  secret-manager retrieve ssh-key my-server --clipboard

Debug Mode:
  The --debug flag (used with 'list' command) shows folder lookup details,
  folder IDs, and item counts for troubleshooting Bitwarden connectivity issues.

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
     
     # Ensure parent folder exists
     local parent_folder_id
     parent_folder_id=$(get_folder_id_by_name "secret-manager")
     
     if [[ -z "$parent_folder_id" ]]; then
       echo "Creating parent folder: secret-manager"
       parent_folder_id=$(${pkgs.bitwarden-cli}/bin/bw folder create "secret-manager" 2>/dev/null | ${pkgs.jq}/bin/jq -r '.id' || echo "")
       if [[ -z "$parent_folder_id" ]]; then
         echo "Error: Failed to create parent folder 'secret-manager'" >&2
         return 1
       fi
       echo "✓ Created parent folder 'secret-manager'"
     fi
     
     # Check if type-specific folder exists, create if not
     local folder_id
     folder_id=$(get_folder_id_by_name "$folder_name")
     
     if [[ -z "$folder_id" ]]; then
       echo "Creating folder: $folder_name"
       folder_id=$(${pkgs.bitwarden-cli}/bin/bw folder create "$folder_name" 2>/dev/null | ${pkgs.jq}/bin/jq -r '.id' || echo "")
       if [[ -z "$folder_id" ]]; then
         echo "Error: Failed to create folder '$folder_name'" >&2
         return 1
       fi
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
     
      # Get folder ID using exact matching
      local folder_id
      folder_id=$(get_folder_id_by_name "$folder_name")
     
     if [[ -z "$folder_id" ]]; then
       echo "Error: Folder '$folder_name' not found." >&2
       echo "Use: secret-manager store $type <name>" >&2
       echo "Or run: bw sync --force (if you added folders in the web vault)" >&2
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

   # List command
   list_secrets() {
     local type_filter="''${1:-}"
     local debug_mode=false
     
     # Check for --debug flag
     if [[ "''${2:-}" == "--debug" ]] || [[ "$type_filter" == "--debug" ]]; then
       debug_mode=true
       # If first arg was --debug, shift it out
       if [[ "$type_filter" == "--debug" ]]; then
         type_filter=""
       fi
     fi
     
     # Check Bitwarden login
     if ! check_bw_login; then
       return 1
     fi
     
     # Fetch all folders once (optimized - single API call)
     local all_folders
     all_folders=$(get_all_folder_ids)
     
     if [[ $debug_mode == true ]]; then
       echo "[DEBUG] Fetched all folders from Bitwarden" >&2
     fi
     
     # If type is specified, validate and list only that type
     if [[ -n "$type_filter" ]]; then
       if ! get_folder_name "$type_filter" &>/dev/null; then
         echo "Error: Invalid type. Use: api-key, age-key, gpg-key, ssh-key" >&2
         return 1
       fi
       
       local folder_name
       folder_name=$(get_folder_name "$type_filter")
       
       # Find folder ID for this type
       local folder_id
       folder_id=$(echo "$all_folders" | ${pkgs.jq}/bin/jq -r "select(. | startswith(\"$folder_name|\")) | split(\"|\")[1]" || echo "")
       
        if [[ $debug_mode == true ]]; then
          echo "[DEBUG] Looking for folder: $folder_name" >&2
          if [[ -z "$folder_id" ]]; then
            echo "[DEBUG] Folder ID: (not found)" >&2
          else
            echo "[DEBUG] Folder ID: $folder_id" >&2
          fi
        fi
       
       if [[ -z "$folder_id" ]]; then
         echo "No secrets found for type '$type_filter'"
         if [[ $debug_mode == true ]]; then
           echo "[DEBUG] Available folders:" >&2
           echo "$all_folders" | ${pkgs.jq}/bin/jq -r 'split("|")[0]' | sed 's/^/[DEBUG]   /' >&2
         fi
         return 0
       fi
       
       # Get items for this folder
       local items
       items=$(${pkgs.bitwarden-cli}/bin/bw list items --folderid "$folder_id" 2>/dev/null | ${pkgs.jq}/bin/jq -r '.[].name // empty' | sort || echo "")
       
       if [[ $debug_mode == true ]]; then
         local item_count
         item_count=$(echo "$items" | grep -c . || echo 0)
         echo "[DEBUG] Items in folder: $item_count" >&2
       fi
       
       if [[ -z "$items" ]]; then
         echo "$type_filter: (no secrets)"
         return 0
       fi
       
       echo "$type_filter:"
       echo "$items" | sed 's/^/  - /'
     else
       # List secrets from all types (single folder fetch, cached)
       local all_types=("api-key" "age-key" "gpg-key" "ssh-key")
       local found_any=false
       local first_section=true
       
       for type in "''${all_types[@]}"; do
         local folder_name
         folder_name=$(get_folder_name "$type")
         
         # Find folder ID from cached results
         local folder_id
         folder_id=$(echo "$all_folders" | ${pkgs.jq}/bin/jq -r "select(. | startswith(\"$folder_name|\")) | split(\"|\")[1]" || echo "")
         
         if [[ -z "$folder_id" ]]; then
           if [[ $debug_mode == true ]]; then
             echo "[DEBUG] Folder not found: $folder_name" >&2
           fi
           continue
         fi
         
         # Get items for this folder
         local items
         items=$(${pkgs.bitwarden-cli}/bin/bw list items --folderid "$folder_id" 2>/dev/null | ${pkgs.jq}/bin/jq -r '.[].name // empty' | sort || echo "")
         
         if [[ -n "$items" ]]; then
           found_any=true
           
           # Add blank line between sections (but not before first)
           if [[ "$first_section" == "false" ]]; then
             echo
           fi
           first_section=false
           
           echo "$type:"
           echo "$items" | sed 's/^/  - /'
           
           if [[ $debug_mode == true ]]; then
             local item_count
             item_count=$(echo "$items" | grep -c . || echo 0)
             echo "[DEBUG] $type: $item_count secrets" >&2
           fi
         fi
       done
       
       if [[ "$found_any" == "false" ]]; then
         echo "No secrets found"
         if [[ $debug_mode == true ]]; then
           echo "[DEBUG] No folders with secrets found" >&2
           echo "[DEBUG] Available folders:" >&2
           echo "$all_folders" | ${pkgs.jq}/bin/jq -r 'split("|")[0]' | sed 's/^/[DEBUG]   /' >&2
         fi
         return 0
       fi
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
     list)
       list_secrets "''${2:-}"
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
