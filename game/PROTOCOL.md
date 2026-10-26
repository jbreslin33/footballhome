# fh-game wire protocol — v1.4

> The protocol is the product boundary (DESIGN.md pillar 4). Every client —
> browser, native, desktop, headless — implements this document and nothing
> else. The server implements it exactly once. Changes land here BEFORE they
> land in code, and the version number is the contract.
>
> Status: **skeleton**. Field layouts get locked during G0; sections marked
> TBD are filled by the G0 slices that implement them. Conventions carried
> from v1's `fh-sim.v1`: little-endian, length-prefixed frames, JWT inside
> the WebSocket subprotocol header.

## 1. Transport & handshake

- WebSocket, binary frames, over the stack's TLS-terminating nginx.
  Path: `/game/<match_routing_key>` (variable-resolved upstream, request-time
  DNS — the v1 pattern; never a startup-resolved literal host).
- Auth: JWT travels in the `Sec-WebSocket-Protocol` header:
  `fh-game.v1.bearer.<JWT>` — same shared-secret JWTs the club app already
  issues, so a browser client reuses the session token it has.
- First server frame: `HELLO`. A client that can't speak the major version
  disconnects with a reason frame: stale clients are told, never desynced.
  Payload (locked G0.3):

  ```
  u8 major | u8 minor | u8 patch | u64 match_id | u8 tick_rate |
  u8 capabilities (§3 bits) | u8 slot_count |
  i64 pitch_half_x (Fixed64 raw, m) | i64 pitch_half_y (Fixed64 raw, m)
  ```

  Team manifest and sim-speed fields are appended by later minor versions
  (decoders already ignore trailing bytes, §9).

## 2. Frame envelope

```
u16 length | u8 frame_type | u8 flags | payload…
```

Frame types (u8):

