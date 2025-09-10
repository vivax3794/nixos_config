echo "=== NIX ==="
echo "--- cleaning store ---"
sudo nix-collect-garbage --delete-old
echo "--- optimizing store ---"
sudo nix-store --optimize

echo "=== DOCKER ==="
docker stop $(docker ps -a -q -f 'name=dagger-engine') || true
docker rm $(docker ps -a -q -f 'name=dagger-engine') || true
docker system prune --all --volumes --force

echo "=== LOGS ==="
sudo journalctl --vacuum-size=100M

echo "====== CLEANING FILES ====="
sudo rm -rfv ~/coding/**/target
rm -rfv ~/.cache
rm -rfv ~/.cargo/registry/cache
rm -rfv ~/.cargo/registry/src
rm -rfv ~/.cargo/git
sudo find /var/lib/systemd/coredump -name "*.xz" -delete
sudo systemd-tmpfiles --clean
rm -rfv ~/.local/share/Trash/*
