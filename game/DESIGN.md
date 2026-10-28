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
5. **Realism item by item, coached like a team.** Each thing a player does
   is made as real as it can be, then measured and watched — James reads
   the match as a coach, the harness (`fh-game-match`) prints the numbers
   (line height, team length, shots, entries, pass outcomes). Overall
   results (goals per game) are what fall out, never a target: a jump
   means a hurdle was crossed and the next biggest problem is showing.
   **No realism gate** (James 10/24: "no gate!") — measurements inform,
   they never block a build. Determinism goldens and unit tests stay.
   Anti-FIFA by construction: no tuned chance rates, no compressed clock.

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
| **G4** | Calibration (measured, not gated since 10/24); level bands (youth→world cup) via attribute distributions + noise scaling; touch-control + camera polish | Realistic, level-aware 11v11, item by item | **in progress** |
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

### 8.47 G4.51 — locomotion: bodies get up to speed (§8.46 step 1a)

- **The law** (`core::Locomotion`, mig 678, new param owner `physics`):
  velocity relaxes toward the wanted one, dv/dt = (v_wanted − v)/τ,
  |dv/dt| ≤ max_accel [Furusawa/Hill 1927; Samozino/Morin]: τ 1.2 s,
  cap 7 m/s² (braking, cutting, reversing), carrier top speed 88% of his
  own. From rest he reaches 63% of top speed in 1.2 s, not 100% in one
  tick; a reversal at speed brakes first. Facing follows the BODY once it
  moves ≥ 0.5 m/s, so the carried ball goes where he goes. Pitch-edge clamp
  kills the speed into it; placement starts a player standing.
- **The brain reads the same law** (`Locomotion::reach`, closed form
  top·t − (top − v0)·τ(1 − e^(−t/τ)), v0 = his speed along the line):
  pass safety, the flight read and `interceptPoint` — which had the
  chaser's speed hard-coded at 6 m/s since G4.14 — now ask what his legs
  can do from how he is moving. New `math::fx_exp_neg` (table + Taylor,
  < 1e-6) and a per-tick lag table; out-of-reach men skip the sqrt.
- **The keeper dive** (Action 6 `Dive`, wire additive): measured first —
  keepers on the law conceded 28 goals a world match (they ran at
  shots); exempt from it, 0.5 (87 of 88 on target saved). Neither is
  football. A dive is a launch: 4 m/s along his line, ballistic 0.6 s,
  then 0.8 s on the turf. The keeper dives when his feet can't get him
  there before the ball AND it arrives while he's still airborne
  (`Why::KeeperDive`, "keeper dive"). No client animation yet (the
  snapshot flags don't carry it).
- Measured (60, real matchup; per team):

| | G4.49 | G4.51 | Real (approx.) |
|---|---|---|---|
| Margin LH | −2.32 ± 0.22 | **+0.72 ± 0.28** | — |
| Goals | 1.02 / 3.33 | 2.42 / 1.70 | ~1.4 |
| Shots | 95 / 133 | 38 / 30 | ~13 |
| Clears | 339 / 274 | 162 / 114 | ~20 |
| Pass completion | ~89% | ~70% | ~70-80% semipro |
| Final-third entries | 160 / 143 | 122 / 76 | ~45 |
| Kicks | 1,217 / 1,450 | 614 / 716 | ~500 |

  Ladder (4×90 mirrors): u10 19.5 / u14 17.0 / amateur 11.8 / semipro
  3.0 / pro 3.0 / world 4.0 (was 28.2 before the dive); bands test green.
  Duels: world tackles won 54 a match (G4.24: ~50 resolved dives).
- **Still unreal, and the next biggest:** shots ~3× and 90% from outside
  the box (shot selection); clears ~6× (the catch-all fallback); amateur
  and youth scoring high (youth keepers dive like pros — the Goalkeeping
  skill should scale the dive; amateur 11.8 vs Sunday ~4-5); the u10
  keeper fudge (§8.43) still in. Harness ~2.5× slower per match (41 µs a
  tick; the live budget is 33 ms).
- Next in step 1: **1b** facing separate from movement (intent + wire) →
  backpedal and jockey; **1c** jog / run / sprint effort and real top
  speeds (pace still maps to 5.4-7.4 m/s).

### 8.48 G4.52 — every player's own body; people are individual, the world is shared

James: "all players should have different rates of acceleration and speed
… with or without ball" / "we want to not use global dampings" / "use a
bell curve?" / "we want everything individual based right? except the
concepts that are team based" / "there is no team skill — maybe a tactic
or style".

- **The rule.** Numbers about PEOPLE are each player's own; numbers about
  the WORLD (gravity, ball bounce/roll/skid, pitch, goal, the laws) are
  shared; a TEAM has a tactic / style (game model demands, formation,
  roles, team concepts) — never a skill. Team concepts are still played by
  individuals at min(demand, his ability).
- **`core::Body`** per slot (World::setBody, hashed): his τ (acceleration
  1.5 / 1.2 / 0.9 s at 0 / 50 / 100), braking limit (deceleration 5 / 7 / 9
  m/s²), turning limit (agility 4 / 6 / 8 m/s² — braking and turning are
  now separate, split along his line of travel; G4.51 had one 7 m/s² cap),
  top speed with the ball (dribbling 80 / 88 / 95% — so he also gets up to
  speed slower with it) and dive launch (goalkeeping 3 / 4 / 5 m/s).
  `BodySkill` classes read three DB points each (mig 679, owner `skill`);
  G4.51's four shared `physics` rows are deleted. Only the dive's air and
  ground time stay shared (the physics of a jump). The Brain reads each
  man's own law (`runToward(world, slot, …)`).
- **Attributes:** acceleration / deceleration / agility wired, `dribbling`
  new (mig 679); engine order append-only, wire 0x37 grows to 12
  (count-prefixed, so an 8-value frame from an old client still works).
  The editor already lists every registry attribute.
- **Who has what — the bell curve** (`game/scripts/draw_bodies.py`):
  N(50, 12), seeded per (team, shirt, attribute), correlated the way
  bodies are [FH estimates]: acceleration ρ 0.6 with his pace z inside his
  team (measured 0.52), deceleration 0.5 / agility 0.4 with acceleration,
  dribbling 0.5 with first touch; position shape (wide men quicker, CBs
  slower to turn). 528 ratings drawn, source 'derived' — edits never
  overwritten. Age not used (no age on game_demo_players).
- Measured: ladder u10 14.0 / amateur 9.5 / world 3.5 (bands green);
  real matchup (60) **+1.47 ± 0.27** (was +0.72), shots 42 / 28, clears
  165 / 117, pass completion ~70%. The swing is random bodies against a
  partly placeholder Ukies squad — margin means little until bodies are
  rated. The calibration harness still plays identical 50-bodies per band.

**Still shared that is about people — to individualize** (adds to §8.46):
kick powers (8 / 14 / 24 m/s presets; `power` unwired), body size and
mass in collisions (`strength` unwired), reaction time (0.2 s in pass
safety and meet-the-pass; `reaction` unwired), jumping reach (`jumping_reach`
unwired), tackle reach, steal radius and ticks, the 20 m/s control cap,
keeper reach / hands bonus, dive air time. Pace still maps to 5.4-7.4 m/s
at every level (step 1c).

**Dissolve the band** (new step, after 1c): the level band (u10 … world)
is a team-wide skill dial — every player starts from the same perception
delay, kick error, tackle success, swarm and keeper numbers, attributes
only bend it. Done right, a band only generates unrated players'
attributes (the centre of each bell curve); swarm becomes his own
`discipline` (unwired today).

### 8.49 G4.53 — facing apart from movement: backpedal, shuffle, see ball and man (§8.46 step 1b)

- **Engine.** `MoveIntent.face` (zero = the way he travels). His body turns
  toward it at his own yaw rate (`Body::turnToward`, agility 7 / 9 / 11
  rad/s), and moving off that line costs speed (`Body::gait`, linear in the
  cosine): forward 100%, side-shuffle 40 / 50 / 60%, backpedal 55 / 65 / 75%
  of his forward top speed (agility 0 / 50 / 100; mig 686, [FH] estimates to
  source). Facing is no longer copied from velocity. Snapshot 1.8 appends
  facing (i8 x, i8 y per player); the client turns figures to it.
- **Knowledge.** `face-the-play` (154, core, U-10, "see ball and man"):
  off the ball and adjusting within 10 m, he faces the ball; a failed roll
  turns his back and runs. Runs in behind, chases, presses, recovery
  sprints and meet-the-pass face their travel. Keepers face the ball for
  the set position on short adjustments (always facing measured 5.4 goals a
  match — a keeper shuffling 30 m at half speed); long ones turn and run.
- **The harness never played meet-the-pass.** `ConceptRegistry::builtin()`
  (DB-less: the calibration harness, the tests) stopped at concept 30, so
  every concept wired after G4.36 — meet-the-pass included — was off in
  calibration. 153 and 154 are now built in.
- Measured (60, real matchup): G4.52 +1.47 (goals 2.68–1.22, LH shots 42)
  → G4.53 **+1.60 ± 0.25** (3.18–1.58, shots 51 / 36); face-the-play off
  +1.45 ± 0.33 (neutral). Ladder u10 16.8 / amateur 11.5 / world 4.8.
  Defending got harder: a body that must turn before it sprints, and a
  shuffle or backpedal slower than a sprinting dribbler. Real defenders
  don't backpedal square-on — they jockey **side-on** and drop-step to run
  with him. That (1v1 defending choices: stance, distance, show
  inside/outside, engage or contain — the knowledge sweep's biggest gap)
  is next.
- Not yet: human clients send no facing (they face their travel); the
  carried ball still sits ahead of facing.

### 8.50 The taxonomy sweep (2026-10-24)

James: "search for all possible things a player can do and all possible
knowledge … and team tactics … the goal is to simulate football" /
"looking off an opponent with your eyes or your body" / "butt size helps
dribblers … low centre of gravity" / "take ideas from Football Manager but
go beyond". Five sweeps → 906 candidates for review at
https://claude.ai/artifact/GqcmcjN9VabWS1RkQQLhXW (strike / discuss, five
decisions; marks in its db): 353 actions (61 fouls, 45 deception with the
cue each fakes, gaits, aerial play, calls), 128 knowledge (6 new
principles: See the picture, Disguise and deceive, Read the opponent,
Manage the game, Talk and organise, Penalty duel), 145 team (24 roles, 19
game models, set pieces, game management, 33 Laws), 34 body (the
glute/low-COG claim is anecdote; low COM is sound physics — model it from
height, mass, hip width, never as a "small = dribbler" rule), 246 Football
Manager elements (37 gaps; replace FM's dice rolls with simulation, keep
its catalogue). Engine needs, by items: the referee and the laws 186, body
contact 118, team shape 116, ball at height 104, a readable/fakeable body
99, restarts 94. Raw sweeps + page builder:
~/footballhome-notes/taxonomy-2026-10-24/. Kept items become queued rows
after James marks the page.

### 8.51 G4.54 — 1v1 defending: side-on, turn and run, when to step in

- **Gait fixed.** G4.53 made 90° off his travel the SLOWEST way to move (a
  square shuffle). A defender running side-on looks over his shoulder for
  free (head turn, `physics.body.head_turn_deg` 60) and runs a crossover
  with his hips open: full speed within 60°, side-on run 70 / 80 / 90% at
  90°, backpedal 55 / 65 / 75% at 180° (agility; mig 689).
- **Three lessons** from the knowledge sweep's biggest gap (sources:
  FIFA Training Centre "Defending in 1v1", FA Boot Room 1v1 defending,
  jockeying coaching sheets), all core from U-14:
  - `side-on-jockey` (155): delaying, body turned 40° open toward the side
    he shows. Lapse: square-on.
  - `drop-step` (156): the carrier comes at goal ≥ 4.5 m/s within 4 m →
    turn and run with him, 2 m ahead on his run, a metre goal-side.
    Lapse: keeps backpedalling.
  - `engage-or-contain` (157): the measured problem — the final-third
    tally showed the nearest defender pressing 61-68% and delaying never,
    because "organized" (more of us than them behind the ball) alone sent
    him in. Now he steps in on a trigger: cover ARRIVED (a teammate
    goal-side within 6 m of the carrier), the carrier's back to our goal,
    or pinned within 6 m of the touchline. A loose touch is the missing
    fourth trigger (no heavy touches in the engine yet). Lapse: dives in.
