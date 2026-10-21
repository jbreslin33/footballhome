# Football Home Game (v2) — 3D 11v11 — Design & Progress

> **This document is the source of truth for both design AND progress** (the
> rule inherited from v1 that made it ship). Milestones and slices below carry
> checkboxes; tick them in place as work lands. Do not create parallel
> progress files — `TODO.md` at the repo root holds only a pointer here.
>
> Predecessor: `archive/sim-2d-v1/` (2D sim, M0–M3 complete). Its DESIGN.md —
> especially the §21 blocker catalogues and §22 ADRs — is reference literature
> for this project, with no special status over the external references in §9.

## 1. What this is

A server-authoritative 3D 11v11 soccer game, playable in a browser (and later
any client), with human control of one or more players and AI control of the
rest — built as a teaching tool for real tactical knowledge, from youth to
world-cup level, and open enough to also run as a management game
(Football-Manager-style: humans set tactics, AI plays) and to decompose into
small-sided scenarios (4v4, 2v1, coach-painted drills).

## 2. Pillars (every slice is judged against these)

1. **Open system.** The engine knows physics and perception. Everything that
   constitutes soccer knowledge — attributes, behaviors, formations, tactics,
   scenarios, rules flags, level bands, copy — is data: DB registry rows and
   parameterized components, changed by migration, never by engine edits.
2. **Server-authoritative.** All game state is computed server-side in C++.
   Clients send intents and render snapshots. Zero game logic client-side;
   client prediction/smoothing is cosmetic only.
3. **Deterministic fixed point.** No floats in the sim loop. Same seed + same
   inputs = byte-identical results across architectures, locked by replay
   goldens. This is what makes permanent refactoring safe.
4. **Protocol-first.** The versioned binary wire protocol (`game/PROTOCOL.md`)
   is the product boundary. Browser, native phone, desktop C++, and headless
   clients (calibration, AI stand-ins, spectator, replay) all interoperate by
   speaking it. Clients can be built by anyone, any time, without server
   changes.
5. **Realism by calibration, not vibes.** A headless calibration harness
   simulates batches of matches and asserts statistics against real-world
   anchors (~2.7 goals/game at top level, pass-completion % by level, shot
   counts, possession splits). Once live, those assertions are CI gates: a
   change that makes the game arcadey fails the build. Anti-FIFA by
   construction.

## 3. Non-negotiables (carried from v1 — decisions, not code)

- Gameplay math is fixed point; floats never enter the sim loop.
- Binary wire format; JSON only on human-facing debug surfaces.
- Every slice lands green: containerized test suite passes before commit.
- New registry attributes/concepts arrive by migration + regenerated header +
  consistency check against the live DB.
- Determinism goldens accumulate; a golden never silently changes value.
- **Slot-count agnosticism (new):** every component must work at any team
  size. A small-sided `MatchScenario` config (3v3) keeps its own determinism
  golden in CI from day one — if a feature only works at 22 slots, the build
  fails. This is what keeps 4v4/2v1/painted drills free forever.

## 4. Architecture

```
┌────────────┐ intents  ┌──────────────────────────────┐
│  clients    │ ───────▶ │  match daemon (C++)          │
│  browser    │ ◀─────── │  tick loop · fixed-point     │
│  native     │ snapshots│  physics (3D ball, planar    │
│  desktop    │          │  players) · utility AI ·     │
│  headless   │          │  rules · event log · replay  │
└────────────┘          └──────────┬───────────────────┘
                                    │ registries, profiles,
                                    │ results, replays
                              ┌─────▼─────┐
                              │ Postgres  │  ◀── meta layer (seasons,
                              └───────────┘      training, FM careers)
                                                 lives OUTSIDE the match
                                                 engine, same DB
```

- **3D scope:** the ball gets a z-axis (lofted passes, bounces, headers);
  player locomotion is planar. The browser client renders with WebGL
  (Three.js); fidelity is client-local dressing over the same authoritative
  positions.
- **Sim speed is a server parameter**, decoupled from wall clock: 1× live,
  N× fast-forward, headless max-speed. Required by the calibration harness
  and by manager mode; trivial under determinism.
- **Match lifecycle:** per-match daemons orchestrated like v1 (container per
  match, reaper), reachable via nginx WebSocket proxy with runtime DNS
  resolution (variable `proxy_pass` — the v1 pattern that resolves at request
  time, never startup).
- **Club integration (not optional — the point).** The game runs on the club
  app's own data: game profiles key on `persons.id` (your real squad are the
  characters, at their real levels); teams/rosters/formations are the club's
  existing rows; auth is the club's JWTs, so magic links drop a player into
  the game as themselves with zero signup (v1 proved this end to end). FM
  mode manages real club teams and fixtures; painted scenarios attach to a
  real person; training/attendance can feed attribute growth over time.

