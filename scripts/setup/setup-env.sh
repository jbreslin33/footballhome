#!/bin/bash
# scripts/setup/setup-env.sh — env file template + Docker Hub login
set -e
source "$(dirname "$0")/_lib.sh"
REPO_ROOT="$(setup_repo_root)"
cd "$REPO_ROOT"

if [ ! -f env ]; then
  print_status "Creating env from env.example..."
  cp env.example env
  chmod 600 env
  print_success "env file created from env.example"
else
  print_success "env file already exists"
fi

source ./env 2>/dev/null || true

# If LeagueApps key material exists, ensure PEM is available for JWT signing.
if [ -n "${LEAGUEAPPS_API_PRIVATE_KEY:-}" ]; then
  P12_FILE="config/${LEAGUEAPPS_API_PRIVATE_KEY}.p12"
  PEM_FILE="config/${LEAGUEAPPS_API_PRIVATE_KEY}.pem"
  if [ -f "$P12_FILE" ]; then
    if [ ! -f "$PEM_FILE" ] || [ "$P12_FILE" -nt "$PEM_FILE" ]; then
      print_status "Generating LeagueApps PEM from $(basename "$P12_FILE")..."
      if openssl pkcs12 -in "$P12_FILE" -nodes -passin pass:notasecret -out "$PEM_FILE" >/dev/null 2>&1; then
        chmod 600 "$PEM_FILE"
        print_success "LeagueApps PEM ready: $(basename "$PEM_FILE")"
      else
        print_warning "Failed to build LeagueApps PEM from $(basename "$P12_FILE")"
      fi
    else
      print_success "LeagueApps PEM already up to date"
    fi
  else
    print_warning "LeagueApps P12 not found: $P12_FILE"
  fi
fi

# Docker Hub login
if LOGIN_USER="$(run_podman login --get-login docker.io 2>/dev/null)"; then
  print_success "Already logged in to Docker Hub as: $LOGIN_USER"
else
  source ./env 2>/dev/null || true
  if [ -n "$DOCKER_HUB_USERNAME" ] && [ -n "$DOCKER_HUB_TOKEN" ]; then
    print_status "Logging in to Docker Hub from env file..."
    if echo "$DOCKER_HUB_TOKEN" | run_podman login docker.io -u "$DOCKER_HUB_USERNAME" --password-stdin; then
      print_success "Logged in to Docker Hub"
    else
      print_warning "Docker Hub login failed — check env credentials"
    fi
  else
    print_warning "No Docker Hub credentials in env (optional, raises pull rate limit)"
  fi
fi
