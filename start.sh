#!/usr/bin/env bash
# Start the Maestree auth server stack (Postgres + Go auth + Caddy) — one command.
# Pulls the latest prebuilt auth image from GHCR and brings everything up.
#
#   ./start.sh
#
# Prereqs: ./install.sh has been run, and .env exists (see below).
set -euo pipefail

# Always operate from this script's directory, so it works from any cwd.
cd "$(dirname "$(readlink -f "$0")")"

# 1. Config. The compose file requires .env (secrets + AUTH_DOMAIN). If it's
#    missing, seed it from the template and stop so you can fill it in.
if [ ! -f .env ]; then
  echo "→ No .env found — creating one from .env.template."
  cp .env.template .env
  echo "✗ Edit .env now (set POSTGRES_PASSWORD, AUTH_DOMAIN, AUTH_ED25519_SEED),"
  echo "  then re-run ./start.sh."
  exit 1
fi

# 2. The auth image is private on GHCR. If the pull fails for auth, it's almost
#    always a missing login — hint at it instead of a cryptic compose error.
echo "→ Pulling images…"
if ! docker compose pull; then
  echo
  echo "✗ Pull failed. If it's the auth image, log in to GHCR first:"
  echo "    echo \$GHCR_PAT | docker login ghcr.io -u <github-user> --password-stdin"
  echo "  (PAT needs read:packages — or make the GHCR package public.)"
  exit 1
fi

# 3. Bring the stack up in the background.
echo "→ Starting stack…"
docker compose up -d

echo
docker compose ps
echo
echo "✓ Up. Watch Caddy fetch its TLS cert with:"
echo "    docker compose logs -f caddy"
echo "  Then verify:  curl https://\$(grep -E '^AUTH_DOMAIN=' .env | cut -d= -f2)/healthz"
