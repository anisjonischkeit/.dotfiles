#!/usr/bin/env bash

export STOW_FOLDERS="zsh,nvim"

# Disable "Displays have seperate Spaces" for Aerospace
# https://nikitabobko.github.io/AeroSpace/guide#a-note-on-displays-have-separate-spaces
echo "Disabling 'Displays have seperate Spaces'"
defaults write com.apple.spaces spans-displays -bool true && killall SystemUIServer

for folder in $(echo $STOW_FOLDERS | sed "s/,/ /g"); do
  echo "stow personal-mac/$folder"
  stow -t ../../ -R $folder
done

../homebrew/install.sh
