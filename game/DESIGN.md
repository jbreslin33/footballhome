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

### 5.1 Technique inventory & the history ladder [FH]

- **Techniques by layer** (what "utility AI" concretely means here):
  team layer = finite state machine over tactic states [Buckland's team
  states]; role layer = cost-minimizing assignment (who presses / covers /
  outlets) [HELIOS marking]; player layer = utility-scored behavior bags
  with hysteresis [v1], executed through steering behaviors (seek / arrive /
  pursue / interpose) [Reynolds via Buckland]. G2 ships the primitive form:
  steering + a priority rule list + linear formation shift; each upgrade
  replaces a piece in place. Next majors: [Buckland]'s support-spot
  calculator (the passing game's heart) + his messaging pattern for
  coordination; [HELIOS] Delaunay formations; someday [HELIOS] chain-action
  search for pass sequences. [GRF]'s rule-based 11v11 is the sanity
  benchmark.
- **Tactics are implanted, not evolved.** Mechanics must land in dependency
  order — which IS soccer's historical order (no passing game without a
  pass, no WM without positions, no gegenpress without press triggers) —
  but tactical knowledge arrives off-the-shelf as registry data, never
  rediscovered by self-play (§5's no-RL charter).
- **The history ladder = the level ladder [FH].** U-8 swarm ball IS 1860s
  soccer; positional U-12 is the 1900s; a pressing high-school side is the
  1980s; pro positional play is the 2020s. Levels therefore combine
  attribute/noise scaling with TACTICAL ERA, and a campaign through soccer
  history ("beat the pyramid", "break catenaccio", "escape the gegenpress")
  is a coaching curriculum disguised as a game — teaching content for free.

### 5.2 Rated tactical understanding — the knowledge triple [v1]

Tactical intelligence is per-player DATA in three registries (v1 built all
three: attribute registry, concept registry, PatternRegistry +
RecognitionSystem — v2 inherits the model):

1. **Recognition** — *can you see it?* Named patterns are computed from
   world state (e.g. `high_line`: opponents' rear line x + space behind);
   a player's recognition rating decides IF and HOW EARLY their brain is
   told the pattern fired.
2. **Concept** — *do you know the answer?* Concepts gate which behaviors
   are in a player's bag (`play_over_the_top` responds to `high_line`).
3. **Execution** — *can you pull it off?* The kick/control attributes +
   skill noise decide whether the answer comes off.

"Sees the high line and plays over it" = three separately rated, separately
trainable rows — so every failure is diagnosable (didn't see / didn't know /
didn't execute), which is the teaching thesis in one sentence. Second worked
example: `deep_block` + `ball_side_overload` recognitions → `switch_play`
concept (v1's SwitchSideSupportBehavior is already implemented + tested in
the archive's seven unwired behaviors) → long cross-field pass execution.
The pattern vocabulary grows as registry rows: `pressing_trap`, `keeper_off_
line`, `third_man_free`, … — each one a lesson a coach can rate and train. Tactical
eras (§5.1) are level-band bundles of concepts + recognitions; painted
scenarios can target one pattern; training/attendance raises specific rows.

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
| **G0** | Protocol v1 handshake + intents/snapshots; fixed-point core (port Fixed64/FixedMath/TrigLUT concepts from v1); tick loop; WebSocket server; `make game-deploy` container test gate; Three.js client: pitch + one movable player | **You move a player around a 3D pitch from your phone.** Walking skeleton — every later slice lands inside it | **done** (10/21) |
| **G1** | 3D ball: dribble, ground pass, lofted kick, bounce; goal detection; first determinism goldens | **Kickabout**: dribble and shoot on a goal; two humans pass | **done** (10/21) |
| **G2** | Parameterized `MatchScenario`; formation anchoring; team possession state; utility-AI roles; calibration harness v0 (headless client, max-speed); standing 3v3 golden | **Playable 3v3 vs AI** — first real game | **done** (10/21) |
| **G3** | 22 slots; GK behaviors; restarts (kickoff, throw-in, goal-kick, corner — no offside/fouls); score/clock/halves; player switching | **Full 11v11 vs AI in the browser — THE PROTOTYPE** | **done** (10/21) |
| **G4** | Calibration CI gates live; level bands (youth→world cup) via attribute distributions + noise scaling; touch-control + camera polish | Realistic, level-aware 11v11 that fails CI if it goes arcadey | **in progress** (G4.1-G4.14; CI gate LIVE) |
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
- G0.6 [x] (2026-10-21) nginx `/game` proxy (variable upstream + resolver =
  request-time DNS, so nginx starts with the daemon down — the old /sim
  literal-host footgun avoided) + `footballhome_game` compose service.
  Deployed; the retired sim container was removed in the same deploy.
- G0.7 [x] (2026-10-21) Browser client: `game.html` + `js/game/` (wire
  codec via DataView/BigInt, WS subprotocol auth reusing the club session
  token, Three.js broadcast-camera pitch, 100 ms snapshot interpolation
  [QUAKE], tap-to-claim, WASD + anchored virtual joystick). JwtVerifier
  extended to the club backend's real claim shape (`userId` as JSON string
  = users.id; users.id → persons.id mapping lands with G2's DB layer).
  G0 spawn: two facing team lines via `World::placePlayer` (golden
  unaffected — its world never places).
- G0.8 [~] Exit gate verified end-to-end on DESKTOP against live
  footballhome.org (2026-10-21): claim → drive → 17.0 m east at exactly
  6 m/s, server-computed, through host nginx + container nginx + daemon
  with a real club JWT. 14/14 ctests green, golden intact. **Remaining:
  James's phone test, then tick this box.**

### 8.2 G1 slices — the ball

- G1.1 [x] (2026-10-21) 3D ball in `core`: gravity + ground bounce (restitution) on z,
  [v1]'s multiplicative roll decay + snap-to-rest + kick-alive runway on the
  ground plane (constants re-derived for 30 Hz), arcade boundary walls at
  the pitch edges ([FH] placeholder until G3 restarts replace them —
  kickabout must not lose the ball). World gains pitch dims + the ball;
  canonical hash extends to ball state; **golden re-locked once, here**.
- G1.2 [x] (2026-10-21) Possession: automatic first-touch capture (slow ball within
  [v1] control radius 0.5 m, nearest wins, lower slot breaks ties), glue
  carry 0.4 m ahead of movement, no stealing yet (press arrives G2).
- G1.3 [x] (2026-10-21) Kick actions via the intent `action` field (1 = ground kick,
  2 = lofted kick; direction = move vector, else carry direction; preset
  powers). Actions latch until consumed by the next tick. Goal detection:
  mouth AABBs at x = ±half_x (7.32 × 2.44 m), goal → event + kickoff reset.
- G1.4 [x] (2026-10-21) Wire 1.1 shipped end to end: SNAPSHOT ball tail,
  EVENT goal frames; client renders ball + goal frames, Space/PASS and
  X/LOFT kick controls (keyboard + touch buttons), goal flash + running
  score from server events only.
- G1.5 [~] Exit gate verified on DESKTOP against live footballhome.org
  (2026-10-21): claimed #6, ran onto the loose ball, auto-captured, glue
  dribble, lofted chip (flight apex 1.74 m), ball outran the chase, rolled
  in — server GOAL event, "GOAL! 1 — 0", kickoff reset. **Remaining:
  phone kickabout (ideally 2 humans passing), then tick.**
- Known gap logged during verification: PLAYERS have no pitch bounds (the
  scorer chased the ball straight off the grass). Fine for G1 arcade walls
  era; G2's formation/positioning work should clamp player positions to
  pitch + margin.

### 8.3 G2 slices — shape and brains

- G2.1 [x] (2026-10-21) Player pitch bounds (clamp to pitch + 2 m margin — the G1 live
  test watched a scorer sprint into the void). Changes the state surface →
  golden re-lock batched with G2.2's.
- G2.2 [x] (2026-10-21) Formations as data-shaped specs: per-team-size base positions
  (11 = 4-4-2, 3 = 1-1-1, generic lines otherwise) + ball-relative anchor
  shift ([HELIOS]-lite: translate the shape toward the ball, clamped;
  the full Delaunay interpolation and the DB formation registry with
  [v1]-style migration→codegen land in their own slice before G3 closes —
  in-code specs are an explicit, documented stopgap).
- G2.3 [x] (2026-10-21) Team setup (World::setTeam) + possession state (ours / theirs / loose, from ball
  owner's team) feeding the AI.
- G2.4 [x] (2026-10-21) First AI brains for every un-claimed slot, deterministic and
  pure ([FH]/[Buckland]-lite utility): hold shifted anchor; nearest to a
  loose ball chases; nearest presses an opposing carrier; an AI carrier
  dribbles at goal and shoots inside 22 m (aim = goal centre, kick = the
  existing action path). Humans always override by claiming; released
  slots revert to AI.
- G2.5 [x] (2026-10-21) Calibration harness v0 [FH]: `fh-game-calibrate` headless tool —
  N AI-vs-AI matches at free-run speed, prints goals/game + possession
  split; ctest sanity gate (a match completes; goals in a sane band).
  Protocol-speaking harness replaces it when orchestration lands.
- G2.6 [x] (2026-10-21) Standing 3v3 golden (slot-count agnosticism enforced in CI) +
  11v11 AI-match golden; client Q-key cycles held players.

**G2 calibration log (the harness earning its keep on day one):** run 1
caught chasers stopping 1.5 m from a 0.5 m-capture ball (100% loose);
run 2 caught kicks being unreceivable (capture cap 8 < kick 14 — raised to
20: receiving and intercepting became the same mechanic); run 3 exposed
shot-stutter self-recapture (fixed: 0.5 s kicker lockout) and that pressing
without STEALING is cosmetic (one-sided 160–0 cycles) — touch-to-steal
[v1 contest lineage] added (0.6 m, 10 ticks); runs 4–5 showed kick-under-
pressure degenerates to ping-pong (50–79% loose) — carriers carry, steals
supply turnovers. Shipped level: symmetric 112–91, possession 40/38/20,
saves + steals + end-to-end play. ~203 goals/game vs the ~2.7 anchor is
G4's job (GK hands, passing, shot noise, touch quality all precede tuning).

### 8.4 G3 slices — a real match

- G3.1 [x] (2026-10-21) MatchEvent generalization (Goal / ThrowIn / GoalKick / Corner /
  Kickoff / HalfTime / FullTime, each with a team) replacing the bare
  GoalEvent; wire EVENT ids assigned once in PROTOCOL.md.
- G3.2 [x] (2026-10-21) Restarts replace the arcade walls: last-touch tracking; side
  line → throw-in at the crossing point (other team); end line outside the
  mouth → corner (attackers, nearest corner) or goal kick (defenders);
  goal → kickoff awarded to conceders. A restart places a DEAD ball only
  the awarded team may first-capture; AI opponents hold anchors instead of
  crowding it (no hands/thrower animation — a throw-in is a kick in v0,
  documented). NO offside, NO fouls (charter).
- G3.3 [x] (2026-10-21) Score, match clock, halves in World (period 1/2, configurable
  half length, kickoff alternates; no side swap in v0 — documented);
  FullTime → score/clock reset + restart (match 1 is a perpetual sandbox).
  State surface grows → goldens re-locked once, batched here.
- G3.4 [x] (2026-10-21) Wire 1.2: SNAPSHOT appends score/period/clock/restart-team
  (additive); client scoreboard (score + mm:ss + period), restart/goal
  status toasts, AUTO toggle (auto-switch active to held player nearest
  the ball) + Q-cycle kept.
- G3.5 [~] Exit gate verified on DESKTOP (2026-10-21): live sandbox match
  on footballhome.org with running scoreboard (watched 1-0 become 1-1),
  "Kickoff — away" toast after the goal, dead-ball restarts in the 1.2
  snapshots; 5-minute halves (GAME_HALF_MINUTES). Calibration with
  restarts: symmetric 146-145, possession 33/32/34, 10-min sanity = 27
  goals (band holds). **Remaining: James plays a timed match on his
  phone, then tick.** Goldens re-locked for the G3 surface (history in
  test_determinism_core).

### 8.5 G4 slices — the passing game & toward realism

- G4.1 [x] (2026-10-21) The passing game [Buckland]-lite: carrier evaluates
  forward receivers (progress-scored, 5–30 m window, 2 m lane check via
  point-segment distance), passes when pressed or when the gain is big;
  ShortPass action (8 m/s) inside 14 m, driven ball beyond; loft-clear only
  when touch-tight with no outlet. One support teammate (nearest to the
  carrier) runs a chosen-side spot 12 m ahead ([Buckland] support-spot
  sampler replaces this). **Calibration: 291 → 10.0 goals/game (5–5
  symmetric), 10-min sanity 3 goals** — the single biggest realism jump so
  far; the 1860s→1890s transition on the §5.1 ladder. AI goldens re-locked.
  Note: "possession %" now undercounts (pass flight counts as loose) —
  attribute in-flight ball to last-touch team in a later metrics slice.
- G4.2a [x] (2026-10-21) Formations from the CLUB's own `formations` table
  — no new tables, no migration: the lineup picker's positions_json rows
  ARE the AI shapes (Postgres expands the JSON server-side; the daemon
  never parses JSON). Boot-time load only, loud FALLBACK to built-ins when
  the DB is down (goldens/tests use built-ins, never the DB). Compose:
  GAME_FORMATION_HOME=4-4-2 / AWAY=4-3-3 + explicit POSTGRES_* (password
  matches the db service, not the env file). Live: home plays the club's
  4-4-2, away its 4-3-3; a formation added on the club page is instantly
  a playable AI shape.
- G4.2b [ ] Attribute/concept/recognition registries + per-person profiles
  ([v1] migration→codegen; needs minted migration numbers) and the
  users.id→persons mapping.
- G4.3 [x] (2026-10-21) Skill noise + level bands [FH]: LevelParams
  (perception delay ticks / kick angle+power error / decision jitter) per
  team; noise = PURE hash of (match_seed, tick, slot, channel) so brains
  stay pure and replays byte-identical; perception = linear backtrack (no
  history state); error scales by kick kind (short pass ½, drive 1, loft
  1¼); zero params = the baseline every earlier golden locks (hash grew
  the config fields — one re-lock). Bands u10→world via GAME_LEVEL_HOME/
  AWAY + GAME_MATCH_SEED (seeds finally vary matches). **Measured ladder,
  monotone: perfect 10 / world 19 / semipro 89 / amateur 182 goals per
  game; pro vs u10 ≈ 175–40.** Sandbox defaults world/world. Negative
  result recorded: naive fixed-lead interception made every level WORSE
  (perfect 10→394) — proper closing-speed interception is its own slice.
  Ordering note: G4.2b (per-person profiles) deferred until slots map to
  persons (team/lobby selection) — it had no consumer yet.
- G4.4 [x] (2026-10-21; closed by G4.14) Defense-as-structure + keeper hands +
  touch quality. James's two laws drove the slice: **"the thing that stops
  goals really is the bunching"** and **"the swarming of defense and the
  bunching of the offense is what stops goals."** Shipped mechanics:
  keeper hands (1.2 m reach, 2.2 m height, +6 m/s hands bonus, high-ball
  catch) + angle play + dive-lite (fast incoming ball → track its actual
  trajectory); touch quality (ball faster than your level's control speed
  bobbles off the first touch, ±60° noise deflection — receiving and
  intercepting degrade together); Shot action (18 m/s — 24 measured as
  uncatchable pinball, reverted) with far-corner placement away from the
  keeper; defensive SHAPE — compactness cap (no anchor >10 m upfield of
  the ball), back-line depth cover (track the deepest runner, no offside
  law yet), cover man (2nd-closest sits on the ball→goal line 7 m
  goal-side); and the swarm_pct level dial (the U-10 amoeba crowds its own
  attack AND barricades its goal — shape discipline IS a skill).
  **Measured ladder (mirrors, 90 min): perfect 0 / world 0.5 / semipro
  9.5 / amateur 26 / u10 58 goals per game.** Sandbox = semipro (3-4 and
  8-4 scorelines). The four items that were owed for this [x] — keeper
  reaction-time knob, interception closing-speed math, possession metric
  (flight → last-touch team), CI assertion bands — all landed in G4.14
  (§8.9).

### 8.6 G4.8 — the attack learns to run, and soccer reinvents offside

- Off-ball attack: run-in-behind by the most advanced disciplined
  attacker, back outlet (second support, 8 m goal-side) completing the
  triangle, over-the-top LoftedKick to a receiver beyond their last
  outfield line (§5.2's "sees the high line, plays over" — live).
- **The history ladder proved itself in the harness**: runs-in-behind
  instantly recreated 1860s goal-hanging (world 13→28 goals/game camping
  behind the line) — the exact problem the real offside law was invented
  for. So offside landed (charter amended, by measured need): flags armed
  per kick vs the second-last opponent + ball + halfway line, whistle on
  flagged first touch, dead-ball free kick, Offside match event (id 10).
- Then the SECOND emergent lesson: line-riding runners × man-tracking
  depth cover = a retreat spiral walking both lines into the goalmouth
  (0 offsides, goals UP). Fix: the back line HOLDS ≥ ball−25 m — which is
  what makes run timing a real problem (and the trap possible later).
- Keeper sweeping (free ball in the defensive third is the keeper's,
  hands and all) — gated as an ADVANCED concept (swarm < 40): two
  sweeping U-10 keepers measured a 97%-loose swamp and inverted the
  ladder. U-10 keepers stay rooted, as in life.
- Flat +5° shot difficulty on top of level error (1° finishing converted
  like penalties).
- Ladder as locked: u10 37 / u14 27 / amateur 26 / semipro ~27 / world 17
  (90-min mirrors) — endpoints right, middle compressed. The SYSTEMATIC
  parameter sweep via the harness (not sequential nudging) is the
  remaining G4.4 work, now with offside/tackle/sweep counters to target.

### 8.7 G4.9 — concepts become per-player, editable, fictional-rostered

- game/CONCEPTS.md: the knowledge taxonomy (10 wired concepts with bit
  ids + the build queue through team-tactics tier). James's standing
  instruction: MORE detail than FIFA/FM ever simulates — understanding is
  the product.
- Per-slot concept masks gate every knowledge branch in the Brain (the
  swarm>=40 team gate decomposed into per-player bits; band bundles
  reproduce prior behavior exactly — goldens unchanged).
- Wire 1.3: PLAYER_SETTINGS (0x33, admin) + ROSTER (0x34, names + masks).
  In-game EDIT mode: tap a player, tick his knowledge, APPLY — live.
- Fictional demo rosters (mig 628, James: real teams are a bad idea
  during dev): five teams filling the ladder — Lighthouse XI (world),
  Harbor Athletic (semipro), Sunday Albion (amateur, with 'Old Gio':
  full knowledge, 4.8 m/s legs), Tide U14, Minnows U10 (with 'Lily
  Park', the coached kid who marks while her team swarms). Per-player
  names + speeds + concept overrides from the DB; GAME_TEAM_HOME/AWAY
  select; roster band overrides level env. Verified live: drove "Karl
  Brandt", edited "Luis Serra" down to 8 concepts from the page.

### 8.8 G4.13 — presets become rows, identity becomes one tap

- Mig 630 (`game_style_presets` + `game_style_preset_ratings`): the
  auteur canon (CONCEPTS.md schools) + THE CLUB PRESET "Lighthouse" as
  DB rows — concept NAMES not bit ids (names survive bit growth), every
  Lighthouse rating citing its verbatim docs/game-model/ source line.
- Overlay semantics: a preset carries only the dials it names; applying
  it leaves unnamed concepts at their current rating (explicit 0 rows are
  meaningful — Sacchi zeroes man-mark). `applyPresetOverlay` in
  Levels.hpp, unit-tested.
- Wire 1.4: PRESETS (0x35, s→c catalog on connect — names only, id =
  index, vectors stay server-side) + APPLY_PRESET (0x36, c→s admin:
  `u8 team | u8 preset_id`) → fresh ROSTER. PROTOCOL.md 0x33/0x34 docs
  caught up to the graded form G4.11 shipped.
- Edit mode grew the preset bar: dropdown + → H / → A — a coach paints a
  team identity in one tap. DB down = no PRESETS frame, bar stays hidden;
  goldens untouched (presets only act when applied).

### 8.9 G4.14 — the sweep that found the keeper, G4.4 closed

The G4.11 grading had quietly INVERTED the ladder (measured at slice
start: pro 37 / world 30 / u10 30 goals per game) — three slices of
golden-gated work never noticed, which is exactly why the calibration CI
gate exists. Diagnosis was instrumentation, not nudging: the harness grew
possession-by-last-touch (the G4.1 metric gap, closed), shots + goal
anatomy (breakaway flag, scoring distance, PRE-TICK keeper geometry — the
Goal event fires after the kickoff reset and the first readings were
reset-state garbage), and dial-override args for no-recompile sweeps.

What the instruments found, in order:
- **Keepers were the whole inversion.** Beaten keepers measured 12-14 m
  off their line: the keeper block never `return`ed, so keepers fell
  through into the outfield counter-press/chase branches and hunted balls
  28 m upfield. The one-line fix (keepers do ONLY keeper things) took
  world 32 → 0.7 overnight. Supporting fixes: sweep gated on WINNABLE
  ("is it mine?" — keeper must beat the nearest opponent by 2 m), and the
  keeper's arrive radius cut 1.5 → 0.5 m (hands reach 1.2 m; the shared
  radius left a dead band where he stood watching the ball pass).
- **u14 keepers watched tricklers roll in**: a 14 m/s youth shot decays
  to ~7 m/s over 17 m of grass, arriving UNDER dive-lite's 12 m/s "is a
  shot" gate. The gate now asks "is it moving goalward" (4 m/s).
- **Keeper parry**: a beaten-control keeper's bobble was direction-
  preserving — u14 keepers deflected 23% of shots into their own net.
  Parries now always push away from goal.
- **Keeper reaction knob** (the owed G4.4 item): `keeper_reaction_ticks`
  per band — the keeper holds his angle-play spot for the first reaction
  ticks of a shot's flight. Physiological values (world 8 ticks ≈ 0.27 s
  … u10 18). Brain-side dial, deliberately NOT in the canonical hash.
- **Strike power is a skill**: shot speed caps at the band's
  control_speed + 6 (a U-10 "blast" is 12 m/s); kShotSpeed restored to
  24 m/s — above the 20 m/s outfield capture cap, so only keepers can
  handle a top-band strike. Placement aims 3.3 m inside the post.
- **Closing-speed interception** (the owed G4.3 negative-result redo):
  earliest-reach point on the ball's friction path, bounded 48-tick scan
  (can't aim past the catchable point, unlike the fixed-lead that
  measured worse). Ungated it re-broke the ladder both ways (u10 22,
  world 1.9), so it landed as concept bit 20 `intercept` — graded,
  per-second rolls, in the swarm<40 bundle.
- **Keeper distribution**: keepers never dribble out; open pass at ANY
  gain, else PUNT to the emptier wide midfield channel.

**Locked ladder (12-match 90-min mirrors, 2026-10-21): u10 12.7 /
u14 14.7 / amateur 9.1 / semipro 2.6 / pro 2.8 / world 2.2 /
perfect 0.8 goals/game** — first-ever realistic magnitudes (real-world
anchor 2.7; prior best had world at 17). u10/u14 are adjacent chaos
bands within noise of each other; the top three sit AT the anchor.
`test_calibration_bands` (ctest, ~25 s, 4-match samples) asserts the
ladder's SHAPE — u10 ∈ [6,25], amateur ∈ [4,16], world ∈ [0.5,6],
u10 > amateur > world, u10 ≥ 2×world — so the next silent inversion
fails the build instead of waiting three slices. AI goldens re-locked
(3v3 0x711f559f…, 11v11 0x694fffef…); zero-param determinism goldens
untouched.

### 8.10 G4.15 — teams wear their identity

Mig 631: `game_demo_teams.style_preset` names a mig-630 preset; the
daemon overlays it onto the team's ratings at boot and re-applies it
after every MATCH_SETTINGS band reset, so the identity survives level
changes. Lighthouse XI boots wearing "Lighthouse" — the club game model
(docs/game-model/) PLAYING, not just spec'd. Boot log names the worn
preset. No wire changes; the edit panel shows the overlaid ratings via
the ordinary ROSTER frame.

### 8.11 G4.16 — restraint: the anti-tackle

CONCEPTS.md queue bit wired: `restraint` (bit 21), the pro's discipline
NOT to dive. All three dive sites scale their per-tick eagerness by the
rating (x0.2 at 100); the step stays real (organized teams still step).
Measured: world-band dive attempts 245 → 127 per match (a real match has
~35 tackles — directionally right, volume still generous); u10 unchanged
at ~3,500 attempts (rating 0 — kids dive, as in life). World keeper
reaction re-centred 8 → 9 ticks to hold the anchor. Refreshed 12-match
ladder: u10 12.7 / u14 14.7 / amateur 7.7 / semipro 3.1 / pro 1.7 /
world 2.8 / perfect 1.2 — world EXACTLY at the 2.7 real-world anchor.
AI goldens re-locked; bands test green.

### 8.12 G4.17 — tackle timing: dive on the exposed ball

CONCEPTS.md queue bit wired: `tackle_timing` (bit 22), the companion to
G4.16's restraint. The carried ball glues ahead of the carrier's FACING
(§ the [v1] glue), so the engine-honest reading of "dive on the heavy
touch, not on faith" is geometric: a defender in the carrier's front
half-plane pokes through the ball; a lunge from behind goes through the
man. Rated players suppress the from-behind dive (x0.1 at 100) and keep
the ball-side dive at the restraint-scaled rate. Dive eagerness moved to
a tenths scale in the same change — the old integer math was rounding
away most of restraint's suppression (world eagerness 4→2 instead of
4→1.056), so part of this slice's drop is restraint finally applying at
its spec'd strength. Measured (12-match 90-min mirrors): world resolved
dives 127 → ~50 per match against the ~35 real-tackle anchor, and the
dive ladder is now monotone with skill — u10 3,878 / u14 1,071 /
amateur 163 / semipro 119 / pro 67 / world 50 (kids dive, pros pick
their moment). Goals ladder refreshed: u10 12.7 / u14 14.7 / amateur
7.2 / semipro 2.8 / pro 2.8 / world 3.1 / perfect 1.4 — world a hair
above the 2.7 anchor, within sample noise (bands test green). 11v11 AI
golden re-locked (0x0d7303454c42cdda); 3v3 golden unchanged.

### 8.13 G4.18 — counter attack, and the harness learns where goals come from

Built `counter_attack` (bit 23, KNVB moment 4): carrier gain threshold
collapses inside a fast-break window, a second runner joins the run in
behind. Band-wide it took world 3.1 → 5.8 goals — so before tuning, the
harness learned to see goal ORIGINS, and what it saw re-scoped the slice:

- **"Wins" 0.6 s before the goal.** A keeper parry or a block makes the
  defenders last-touch, so the attacker collecting the rebound registers
  a turnover — the window was opening on rebounds in the box. World now
  records `turnoverBallX` (not in the canonical hash); a counter = ball
  won in your OWN half.
- **Goal origin by band** (12×90-min mirrors, pre-slice brain): semipro
  10 of 33 goals are counters (~30% — real-world-like); world **0 of
  37** — 35 are SCRAMBLES (win < 3 s before the goal: 17 off keeper
  parries, 18 off outfield deflections). The world band hits the 2.7
  anchor for the wrong reason: airtight structure, every goal a second
  ball. Anything adding bodies near goal inflates world scoring.
- **Possession churn — the root.** Changes per match by cause: amateur
  691 (7.8 s each), semipro 1,097 (4.9 s), **world 2,459 (2.2 s — worse
  than u10's 2.3 s)**, of which 2,230 are a loser's kick collected by the
  other side. Real football: ~200–250 possessions. The asymmetry: G4.14
  taught DEFENDERS the earliest-reach read (`intercept`), but PASSERS
  still judge a lane by a static 2 m corridor at current positions —
  the better the band, the more passes are read. Counter funnel at
  semipro (own-half wins → final third ≤10 s → shot): 413 → 155 → 96
  per team per match, and the counter identity moved none of it
  (416 → 149 → 95) — breaks die to churn, not to lack of intent.

Shipped at the scope the evidence supports: `counter_attack` is a STYLE
concept [S] (default 0, out of the band bundle — every golden is
byte-identical to G4.17) with **no preset rows yet** (head-to-head it
measured null-to-harmful; rows — incl. Lighthouse's sourced "attack
quickly with numbers… before the opponent can recover" — land once
possession can last). Harness grew: counter/scramble goal classes,
scramble cause (parry / deflection / poke), the counter funnel, churn
anatomy, and argv[9] home-team concept overrides ("name:rating,...") for
head-to-head identity tests.

**Next — G4.19, pass safety [Buckland]:** the passer runs the
interceptor's closing-speed math against every opponent on the pass's
friction path and rejects passes someone reaches first. Targets: world
churn toward ~250 changes/match, goals from scrambles toward a minority,
then re-measure counter_attack and land its preset rows.

### 8.14 G4.19 — pass safety: the team learns to keep the ball

`safe_pass` (bit 24, band bundle, graded, rolls per second) [Buckland]:
1. **Read the interceptors.** The passer walks the ground pass's friction
   path in 3-tick strides; unsafe if any opponent reaches a point
   (max_speed × (t − 0.2 s) + reach) before the receiver stepping to meet
   it (ties to the defender). Verticality shrinks the 1 m reach to 0.6 m
   (accepts risk). Balls lofted over the line are exempt.
2. **Recycle.** Pressed with nothing safe forward → the most progressive
   SAFE pass in any direction. The old loop only considered receivers
   ≥ 3 m forward, so the G4.8 "safety valve" back outlet could never
   actually receive.
3. **Clear only in your own third.** The A/B that found it: the
   touch-tight "clear over the press" fired anywhere and was 858 of
   world's 989 lost kicks per match; without it possessions went
   5.1 s → 12.2 s. Readers now keep it outside their defensive third.

Two traps measured along the way: a per-TICK roll at rating 92 leaves a
blind tick inside 92% of one-second carries (the pass fires on exactly
that tick) — duties roll per second; and short/driven passes lost fell
from ~2,200 to ~32 per world match once read, so what remained was
never passing.

**Churn ladder (12×90-min mirrors, changes/match → avg possession):**
u10 2,346 (2.3 s, unchanged — kids don't read) / u14 1,530 (3.5 s) /
amateur 622 (8.7 s) / semipro 641 (8.4 s) / pro 577 (9.4 s) / **world
2,459 → 535 (2.2 s → 10.1 s)** / perfect 650. Real football ~200–250.
**Goals:** u10 12.7 / u14 14.7 / amateur 5.4 / semipro 1.8 / pro 1.8 /
world 2.2 / perfect 0.8 — world's first counter goals (3 of 26). Bands
test green; AI goldens re-locked (3v3 0x20c5332a…, 11v11 0x2124a848…).

counter_attack re-measured as promised: possession lasts now, yet the
identity still gains nothing reaching the final third (semipro 65 → 58
per match) and concedes more. Passing forward sooner isn't what makes
a break: the carrier must RUN WITH THE BALL into space. Stays inert, no
preset rows; carry-into-space queued.

**Next — shot selection.** Keeping the ball exposed the last pinball
source: carriers now dribble into the 22 m ring and ALWAYS shoot —
world 259 shots/match (real ~25), 223 of its lost kicks are shots.
Shoot on chance quality (angle, distance, keeper position, blockers),
not on range; then re-tune keeper reaction against real shot volume.

### 8.15 G4.20 — players stop jittering (James: "players jitter")

James's live report, then his diagnosis as a question: "are they flipping
between states?" — yes. The harness grew a jitter metric (ordered-heading
reversals > 90° between ticks, and go-stop flicker) split by role, and a
temporary branch tag (source line per order) attributed every flip.
Measured in the live matchup (world vs semipro), pre-existing — G4.19
didn't cause it (prior commit identical):

- **Bang-bang steering.** World sets velocity = desire × max_speed with
  no acceleration; `seek` returned full speed or a dead stop, so every
  off-ball player tracking a drifting anchor stop-started ~3-4×/s
  (~4,000 flickers/min). Fix: continuous arrive ramp [Reynolds, via
  Buckland] — full speed outside the arrive radius, linear to zero at a
  settle radius; never overshoots. Anchor-HOLD settles at 0.5 m (anchors
  wobble with every touch; chasing the wobble shuffled and spun bodies).
- **Per-tick consistency rolls on sustained duties** (marking, recover,
  double-team, keeper sweep): a rating-92 marker dropped his man on 8%
  of TICKS (semipro: 32%). All duties now roll per second (G4.19's
  lesson, applied everywhere; over-the-top stays per-tick — a one-shot
  kick choice).
- **Recover ↔ anchor fight**: a forward caught upfield "recovered"
  behind the ball, crossed it, and his anchor pulled him back up. Only a
  player whose ANCHOR is goal-side of the ball is beaten.
- **Marks dropped on every opponent pass**: marking required an
  opponent CARRYING the ball; their pass in flight released all markers.
  Their ball now includes their pass in flight.

**Off-ball, per minute: flicker 3,699 → 35; reversals 1,023 → 308** (~one
re-orientation per player every 3.5 s — ordinary football). Calmer
defenders reshaped goal ORIGINS: semipro 14 of 41 goals are counters
(34%), world 6 of 14 — scrambles no longer dominate. Ladder (12×90):
u10 12.2 / u14 13.5 / amateur 8.0 / semipro 3.4 / pro 1.9 / world 1.2 /
perfect 1.9. Bands green; goldens re-locked (3v3 0x91d77760…, 11v11
0x77151252…). Shot selection (§8.14's next) resumes as G4.21.

### 8.16 G4.21 — shot selection, and what it proved about the box

`shot_selection` (bit 25, band bundle, per-second roll): shoot on chance
quality — visible goal angle (fx_atan2) halved per outfield body inside
the shooter→post→post triangle — at ≥ 0.30 rad (0.18 pressed), always
inside 8 m. Kids still shoot on range.

Ladder (12×90): u10 12.2 / u14 13.5 / amateur 7.5 / semipro 3.3 / pro
2.7 / world 3.0 / perfect 2.4 — pro and world AT the 2.7 anchor, and
goals are now mostly built, not scrambled (semipro 21 of 40 counters, 4
scrambles). Bands green; 11v11 golden re-locked (0xb80b68b7…; 3v3
unchanged).

**But shot VOLUME didn't move (world ~276/match vs real ~25):** the bar
sweep (u45/p30 → world 4.5 goals, u60/p40 → 16.2, u80/p55 → 31.8, shots
flat at ~240-276) showed a carrier who declines one shot gets a better
one later. Shipped at the safe 30/18 point. *(The diagnosis first written
here — "defenders delay into their own six-yard box" — was WRONG; G4.22
measured it. See §8.17.)*

### 8.17 G4.22 — the shot flood is a ball-winning problem (investigation)

No behavior shipped; the harness grew shot anatomy (depth bucket +
nearest defender at the strike) and the record is corrected. Measured
(world mirrors):

- **Shots are NOT box shots:** <8 m 1 / 8-16.5 m 11 / beyond the box
  **267** per match; a defender within 2 m on 68%. G4.21's six-yard-box
  diagnosis was wrong.
- **Not a counting artifact** (0 of ~250 shot orders issued while
  stunned), **not a rebound loop** (~88% of a team's shots come 15 s+
  after its previous one), **not the per-second roll leak** (home
  shot-selection forced to 100: 132 vs 136 shots).
- Tried and measured, all leaving volume at ~240-265: pressed discount
  only inside the box; a body within 1 m of the shot triangle blocks
  (moves shots closer: 8-16.5 m 11 → 109); `block-shot` (no delay within
  25 m of goal, cover man 7 → 2 m in the lane); final-third patience
  (recycle unpressed). Re-sweeping the bar on top of all of it: world
  4.7 → 18.5 → 24.9 goals as it rises, shots flat at ~240.

**Conclusion:** each attack ends in exactly ONE shot — the bar only sets
its quality — because possessions don't end any other way: world
defenders dispossess a dribbler ~8 times (tackle) + ~70 (steal) per
match. G4.16/17 made defenders DISCIPLINED (dive less, time it); nothing
makes them able to WIN it once engaged. Real: ~100 possessions per team
with ~12% ending in a shot (here ~330 and ~40%).

The defending mechanisms are realistic but alone only cut shot QUALITY
(world 3.0 → ~1 goal/game), so they're parked on branch
`game/g4-block-shot-wip` (commit 2f7c404a) for the next slice.

**Next — ball-winning:** duels for a moving dribbler (the touch-tight
steal needs 10 static ticks inside 0.6 m — a dribbler outruns it),
engaged-defender tackle success vs the carrier's touch, interceptions of
the carry, ball out of play. Targets: possessions → ~100-150 per team,
shots → tens, conversion ~10%; then land the parked block-shot work.

### 8.18 G4.23 — the accidental chip: youth scoring was a bug

Set out to fix ball-winning; the duel instrument (every carry an opponent
engaged inside tackle reach, by outcome) confirmed the gap — world
defenders engaged 2.0 s and won 3% — but the first remedy tried (carrier
top speed ×0.85, the real with-ball ratio) barely moved duels (3 → 4%)
and sent amateur to 26.5 goals on 73 shots. Chasing THAT found the
biggest calibration bug in the project:

- **Goal anatomy, read PRE-tick** (the G4.14 trap, hit again: the Goal
  event fires after the kickoff reset, so a post-tick read called every
  goal an own goal): 33 of 36 HEAD amateur goals had no shot in the 20 s
  before — they were the touch-tight **"clear" lofted along the
  carrier's run**, i.e. at goal: an uncounted chip over the keeper. The
  loft-clear dates to G4.1, so youth/amateur scoring had ridden it all
  along. Fixed: in shooting range the boot IS a shot (shot physics,
  counted); elsewhere it's a clearance to the emptier wide channel
  upfield. Without it the ladder INVERTED: u10 2.8 / u14 1.4 / amateur
  0.5 / world 3.9.
- **Shot outcomes** (followed from the strike to first resolution):
  keepers held ~90% of ALL shots and ~0% missed the target. Dive-lite
  tracked every shot to ±6 m; a slow strike gives a 6 m/s keeper time to
  reach anything. Keepers now project to the GOAL line and LEAVE shots
  going wide (> post + 0.3 m): off-target 0 → 20-30% (real ~a third).
- **Strike power** (G4.14's cap reversed): hardest shot = control + 6
  equalled the band's own keeper catch cap — a U-10 keeper caught every
  U-10 shot he reached. Now control + 12 (amateur 22 m/s, u10 18; top
  bands still the 24 m/s kShotSpeed), keeper hands bonus 6 → 10 (sweep:
  +6 amateur 8.8 > u14, +8 5.9, +10 4.2 — the first fully ordered
  ladder).
- **Keeper handling** (`keeper_fumble_pct`, World-side, hashed only when
  set so zero-param goldens hold): shot-speed balls fumbled u10 40% /
  u14 28 / amateur 15 / semipro 8 / pro 5 / world 3; a third of fumbles
  squirm through.
- **Keeper reaction made monotone**: the G4.14 table (u10 18 / u14 14 /
  amateur 6 / semipro 14 / pro 11 / world 9) was tuned while chips
  inflated amateur — semipro reacting 2.3× slower than amateur sent it
  to 7.5 goals. Now 18 / 15 / 12 / 11 / 10 / 9.
- Dribble ×0.85 dropped (no duel benefit, ladder harm).

**Ladder (12×90): u10 7.8 / u14 6.4 / amateur 4.2 / semipro 3.1 / pro
3.0 / world 3.3** — every goal now from a real shot, magnitudes realistic
at every band, monotone within noise. Bands test green (its 4-match u10
> amateur assertion caught the +6 hands variant). 11v11 golden re-locked
(0x78ee092b…); 3v3 + determinism goldens unchanged.

Still open, unchanged by this slice: shot VOLUME (~250/match) and
conversion ~1-5% — ball-winning (duels: 3% won) is next, then the parked
block-shot work (§8.17).

### 8.19 Match length — real football (James, 2026-10-22)

"It needs to be real football 90 minutes, 45 minute halves, and the game
super realistic." The sandbox's 5-minute halves (G3) are retired: 2 × 45
min at real time is now both the compose setting and the code default.
The clock is never compressed FIFA-style — FIFA accelerates the clock
and over-produces chances to keep scorelines up; here the calibrated
ladder (§8.18, per 90 real minutes) IS the live scoreline. The wire
clock is cumulative (u16 seconds), so the second half reads 45:00 →
90:00 like a broadcast.

### 8.20 G4.24 — ball-winning: two bugs made won tackles worthless

Duel instrument at slice start (world): defender inside tackle reach
2.0 s per duel, ball won 3%. Branch-tagging the engaged defender found:

- **Dead-code tackle.** The STEP branch (the engaged presser's own
  dive) rolled noise channel 7 — the very value the traffic-tackle check
  above had already failed that tick — so it could never fire: 28,748
  engaged ticks, 0 tackles. Own channel (13) now. Lesson for every
  roll: two decisions on one (tick, slot) need DIFFERENT channels, or
  the second is the first's shadow.
- **Won tackles handed the ball back.** World matches won 52 tackles and
  changed possession 5 times: the poke drove the ball from the tackler
  THROUGH the ball line — from a front-on tackle, straight back to the
  carrier's feet. A won tackle is now a clean win 70% (tackler takes it;
  carrier off balance kDispossessedRecovery = 10 ticks) and a sideways
  squirt across the carrier's line 30% (a true 50/50). Turnover clock +
  location recorded on the tackle.

Duels won: world 3 → 14% / pro 17 / semipro 22 / amateur 20 / u14 49 /
u10 57 (the u10 frenzy: ~5,400 dives a match). Ball-winning helped
amateur defending more than amateur attack (bands test caught amateur
2.5 < world 3.5 in its sample), so keeper fumbles re-set: amateur 15 →
22%, world 3 → 2%. **Ladder (12×90): u10 11.2 / u14 7.3 / amateur 5.2 /
semipro 2.7 / pro 2.5 / world 2.8.** Bands green; AI goldens re-locked
(3v3 0xdf0bf528…, 11v11 0x1cf73c7a…).

Shot volume is STILL ~250 (world 264): with ball-winning and the parked
block-shot work combined, the bar sweep repeats the G4.22 pattern —
shots flat at ~230-250, goals 1.6 → 8.9 → 19.9 as the bar rises. A
declined shooter still reaches a better chance; 14% duels can't stop
him. The attack is reaching shooting range far too easily — next is an
instrument for final-third ENTRIES (real ~45 per team, ~25% → shot) to
see where the defensive block leaks. block-shot stays parked (alone it
takes world to 1.6).

### 8.21 G4.25 — bodies block shots; where attacks really leak

New instrument — final-third ENTRIES (episode opens when a team's ball
crosses 17.5 m past halfway; closes on its shot, a turnover, or a
retreat): world teams CARRY the ball in ~119×/match and shoot after
81%; passed entries (18) die 92% of the time. Real: ~45 entries per
team, ~25% → a shot. The attack walks in because the jockeying
defender retreats at full speed 2.2 m goal-side — an ESCORT. Tried:
"a set defender is planted" (carrier takes the whole collision push) —
no effect, carriers rarely touch their marker; reverted.

Shipped — **body blocks.** Above the 20 m/s capture cap outfielders were
ghosts: a 24 m/s shot passed through them (world: 0% of shots blocked;
real ~a quarter to a third), and at 0.8 m/tick could tunnel a 0.5 m
capture radius. The ball's path for the coming tick is now swept; the
first OPPONENT outfield body within 0.45 m below 1.8 m rebounds it
(reversed, ±60° noise, 30% speed). Opponents only: teammate blocks
measured u10 dropping to 5.2 (the amoeba shooting into its own backs).
Blocked: world 0 → 12%, pro 7, semipro 9, amateur 9, u14 31, u10 56.

**Ladder (12×90): u10 6.2 / u14 6.8 / amateur 4.4 / semipro 3.0 / pro
2.7 / world 2.5.** Bands floors lowered (u10 6 → 4, amateur 4 → 2.5):
the G4.14 floors were set while the chip bug inflated those bands, and
realistic values now sit on them — a 4-match sample made the gate a
coin flip. Ordering assertions unchanged. Goldens unchanged.

Next: the ESCORT. Delay must stop being a full-speed retreat —
backpedal speed < forward, and/or delay ends at a depth line (the
defender holds and engages) — so carried entries fall toward ~45 and
the block-shot work (branch game/g4-block-shot-wip) can land.

### 8.22 G4.26 — players you can watch: humanoids, animation, a camera you turn

James, 2026-10-22: "we are far away from realistic — need player
animations and ability to rotate and to be more playable." Client-side,
no protocol cost beyond one reserved flag bit:

- **Humanoid figures** (`frontend/js/game/players.js`): primitive-built
  rig with hip / knee / shoulder / elbow pivots; home navy-gold, away
  white, keepers in their own kit (snapshot flags bit1 = goalkeeper,
  PROTOCOL 1.4 additive — the only server change); shirt numbers on the
  back; varied skin/hair.
- **Procedural animation** driven by what the wire already carries
  (interpolated velocity): run cycle with speed-scaled cadence/stride,
  knee heel-kick on the back-swing, counter-swinging arms, sprint lean,
  bob, breathing idle, keeper set position; a KICK animation queued on
  the server timeline when the ball leaves its owner. Bodies TURN to
  face travel (~11 rad/s, shortest way) and hold facing when still.
- **Camera rig** (`camera.js`): TV (broadcast, pans with play) / FREE
  (drag to orbit, wheel or pinch to zoom) / BEHIND (behind your player
  looking up the pitch he attacks) / TOP (tactical). Any drag rotates;
  C or the CAM button cycles; modes ease, never cut.
- **Controls are camera-relative**: "up" is away from the viewer however
  the view is turned (verified: W behind a home player = +12.9 m up the
  pitch in 2 s, 0 lateral). A drag never claims a player; touch claims
  on release.
- Pitch dressing: mowing stripes, full Laws markings (areas, spots,
  arcs, corners), goal nets, blob shadows, a rolling panelled ball;
  controlled player = gold ring (any shirt glow tinted navy kits);
  tackle events no longer toast "event", offside does.

Also measured (sim): a jockey BACKPEDAL speed (100/65/50% when
retreating) moved nothing — carried final-third entries stayed ~118 —
so the delay branch isn't where the escort lives; reverted. Next sim
step attributes the carrier's escort by branch (the G4.20/G4.24 tag
method) before changing behavior.

### 8.23 G4.27 — graphics + animation pass (James: "make that even better")

- **Rig v2** (`players.js`): capsule anatomy on MeshStandard materials —
  pelvis hub, twisting chest, neck/head, hip→knee→ankle→boot,
  shoulder→sleeve→elbow→hand; three hair cuts, collar ring, sock trim
  bands, team boots (away red), keeper gloves; all meshes cast shadows.
- **Animation layers**, each overlay with an eased weight (nothing
  snaps): stride (cadence/stride by speed; quicker, shorter DRIBBLE
  steps when carrying), banking into turns from yaw rate, head + chest
  TRACK THE BALL, kick (wind-back/strike, opposite arm, chest twist),
  SLIDE TACKLE (flags bit2), STUMBLE when dispossessed (bit3), KEEPER
  DIVE (keeper moving fast with the ball near), HEADER jump (ball at
  head height arriving), GOAL CELEBRATION (scoring side, from the Goal
  EVENT — never inferred).
- **Server**: PlayerState.recovery_kind (1 tackle / 2 dispossessed) →
  snapshot flags bit2/bit3; presentation only, not hashed (goldens held).
- **Scene**: real PCF-soft shadows from a low evening sun (2048 map;
  1024 on touch devices), canvas grass (mowing stripes + blade noise,
  anisotropic), four raked stands with crowd textures + roofs, LED
  boards round the pitch (club copy), corner floodlight masts. Tone
  mapping tried (ACES) and dropped — it bleached kits and grass.
  Broadcast camera moved to the front of the main stand (from 68 m out
  the roof filled the lower frame). Status/score on dark pills.

### 8.24 G4.28 — Lighthouse Field, mapped; six camera views; zoom

James: "field gets cut off at bottom. crowd is not needed… just a grass
field with some stands like 3 row stands, movable like 5 of them…
199 east erie avenue… bonus if you map the complex… the barn and the
rodeo area and the tree line and the baseball field… horses in the
stables and the sixers bball court — details not rendered unless we
scan the field… use more of screen for pitch… zoom controls… follow
ball, follow man… broadcast, overhead, 1st person, 3rd person."

- `frontend/js/game/field.js`: the stadium is gone. Five portable 3-row
  aluminium bleachers round the pitch; beyond them Lighthouse Sport
  Complex Field mapped from satellite imagery of 199 E Erie Ave (scale
  from the map's scale bars, 0.81 / 0.405 m/px): the grass lot, N Front
  St, Erie Ave (it runs at an angle), Whitaker Ave, Cedar Hill Cemetery
  + headstones, the tree lines, the main diamond (grass infield, mound,
  backstop) and two skin infields, the rodeo ring (sand, white panels,
  four little bleachers, tent, trailers), the barn (red, gable, white
  X-door) + fenced paddock, the clubhouse on Erie with its sign, The
  League Park building, the parking lot, neighbourhood massing. First
  pass had Front St 150 m off (the internal tree line read as the
  boundary) — corrected from the close view.
- LOD DETAILS, drawn only within range of the camera: grazing horses at
  the barn, the League Park court's Sixers-colours markings + hoops,
  parked cars.
- `camera.js`: TV (tight broadcast, aim biased so both touchlines fit),
  BALL (chase), 3RD (behind your player — or the ball carrier), 1ST (eye
  line, own body hidden, zoom = field of view), TOP, FREE. C cycles,
  1–6 select; zoom in EVERY mode via wheel, pinch, +/− buttons, +/− keys.

### 8.25 G4.29 — Lighthouse Field from real data (OSM + imagery + layout)

James: "make the complex and surrounding area of lighthouse using google
maps and street views… once you have dimensions of everything then
detail can be added later… field outline is old but it will get you
started and i can then guide you on new dimensions and kids 7v7 field."
The hand-estimated G4.28 map is replaced by three data layers:

- `frontend/js/game/lighthouse-site.js` — GENERATED by
  `game/scripts/build_lighthouse_site.py` from OpenStreetMap (Overpass):
  Lighthouse Field (way 762100596), 13 pitches (old soccer outlines,
  4 baseball, the League Park basketball court), 270 buildings, roads
  (per-carriageway widths — divided Erie Ave is two ways), railways
  (Northeast Corridor), parking, New Cathedral Cemetery (not Cedar Hill
  — OSM corrected the G4.28 label). Metres from a FIXED origin (the
  Lighthouse Field centroid 40.008229, -75.124772), x east, z south.
  © OpenStreetMap contributors, ODbL — attribution in the file.
- `frontend/js/game/lighthouse-trees.js` — GENERATED by
  `game/scripts/detect_lighthouse_trees.py`: 1,041 trees classified from
  georeferenced Esri World Imagery z19 tiles (canopy V≈0.15 vs field grass
  V≈0.28, calibrated on sampled patches; 5 m cells >70% canopy) — the
  real tree lines (cemetery edge, Whitaker, Erie verge, League Park copse).
  OSM outlines overlaid on the same imagery line up to within a metre.
- `frontend/js/game/lighthouse-layout.js` — HAND-EDITED, today's truth
  for James to steer: gamePitch placement (placeholder: centred on the
  old 96 x 51.5 m OSM outline, long axis 58.1°), the five bleachers (in
  pitch coords; imagery shows them parked in a row by Erie), rodeo ring +
  oval pen + red-roofed barn, the stable block + paddock + green shed by
  Erie, horses, and an empty `kidsFields` for the 7v7. Positions measured
  on the imagery (CONFIRM flags where unsure).

`field.js` renders all three: merged per-surface ground layers (polygon
offsets — mm gaps alone z-fought into moiré), ribbon roads (up-facing
winding — down-facing ribbons lit from below read black), extruded
buildings, baseball infields placed at the vertex where the foul lines
meet, court + hoops + parked cars as LOD details, instanced trees and
headstones; the whole site is rotated so the game pitch lands on its real
spot and angle. Pitch markings are now PAINTED into a 2048-px turf
texture (line geometry lost depth fights with the turf at range).

### 8.26 G4.30 — real teams, real attributes: Lighthouse APSL vs the Ukies

James (10/22): "lets make Lighthouse APSL vs Ukrainian Nationals … give
our guys random attributes and i can fix them and describe the type of
player … this will be an attempt to start a game realistic for apsl".

- **Attributes become per player [FH].** Mig 636's `game_attributes`
  registry (pace, passing, shooting, first touch, tackling, anticipation,
  decisions, goalkeeping — 0-100, 50 = the team's band EXACTLY) and
  `game_demo_player_attributes`. `core::levelForPlayer` bends the band's
  numbers per player (errors x1.5 at 0 … x0.5 at 100; touch x0.75…x1.25;
  tackling ±30 points; pace → 5.4-7.4 m/s), and World/Brain read a
  per-slot level where one is set — unset slots ARE their band, so every
  golden held (19/19, calibration unchanged). Shots got their own error
  dials (default "same as passes") so a finisher who can't pass is
  expressible. Per-slot levels join the canonical hash only when set.
- **Real people, at James's request** — reversing mig 628's
  fictional-only rule for these two teams. No names in git: the migration
  copies them from the club's rows when it runs. Lighthouse APSL = the
  RSVP-able APSL roster (active, not invite-only), seated in the 4-3-3 by
  each player's last Game Center lineup position (GK from the lineup —
  no `is_keeper` flags exist); the rest are the bench (loaded, not on the
  pitch yet). Ukrainian Nationals = the six players on file plus numbered
  placeholders (the full APSL roster isn't in the DB). Attributes are a
  deterministic random draw (40-75; keepers 60-80 in goal) for James to
  correct.
- **Teams carry their formation** (`game_demo_teams.formation_code`):
  Ukies 4-2-3-1, Lighthouse APSL 4-3-3 wearing the "Lighthouse" preset
  (the club's Bielsa-based model). The -1/+1 match-up that PRODUCES the
  4-3-3 is queued as the `match_up` concept (CONCEPTS.md).
- **The editor (same day):** EDIT → tap a player → PLAYER tab: the eight
  attribute sliders + "what type of player is he?" for him or anyone on
  his team (bench included). SAVE writes the club DB (`/api/game/roster`
  read for signed-in members, `/api/game/player` save for admins — the
  daemon still reads the DB only at boot) AND sends wire 1.5's
  PLAYER_ATTRIBUTES (0x37) so the running match uses the new numbers at
  once; TEAMS (0x38) tells the client which rosters it's looking at. The
  old concept sliders are the KNOWLEDGE tab. Names on the wire now decode
  as UTF-8.
- Next: the full Ukies roster, substitutes, the `match_up` concept.

### 8.27 G4.31 — Lighthouse man-marks with a free +1; kits; the Medford XI

James: "make lighthouse man mark with + 1 and -1 on center backs. make lh
white socks, blue shorts blue shirts. ukies black socks white shorts and
white shirts" … "use our lineup from last game vs medford".

- **Per-player knowledge** (mig 639 `game_demo_player_concepts`, by
  concept NAME) applies after the team's style preset — and after an
  admin paints a preset — so a ROLE beats the identity. Lighthouse APSL:
  every outfield player marking 90 + man-mark 90; one centre back marking
  0 / man-mark 0 / cover 95 — the free man. The Brain's marking hand-out
  now skips non-markers (rating 0), so nobody's man is spent on the spare:
  vs the Ukies' lone 9 one CB takes him and one is free (+1); our front
  three meet their back four (-1). Goldens + calibration unchanged.
- **Kits** live on the team row (mig 639) and ride the TEAMS frame as
  optional trailing bytes (older decoders stop after the names); the
  client recolours and rebuilds the figures. Keepers keep their kit.
- **The Medford XI** (mig 640): Lighthouse APSL reseated from the 10/21
  game's Game Center lineup (match 9330), 4-4-2 labels mapped to the 4-3-3
  (the second striker drops in as the third CM); attributes and
  descriptions follow the person across the reseat.

### 8.28 G4.32 — lineups you change, and "set lineup from Game Center"

James: "allow for lineup change and for set lineup from game center".
Mig 641: `game_demo_players.lineup_slot` (1-11, NULL = bench) — starters
are the lineup, not the first eleven shirts; daemon + API order players
by it. `game_demo_teams.club_team_id` links Lighthouse APSL to team 35.
The edit panel's LINEUP tab picks who starts in each formation slot and
can SET FROM GAME CENTER (any game of the linked team with a starting XI):
starters are mapped to the formation by their club position (greedy best
fit — the Medford 4-4-2 → 4-3-3 rule of mig 640, generalised), players
new to the game join with the random draw, and a team playing the +1
scheme re-picks its free CB among the CBs now starting. Both save to the
DB, then wire 1.5 RELOAD_ROSTERS (0x39, admin) makes the running match
re-read both teams — a config load between ticks; a failed load keeps the
team as it was; formations stay.

### 8.29 G4.33 — concepts and skills become classes; numbers come from the DB

James: "each concept is a class? extended from concept? each skill a
skill extended from skills? … no hard code. all comes from db and oop".

- **Skills** (`core::Skill`, game/src/core/Skill.hpp): Pace, Passing,
  Shooting, FirstTouch, Tackling, Anticipation, Decisions, Goalkeeping —
  one class each, held by `core::SkillSet` in registry order. One integer
  formula (`scaled`) reproduces G4.30's numbers exactly, so every golden
  held.
- **Concepts** (`ai::Concept`, game/src/ai/Concept.hpp): `Libero`,
  `CoverShadow`, `LineStep` — each knows its registry name + bit; the
  Brain still rolls the player's rating, then asks the class for a
  target or a line. The 26 inline concepts migrate one by one.
- **Numbers** in `game_model_params` (mig 642, owner.code.param + unit +
  source note), loaded at boot into `core::ModelParams`, converted to
  Fixed64 once (milli-units) so the same rows give the same match.
- **Lighthouse out of possession [Bielsa]:** every outfield man marks; the
  free CB is the libero (95); the starting 9 presses on a cover shadow
  (90). **Both teams step their line [Sacchi]** at a semi-pro 68:
  up while the ball is covered, hold when a free man receives facing
  forward. All three are STYLE concepts (default 0 at every band) so the
  bands and goldens are untouched; teams are coached into them by rows.

### 8.30 G4.34 — researched team models: Ukies 4-2-3-1, Lighthouse Bielsa

James: "look up how a 4231 defense and offense works for ukies. use
bielsa system of tactics for lh". Data only (mig 644), every rating citing
its source: the **Bielsa** preset completed (13 dials: man-mark 95,
marking 90, counter-press 90, verticality 90, runs 90, counter-attack 85,
give-and-go 85, support 85, width 85, push-up 85, intercept 80,
double-team 75, safe-pass 45) and now worn by Lighthouse APSL; a new
**Classic 4-2-3-1** preset (zonal back four, double pivot screening and
intercepting, full-backs tucking in, compact mid-block, CBs into the
pivots, 10 supporting the 9, width from the full-backs) worn by the
Ukies. Per-player roles (libero, cover-shadow 9, line-step 68) still sit
on top. The roles the research names but the engine can't yet play are
queued in CONCEPTS.md.

### 8.31 G4.35 — the pass ladder (first concept from the Leeds book)

James: "yes build pass_ladder" — first build from the Leeds 2019/20 book
plan (CONCEPTS.md G4.35, [Bielsa-Leeds ch4]). Concept bit 29
`pass-ladder`, class `ai::PassLadder`: the carrier ranks forward
receivers by RUNG instead of raw progress — 1/2 behind their deepest
outfield player (central, then wide), 3/4 in the 10 m pocket in front
of it, 5/6 past their most advanced outfielder, 0 = off the ladder —
and plays any rung up to `fireRung(rating)` at once, skipping the 8 m
"worth it" gain threshold (rating 0 → rungs 1-2, 50 → 3, 90/100 → 4).
Lanes and interceptor safety stay the existing safe_pass gate. Numbers
in `game_model_params` (mig 646: pocket depth 10 m, central half-width
20 m, fire rung 2 + 2 × rating); STYLE class, so every band, golden and
calibration test is unchanged (20/20). The Bielsa preset carries it at 90.

Measured (fh-game-calibrate, 30 semipro 11v11 matches per row, home
team overridden):

| Home team | Goals H–A | Shots H–A | Passed final-third entries → shot / lost |
|---|---|---|---|
| Bielsa preset | 2.67–1.90 | 106–63 | 153 → 6.6 / 145 |
| Bielsa + ladder 90 | 2.67–1.73 | 105–62 | 154 → 6.9 / 146 |
| Plain mirror | 1.57–1.70 | 117–114 | 76 → 0.5 / 76 |
| Plain + ladder 90 | 1.70–1.53 | 114–111 | 80 → 0.7 / 79 |

A small, consistent edge (goal margin +0.17 to +0.30), not a step change.
The table names the real blocker: ~95% of PASSED entries into the final
third are lost — the receiving end (first touch under pressure, a runner
timed to the pass, the next pass) can't use a better-chosen ball yet. That
is what `blind_side_run`, `rotation` and `release_timing` (next in the
plan) are for; re-measure the ladder after each.

### 8.32 G4.36 — the blind-side run; the ladder learns offside

James: "build blind_side_run next". Building it exposed a flaw in §8.31:
offside is the real law here (World arms it on every kick: beyond the
second-last opponent, the ball and halfway), so the ladder's rungs 1-2 —
ranked by where a receiver STANDS — mostly pointed at men already
offside. Rungs 1-2 are a ball into SPACE for an onside RUNNER.

- **Ladder fix:** a laddered passer skips anyone in an offside position
  (`PassLadder::offsidePosition`, the World's own rule) and plays a moving
  receiver at his lead point — where he'll be after 0.3 s reaction + the
  ball's flight (distance / 12 m/s); the rung comes from that point.
- **`blind_side_run`** (bit 30, `ai::BlindSideRun`) [Bielsa-Leeds
  f7/21/35/46/48/51/65/78/81/82]: the two most advanced attackers within
  18 m of their line wait 2 m onside on the far-from-ball shoulder of
  their nearest line defender; GO when our carrier is free (nobody within
  3.5 m) and the defender can't see them (runner > 90° off his facing):
  10 m behind the line, pulled 0.6 toward the channel — across his back.
  A run the pass didn't find (offside, ball still ours) comes back to the
  waiting spot to re-time. Numbers: mig 648. STYLE, default 0.
- Measuring changed the design twice (scratch probe, 3-6 matches): the
  book's cue "passer turns forward" fires 96% of the time here (carriers
  always face their dribble) → replaced by "carrier free"; the first lead
  (a flat 1 s) put the ball behind the line ~1% of the time → flight-time
  lead.

Measured (60 semipro 11v11 matches per row, home = Bielsa preset; ± 1 SE):

| Home team | Goals H–A | Margin | Offsides/match |
|---|---|---|---|
| Bielsa | 2.37–1.62 | +0.75 ± 0.23 | 0.33 |
| + pass ladder 90 (offside-aware) | 2.63–1.60 | +1.03 ± 0.26 | 0.15 |
| + ladder + blind-side run 85 | 2.47–1.85 | +0.62 ± 0.27 | 0.07 |

The run HAPPENS (probe: ~15 receptions a match by a going runner) but
lands at x ≈ 19.5 m — in front of their line, ~33 m out — not in behind:
39 of 92 receptions led to a hard strike within 3 s, none scored. So it
is NOT in the Bielsa preset yet (Lighthouse doesn't play it); the ladder
fix ships. Next lever is the receiving end, not more runs: a runner
going beyond the line needs the pass on the RELEASE tick (`release_timing`:
the carrier holds for the runner, then plays) — then switch the run on
by preset row and re-measure. (The 32-concept cap noted here is gone:
§8.33.)

### 8.33 G4.37 — the concept registry IS the curriculum

James: "there is always room for a concept right?" / "the concepts are
also the curriculum to teach". The cap was an implementation leftover
(the level-band defaults packed into a u32, `conceptBundle`) — and the
list itself was C++, against "no hard code, all from DB". Now:

- **`game_concepts`** (mig 650) is the curriculum: stable id (= wire id,
  0-254), name, title, family (individual / group / team / keeper),
  moment (KNVB four: in / out of possession, to attack / to defend), kind
  (core / style), `taught_from` (lowest level band that knows it by
  default), status (wired / queued / teaching), the lesson (cue → answer,
  what lacking it looks like) and sources. **`game_concept_requires`** =
  teach this before that (wall-pass ← give-and-go + support, …). Seeded
  with the 31 wired concepts at their old ids and the 45 queued lessons
  from CONCEPTS.md (the Leeds book plan included); 26 prerequisite links.
- **`core::ConceptRegistry`** loads it at boot (`fh-game: N concept(s) in
  the curriculum`); `builtin()` = the wired 31 for tests and DB-down
  boots. A DB that renumbers a wired id is REFUSED at boot (ids key every
  saved rating). Engine classes bind by name; a concept without a class
  is still rated and taught — it just doesn't drive behaviour.
- Rating vectors hold `kMaxConcepts` = 255 (the wire's u8 count);
  `defaultRatings` = band quality on every concept with `taught_from` at
  or below the band — the old bundles reproduced exactly (goldens and
  calibration unchanged, 20/20).
- Wire 1.6: **CONCEPTS (0x3A)** sends the names on connect; ROSTER sends
  `rating_count` = curriculum size; the client replaces its built-in list
  and the editor skips id holes.
- Adding a lesson is now a row. Wiring it into play is a class + params +
  `status = 'wired'`. CONCEPTS.md stays the design notes; the table is
  the record. Next for the club app (not built — no ghost features): a
  curriculum page and per-lesson player ratings over these rows.

### 8.34 G4.38 — taxonomy → game model → formation → player

James: "what we want is a taxonomy of football. then the game models
filter right? then the formation filters further then the player filters
further." Concepts, game models and formations overlap (Bielsa's press run
is Klopp's and Pochettino's), so each is its own layer over ONE shared set
of concepts (mig 652):

- **Taxonomy** — `game_moments` (the four + set pieces) → `game_principles`
  (a tree; 19 seeded: build up, break the lines, pressure on the ball,
  press as a team, delay and recover, …) → `game_concepts` (all 76 placed).
  `game_sources` + `game_concept_sources` (one idea, many sources and local
  names; the old free-text column parsed into 98 rows) and
  `game_concept_links` (requires / refines / counters).
- **Game model** — `game_models` (school / club / federation / formation /
  team, with a PARENT: a team model is its school plus changes) →
  `game_model_concepts` (DEMAND 0-100) + `game_model_concept_params` (a
  model's own numbers — table ready, engine use with the first concept that
  needs it). The 13 presets moved in; two TEAM models now inherit: Lighthouse
  APSL ← Bielsa (+ line step 68), Ukrainian Nationals ← Classic 4-2-3-1
  (+ line step 68). Bielsa's libero / cover-shadow became school demands.
- **Formation** — `game_roles` (9), `formation_slot_roles` (4-3-3, 4-2-3-1,
  3-3-1-3), `game_role_concepts` (78 links: the coaching list per position),
  `game_model_role_concepts` (role demand inside one model; empty until a
  model needs it).
- **Player** — `game_demo_player_concepts` is his ABILITY (the backend's
  lineup roles write it, unchanged).

The engine rule: a player PLAYS **min(demand, ability)**; demand − ability
is what to coach. `core::defaultAbility` (band quality on every concept
taught at or below the band — style concepts are now learnable from
amateur; libero / cover-shadow stay role skills), `defaultDemand` (core 100,
style 0), `effectiveRatings`; `defaultRatings` = no model = the old bundles
exactly (goldens unchanged). The server keeps `ability_` per slot and
`team_model_` per side; band changes move ability, APPLY_PRESET switches a
team's model. 20/20.

Measured (60 semipro matches/row, home = Bielsa): painted at 90-95 as
before: +1.03 ± 0.26; capped at semipro ability 68 everywhere: **−0.52 ±
0.21** (half-learned man-marking is worse than none — plain mirror −0.13);
the LIVE mix (Lighthouse's own marking/man-mark ability rows 90, the rest
68): +1.10 ± 0.32 — unchanged, so it deployed. The lesson for the
curriculum: a system demands its core concept at full ability; rate the
players who have it, don't inflate the model.

### 8.35-8.37 G4.39-G4.41 — curriculum content, real squads, the brain overlay

- **G4.39 curriculum content** (mig 653 schema, 655 content): 73 new
  concepts (149 total), 180 techniques (10 families, 28 groups) with ages,
  25 attributes, concept→technique links; single-source / unverified rows
  in, flagged by the view `game_curriculum_to_evaluate` (James: "flag the
  ones that have only 1 source and evaluate").
- **G4.40 squads** (mig 656-658, `game/scripts/load_squads.py`): the APSL
  Jumbotron feed + team pages (via the scraper proxy) and the club rosters
  and lineups rate both squads: quality by TABLE POSITION in each
  division (no outliers), Lighthouse tiers APSL starter > APSL bench >
  Liga 1 starter > Liga 1 bench, pace physical (not quality), age moves the
  mental side and potential; hand edits (source 'edited') survive reloads.
  The game always boots Lighthouse APSL vs Ukrainian Nationals.
- **G4.41 brain overlay** — James: "an overlay that shows info about
  players brain. pills to show just one guy etc or whole team. like a hud …
  buckland does basically this in his book" [Buckland: Simple Soccer's
  debug display]. Every Brain decision point (21) tags `Orders.why /
  target / other / rung` — read-only, goldens unchanged. Wire 1.7 BRAIN
  (~5 Hz to watchers), BRAIN_WATCH, BRAIN_LEGEND. Client: pills Off / One /
  home / away / Both; each shown player a decision label, a line to his
  target and a dashed line to the man he's acting on; One = a panel with
  his decision and the rating of the concept behind it, ‹ › to step.

### 8.38 G4.42-G4.43 — the two game models, measured on the real matchup

- **Game models** (mig 660): Bielsa from the literature (64 demands, each
  citing the Leeds book chapter / figure) ← Lighthouse APSL; U.S. Soccer
  U17+ (48, main principle 85 / sub-principle 75) ← Ukrainian Nationals.
- **fh-game-match** (`game/scripts/match.sh [matches] [minutes]
  [home:concept=demand,...|-] [away:...]`): N full matches of the REAL
  matchup through `server::loadMatchFromDb` — the same loader the daemon
  now uses (squads, models, qualities, attributes, edits, formations,
  settings, curriculum), the real GameServer with a no-op network, seed
  base+m. Overrides A/B a demand (`home:blind-side-run=0`) or drop the
  players' ability rows for a concept (`home:!marking`). DB never written.
- **First finding:** the backend's lineup roles (mig 639) wrote marking /
  man-mark 90 as every Lighthouse outfielder's ABILITY. With those, the
  60-rated side beat the 71-rated Ukies 39-12-9 (+1.37 ± 0.26 / 60
  matches); at their own quality they lose 5-9-46 (−2.13 ± 0.29). The 90s
  were removed (the free CB's 0s and the libero / cover-shadow role skills
  kept). `GameRoster::afterLineup` still writes them on a lineup save —
  changing it waits for a safe backend deploy.
- **Live now** (60 matches): Lighthouse 8-7-45, 1.38-3.28, −1.90 ± 0.29;
  blind-side run off: −1.53 ± 0.25 — it still costs ~0.4 a match until
  release timing lands.

### 8.39 G4.44 — no inflated role rows; release timing built, parked

- **Role rows** (backend `GameRoster::afterLineup`, mig 662): the lineup
  roles write only WHO holds a role — the free CB (libero at his own
  quality, marking / man-mark 0) and the starting 9 (cover-shadow at his
  quality) — never marking 90 / line-step 68 / cover 95. Live after the
  fix: Lighthouse 20-13-27, −0.55 ± 0.29 (60 matches).
- **What the real matchup says about Lighthouse's concepts** (60 each):
  without the libero +0.22 (he HURTS — he sits 2-5 m behind the line and
  plays everyone onside); without the line step −1.93; without the 9's
  cover shadow −1.23; without the blind-side run −0.19 (it still costs).
- **Release timing** (`ai::ReleaseTiming`, curriculum id 60): an unpressed
  carrier holds — at a walking carry — while a teammate attacks their line
  (onside, ≥ 4 m/s, within 15 m), and plays only the ball in behind (ladder
  rungs 1-2) once it is on; "wait for the runner" in the overlay. Measured:
  neutral for Lighthouse, costs the Ukies ~0.6 a match (neither −0.55, LH
  only −0.47, Ukies only +0.13, both +0.02) — so it is PARKED (mig 664: not
  known by default). The blocker is the receiving end: the ball in behind
  still rarely reaches a runner behind the line.

### 8.40 G4.45 — the libero holds the line, moves into the ball's channel

- James: the libero stays WITH the line in defensive phases until their
  carrier can play long forward — "that is standard". `Libero::target(cx,
  can_play_long)`: while the ball is covered (`LineStep::covered`) he stands
  0.5 m goal-side of the deepest teammate (`level_offset_m`); sweeping depth
  behind it only once a free carrier faces forward; a long ball in the air
  is still met where it lands. This fixes §8.39's finding (he sat 2-5 m
  behind the line and played everyone onside).
- Channels: five equal channels across the width (13.6 m each); he follows
  the ball fully into its channel within 2-4 (`lateral_follow` 1.0,
  `lateral_max_m` 19, mig 666) and avoids 1 and 5 unless absolutely needed
  — the long ball dropping out wide.
- Measured (real matchup, 60): −0.55 → line rule −0.23 → line + channels
  **+0.25 ± 0.22** (W24 D19 L17).

### 8.41 G4.46 — lapses: failing a concept = drifting into a neighbour

- James: "a bad libero will lag behind the line too much and also get
  caught too high up" … "they drift into another concept not in the game
  model … a concept that is good in other systems". So there are no "bad"
  concepts. `game_concept_links` gains kind **lapses-to** (mig 668): when a
  player fails his ability roll on a demanded concept he plays one of its
  lapse neighbours, picked in proportion to his own ABILITY on each (his
  habit — `Brain::setHabits` gets ability before the model's demand;
  `Brain::lapse`). No neighbour known → the old fall-through. `[FH]`
- The libero's roll is per 3 s window (`lapse_window_s`), so a lapse lasts
  long enough to cost. His lapses, both right elsewhere:
  - **deep-sweeper** (149, `ai::DeepSweeper`) [catenaccio]: always 4 m
    behind the line — "lapse: sweeping too deep" in the overlay;
  - **step-out** (150, `ai::StepOut`) [Gasperini]: out to the man between
    the lines in his channel, else 6 m off the line — "lapse: stepped out
    too high".
- Measured (real matchup, 60): Lighthouse's libero (ability 64) lapses about
  a third of the time: +0.25 → **−0.27 ± 0.19**; with no libero +0.22. At
  his level the game now says play a flat back four, or coach the libero
  (demand − ability = 36 to coach).
- Next: the same mechanism for techniques and decisions (Football Manager
  style tendencies) — a pass-choice lapse into the neighbour pass type he
  prefers.

### 8.42 G4.47 — pass lapses and tendencies (Football Manager style)

- James: "like football manager … tries short passes at a certain percent.
  tries long balls?" — "i like both ideas". Two mechanisms, one rule
  (`Brain::choose`):
  1. **Tendency** (`game_demo_player_tendencies`, mig 669): how much he
     LIKES a concept, apart from how well he does it (50 neutral). Above 50
     he plays it on his own initiative (t − 50)% of windows ×
     `skill.tendency.initiative` — even when he could do what the model
     asks. It also weights which way he lapses (else his ability does).
  2. **Lapse**: the model asks, his ability roll fails → a lapses-to
     neighbour (§8.41).
- The pass ladder lapses into two pass habits, each right in its system:
  **short-simple** (151, `ai::ShortSimple`, possession [Guardiola]): the
  nearest open man within 15 m, up to 5 m back; **direct-ball** (152,
  `ai::DirectBall`, route one [Reep]): lofted to the furthest-forward man
  10 m+ ahead, 15-30 m away, over the lane. Overlay: "lapse: short and
  simple" / "lapse: hit it long" / "likes it short" / "likes it long" (and
  the libero's "likes to sit deep / step out"). The 30 m cap is the lofted
  kick's fixed carry; a real 50 m diagonal needs a variable-power loft.
- First real tendency: Lighthouse's 6 (long passing rated 74-80) likes it
  long, 75. fh-game-match gains `home:~concept` (drop tendency rows).
- Measured (60): lapses 668 −0.27 → + pass lapses −0.17 → + the 6's long
  ball **−0.03 ± 0.17** (goals 1.20 − 1.23: fewer both ways). Each step is
  inside one SE — realism, not a tuning win.

### 8.43 G4.48 — the aimed loft

- The lofted kick had one power (12 m/s + 6 m/s rise): first bounce ~15 m
  out, then ~45 m of skipping, so direct-ball capped itself at 30 m. A
  LoftedKick now carries `carry_m` (Orders → `World::setAction`): power
  from the drag-free flight law (first bounce at v²·2r/g, rise = r·v,
  `kLoftLaunchRatio` ½ ≈ the chip's 27°), capped by the kicker's
  `kick_range_m` (band u10 30 … world 60 m; passing 0 → 80%, 100 → 120%).
  Direct-ball, over-the-top, keeper punts and clears drop the ball where the
  receiver will be / inside the pitch (dropping a clear ON the wide channel
  put ~300 balls a match into touch). Mig 671: direct-ball `max_m` 30 → 50.
- **Grass skid** `kBounceSkid` 0.65: a bounce keeps 65% of forward speed
  (without it a 40 m pass landed at 20 m/s and ran 40 m on).
- fh-game-match grew the instruments that drove G4.49: every kick resolved
  at the next owner by the passer's reason (to the man he picked / a mate /
  lost / dead), goal anatomy by the assisting pass, escort attribution;
  `GAME_PARAMS="owner.code.param=v,…"` A/Bs any param without the DB.
- **u10 keeper dials** reaction 18 → 45 ticks, fumble 40 → 80%: without
  them u10 (2.2) scored less than amateur (3.8) on the bands test. This is
  a ladder fudge, not a sourced value — §8.46 step 3 undoes it.

### 8.44 G4.49 — meet the pass (and the flight read)

- The pass tally showed, while OUR pass travelled, every brain read the
  free ball as THEIR ball: the receiver stood, forwards turned back; the
  man the passer picked got 24%, the ball in behind 2%. `Brain::flightRead`
  now simulates the ball's flight (air and ground, World's own bounce/skid/
  roll) and finds where and when each player can first take it.
- `meet-the-pass` (153, core, u10, mig 672) [Buckland ReceiveBall,
  stateless; Coerver "come to the ball"]: our first man goes to meet it; if
  we get there first the ball is still ours (attacking shape holds) and a
  runner ahead of it keeps running. `intercept` (20) chases by the same read.
- Measured (real matchup, 60 each, ± 1 SE):

| Tree | Margin | Goals LH–Ukies |
|---|---|---|
| G4.47 (committed) | −0.32 ± 0.21 | 1.38–1.70 |
| G4.48 + G4.49 | **−2.32 ± 0.22** | 1.02–3.33 |
| meet-the-pass off | −0.57 ± 0.19 | 1.02–1.58 |
| meet on, flight not "ours" | −0.92 ± 0.17 | 0.75–1.67 |
| keep-running off | −1.97 ± 0.22 | 0.63–2.60 |
| aimed loft off (World) | −3.80 ± 0.35 | 1.27–5.07 |
| flight-read intercept off | −2.83 ± 0.31 | 1.25–4.08 |

  The picked man's share barely moves (43.3 → 43.6%); the Ukies score
  1.6 a match off ordinary passes (0.38 without it). Treating our ball in
  flight as ours sends everybody forward — there is no rest defence
  (curriculum 70, queued). **Shipped ON, imbalance and all** (James,
  10/24: "it's ok to be unbalanced while we continue to calibrate"):
  meeting the pass is right; the missing rest defence is the problem.
- `match.sh 'home:!meet-the-pass'` does NOTHING for a core concept (no
  ability rows to drop — it reports "dropped (0)"). A/B core concepts in
  code or by a demand override, never by `!`.

### 8.45 G4.50 attempt — dribble speed (not shipped, see §8.46)

Carrier at 85% of top speed (the ball-at-feet sprint). Bands: u10 5.0 /
amateur 0.8 / world 0.0; 95% → world 0.8, 92% → 0.5. Second time it was
dropped for ladder harm (first: G4.23). It is right, and it fails because
of §8.46's root cause, so it returns in step 1.

### 8.46 Audit (2026-10-24) — the shortcuts, and the method from here

James: "the way we should build the game is the same way a coach coaches
… we see something not optimal and fix the biggest problems first … we
should not take short cuts. we should lay bare what should be done."

**The method.** A change is judged by REALISM — event volumes and shapes
against real football — not by the LH–Ukies margin or by the goals
ladder holding. Margin is the last check, never the target. Unbalanced
is fine mid-calibration. One change, 60 matches, kept if it is more real.
Failures are recorded (what didn't work, and why) like successes.

**Where we are vs real** (G4.49 tree, per team per match; reference
numbers approximate pro, to be sourced into DB rows in step 2):

| Stat | Us | Real |
|---|---|---|
| Shots | 95 / 133 (23 / 31 with dribble 85%) | ~13 |
| Clears | 340 / 275, ~87% lost | ~20 |
| Final-third entries | 160 / 143 | ~45 |
| Kicks | ~1,100 | ~500 |

**Root cause: no locomotion physics.** `World::tickPlayers` sets
`vel = desire × max_speed` — 0 → top speed in one tick, 180° turns free.
G4.20 saw it and ramped the BRAIN's steering instead. It explains: the
ESCORT (a defender backpedals at full speed and mirrors every cut),
duels won 3-14% (a 1v1 is a pure speed race), dribble speed failing twice
(a slower carrier can never get away), and the shot flood (G4.22:
possessions end in a shot because nothing else can end them).

**The recurring shortcut: tuning to the goals ladder.** Keepers absorbed
every other bug: reaction table tuned while the chip bug inflated scoring
(G4.14, reset G4.23); fumbles re-set so amateur > world (G4.24); hands
bonus 6 → 10 picked by ladder sweep (G4.23); u10 18 → 45 / 40 → 80%
(G4.48); a flat +5° on every shot (G4.8) because good finishers converted
like penalties; the shot-selection bar shipped "at the safe point"
(G4.21). The bands test gates goals only, on 4-match samples, with
floors lowered in G4.25 — a gate that rewards exactly this.

**Realistic things parked because goals fell:** dribble speed (×2);
block-shot (branch `game/g4-block-shot-wip`, G4.22); teammate body
blocks (G4.25); release timing (mig 664); the blind-side run out of the
Bielsa model (G4.36). Each needs re-measuring on real physics.

**Clamps standing in for football:** anchors ≤ 10 m upfield of the ball;
the back line holds ≥ ball − 25 m (a fix for a retreat spiral); the clear
as catch-all (aim hard-coded +35 m); carriers always face their dribble
(no separate facing — no backpedal, no "passer turns forward"); steals =
10 ticks within 0.6 m; any ball < 20 m/s is controllable; pace maps to
5.4-7.4 m/s (an average speed standing in for top speed + acceleration).
`Brain.cpp` holds ~111 numeric literals against ~23 DB reads — the "no
hard code, all from DB" rule (G4.33) is mostly unmet.

**Measurement:** the Ukies' positions are guesses and part of their
roster is placeholders, so the real matchup leans on fiction.

**What should be done, in order:**
1. **Locomotion** — acceleration (Furusawa/Hill mono-exponential, τ from
   sprint data), braking, turn limit, dribble speed: World-side, DB rows
   (owner `physics`). 1b: facing separate from movement (intent + wire)
   → a real backpedal / jockey. 1c: top speed vs effort (jog / run /
   sprint) once acceleration exists; pace → real top speeds.
2. **Realism scoreboard** — reference stats as sourced DB rows;
   fh-game-match prints us vs real; it replaces the goals-only bands gate.
3. **Keepers back to sourced values**; drop the +5°; goals land where
   they land.
4. **Re-measure the parked work** on the new physics.
5. **Clamps → concepts**: rest defence (70), delay/jockey, purposeful
   clears, compactness as a concept not a cap.
6. **Brain numbers → `game_model_params`** as each piece is touched.

Expect the ladder to break hard after step 1 — that shows how much was
propped up.

### v1 explicit non-goals (do not build before G4 closes)

Fouls/cards, stamina, substitutions-as-rule (subs arrive with G5 tactical
intents), weather, crowd, licensed anything, client-side prediction.
(Offside was on this list until G4.8, when the harness measured the exact
1860s goal-hanging problem the law exists to solve — amended by evidence.)

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
