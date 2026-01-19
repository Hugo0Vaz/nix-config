{ pkgs }:

pkgs.writeShellScriptBin "powerMenu" ''
  # Power menu options
  options="Shutdown\nReboot\nLogout\nLock"
  
  # Show wofi menu and get selection
  selected=$(echo -e "$options" | ${pkgs.wofi}/bin/wofi --dmenu --prompt "Power Menu" --width 200 --height 200)
  
  # Execute the selected option
  case $selected in
    "Shutdown")
      systemctl poweroff
      ;;
    "Reboot")
      systemctl reboot
      ;;
    "Logout")
      hyprctl dispatch exit
      ;;
    "Lock")
      hyprlock
      ;;
  esac
''
