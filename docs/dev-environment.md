# Permanent Dev Environment (Cursor Cloud)

Production lives on the host at `/srv/footballhome` (Podman). Cloud agents
used to edit a **code-only** GitHub clone with no DB — so Members/Person
changes could not be verified against LeagueApps data.

This repo now defines a **Cursor Cloud Environment** that boots the real
stack (Docker + Postgres + backend + frontend) with decrypted secrets so
agents can sync and click through Membership like production.

## Mental model

| Place | What it is | When UI updates |
|---|---|---|
| Cursor Cloud Environment | Disposable VM per agent run, warm snapshot + compose stack | Immediately inside that VM (`localhost:3000`) |
| GitHub `main` | Source of truth for code | Never by itself |
| Production host `/srv/footballhome` | Live footballhome.org | After `git pull` (+ `make deploy` / `make migrate` when needed) |

Agents edit → open PR → merge to `main` → **you still pull on the server**
to ship production. Cloud is for **dev/test**, not auto-deploy.

## One-time human setup

1. Merge this scaffolding to `main`.
2. Open [Cloud Agents → Environments](https://cursor.com/dashboard/cloud-agents).
3. Create / select an environment for `jbreslin33/footballhome`.
4. **Secrets → Runtime Secret:** `AGE_PASSPHRASE` = the passphrase that
   decrypts `env.age` (same as `./setup.sh` on the server).
5. Optional: add any extra runtime secrets you do not want inside `env.age`.
6. Run an agent (or **Update with Agent**) and confirm:
   - `env` decrypts
   - `docker compose` brings up `db`, `backend`, `frontend`
   - `http://localhost:3000` loads; Members can Sync now
7. **Save snapshot** so later agents boot warm.
8. Ensure subsequent Cloud Agent runs use this environment (not a bare JIT VM).

Repo config (already committed):

- `.cursor/environment.json` — install / start / terminals / ports
- `.cursor/Dockerfile` — Ubuntu + Docker-in-Docker + age/cmake/node
- `scripts/dev/cloud-*.sh` — decrypt, start dockerd, compose up
- `AGENTS.md` — cloud-specific agent instructions

## Day-to-day agent loop

1. Start a Cloud Agent **on the footballhome-dev environment**.
2. Stack comes up via `cloud-stack.sh` (tmux terminal `stack`).
3. Agent changes code, hits Members/Person on `:3000`, verifies Sync.
4. Agent opens a PR; you review/merge.
5. On the production host:

```bash
cd /srv/footballhome
git pull origin main
# frontend bind-mount usually picks up JS immediately
sudo make deploy    # if backend C++ changed
sudo make migrate   # if new migrations landed
```

## Data

- Cloud DB starts empty (or from whatever was snapshotted on disk).
- With decrypted `env`, **LeagueApps sync is live** — open Members and
  Sync now to pull real membership rows (same source of truth as prod).
- Do **not** point cloud agents at the production Postgres. Keep a
  separate compose volume.
- Prefer LA sync over restoring prod dumps unless you need historical rows.

## OAuth / login notes

`env.age` usually has production Google OAuth redirect URIs. Browser login
inside the cloud VM may fail until you either:

- add a cloud redirect URI in Google Cloud Console and a cloud-specific
  override secret, or
- reuse an existing session token for API checks (`Authorization: Bearer …`).

UI work that only needs club-admin APIs can often use a minted JWT from
the backend once the stack is up.

## Prod vs cloud engines

- Production host: **Podman** + `podman-compose` (existing path).
- Cursor Cloud: **Docker** + `docker compose` (Podman is not supported in
  Cloud Agent VMs). The Makefile auto-detects `ENGINE` / `COMPOSE`.

## Troubleshooting

| Symptom | Fix |
|---|---|
| Agent has no DB / fat Members still on footballhome.org | Wrong place — cloud is localhost; prod needs `git pull` |
| `AGE_PASSPHRASE unset` | Add Runtime Secret on the Environment |
| Docker never ready | Check `start` ran `cloud-start.sh`; see `/tmp/dockerd.log` |
| Snapshot expired (90 days idle) | Re-run setup, save a new snapshot, update dashboard |
| Backend build OOM | Enterprise: ask Cursor for larger VM; or build backend on host |

## Related

- `AGENTS.md` — short instructions agents read every run
- `README.md` — production host first-time setup
- `CONVENTIONS.md` — LA→DB→render and other project rules
