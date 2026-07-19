# How We Develop

This is the **canonical** Football Home development workflow for every
coder (including Cursor Cloud agents). Do not invent a parallel path.

```text
┌─────────────────────┐     dump      ┌──────────────────────────┐
│  Production host    │ ───────────►  │  Dev stack (you / lbreslin│
│  /srv/footballhome  │  DEV_MIRROR   │  Cursor Cloud or local)  │
│  footballhome.org   │               │  own Postgres volume     │
└─────────┬───────────┘               └────────────┬─────────────┘
          │                                        │
          │  git pull + deploy                     │  code + test
          │                                        │  PR → merge main
          ◄────────────────────────────────────────┘
```

## Rules

1. **Develop against a DB mirror + live LeagueApps sync** — not an empty DB,
   and not by pointing compose at prod Postgres.
2. **Ship only through GitHub `main`**, then update the production host.
3. **Never commit** plaintext `env`, dumps under `backups/`, or other secrets.

Editing directly on production is an emergency escape hatch, not the default.

## Roles

| Who / where | Does |
|---|---|
| Prod host maintainer | Refresh mirror dumps; pull/deploy after merges |
| Developer (local or Cursor) | Restore mirror, run stack, change code, open PR |
| GitHub `main` | Source of truth for code |

---

## A. Production host — publish a fresh mirror

Run on `/srv/footballhome` whenever devs need fresher data (weekly is fine;
before big membership work is better).

```bash
cd /srv/footballhome
sudo make backup
sudo make dev-mirror
# → backups/dev-mirror.sql.gz  (gitignored)
```

Give developers that file (scp, shared private storage, etc.), **or** host it
privately and set Cursor Runtime Secret `DEV_MIRROR_URL` to a signed URL.

Also ensure teammates have the `age` passphrase so they can decrypt `env.age`
(`AGE_PASSPHRASE` as a Cursor Runtime Secret, or interactive `./setup.sh`).

---

## B. Developer machine / Cursor Cloud — boot the stack

### B1. One-time Cursor Environment (Cloud)

1. [Cloud Agents → Environments](https://cursor.com/dashboard/cloud-agents)
2. Environment for `jbreslin33/footballhome`
3. Runtime Secrets:
   - `AGE_PASSPHRASE` (required)
   - `DEV_MIRROR_URL` (recommended — points at `dev-mirror.sql.gz`)
4. First agent run: stack comes up via `.cursor/environment.json`
5. Confirm mirror restore + `http://localhost:3000`
6. **Save snapshot** — all future agents use this environment

Repo files: `.cursor/environment.json`, `.cursor/Dockerfile`,
`scripts/dev/cloud-*.sh`, `AGENTS.md`.

### B2. Local clone

```bash
git clone https://github.com/jbreslin33/footballhome.git
cd footballhome
./setup.sh                          # decrypts env.age (prompts or AGE_PASSPHRASE=)
# place backups/dev-mirror.sql.gz   # from prod, or set DEV_MIRROR_URL
sudo make up                        # Podman on Linux; Docker works too
make restore-mirror
# open http://localhost:3000
```

Cursor Cloud uses Docker; the production host uses Podman. The Makefile
auto-detects `ENGINE` / `COMPOSE`.

### B3. Every day on the mirror

```bash
# stack already up
make restore-mirror                 # when you grabbed a newer dump
# UI: Membership → Sync now        # LeagueApps → mirror DB → render
# edit code, verify on :3000
git checkout -b cursor/my-change-xxxx
# … commit …
git push -u origin HEAD
# open PR → merge to main
```

LeagueApps remains membership source of truth for **freshness** after restore
(`CONVENTIONS.md` LA → DB → render).

---

## C. Ship to the live server (whole chain)

After the PR is **merged to `main`**, on the production host:

```bash
cd /srv/footballhome
git fetch origin main
git checkout main
git pull origin main

# Schema changes?
sudo make migrate

# Backend C++ changed?
sudo make deploy

# Frontend-only JS/CSS/HTML: bind-mounted — usually live after pull.
# Hard-refresh the browser (cache-control is already no-store).

sudo make ps                        # confirm containers healthy
# smoke: open https://footballhome.org → Membership → Sync now
```

Cheat sheet (prints the same steps):

```bash
./scripts/dev/ship-to-live.sh
```

| Change type | Prod action |
|---|---|
| Frontend JS/HTML/CSS only | `git pull` (+ hard refresh) |
| New SQL migration | `git pull` → `sudo make migrate` |
| Backend C++ | `git pull` → `sudo make deploy` |
| Both | `git pull` → `migrate` → `deploy` |
| Fresh mirror for other devs | `sudo make backup && sudo make dev-mirror` |

---

## D. What “done” means

A change is **not live** until section C has run on `/srv/footballhome`.
Merging to GitHub alone does not update footballhome.org.

A change is **verified in dev** only when exercised on the mirror stack at
`localhost:3000` (or equivalent), not by staring at production.

---

## Troubleshooting

| Symptom | Fix |
|---|---|
| Live site still old after merge | Section C not run on prod |
| Dev Members empty / wrong | Restore mirror; then Sync now |
| `AGE_PASSPHRASE unset` | Add Cursor secret or run `./setup.sh` |
| OAuth login fails on cloud | Separate redirect URI, or use API bearer JWT |
| Accidentally on prod DB | Stop — compose must use local volume only |

## Related

- `README.md` — short entry + common commands  
- `CONVENTIONS.md` — LA → DB → render and repo rules  
- `AGENTS.md` — Cursor Cloud agent runbook  
- `Makefile` — `backup`, `dev-mirror`, `restore-mirror`, `deploy`, `migrate`  
