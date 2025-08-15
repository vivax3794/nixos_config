echo "=== System ==="
nix flake update
sudo nixos-rebuild boot --upgrade-all
