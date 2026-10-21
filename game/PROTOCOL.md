# fh-game wire protocol — v1.1

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
| 0x31 | SPEED | c→s | manager/spectator: request sim speed (server-gated) |
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
```

- Players are planar (DESIGN.md §4), so player records carry **no z** —
  that's ~8 bytes × 22 players × 30 Hz saved. The ball record (added in G1,
  appended after the player array) carries x, y, z + velocity + owner slot.
- `flags`: bit0 = human-controlled; the rest reserved.
- 22 players ≈ 730 B/frame ≈ 22 KB/s at 30 Hz — comfortably inside the u16
  envelope and the phone budget. Delta-encoding is a later optimization,
  never a v1 requirement.
- Clock/score join the layout with G3 (score/clock/halves slice), appended
  per §9's additive rule.

## 7. EVENT (s→c + replay log)

Versioned, append-only event records ([v1] model): goal, kickoff, ball-out →
restart type, sub made, tactic changed. Events are the source for match
reports, highlights, and the calibration harness's statistics.

Layout (locked 1.1):

```
u8 event_type | u8 team | u64 tick
```

- event_type 1 = goal; `team` is the scoring team (0 = home, attacks +x).
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
