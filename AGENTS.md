# Agent instructions (Football Home)

## Cursor Cloud specific instructions

This repo’s permanent **dev/test** loop is the Cursor Cloud Environment
defined in `.cursor/environment.json` (not a bare GitHub checkout, and not
production).

### What should already be running

After boot you should have:

- Docker daemon (`scripts/dev/cloud-start.sh`)
- `db` / `backend` / `frontend` via `scripts/dev/cloud-stack.sh` (tmux `stack`)
- Decrypted `env` from Runtime Secret `AGE_PASSPHRASE`

Verify:

```bash
docker compose --env-file env ps
curl -sI http://localhost:3000 | head -5
curl -sI http://localhost:3001/api/health 2>/dev/null | head -5 || true
```

If `env` is missing:

```bash
AGE_PASSPHRASE="$AGE_PASSPHRASE" ./scripts/setup/setup-age.sh
./scripts/dev/cloud-stack.sh &
```

### How to test UI changes (Members / Person / Club Admin)

1. Prefer the cloud stack at `http://localhost:3000` — **not** footballhome.org.
2. Open Membership → Sync now (LeagueApps → DB → render).
3. Confirm slim cards / Person View·Edit / etc. against synced data.
4. Hard-refresh if the browser cached old JS.

Production (`footballhome.org`) only updates after a human `git pull` on
`/srv/footballhome`. Do not tell the user a UI change is live on prod until
that deploy happens.

### Backend / migrations

```bash
# after C++ changes
docker compose --env-file env up -d --build backend

# schema
make migrate
```

### Do not

- Wipe the cloud DB without asking (`make rebuild` is destructive).
- Commit decrypted `env`, `*.conf`, or other plaintext secrets.
- Assume Podman is available in Cloud (use Docker; Makefile detects it).
- Point compose at the production database.

### Production deploy reminder (for the human)

```bash
cd /srv/footballhome && git pull origin main
sudo make deploy    # if backend changed
sudo make migrate   # if migrations landed
```

## General project rules

Follow `CONVENTIONS.md` (LeagueApps is membership source of truth;
LA → DB → render on request paths). Design docs live under `docs/`.
Dev environment design: `docs/dev-environment.md`.
