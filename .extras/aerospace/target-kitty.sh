#!/bin/bash

# === CONFIGURATION: MUST BE SET BY USER ===
# 1. Find Kitty's Bundle ID: Run 'aerospace list-apps' while Kitty is open.
#    E.g., 'net.kovidgoyal.kitty' or 'com.github.kovidgoyal.kitty'.
# 2. Find Kitty's Process Name: Usually 'kitty' or 'Kitty'. Check Activity Monitor.
KITTY_BUNDLE_ID="net.kovidgoyal.kitty" # !!! REPLACE with your Kitty's actual bundle ID !!!

FRONTMOST_APP_BUNDLE_ID=$(osascript ~/.dotfiles/.extras/aerospace/get_first_process.scpt)

if [ "$FRONTMOST_APP_BUNDLE_ID" != "$KITTY_BUNDLE_ID" ]; then
  open /Applications/kitty.app
fi
