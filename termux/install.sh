#!/usr/bin/env bash

export STOW_FOLDERS="bin,bash"

for folder in $(echo $STOW_FOLDERS | sed "s/,/ /g"); do
	echo "stow $folder"
	stow -t ../../ --no-folding -R $folder
done

find ./copy -type d | sed "s/^\.\/copy\///g" | xargs -I{} mkdir -p "../../{}"
find ./copy -type f | sed "s/^\.\/copy\///g" | xargs -I{} cp "copy/{}" "../../{}"
