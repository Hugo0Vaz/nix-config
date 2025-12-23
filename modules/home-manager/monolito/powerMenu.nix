{ pkgs }:

pkgs.writeShellScriptBin "powerMenu" ''
  # Define power options with emojis
  options="🔴 Shutdown\n🔄 Reboot\n💤 Suspend\n🚪 Logout\n🔒 Lock"
 
  # Show menu with wofi and get selection
  selected=$(echo -e "$options" | ${pkgs.wofi}/bin/wofi --dmenu --prompt "⚡ Power Menu" --width 350 --height 280)

  # Execute based on selection
  case "$selected" in
    "🔴 Shutdown")
      systemctl poweroff
      ;;
    "🔄 Reboot")
      systemctl reboot
      ;;
    "💤 Suspend")
      systemctl suspend
      ;;
    "🚪 Logout")
      hyprctl dispatch exit
      ;;
    "🔒 Lock")
      ${pkgs.hyprlock}/bin/hyprlock
      ;;
    *)
      exit 0
      ;;
  esac
''
