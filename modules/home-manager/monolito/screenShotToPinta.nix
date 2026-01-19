{ pkgs }:

pkgs.writeShellScriptBin "screenShotToPinta" ''
  # Create Screenshots directory if it doesn't exist
  mkdir -p ~/Pictures/Screenshots

  # Generate filename with timestamp
  FILENAME=~/Pictures/Screenshots/$(date +'%Y-%m-%d_%H-%M-%S.png')

  # Take screenshot based on argument
  case "$1" in
    "area")
      ${pkgs.grim}/bin/grim -g "$(${pkgs.slurp}/bin/slurp)" "$FILENAME"
      ;;
    "full")
      ${pkgs.grim}/bin/grim "$FILENAME"
      ;;
    *)
      echo "Usage: $0 {area|full}"
      exit 1
      ;;
  esac

  # Check if screenshot was taken successfully
  if [ -f "$FILENAME" ]; then
    # Open in Pinta
    ${pkgs.pinta}/bin/pinta "$FILENAME" &
  else
    ${pkgs.libnotify}/bin/notify-send "Screenshot Failed" "Could not capture screenshot"
  fi
''