- Measured (60, real matchup): nearest defender in the final third now
  presses 27-37%, contains 30-32% (delay 8, side-on 10-14, turn-and-run
  10-12); margin +1.70 ± 0.25; **shots unchanged (48 / 33)**. The 1v1
  wasn't what makes the shot flood. Next: shot selection — ~90% of shots
  come from outside the box. Ladder u10 16.2 / amateur 8.8 / world 5.5.

### 8.52 G4.55-56 — hold the line, man-marking matchups, shots on what they're worth; no gate

James: "what concepts are not being used that causes the players to drop
so far back on defense … pushing up the lines. then for lighthouse it's
the same to get to mark and -1 and +1" / "don't care about overall —
just want each item real" / "no gate!"

- **Why lines sank.** The back line stood 2 m goal-side of the deepest
  ATTACKER — G4.4's rule, written "no offside law yet", never removed when
  offside landed (G4.8) — and the hold distance only CAPPED a defender,
  never brought him up. fh-game-match's new line instrument: back lines
  16-22 m from their own goal (Ukies inside 20 m 67% of the time), the ball
  33-35 m beyond them (real ~35-45 m and ~20-25 m).
- **`line-hold` (9) rebuilt** (`ai::LineHold`, mig 692): the line SETS at
  the ball − hold_m 25 (push-up squeezes by up to 13) on a covered ball,
  6 m deeper on an uncovered one; an attacker beyond it is offside, not a
  man to follow. Lapse: the old deepest-attacker rule with its 25 m floor.
  Measured (60): lines 30 m (LH) / 25 m (Ukies), teams 29-32 m long, ball
  24-27 m beyond; shots 34 / 19.
- **Man-marking matchups** (`Brain::matchups`): man-markers take their
  DIRECT opponent from the two formations (their shape mirrored into ours,
  paired nearest-first; the free man takes nobody = the +1; their spare is
  the −1) and follow him anywhere; the zonal hand-out only tracked
  goal-side men near the ball. LH outfielders marking 22% → 30%; most of
  the rest is the ability roll (~60 man-mark ability = loses his man ~40%
  of seconds) — a rating question for James, not a tuning one.
- **Shot selection (25) by worth** (`ai::ShotSelection`): an xG-like read
  (visible angle × e^(−d/13.5) × 0.64, ×0.7 pressed; [FH] fit to rough
  public anchors, source to pin; his decisions jitter his read): pressed,
  shoot at 0.05+; free, need 0.12 or work it closer; a mate with a safe
  pass and 1.5× the chance gets it. Shots outside the box ~90% → ~50%.
  `engage-or-contain` gained "deny the shot": within 25 m of our goal he
  closes the carrier down.
- **Next biggest problem it exposes:** attacks CARRY into the box (world
  mirror: ~100 carried entries, 55% → a shot, from ~11 m): defenders now
  contain correctly but cannot win the ball — no body contact, no loose
  touches. Taxonomy's #2 engine need (body contact, 118 items).
- **The gate is gone.** `test_calibration_bands` deleted, the goals ceiling
  in test_ai_match too. Its replacement (back-line height / team length
  ranges) was shown to catch the deep line (semipro 21.7 m, world 17.7 m
  failed) — and then dropped at James's word: measurements are read.
- **Hotfix found on the way** (97861086): G4.53's builtin concepts made the
  boot check REFUSE every DB curriculum (it compared the builtin's empty
  ids), so the daemon — and every match run since G4.53 — played the
  builtin curriculum. All G4.53-G4.54 numbers above were measured on it.

### 8.53 G4.57 — the direct opponent: tether, where to stand, lose your marker

James: "use lh tactic to tether to ukies … we can mark from behind or
cover shadow in front or tuck inside. offense we unmark. in any
direction" / "we call it a direct opponent and it's an important concept
that goes beyond lh and bielsa" / "the 9's direct opponents are the 4 and
5 and vice versa. that gives the -1, +1. 10:6, 7:2, 3:11, 8:8" / "a
universal concept, it's just that the zonal systems move in relation of
their zone to mark and unmark" / "there are kamikaze teams that press
man to man across with no +1 or they derive the +1 in different areas
like weak side".

- **Position numbers** on formation slots (`formation_slot_roles.number`,
  mig 694) and **`game_direct_opponents`** pairs by number (James's).
  7 = LEFT winger, 11 = RIGHT winger here so 7:2 and 3:11 face each other —
  for James to confirm. `Brain::directOpponents`: each marker takes the
  nearest opponent his number is paired with (two of ours may share one —
  the 4 and 5 on their 9; our 9 has their 4 and 5); unnumbered slots fall
  back to the shape matchup (theirs mirrored into ours, nearest-first).
  Measured matchups: LH 5 (libero, marking 0) → nobody (+1); LH 4 → their
  9; LH 9 → the nearer of their 4/5 (−1); 10↔6, 6↔10, 8↔8, 7↔2, 3↔11.
- **`direct-opponent` (160, core, U-10):** man-markers follow him
  anywhere; a zonal marker picks him up first while he's within 12 m of
  where the zone puts him, and passes him on when he leaves.
- **`mark-position` (158, core, U-14):** always goal-side; near the ball
  (< 10 m) step ball-side into the passing line — the cover shadow in
  front; far from it (to 30 m) tuck up to 35% of the way toward the ball.
  Lapse: flat behind the man.
- **`lose-your-marker` (159, core, U-10):** our ball, an opponent within
  3 m of a player holding shape / supporting / an outlet → step 5 m to the
  spot (8 directions) furthest from every opponent, within 8 m of his job.
  "lose your marker" in the HUD.
- Measured (30): LH +1.43; marking share unchanged (LH 30%, Ukies 6% —
  zonal defending is mostly positioning; the rest is ability rolls at
  ~60); pass completion ~70% → ~66% (markers in the lanes, attackers off
  their men); team length 32 / 28 m.
- **Queued (James):** kamikaze man-to-man (every man marks, no +1 —
  expressible today: nobody at marking 0); a weak-side +1 (the marker
  whose man is furthest from the ball goes free to help); the Ukies'
  rotations (10 drops, wingers invert, full-backs overlap) then back to
  shape.

### 8.54 G4.58 — phases of play: the coach's restart

James: "lets have a restart from keeper option. for either team. this is
the MOST organized a team will ever be. we can start the learning process
from there and work backward" / "then mid block … final third … tap off
and special kicks like corners" / "we want to think like coaches when
designing the game … coaching methodology is the most important."

- **`game_phases`** (mig 695): a phase is a row — kind (keeper / open /
  kickoff / corner), the ball's spot as % up the pitch from the team in
  possession's own goal line and across it, a coaching point. Seeded: From
  the keeper (6%), Into their mid-block (45%), In the final third (75%,
  20% left), Kick-off, Corner left / right.
- **`GameServer::runPhase(team, id)`**: all 22 placed at their formation
  anchors for that ball (`ai::anchorFor`, facing it; nobody over halfway at
  a kick-off), everyone on his feet; then the dead ball only `team` may
  touch first (keeper = a goal-kick restart at the spot, corner, kick-off)
  or, for open play, the team's nearest outfielder on the spot with the
  ball (`World::giveBall`). Wire 1.9 PHASES 0x3E / RUN_PHASE 0x3F (admin).
- **Where the defenders start** (mig 696, `press_line_pct`): the
  defending team's most advanced outfield line slides to that % up from
  the possessing team's goal line, its shape with it, its keeper home.
  From the keeper = 20 (James: "set ukies in 4231 in our zone first off")
  — their front four just outside our box against Lighthouse's 4-3-3.
- **Restart shapes as rows** (`game_phase_positions`, migs 697-698): per
  phase, formation, side (in / out of possession) and position number —
  depth from the team's own goal line, width + = left. A formation with
  rows stands there; without, its ordinary shape. Both teams HOLD their
  marks (facing the ball) until the dead ball is played
  (`Brain::setRestartShape`), the taker excepted. From the keeper, James's
  4-3-3 (sources: FIFA Training Centre goal-kick build-up, Coaches' Voice;
  metres [FH] / James): keeper on the ball; CBs low on the box edge (7 m,
  ±19); the 6 just above the box (19 m); full-backs on the touchlines
  (30 m, ±33.5); the 8 and 10 high short of halfway (42 m, ±13); the front
  three near halfway (49-50 m). The Ukies' 4-2-3-1 pressing (James): back
  four on halfway, CDMs 8-10 yd ahead, the line of three 8-10 yd ahead of
  them (7 and 11 in lanes 2 and 4 of 5, the 10 in lane 3), the 9 ahead.
- **Client:** an admin bar under the Brain pill — pick a phase, ▶ either
  team. Deterministic engine: the same phase on the same seed replays
  exactly, so one change at a time shows its own effect.

**The coaching roadmap (James: methodology is the design input)** — TODO:
1. Phases as rows (done) → throw-ins, free kicks (direct / indirect,
   walls), penalties, goal kicks short / long — each a `game_phases` row
   plus its restart kind.
2. **Freeze frame**: pause + slow motion (§8.57), viewer replay with frame steps (§8.59) done; server rewind (replay from a checkpoint),
   annotate — the coach's "stop, look at the picture".
3. **Play-practice-play** in the harness (built, §8.55): `fh-game-match` runs N of a
   phase and reports how it went (time to cross halfway, turnovers,
   entries, shots) — measure one phase, fix, re-measure.
4. **Constraints and small-sided games**: conditions as rows (two-touch,
   overloads 4v3, score only after a switch), 3v3 / 7v7 already run.
5. **Set-piece routines** (taxonomy: 20 set-piece items) on top of the
   corner / free-kick phases.
6. Rotations for zonal teams (Ukies: 10 drops, wingers invert, full-backs
   overlap), the weak-side +1, kamikaze man-to-man (§8.53 queue).

### 8.55 G4.59 — play-practice-play: the phase harness (roadmap #3)

`GAME_PHASE=code:team fh-game-match N` runs N **episodes** of one phase
instead of N matches (seed base+n, so a fixed sample). An episode sets the
phase up, plays it, and ends at the first of: a goal, the other team owning
the ball, a dead ball given to them, or `GAME_PHASE_SECONDS` (default 30)
with the ball still ours (our own throw or corner carries on). It reports
the coach's questions from the possessing team's side: restart played, over
halfway and into the final third (% and median time), shot, passes
completed, deepest ball, and how it ended — lost in our / the middle /
their third (and the median metres from our goal), out to them, scored,
conceded. Episode 1 prints the set-up. 200 episodes ≈ 3 s. [FH]

**The first run found a bug in G4.58:** a held restart shape exempts only
the player whose mark is on the ball, and only Lighthouse's goal-kick rows
put anyone there — kick-offs, corners and the Ukies' goal kick held all 22
on their marks for ever (live ▶ froze the same way). `runPhase` now stands
a taker 0.5 m behind every dead ball: the keeper for his goal kick, else
the team's nearest outfielder. Test `every_dead_ball_phase_gets_taken`.

**Baseline** (Lighthouse APSL vs Ukrainian Nationals, 200 episodes each,
2026-10-26; LH = Lighthouse in possession, UK = the Ukies):

| phase | over halfway | final third | shot | passes | lost own / mid / their third | out to them | scored |
|---|---|---|---|---|---|---|---|
| keeper LH | 7.5% | 3.0% | 2.0% | 2.4 | 10.5 / 67 / 20.5 | 1.5 | 0 |
| keeper UK | 6.0% | 4.5% | 1.5% | 2.2 | 66.5 / 12 / 16.5 | 4.0 | 0 |
| mid-block LH | (100) | 5.0% | 2.0% | 0.5 | 12 / 56.5 / 30.5 | 1.0 | 0 |
| mid-block UK | (100) | 7.0% | 2.0% | 1.3 | 23.5 / 54 / 18.5 | 2.0 | 0.5 |
| final-third LH | — | — | 49% | 0.0 | 0 / 0 / 87 | 9.5 | 3.5 |
| final-third UK | — | — | 73.5% | 0.1 | 0 / 1.5 / 81 | 13.5 | 4.0 |
| kickoff LH | 100 | 4.0% | 1.5% | 0.8 | 6 / 67.5 / 23.5 | 2.0 | 0 |
| kickoff UK | 100 | 5.5% | 3.5% | 1.6 | 11.5 / 63.5 / 21 | 3.0 | 0.5 |
| corner-left LH / UK | — | — | 8 / 19% | 0.2 / 0.8 | — | 23.5 / 19 | 0.5 / 2.0 |
| corner-right LH / UK | — | — | 2.5 / 26.5% | 0.7 / 0.0 | — | 12 / 32 | 0.5 / 1.0 |

What it says, biggest first: **no phase keeps the ball.** Possessions die
within 2-3 passes; from the mid-block and kick-off, under one completed
pass, so the man on the ball carries into the block and loses it. Building
from the keeper, Lighthouse loses it in the middle third two times in three,
and the Ukies (no 'in' restart rows yet, so their natural shape) lose it in
their own third two times in three against Lighthouse's man-to-man press.
In the final third the first action is a shot or a loss — never a pass.
The harness also says HOW each ball was lost (taken off the carrier, or
our last kick by its reason) and kicks per episode by reason. Into the
mid-block, Lighthouse: 59% of losses are a **clear** (the touch-tight
hoof), 17% a recycle, 9% taken off the carrier, 5% a pass — 0.11 passes
per episode. A pressed carrier keeps it only if he READS (safe_pass, rolled
per second), so at semipro he hoofs from halfway about as often as not;
underneath, he rarely has a pass on at all. From the keeper the passes do
go (2.2 per episode) but 31% (LH) / 49% (UK) of losses are a pass picked
off. Next: the pressed carrier at halfway — shield / turn back / play it
back before the hoof — then the receivers' movement to give him a pass.

### 8.56 G4.60 — pressed with no pass: keep it; read the pass once

James 10/26, on the §8.55 finding (59% of Lighthouse's mid-block losses a
hoof from halfway): a closed-down player with nothing on shields and turns
back, plays it back to a centre back or the keeper, and hoofs it only in
his own third — "yes that is right".

- **`keep-it-under-pressure`** (161, core, U-10, principle *Keep the
  ball*; mig 700; `ai::KeepItUnderPressure`, `Brain::keepIt`): touch-tight
  outside shooting range → **play it back** (Why "play it back": the open
  teammate goal-side within `back_pass_max_m` 30, the one with most room)
  → else **shield and turn** (Why "shield and turn": `shield_step_m` 3
  away from the presser, leaning toward our goal, at `shield_speed_share`
  0.5) → only within `own_third_m` 35 of our goal line the old clear. A
  lapse (the per-second rating roll) is the old hoof. The back pass's lane
  starts a lane-width out — first cut measured 0 back passes, because the
  presser at his feet "blocked" every lane.
- **Meet the pass is read once per pass** (bug, found by the harness's
  new `GAME_PHASE_TRACE=n`, which prints episode n twice a second, every
  kick with its target and the receiver's distance, and touches that don't
  stick): the rating rolled every SECOND, so a semipro receiver met the
  ball, "forgot" it the next second and walked back to his shape 2 m from
  it. The roll is now keyed by the flight (kicker + heading; friction slows
  a rolling ball but never turns it). [FH]
- Goldens re-locked: 3v3 0xcdc53674630e2e7f, 11v11 0x8081ba3176dad103.

Measured (200 episodes per phase; 20 x 90 min, same seeds):

| | before | after |
|---|---|---|
| mid-block LH: passes / kept / clears of losses | 0.5 / 6.1 s / 59% | 1.1 / 8.1 s / 28% |
| mid-block UK: passes | 1.3 | 2.1 |
| keeper LH: passes / over halfway | 2.4 / 7.5% | 2.9 / 9.0% |
| match: passes+recycles+back passes LH / UK | 333 / 535 | 482 / 711 |
| match: LH shots / final-third entries | 37 / 140 | 44 / 160 |
| match: goals LH – UK | 3.50 – 1.20 | 5.50 – 1.55 |

Back passes ≈ 120 per team per match at 86-89% completion. Keeping the
ball raises the goals because the final third was already broken — 44
shots and 160 entries a match against real ~12 and ~45 (§8.22/§8.25): the
attack that keeps it now reaches it more. That is the next biggest problem
(the final third: "the first action is a shot or a loss, never a pass").

### 8.57 G4.61 — slow motion, fast forward, pause: the coach's clock

James: "can we have setting to do slow mo game lol or speed up but with
same physics? like a slider or dial. slow mo would allow me to really see
the tactics and movements and help coach it with you."

The sim already lived in ticks (§4: pacing lives in the daemon, never in
the World), so speed is only the wall-clock gap between ticks. Wire 1.10
SPEED 0x31 (`u16 pct`, admin): 5-400 %, 0 = pause; the server tells every
client on connect and on each change. `GameServer::speedPct/setSpeedPct/
heartbeat`; the daemon paces `tick_period·100/pct` and waits on the
socket, not a sleep, so a tap at 5 % (667 ms a tick) lands at once; paused,
it sends the frozen snapshot every 200 ms. Client: a bar under the phase
bar (admins) — ⏸/▶, slider 5 / 10 / 25 / 50 / 75 / 100 / 150 / 200 / 400 %,
1×. The renderer's tick timeline runs at the new rate and re-anchors on a
change; the delay stays ~133 ms of wall clock (4·s ticks, ≥ 1.5); figures
animate in sim time (legs slow with the play); paused, the picture holds
and the camera still orbits — the freeze frame of roadmap #2 (step and
rewind still to come). Test `admin_sets_the_sim_speed_everyone_hears_it`.

