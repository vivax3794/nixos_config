echo "=== NIX ==="
echo "--- cleaning store ---"
sudo nix-collect-garbage --delete-old
echo "--- optimizing store ---"
sudo nix-store --optimize

echo "=== DOCKER ==="
docker stop --all
docker rm --all
docker system prune --all --volumes --force

echo "=== LOGS ==="
sudo journalctl --vacuum-size=100M

echo "====== CLEANING FILES ====="
sudo rm -rfv ~/coding/**/target
rm -rfv ~/.cargo/registry/cache
rm -rfv ~/.cargo/registry/src
rm -rfv ~/.cargo/git

rm -rfv ~/.cache
rm -rfv /tmp

sudo find /var/lib/systemd/coredump -name "*.xz" -delete
sudo systemd-tmpfiles --clean
rm -rfv ~/.local/share/Trash/*
