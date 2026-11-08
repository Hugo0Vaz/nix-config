{ pkgs }:
pkgs.writeShellScriptBin "screenshot-edit" ''
  # Select a screen region, save it, copy it to the clipboard and open it in Pinta.
  set -euo pipefail

  dir="''${XDG_PICTURES_DIR:-$HOME/Pictures}/Screenshots"
  mkdir -p "$dir"
  file="$dir/Screenshot from $(date '+%Y-%m-%d %H-%M-%S').png"

  # slurp exits non-zero when the selection is cancelled (Esc).
  region="$(${pkgs.slurp}/bin/slurp)" || exit 0

  ${pkgs.grim}/bin/grim -g "$region" "$file"
  ${pkgs.wl-clipboard}/bin/wl-copy < "$file"
  exec ${pkgs.pinta}/bin/pinta "$file"
''