### 8.58 The Ukies' own shape from the keeper (mig 705)

James 10/26: "fix 1) Ukies from the keeper. their cdms should be outside
the box" / "thier 7,11 and 10 should be then 8 to 10 yards past the cdmes
and the 9 8 to 10 or near half line". The 4-2-3-1 had no 'in' rows, so it
stood in its open-play shape squeezed onto a ball on its own 6-yard line —
back four on the goal line, CDMs at 6.8 m. Now: keeper on the ball, CBs 7 m
±19 and full-backs 30 m on the touchlines (Lighthouse's numbers), CDMs
19 m ±8 (just outside the box), the 7 / 10 / 11 at 27 m in lanes 2 / 3 / 4,
the 9 at 35.5 m. 200 episodes: lost in own third 70.5 → 53%, passes 2.5 →
3.4, kept 7.4 → 9.4 s; out to Lighthouse 22% (was ~4%) — balls into touch.

Second pass (mig 706), James: "cdms should be above penalty box by 10
yards. then 7,11 should be pinned to sideline high up. near center line. 10
should be above the 6,8(cdms) 9 should be inside half circle". CDMs 25.6 m
±8; 7 / 11 on the touchlines (±33.5) at 49 m; the 10 at 33 m centre (gap
not given — ~8 yd); the 9 at 48 m, in his half of the centre circle. 200
episodes: lost in own third 45%, middle 24.5%, out to Lighthouse 21.5%;
over halfway 6.5%, passes 2.5, kept 7.1 s.

### 8.59 G4.62 — replay and rewind (viewer-side)

James: "not seeing replay or rewind more importantly" / "slider bar needs
buttons on the side to increment for replay and speed". The renderer keeps
every snapshot for 2 minutes of sim time (3,600 ticks); ⏪ Replay (every
viewer) rewinds 10 s, paused: a timeline to scrub, ‹ › one frame (1/30 s),
« » one second (keys , . and < >), play at 0.1 / ¼ / ½ / 1×, LIVE back.
The Brain HUD replays too — each BRAIN frame is kept with the tick it
arrived at. Nothing goes to the server, so a coach rewinding never disturbs
the match (it runs on underneath). The speed slider gained − / + steps.
Still to come: server-side rewind-and-replay (restore a checkpoint and let
the same seconds play again, or play them differently).

### 8.60 G4.63 — the one-spot defender (mig 723)

James 10/26, Lighthouse defending the Ukies building from the keeper: the
direct opponent goes after his man while the pass travels to him; the
others cover-shadow players who aren't theirs; and stay within pressing
distance of other men's direct opponents — "a player could be close enough
to get to direct opponent during pass traversal, while also cover
shadowing another opp from current ball carrier who is not their direct
opp, while also being dense enough to get to 1 or more others direct
opponents to help … on the way to being the ultimate defender". "These are
critical concepts" / "they need to be in taxonomy and lh/bielsa system
relies on them to be advanced" / "we could suck at it at first but the
concepts need to be there and applied".

Three STYLE lessons, taught from amateur (youth bands don't know them),
asked by the Bielsa model (Lighthouse APSL inherits it), not by the Ukies'
U.S. Soccer model [FH, after Bielsa-Leeds ch3, Rangnick, Klopp]:

- **pressing-distance (164)** — `Brain::pressReach`: where his man would
  RECEIVE a pass from the ball (he comes `meet_share` of his own run to
  it, the ball covers the rest at `pass_speed_mps`) and how far the
  defender runs in that time less `reaction_s` (his body's own law, from a
  standing start), plus `contact_m`. The first cut judged distance to
  where the man stood; he checked toward the ball and the jumper, starting
  5 m behind, followed him at the same speed and arrived 5 m late.
- **shadow-second-man (163)** — `Brain::oneSpot`: from his marking spot,
  candidate spots (the nearest point of each other man's lane from the
  carrier, halfway to it, a third and two thirds of the way to each other
  man's reception point). A candidate must keep his own man in pressing
  distance; it scores `lane_weight` per lane cut (a lane a teammate
  already stands on is taken), `help_weight` per other man in pressing
  distance (164), less `move_cost_per_m`. No better spot: the marking spot.
  Why "shadow and help".
- **jump-the-pass (162)** — `Brain::jumpThePass`: their pass in flight to
  a man we won't beat to it (the flight read, G4.49): his defender goes,
  facing his run, to arrive `arrive_gap_m` goal-side of the reception.
  Who goes: his own defender if he gets there in time; else the nearest
  teammate who does and knows 164 (the chain); else his own from within
  `jump_max_m`, late. Why "jump the pass".

**Their dead ball, man-markers pick up their men.** The trace showed the
Ukies' keeper playing the goal kick at t = 0.07 s with every Lighthouse
marker 10-27 m off his man — still in the zonal press-line shape. Now a
man-marker (18), on their restart, takes his direct opponent goal-side and
then the one spot; a phase's dead ball starts the defending side there
(`GameServer::runPhase` asks the Brain twice, so the lanes see teammates).
Zonal sides (man-mark 0) are unchanged — the goldens too.

Phase harness, Ukies from the keeper (200 episodes; the harness gained the
defenders' first-touch distance and their order shares):

| | before | dead-ball marking | + 162-164 |
|---|---|---|---|
| lost it in their own third | 45% | 24.5% | 27% |
| lost via keeper punt | 0% | 45% | 45% |
| over halfway | 6.5% | 4.0% | 3.5% |
| pressed within 2 m on a first touch after a ≤25 m pass | 6% | 6% | 13% |

Full matches (20, Lighthouse v Ukies; before / dead-ball marking / +
162-164): goals 5.50–1.55 / 4.30–2.00 / 6.35–1.85 (each ± ~0.6 SE: inside
the noise of 20 matches), LH shots 44.1 / 41.9 / 46.6, Ukies pass
completion 63.9% / 64.3% / 62.9%. Full matches barely move — open play
rarely leaves a lane or a second man inside pressing distance of a man who
must stay on his own. "Shadow and help" is 9% of Lighthouse's
out-of-possession man-time, the jump about 2%.

Known next: a third of Lighthouse's outfield man-time out of possession
is "hold shape" — the marking roll (ability ~68 vs Bielsa's 90 demand)
failing for a whole second, the man ball-watching in shape. That is the
"suck at it" James expected, from the player data; how a failed mark
LOOKS (stand in shape a second) is crude and is the next thing to make
real. The final third (§8.56) is still broken: LH 46 shots, 165 entries.

### 8.61 Law 16 — their goal kick: out of the box until it's kicked

James: "its illegal on restart goal kick for lh 9 breslin to be where he
is. they most all start from beyond 18." G4.63's man-markers picked up
their man goal-side on the opponent's dead ball — for a goal kick that put
LH's 9 on the split centre-back, 13 m from the Ukies' goal line, inside the
box. Law 16: the opponents stay outside the penalty area until the ball is
kicked. `World::boxClearTeam()` is set on a goal kick (the side that
isn't kicking) and outlives `restartTeam()` — which clears when the keeper
settles the ball — until the ball is kicked, tackled or a new restart is
awarded. `Brain::ordersFor` applies it after every decision: a target
inside the box (+1 m) moves to the 18 + 1 m line, a man already in walks
out. The phase harness places the defending side the same way. Harness
(keeper:1, Ukies' goal kick): LH 9 starts at 87.5 m from his goal, was
97.0. [FH]

### 8.62 G4.64 — Lighthouse packs the middle, then presses the full-back (mig 730)

James 10/26: "in bielsa he would … cover shadow the center backs 4 and 5.
but our lh tactic is for him to … play a false 9 so in defense he will drop
and assist the man markers in the lh midfield the 6 8 and 10. also our 7
and 11 will assist the midfield as well by staying tight inside. this gives
us a 6v3 in midfield … so they will pass to fb on either side. this is when
our ball side 7 or 11 go after their direct opponent while cover shadowing
middle. our weak side 7 or 11 tuck in further … and our 9 'locks the door'
by now going up to the closest cb and not allow a return pass from fb to
cb. he can play off a little and shade toward weakside cb" / "we
essentially pack the middle then wait for the inevitable pass to full then
we press" / "the ball side 7/11 doesn't curve run he just cover shadows
their 6 8 10 … while stepping to direct op".

Three style lessons (taught from amateur), asked for by the Lighthouse APSL
team model only, keyed to position numbers held in game_model_params (no
numbers in code): `pack-the-middle` (165), `press-the-full-back` (166),
`lock-the-door` (167); `Brain::packAndTrap` plays them while the ball is in
their half. Lighthouse's `cover-shadow` demand is now 0 (the 9 drops
instead of running at the CB). Sources: the narrow front three showing the
build-up wide is Klopp's Liverpool press [klopp] (their wingers curve the
run; Lighthouse's step straight — the shadow on the midfield is the
point); the pass wide as the trigger is Rangnick's [rangnick]; the false
9's drop into a 6 v 3, the far winger as an extra midfielder and "lock the
door" shaded to the far CB are Lighthouse's own [FH].

- **Pack (no trigger):** their midfield = the men our 6/8/10 mark (direct
  opponents). The 9 screens the one nearest the ball, `screen_gap_m` off
  him on the line from the ball; each winger screens the one nearest his
  tucked spot (not the 9's man, not the other winger's), no wider than
  `tuck_width_m`. Their full-backs are left open on purpose.
- **Trigger:** their ball at, or their pass reaching first, a full-back — a
  wide man (`central_width_m`) who isn't a CB, or a winger's direct
  opponent. The nearer winger steps straight at him, `step_gap_m` off him
  on the line to their nearest midfielder (inside `handover_m` the normal
  press/tackle takes over); the far winger screens no wider than
  `weak_tuck_width_m`; the 9 goes `lock_gap_m` off the near CB toward the
  full-back plus `shade_m` toward the far CB. Their CBs = the men our 9's
  number is paired with (game_direct_opponents).
- A failed roll on any of them is the ordinary brain (mark / shape). On a
  dead ball the men packing start on their spots, like the markers (G4.63).

Harness additions: `GAME_PHASE_WATCH=9,7,11` prints the defending side's
men with those numbers on the traced episode; the phase report now says
where the passes went by receiver number (full-back / CB / 6-8-10 / else),
full-back→CB returns, losses within 5 s of a pass to a full-back, and the
commonest passer→receiver pairs.

Measured, keeper:1 (the Ukies from their keeper), 200 episodes, before →
after: keeper→10 68 → 22 and keeper→8 38 → 18 passes; passes completed
1.3 → 0.7 per episode; deepest ball 21 m → 6 m (median); they kick it long
instead (lost in LH's third 42% → 62%, where the libero lives). The pass
to a full-back stays rare (8-10% of passes): the Ukies' keeper goes long
rather than wide, so press-the-full-back and lock-the-door fire about 1%
of man-time; the trap waits on the opponent choosing the full-back. 30 full
matches: margin +3.63 ± 0.53 (plan off) → +4.20 ± 0.45, within noise; pack
the middle 6% of LH's out-of-possession man-time.

**Same day, James on the Ukies' restart: "our 10 should be on their 6!" /
"8 on 8, 6 on 10, our 9 floats, our 7 and 11 inside with help defense for
midfield" / the 9 "helps mids then locks the door on pass to fb".** The
pairs were right (game_direct_opponents); four fixes made the picture:
- *Set-up has seconds* (`Brain::setDeadBallSetup`): while a phase is being
  set up every man who knows his job (rating > 0) is on it — the
  consistency roll is for the live game. The 10 had been rolling once at
  placement and starting 18 m off their 6.
- *A restart is not a turnover* (`World::awardRestart` / `awardKickoff`
  set the last toucher to the restart team): the keeper taking the dead
  ball counted as Lighthouse losing it, so their men counter-pressed a
  goal kick — in full matches too.
- *Who screens whom:* each winger takes the man of their midfield on his
  side (leftmost / rightmost); the 9 floats onto the one left nearest the
  ball, `nine_screen_gap_m` (8 m) off him toward the ball — higher, between
  their centre-backs and midfield, in reach to lock the door.
- *One roll per possession* (pack) and *per trigger* (press, lock): per-
  second rolls flipped the wingers between the tuck and their full-back.
  A failed roll is the old (Bielsa) job for that possession — he marks
  his full-back.

New phase `cb-build` (mig 733): the keeper shape with the ball at a split
centre-back's feet, open play — the trap's own picture; open phases now
start with the defence set too. 200 episodes, Ukies in possession, plan
off → on: their passes to a full-back 6% → 37% (4→3 the commonest pass,
111), into the middle 45% → 14%; but the full-back plays it back to the
centre-back 0.01 → 0.29 per episode and they keep it longer (0.4 → 1.7
passes; lost 26 → 33 m from their goal). The door isn't locked yet: their
full-back stands high on the touchline (30 m, 33.5 across), the ball-side
winger screening their midfield starts ~24 m from him and the 9 ~12-20 m
from the centre-back, and from a standing start a man covers ~5 m in
1.5 s — the 2-second return pass beats both. Semipro ability 68 also
means a third of possessions a man forgets the plan.

James: "7 protects midfield and adjusts to their 2 on the ball
transmission. our 9 needs to stay close enough to ball side cb to lock door
on cb to fb transmission." The winger already moves on the pass (the
trigger reads the flight); the 9 now floats no further than
`lock-the-door.reach_m` (8 m) from the centre-back nearest the ball. cb-build,
200 episodes: full-back back to centre-back 58 → 24 (0.29 → 0.12 per
episode); they lose it 37.7 m from their goal (was 33.2). Their escape now
is down the line, full-back → winger (3→7, 26) — our full-back's job.
30 full matches: margin +4.00 ± 0.44 (was +4.20 ± 0.45), within noise.

James: "that looks really bad leaving their winger wide open unmarked."
On the Ukies' goal kick our 2 stood on their full-back's spot, 20 m off
their 7: G4.63's one spot (`Brain::oneSpot`) scored the keeper→full-back
lane and judged the 7 still "in pressing distance" for a 45 m ball. The one
spot now never takes a marker more than `pressing-distance.max_off_man_m`
(6 m) from where he'd mark his own man. The goal kick now: 4 on their 9, 3
on 11, 2 on 7, 8 on 8, 6 on 10, 10 on 6, libero free, the 9 and wingers
screening — their keeper kicks long almost every time (4 completed short
passes in 200). 30 full matches +3.90 ± 0.39, within noise.

### 8.63 G4.65 — Lighthouse's two tactics on the full-back / winger, picked in the HUD (mig 734)

James 10/26: "the standard one … is 3 rules. #1 priority interception, #2
no turn, #3 contain. there is another tactic where our winger does a cover
shadow from their winger to fb … they go to the closest point of future
line of pass from fb to winger. then traverse up to fb while looking behind
… the standard thing for our fb there is to not play tight since ball to
the ground is cover shadowed so they play off for long ball. can we have in
the hud a way to pick the tactic? … they still always have a direct
opponent to mark its just how they mark."

- **Tactic A = the Lighthouse APSL model:** `defend-your-man` (168, asked
  90) — the marker's ladder on his direct opponent, named in the HUD:
  *intercept* (first to the pass to my man: the flight read's race), *no
  turn* (jump the pass as his own man's defender; and while my man has it
  with his back to our goal, `no_turn_gap_m` 0.7 m goal-side within
  `no_turn_within_m` 3 m — no dive), *contain* (he's turned: the delay).
- **Tactic B = child model "Lighthouse APSL — shadow the line":** adds
  `shadow-the-line` (169): on the pass to their full-back the ball-side
  winger goes to the nearest point of the full-back → their-winger line
  (their winger = their man nearest the full-back, ahead of him, not a CB
  and not one our midfield marks), then up it to `from_fb_m` 3 m off the
  full-back, the line re-read every tick; and `play-off-long-ball` (170):
  our full-back marks that winger `off_m` 7 m goal-side.
- **The HUD:** the admin bar's game-model dropdown (ApplyPreset, mig 652)
  lists every model; pick either Lighthouse model, Home/Away — no new wire.
- Defaults where James hadn't said: the line follows their winger wherever
  he goes; the 3 rules for every man-marker (CB on their 9, the 6/8/10).
- **(a) answered 10/27 (mig 745):** their winger drops short — our winger
  keeps the shadow, and our full-back does NOT follow him up the field
  (James: "our fb is already playing for long ball and 'off' coverage so to
  follow a winger up the field is too much to ask"). Playing off, he stops
  at our highest centre-back (4/5) plus `ahead_of_line_m` — 5 m since mig
  747 (James: "our fb can step its just that he is gonna have trouble
  getting tight so he stil relys on cover shadow from our winger" — playing
  off keeps him in reach to help, and chasing gains nothing for our
  transition). cb-build:1
  rarely springs it (passes to their full-back ~6%), so it barely moves
  the drill. **(c) answered 10/27:** yes — the 3 rules are every coach's,
  but each coach weights them differently by zone of the field, and the
  player's level gates what he can do (a low-rated man can't intercept).
  Per-zone weights built in G4.68 (§8.66). **(b) answered 10/27:** the
  ball reaches their winger anyway — our full-back drops "play off" and
  plays his 3 rules on him as his direct opponent; most likely contain.

Found on the way — why their winger was open (both tactics): G4.57's
mark-position tucked a marker toward the ball by a share of the distance
(our 2 stood 18 m infield of their 7 with the ball 35 m away), and G4.63's
jump-the-pass *chain* sent our 2 onto their full-back. Now the tuck is
capped at `pressing-distance.max_off_man_m` (6 m) and the chain never takes
a man whose own man is goal-side of the reception point. Goldens re-locked;
the 3-minute flow test now checks the last second, not one tick (it caught
a 9.6 m/s pass with the nearest man at 10.0 m).

cb-build (the Ukies' CB on the ball), 200 episodes: their way out is now
full-back → winger down the line (our 2 goal-side of him, ~5-6 m off on
his first touch); the 9 locks the door (return passes ~0). 30 full
matches: A +4.13 ± 0.60, B +3.90 ± 0.51 — within noise of each other and
of before. Open: from a standing start a man covers ~5 m in 1.5 s (a pro
~5 m in 1 s), so every press — the winger on the full-back, our 2 on their
7 — arrives late; that's the body model (Locomotion), a separate slice.

### 8.64 G4.66 — what a player can see: the men behind him are as of his last look (mig 737)

CONCEPTS.md queue NEXT #2 (James 10/26): "men BEHIND him are known only as
of his last shoulder check; scanning becomes a rated skill. Foundation for"
communication.

- **The body (`physics.vision`, `ai::Vision`):** men within `view_half_deg`
  100° of where he faces (PlayerState.face, the G4.53 body), and anyone
  within `feel_m` 2 m, are seen as they are. Everyone else is where he WAS
  at this player's last look — pos − vel × age, the same linear trick as
  the ball's perception delay (G4.3; no history state, brains stay pure),
  placed back along his run by at most `max_age_s` 3 s (the look itself
  can be older — mig 740; 0-rated = never looks). A man who ran in behind him since is
  still back where he started. `Brain::ordersFor` builds that picture as a
  copy of the World (`World::seePlayerAt`) and decides on it; the flight
  read and direct-opponent pairs are read from the true world first, so
  their per-tick caches stay shared by all 22 brains. The perfect band
  sees everything (every golden unchanged).
- **The skill — two core concepts set how often he looks.** In possession
  `scan-before-receive` (33, queued since mig 650, now wired; U-10), out of
  possession `scan-defending` (171, new; U-14). A 1 looks every
  `every_s_at1` 20 s (mig 740 — James: a 1 "should basically look less"
  than the first cut's 5 s), a 100 every `every_s_at100` 1.25 s (~0.8 a
  second — [Jordet et al. 2013]: the best Premier League midfielders),
  looks per second on a straight line between (a 60 ≈ every 2 s, a 30 ≈
  3.7 s); each look is rolled like any concept (a miss = that look
  skipped), each player on his own rhythm. 0 = never looks: only what's
  in front of him. Plus the look while the pass is on its way to him (the
  flight read's first man of the passing team), rolled per half second.
- **No blind passes** (`blind_pass_s` 0.5 s): on the ball, a mate he can't
  see is no option unless he looked within that. Found by measurement:
  without it the carrier played balls to where men USED to be, and
  completion fell 63% → 52% for both teams (carrier exempt: back to 64%).
- **HUD:** the brain overlay (wire 1.11, a trailing vision block on BRAIN —
  old clients ignore it) shows "👀 1.4s, 3 behind" per player in the side
  list and "👀 1.4s" on the pitch label.

30 full matches, same seeds, Lighthouse APSL vs Ukrainian Nationals:

| | before | vision |
|---|---|---|
| margin | +4.13 ± 0.60 (6.20 – 2.07) | +2.57 ± 0.59 (5.00 – 2.43) |
| pass to a mate, LH / UK | 62.7% / 63.2% | 65.8% / 64.2% |
| recycles per match, LH / UK | 137 / 271 | 61 / 132 |
| clearances per match, LH / UK | 77 / 52 | 101 / 77 |
| Ukies shots / final-third entries | 17.7 / 73 | 29.3 / 90 |

Mig 740 (a 1 every 20 s, looks per second linear — so a mid-rated player
looks MORE often than the first cut): +3.67 ± 0.50 (6.13 – 2.47); pass
64% / 63%; recycles 68 / 145; clearances 98 / 81; Ukies shots 27, entries 89.

The carrier who can't see his support behind him no longer recycles to it
— he clears or goes forward; Lighthouse's man-markers, facing the ball,
lose a man who moves behind them between looks, and the Ukies get more
into our third. Open: the stale picture keeps the man's CURRENT velocity
(a stateless approximation — a true "as of then" needs position history);
the harness runs ~2× slower (a World copy per brain per tick; ~110 µs a
tick, far inside the 33 ms live budget). Next: communication — the call
that refreshes a teammate's picture ("man on", "turn", the full-back's
cover-shadow adjustment).

### 8.65 G4.67 — mark by distance from the ball: tight near it, protect the middle away from it (mig 743)

James 10/26: "marking should be proximal to ball. so further away from
ball the more you protect middle … closer to ball the more tight" / "that
will make our fb play more central on build out by ukies".

- **`near-tight-far-zone` (122)** — in the curriculum since the import
  ("tight near the ball, zone away from it"), queued, taught from nowhere;
  now wired, core, U-14 (`ai::NearTightFarZone`). His man within `near_m`
  10 m of the ball: `tight_m` 1 m off him (or man-orientation's tighter
  gap), goal-side and ball-side. At `far_m` 35 m or more: `loose_m` 6 m off
  him, goal-side and toward the middle (inside). Gap and direction blend
  on a straight line between. It replaces mark-position's spot when it
  applies (rolled per second; a miss = mark-position, tuck toward the
  ball); play-off-long-ball and the one spot still refine it after.
- HUD names it: "mark tight (near the ball)" / "protect the middle (far
  from the ball)".
- **Lighthouse asks 90.** It inherited Bielsa's 20 (Bielsa marks tight
  everywhere), which fired it one second in five; both Lighthouse tactics
  inherit the 90. Every other U-14+ side plays it at its own quality (it's
  core), the Ukies included.
- cb-build trace: their CB on the ball, our #3 on their #11 out wide reads
  "protect the middle", ~4 m inside him; tight again once the ball goes to
  their full-back. loose_m (6 m, the same as G4.65's max_off_man_m) is the
  dial for "more central".

30 matches (same seeds) vs G4.66's +3.67 ± 0.50: +1.83 ± 0.51 with
Lighthouse at Bielsa's 20; +1.83 ± 0.42 (4.83 – 3.00) at 90. The drop is
mostly at the other end — Lighthouse scores 6.13 → 4.83 now the Ukies'
markers are tight near the ball (they play it at their own quality);
Lighthouse concedes 2.47 → 3.00. Pass completion 65% / 63%. Lighthouse
out of possession: mark tight 6%, protect the middle 3%, plain mark 7%.
Goldens re-locked.

### 8.66 G4.68 — the 3 rules weighted by coach and third; late = contain (mig 747)

James 10/27, on (b): "the w is his do (direct opponent) so he reads the
pass (ball) and player. so he resumes normal marking concept. intercept, no
turn, contain. its just most likely he is looking at contain but depends."
On (c): "a general rule for bielsa but i would say all coaches. but its
calibrated for the 3 differently depending on coach and part of field. and
even level of player to be able to lets say intercept."

- **Late = contain.** Jump-the-pass sent a man's own defender who couldn't
  get there in time (the "late" pick, within `jump_max_m`) at the reception
  point anyway — he arrived as the man turned. With defend-your-man on he
  now runs to `contain_gap_m` 2.2 m goal-side of where it lands and the HUD
  says *contain*; in time, it's still *no turn*.
- **`game_model_ladder`** (model, zone own/middle/their, rung intercept/
  no_turn/contain, weight 0-100): how often a coach's marker plays each
  rule in each third when it's on, rolled per second after the concept's
  own roll (`Brain::rung`, zone = the third of the reception point / the
  ball). Child models inherit row by row; missing = 100 (no change). A miss
  drops a rung: no interception → he arrives so his man can't turn (he'd
  have won the race); no "no turn" → contain. Contain's weight only names
  the rung today (its miss is the same delay move) — it gets a real miss
  when a coach asks for one. The player's level still gates everything:
  min(ability, demand) on defend-your-man, and the flight-read race decides
  whether he CAN intercept.
- **Lighthouse APSL** (both tactics): own-third intercept 50 — a missed
  interception there is a man through on goal. Everything else 100.
  Starting numbers; James sets the rest.

30 matches, same seeds, vs G4.67's +1.83 ± 0.42: tactic A +2.60 ± 0.56
(5.20 – 2.60), tactic B (`home:shadow-the-line=90,play-off-long-ball=90`)
+2.20 ± 0.48 — within noise. Harness note: a tactic is a demand override on
the team's model; GAME_TEAM_HOME takes a TEAM name (a model name there
loads no squad — that run reads −1.80 and means nothing).

### 8.67 G4.69 — playing off, the full-back attacks the ball in the air (mig 752)

James 10/27: "our full back needs to be agressive in reading the type of
pass when he is in the off coverage tactic. he does not 'wait' for ball to
reach. he reads pass. in the air he chases it and trys to recive facing
their goal to play forward. its bad to be running backwards toward own goal
but that is 2nd option. but if on ground he does normal intercept, no turn,
contain."

- **`Brain::attackTheDrop`** (play-off-long-ball 170), ahead of jump-the-
  pass: their pass in the air (above control height, or rising) whose first
  man to it (the flight read) is his direct opponent — he goes on the kick,
  to `face_up_m` 1.5 m past his own first point on its flight, along its
  path, so it comes onto him facing their goal. He goes whether or not he
  wins the race (no intercept weight, no contain). HUD: *attack the ball in
  the air*; when that spot is behind him, *run back for the ball in the
  air* — the second option.
- On the ground nothing changes: the 3 rules (§8.66).

cb-build:1 (tactic B): it fires — under 0.5% of Lighthouse's man-ticks,
because the Ukies seldom loft it to the winger from there. 30 matches,
tactic B: +2.77 ± 0.52 (5.43 – 2.67), vs +2.20 ± 0.48 — noise. Not
measured: how many of their aerial balls to the winger our full-back now
wins; the harness has no counter for it yet.

### 8.68 G4.70 — communication, the first call: "adjust your shadow" (mig 753)

CONCEPTS.md queue #3 (James 10/26: "the full back would communicate to the
winger the cover shadow adjustment"). Three parts, all stateless like the
look (§8.64):

- **KNOWING — `call-adjust-shadow` (172, style, amateur):** a concept per
  call. Lighthouse's tactic B asks 90.
- **SAYING — the `communication` attribute (mig 655, now wired):**
  `LevelParams::speak_pct`, the % of due calls he makes, rolled per second:
  by level u10 20 · u14 40 · amateur 55 · semipro 70 · pro 85 · world 95
  ([FH] starting numbers); his rating bends it (`core::Communication`: 0 →
  none, 50 → his level's, 100 → double, capped at every call). The 13th
  attribute — PlayerAttributes, wire 0x37 (append-only), the HUD editor.
- **HEARING — `Brain::shadowCall`:** the call is due when their pass is
  going to their full-back in our half (the trap's read), our winger is
  rated to shadow the line, the full-back playing off their winger SEES
  him, and our winger DOESN'T (he's behind him). Made = knows × says. Our
  winger then sees that one man as of `hear_s` 0.5 s + his own perception
  delay ago instead of his last look — the call refreshes his picture.
  Concentration (does he listen) isn't an engine attribute yet.
- **HUD (wire 1.12):** a trailing call block on BRAIN (`u8 call` legend
  index, `u8 to`); the pitch label reads "📣 call: adjust your shadow" with
  a white dashed line to the winger; the side list adds "· 📣 … → <name>".
- **Harness:** the phase report prints calls made / seconds due.

cb-build:1, 200 episodes, tactic B: a call is due ~0.5 s an episode, made
46% of it (the call's 90 × Lighthouse's amateur-level speak). The drill
can't tell call-on from call-off (shots 2.0% vs 1.5%; passes to their
full-back lost within 5 s 52% vs 57%). 30 matches, tactic B with the call:
+3.93 ± 0.59 (6.03 – 2.10) vs +2.77 ± 0.52 without — ~1.5 SE, mostly
Lighthouse scoring more, so not claimed for the call. Next calls (taught
by level): man on, turn, time, line, squeeze.

### 8.69 G4.71 — every player listens (or doesn't); man on, turn, time, squeeze, line (mig 754)

James 10/27: "yes we need whether he listens to communicaiton. really for
all players. same with the other calls."

- **HEARING for everyone:** the `concentration` attribute (mig 655, now
  wired, the 14th; wire 0x37 1.13) → `LevelParams::listen_pct`, rolled per
  listener per second per call: by level u10 40 · u14 55 · amateur 70 ·
  semipro 80 · pro 90 · world 95 ([FH] starting numbers); rating bends it
  like communication. And `physics.voice.range_m` 40: further from the
  talker, nobody hears it.
- **One machine for every call (`ai::Call`, `Brain::calls/says/hears`):**
  per team per tick, which calls the moment asks for, who's due to make
  each (`Orders::due`), whether he does (`call`/`call_to`), and whether
  each listener takes it in (`Orders::heard`). All stateless.
- **The calls** (all core — every side plays them at its own quality):
  - *man on* (173, U-10): our man on the ball / receiving has a man within
    `near_m` 5 m he can't see; the nearest mate in voice range who sees
    both calls it. Heard: that man is `hear_s` 0.3 s old in his picture —
    he shields / plays it back off the real threat (G4.60's keep-it).
  - *turn* (174, U-10) / *time* (175, U-14): nobody within `free_m` 7 m,
    and his look is stale (> blind_pass_s); back to their goal = turn,
    facing up = time. Heard: everyone behind him is `hear_s` 0.5 s old —
    he sees he's free, and his blind-pass gate opens.
  - *squeeze* (176, U-14): the keeper, when line-step reads a covered
    ball and a back-line man is a metre or more under the step. Heard: a
    back-line man (2-5) who knows line-step steps even if his own roll
    missed.
  - *line* (177, U-14): the keeper, when a back-line man is `gap_m` 2 m or
    more under the line's highest man with one of theirs between them.
    Heard: one who knows line-hold holds it even if his own roll lapsed.
  - *adjust your shadow* (172, G4.70) now runs on the same machine.
- **HUD:** wire 1.13 `to` 254 = the back line ("📣 call: squeeze → back
  line", no line drawn).
- **Harness:** the phase report prints per team, per call: seconds due per
  episode, % made, listeners who heard it per call made.

cb-build:1, 200 episodes: Ukies (on the ball) man on due 1.3 s/ep, made
67%, heard by 0.81; turn 0.7 s, 67%, 0.80; time 0.4 s, 61%, 0.74.
Lighthouse squeeze 3.0 s, 66%, heard by 0.81 of 4; line 2.1 s, 65%, 0.45
— the keeper is past voice range when the line is up near halfway. Open:
a centre-back as second organiser (who talks for the line is a coach's
choice). 30 matches, calls off for both (exactly G4.68's +2.60 ± 0.56)
vs on: +2.20 ± 0.47 (4.77 – 2.57) — noise; pass completion 65.0 / 63.4%
vs 64.5 / 63.3%. Calls change little in this measure yet; watch them.

### 8.70 G4.72 — Lighthouse on the Ukies' restart: the 9 in the box, wingers as book-ends, full-backs off (mig 755)

James 10/27: "lh 2 & 3 still too close to 7 & 11 on restart. lh 9
positioning makes no sense. he should be in middle of their 6 and 8 and
able to cover shadow them. like in a box between ukies 4,5,6,8. lh 7 and
11 should be book ends to lh 8,10."

All in `Brain::packAndTrap` (pack-the-middle 165), so the live game and the
phase setup place them the same way:

- **The 9:** the middle of their two centre-backs and their two deepest
  central midfielders (the 4, 5, 6, 8 box) — between the passer and both
  6 and 8. The 8 m lock-the-door clamp no longer applies before the
  trigger; on the pass to a full-back he still locks the door.
- **The wingers:** level with our 8 or 10 (the one nearer his shape's
  side), `bookend_gap_m` 6 m wider — a line of four, 7-8-10-11, instead of
  screening their 6/8 from in front of our 8/10.
- **The full-backs (2/3) on their restart** (their dead ball, or their
  keeper on the ball): `fb_off_m` 10 m goal-side and `fb_inside_m` 5 m
  inside their winger (HUD "play off for the long ball"). Before, with no
  4-3-3 'out' rows, they stood on the formation shape pushed up to the
  press line — 0.8 m from the Ukie wingers. In open play they mark as
  before.

keeper:1 setup: 7/8/10/11 at 26.5 m, ±13.9/±7.9 across; 9 at 17.5 m,
centred; 2/3 at 59 m vs their wingers' 49 m, 28.5 vs 33.5 across. Their
keeper still punts 97%. cb-build:1, 200 episodes, vs G4.71: over halfway
8.0% (14.5%), final third 4.5% (8.5%), shots 2.0% (3.0%). 30 matches:
+2.77 ± 0.45 (4.87 – 2.10) vs +2.20 ± 0.47 — noise, conceding 2.10 vs
2.57.

### 8.71 G4.73 — hurry the keeper (or drop); press the bad touch (mig 756)

James 10/27: "in any system we will go after their keeper or press on bad
touch etc or just drop. that is more of a game model thing" / "the norm is
go after if you think you can hurry a pass. if not drop" / "if bad touch
that is almost universal to press" / "can we get these in as concepts?"

- **`hurry-the-keeper` (178, core, U-14):** their keeper on the ball in
  open play, or their back pass going to him: our nearest outfielder goes
  only if he can get within `hurry_m` 3 m before the keeper is ready —
  `settle_s` 1.5 s after he has it (a back pass: its flight + settle). He
  goes on the line to the keeper's nearest man. Can't make it: drop (the
  normal shape). HUD "hurry the keeper".
- **`press-the-bad-touch` (179, core, U-10):** one of theirs miscontrols it
  (World's control bobble, now recorded: `World::badTouchSlot/Tick`) —
  our nearest man goes for the loose ball for `window_s` 1 s. HUD "press
  the bad touch".
- **Their keeper is nobody's mark:** the zonal hand-out skipped nothing,
  so a marker could pick the keeper (seen in a cb-build trace: our 10 "mark
  tight → their #1"). Now he's hurried or left.
- `World::ownedAtTick()` (when the owner got it) — not hashed, goldens
  unchanged.
- Both are core: default demand 100 for every model (a model can ask
  less: an explicit row).

Rare in the drills (bad touch 0.00% of man-ticks in cb-build:1; hurry
never — their goal kick is a restart, and back passes to the keeper
seldom come from these pictures). The phase report now prints rare orders
too. 30 matches: +2.93 ± 0.54 (4.97 – 2.03) vs +2.77 — noise.

### 8.72 G4.74 — the game model on the HUD: change any concept's demand live

James 10/27: "did we agree that all concepts [are] valid and that its a
matter of focus in the game model right? so where do we set those? if not
set by us it should go to a default" / "should there be a screen or right
on the hud but collapsable" / "hud would be good to change mid game to see
diff behavour?"

- **Yes, already the rule (mig 652):** a player plays min(his ability, his
  team's demand); a concept the model doesn't set takes the default —
  core 100 (as well as he knows it), style 0 (off: a coach's choice, e.g.
  shadow-the-line, 3-rule marking). Models live in `game_model_concepts`
  rows; a child model inherits its parent's.
- **The HUD:** admin pill **🎛 MODEL** beside EDIT opens a collapsible
  panel: Home / Away, the model the team plays, and every concept's demand
  as a slider with its source — *default*, *model* (its own row), *LIVE*
  (changed here; ↺ puts it back). Filters: Model + live (default view),
  Live, All; a search box. A slider is sent on release; the team's
  knowledge is recomputed at once (`GameServer::recomputeKnowledge`), so
  behaviour changes mid-match. Live changes are NOT saved and picking a
  model (the preset dropdown) clears them.
- **Wire 1.14:** MODEL_DEMANDS 0x40 (s→c admin) and SET_DEMAND 0x41 (c→s
  admin); codec round-trip tests.
- Save landed in G4.76 (§8.74).

### 8.73 G4.75 — beat the high line: the keeper reads it, or plays short (mig 757)

James 10/27: "why does ukie keeper go deep every time lol. its high line i
get it. but that is what a pro player would do. semi pro and amateur and
youth are dumber lol." / "high line go over top number 1 is a concept but
players should be rated on understanding it, percieving it, ability to
carry it out, etc"

Why 97%: the keeper never CHOSE long. His pass search only takes men 3 m+
further forward (split centre-backs level with him never qualify; our 8/10
sit in the lanes to their 6/8), so every goal kick fell through to the
punt — at every level.

- **`beat-the-high-line` (180, core, taught from semipro):** their last
  outfield man `high_m` 30 m+ off his goal line → a lofted ball `behind_m`
  8 m past him toward our most advanced man (HUD "over the high line").
  The three ratings James named are the three layers: UNDERSTANDING = this
  concept (amateur / youth 0; semipro at its quality 68; pro 82; world 92;
  a model's demand caps it), PERCEIVING = his picture (scanning,
  anticipation: where he THINKS their line is), CARRYING IT OUT = the
  lofted kick (passing error, kick range).
- **Not read** (doesn't know it, or his roll misses): the keeper's short,
  simple ball to the nearest open man within `keeper_short_m` 25 m, any
  direction (HUD "keeper: short and simple"); the old forward-pass search
  and the punt only when nobody is open.
- First wired for the keeper; the same read for an outfield passer is next
  if James wants it.

keeper:1, 200 episodes — Ukies (semipro) read it: over the high line 0.69
a episode, short 0.33; with the read off (`away:beat-the-high-line=0`, the
amateur / youth picture): short 1.07, over 0, and passes are 69% of their
losses (45%). 30 matches: +2.43 ± 0.48 (4.87 – 2.43) — noise.

### 8.74 G4.76 — the taxonomy, the game model, and both in the DB (mig 762, wire 1.15)

James 10/27: "lets really define what the football taxonomy is and then
what a game model is and how it will be stored in db normalized of course
and be editalbe in hud right?" / "can we do the models in oop c++ or should
they be in db" / "make a game model though called "Semi Pro Standard" this
is the 4231 the ukies are running … make the ukies inherit (in db like you
said) all of the Semi pro standard"

- **The taxonomy is the dictionary, facts only:** moments (`game_moments`,
  5) → principles (`game_principles`, a tree) → concepts (`game_concepts`,
  family, moment, principle, taught-from level) + techniques, attributes,
  roles, phases. Mig 762 drops `game_concepts.kind` (core/style): whether a
  coach asks for a concept is the coach's call, and the C++ applied it as
  a hidden default (core 100, style 0).
- **The player** (ability) is separate: understands it (level / his own
  `game_demo_player_concepts` row), sees it (scanning, anticipation),
  executes it (techniques, attributes).
- **A game model is a coach's answer, as data:** `game_models` (parent_id),
  demand 0-100 per concept (`game_model_concepts`), per role
  (`game_model_role_concepts`), the 3 rules by third (`game_model_ladder`),
  numbers per concept (`game_model_concept_params`; global starting values
  in `game_model_params`). A player plays min(ability, demand).
- **Rule:** a top-level model (no parent) has a row for EVERY concept and
  all nine ladder cells — deferred constraint triggers
  (`fh_game_models_complete`) refuse a commit otherwise, so a migration
  adding a concept must say what each top-level model asks. A child model
  holds only its differences; no row = its parent's. Mig 762 wrote every
  root's missing rows at the old code default (nothing changed on the
  pitch); teams with no coach play **Curriculum** (every concept the club
  teaches, nothing chosen), so `game_demo_teams.game_model` is NOT NULL.
  `ConceptRegistry::defaultDemand` remains only for DB-less boots / tests.
- **Models in the DB, behaviour in C++ OOP:** a C++ subclass per coach
  would make every tweak a rebuild and the HUD unable to save. One
  `GameModel` + `resolveGameModels` walks the parent chain; it keeps each
  model's OWN rows (`own`, `own_ladder`) apart from the resolved values and
  records each value's `origin`, so it re-resolves after a save.
- **Semi Pro Standard** (new root, 4-2-3-1): the Ukies' model as it played
  — U.S. Soccer U17+ plus their line-step 68, flattened, citations kept.
  **Ukrainian Nationals** is now its child with no rows: verbatim for now,
  their own changes go there.
- **HUD (wire 1.15):** MODEL_DEMANDS gains a trailer (`u8 parent`, per
  concept `u8 origin` model); sources are own / inherited (shows the parent
  model's name) / LIVE. 💾 on a live change = SAVE_DEMAND 0x42 → upsert
  into the team's own model (citation "Set in the game HUD, <date>"),
  every model inheriting it re-resolves at once; ↺ on a saved row of a
  child model deletes it (back to the parent); a top-level model has no ↺
  (it must state everything). Filters: All (default), Own + live, Live.
- **Numbers too (the panel's Numbers view):** each concept number (151,
  `game_model_params` owner concept whose code is a concept) and the nine
  3-rule weights, with source *global* / *own* / inherited model / *LIVE*,
  the same 💾 and ↺. Numbers are the one exception to "a top-level model
  states everything": a number no model sets is the global
  `game_model_params` row (a distance of 0 would be nonsense, and the
  global row is the starting value every coach tunes from). Brain holds
  one `ConceptBook` per team (`books_[2]`, `bookOf(slot)`; each method
  reads his own team's), configured in `recomputeKnowledge` from global +
  model chain + live; DB-identical books, so the goldens didn't move.
  Wire: MODEL_PARAMS 0x43, SET_PARAM 0x44 (op 0 live, 1 undo, 2 save,
  3 inherit); keys `concept.<code>.<param>` / `ladder.<zone>.<rung>`,
  milli-units. APPLY_PRESET clears live numbers too.
- **G4.77, own vs parent:** James 10/27 "so if a model inherits it lists
  diff? … if -10 then its 60?" — no: a child's row REPLACES the parent's
  value (not an offset; a parent change never shifts a number the child
  chose, and offsets could leave 0-100). To make the difference readable
  anyway, MODEL_DEMANDS and MODEL_PARAMS carry a second trailer (what the
  parent plays, per concept / number) and the HUD tags an own or live
  value with its difference: "own −25", tooltip "Semi Pro Standard plays 85".

### 8.75 G4.78 — everyone talks, everyone reads the high line, the false 9 drops in (mig 764)

James 10/27: "1) all players should communicate so yes. 3) yes everyone
including false 9 dropping in and taking care of it to send long ball like
harry kane. (that should be in lh game model as that is how our 9 should
play when Luke Breslin is in)"

- **The organiser:** man on / turn / time already came from whichever
  mate was nearest; squeeze and line were the keeper's only. Now the keeper
  calls them while his voice (`physics.voice.range_m` 40) reaches the
  whole back line; when the line is up and out of his range, the
  back-liner who talks the most (his `speak_pct`, from communication)
  organises, the more central on a tie.
- **Everyone reads the high line (180):** one helper, `overTheLine`, for
  the keeper and any outfield passer with time (not pressed). New: the
  PERCEIVING half — the runner is onside within `runner_from_line_m` 12 of
  their last man, already going forward at `runner_speed_mps` 3, and
  `race_m` 3 nearer the drop (behind_m past their line, his channel) than
  any of theirs, keeper included; the ball travels `pass_min_m` 20+ and is
  in the passer's range. **Bug found:** G4.75's keeper had no race check —
  16-19 balls a match over the line, 91% to them (the +2.43 headline hid
  it). Now a keeper who reads it but sees no race on plays short.
- **false-nine-drop (181, role skill, taught_from NULL):** off the ball,
  our ball `from_line_m` 25+ short of their back line → the number 9
  drops to `drop_m` 14 in front of it, central, ahead of the ball (HUD
  "false 9: drop in"); the most advanced man is now a winger, so the run
  in behind becomes his. On the ball the 9 goes over their line when
  `space_m` 20 of grass is behind it (no high line needed). Asked by the
  Lighthouse and Lighthouse APSL models (90), 0 everywhere else; known by
  Luke Breslin (his row, 70) — so it's how OUR 9 plays when Luke is in.

10 matches LH APSL v Ukies: over the line 0.5 / 1.5 a match (was 16-19),
60% / 27% reach our man; keepers short 30 / 43 a match; margin +2.90 ±
1.23. cb-build:0 trace: Luke drops on our centre-back's ball.

### 8.76 G4.79 — realistic top speeds and acceleration (mig 766)

James 10/27: "4. yes make moveemnte realistic!" (open since G4.52,
"acceleration too slow").

- The law was right (mono-exponential sprint, τ — §8.49); the numbers were
  not. Pace 50 ran 6.4 m/s and pace 100 7.4 (23-27 km/h); our sides (pace
  61) topped out at 6.6 m/s. Real maximal sprint speeds [Mendez-Villanueva
  et al. 2011 by age: ~U13 7.1, U15 7.9, U17 8.4, U18 8.6 m/s; Haugen et al.
  2014 by level; Premier League tracking: match top speeds 32-34 km/h, the
  fastest 36-37]: amateur ~7.5-8, semi-pro ~8.3-8.8, pro ~9-9.5, elite 10+.
- **Pace** now 0 → 6.0, 50 → 8.0, 100 → 10.0 m/s: Lighthouse / Ukies run
  8.4 m/s (30 km/h). **τ** 1.4 / 1.1 / 0.85 s at 0 / 50 / 100 (soccer
  force-velocity profiles V0/F0 ≈ 1.0-1.3 s [Samozino/Morin; Jiménez-Reyes
  2018]): first acceleration ~7.5 m/s², 10 m in ~2.0 s from standing.
  Unrated sides' `max_speed_cms` ×1.35 (U10 6.2, U14 7.5, amateur 7.9,
  semi-pro 8.5, world 9.2 m/s average).
- **What it exposed** (10 matches LH APSL v Ukies, before → after): shots a
  match 45 / 32 → 72 / 55 (real ~12 a team), final-third entries 145 / 97
  → 188 / 133 (real ~40-50), goals 5.9-3.0 → 11.6-6.4 (real ~2.7 a
  match). Movement is now realistic; the defending block (compactness,
  pressure on the ball in and around the box) is the biggest realism gap
  and is next.

### 8.77 G4.80 — semi-pros stay on their position; the named ways off it; braking to arrive (mig 771)

James 10/27: "guys are just over running the ball and look like the are on
skates lol" and "semi pro players also don't bunch up like we are seeing.
they are 'lazy' unlike little kids. unless they are told to rotate or its
in ther profile or game model they tend to stay tethered to position.
there are exceptions a winger droppping down a mid checking in. a full
making an overlap.. put them in"

- **Tethered (Levels.hpp `shape_pull_pct`):** the ball pull on every
  anchor was `swarm_pct` at every band (semi-pro 12%). It is now its own
  field, defaulting to the swarm; semi-pro, pro and world set it to 0.
  The swarm still sets their dive eagerness and chaser count. Brain-side,
  not hashed.
- **The block moves up with its own ball (`possessionX`):** formation
  bases are the kick-off shape in our own half, and `anchorFor` slides
  them only 25% of the ball's x (capped 14 m), which is a defending slide.
  With the swarm pull gone, nothing brought a semi-pro side up the pitch.
  In possession the shape keeps its lines' spacing × `ours_depth_k` 1.4
  around the team's middle, and the middle stands at `ours_slope` 0.45 ×
  the ball's x + `ours_offset_m` 2 [FH; team centroids move in phase with
  the ball — Frencken, Lemmink, Delleman & Visscher 2011]. Ball on their
  18: centre-backs about halfway, the front three on their line.
- **G4.80b, the shape's phase is the team's possession:** the harness
  found hold-shape targets jumping ~24 m in one tick, mid-possession.
  `ours` was keyed on the owner, so every one of our passes whose
  meet-the-pass read didn't fire flipped the whole team to its defending
  block and line for the flight, and back on the touch. Men 12 m off
  their spot chased a target that wouldn't stay put: that was the skating.
  Now `shape_ours` = ours, or a loose ball in open play we touched last.
  Dead balls keep their own shapes. The chasers and the press still read
  `ours`.
- **The named ways off a position** (each a core concept every top-level
  model states, per mig 762; demand 60, Lighthouse 80, Bielsa/Gasperini
  overlap 90, Curriculum 100). These go by formation number, and his side
  is his base's:
  - *overlap (41, now wired, taught from amateur):* our 7/11 on my side
    has it at least `infield_m` 8 inside the touchline, no more than
    `from_halfway_m` 5 short of halfway, ahead of me → the full-back (2/3)
    runs `ahead_m` 8 beyond him, `wide_m` 4 in from the line.
  - *winger-come-short (182, amateur):* our ball in our half on my side,
    me `gap_m` 18+ beyond it → come back on my line to `ahead_m` 10 in
    front of it.
  - *mid-check-in (183, u14):* a 6/8/10 marked (`tight_m` 4) with the ball
    `far_m` 14+ behind him, and no mate already showing → show `show_m` 8
    from the carrier on the line between them.
- **Brake to arrive (`brakeToArrive`):** seek's arrive radius (1.5 m) was
  sized before momentum and real top speeds; at 8.4 m/s a man needs ~8 m
  to stop, so runs went past their spot and came back. He now runs no
  faster than v ≤ √(v_end² + 2·b·d), with b = `arrive_decel_mps2` 4.5
  [Reynolds 1999 "arrive"; Harper, Carling & Kiely 2019: high-intensity
  decelerations past −3 m/s², maxima −5 to −8]. v_end is 0 to a spot and
  `arrive_through_mps` 3 to a ball he's running onto. Runs beyond the line,
  tackles and dives are exempt.
- **Braking on its own τ (Locomotion.hpp `brake_tau`):** slowing down isn't
  the sprint law run backwards; a player plants and brakes harder than he
  accelerates. Along his line a wish below his speed now relaxes on
  `brake_tau` (skill deceleration: 0.5 / 0.35 / 0.25 s at 0 / 50 / 100)
  instead of τ. At 50, 8 m/s comes to a stop in ~1.3 s and ~5 m (it was
  a ~9 m glide). Default brake_tau = 0.3 τ for bodies without the skill.
- **The legs (players.js):** strides follow the direction he moves, not
  the way he faces, so a man backpedalling or shuffling side-on while he
  watches the ball steps sideways instead of striding forward under a
  sliding body.
- **Harness lines (fh-game-match):** the crowd (outfielders within 10 m of
  the ball) and the outfield's width × length, with and without the ball;
  distance off his position (a holder against the spot he holds) with the
  reasons; possession spells and the hold-shape gap in a spell's first
  5 s vs after; ran-past-his-target player-seconds.

10 matches LH APSL v Ukies (G4.79 → G4.80 → G4.80b): shots a team 72 / 55
→ 48 / 47 → 42 / 47; final-third entries 188 / 133 → 117 / 119 → 118 /
124; goals a match 18.0 → 17.2 → 12.9; possession spells 849 → 695 a
match. A holder settled in possession is 8.2 m from his spot (was 12.5).
Within 10 m of the ball: 1.7 with it, 3.0 without. Still far from real
(~12 shots a team, ~2.7 goals, ~200-300 possessions): the defending block
stays next.

### 8.78 G4.81 — where the shots come from; a pass to a man reaches him

James 10/28: "go ahead with the defending block" (G4.80's NEXT). Measured
first. New fh-game-match lines (all printed per team): shot anatomy (the
spell's age, defenders goal-side of the shooter when he shot and when he
got it, his carry, where the spell began), rest defence at each
turnover, how a team loses the ball within 35 m of its own goal, every
pass to a picked man by how free he was, and two tracers —
`GAME_TRACE_LOST=n` (own-third losses) and `GAME_TRACE_FREE=n` (+
`GAME_TRACE_FREE_TICKS=1`: the flight every 0.2 s) for passes to a man
10 m+ free that went wrong.

What it showed (10 matches LH APSL v Ukies, G4.80): 53-62% of shots came
from a ball won within 35 m of the goal it attacks, 56-62% within 5 s of
winning it, the shooter taking it with 0-2 defenders goal-side 58-62% of
the time and shooting within 3 m. At the turnover the losing side had
7-10 men behind the ball. So the settled block was rarely carved open:
the defending side gave the ball away in its own third ~60 times a match
(real ~10-15) and the other side shot at once. And that was passing: an
ordinary pass reached the man it was played to 37 / 42% of the time;
passes to a man with nobody within 10 m reached him 40-49% and were LOST
16-26% (a free man gets ~95% in life). The traces:

- **The receiver ran off it.** Only the mate the flight read put first
  (G4.49) met the pass; 41-47% of the time that was somebody else, and
  the man it was for held his shape — whose possession spot (G4.80) moves
  upfield — so 0.3 s after the kick he was "hold shape" 54-62% of the
  time, 10-15 m off the ball when they took it.
- **Teammates took passes meant for someone else**, the man beside the
  passer 0.1-0.3 s after the kick, the World's capture taking any ball
  within 0.5 m.
- **Passes were slow.** Every ground pass went at a preset 14 m/s (8 for
  short ones) whatever the distance: a 25 m pass took 3.5 s, a 13 m one
  2.6 s — 3-5 s for a defender to close.
- **Passes went where a moving man had been** (4-8 m/s, 2.5 s of flight).

The fixes:

- **The pass is for somebody** (`BallState.pass_to`, set from the
  passer's `Orders.pass_to`; FH original). He meets it (MeetPass) even
  when another mate would get there first; the rest LET IT RUN unless he
  can't beat them to it (then our first man rescues it). For the kick's
  half-second lockout the passer's other mates don't capture it — they
  step over it or out of its way, as the body block (G4.25) already
  assumes for shots. A deflection or a touch clears it.
- **His lapse** (meet-the-pass rolled and missed): he lets it come to
  him — steps onto its line and waits ("come to the ball!" is the coach's
  call) — Why "lapse: lets it come to him". Waiting where he stood was
  tried and was worse (the ball rolled past 2-3 m off him).
- **Weighted passes** (`core::weightedPassSpeed`): a ground pass to a
  man is struck to arrive at `kPassArriveSpeed` 6 m/s; under the roll
  decay a ball loses 0.39 m/s per metre, so v0 = 6 + 0.39·d, capped at
  the 20 m/s capture speed (25 m → 15.8 m/s, 2.5 s). The passer's safety
  read (passSafe [Buckland]) walks the same speed.
- **Into his path:** a ball aimed at his feet goes where he'll be when it
  arrives (flight time by Simpson's rule on 1/v), at most 10 m on.
- **Tried and dropped:** a control reach of 0.9 m (was 0.5) — defenders
  reach passes as much as receivers do; shots went to 77 a team.

10 matches each, G4.80 → G4.81: pass reaches the man it was played to
37 / 42% → 60 / 63%, lost 35 / 27% → 26 / 23%; free (10 m+) passes 40-49%
→ 57-62%, lost 16-26% → 11-15%; own-third losses 59 / 62 → 53 / 59 a
match; shots 42 / 47 → 40 / 47. Without the weight and lead: 48 / 52
shots, 51 / 58% to the man — they earn their place.

**Mastery (built, OFF until James says):** `core::defaultAbility` takes
`ability.mastery.lapse_kept_pct` (a game_model_params row; absent = 100 =
every concept at his quality, as before). Each band a player stands above
the band a concept is taught at keeps that share of his misses — at 50 a
60-quality semipro meets the pass (taught u10) 95 times in 100 and plays
the semipro-taught concepts at 60. FH original: fundamentals from his u10
years don't lapse like last season's. Per-player ability rows (mig 639)
are untouched. At 50 on top of G4.81: shots 36 / 42, goals 11.9 a match
(14.7 without), spells 627 (679).

Still far from real (~12 shots a team, ~2.7 goals, ~250 possessions):
shots still mostly come off an own-third turnover against 0-2 men
goal-side. Next: the passes still lost to a man 2-5 m off the receiver
(28-33%), and the keeper's short ball and the lapse short ball, which
check the lane only (passSafe never runs on them) — 30% of own-third
losses between them.

### 8.79 G4.81b — pro reference numbers in the DB (mig 782)

James 10/28: "can we actaully look at pro data and get it into db and then
we can work off it and referecne it?" — "whatever pro data is semi pro is
worse of course". Until now "real" in these notes was figures from memory
(the "~10-15 own-third giveaways" of §8.78 was one, and it was wrong).

- **Source:** StatsBomb Open Data [StatsBomb] (github.com/statsbomb/
  open-data — event data, free with attribution), Premier League 2015/16,
  all 380 matches. Shots carry a freeze frame of the players, so
  "defenders goal-side of the shooter" is measured, not guessed.
- **Measured by** `game/scripts/benchmarks_statsbomb.py <comp> <season>`
  (run with `python3 -I`; downloads ~1.2 GB, keeps nothing unless given a
  cache dir) with the harness's own definitions, written into
  `game_benchmark_metrics` (code, label, unit, definition — 33 measures)
  and `game_benchmarks` (source, level, competition, season, matches,
  value). Another league or season = rerun and add rows; a semi-pro source,
  if one ever exists, = level 'semipro'.
- **fh-game-match prints PRO REFERENCE** at the end of every match run:
  each measure, home, away, pro.
- **Definitions differ in one place:** a StatsBomb possession needs
  control; the harness counts every change of the ball's owner, so a
  touch-and-lose is a spell there and not here. It inflates the game's
  spell and own-third-loss counts somewhat — not by 5-25×.

Pro (a team a match unless noted): 12.9 shots, 2.5 goals a match (no
penalties), 378 open-play passes at 79% (ground passes 91%), 121 spells a
match of 47 s, 44 final-third entries, 2.1 balls lost within 35 m of their
own goal (12.5% shot at inside 10 s). Open-play shots: 72% come 20 s+
into the spell and 58% from a spell begun 70 m+ from goal; 0-2 defenders
goal-side 28%, 7+ 24%; 16% from 25 m+.

G4.81 against it (10 matches LH APSL v Ukies): 40 / 47 shots, 14.7 goals,
548 / 674 passes at 64 / 69%, 679 spells of 6.8 s, 53 / 59 own-third
losses (33-41% shot at inside 10 s); 98% of shots inside 20 s of the spell,
54-56% from a spell begun inside 35 m, 62-73% against 0-2 men goal-side,
none from 25 m+.

What it says: the gap is POSSESSION, not the shot. Pro teams keep the ball
47 s at a time and score from build-up; ours turn it over every 7 s
(5.6× the spells) and score from the turnover. Fix the ball-keeping —
passing, receiving, the man on the ball under pressure — and the shots'
anatomy should follow; the defending block's share is what's left after.

### 8.80 G4.82 — ball-keeping: how possessions end, interceptions (migs 785, 787)

James 10/28: "commit and deploy and conintyue" — §8.79's gap is
possession. New reference rows and harness lines:

- **How a spell ends** (mig 785; pro = the losing side's last on-ball
  event): pro 55% a lost pass, 1% clearance, 13% shot, 11% bad touch, 15%
  beaten on the ball. The game's SHARES were already pro-like (56-62% pass,
  11-18% clearance, 11% shot, ~0% bad touch, 14-16% on the ball) — the gap
  is the RATE: everything 5.6× as often.
- **Interceptions** (mig 787): pro 11.7 a team a match, 7.2 kept (62%);
  bad touches 18.7 (miscontrols + interceptions that came off the man).
  The game: passes cut out 124-132 a team a match, every one clean.
  Each interception's anatomy (how far the man moved since the kick, the
  flight time, the pass's kind, what he was doing) and — the decisive line
  — what the flight read (G4.49) said ONE TICK after the kick: half the
  cut-out passes were predictably theirs when struck. By kind: ordinary
  passes 19%, recycles 18%, pass-ladder balls 30%, lapse long balls 31%.

Fixes:

- **The reaction touch** (World, `LevelParams::intercept_control_pct`):
  an outfielder meeting THEIR kick while it still travels (3 m/s+) keeps
  it that share of the time; otherwise it comes off him loose (the bobble
  path, ±60°). Pro 62% MEASURED; u10 30, u14 40, amateur 48, semipro 55,
  world 68 are FH estimates down the ladder. Hashed when set.
- **The led pass is the one he reads** (Brain, ordersFor): G4.81's lead
  into a moving man's path was applied AFTER passSafe — the ball struck
  wasn't the ball checked. The led target is re-read; unsafe, he plays the
  ball he checked. Predictably-theirs ordinary passes 19 → 12%, recycles
  18 → 6%, ladder 30 → 15%.

10 matches LH APSL v Ukies, G4.81 → G4.82: shots 40 / 47 → 34 / 36 a team,
goals 14.7 → 11.7, spells 679 → 637, own-third losses 53 / 59 → 44 / 54,
clean interceptions ~128 → 79 / 83 a team, completion 64 / 69 → 68 / 72%.
With mastery 50 (§8.78, still off): shots 24 / 27, goals 7.6, spells 431,
own-third losses 36 / 36, interceptions 59 / 64 — the 12% of ordinary
passes still predictably lost are mostly the safe-pass read's per-second
lapse (40% of seconds at quality 60: a blind pass). Still far: shots
from a 20 s+ spell 2-5% (pro 72%).

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
