# shared/

Code that the club backend (`backend/`) and the game engine (`game/`) both
build. Owner, 2026-11-07: "always share where we can, only differ when we
have to … standard OOP parent child."

| File | What | Who builds it |
|---|---|---|
| `tactics/TacticGeometry.hpp` | Where our men stand from their tactic-plan jobs. Parent `JobRule` with one child per `tactic_job_rules` row (home, mark, press, cover_shadow, lane, hold_between, straddle), plus `RuleBook` and `Solver`. Header-only C++17 with no database or JSON. | backend (`/api/tactic-plans`, every state's `solved` + `POST /solve`); the game's plan reader (the game session wires it in) |

The rules are written out in words in `game/DESIGN.md` §8.137. A rule change
lands in the header, and that section is amended along with it.

## Build plumbing

- **Builder** (`make builder-up`): mounts `shared/` at `/shared`. CMake's
  `${CMAKE_SOURCE_DIR}/../shared` resolves to `/src/../shared`.
- **Full build** (`make deploy-clean`, `make build`):
  `podman build --build-context shared=./shared`, and the Dockerfile runs
  `COPY --from=shared . /shared`.
- **docker compose**: `additional_contexts: shared: ./shared` on the backend
  service. podman-compose 1.0.6 ignores this key, which is why the Makefile
  calls `podman build` directly.
- **Game**: its build context is `game/`. Pull the header in the same way
  (`--build-context shared=../shared` and an include path). The game
  session owns that change.

There is no JavaScript copy. The Tactics pill draws the spots that the
backend solves with this header.
