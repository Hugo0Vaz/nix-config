{ pkgs }:

pkgs.writeShellScriptBin "rebuildSystem" ''
    set -e

    # Colors for output
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    NC='\033[0m' # No Color

    # Function to print colored output
    print_info() { echo -e "''${GREEN}[INFO]''${NC} $1"; }
    print_warn() { echo -e "''${YELLOW}[WARN]''${NC} $1"; }
    print_error() { echo -e "''${RED}[ERROR]''${NC} $1"; }

    # Validate we're in a flake directory
    if [[ ! -e "$PWD/flake.nix" ]]; then
        print_error "No flake.nix found in $PWD"
        exit 1
    fi

    # Detect current hostname for flake target
    HOSTNAME=$(hostname)

    # Try to find matching configuration in flake
    FLAKE_CONFIGS=$(nix flake show --json 2>/dev/null | ${pkgs.jq}/bin/jq -r '.nixosConfigurations | keys[]' 2>/dev/null || echo "")

    if [[ -z "$FLAKE_CONFIGS" ]]; then
        print_error "No NixOS configurations found in flake"
        exit 1
    fi

    # Try exact hostname match first
    if echo "$FLAKE_CONFIGS" | grep -q "^$HOSTNAME\$"; then
        FLAKE_TARGET="$PWD#$HOSTNAME"
        print_info "Found exact hostname match: $HOSTNAME"
    # Try hostname as prefix (e.g., "nixos" matches "nixos-workstation")
    elif MATCHED_CONFIG=$(echo "$FLAKE_CONFIGS" | grep "^$HOSTNAME-" | head -1); then
        FLAKE_TARGET="$PWD#$MATCHED_CONFIG"
        print_info "Found hostname-prefixed match: $MATCHED_CONFIG"
    # If only one configuration exists, use it
    elif [[ $(echo "$FLAKE_CONFIGS" | wc -l) -eq 1 ]]; then
        SINGLE_CONFIG=$(echo "$FLAKE_CONFIGS" | head -1)
        FLAKE_TARGET="$PWD#$SINGLE_CONFIG"
        print_info "Using only available configuration: $SINGLE_CONFIG"
    else
        print_error "Could not determine which configuration to use for hostname '$HOSTNAME'"
        print_info "Available configurations:"
        echo "$FLAKE_CONFIGS" | sed 's/^/  - /'
        exit 1
    fi

    echo "Rebuilding NixOS configuration..." | ${pkgs.cowsay}/bin/cowsay
    print_info "Flake directory: $PWD"
    print_info "Target configuration: $FLAKE_TARGET"
    
    read -p "Continue with rebuild? [y/N]: " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "Rebuild cancelled"
        exit 0
    fi

    # Handle dirty git state
    if [[ -n "$(${pkgs.git}/bin/git status --porcelain)" ]]; then
        print_warn "Git working tree has uncommitted changes"
        ${pkgs.git}/bin/git status --short
        read -p "Stage all changes and continue? [y/N]: " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            ${pkgs.git}/bin/git add .
            print_info "Changes staged"
        else
            read -p "Continue without staging? [y/N]: " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                print_info "Rebuild cancelled"
                exit 0
            fi
        fi
    fi

    # Ensure sudo credentials are cached
    sudo -v

    # Perform the rebuild with error handling
    print_info "Starting NixOS rebuild..."
    
    # Use a more robust method to capture exit status
    if sudo nixos-rebuild switch --flake "$FLAKE_TARGET" 2>&1 | ${pkgs.nix-output-monitor}/bin/nom; then
        REBUILD_STATUS=0
    else
        REBUILD_STATUS=$?
    fi
    
    if [[ $REBUILD_STATUS -eq 0 ]]; then
        print_info "NixOS rebuild completed successfully"
        
        # Auto-commit if there are staged changes
        if [[ -n "$(${pkgs.git}/bin/git diff --cached --name-only)" ]]; then
            gen=$(nixos-rebuild list-generations | grep current | head -1)
            if [[ -n "$gen" ]]; then
                ${pkgs.git}/bin/git commit -m "nixos: $gen"
                print_info "Configuration committed: $gen"
            else
                ${pkgs.git}/bin/git commit -m "nixos: rebuild $(date '+%Y-%m-%d %H:%M')"
                print_info "Configuration committed with timestamp"
            fi
        else
            print_info "No staged changes to commit"
        fi
    else
        print_error "NixOS rebuild failed"
        exit 1
    fi
''
