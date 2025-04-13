#!/bin/bash

# List of commands to display in Wofi
commands=(
  "List Files: ls -l"
  "Show Processes: ps aux"
  "Current Date: date"
  "Open Firefox: firefox"
  "Shutdown: systemctl poweroff"
)

# Extract the command names for display
command_names=$(printf "%s\n" "${commands[@]}" | cut -d ':' -f 1)

# Show Wofi and get user selection
selected=$(echo "$command_names" | wofi --show dmenu --prompt "Run Command")

# Find and execute the corresponding command
if [[ -n "$selected" ]]; then
  command_to_run=$(echo "${commands[@]}" | grep "$selected" | cut -d ':' -f 2- | xargs)
  eval "$command_to_run"
fi
