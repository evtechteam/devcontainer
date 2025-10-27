#!/bin/bash
set -e

echo "============================================"
echo "Installing packages via pkgx/pkgm..."
echo "============================================"

# Validate _CONTAINER_USER_HOME is set
if [ -z "$_CONTAINER_USER_HOME" ]; then
  echo "Error: _CONTAINER_USER_HOME is not set"
  exit 1
fi

echo "Using home directory: $_CONTAINER_USER_HOME"

# Ensure PATH is set for this session (both system and user paths)
export PATH="$_CONTAINER_USER_HOME/.local/bin:/usr/local/bin:$PATH"

# Install pkgx (upstream feature should have already installed it)
# This is a fallback in case it's not available
if ! command -v pkgx &> /dev/null; then
  echo "Warning: pkgx not found, installing..."
  curl https://pkgx.sh | sh
else
  echo "✓ pkgx already installed"
fi

# Process packages for full installation
# Note: Arrays from devcontainer.json are passed as comma-separated strings
if [ -n "$PACKAGES" ]; then
  echo ""
  echo "Installing packages (full install): $PACKAGES"
  echo "-----------------------------------"

  # Convert comma-separated string to array
  IFS=',' read -ra PKG_ARRAY <<< "$PACKAGES"

  for pkg in "${PKG_ARRAY[@]}"; do
    # Trim whitespace
    pkg=$(echo "$pkg" | xargs)

    if [ -n "$pkg" ]; then
      echo "Installing $pkg..."
      pkgm install "$pkg" || echo "Warning: Failed to install $pkg"
    fi
  done

  echo "✓ Package installations complete"
fi

# Process packages for shimming
# Note: Arrays from devcontainer.json are passed as comma-separated strings
if [ -n "$SHIMS" ]; then
  echo ""
  echo "Creating shims for: $SHIMS"
  echo "-----------------------------------"

  # Convert comma-separated string to array
  IFS=',' read -ra SHIM_ARRAY <<< "$SHIMS"

  for pkg in "${SHIM_ARRAY[@]}"; do
    # Trim whitespace
    pkg=$(echo "$pkg" | xargs)

    if [ -n "$pkg" ]; then
      echo "Shimming $pkg..."
      pkgm shim "$pkg" || echo "Warning: Failed to shim $pkg"
    fi
  done

  echo "✓ Shim creation complete"
fi

# Add pkgx to PATH in .zshrc
echo ""
echo "Adding pkgx to PATH in .zshrc..."
if ! grep -q 'export PATH="$HOME/.local/bin:$PATH"' "$_CONTAINER_USER_HOME/.zshrc" 2>/dev/null; then
  cat >> "$_CONTAINER_USER_HOME/.zshrc" << 'PATH_EOF'

# Add pkgx to PATH
export PATH="$HOME/.local/bin:$PATH"
PATH_EOF
  echo "✓ pkgx PATH added to .zshrc"
else
  echo "✓ pkgx PATH already in .zshrc"
fi

echo ""
echo "==================================="
echo "pkgx feature installation complete!"
echo "==================================="
