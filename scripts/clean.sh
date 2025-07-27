echo "=== NIX ==="
echo "--- cleaning store ---"
nix-collect-garbage --delete-old
echo "--- optimizing store ---"
nix-store --optimize

