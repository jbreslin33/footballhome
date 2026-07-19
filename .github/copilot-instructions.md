# Football Home Copilot Bootstrap

`CONVENTIONS.md` is the canonical source for repository rules. Read it before
making code, setup, database, documentation, or workflow changes.

**How we develop:** `docs/dev-environment.md` — DB mirror + LeagueApps sync →
PR → prod `git pull` / `make migrate` / `make deploy`. Cursor Cloud: `AGENTS.md`.

## Pre-Work Checks

Before running commands or editing files:

1. Run `pwd`. Production host is `/srv/footballhome`; Cursor Cloud / laptop
   checkouts use their own path with a **separate** DB volume.
2. Run `make help` so available targets are not guessed.
3. Before container or database work: on prod `sudo podman ps`; in Cloud
   `docker compose --env-file env ps`.
4. Read the relevant existing file before editing it.
5. Verify UI changes on the **dev mirror** (`localhost:3000`), not by assuming
   footballhome.org updated.

## Safety Rules

- Use `/srv/footballhome` in absolute paths, service units, cron jobs, nginx
  configs, and backup scripts.
- Do not run destructive operations such as `make rebuild`, volume deletion, or
  database resets without explicit approval. Run `make backup` first when
  destructive work is approved.
- Show full command output. Do not hide validation or diagnostic output with
  display filters, pagers, quiet flags, or redirection.
- Do not commit secrets, plaintext env files, local credentials, backups, logs,
  scratch files, or generated local media.
- Do not stage or commit unrelated user changes.

## Source-Of-Truth Boundaries

- LeagueApps membership: follow the strict flow in `CONVENTIONS.md` before any
  endpoint reads or renders LeagueApps-derived membership data.
- Google Calendar events: Calendar owns event timing and tags; Football Home
  layers RSVPs and application state on top.
- Browser caching: no caching except login localStorage for token/user unless
  `CONVENTIONS.md` is updated to allow it.

## Context Routing

- Simulator work: start with `sim/README.md`, then `sim/DESIGN.md`, then the
  directly touched source and tests.
- Backend membership work: start with `CONVENTIONS.md`,
  `backend/src/core/Controller.*`, the target controller/model, and
  `scripts/enforce-la-sync.sh`.
- Frontend screen work: start with `frontend/js/app.js`, the target screen, and
  adjacent screen classes.
- Setup/deploy work: start with `setup.sh`, `scripts/setup/`, `build.sh`,
  `Makefile`, and `docker-compose.yml`.

If this file and `CONVENTIONS.md` disagree, update this file to point at the
canonical rule in `CONVENTIONS.md` rather than duplicating the full rule here.