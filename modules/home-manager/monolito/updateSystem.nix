{ pkgs }:

pkgs.writeShellScriptBin "updateSystem" ''
    set -e

    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    PURPLE='\033[0;35m'
    NC='\033[0m' # No Color

    print_info() { echo -e "''${GREEN}[INFO]''${NC} $1"; }
    print_warn() { echo -e "''${YELLOW}[WARN]''${NC} $1"; }
    print_error() { echo -e "''${RED}[ERROR]''${NC} $1"; }
    print_update() { echo -e "''${PURPLE}[UPDATE]''${NC} $1"; }

    if [[ ! -e "$PWD/flake.nix" ]]; then
        print_error "No flake.nix found in $PWD"
        exit 1
    fi

    if [[ -f "$PWD/flake.lock" ]]; then
        print_info "Current flake.lock found, will show updates"
        HAS_LOCK=true
    else
        print_warn "No flake.lock found, will create new one"
        HAS_LOCK=false
    fi

    echo "Updating Nix Flake Inputs..." | ${pkgs.cowsay}/bin/cowsay
    print_info "Flake directory: $PWD"

    print_info "Current flake inputs:"
    nix flake metadata --json 2>/dev/null | ${pkgs.jq}/bin/jq -r '.locks.nodes.root.inputs | to_entries[] | "  \(.key): \(.value)"' || echo "  Unable to read current inputs"

    echo
    read -p "Continue with flake update? [y/N]: " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "Update cancelled"
        exit 0
    fi

    # Parse command line arguments for specific input updates
    SPECIFIC_INPUTS=()
    while [[ $# -gt 0 ]]; do
        case $1 in
            --input|-i)
                SPECIFIC_INPUTS+=("$2")
                shift 2
                ;;
            --help|-h)
                echo "Usage: updateSystem [--input|-i INPUT_NAME]..."
                echo "  --input, -i INPUT_NAME    Update only specific input(s)"
                echo "  --help, -h               Show this help"
                exit 0
                ;;
            *)
                print_warn "Unknown option: $1"
                shift
                ;;
        esac
    done

    # Backup current flake.lock if it exists
    if [[ "$HAS_LOCK" == "true" ]]; then
        cp flake.lock flake.lock.backup
        print_info "Backed up current flake.lock to flake.lock.backup"
    fi

    # Perform the update
    print_update "Starting flake update..."

    if [[ ''${#SPECIFIC_INPUTS[@]} -gt 0 ]]; then
        print_info "Updating specific inputs: ''${SPECIFIC_INPUTS[*]}"
        for input in "''${SPECIFIC_INPUTS[@]}"; do
            print_update "Updating input: $input"
            if ! nix flake lock --update-input "$input"; then
                print_error "Failed to update input: $input"
                if [[ "$HAS_LOCK" == "true" ]]; then
                    print_info "Restoring backup..."
                    mv flake.lock.backup flake.lock
                fi
                exit 1
            fi
        done
    else
        print_info "Updating all inputs..."
        if ! nix flake update; then
            print_error "Flake update failed"
            if [[ "$HAS_LOCK" == "true" ]]; then
                print_info "Restoring backup..."
                mv flake.lock.backup flake.lock
            fi
            exit 1
        fi
    fi

    print_info "Flake update completed successfully"

    if [[ "$HAS_LOCK" == "true" ]]; then
        print_info "Changes made to flake.lock:"
        if ${pkgs.git}/bin/git diff --no-index --color=always flake.lock.backup flake.lock 2>/dev/null || true; then
            echo
        else
            print_info "No changes detected in flake.lock"
        fi
    fi

    if ${pkgs.git}/bin/git rev-parse --git-dir >/dev/null 2>&1; then
        if [[ -n "$(${pkgs.git}/bin/git status --porcelain flake.lock 2>/dev/null)" ]]; then
            echo
            read -p "Commit flake.lock changes? [Y/n]: " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Nn]$ ]]; then
                print_info "Changes not committed"
            else
                ${pkgs.git}/bin/git add flake.lock
                if [[ ''${#SPECIFIC_INPUTS[@]} -gt 0 ]]; then
                    commit_msg="flake: update inputs ''${SPECIFIC_INPUTS[*]}"
                else
                    commit_msg="flake: update all inputs"
                fi
                ${pkgs.git}/bin/git commit -m "$commit_msg"
                print_info "Committed flake.lock changes: $commit_msg"
            fi
        else
            print_info "No changes to commit"
        fi
    else
        print_warn "Not in a git repository - changes not committed"
    fi

    if [[ "$HAS_LOCK" == "true" && -f flake.lock.backup ]]; then
        rm flake.lock.backup
        print_info "Cleaned up backup file"
    fi

    print_info "Updated flake inputs:"
    nix flake metadata --json 2>/dev/null | ${pkgs.jq}/bin/jq -r '.locks.nodes.root.inputs | to_entries[] | "  \(.key): \(.value)"' || echo "  Unable to read updated inputs"

    print_info "Flake update process completed!"
    print_warn "Consider running 'rebuildSystem' or 'rebuildHome' to apply updates"
''
