#!/bin/bash
# scripts/setup/setup-env.sh — env file template + Docker Hub login
set -e
source "$(dirname "$0")/_lib.sh"
REPO_ROOT="$(setup_repo_root)"
cd "$REPO_ROOT"

if [ ! -f env ]; then
  print_status "Creating fresh env template..."
  cat > env << 'EOF'
# Football Home Environment Variables (created by setup-env.sh)

# Docker Hub Authentication (avoid pull rate limits)
DOCKER_HUB_USERNAME=
DOCKER_HUB_TOKEN=

# Twilio SMS (optional)
TWILIO_ACCOUNT_SID=
TWILIO_AUTH_TOKEN=
TWILIO_FROM_PHONE=

# Google OAuth (optional)
GOOGLE_OAUTH_CLIENT_ID=
GOOGLE_OAUTH_CLIENT_SECRET=
GOOGLE_OAUTH_REDIRECT_URI=http://localhost:3000/oauth/google/callback

# Let's Encrypt — email used by certbot for renewal notices.
# When set, ./setup.sh will run `certbot --nginx --obtain-cert` automatically.
LE_EMAIL=
EOF
  print_success "env file created"
else
  print_success "env file already exists"
fi

# Docker Hub login
if podman login --get-login docker.io &> /dev/null; then
  print_success "Already logged in to Docker Hub as: $(podman login --get-login docker.io)"
else
  source ./env 2>/dev/null || true
  if [ -n "$DOCKER_HUB_USERNAME" ] && [ -n "$DOCKER_HUB_TOKEN" ]; then
    print_status "Logging in to Docker Hub from env file..."
    if echo "$DOCKER_HUB_TOKEN" | podman login docker.io -u "$DOCKER_HUB_USERNAME" --password-stdin &> /dev/null; then
      print_success "Logged in to Docker Hub"
    else
      print_warning "Docker Hub login failed — check env credentials"
    fi
  else
    print_warning "No Docker Hub credentials in env (optional, raises pull rate limit)"
  fi
fi
