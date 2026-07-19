# How We Develop

Canonical workflow for every coder (**jbreslin**, **lbreslin**, agents).

```text
┌──────────────────────┐   dump    ┌─────────────────────────────────┐
│ Production           │ ────────► │ Per-dev stack on SAME server    │
│ /srv/footballhome    │           │ /srv/footballhome-dev-<slug>    │
│ footballhome.org     │           │ <slug>.dev.footballhome.org     │
│ :3000 / :3001 / :5432│           │ own ports + own DB volume       │
└──────────┬───────────┘           └───────────────┬─────────────────┘
           │                                       │
           │  git pull + migrate/deploy            │  code + browser test
           │                                       │  PR → merge main
           ◄───────────────────────────────────────┘
```

## Rules

1. **Test on your personal server stack** (DB mirror + LeagueApps sync).
2. **Ship only via GitHub `main`**, then update **prod** checkout.
3. Never point a dev compose file at the production Postgres volume.
4. Do not commit plaintext `env` or `backups/`.

---

## A. Slots (you + lbreslin)

Ports live in [`config/dev-slots.conf`](../config/dev-slots.conf):

| DEV | Frontend | Backend | DB | URL |
|---|---|---|---|---|
| `jbreslin` | 3010 | 3011 | 5440 | `https://jbreslin.dev.footballhome.org` |
| `lbreslin` | 3020 | 3021 | 5442 | `https://lbreslin.dev.footballhome.org` |

Add a row for each new person, pick free ports, commit.

---

## B. Create / rebuild developer stacks (on the server)

Everything below is **idempotent** — re-run after a server migrate.

### Preferred: `setup.sh` (all slots)

From the **production** checkout (`/srv/footballhome`):

```bash
cd /srv/footballhome
git pull origin main

# Fresh host (or full migrate): setup.sh runs step `dev-slots` after nginx/gcal.
# That calls scripts/setup/setup-dev-slots.sh → setup-dev-jbreslin.sh / setup-dev-lbreslin.sh
# for every row in config/dev-slots.conf.
./setup.sh

# Or only rebuild the per-dev stacks:
./setup.sh --only dev-slots
# subset: DEV_SLOTS=jbreslin ./setup.sh --only dev-slots
# make equivalents:
#   make setup-dev-slots
#   make setup-dev-jbreslin
#   make setup-dev-lbreslin
```

Each slot script: worktree → `dev-up` → restore mirror (if dump exists) → nginx vhost.

After prod is up and you have a fresh dump:

```bash
sudo make backup && sudo make dev-mirror
./setup.sh --only dev-slots          # re-restores into every slot
```

**DNS + TLS** (once A records point here):

```bash
# jbreslin.dev.footballhome.org + lbreslin.dev.footballhome.org → this host
sudo DEV_SLOTS_OBTAIN_CERT=1 LE_EMAIL=you@example.com ./setup.sh --only dev-slots
```

### Manual (one person)

```bash
sudo make backup && sudo make dev-mirror
sudo make setup-dev-slot DEV=jbreslin   # or: ./scripts/setup/setup-dev-jbreslin.sh
# low-level pieces still available: make dev-init|dev-up|dev-restore-mirror|dev-nginx DEV=…
```

**Browse immediately (no DNS):** `http://<server-ip>:3010` (jbreslin) or `:3020` (lbreslin).

Then Membership → **Sync now** (LeagueApps → your mirror DB → UI).

`dev-init` (inside the setup scripts) creates `/srv/footballhome-dev-<slug>` and
symlinks `env` from prod so LeagueApps keys work.

---

## C. Day-to-day (each developer)

```bash
ssh you@server
cd /srv/footballhome-dev-jbreslin

git fetch origin
git checkout -b cursor/my-feature-xxxx origin/main   # or pull latest
# edit frontend/backend…

# if backend C++ changed:
sudo make dev-up DEV=jbreslin          # rebuilds that slot's backend

# browser: http://SERVER:3010  or  https://jbreslin.dev.footballhome.org
# Membership → Sync now when you need fresher LA data

git add … && git commit && git push -u origin HEAD
# open PR → merge to main
```

Refresh mirror when data feels stale (prod maintainer):

```bash
cd /srv/footballhome
sudo make backup && sudo make dev-mirror
cd /srv/footballhome-dev-jbreslin
sudo make dev-restore-mirror DEV=jbreslin
```

Stop slot (keeps DB volume):

```bash
sudo make dev-down DEV=jbreslin
# wipe that slot's DB: sudo make dev-down DEV=jbreslin DEV_WIPE=1
```

---

## D. Ship to live (after PR merges)

```bash
cd /srv/footballhome
git pull origin main
sudo make migrate          # if migrations landed
sudo make deploy           # if backend C++ changed
# frontend-only: pull + hard refresh usually enough
```

Or print the checklist: `./scripts/dev/ship-to-live.sh`

| Change | Prod action |
|---|---|
| Frontend only | `git pull` + hard refresh |
| Migration | `git pull` → `sudo make migrate` |
| Backend C++ | `git pull` → `sudo make deploy` |

Dev stacks are **not** updated by shipping prod — each person `git pull`s
their own `/srv/footballhome-dev-<slug>` when they want new `main`.

---

## E. Commands cheat sheet

```bash
./setup.sh --only dev-slots           # all slots (also part of full ./setup.sh)
make setup-dev-slots                  # same
make setup-dev-jbreslin               # one person
make setup-dev-lbreslin
make setup-dev-slot DEV=<slug>
make dev-init DEV=<slug>              # low-level pieces
make dev-up DEV=<slug>
make dev-restore-mirror DEV=<slug>
make dev-nginx DEV=<slug>
make dev-ps DEV=<slug>
make dev-down DEV=<slug>              # DEV_WIPE=1 drops volume
make backup && make dev-mirror        # on prod checkout
./scripts/dev/ship-to-live.sh
```

Compose file: `docker-compose.dev.yml` (db + backend + frontend only — no
sim / podman.sock, so it won’t fight production’s sim orchestrator).

---

## F. Cursor Cloud / laptop (optional)

Still supported via `.cursor/environment.json` and local Docker, but the
**default team path is per-dev stacks on the server** so everyone gets a
real browser URL without DinD on a laptop.

See also: `AGENTS.md`, `README.md`, `CONVENTIONS.md`.
