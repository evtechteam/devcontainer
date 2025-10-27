# Starship Configuration Feature

This devcontainer feature configures [Starship](https://starship.rs) prompt with a preset theme and automatically initializes it in zsh.

**Note:** This feature requires the upstream [starship.rs](https://github.com/devcontainer-community/devcontainer-features/tree/main/src/starship.rs) feature to be installed first.

## Usage

```json
{
  "features": {
    "ghcr.io/devcontainer-community/devcontainer-features/starship.rs:1": {},
    "./features/starship-config": {
      "preset": "catppuccin-powerline"
    }
  }
}
```

## Options

| Option | Type | Description | Default |
|--------|------|-------------|---------|
| `preset` | string | Starship preset theme to use | `catppuccin-powerline` |

## Available Presets

- `bracketed-segments` - Bracketed segments style
- `catppuccin-powerline` - Catppuccin powerline theme
- `gruvbox-rainbow` - Gruvbox rainbow colors
- `jetpack` - Jetpack inspired theme
- `nerd-font-symbols` - Uses Nerd Font symbols
- `no-nerd-font` - No Nerd Fonts required
- `no-runtime-versions` - Hides runtime versions
- `pastel-powerline` - Pastel colored powerline
- `plain-text-symbols` - Plain text symbols only
- `pure-preset` - Pure prompt inspired
- `tokyo-night` - Tokyo Night theme

See all available presets at: https://starship.rs/presets/

## What It Does

1. Downloads the specified preset configuration to `~/.config/starship.toml`
2. Adds `eval "$(starship init zsh)"` to `~/.zshrc`
3. Prevents duplicate initialization

## How It Works

1. The upstream `starship.rs` feature installs the Starship binary
2. This feature configures it with a preset and initializes it
3. The `installsAfter` directive ensures this runs after Starship is installed

## Example

```json
{
  "features": {
    "ghcr.io/devcontainer-community/devcontainer-features/starship.rs:1": {},
    "./features/starship-config": {
      "preset": "tokyo-night"
    }
  }
}
```

This will:
1. Install Starship (via upstream feature)
2. Configure it with the Tokyo Night preset
3. Initialize it in zsh automatically
