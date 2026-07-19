# Scripts

This directory holds operational scripts that are not part of the backend,
frontend, database scraper pipeline, or simulator source trees.

## Keep Here

- `setup/`: first-time host setup steps called by root `setup.sh`.
- `scrape-vpn.sh` and `vpn-wrap.sh`: scraper VPN container lifecycle and wrapper
  used by league scrape commands.
- `gcal-*.js`: Google Calendar mirror, classifier, tests, and RSVP applier used
  by systemd timers and calendar operations.
- `sync-leagueapps-*.py`: LeagueApps sidecar jobs and payment sync utilities.
- `social/`, exhibit, poster, and operator scripts: Instagram/exhibit workflows
  and the local operator dashboard.
- Meta ad and lead scripts: ad creation, targeting audits, ZIP allowlists, lead
  form setup, and spend reports.
- `dev/`: local developer helpers and probes.
- One-shot migration helpers may stay only while they document or safely repeat a
  still-relevant operational migration.

## Keep Elsewhere

- League scraper implementation belongs under `database/scripts/`.
- Simulator tooling belongs under `sim/scripts/`.
- Repo-wide rules belong in `CONVENTIONS.md`, not in scripts.
- Logs, cache directories, local credentials, and generated media are ignored and
  must not be committed.

If a script is personal tooling, a one-off data patch, or no longer referenced by
setup, Makefile targets, systemd units, docs, or code, remove it rather than
letting it become a second junk drawer.