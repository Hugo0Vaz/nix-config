{ pkgs }:

pkgs.writeShellScriptBin "rebuildHome" ''
    set -e

    # Colors for output
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    NC='\033[0m' # No Color

    # Function to print colored output
    print_info() { echo -e "''${GREEN}[INFO]''${NC} $1"; }
    print_warn() { echo -e "''${YELLOW}[WARN]''${NC} $1"; }
    print_error() { echo -e "''${RED}[ERROR]''${NC} $1"; }
    print_blue() { echo -e "''${BLUE}[HM]''${NC} $1"; }

    # Validate we're in a flake directory
    if [[ ! -e "$PWD/flake.nix" ]]; then
        print_error "No flake.nix found in $PWD"
        exit 1
    fi

    # Detect if running on NixOS
    IS_NIXOS=false
    if [[ -f /etc/os-release ]] && grep -q "ID=nixos" /etc/os-release; then
        IS_NIXOS=true
    fi

    # Determine Home Manager configuration
    USERNAME=$(whoami)
    HOSTNAME=$(hostname)

    if [[ "$IS_NIXOS" == "true" ]]; then
        print_warn "Running on NixOS - Home Manager is likely integrated with system config"
        print_warn "Consider using rebuildSystem instead for full system rebuild"
        read -p "Continue with Home Manager only rebuild? [y/N]: " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_info "Rebuild cancelled - use rebuildSystem for integrated configs"
            exit 0
        fi
    fi

    # Try to find appropriate Home Manager configuration
    FLAKE_TARGETS=()

    # Check common naming patterns
    POSSIBLE_CONFIGS=(
        "$USERNAME-$HOSTNAME"
        "$USERNAME-$(echo $HOSTNAME | cut -d'.' -f1)"
        "$USERNAME"
        "$HOSTNAME"
        "$(echo $HOSTNAME | cut -d'.' -f1)"
    )

    # Check which configurations exist in the flake
    print_info "Checking available Home Manager configurations..."

    for config in "''${POSSIBLE_CONFIGS[@]}"; do
        if nix flake show --json 2>/dev/null | ${pkgs.jq}/bin/jq -e ".homeConfigurations.\"$config\"" >/dev/null 2>&1; then
            FLAKE_TARGETS+=("$config")
            print_blue "Found configuration: $config"
        fi
    done

    # If no configs found, show available ones
    if [[ ''${#FLAKE_TARGETS[@]} -eq 0 ]]; then
        print_warn "No matching Home Manager configurations found"
        print_info "Available configurations:"
        if nix flake show --json 2>/dev/null | ${pkgs.jq}/bin/jq -r '.homeConfigurations | keys[]' 2>/dev/null; then
            echo
            read -p "Enter configuration name manually: " MANUAL_CONFIG
            if [[ -n "$MANUAL_CONFIG" ]]; then
                FLAKE_TARGETS+=("$MANUAL_CONFIG")
            else
                print_error "No configuration specified"
                exit 1
            fi
        else
            print_error "No Home Manager configurations found in flake"
            exit 1
        fi
    fi

    # Select target if multiple found
    SELECTED_TARGET="''${FLAKE_TARGETS[0]}"
    if [[ ''${#FLAKE_TARGETS[@]} -gt 1 ]]; then
        print_info "Multiple configurations found:"
        for i in "''${!FLAKE_TARGETS[@]}"; do
            echo "  $((i+1)). ''${FLAKE_TARGETS[$i]}"
        done
        read -p "Select configuration [1]: " selection
        if [[ -n "$selection" && "$selection" =~ ^[0-9]+$ && "$selection" -le ''${#FLAKE_TARGETS[@]} ]]; then
            SELECTED_TARGET="''${FLAKE_TARGETS[$((selection-1))]}"
        fi
    fi

    FLAKE_TARGET="$PWD#$SELECTED_TARGET"

    echo "Rebuilding Home Manager configuration..." | ${pkgs.cowsay}/bin/cowsay
    print_info "Flake directory: $PWD"
    print_info "Target configuration: $FLAKE_TARGET"
    print_info "Username: $USERNAME"
    print_info "Hostname: $HOSTNAME"

    read -p "Continue with Home Manager rebuild? [y/N]: " -n 1 -r
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

    # Perform the rebuild with error handling
    print_info "Starting Home Manager rebuild..."
    
    # Use a more robust method to capture exit status
    if ${pkgs.home-manager}/bin/home-manager switch --flake "$FLAKE_TARGET" 2>&1 | ${pkgs.nix-output-monitor}/bin/nom; then
        REBUILD_STATUS=0
    else
        REBUILD_STATUS=$?
    fi
    
    if [[ $REBUILD_STATUS -eq 0 ]]; then
        print_info "Home Manager rebuild completed successfully"

        # Auto-commit if there are staged changes
        if [[ -n "$(${pkgs.git}/bin/git diff --cached --name-only)" ]]; then
            # Get Home Manager generation info
            gen=$(${pkgs.home-manager}/bin/home-manager generations | head -2 | tail -1 | awk '{print "generation " $5 " - " $1}')
            if [[ -n "$gen" ]]; then
                ${pkgs.git}/bin/git commit -m "home-manager: $gen ($SELECTED_TARGET)"
                print_info "Configuration committed: $gen"
            else
                ${pkgs.git}/bin/git commit -m "home-manager: rebuild $SELECTED_TARGET $(date '+%Y-%m-%d %H:%M')"
                print_info "Configuration committed with timestamp"
            fi
        else
            print_info "No staged changes to commit"
        fi

        # Show generation info
        print_blue "Current Home Manager generation:"
        ${pkgs.home-manager}/bin/home-manager generations | head -1

    else
        print_error "Home Manager rebuild failed"
        exit 1
    fi
''
