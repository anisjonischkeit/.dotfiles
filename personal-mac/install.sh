#!/usr/bin/env bash

export STOW_FOLDERS="zsh,aerospace,nvim"

for folder in $(echo $STOW_FOLDERS | sed "s/,/ /g"); do
  echo "stow personal-mac/$folder"
  stow -t ../../ -R $folder
done
