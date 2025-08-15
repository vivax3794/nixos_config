echo "=== NIX ==="
echo "--- cleaning store ---"
sudo nix-collect-garbage --delete-old
echo "--- optimizing store ---"
sudo nix-store --optimize

