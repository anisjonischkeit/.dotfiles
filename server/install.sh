#!/usr/bin/env bash

export STOW_FOLDERS="zsh,nvim"

for folder in $(echo $STOW_FOLDERS | sed "s/,/ /g"); do
	echo "stow $folder"
	stow -t ../../ -R $folder
done
