# Football Home

Football Home is the Lighthouse 1893 football operations app: rosters, RSVPs,
LeagueApps membership sync, Google Calendar event layering, social/lead ops, and
the deterministic C++ tactical simulator.

This README is only the repo entrypoint. Project-wide rules live in
`CONVENTIONS.md`; deeper design docs live beside the subsystem or under `docs/`.

## Start Here

- Rules and source-of-truth boundaries: `CONVENTIONS.md`
- Documentation index: `docs/README.md`
- **How we develop (mirror → PR → live):** `docs/dev-environment.md`
- Simulator entrypoint: `sim/README.md`
- Simulator design/roadmap: `sim/DESIGN.md`
- Setup scripts: `setup.sh` and `scripts/setup/`

## How We Develop

Canonical path for **jbreslin** and **lbreslin** (same server, isolated stacks):

```bash
# once on the host
cd /srv/footballhome && sudo make backup && sudo make dev-mirror
sudo make dev-init DEV=jbreslin          # or DEV=lbreslin
cd /srv/footballhome-dev-jbreslin
sudo make dev-up DEV=jbreslin
sudo make dev-restore-mirror DEV=jbreslin
# browse http://SERVER:3010  (lbreslin → :3020)
# → Membership → Sync now → code → PR → merge

# ship to live
cd /srv/footballhome && git pull && sudo make migrate && sudo make deploy
```

Slots/ports: `config/dev-slots.conf`.  
Full guide: [`docs/dev-environment.md`](docs/dev-environment.md).  
Ship checklist: `./scripts/dev/ship-to-live.sh`

Merging to GitHub alone does **not** update footballhome.org.

## Runtime Stack

- Frontend: vanilla JavaScript SPA served by nginx on port 3000.
- Backend: custom C++ HTTP server on port 3001.
- Database: PostgreSQL with pg_cron on port 5432.
- Sync worker: LeagueApps conversion sidecar.
- Simulator: C++ deterministic sim service plus per-match sim containers.
- Container engine on this host: rootful Podman.

## Secrets and Config

Tracked encrypted secret bundles:

- `env.age` decrypts to ignored plaintext `env`.
- `scrape-vpn.conf.age` decrypts to ignored plaintext `scrape-vpn.conf`.
- `apsl-credentials.conf.age` decrypts to ignored plaintext
  `apsl-credentials.conf` for authenticated APSL TeamPass DOB scraping.

`setup.sh` runs `scripts/setup/setup-age.sh`, which installs `age` if needed and
decrypts the `.age` files after prompting for the passphrase. The plaintext files
are runtime inputs and must not be committed.

`env.example` is a non-secret key template only. The normal server path is to
decrypt `env.age`, not to hand-build `env` from the template.

`config/` contains tracked runtime configs such as the host nginx site and Meta
ZIP allowlists. Ignored LeagueApps `.p12` / `.pem` key material may also live
there because backend containers mount `config/` read-only at `/app/config`.

## First-Time Setup

On the production Linux host, Podman runs rootful. Use `sudo` for container and
database targets.

```bash
git clone https://github.com/jbreslin33/footballhome.git
cd footballhome
./setup.sh
sudo make rebuild
sudo make lighthouse
```

`./setup.sh` installs host dependencies, decrypts encrypted config, prepares the
scraper/VPN path, installs systemd timers where applicable, and prints the next
steps. `sudo make rebuild` is destructive, so use it only for a fresh host or when
a rebuild has been approved.

Local URL after startup:

```text
http://localhost:3000
```

## Common Commands

Run `make help` for the full target list.

```bash
sudo make ps                 # show running containers
sudo make up                 # start the stack
sudo make down               # stop the stack
sudo make deploy             # rebuild and replace backend/frontend services
sudo make migrate            # apply database migrations without wiping data
sudo make backup             # pg_dump snapshot under backups/
sudo make dev-mirror         # latest backup → backups/dev-mirror.sql.gz
sudo make restore            # restore latest backup, or BACKUP=file.sql
make restore-mirror          # restore prod mirror into *dev* DB
sudo make lighthouse         # refresh Lighthouse APSL + CASA data
sudo make sync-lighthouse    # legacy Lighthouse sync target
sudo make shell-db           # database shell
sudo make sim-deploy         # rebuild sim image, run sim tests, verify registry
./scripts/dev/ship-to-live.sh  # print prod ship checklist
```

Destructive reset:

```bash
sudo make backup
sudo make rebuild
sudo make lighthouse
```

Do not run destructive targets on a live data set without explicit approval.

## Project Layout

```text
backend/          C++ HTTP server
config/           runtime configs and ignored local key material
database/         bootstrap SQL, migrations, scraper pipeline, DB docs
docs/             cross-cutting designs and ADRs
frontend/         vanilla JS SPA and static assets
scripts/          operational, setup, sync, social, and debug scripts
sim/              deterministic C++ tactical simulator
systemd/          host timer/service units
```

Root is intentionally small: first-class entrypoints, encrypted config bundles,
and canonical documentation only.

## Data Source Boundaries

- LeagueApps is the source of truth for membership. Football Home syncs it on
  request paths before rendering LeagueApps-derived membership state.
- Google Calendar owns event timing and tags. Football Home layers RSVPs and app
  state on top.
- League websites are the source for scraped league data. Sync commands are
  idempotent and use UPSERTs.
- User-created app data is recoverable only from database backups.

See `CONVENTIONS.md` for the strict implementation rules behind these boundaries.