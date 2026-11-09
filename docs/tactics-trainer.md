# Tactics trainer — the game engine plays, teaches and edits the tactic plans

Owner, 2026-11-09: "why can't we use the game engine to do the tactics … can we extend game to
show players tactics?" · "as the game matures so will the tactics trainer — it can be premier
league teams that 'teach' the tactics" · "i would like to train from the game too. have that
option" · "yes do it all".

## The idea

One plan, two views, one store.

| | Board (Game Center 🎯 Tactics) | Game (3D engine, `game.html`) |
|---|---|---|
| Who builds it | club sessions | game session (`game/`, `frontend/game*`) |
| Good for | sketching a plan from nothing, quick phone look | real movement: testing a plan, players watching, coaching on real moments |
| Reads | `/api/tactic-plans` (+ `solved`) | the club DB tables in §8.137 (engine), `/api/tactic-plans` (client) |
| Writes | `/api/tactic-plans` | `/api/tactic-plans` — the same calls, coach JWT |
| Spots | `shared/tactics/TacticGeometry.hpp` via the backend | the same header, compiled into the engine |

Nothing is copied between them. A job changed in the game shows on the board and the reverse.
As the engine's realism improves, every lesson improves with it.

## Build order (game session owns 1–4; club session owns 5)

1. **The engine reads the plans** — `game/DESIGN.md` §8.137 (the contract, already written;
   "engine reader not built yet"). Include `shared/tactics/TacticGeometry.hpp` (the only placement
   code; the engine's build context is `game/` today, so it needs `shared/` mounted or a build
   context like the club backend's). Lighthouse (3-5-2, 3-R2) plays its plans out of possession.
2. **Practice match** — a match separate from the one live match (one clock, one `SPEED`): load
   a plan, start at its root (their keeper, goal kick, our line held at the 18 — `tactic_restarts`),
   step along the tree "ball to their #N" at a chosen speed, freeze, play on live from any state.
   Freeze frame / play-practice-play is the design input (memory: coaching methodology).
3. **Edit from the game** — paused, tap one of ours (3D pick) → the same job sheet the board has
   (job kind dropdown filtered by the plan's moment, ⭐ shortcuts first, targets = their numbers,
   stance, the concept's cue). Save = `PUT /api/tactic-plans/states/:id {opponents, jobs}`.
   **Save this moment as a step**: `POST /api/tactic-plans/states {parent_state_id, ball_with}`
   (ball_with = their carrier's number) then `PUT …/states/:id` with `opponents` = their 10 outfield
   men's x,y in §8.137 coordinates (0-100, our view, y 0 = our goal line) and the current jobs.
   Then play on with the new jobs. Open question for the game session: what a frame means when the
   ball is in flight or men are mid-run (suggest: use the intended receiver as ball_with, and
   their positions at the freeze tick).
4. **Premier League sides teach** — with the reader in place, any of the 20 PL 15/16 sides can
   demonstrate a lesson ("their block from a goal kick", "their press when the ball goes wide").
   Honesty rule: our PL data is StatsBomb events (pressure and ball-win locations, no off-ball
   tracking); off-ball shape is from DFL (Bundesliga). A lesson may say "measured" only for what
   was measured.
5. **Club side** (club session): a 🎮 3D view pill on the 🎯 Tactics panel beside ↕ Upright /
   ↔ Sideways that opens the practice match on the current plan + state (deep link into
   `game.html`), and the job sheet copy the game shows comes from the same DB rows
   (`tactic_job_kinds`, `game_concepts`) — no hard-coded labels.

## API the game client uses (exists today, `backend/src/controllers/TacticPlansController.cpp`)

- `GET /api/tactic-plans` — lookups, plans, states, jobs, `solved` spots, shortcuts.
- `POST /api/tactic-plans/states {parent_state_id, ball_with}` → `{id}`.
- `PUT /api/tactic-plans/states/:id {opponents, jobs}` — coaches/admins only.
- `DELETE /api/tactic-plans/states/:id`.
- `POST /api/tactic-plans/solve` — spots for an unsaved state.
- `POST /api/tactic-plans/shortcuts {kind, on}`.

If the game needs something these can't do, ask the club session; don't add a second write path.
