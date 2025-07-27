echo "=== System ==="
nix flake update
nixos-rebuild boot --upgrade-all