| id | name | dir | purpose |
|---|---|---|---|
| 0x01 | HELLO | s→c | handshake (§1) |
| 0x02 | GOODBYE | both | reason-coded disconnect |
| 0x10 | PLAYER_INTENT | c→s | §4 |
| 0x11 | TACTICAL_INTENT | c→s | §5 |
| 0x20 | SNAPSHOT | s→c | §6 |
| 0x21 | EVENT | s→c | §7 |
| 0x30 | CLAIM / RELEASE slot | c→s | take or drop control of a slot |
| 0x31 | SPEED | both | (1.10, G4.61) `u16 pct` — sim speed in percent of real time: 100 live, 5-400 slow motion to fast forward, 0 paused (1-4 clamp to 5, above 400 to 400). c→s admin only (one match, one clock); s→c on connect and to every client on each change. Only the wall-clock gap between ticks changes — the same ticks, the same physics. Paused, the server sends the frozen SNAPSHOT every 200 ms (same tick) so watchdogs stay quiet; clients render the tick timeline at 1000/(30·pct/100) ms per tick |
| 0x33 | PLAYER_SETTINGS | c→s | admin: one slot's GRADED knowledge (1.4 superseded the 1.3 bitmask): `u8 slot \| u8 count \| u8 rating…` (0-100 per concept, by curriculum id — CONCEPTS frame 0x3A; extra trailing ratings ignored) |
| 0x34 | ROSTER | s→c | per-slot knowledge + names (1.4 graded form), on connect and after changes: `u8 count`, then per slot `u8 rating_count \| u8 rating… \| u8 name_len \| name bytes` |
| 0x32 | MATCH_SETTINGS | c→s | admin: set both teams' skill bands live (1.3): `u8 level_home \| u8 level_away` (band ids 0-6 = perfect/u10/u14/amateur/semipro/pro/world); non-admin senders are ignored |
| 0x35 | PRESETS | s→c | style-preset catalog (1.4), on connect: `u8 count`, then per preset `u8 name_len \| name bytes`; a preset's wire id IS its index in this list. Rows come from `game_models` (mig 652; were `game_style_presets`, mig 630); vectors stay server-side |
| 0x36 | APPLY_PRESET | c→s | admin: paint one team's identity in one tap (1.4): `u8 team (0 home / 1 away) \| u8 preset_id (PRESETS index)`. Since 1.6 the team PLAYS that game model: its demand against each player's ability (min of the two); server answers with a fresh ROSTER |
| 0x37 | PLAYER_ATTRIBUTES | c→s | admin (1.5, G4.30): one slot's attributes, live: `u8 slot \| u8 count \| u8 rating…` in this append-only order: pace, passing, shooting, first_touch, tackling, anticipation, decisions, goalkeeping, then (G4.52, 1.8) acceleration, deceleration, agility, dribbling — a shorter frame leaves the rest unchanged; 255 = unrated (the band / a 50-rated body). The editor saves the same values to the club DB (`/api/game/player`), which the daemon reads at boot |
| 0x38 | TEAMS | s→c | the two teams playing (1.5, G4.30), on connect: `u8 len \| home name (UTF-8) \| u8 len \| away name` — game_demo_teams names, the editor's key into `/api/game/roster` |
| 0x39 | RELOAD_ROSTERS | c→s | admin (1.5, G4.32): empty payload — re-read both teams (lineup, attributes, roles, kits) from the club DB after the page saved them; answers with fresh TEAMS + ROSTER. Formations are not reloaded |
| 0x3A | CONCEPTS | s→c | the curriculum (1.6, G4.37), on connect: same layout as PRESETS — `u8 count`, then per concept id `u8 name_len \| name bytes` (a hole = empty name). Rows come from `game_concepts` (mig 650); it replaces the client's built-in list, and ROSTER / PLAYER_SETTINGS rating vectors are indexed by these ids (`rating_count` = this count) |
| 0x3B | BRAIN | s→c | the brain overlay (1.7, G4.41), ~5 Hz, only to clients that sent BRAIN_WATCH on: `u8 count`, then per slot `u8 why (BRAIN_LEGEND index) \| i16 target x dm \| i16 target y dm \| u8 other slot (255 none) \| u8 ladder rung (0 n/a)` |
| 0x3C | BRAIN_WATCH | c→s | anyone (1.7): `u8 on` — start / stop the BRAIN feed for this client |
| 0x3D | BRAIN_LEGEND | s→c | on connect (1.7): the decision names, PRESETS layout; a BRAIN entry's `why` indexes it |
| 0x3E | PHASES | s→c | the phase-of-play catalog (1.9, G4.58), on connect: PRESETS layout, titles from `game_phases` (mig 695); index = phase id |
| 0x3F | RUN_PHASE | c→s | admin (1.9): `u8 team \| u8 phase` (APPLY_PRESET layout) — all 22 placed in their organized shapes for the phase's ball, then the dead-ball restart (keeper / corner / kick-off) or the ball at the team's nearest outfielder (open play); unknown ids ignored |
| TBD | … | | reserved; new types are additive within a major version |

Snapshot payloads at 22 slots + 3D ball must be measured against the u16
length cap during G0 (v1 catalogued this exact risk) — if tight, SNAPSHOT
gets its own u32-length envelope before anything ships.

## 3. Client capabilities

Granted at handshake from the JWT + match config, not claimed by the client:

- `player` — may claim slots and send PLAYER_INTENT
- `manager` — may send TACTICAL_INTENT for its team
- `spectator` — receives snapshots only
- `admin` — speed control, headless batch runs (calibration harness)

A manager client is just a connection with only `manager`. FM-mode = match
with zero `player` connections. Headless calibration = `admin` + max speed.

## 4. PLAYER_INTENT (c→s, ≤1 per client tick)

High-level intents, never positions — the server owns all movement:

Layout (locked G0.3):

```
u8 slot | i64 move_x (Fixed64 raw) | i64 move_y (Fixed64 raw) | u8 action
```

- The move vector is desire, not position; the server clamps it to unit
  length, so an overlong vector buys nothing.
