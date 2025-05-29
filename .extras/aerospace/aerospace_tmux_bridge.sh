#!/bin/bash

echo "DEBUG: Script initiated with argument: '$1'"

# === CONFIGURATION: MUST BE SET BY USER ===
# 1. Find Kitty's Bundle ID: Run 'aerospace list-apps' while Kitty is open.
#    E.g., 'net.kovidgoyal.kitty' or 'com.github.kovidgoyal.kitty'.
# 2. Find Kitty's Process Name: Usually 'kitty' or 'Kitty'. Check Activity Monitor.
KITTY_BUNDLE_ID="net.kovidgoyal.kitty" # !!! REPLACE with your Kitty's actual bundle ID !!!
KITTY_PROCESS_NAME="kitty"             # !!! REPLACE with Kitty's actual process name (case-sensitive) !!!
# === END CONFIGURATION ===

THE_KEY="$1"

# if [ -z "$THE_KEY" ]; then
#   echo "DEBUG: ERROR - No key argument provided to script. Exiting."
#   if command -v aerospace &>/dev/null; then
#     aerospace mode main
#   fi
#   exit 1
# fi
# echo "DEBUG: Key to use: '$THE_KEY'"

aerospace mode main
echo "DEBUG: Getting current frontmost application..."
FRONTMOST_APP_BUNDLE_ID=$(osascript ~/.dotfiles/.extras/aerospace/get_first_process.scpt)
echo "DEBUG: Current frontmost app Bundle ID: '$FRONTMOST_APP_BUNDLE_ID'"
echo "DEBUG: Target Kitty Bundle ID: '$KITTY_BUNDLE_ID'"

if [ "$FRONTMOST_APP_BUNDLE_ID" != "$KITTY_BUNDLE_ID" ]; then
  echo "DEBUG: Current app is NOT Kitty. Attempting 'aerospace focus --app-id \"$KITTY_BUNDLE_ID\"'..."
  aerospace focus --app-id "$KITTY_BUNDLE_ID"
  # Test if 'aerospace focus' produces output (it might be the source of '2')
  # For now, let it print if it does.
  echo "DEBUG: 'aerospace focus' command finished. Pausing for 0.6s..."
  #  sleep 0.1 # Increased pause for focus to take effect
  echo "DEBUG: Pause finished."
else
  echo "DEBUG: Current app IS Kitty. No 'aerospace focus' needed."
fi

echo "DEBUG: Executing AppleScript..."
osascript_output=$(osascript ~/.dotfiles/.extras/aerospace/send_tmux_key.scpt "$THE_KEY" "$KITTY_PROCESS_NAME" "$KITTY_BUNDLE_ID")
echo "DEBUG: AppleScript execution finished by shell. Output (if any): $osascript_output"

echo "DEBUG: Executing 'aerospace mode main'..."
# Test if 'aerospace mode main' produces output (it might be the source of '2')
# For now, let it print if it does.
echo "DEBUG: 'aerospace mode main' finished. Script effectively ended."
# The final '2%' will appear after this if something prints '2' without a newline
#
