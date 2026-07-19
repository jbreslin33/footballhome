# Permanent Dev Environment

Two workable modes:

1. **Dev DB mirror + LeagueApps sync** (permanent solution)  
2. **Edit directly on production** (fast, dangerous)

If you want agents / local to test Members like prod without risking
footballhome.org, you need (1).

## Mental model

| Place | Role |
|---|---|
| Dev stack (Cursor Cloud or local Docker/Podman) | Own Postgres **volume** seeded from a prod dump; reads LeagueApps with decrypted `env` |
| GitHub `main` | Code only |
| Production `/srv/footballhome` | Live site — `git pull` + deploy/migrate |

```text
prod:  make backup  →  backups/dev-mirror.sql(.gz)
         ↓ copy / DEV_MIRROR_URL
dev:   compose up  →  restore-mirror  →  LA Sync (fresh membership)
         ↓ PR → merge
prod:  git pull  →  make deploy / migrate
```

## Why a mirror (not empty DB)

- Membership screens also need accounts, roster links, RSVP grants, billing
  flags, etc. that an empty DB + one Sync does not fully recreate.
- Permanent = **persistent volume + refreshable dump**, not “sync from
  scratch every cold boot.”
- LeagueApps stays source of truth for membership *freshness* after restore
  (LA → mirror DB → render).

Never point compose at production Postgres.

## One-time / recurring: refresh the mirror from prod

On the production host:

```bash
cd /srv/footballhome
sudo make backup
cp "$(ls -t backups/backup-*.sql | head -1)" backups/dev-mirror.sql
gzip -kf backups/dev-mirror.sql
```

Get `backups/dev-mirror.sql.gz` onto the machine that runs the dev stack
(scp, private object storage, etc.). That path is **gitignored** — do not
commit dumps.

Optional Cursor Runtime Secret: `DEV_MIRROR_URL` = signed URL to that file.
`scripts/dev/restore-mirror.sh` downloads it on boot.

## Cursor Cloud Environment

Repo scaffolding:

- `.cursor/environment.json` + `.cursor/Dockerfile`
- `scripts/dev/cloud-{install,start,stack}.sh`
- `scripts/dev/restore-mirror.sh`
- `AGENTS.md`

Dashboard setup:

1. Environment for this repo  
2. Runtime Secrets: `AGE_PASSPHRASE` (required), `DEV_MIRROR_URL` (recommended)  
3. First agent run: stack up → mirror restore → Members Sync  
4. **Save snapshot** (warm tools + ideally filled Docker volume)  
5. All future Cloud Agents use this environment  

## Local (same idea)

```bash
./setup.sh                    # decrypt env.age
# place backups/dev-mirror.sql.gz
sudo make up                  # or docker compose --env-file env up -d
./scripts/dev/restore-mirror.sh
# open http://localhost:3000 → Members → Sync now
```

## Ship to production

```bash
cd /srv/footballhome
git pull origin main
sudo make deploy    # backend C++ changes
sudo make migrate   # new migrations
# frontend bind-mount usually picks up JS without rebuild
```

## OAuth note

Cloud/local Google login may need a separate redirect URI; API testing can
use a bearer JWT. See `AGENTS.md`.

## Related

- `AGENTS.md` — cloud agent runbook  
- `README.md` — production host setup  
- `CONVENTIONS.md` — LA → DB → render  
