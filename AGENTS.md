# Agent instructions (Football Home)

## How we develop (read this first)

Canonical workflow: [`docs/dev-environment.md`](docs/dev-environment.md).

```text
DB mirror + LA sync on :3000  →  PR → merge main  →  prod git pull + migrate/deploy
```

- Develop and verify on the **dev mirror stack** (`localhost:3000`).
- Do **not** claim a UI change is live on footballhome.org until a human has
  run the ship steps on `/srv/footballhome` (see below).
- Never point compose at production Postgres.

## Cursor Cloud specific instructions

Use the environment in `.cursor/environment.json` (Docker stack + secrets),
not a bare JIT clone without DB.

### Boot expectations

- Docker daemon: `scripts/dev/cloud-start.sh`
- `db` / `backend` / `frontend`: `scripts/dev/cloud-stack.sh` (tmux `stack`)
- Decrypted `env` from Runtime Secret `AGE_PASSPHRASE`
- DB mirror from `backups/dev-mirror.sql.gz` or Runtime Secret `DEV_MIRROR_URL`

```bash
docker compose --env-file env ps
./scripts/dev/restore-mirror.sh          # if not already restored
curl -sI http://localhost:3000 | head -5
```

If `env` is missing:

```bash
AGE_PASSPHRASE="$AGE_PASSPHRASE" ./scripts/setup/setup-age.sh
./scripts/dev/cloud-stack.sh &
```

### Test UI (Members / Person / Club Admin)

1. Mirror restored
2. Membership → Sync now (LeagueApps → mirror DB → render)
3. Exercise the change on `:3000`
4. Hard-refresh if needed

### Backend / migrations (dev)

```bash
docker compose --env-file env up -d --build backend   # after C++ changes
make migrate
```

### Ship reminder (human on prod — print anytime)

```bash
./scripts/dev/ship-to-live.sh
```

```bash
cd /srv/footballhome
git pull origin main
sudo make migrate    # if migrations landed
sudo make deploy     # if backend C++ changed
# frontend-only: pull + hard refresh usually enough
```

### Do not

- Wipe the cloud DB without asking (`make rebuild` is destructive)
- Commit decrypted `env`, dumps, or credentials
- Assume Podman in Cloud (use Docker; Makefile detects it)
- Edit production as the default path

## General project rules

Follow `CONVENTIONS.md` (LeagueApps membership: LA → DB → render).
Design docs under `docs/`. Development chain: `docs/dev-environment.md`.
