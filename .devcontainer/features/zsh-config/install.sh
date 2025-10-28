#!/bin/bash
set -e

echo "============================================"
echo "Configuring zsh..."
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

# Use options with defaults
HISTORY_SIZE="${HISTORYSIZE:-10000}"
ENABLE_COMPLETION="${ENABLECOMPLETION:-true}"
# Note: Arrays from devcontainer.json are passed as comma-separated strings
ALIASES="${ALIASES:-ls=lsd,ll=lsd -la,la=lsd -a,lt=lsd --tree,lg=lazygit,cat=bat}"

echo "History size: $HISTORY_SIZE"
echo "Enable completion: $ENABLE_COMPLETION"

# Start building zshrc content
cat >> "$_CONTAINER_USER_HOME/.zshrc" << 'ZSHRC_START'

# ==========================================
# Zsh Configuration (via zsh-config feature)
# ==========================================

ZSHRC_START

# History configuration
echo "Configuring history..."
cat >> "$_CONTAINER_USER_HOME/.zshrc" << HISTORY_EOF

# History configuration
HISTFILE="$_CONTAINER_USER_HOME/.zsh_history"
HISTSIZE=${HISTORY_SIZE}
SAVEHIST=${HISTORY_SIZE}
setopt SHARE_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS
HISTORY_EOF

echo "✓ History configured (size: $HISTORY_SIZE)"

# Auto-completion
if [ "$ENABLE_COMPLETION" = "true" ]; then
  echo "Configuring auto-completion..."
  cat >> "$_CONTAINER_USER_HOME/.zshrc" << 'COMPLETION_EOF'

# Enable auto-completion
autoload -Uz compinit && compinit
COMPLETION_EOF
  echo "✓ Auto-completion enabled"
fi

# Aliases
if [ -n "$ALIASES" ]; then
  echo ""
  echo "Configuring aliases..."
  echo "" >> "$_CONTAINER_USER_HOME/.zshrc"
  echo "# Aliases" >> "$_CONTAINER_USER_HOME/.zshrc"

  # Parse comma-separated aliases
  IFS=',' read -ra ALIAS_ARRAY <<< "$ALIASES"

  for alias_def in "${ALIAS_ARRAY[@]}"; do
    # Trim whitespace
    alias_def=$(echo "$alias_def" | xargs)

    if [ -n "$alias_def" ]; then
      # Split on = to get name and command
      name=$(echo "$alias_def" | cut -d'=' -f1)
      command=$(echo "$alias_def" | cut -d'=' -f2-)

      if [ -n "$name" ] && [ -n "$command" ]; then
        echo "alias $name='$command'" >> "$_CONTAINER_USER_HOME/.zshrc"
        echo "  ✓ $name -> $command"
      fi
    fi
  done

  echo "✓ Aliases configured"
fi

echo ""
echo "============================================"
echo "Zsh configuration complete!"
echo "============================================"
