jj new -m "UPDATE"
nix flake update
sudo nixos-rebuild boot --upgrade-all
