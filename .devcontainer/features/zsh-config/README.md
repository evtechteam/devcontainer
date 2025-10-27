# Zsh Configuration Feature

This devcontainer feature configures zsh with history settings, auto-completion, and custom aliases.

## Usage

```json
{
  "features": {
    "./features/zsh-config": {
      "historySize": 10000,
      "enableCompletion": true,
      "aliases": ["ls=lsd", "ll=lsd -la", "la=lsd -a", "lt=lsd --tree", "lg=lazygit", "cat=bat"]
    }
  }
}
```

## Options

| Option | Type | Description | Default |
|--------|------|-------------|---------|
| `historySize` | number | Number of commands to keep in history | `10000` |
| `enableCompletion` | boolean | Enable zsh auto-completion | `true` |
| `aliases` | array | Array of aliases (format: `["name=command", "name2=command2"]`) | `["ls=lsd", "ll=lsd -la", ...]` |

## What It Does

1. **History Configuration**:
   - Sets `HISTFILE` to `~/.zsh_history`
   - Configures `HISTSIZE` and `SAVEHIST` to specified size
   - Enables history sharing across sessions
   - Prevents duplicate entries

2. **Auto-Completion**:
   - Loads and initializes zsh completion system
   - Can be disabled via `enableCompletion: false`

3. **Aliases**:
   - Parses comma-separated alias definitions
   - Format: `name=command,name2=command2`
   - Example: `ls=lsd,ll=lsd -la,cat=bat`

## Examples

### Minimal Configuration

```json
{
  "features": {
    "./features/zsh-config": {}
  }
}
```

Uses all default values.

### Custom History Size

```json
{
  "features": {
    "./features/zsh-config": {
      "historySize": 50000
    }
  }
}
```

### Custom Aliases

```json
{
  "features": {
    "./features/zsh-config": {
      "aliases": ["g=git", "d=docker", "k=kubectl", "tf=terraform"]
    }
  }
}
```

### Disable Completion

```json
{
  "features": {
    "./features/zsh-config": {
      "enableCompletion": false
    }
  }
}
```

## Alias Format

Aliases are specified as an array of strings, each in the format `name=command`:

```json
["name=command", "name2=command with args", "name3=another command"]
```

**Examples**:
- `"ls=lsd"` → `alias ls='lsd'`
- `"ll=lsd -la"` → `alias ll='lsd -la'`
- `"g=git"` → `alias g='git'`
- `"k=kubectl"` → `alias k='kubectl'`

## Integration

This feature automatically appends configuration to `~/.zshrc` with a clear header:

```bash
# ==========================================
# Zsh Configuration (via zsh-config feature)
# ==========================================
```

This makes it easy to identify and modify feature-added configuration.
