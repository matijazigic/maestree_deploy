#!/usr/bin/env bash
# Install everything the Maestree auth server box needs: Docker Engine + the
# Compose plugin. Run ONCE on a fresh server (Debian/Ubuntu and most distros the
# official Docker script supports). Safe to re-run — it's idempotent.
#
#   ./install.sh
#
# After it finishes, log out and back in (or `newgrp docker`) so your user picks
# up the `docker` group, then run ./start.sh.
set -euo pipefail

# Re-exec with sudo if not root (the install needs it).
if [ "$(id -u)" -ne 0 ]; then
  echo "→ Not root; re-running with sudo…"
  exec sudo -E bash "$0" "$@"
fi

# The user who invoked sudo (so we add the right account to the docker group).
TARGET_USER="${SUDO_USER:-root}"

if command -v docker >/dev/null 2>&1; then
  echo "✓ Docker already installed: $(docker --version)"
else
  echo "→ Installing Docker Engine via the official convenience script…"
  curl -fsSL https://get.docker.com | sh
fi

# Compose v2 ships as a plugin; verify it's present.
if docker compose version >/dev/null 2>&1; then
  echo "✓ Docker Compose plugin present: $(docker compose version --short)"
else
  echo "→ Installing the Docker Compose plugin…"
  apt-get update && apt-get install -y docker-compose-plugin
fi

echo "→ Enabling and starting the Docker service…"
systemctl enable --now docker

# Let the non-root user run docker without sudo.
if [ "$TARGET_USER" != "root" ]; then
  echo "→ Adding '$TARGET_USER' to the 'docker' group…"
  usermod -aG docker "$TARGET_USER"
  echo "  (log out/in or run 'newgrp docker' for this to take effect)"
fi

echo
echo "✓ Done. Next:"
echo "    1. cp .env.template .env   &&  edit .env (secrets + AUTH_DOMAIN)"
echo "    2. ./start.sh"