## 5. AI — three layers, hand-authored, data-driven

1. **Team layer** — tactic state (press high / mid-block / counter / hold),
   ball-relative formation targets (HELIOS-style interpolation: home position
   = f(formation, ball position)). Coaching knowledge lives here as DB rows.
2. **Role/unit layer** — responsibilities within the tactic: cover shadows,
   press partners, support spots, marking assignments, third-man runs.
3. **Player layer** — utility-scored behavior bags (v1's model), filtered by
   **skill-scaled perception/decision/execution noise**. Level (youth →
   world cup) = attribute distribution + noise scale. One knob, not twelve
   codepaths.

**No neural nets / RL for players** — opaque, non-deterministic,
unteachable. ML is permitted only offline: optimizing utility weights against
the calibration harness, with the resulting numbers committed as data.
Every decision must be inspectable ("jockey scored 0.8 because lateral
dribble + positioning_sense 72") — that inspectability IS the teaching tool.

## 6. Manager mode (FM-style) — day-one hooks, later milestone

The protocol defines **two intent classes from the start**: player intents
(move/pass/shoot/switch) and **tactical intents** (set formation, make sub,
change role instruction, set tactic state). A manager client is an ordinary
protocol speaker that only sends tactical intents and watches — at 1× or
fast-forwarded. A match with zero player-clients is AI vs AI, which is also
exactly what the calibration harness runs. The career meta-game (seasons,
transfers, training-driven attribute growth) is a separate layer over the
same DB registries and never touches the match engine.

## 7. Clients

- **v2.0 client: browser**, Three.js/WebGL, barebones polygon players.
  Phone-first: virtual joystick + pass/shoot/press buttons + tap-to-switch,
  broadcast-angle camera legible on a 6" screen. Touch controls and camera
  are named milestones, not afterthoughts.
- Snapshot budget ~15–25 KB/s (22 slots + 3D ball at 20–30 Hz) — fine on LTE.
- Later, without server changes: realistic desktop C++ client, native apps,
  WASM build of the fixed-point core for offline solo practice.

## 8. Milestones

| # | Adds | Exit gate (playability checkpoint) | Status |
|---|---|---|---|
| **G0** | Protocol v1 handshake + intents/snapshots; fixed-point core (port Fixed64/FixedMath/TrigLUT concepts from v1); tick loop; WebSocket server; `make game-deploy` container test gate; Three.js client: pitch + one movable player | **You move a player around a 3D pitch from your phone.** Walking skeleton — every later slice lands inside it | not started |
| **G1** | 3D ball: dribble, ground pass, lofted kick, bounce; goal detection; first determinism goldens | **Kickabout**: dribble and shoot on a goal; two humans pass | not started |
| **G2** | Parameterized `MatchScenario`; formation anchoring; team possession state; utility-AI roles; calibration harness v0 (headless client, max-speed); standing 3v3 golden | **Playable 3v3 vs AI** — first real game | not started |
| **G3** | 22 slots; GK behaviors; restarts (kickoff, throw-in, goal-kick, corner — no offside/fouls); score/clock/halves; player switching | **Full 11v11 vs AI in the browser — THE PROTOTYPE** | not started |
| **G4** | Calibration CI gates live; level bands (youth→world cup) via attribute distributions + noise scaling; touch-control + camera polish | Realistic, level-aware 11v11 that fails CI if it goes arcadey | not started |
| **G5** | Manager mode v0: tactical intents live (subs, formation, tactic state); fast-forward; AI-vs-AI spectating | **Watch your lineup play your tactic, FM-style** | not started |
| **G6+** | Drills as `MatchScenario` configs (2v1, 4v2 press…); coach-painted scenarios; replay viewer; desktop client; WASM offline | Teaching library + client family | not started |

v1 shipped its first four milestones in ~17 days of sessions against a
15–20-week estimate; G0–G3 at that cadence is realistically a few weeks of
sessions. Slices get specced per-milestone as work opens (v1 style: numbered
slices, exit gates, goldens).

### 8.1 G0 slices

- G0.1 [x] (2026-10-21) Scaffolding + fixed-point math core **adopted verbatim from v1
  after review** (`Fixed64`, `FixedMath`, `TrigLUT`, `RngDet`, `Vec3` + their
  golden tests — knowledge-free, dimension-agnostic infrastructure; adopting
  a vetted library is not carrying old architecture). `game/CMakeLists.txt`,
  tests green on host. Landed: namespace `fh::game::math`, 5/5 ctests passed
  (fixed64, fixed_math, trig_lut, rng_det, vec3) on g++ 13 / CMake 3.28.
- G0.2 [x] (2026-10-21) Tick loop + match clock + world skeleton (slot-count
  agnostic `World` integrating sampled MoveIntents; desire clamped to unit
  length so a hostile client can't outrun max_speed) + byte-order-stable
  FNV-1a canonical hash + **first determinism golden** locked at
  `0xba2dc29b0b1bbb1a` (4 players, seeded intents, 400 ticks, seed 42).
  8/8 ctests green.
- G0.3 [x] (2026-10-21) Protocol framing: envelope codec + HELLO/GOODBYE/
  PLAYER_INTENT/SNAPSHOT/CLAIM encode/decode (`fh::game::net`), total-function
  decoders (truncation-safe, trailing-bytes-tolerant per §9). PROTOCOL.md
  §1/§4/§6 layouts locked in the same slice; players carry no z on the wire
  (planar — ball gets z in G1), 22-player snapshot ≈ 730 B ≈ 22 KB/s @ 30 Hz.
  9/9 ctests green.
- G0.4 [x] (2026-10-21) WebSocket server + daemon. [v1]'s RFC 6455 stack
  (frame codec, handshake, poll(2) transport) + HMAC-SHA256 JwtVerifier
  adopted, subprotocol rebranded `fh-game.v1.bearer.<JWT>`. New
  `fh::game::server::GameServer`: HELLO on connect, first-claim-wins slots
  (one client may hold several — "control 1 or more players"), intents
  authorized against slot ownership (the frame's slot field is a request,
  never a fact), snapshot fan-out each tick. `fh-game` daemon binary:
  env-configured, wall-clock pacing outside the sim (GAME_SPEED=0 = headless
  free-run for calibration/FM). 14/14 ctests. Dockerfile moved to G0.5
  where the container gate lands.
- G0.5 [x] (2026-10-21) Container gate: two-stage `game/Dockerfile` ([v1]
  pattern — lint gates `check_no_floats`/`check_no_bad_rng` + Release build
  + full ctest INSIDE the image build, so a failing test fails the build and
  a bad image cannot exist). Runtime stage: slim, non-root, binary + libssl.
  `make game-deploy` (compose build) + `make game-test` (fast host loop).
  First image built clean.
- G0.6 [ ] nginx `/game/<key>` proxy (variable upstream, request-time DNS) +
  compose service — the one club-stack touchpoint; coordinated deploy.
- G0.7 [ ] Browser client: Three.js pitch + player, snapshot interpolation,
  virtual joystick + keyboard, `game.html`.
- G0.8 [ ] Exit gate: **move a player around a 3D pitch from a phone over
  prod TLS**; determinism golden re-verified; G0 close-out ticked here.

### v1 explicit non-goals (do not build before G4 closes)

Offside, fouls/cards, stamina, substitutions-as-rule (subs arrive with G5
tactical intents), weather, crowd, licensed anything, client-side prediction.

## 9. Documentation & attribution (standing convention)

- **Docs live with the code and land in the same commit.** DESIGN.md and
  PROTOCOL.md are never allowed to lag the implementation; a slice that
  changes behavior updates the doc in the same slice.
- **In code:** every file opens with a purpose comment; every non-obvious
  mechanism states its constraint or reason, not its mechanics.
- **Credit the source of every technique**, in the file header or at the
  mechanism, using these tags (also used in DESIGN/PROTOCOL prose):
  - `[HELIOS]` — RoboCup HELIOS/agent2d lineage (e.g. Delaunay ball-relative
    formations, Akiyama et al.)
  - `[GRF]` — Google Research Football's rule-based AI structure
  - `[Buckland]` — *Programming Game AI by Example* (support spots, state-
    driven team play)
  - `[QUAKE]` — classic server-authoritative netcode lineage (intents up,
    snapshots down, client interpolation)
  - `[v1]` — our own archived 2D sim (archive/sim-2d-v1), adopted or adapted
  - `[FH]` — **original to Football Home** (e.g. the calibration harness as
    a CI realism gate; skill-scaled perception/decision/execution noise as
    the single level mechanism; drills-as-configs of one MatchScenario)
  - Public-domain algorithms are named plainly (e.g. FNV-1a hash).
- External code is never pasted in; techniques are learned and re-expressed
  in fixed point (§3). Credit is about intellectual honesty, not licensing.

## 10. References

- `archive/sim-2d-v1/DESIGN.md` — v1 lessons: §21 blocker catalogues, §22
  ADRs, registry/codegen machinery, orchestration + nginx routing patterns.
- RoboCup 2D / HELIOS, agent2d — ball-relative formations via Delaunay
  interpolation (Akiyama); 25 years of positioning/pressing literature.
- Google Research Football (google-research/football) — shipped rule-based
  11v11 AI in readable C++; role/mentality structure.
- Buckland, *Programming Game AI by Example* — Simple Soccer: support-spot
  scoring, state-driven team play.
- Mine all of these for AI design; re-express in fixed point. Never port
  floats.