- `action` (one-shot; latches server-side until the next tick consumes it):
  - 0 = none
  - 1 = ground kick (1.1) — direction = move vector, else facing; preset
    power until pass attributes land (G2)
  - 2 = lofted kick (1.1) — same direction rule, adds vertical velocity
  - 3 = short pass (1.2) — 8 m/s feet-to-feet ball; same direction rule
  - 4 = shot (1.2) — 18 m/s placed strike; same direction rule
  - 5 = tackle (1.3) — committed dive at an OPPONENT'S carried ball within
    1.3 m: win pokes it loose, miss (or lunging at nothing) stuns the
    tackler ~0.5 s; owners can't tackle
  - 6 = dive (G4.51) — KEEPER only, on his feet, without the ball: a
    launch along the move vector (physics.keeper_dive speed), ballistic
    while airborne, then down on the turf; ignored for anyone else
  - press / switch-player / through-ball / cross / header contest get ids
    additively as their mechanics land.
  - Only the slot's OWNER's action fires, and only while that slot carries
    the ball.

## 5. TACTICAL_INTENT (c→s)

The manager-mode class, defined from day one even though it ships in G5:

- set formation (formation code — the DB registry id)
- set tactic state (press-high / mid-block / counter / hold)
- substitution (slot ↔ bench person)
- role instruction override (slot, instruction id)
- TBD: payload layouts locked when G5 opens; ids are registry rows.

## 6. SNAPSHOT (s→c, at tick rate)

Authoritative world state, interpolation-friendly:

Layout (locked G0.3):

```
u64 tick | u8 player_count |
per player: i64 pos_x | i64 pos_y | i64 vel_x | i64 vel_y | u8 flags |
ball (appended in 1.1):
  i64 pos_x | i64 pos_y | i64 pos_z | u8 owner_slot (0xFF = free)
match structure (appended in 1.2):
  u8 score_home | u8 score_away | u8 period |
  u16 clock_seconds (resets at full time) | u8 restart_team (0xFF = live)
levels (appended in 1.3):
  u8 level_home_id | u8 level_away_id
facing (appended in 1.8, G4.53):
  per player: i8 face_x | i8 face_y   (unit vector × 127)
```

- Players are planar (DESIGN.md §4), so player records carry **no z** —
  that's ~8 bytes × 22 players × 30 Hz saved. The ball record (added in G1,
  appended after the player array) carries x, y, z + velocity + owner slot.
- `flags`: bit0 = human-controlled; bit1 = goalkeeper; bit2 = down in
  a tackle (sliding / recovering); bit3 = dispossessed, off balance
  (all 1.4 additive, 2026-10-22 — older clients ignore them); the rest
  reserved.
- 22 players ≈ 730 B/frame ≈ 22 KB/s at 30 Hz — comfortably inside the u16
  envelope and the phone budget. Delta-encoding is a later optimization,
  never a v1 requirement.
- A restart (throw-in / goal kick / corner / kickoff) places a DEAD ball:
  only `restart_team` may take the first touch; everyone sees it via the
  1.2 tail.

## 7. EVENT (s→c + replay log)

Versioned, append-only event records ([v1] model): goal, kickoff, ball-out →
restart type, sub made, tactic changed. Events are the source for match
reports, highlights, and the calibration harness's statistics.

Layout (locked 1.1):

```
u8 event_type | u8 team | u64 tick
```

- event_type values (= `core::MatchEventType`, append-only): 1 goal,
  2 throw-in, 3 goal kick, 4 corner, 5 kickoff, 6 half time, 7 full time.
  `team` = scorer (goal) or awarded team (restarts); unused for 6/7.
- New event types append their own payload fields after `tick`; decoders
  ignore fields they don't know (§9).

## 8. Replay

Every match logs seed + all intents (v1's model). Replay = re-run
deterministically; a replay viewer is just a spectator client fed recorded
snapshots. Byte-identical replay is a standing CI assertion.

## 9. Versioning rules

- Major = breaking (HELLO rejects), minor = additive frames/fields with
  flags, patch = server-internal.
- Clients ignore unknown frame types and unknown trailing bytes within a
  frame — that's what makes minor versions safe.
- This file is the registry of frame ids; a frame id is never reused.
