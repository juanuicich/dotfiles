#!/bin/bash

set -euo pipefail

echo "Starting bootstrap process..."

# 1. Install Nix
if ! command -v nix >/dev/null 2>&1; then
  echo "Installing Nix..."
  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
  . "$HOME/.nix-profile/etc/profile.d/nix.sh"
else
  echo "Nix is already installed."
fi

# 2. Clone dotfiles repository
DOTFILES_REPO="https://github.com/juanuicich/dotfiles.git"
DOTFILES_DIR="$HOME/.dotfiles"
if [ ! -d "$DOTFILES_DIR" ]; then
  echo "Cloning dotfiles repository..."
  git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
else
  echo "Dotfiles repository already cloned."
fi

cd "$DOTFILES_DIR"

# 3. Check if HOSTNAME is set
if [ -z "${HOSTNAME:-}" ]; then
  echo "HOSTNAME environment variable is not set."
  read -rp "Please enter a hostname for this machine: " entered_hostname

  # Set the hostname on macOS
  echo "Setting hostname to '$entered_hostname'..."
  sudo scutil --set HostName "$entered_hostname"
  sudo scutil --set LocalHostName "$entered_hostname"
  sudo scutil --set ComputerName "$entered_hostname"

  # Set the HOSTNAME environment variable
  export HOSTNAME="$entered_hostname"
  echo "HOSTNAME environment variable set to '$entered_hostname'."
fi

# 4. Install nix-darwin
if [ ! -d "/nix/var/nix/profiles/system" ]; then
  echo "Installing nix-darwin..."
  nix build .#darwinConfigurations.$(hostname -s).system --extra-experimental-features nix-command --extra-experimental-features flakes
  ./result/sw/bin/darwin-rebuild switch --flake .
else
  echo "nix-darwin is already installed."
fi

# 5. Apply configurations
echo "Applying Nix configurations..."
darwin-rebuild switch --flake "$DOTFILES_DIR"

echo "Bootstrap process complete!"
