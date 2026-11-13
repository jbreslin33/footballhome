# fh-game wire protocol — v2.0

> **2.0 (G5.23, 2026-11-05):** the old brain's frames and fields are gone — levels
> (MATCH_SETTINGS, the snapshot's level ids), per-player concept ratings
> (PLAYER_SETTINGS, ROSTER's ratings, CONCEPTS) and attributes (PLAYER_ATTRIBUTES),
> game models and their numbers (PRESETS, APPLY_PRESET, MODEL_DEMANDS, SET_DEMAND,
> SAVE_DEMAND, MODEL_PARAMS, SET_PARAM), phases of play (PHASES, RUN_PHASE), and the
> brain entry's ladder rung, vision and call blocks. Their ids are retired, never
> reused. The subprotocol is `fh-game.v2.bearer.<JWT>`: a 1.x client is refused at
> the handshake, never desynced. Layouts below are 2.0.

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
  `fh-game.v2.bearer.<JWT>` — same shared-secret JWTs the club app already
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
| 0x34 | ROSTER | s→c | per-slot names, on connect and after changes: `u8 count`, then per slot `u8 name_len \| name bytes`; then `u8 count \| u8 position number…` per slot — the formation's traditional number the engine plays (2 RB … 6, 8, 10 … 9 striker; 0 unknown) |
| 0x38 | TEAMS | s→c | the two teams playing (1.5, G4.30), on connect: `u8 len \| home name (UTF-8) \| u8 len \| away name` — game_demo_teams names, the editor's key into `/api/game/roster` |
| 0x39 | RELOAD_ROSTERS | c→s | admin: empty payload — re-read both teams (lineup, kits) from the club DB after the page saved them; answers with fresh TEAMS + ROSTER. Formations are not reloaded |
| 0x3B | BRAIN | s→c | the brain overlay (G4.41), ~5 Hz, only to clients that sent BRAIN_WATCH on: `u8 count`, then per slot `u8 why (BRAIN_LEGEND index) \| i16 target x dm \| i16 target y dm \| u8 other slot (255 none)` |
| 0x3C | BRAIN_WATCH | c→s | anyone (1.7): `u8 on` — start / stop the BRAIN feed for this client |
| 0x3D | BRAIN_LEGEND | s→c | on connect: the decision names, `u8 count`, then per name `u8 len \| bytes`; a BRAIN entry's `why` indexes it |
| 0x45 | TEAM_LIST | s→c | (2.1, G5.35) on connect: every team a match can be made of (game_demo_teams, A-Z) — `u8 count`, then per team `u8 len \| name (UTF-8)`; the page's matchup dropdowns |
| 0x46 | NEW_MATCH | c→s | (2.1, G5.35) admin: a TEAMS payload, names only (`u8 len \| home \| u8 len \| away`) — kick off that match fresh, each side in its own formation; claims dropped; answers every client with TEAMS + ROSTER + a SNAPSHOT. Unknown, empty or equal names change nothing |
| — | retired in 2.0 | | 0x32, 0x33, 0x35, 0x36, 0x37, 0x3A, 0x3E, 0x3F, 0x40, 0x41, 0x42, 0x43, 0x44 — never reused |
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
facing (appended in 1.8, G4.53):
  per player: i8 face_x | i8 face_y   (unit vector × 127)
officials (appended in 1.16, G4.93):
  u8 official_count |
  per official: i64 pos_x | i64 pos_y | i8 face_x | i8 face_y | u8 flags
feet (appended in 2.3, G5.77), per player in slot order:
  u8 feet_down | i16 foot0_x | i16 foot0_y | i16 foot1_x | i16 foot1_y | u8 prog0 | u8 prog1
```

- Feet (2.3): the engine's footstep body (`core::Footsteps`, DESIGN §8.178).
  `feet_down` bit0 / bit1 = foot 0 (his right) / foot 1 on the ground. The
  i16s are centimetres in pitch coordinates: where a planted foot stands,
  or where a foot in the air will land (re-read every tick until it does).
  `prog` = 0..255 through the current stance or swing. 11 B per player,
  242 B for 22. A 2.2 decoder ignores the tail (§9); a 2.3 decoder of a 2.2
  frame gets no feet and the viewer falls back to its own gait.

- Officials (1.16): index 0 the referee, 1 the assistant on the +y
  touchline (judges the +x half), 2 the assistant on −y (the −x half) —
  `core::Officials`, NOT player slots (BRAIN, ROSTER, CLAIM etc. never
  index them). `flags` bit0 = flag up: an assistant whose offside call was
  whistled, for 1.5 s after it; the rest reserved. 19 B each, 58 B for the
  crew. A 1.15 decoder ignores the tail (§9); a 1.16 decoder of a 1.15
  frame gets no officials and draws none.

- Players are planar (DESIGN.md §4), so player records carry **no z** —
  that's ~8 bytes × 22 players × 30 Hz saved. The ball record (added in G1,
  appended after the player array) carries x, y, z + velocity + owner slot.
- Officials `flags` bits 1-3 (G5.2, additive): the signal for a ball out, on
  the official who called it and the referee: 0 none; 1 / 2 throw-in, attack
  toward +x / -x; 3 / 4 goal kick at the +x / -x end; 5 / 6 corner at the +x /
  -x end. Down when the ball is played or after 5 s.
- `flags`: bit0 = human-controlled; bit1 = goalkeeper; bit2 = down in
  a tackle (sliding / recovering); bit3 = dispossessed, off balance
  (all 1.4 additive, 2026-10-22 — older clients ignore them); bit4 = taking
  a throw-in, ball in both hands overhead (G5.2, additive); bit5 = his last
  kick was off his left foot (G5.79); bits6-7 = his last kick's kind, 0 none /
  short pass, 1 ground kick, 2 lofted, 3 shot (G5.112, additive).
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
  2 throw-in, 3 goal kick, 4 corner, 5 kickoff, 6 half time, 7 full time,
  8 / 9 tackle won / lost (team = the tackler's), 10 offside (awarded team),
  11 foul (team = the fouler's; sent with advantage too), 12 free kick
  (awarded = the fouled team) — 11 / 12 since G5.28, additive; 13 penalty
  (awarded = the fouled team; Law 14, G5.40), additive.
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
