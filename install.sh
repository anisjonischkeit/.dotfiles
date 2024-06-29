#!/usr/bin/env bash
# I am using zsh instead of bash. I was having some troubles using bash with
# arrays.  Didn't want to investigate, so I just did zsh

export DOTFILES=$HOME/.dotfiles
export STOW_FOLDERS="bin,zsh,tmux"

pushd $DOTFILES
for folder in $(echo $STOW_FOLDERS | sed "s/,/ /g"); do
	echo "stow $folder"
	stow --no-folding -R $folder
done
popd

if [ ${TERMUX_VERSION+x} ]; then
	pushd ./termux/; \
        ./install.sh; \
	popd;
fi
