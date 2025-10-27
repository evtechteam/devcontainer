# pkgx Feature

This devcontainer feature allows you to specify packages to install or shim using [pkgx](https://pkgx.sh) package manager.

## Usage

```json
{
  "features": {
    "ghcr.io/bascodes/devcontainer-features/pkgx:1": {},
    "./features/pkgx": {
      "packages": ["lsd", "bat", "nano"],
      "shims": ["lazygit", "yq", "jq", "htop", "tree", "sops"]
    }
  }
}
```

## Options

| Option | Type | Description | Default |
|--------|------|-------------|---------|
| `packages` | array | Packages to fully install to `~/.local` (frequently used tools) | `[]` |
| `shims` | array | Packages to shim (lightweight wrappers, download on-demand) | `[]` |

## What's the difference?

### Full Install (`packages`)
- Package is downloaded and installed to `~/.local/bin`
- Always available, no download delay
- Use for frequently-used tools
- Examples: `lsd`, `bat`, `nano`

### Shim (`shims`)
- Lightweight wrapper created
- Actual package downloads on first use
- Saves space and build time
- Use for occasionally-used tools
- Examples: `lazygit`, `yq`, `jq`, `htop`, `tree`, `sops`

## How It Works

1. Installs the pkgx package manager
2. This feature then uses pkgx to install specified packages or create shims
3. The `installsAfter` directive ensures this runs after pkgx is available

## Example

```json
{
  "features": {
    "./features/pkgx": {
      "packages": ["ripgrep", "fd"],
      "shims": ["gh", "docker"]
    }
  }
}
```

This will:
1. Install pkgx package manager
2. Fully install `ripgrep` and `fd`
3. Create shims for `gh` and `docker`
