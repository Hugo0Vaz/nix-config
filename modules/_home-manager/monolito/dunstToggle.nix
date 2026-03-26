{ pkgs }:

pkgs.writeShellScriptBin "dunst-toggle" ''
  # If argument is "toggle", toggle the notification state
  if [[ "$1" == "toggle" ]]; then
    ${pkgs.dunst}/bin/dunstctl set-paused toggle
  fi

  # Output current state for waybar
  if ${pkgs.dunst}/bin/dunstctl is-paused | grep -q "true"; then
    echo '{"text": "󰪑", "tooltip": "Notifications disabled", "class": "disabled"}'
  else
    echo '{"text": "󰅸", "tooltip": "Notifications enabled", "class": "enabled"}'
  fi
''
