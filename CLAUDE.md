# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Dual-machine NixOS flake configuration for user `viv`, managing a `desktop` (NVIDIA GPU, VR) and `laptop` (LUKS-encrypted, Jupyter). Runs Niri (Wayland tiling WM) with Tokyo Night theme throughout.

## Common Commands

```bash
# Check configuration for errors
nix flake check
```

## Architecture

**Entry point**: `flake.nix` defines a `mkSystem` function that builds both hosts. Each host gets the same module set with `host` passed via `specialArgs` for conditional logic.

**Host-specific branching**: Throughout the config, `isDesktop = host == "desktop"` and `isLaptop = host == "laptop"` with `lib.mkIf` / `lib.optionals` control per-machine features. Hardware configs live in `hardware/{desktop,laptop}.nix`.

**Module layout**:
- `configuration.nix` — System-level: boot, networking, services, hardware, programs
- `home.nix` — User-level via Home Manager: shell, GUI apps, user packages
- `nvim.nix` — Neovim config via nixvim (LSP, treesitter, plugins)
- `niri.nix` — Window manager keybindings, layout, window rules
- `theme.nix` — Shared color palette and font, imported by other modules
- `waybar.nix` + `dotfiles/waybar.css` — Status bar config
- `fastfetch.nix` — System info display
- `it87-patch.nix` — Custom kernel module derivation (desktop hardware sensors)
- `cachix.nix` + `cachix/` — Binary cache configuration

**Key flake inputs**: nixpkgs (unstable), home-manager, nixvim, niri, zen-browser, fenix (Rust), serpentine + tree-sitter-serpentine, nix-flatpak.

## Conventions
- Home Manager is integrated at NixOS module level (not standalone)
- Theme colors/font come from `theme.nix` — use `import ./theme.nix` to stay consistent
- Shell is Fish; aliases and shell config are in `home.nix`
- Unfree packages are allowed (`nixpkgs.config.allowUnfree = true`)
- State version is `25.05`
- use inline package reference (`${pkgs.python3} ...`) etc instead of installing packages globally if possible.
- Use nix features to avoid magic numbers.
- Use nixos/home-manager settings over manual setups for supports programs.
