#!/usr/bin/env bash

export STOW_FOLDERS="zsh,aerospace"
export OPTIONAL_STOW_FOLDERS="nvim"

for folder in $(echo $STOW_FOLDERS | sed "s/,/ /g"); do
	echo "stow origin-mac/$folder"
	stow -t ../../ -R $folder
done

for folder in $(echo $OPTIONAL_STOW_FOLDERS | sed "s/,/ /g"); do
	pushd "../optional/"
	echo "stow optional/$folder"
	stow -t ../../ -R $folder
	popd
done
