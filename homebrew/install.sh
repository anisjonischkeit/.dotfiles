#!/usr/bin/env bash

if ! command -v brew >/dev/null 2>&1; then
  echo "Installing Homebrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  echo "Installing Homebrew Packages"
  brew install stow zk neovim
  brew install --cask nikitabobko/tap/aerospace
else
  echo "Homebrew already installed, skipping brew and package installation"
fi
