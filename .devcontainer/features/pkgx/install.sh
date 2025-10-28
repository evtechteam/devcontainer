#!/bin/bash
set -e
set +h  # Disable command hashing to reduce memory usage

# Optimize memory usage
unset HISTFILE  # Disable history file
export BASH_ENV=""  # Don't load bash configs

echo "============================================"
echo "Installing packages via pkgx/pkgm..."
echo "============================================"

# Debug information
echo ""
echo "=== Debug Information ==="
echo "Architecture: $(uname -m)"
echo "Bash version: $BASH_VERSION"
echo "Bash path: $(which bash)"
echo "Memory info:"
free -h 2>/dev/null || echo "free command not available"
echo "========================="
echo ""

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

# Show pkgx information
echo ""
echo "pkgx path: $(which pkgx 2>/dev/null || echo 'not found')"
echo "pkgm path: $(which pkgm 2>/dev/null || echo 'not found')"

# CRITICAL: Prevent pkgx from installing its bundled bash (which crashes on ARM64)
# Set environment variables BEFORE running pkgm commands
export PKGX_BASH_PATH=/bin/bash
export SHELL=/bin/bash

if command -v pkgm &> /dev/null; then
  echo "pkgm version: $(SHELL=/bin/bash pkgm --version 2>&1 || echo 'unknown')"
fi

# Apply workaround IMMEDIATELY after pkgm initializes (which may install bash)
if [ -d "$HOME/.pkgx/gnu.org/bash" ]; then
  echo "Detected pkgx bundled bash - applying ARM64 crash workaround"

  # Create wrapper script to redirect broken bash to system bash
  PKGX_BASH_DIR="$HOME/.pkgx/gnu.org/bash"
  for bash_bin in "$PKGX_BASH_DIR"/*/bin/bash; do
    if [ -f "$bash_bin" ] && [ ! -L "$bash_bin" ]; then
      echo "  Replacing $bash_bin with system bash wrapper"
      mv "$bash_bin" "${bash_bin}.broken" 2>/dev/null || true
      cat > "$bash_bin" << 'WRAPPER_EOF'
#!/bin/bash
# Wrapper: redirects to system bash to avoid ARM64 hash table crash
exec /bin/bash "$@"
WRAPPER_EOF
      chmod +x "$bash_bin"
    fi
  done

  # Remove from PATH
  export PATH=$(echo "$PATH" | tr ':' '\n' | grep -v '\.pkgx/gnu\.org/bash' | tr '\n' ':' | sed 's/:$//')
  echo "  ✓ Workaround applied successfully"
fi

echo "Active bash: $(which bash)"
echo ""

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
      echo ""
      echo ">>> Installing package: $pkg"
      echo "Memory before install:"
      free -h 2>/dev/null || echo "N/A"

      # Run in subshell with minimal environment for better cleanup
      if (
        set -x  # Show commands being run
        unset HISTFILE
        export SHELL=/bin/bash
        export BASH_ENV=""
        export PKGX_BASH_PATH=/bin/bash
        # Ensure pkgx bundled bash is not in PATH
        export PATH=$(echo "$PATH" | tr ':' '\n' | grep -v '\.pkgx/gnu\.org/bash' | tr '\n' ':' | sed 's/:$//')
        echo "Using bash: $(which bash)"
        echo "PATH: $PATH"
        pkgm install "$pkg"
      ); then
        echo "✓ Successfully installed $pkg"
      else
        echo "✗ Failed to install $pkg (exit code: $?)"
      fi

      echo "Memory after install:"
      free -h 2>/dev/null || echo "N/A"

      # Small delay to allow cleanup
      sleep 2
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
      # Run in subshell with minimal environment
      (
        unset HISTFILE
        export SHELL=/bin/bash
        export BASH_ENV=""
        pkgm shim "$pkg"
      ) || echo "Warning: Failed to shim $pkg"
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
