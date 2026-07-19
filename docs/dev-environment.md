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

## B. One-time: create your stack (on the server)

SSH to the host. From **production** checkout:

```bash
cd /srv/footballhome
git pull origin main

# Fresh mirror for all devs
sudo make backup
sudo make dev-mirror

# Your personal checkout + stack
sudo make dev-init DEV=jbreslin          # or DEV=lbreslin
cd /srv/footballhome-dev-jbreslin
sudo make dev-up DEV=jbreslin
sudo make dev-restore-mirror DEV=jbreslin

# Optional pretty URL (needs DNS A record → this host)
sudo make dev-nginx DEV=jbreslin
# sudo certbot --nginx -d jbreslin.dev.footballhome.org
```

**Browse immediately (no DNS):** `http://<server-ip>:3010` (jbreslin) or `:3020` (lbreslin).

Then Membership → **Sync now** (LeagueApps → your mirror DB → UI).

`dev-init` creates a git worktree under `/srv/footballhome-dev-<slug>` and
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
make dev-init DEV=<slug>
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
