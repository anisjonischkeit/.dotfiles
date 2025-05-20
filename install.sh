#!/usr/bin/env bash
# I am using zsh instead of bash. I was having some troubles using bash with
# arrays.  Didn't want to investigate, so I just did zsh

export DOTFILES=$HOME/.dotfiles
export STOW_FOLDERS="bin,zsh,tmux,nvim"

source ~/.zshenv-local

if [ -z "$device_name" ] && [ "${TERMUX_VERSION+x}" ]; then
  export device_name="termux"
fi

pushd $DOTFILES
for folder in $(echo $STOW_FOLDERS | sed "s/,/ /g"); do
  echo "stow $folder"
  stow --no-folding -R $folder
done

if [ ${device_name+x} ]; then
  pushd "./$device_name/"
  ./install.sh
  popd
fi

popd
