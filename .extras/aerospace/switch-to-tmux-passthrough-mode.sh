read -n 1 -s -r -p "Press any key: " key

KITTY_BUNDLE_ID="net.kovidgoyal.kitty" # !!! REPLACE with your Kitty's actual bundle ID !!!
KITTY_PROCESS_NAME="kitty"             # !!! REPLACE with Kitty's actual process name (case-sensitive) !!!
FRONTMOST_APP_BUNDLE_ID=$(osascript -e 'tell application "System Events" to get bundle identifier of first process whose frontmost is true')

if [ "$FRONTMOST_APP_BUNDLE_ID" != "$KITTY_BUNDLE_ID" ]; then
  echo "DEBUG: Switching to tmux_passthrough_mode"
  aerospace mode tmux_passthrough_mode
else
  osascript ./tmux-press-key.scpt "$key"
  #   osascript -e '
  # on run argv
  #     set targetChar to item 1 of argv as text
  #
  #     tell application "System Events"
  #         keystroke "a" using {control down}
  #         delay 0.05                         -- Small pause for tmux to register prefix
  #         keystroke targetChar               -- Sends the subsequent character (e.g., "2")
  #     end tell
  # end run
  #   ' "$key"
  #send-keys.applescript "$key" "$KITTY_PROCESS_NAME" "$KITTY_BUNDLE_ID"
  echo "DEBUG: triggering ctrl-b key"

  echo "Key pressed: $key"
fi
