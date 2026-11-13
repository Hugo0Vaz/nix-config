{ pkgs }:

pkgs.writeShellScriptBin "cheatsheet" ''
  # Fuzzy-browse Markdown cheatsheets kept in the repo.
  #   cheatsheet                 pick a sheet, then fuzzy-search its lines
  #   cheatsheet <name>          open one sheet directly
  #   cheatsheet --add <name> "tip"   append a line to a sheet
  #   cheatsheet --edit [name]   edit a sheet in $EDITOR
  # Enter copies the first `inline code` of the line (or the whole line).
  set -euo pipefail

  export PATH="${pkgs.lib.makeBinPath [ pkgs.fzf pkgs.bat pkgs.wl-clipboard pkgs.coreutils pkgs.gnugrep pkgs.gnused ]}:$PATH"

  dir="''${CHEATSHEET_DIR:-$HOME/.local/share/cheatsheets}"
  mkdir -p "$dir"

  pick_sheet() {
    find -L "$dir" -maxdepth 1 -name '*.md' -printf '%f\n' | sed 's/\.md$//' | sort \
      | fzf --prompt='sheet> ' --preview "bat --color=always --style=plain --language=markdown '$dir/{}.md'"
  }

  case "''${1:-}" in
    --add)
      [ $# -ge 3 ] || { echo "usage: cheatsheet --add <name> \"tip\"" >&2; exit 1; }
      printf '%s\n' "$3" >> "$dir/$2.md"
      echo "added to $dir/$2.md"
      exit 0
      ;;
    --edit)
      name="''${2:-$(pick_sheet)}" || exit 0
      exec "''${EDITOR:-nvim}" "$dir/$name.md"
      ;;
  esac

  name="''${1:-$(pick_sheet)}" || exit 0
  [ -n "$name" ] || exit 0
  file="$dir/$name.md"
  [ -f "$file" ] || { echo "no such sheet: $name" >&2; exit 1; }

  line="$(grep -v '^[[:space:]]*$' "$file" | fzf --prompt="$name> " --no-sort --reverse)" || exit 0
  [ -n "$line" ] || exit 0

  code="$(printf '%s' "$line" | grep -o '`[^`]*`' | head -n1 | tr -d '`' || true)"
  printf '%s' "''${code:-$line}" | wl-copy
''
