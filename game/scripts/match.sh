#!/bin/bash
# game/scripts/match.sh — run fh-game-match against the live club DB from the
# host (G4.43). The DB password comes from the running game container's
# environment (never printed); the DB is reached on the host's published port.
#   game/scripts/match.sh [matches] [minutes] [home:concept=demand,...|-] [away:...|-]
set -euo pipefail
cd "$(dirname "$0")/../.."
POSTGRES_PASSWORD="$(sudo -n podman exec footballhome_game printenv POSTGRES_PASSWORD)"
export POSTGRES_PASSWORD POSTGRES_HOST=localhost
exec ./game/build/fh-game-match "$@"
