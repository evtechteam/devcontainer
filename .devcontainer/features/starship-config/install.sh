#!/bin/bash
set -e

echo "============================================"
echo "Configuring Starship prompt..."
echo "============================================"

# Calculate home directory if not provided
if [ -z "$_CONTAINER_USER_HOME" ]; then
  if [ -n "$_REMOTE_USER" ]; then
    if [ "$_REMOTE_USER" = "root" ]; then
      _CONTAINER_USER_HOME="/root"
    else
      _CONTAINER_USER_HOME="/home/${_REMOTE_USER}"
    fi
  else
    echo "Error: Neither _CONTAINER_USER_HOME nor _REMOTE_USER is set"
    exit 1
  fi
fi

echo "Using home directory: $_CONTAINER_USER_HOME"

# Use preset option, default to catppuccin-powerline
PRESET="${PRESET:-catppuccin-powerline}"

echo "Installing Starship preset: $PRESET"

# Create config directory
mkdir -p "$_CONTAINER_USER_HOME/.config"

# Download the preset configuration
echo "Downloading preset from starship.rs..."
if wget -q -O "$_CONTAINER_USER_HOME/.config/starship.toml" "https://starship.rs/presets/toml/${PRESET}.toml"; then
  echo "✓ Starship preset '$PRESET' installed successfully"
else
  echo "⚠ Failed to download preset, using default configuration"
fi

# Add starship init to .zshrc
echo ""
echo "Adding Starship initialization to .zshrc..."

# Check if already initialized to avoid duplicates
if ! grep -q "starship init zsh" "$_CONTAINER_USER_HOME/.zshrc" 2>/dev/null; then
  cat >> "$_CONTAINER_USER_HOME/.zshrc" << 'STARSHIP_EOF'

# Initialize Starship prompt
eval "$(starship init zsh)"
STARSHIP_EOF
  echo "✓ Starship init added to .zshrc"
else
  echo "✓ Starship already initialized in .zshrc"
fi

echo ""
echo "============================================"
echo "Starship configuration complete!"
echo "Preset: $PRESET"
echo "============================================"
