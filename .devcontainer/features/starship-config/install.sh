#!/bin/bash
set -e

echo "============================================"
echo "Configuring Starship prompt..."
echo "============================================"

# Validate _CONTAINER_USER_HOME is set
if [ -z "$_CONTAINER_USER_HOME" ]; then
  echo "Error: _CONTAINER_USER_HOME is not set"
  exit 1
fi

echo "Using home directory: $_CONTAINER_USER_HOME"

# Use preset option, default to catppuccin-powerline
PRESET="${PRESET:-catppuccin-powerline}"

echo "Installing Starship preset: $PRESET"

# Create config directory
mkdir -p "$_CONTAINER_USER_HOME/.config"

# Download the preset configuration
echo "Downloading preset from starship.rs..."
wget -q -O "$_CONTAINER_USER_HOME/.config/starship.toml" "https://starship.rs/presets/toml/${PRESET}.toml"

if [ $? -eq 0 ]; then
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
