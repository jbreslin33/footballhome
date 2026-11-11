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

### 8.81 G4.83 — every player has a character sheet (migs 793-794)

James 10/28: "use dungeons and dragons type rolls to assign experience to
current players and playing history and ability scores" — "why not 1d100
lol? then mod it based on experienmce level adn level they are at now" —
"apply to all and diff between starters, bench and deep bench should be
significant at this level" — "we beasically have a generate player function
right but with paramenters?" — "do we have a 'player class' in c++ to handle
all this?" — "yes build it that way". It replaces §8.78's level-gap
mastery (built, never switched on): mastery is now HIS, from his years.

- **`core::PlayerSheet`** (the player class): age (real or rolled), start
  age, years out, lineup tier, his history stage by stage, every d100, the
  14 attributes, `conceptAbility(taught_rank)`. **`core::PlayerGenerator::
  generate(facts, team mean)` / `generateTeam`** rolls it. Facts = what the
  club DB knows (`persistence::loadSheetFacts`): team quality (records), a
  real age (persons.birth_date), his tier and positions (the club team's
  match_lineups), hand edits. REAL DATA WINS — the dice fill the rest.
  Deterministic: his seed (person id, else team/shirt) + a channel per
  roll → detNoise. FH original; D&D 5e character creation re-expressed on
  a percentile [D&D].
- **Attribute** = (centre − spread) + 2·spread·d100/100 (his rank at his
  level; centre = team quality for what's learned, 60 for the body) + tier
  (starter +10 / bench 0 / deep −10, every attribute) + experience on the
  learned ones (0.3 a weighted year above his team's mean, ±6) + position
  profile (game_sheet_position_profile, his real lineup spots) − 1.5 a year
  past 30 on pace and acceleration. A body roll leans on another's
  (acceleration 0.6 on pace, …). An outfielder's goalkeeping is 25. A
  hand-edited rating is never touched.
- **Tier** (mig 794): starts 35%+ of the club team's lineup matches =
  starter, in the squad 25%+ = bench, else deep bench (Lighthouse APSL:
  11 / 21 / 15). No lineups (the Ukies): the boot XI, the next seven, the
  rest. Quality (the concept dial) = team quality + tier.
- **History** (game_sheet_tables, d100 each): start age 3 + 1d6; youth
  (rec / travel / premier / pro academy) to 14; high school to 18; college
  (none / club / D3 / D2 / D1) to 22; adult (amateur / semi-pro / pro) to
  now; years out (injury / work). Each stage's weight makes his weighted
  experience years; a man with no birth date rolls his age on the age
  table. FH estimates of a US amateur path, for James to set.
- **Concepts** (GameServer::buildAbility): every concept he knows plays at
  100 − (100 − quality) × ½^(years on it / 5), years on it = his playing
  years since the age it's taught (u10 8, u14 12, amateur 18, semipro 20).
  A 25-year-old who started at 6, quality 60: u10 basics 96, amateur ideas
  85, the semipro one 80.
- **Tool** `fh-game-roll [--write] <team> ...` (prints the sheets; writes
  in one transaction). Tables game_demo_player_history / _rolls keep why
  he has each number. draw_bodies.py now refuses (superseded);
  load_squads.py says to re-roll after it.

Rolled 10/28: Lighthouse APSL 47 (real ages, mean 25), Ukies 30 (rolled
ages, mean 27); mean passing by tier 74 / 60 / 47 and 80 / 67 / 62. 10
matches: shots 34 / 36 → 30 / 30 a team, goals 11.7 → 10.0, spells 637 →
522, own-third losses 44 / 54 → 43 / 43. Passes cut out and kept 76 / 84
(pro 7.2) is still the biggest gap.

### 8.82 G4.84 — the receiver arrives on time; a firm pass

James 10/28: "continue". 53% of the passes cut out were OURS by the flight
read one tick after the kick (harness: `GAME_TRACE_FLIP=n`, every 0.2 s of
the flight — our predicted man and their first man, distance, speed, wish,
target). The traces: the receiver braked to "arrive" (G4.80) at the
earliest point he could reach — reachable only flat out — so he was late,
the next read picked a nearer point, he braked again (5.2 → 1.4 m/s) and
the defender stepped in front.

- **On time** (Brain::brakeToArrive): a race to a moving ball (meet the
  pass, intercept, jump the pass, chase) runs at least distance ÷ the read's
  time to the meeting point (+10%). Not braking at all ran men past the
  spot (worse: spells 644); this one is within noise of G4.83 but the
  physics is right.
- **A firm pass** (`kPassArriveSpeed` 6 → 9 m/s): interceptions kept 72 /
  84 → 48 / 54 a team a match, shots 29 → 20, goals 8.7 → 6.4, spells 515 →
  365, own-third losses 42 → 27. At 12 bad touches rose and it all went
  back up.
- **Tried and dropped:** charging the read for turning (half the time to
  kill his sideways speed — worse, spells 573: it hits the defenders' reads
  and the passers' choices too); a passer's time margin on passSafe (0.3 s
  worse, 0.5 s no better — refused passes became dribbles and long balls).

Still the gap: interceptions 48-54 (pro 7.2), shots 20 (12.9), spells 365
(121), shots 20 s+ into a spell 4% (72%).

### 8.83 G4.85 — movement in the taxonomy; reaction is his own, charged once (mig 812)

James 10/29: "lets continue" — then "our taxonomy should cover player
movement" / "lets do it. we can always adjust later".

- **The bug** (GAME_TRACE_FLIP): the flight read charged every man his
  whole reaction AGAIN on every read of the flight. A receiver 3 m from a
  ball rolling at him, already running onto it, read as "can't get there",
  fell back to running at where the ball was, and it rolled past him 0.8 m
  off. Now the reaction counts once, from the tick the flight began
  (`World::flightTick()`: a kick, a tackle's poke, a body block, a bobble).
- **Met hot, it bobbled:** fixed alone, receivers met passes early at 12-15+
  m/s, over their control speed (semipro 13, ×0.75-1.25 by first touch):
  53 bad touches a match at 15 m/s+ on passes meant for him (was 5). A man
  knows his touch — the read now offers OUR men only points where our ball
  has come down to his control speed (`move-controllable-pace`); 53 → 10.
- **Reaction is the player's** (`reaction`, 'teaching' since mig 653, now
  wired): `core::Body::reaction()` from the Reaction skill, 0.30 / 0.20 /
  0.15 s at 0 / 50 / 100 (`skill.reaction.reaction_s_at*`; FH estimates, 50
  = the old flat `concept.meet-the-pass.reaction_s`, retired). The flight
  read and passSafe (was a hard 0.2 s) both use HIS. A body attribute
  (rolled on the body base, never learned); attribute 15 on wire 0x37
  (append-only), hashed in the body (goldens re-locked). Rolled with
  `fh-game-roll --write`: means 60 / 59.
- **The taxonomy covers movement** (mig 812): technique family `movement`
  — HOW the body moves; movement-off-the-ball stays WHERE he runs. Groups:
  ready and react, start and stop, change direction, gaits, adjust to the
  ball, jump and land; 20 techniques, 13 wired to the engine (Body τ,
  braking, turning, yaw, gaits, brakeToArrive, the flight read), linked to
  meet-the-pass, intercept, jump-the-pass, drop-step, side-on-jockey,
  jockey-angle, recover. Sources: [Bloomfield 2007] for the movement types
  and directions, [Sheppard-Young 2006] for agility = change of velocity or
  direction in response to a stimulus.
- **Harness, StatsBomb's Interception:** an OUTFIELDER cutting out a pass.
  Blocked or saved shots (23% of what we counted) and keeper claims (about
  a quarter) were in it: the G4.84 baseline is 32 / 42 a team, not 48 /
  54. New line: bad touches by whose ball (meant for him / another of ours
  / theirs, a reaction touch) × speed.
- **The baseline moved under us:** today's club lineup (a squad of 11
  matches) re-tiered Lighthouse on the re-roll (two bench → starter, a few
  ±1 ratings) and the OLD code on that data: spells 365 → 534, goals 6.4 →
  10.2. Numbers below are old vs new code on today's data.

20 matches LH APSL v Ukies, old → new code (pro): completion 71 / 72 → 77
/ 77% (79), spells 573 → 497 (121), interceptions 46 / 68 → 37 / 61 (7.2),
own-third losses 42 / 51 → 32 / 34 (2.1), bad touches 67 / 75 → 54 / 71
(18.7) — closer on all of them — but shots 35 / 36 → 43 / 40 (12.9) and
goals 10.8 → 14.4 (2.5): our ball now reaches its man, so more attacks get
to the end. Still the gap, biggest first: reaction touches by defenders on
slow balls (< 9 m/s: 39 a match come off him), shots 20 s+ into a spell 3-5%
(72%).

### 8.84 G4.86 — one race: the passer reads the ball the way it will fly

James 10/29: "yes" (ship G4.85, take the next mole) — and "its ok to have
odd scores if the particular behaviour is correct … a bit of a game of
whack a mole".

- **Defenders touch their ball 10× too often:** 223 touches a match on the
  other side's moving ball (kept 109, off him 114 — the reaction roll is
  ~50/50 at every speed and job; pro interceptions ≈ 23 a match). The roll
  isn't the mole; the passes are. Harness lines: every touch on their
  moving ball, kept or off, by his job, speed and the ball's speed relative
  to him; balls in behind theirs at the kick — strike off his aim, where
  their man meets it; balls in behind by whether the passer read them
  (`Orders::read`).
- Balls in behind the read gave to THEM at the kick: the strike was true
  (76% < 2° off his aim) and their man met it AT the spot (72%) — the choice
  was wrong, not the kick. Read ones 23% theirs, unread 36%.
- **Ground means ground:** the safety read skipped a ball past their line as
  "lofted", but whether he lofts it was a separate over-the-top roll later;
  it failed and he drove an unread ground ball through the block. Now one
  roll (`over_top`) decides both.
- **One race, two users (Brain::race):** passSafe was its own walk of the
  pass — no perception delay, stopped as the ball reached the spot (a ball
  into space got there before the runner and rolled on), knew nothing of
  the receiver's touch (G4.85). It now runs the flight read's race on the
  ball he's about to strike (`RaceBall`: from his feet, his weighted speed,
  `since` 0, his own lockout, live offside flags off, `opp_margin` = his
  caution − the control radius, stop at the first man). Safe = ours first,
  ties to them. flightRead is the same race on the ball in the air, cached.
- **Not what he saw — the loft (G4.86b):** read balls in behind were still
  24% theirs. Scanning was the guess; measured, their man was IN the
  passer's view 89% of the time. Split by the kick: read ground balls 5%
  theirs, read LOFTS 30% — a loft was never raced ("it flies over the
  block"). Now `Brain::loftSafe` races the loft he'll hit (loftTo's drop,
  `core::loftLaunchSpeed` — one formula for the World that strikes it and
  the Brain that reads it): out of reach until it comes down, then the same
  race. Read balls in behind 24% → 8% theirs (lofts 30 → 6%); balls in
  behind theirs at the kick 29 → 18 a team a match. passSafe / loftSafe →
  `raceSafe`. Harness: read balls in behind by ground / lofted, their man
  in the passer's view, his look age.

20 matches LH v Ukies, G4.85 → G4.86 → G4.86b (pro): completion 77 → 76 →
76% (79), spells 497 → 532 → 528 (121), interceptions 37 / 61 → 49 / 66 → 47
/ 67 (7.2), shots 43 / 40 → 44 / 42 → 45 / 42 (12.9), goals 14.4 → 12.8 →
11.8 (2.5). Next moles: unread passes (35% of balls in behind theirs —
the safe-pass roll, a lapse), "hit it long" lapses 46% theirs (21 a match),
and a loft lands at its launch speed (no drag: a 30 m ball arrives at 17
m/s, over every control speed) — ball physics.

### 8.85 G4.87 — the ball feels the air (mig 821)

James 10/29: "can we open 2 agents. one for what you were already doing" —
the mole ranked first after G4.86b: a ball in the air felt only gravity, so
a 30 m loft came down at the 17 m/s it was struck, over every control speed.

- **The law** [Goff-Carré 2009]: drag F_D = ½ ρ A v² C_D against the
  velocity, as an acceleration a = −k·|v|·v, k = ρ·(π d²/4)·C_D / (2m) ≈
  0.0105 / m with their measured numbers — ρ 1.2 kg/m³, d 0.218 m, m 0.424
  kg, C_D 0.2 (no-spin launches at ~18 m/s; 0.17 at 19.4). Airborne only:
  on the ground the roll decay [v1] already is the rolling loss. Not
  modelled yet: spin / Magnus, and the drag crisis (below Re ≈ 2.2-3.0 ×
  10⁵, ~15-21 m/s, C_D roughly doubles — Asai et al. 2007).
- **One object, two users** (`core::BallFlight`, the G4.86 rule): the World
  steps it every airborne tick (tickFreeBall) and strikes the aimed loft at
  its `launchSpeed(carry)`; the Brain's race steps the same law
  (Brain::race), `loftTo` leads the mate by its `flightTime(carry)` (was 2rv
  / g) and `loftSafe` races the loft at the same launch speed. The aimed
  loft has no closed form with drag: for every carry 1-255 m the launch
  speed is found by bisection on the tick law itself, once, at construction
  (tables shared, not copied with the World). `core::loftLaunchSpeed`
  (vacuum) is gone. Numbers: `physics.ball.*` (mig 821); k in the hash.
- **Lofts, with drag** (test_ball): 10 m struck 10.4 m/s (vacuum 9.9), lands
  9.3 after 1.03 s; 30 m struck 19.5 (17.2), lands 13.9 after 1.83 s; 50 m
  struck 27.4 (22.1), lands 15.6 after 2.47 s.

20 matches LH v Ukies, G4.86b → G4.87 (pro): lofts now come down where
they're aimed — over the high line to the picked man 45 / 40 → 64 / 55%,
dead (out or offside) 37 / 50 → 18 / 36%; "hit it long" theirs at the kick
46 → 37%; completion 76 / 76 → 77 / 78% (79). But interceptions 47 / 67 →
54 / 72 (7.2), shots 45 / 42 → 53 / 44 (12.9), goals 11.8 → 14.2 (2.5),
spells 528 → 548 (121): more lofts stay in play and get contested. Next
mole: a loft still lands at 9-16 m/s (30 m: 13.9) and the receiver must
take it under his ground control speed (semipro 13) — a dropping ball is
taken with a cushion (thigh / chest / instep, the receiving-bouncing-and-
aerial techniques), so aerial control wants its own number, not the ground
one; then the drag crisis (C_D doubles below ~15-21 m/s).

### 8.86 G4.88 — the AI referee: his own taxonomy; the assistant's offside call stands (mig 822)

James 10/29: "do we have offsides lol" — "we need an ai ref. that has its
own taxonomy of what he sees adn understands". Until now the World WAS the
referee: exact positions at the instant of every kick, never wrong.

- **The referee's taxonomy (mig 822, normalized, beside the players'):**
  `game_ref_laws` (IFAB Laws 5, 6, 9, 11, 12, 13, 14 — wired / partial /
  teaching) → `game_ref_judgements` (cue → call, made_by referee /
  assistant / world) → `game_ref_perceptions` (what he must SEE;
  `game_ref_judgement_perceptions`) and `game_ref_positionings` (where he
  stands); a `_sources` table each (IFAB Laws, IFAB Practical Guidelines,
  [Oudejans 2000], [Helsen 2006], all verified). The officials:
  `game_official_crews` (by level) → `game_officials` (referee,
  assistant_1, assistant_2) → `game_official_ratings` over
  `game_ref_attributes` (pace, acceleration, positioning, offside_judgement
  wired; foul_recognition, game_management teaching). A match is run by the
  crew of the home team's level (semi-pro ~50, pro ~75 — [FH]).
- **Wired:** offside-position (the assistant), offside-involved-playing
  (the flagged man plays the ball → IFK, the G4.8 whistle), ball-out-of-play
  (made_by `world`: still exact). **Teaching only** (fouls and cards stay a
  v1 non-goal): interfering with an opponent, careless/reckless/excessive
  force, handball, advantage, penalty offences, cautions / sending-offs.
- **The officials are bodies (core::Officials):** three `core::Body`s from
  their own pace/acceleration (SkillSet::body, the players' law), moved
  after the players each tick, hashed, NOT in the player slots (the wire,
  the clients and the brains still see 22). Positioning rows:
  ar-second-last-defender — assistant 1 on the +y touchline judging the +x
  half, assistant 2 on −y and −x; level with the second-last defender of
  the team defending his half, or the ball if nearer the goal line, at
  halfway when the line is in the other half; facing the field (so a
  sideways run is his side-on gait); plus his slack beyond the line
  (positioning: 2.5 / 1.2 / 0.3 m at 0 / 50 / 100 [FH] — ARs mostly stand
  beyond it, [Oudejans 2000] 179 of 200). referee-wide-diagonal — on the
  diagonal away from each half's assistant, pulled half-way to the ball's
  y, 8 m behind the ball [FH].
- **The call (Officials::judgeOffsidePosition):** at the kick, the
  assistant covering the half the attack goes into judges each attacker
  from where he stands: kick-moment-and-line — every moving man seen
  flash_lag_s (0.08 s [FH magnitude; direction Helsen 2006]) along his run;
  line-from-his-angle — "level" is his line of sight through the
  second-last defender, true when he stands level with it, from beyond it a
  far-side attacker projects ahead (wrong flag), a near-side one behind
  (missed) [Oudejans 2000]; ± noise by his offside_judgement (1.0 / 0.5 /
  0.2 m [FH]). The ball and halfway parts of the law he reads exactly. HIS
  call (`World::calledOffsideMask`) is what the whistle follows;
  `offsideMask()` stays the truth — what the players know and the brains
  read. Unit test: test_officials (level AR true; 4 m beyond flags a level
  far-side man).
- **Harness:** offsides a team a match; whistles for an onside man and
  offside touches nobody flagged (World counters); men flagged wrongly /
  missed at each kick; where the assistant stood vs level with the line.
  `benchmarks_statsbomb.py` now counts offsides (Offside events + passes
  with outcome Pass Offside) and the metric row is in; the PL value lands
  on the next rerun of the script (~1.1 GB of events, not run here).

20 matches LH APSL v Ukies, G4.86b (World as referee) → G4.88 (the
semi-pro crew): offsides 13.2 / 16.7 → 23.9 / 24.9 a team a match;
whistles for an onside man 15.9 a match = 33% of the calls (Helsen 2006:
~26% wrong at the 2002 World Cup — a semi-pro crew sits worse); offside
touches nobody flagged 2.1 a match. At the kicks with a flag or a man
offside the assistant stood 3+ m beyond the line 34% of the time, 1-3 m
beyond 19%, within 1 m 22%, short of it 25% (mean +2.1 m: his slack plus
a 45-pace body chasing the line). Totals moved with the extra stoppages:
spells 528 → 614, interceptions 47 / 67 → 56 / 76, goals 11.8 → 13.4.
Next: the pro offside number (rerun the script), how far beyond the line
real assistants stand (Oudejans's 179/200 is a share, not a distance), and
the officials on the HUD (an append-only frame).

### 8.87 G4.89 — Law 11 on every pass; the pro offside number (mig 825)

James 10/29: "do we have offsides lol" → offside next, "yes".

- **The pro number** (mig 825): Premier League 2015/16, StatsBomb Open
  Data, 380 matches — **1.96 offsides a team a match** (Offside events +
  passes with outcome Pass Offside; `benchmarks_statsbomb.py 2 27`). The
  game: 28 / 24.
- **Each whistle, measured** (new harness line: the kick it came off, was he
  the man it was played to, his job at the kick, how far past their
  second-last man): the man it was played to 90%; 56% of them 3 m+ past the
  line at the kick, off recycles (16%), the long-ball lapse (20%), plain
  passes, the keeper's short ball. Only the pass ladder asked the law
  (G4.36).
- **Every pass asks it now:** one check (`onside`, PassLadder::
  offsidePosition on `PassLadder::lines` — beyond their second-last man,
  keeper counted, the ball and halfway) on the world as the passer SEES it,
  for the plain pass, the ladder, recycles and the concept pickers
  (ShortSimple / DirectBall through `ConceptContext::eligible`: lapses
  included — a lapse is the wrong KIND of ball, not a blind eye to the
  law). A back pass can't be offside, so play-back doesn't ask.
- 10 matches LH v Ukies: whistles 52.6 → 34.9 a match; for a man really
  offside ~37 → ~9; completion 77 / 78 → 79 / 81% (pro 79); goals 11.0 →
  10.0.
- **Next mole — the assistant:** 75% of the whistles left are for ONSIDE
  men (26 a match): balls now go to runners timed on the line, and our
  assistant stands on average 2 m beyond it (33% of kicks 3 m+; IFAB: level
  with the second-last defender), judging tight calls from a bad angle
  [Oudejans 2000].

### 8.88 G4.90 — the assistant holds the line: level, shadowing it (mig 826)

James 10/29: "continue" (the assistant).

- **Measured, real assistants** [Gonçalves 2021] sit ~1 m off the
  second-last defender; aligned (< 0.2 m) 14% of the time, trailing ~53%,
  leading ~33%; 20-26% of offside decisions wrong (Mallo et al. 2012,
  Oudejans et al. 2005, as cited there — not read directly: verified =
  false).
- **Aim level** (IFAB), not beyond: G4.88's positioning "slack" put him
  1.2 m beyond the line at 50 by design (Oudejans 2000's "mostly beyond" is
  a share, not a distance). Positioning now sets the age of his read of the
  line (`official.assistant.lag_s_at*` 0.6 / 0.3 / 0.1 s) — he trails a
  moving line.
- **He shadows it** (`ar-side-steps`, now wired): his wanted velocity is
  the line's velocity plus the gap closed over `track_s` (0.5 s), capped by
  his gait. Walking to a spot with an ease-in he was always arriving: 29%
  of kicks 3 m+ short, 25% 3 m+ beyond, 17% within 1 m.
- **The measure** (`OffsideCall::off_line_m`) is now vs the line he is to
  hold — the second-last defender, the ball if nearer the goal line, or
  halfway — not the defender alone (level with the ball read as "beyond").
- 5 matches: short of the line 49% (3 m+ 25%), within 1 m 29%, beyond 20%,
  mean −1.2 m — trailing like Mallo's assistants, wider. Per offside
  situation he's wrong ~23% (86 wrong flags + 62 missed of ~633), inside
  the published 20-26%; whistles 35 → 31 a match, still 75% for onside men.
- **Next mole — the volume:** ~630 kicks a match have a man in or near an
  offside position (the pro calls 2 a team). Our attackers live on the
  line; a real one comes back onside when the ball isn't on (the
  taxonomy's run-curved-onside, run-off-shoulder).

### 8.89 G4.91 — stay onside: on the last defender's shoulder (concept 184, mig 830)

James 10/29: "yes" (attackers come back onside).

- **Measured** (harness: men standing in an offside position at a kick, by
  job, depth and how long; `GAME_TRACE_OFFSIDE_MEN=n` prints the 8 m+ ones):
  1,075-1,120 a match, on a third of kicks; 41-43% 8 m+ past the line,
  74% 3 m+. Holding shape 35%, the run in behind 32%, give and go 12%,
  blind-side run 10%. No concept said "stay onside" — runs (5) and
  blind-side-run (30) only of their own run.
- **Concept 184 `stay-onside`** (taught u14, in possession, ip-shape;
  IFAB Law 11.1; techniques run-off-shoulder, run-curved-onside; every root
  model asks 90, Curriculum 100): `Brain::stayOnside`, after the decision
  and unmark — any target past their offside line (second-last man, keeper
  counted; the ball; halfway) comes back onto it, `margin_m` 0.5 short; a
  man past it with no target walks back (`Why::StayOnside`). Rolled per
  second at his rating: a lapse leaves him there.
- **Our ball in flight too:** with only the ball-at-feet case it moved
  nothing — the traces had every deep offside man running ON at ~8 m/s
  while our pass travelled (G4.49 keep running), 11-24 m past. The next
  pass is the one he's judged on: during our flight he holds the line too,
  except the man it's for and the man going for it (meet / chase / jump /
  wait / the ball in the air).
- 10 matches: men offside at a kick 1,120 → 488 a match (8 m+ 43 → 17%);
  whistles 32 → 25 a match; goals 11.8 → 9.6; interceptions 60 / 74 → 55 /
  65 a team. Pro offsides 1.96 a team; we're at 13 / 12.
- **Next mole:** 78% of the whistles left (20 a match) are the assistant
  flagging ONSIDE receivers — runners now ride the line, so the tight call
  is every ball in behind, and ~23% of those go wrong (the published rate).
  The volume is the question: how many balls a match are played to a man
  within a metre of the line, against the pro.

### 8.90 G4.93 — the officials on the HUD (wire 1.16)

James 10/29: "1 then move to all" (the possession mole first, then the rest
— this is "draw the officials on the HUD"). G4.88 put a referee and two
assistants on the pitch as bodies (core::Officials) but the client never
saw them.

- **Wire (1.16, append-only):** SNAPSHOT gains an officials tail after the
  1.8 facing — `u8 count`, per official `i64 x | i64 y | i8 face_x | i8
  face_y | u8 flags`; flags bit0 = flag up (PROTOCOL §6). Not player
  slots: nothing else on the wire indexes them. Old clients ignore the
  tail; a new client against an old server draws no officials.
- **Flag up:** GameServer raises the flag of the assistant whose call
  (`World::lastOffsideCall().assistant`) was whistled, for 45 ticks
  (1.5 s) after the Offside event — presentation only, not World state
  (the canonical hash and every golden are unchanged).
- **Client:** `wire.js` decodes the tail; `PlayerFigure` takes
  `{ official, flag }` — black kit with yellow trim, no number; an
  assistant carries a yellow-and-red flag in his right hand and raises it
  straight up (an eased overlay like the others) while the bit is set.
  `GameRenderer` adds the three figures beside the 22 (not in `figures`,
  not raycast targets), interpolated like the players, with velocity from
  the snapshot-to-snapshot move (the wire carries none for officials).
- Tests: codec `snapshot_officials_tail_round_trips` (a 1.15 frame still
  decodes with none); server `server_snapshot_carries_the_officials`. Not
  yet checked in a browser.

### 8.91 G4.92 — the control touch: he plays it once he has it (mig 841)

James 10/29: "1 then move to all" — the possession churn first.

- **Measured:** 840 passes a team a match (pro 378) at completion 80% (pro
  79%), 505 spells (121): the ball changes hands four times as often at the
  same accuracy. Time on the ball before a pass (new benchmark, mig 841;
  `benchmarks_statsbomb.py`: Ball Receipt → the same player's next
  open-play Pass, same possession): **pro 1.47 s, 46% inside 1 s** /
  game 0.32 s, 89% inside 1 s. The World stopped a taken ball dead and the
  Brain kicked it the next tick: everything one-touch at 30 Hz.
- **The control touch** (World): after he takes it — a capture, a won
  tackle, a steal — no kick until `controlUntilTick()`: his level's
  `control_settle_ms` + `control_per_mps_ms` (25) × the m/s it came in at,
  the settle scaled by his first_touch (×1.5 at 0 … ×0.5 at 100,
  `skill.first_touch.settle_at*_pct`). Bands [FH]: u10 700, u14 600,
  amateur 500, semipro 400, pro 350, world 300 ms; 0 at the perfect level
  (goldens unmoved). A placed restart ball needs none. Hashed when set.
- 10 matches: time on the ball 0.32 → 0.73 s (<1 s 89 → 83%); passes 774 /
  914 → 693 / 819 a team; interceptions 55 / 65 → 41 / 58; lost ON the
  ball 14 / 8 → 24 / 20% of spell ends (pro 15) — men caught in their
  touch; spells 505 → 513.
- **Next mole:** he releases the instant he CAN — 83% still inside a
  second, almost nothing past 2 s (pro 26%). A pro with time takes a touch
  forward, waits for the run, turns: the carrier's choice to keep it.

### 8.92 G4.94 — a dropping ball on the thigh or chest (mig 843)

James 10/29: "1 then move to all" — after the churn, the dropping ball.

- An outfielder could touch a ball only below 0.5 m, at his ground control
  speed: a loft landing at 9-16 m/s (G4.87) was his only once it reached his
  knees, and mostly came off him. Now (`core::kOutfieldReachZ`, 1.5 m) he
  takes it up to the chest; above his feet it is a cushion
  (`core::controlSpeedAt`: 1.2 × his control speed) — the taxonomy's
  recv-thigh / recv-chest, now wired. [FH] anatomy and scale. One rule for
  the World's capture and the Brain's race (the read agrees). Headers are
  still not played.
- 10 matches: bad touches on the pass meant for him at 12-15 m/s 5.5 → 1.3
  a match; the long ball reaches a mate 59-64 → 63-69% (likes it long 64 →
  72%); but defenders take it at the chest too — interceptions 41 / 58 → 45
  / 67, spells 513 → 564, shots 55 / 51 → 64 / 60 a team.
- **Next mole: shots** — 60+ a team a match against a pro 12.9.

### 8.93 G4.95 — first time: the clearance, and one touch when pressed (mig 848)

James 10/29: "yes" — shots next.

- **Where the shots come from:** 60+ a team a match (pro 12.9); 66-93% with
  0-2 defenders goal-side of the shooter (pro 28%); 24-33% from spells that
  began inside 35 m of goal (pro 5%) — own-third losses 34 a team a match
  (pro 2.1), 44% of them dispossessions. New harness line (own-third
  dispossessions): 70-74% within 0.5 s of getting it, 74% still inside his
  control touch (G4.92), the taker counter-pressing 69%, the carrier trying
  to clear 29% / dribble 33%. The control touch had no way out.
- **G4.95a, the clearance first time** (def-clear-foot): `Orders::
  first_time` (Why::Clear) → `World::setAction` lets the kick go inside his
  touch, at 1.5× the strike error [FH]. Clearances 28 → 48 a match,
  dispossessions 17 → 14.5.
- **Tried and dropped:** making passSafe demand the receiver have TIME (no
  opponent within tackle reach of the spot before his touch settles) —
  fewer passes looked safe, carriers fell back to dribbles and hoofs: own-
  third losses 38 → 41, shots 57 → 64. It was standing in for the missing
  behaviour below.
- **G4.95b, one touch when pressed** (pass-one-touch, recv-first-time):
  still in his control touch with a man within 2.5 m, a ground pass to a
  mate goes first time (the lay-off, the wall pass). Dispossessions 14.5 →
  5.4 a match, own-third losses 38 / 31 → 28 / 26, spells 548 → 441, shots
  57 / 59 → 46 / 47, goals 10.9 → 7.9.
- **Next mole:** still 66-92% of shots with 0-2 defenders goal-side (pro
  28%) — the defending block isn't goal-side when the shot comes.

### 8.94 G4.96 — track the runner (concept 121 wired, mig 849); the pro's through balls

James 10/29: "continue" — the block isn't goal-side at the shot.

- **Where the goals come from:** balls in behind (ladder rungs 1-2) — 1.9
  and 1.0 goals a match, breakaways 1.6 / 2.7. **Pro (new benchmark, mig
  849; StatsBomb PL 2015/16, Pass technique Through Ball): 2.04 a team a
  match, 33.7% completed.** The game: ~100 a team, ~80% to the runner.
  Harness line (balls in behind, at the kick): the runner's nearest
  defender 8 m+ off a third of the time, the runner 4 m/s+ faster toward
  goal a quarter, the defender holding shape 22% — but already turned 60%.
- **Track the runner** (121, 'queued' in the taxonomy since the start —
  wired, not duplicated): `Brain::trackRunner`, after the decision — their
  carrier FREE (line-step's covered read says no), an onside runner within
  near_m (8) of the nearest of us, at our line (within near_m of breaking
  it), going for our goal at 4 m/s+: go with him, 1.5 m goal-side of where
  he'll be 0.4 s on, facing where he goes. def-track-runner wired.
- **Tried:** the first cut tracked ANY forward runner (midfield runs too) —
  worse: balls in behind 200 → 236, shots 46 → 55, spells 441 → 536 (with
  demand 0 the run returned exactly to the baseline). Limited to runners
  breaking our line: shots 46 / 47 → 49 / 50, balls in behind ~205 — about
  neutral. The defender is already turned and still loses the race.
- **Next mole: the passer.** ~100 balls in behind a team a match against
  the pro's 2: the pass ladder plays rung 1-2 whenever the read says it's
  safe.

### 8.95 G4.97 — the 9 leaves their centre-backs alone unless one drives (mig 858)

James 10/29: "lh 9 is supposed to sit and cover shadow mid fielders of
ukies. he is not activated to go after 4 and 5 of ukies unless they drive
forward or the ball is played to the ukie fb then he closes the door on the
closest cb to ball."

- **Measured** (new harness line: the home 9 while their 4/5 has it): not
  driving — packing the middle 41%, but counter-pressing the centre-back
  28% (packAndTrap let "we just lost it and he's near it" come first, and
  handed over to the ordinary press inside handover_m); driving at us — no
  trigger at all (pack 24%, counter-press 18%, recover 17%).
- **packAndTrap, the 9:** their centre-back on the ball and NOT driving is
  no trigger — no counter-press, no handover; he stays in his box between
  their 4, 5, 6, 8 (G4.72). DRIVING (toward our goal at `cb_drive_mps` 2+):
  he presses him `cb_press_gap_m` (2) off him on the line to his nearest
  central man — the cover shadow (Why::CoverShadow). The ball to their
  full-back: he locks the door on the nearest centre-back (unchanged).
- 10 matches: not driving — pack 41 → 59%, counter-press 28 → 10% (the
  rest: his pack roll lapsing for that possession); driving — cover shadow
  0 → 55%.

### 8.96 G4.98 — the passer and the ball behind their line (mig 867)

James 10/29: "yes" — take the passer (§8.94's next mole).

- **A fair pro number first.** The 2.04 through balls (§8.94) are a narrow
  event tag — a ball split between defenders for a runner. The harness's
  question is plainer: a pass 3 m+ forward aimed past their last outfield
  man at the kick. StatsBomb's 360 freeze frames put the same question to
  the pro (`game/scripts/benchmarks_statsbomb_360.py`: the pass ends beyond
  the deepest outfield opponent in its frame, 4+ of them in view, its end in
  the visible area — broadcast frames can hide a deeper man, so not exact):
  **Euro 2020 26.7 / World Cup 2022 25.7 a team a match, 62% completed**;
  34-36% lofted, 28-31% from the passer's own half, 15-17% under pressure,
  past the line <2 / 2-5 / 5-10 / 10+ m 31-33 / 34 / 24-25 / 9%. The game:
  **144 / 199**, 70-73% completed, 71% lofted, 51% from his own half, 54%
  dropped 5-10 m past the line. By kind: the ladder's in behind ~80 a team,
  over the high line 36 / 91, the hit-it-long lapse 13 / 17. New harness
  lines: the same measure (any pass), by kind; the passer of a ladder ball
  in behind (pressed, held, where, how deep).
- **The ladder led any man moving forward** (G4.36's lead point): a man
  drifting at 1-2 m/s near their line had his lead past it — rung 1.
  `PassLadder::running`: only a man running at their goal at `run_mps` (4,
  release-timing's bar for a run worth waiting for) is led; slower, he gets
  it to his feet. Ladder in behind 109 → 87 a team a match.
- **"A high line" was any line 30 m+ off its goal** (G4.75). Where a pro
  line sits (new benchmark, the deepest outfield man in view, passer in his
  own half): median 49.0 / 50.0 m, quartiles 40 and 61 m — 30 m is deeper
  than 9 in 10 of them, and both sides here sit 33-36 m, so every line was
  high. `beat-the-high-line.high_m` 30 → 49, the pro median. Over the high
  line 37 / 91 → 21 / 57 a match (the Ukies' rest is mostly the false 9's
  space read, G4.78, which never asked the line's height).
- 10 matches, both: past their last outfielder 144 / 199 → 114 / 143 a team
  a match (78 / 77% to a mate); spells 505 → 446; passes 715 / 920 → 678 /
  830; goals 11.3 → 10.4; shots 53 / 55 → 49 / 65 (the Ukies up); Lighthouse
  W5 D1 L4 → W8 D0 L2. Goldens unmoved.
- **Next mole:** still 4-5x the pro. The rest is the ladder's ball to a real
  runner (~62 a team, 80%+ arriving — the read is right, the space is
  there): the back line doesn't drop on a free passer the way a pro line
  denies the space (pro: 62% arrive), and a laddered passer plays rung 1
  every time it's on. Then the false 9's space read (43 a match for the
  Ukies).

### 8.97 G4.99 — the 9 chills in the box; WATCH one player (mig 869)

James 10/30: "on from the keeper lh 9 is still going after cb of ukies. he is
supposed to chill and help cover shadow ukiies 6,8,10 or even double mark them
checking in. then as soon as ball is struck he goes to mark the ball side cb to
stop back pass. i wan to start focusing on individual players and fix the
behaviour so we become more realistic. neeed to be able to focus on 1 player at
a time with cam too".

- **Measured** (new phase-harness line: their 9 by who has the ball — keeper,
  centre-back, the middle, full-back — on him, within 3 m of a CB, his jobs).
  Two doors to the centre-back: the pack roll lapsing for a whole possession
  fell to the ordinary brain, where his direct opponents ARE their 4 and 5
  (mark, chase, contain, jockey: jockeying 8-12%); and "driving" at 2 m/s was
  a man taking a touch (cover shadow 27% with a CB on the ball).
- **Quiet:** their restart, or their keeper or a centre-back with the ball or
  the ball going to him (the trap's flight read, so it holds from the strike),
  not driving. Quiet, nothing sends him at them: no counter-press, no handover.
  `cb_drive_mps` 2 → 4. **The 9's lapse stands in the box** (hold shape) —
  a lapse is the wrong spot, not a chase.
- **On it:** he shadows the central man nearest the ball, `nine_screen_gap_m`
  off him on the ball's line; a man coming toward the ball at
  `nine_check_in_mps` (2) within `nine_double_reach_m` (12) of the box gets
  him `nine_double_gap_m` (2) off, Why::DoubleCheckIn ("double the man
  checking in"). Still inside lock-the-door's reach of the ball-side
  centre-back. The door itself is unchanged: on the strike to the full-back.
- **Also fixed:** the driving-CB press had no rating check, so any team's 9
  ran it; now pack-the-middle's rating gates all of it.
- 100 keeper episodes, CB on the ball: cover shadow (the drive press) 27 → 6%,
  jockey 8% → under 4%, pack 58 → 70%, hold (lapse) under 4% → 18%; ball to the full-back:
  lock the door 71 → 72%. With the middle on it he is within 3 m of a CB 22%
  (was 11%): pack 73%, double 14% — near one, not on one (on the man with the
  ball 1%).
- 10 matches against G4.98: past their last outfielder 114 / 143 → 130 / 165,
  spells 446 → 506, goals 10.4 → 10.5, shots 49 / 65 → 53 / 66, Lighthouse
  W8 D0 L2 → W4 D3 L3 (margin +0.9 ± 1.06). Correct behaviour, ships anyway:
  an unpressed centre-back has longer to pick his pass.
- **WATCH** (client, camera mode 7): a list by team, `[` `]`, or TAP TO WATCH
  puts the camera on one man without claiming him — behind him on the far side
  from the ball, cyan ring; 3RD and 1ST ride him too. Checked in Chrome against
  the running daemon.

### v1 explicit non-goals (do not build before G4 closes)

Fouls/cards, stamina, substitutions-as-rule (subs arrive with G5 tactical
intents), weather, crowd, licensed anything, client-side prediction.
(Offside was on this list until G4.8, when the harness measured the exact
1860s goal-hanging problem the law exists to solve — amended by evidence.)
(G4.88: the match OFFICIALS are in — bodies, positioning, the assistant's
offside call. Fouls and cards are still out: in the referee's taxonomy as
teaching rows only.)

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
- [Bloomfield 2007] Bloomfield, Polman & O'Donoghue, *Physical demands of
  different positions in FA Premier League soccer*, J Sports Sci Med
  6:63-70 — the Bloomfield Movement Classification (G4.85 movement family).
- [Sheppard-Young 2006] Sheppard & Young, *Agility literature review:
  classifications, training and testing*, J Sports Sci 24(9):919-932 —
  agility responds to a stimulus (G4.85 reaction).
- [Goff-Carré 2009] Goff & Carré, *Trajectory analysis of a soccer ball*,
  Am J Phys 77(11):1020-1027 — drag law and C_D 0.2 (G4.87 BallFlight).
- [Asai 2007] Asai, Seo, Kobayashi & Sakashita, *Fundamental aerodynamics
  of the soccer ball*, Sports Engineering 10(2):101-109 — the drag crisis
  (not yet modelled).
- [IFAB] *Laws of the Game 2025/26* (Laws 5, 6, 9, 11-14) and the
  *Practical Guidelines for Match Officials* (positioning, movement and
  teamwork) — the referee's taxonomy (G4.88).
- [Oudejans 2000] Oudejans, Verheijen, Bakker, Gerrits, Steinbrückner &
  Beek, *Errors in judging 'offside' in football*, Nature 404:33 — the
  assistant's viewing angle (G4.88).
- [Gonçalves 2021] Gonçalves, Coutinho, Travassos, Brito & Figueiredo,
  *Match analysis of soccer refereeing using spatiotemporal data: a case
  study*, Sensors 21(7):2541 — assistant ~1 m off the line; cites Mallo et
  al. 2012 (alignment 14%, trail ~53% / lead ~33%) (G4.90).
- [Helsen 2006] Helsen, Gilis & Weston, *Errors in judging "offside" in
  association football: test of the optical error versus the perceptual
  flash-lag hypothesis*, J Sports Sci 24:521-528 — flash-lag, most errors
  flags (G4.88).
- Mine all of these for AI design; re-express in fixed point. Never port
  floats.

### 8.98 G5.0 — preventive marking, position by position (mig 886)

James 10/30: "intelligent direct opponent unmarking"; "2 and 3 to unmark NOT
wide of do"; "closed ball, open ball"; "ukies should look to get 2,3 wide
during unmark". The football name is preventive marking (marcature preventive),
how rest defence is done [standard coaching, FH wiring].

- **Demand by position**: `game_model_role_concepts` is read at last
  (FormationSpec::Pos::role, GameModel::roles through the parent chain, applied
  per slot in recomputeKnowledge; live HUD changes still win).
- **rest-defense (70), wired**: `gap_m` 0 globally, 3 in the model "Lighthouse
  APSL — preventive marking", so no other model moves. The men with demand (4,
  5, 6, 2, 3) stand gap_m goal-side of their direct opponent, on his line to our
  goal, once the ball is past him. Read once a possession: a per-second lapse
  walked them out and back. Our pass in flight counts as our ball.
- **inverted-fullback (55), wired**: never wider than his man, inside_m inside
  him, lapse or not, in the job and in unmark. No overlap, no spread_wide
  (role demand 0).
- **open-closed-ball (185), new**: nothing in the taxonomy said it. Open
  (nobody within pressure_m, facing forward): forward, sideways, back. Closed:
  toward the ball first. Lapse: forward anyway. The 7 and 11 unmark no further in
  than wing_band_m; an 8 or 10 pops out when nobody holds the ball-side channel.
- **wide_first** on lose-your-marker: the Ukies' full-backs look for the
  touchline first.
- **Flank bug**: y is not mirrored for the away team, so 2:7, 3:11, 7:2 and 11:3
  paired men on opposite touchlines (our 3 marked a man the pitch width away).
  Pairs now 2:11, 3:7, 7:3, 11:2. `Brain::directOpponents`' mirrored() still
  assumes a y mirror the game doesn't have; only the unnumbered fallback uses it.

Measured, 10 matches LH v Ukies, scratch DB: without the tactic W2 D3 L5, goals
6.8-7.3, shots 64/67, spells 539; with it W8 D1 L1, goals 5.9-2.7, shots 53/49,
spells 432. Full-backs wider than their man 81% (3 m+ 71%) → 34% (3 m+ 12%), the
rest mostly on their way there (give and go is not clamped). Back five goal-side
with the ball past him 79 → 88%. Next mole: read the back five (`past`) by
how many they leave up, not all five always.

### 8.99 G5.1 — settle in possession: the team comes up before the ball goes (mig 919)

James 10/31: "continue" — §8.98's next mole, the back five by how many they
leave up. Measured first, and that isn't the mole: marking already scales
with men left up (0.5 men at 1 up, 3.0 at 7+), because `past` is per man. The
number that matters is the one nobody had looked at.

- **The pro number:** `game/scripts/benchmarks_statsbomb_rest.py`, StatsBomb
  360 freeze frames of open-play passes whose visible area reaches the goal
  attacked. Mates ahead of the ball, half to 40 yd out / 40-20 yd / last 20 yd:
  **Euro 2020 5.29 / 3.63 / 1.48, World Cup 2022 5.23 / 3.72 / 1.42**. Frames
  miss men, and the filter favours a forward camera, so read it as a bound.
  Per pass; the harness is per tick with the ball held.
- **The game:** 1.84 / 0.93 / 0.32 (Ukies 1.96 / 0.65 / 0.21). New harness
  lines: rest defence by men left up, mates ahead by zone, each number's spot
  against the ball and what his orders want, mates ahead by spell age.
- **Not the shape, or not first:** `ours_slope` 0.45 → 0.65 with offset 2 → 6
  (the fit to the pro zones) moved them only 1.84 → 1.95 and put balls in
  behind up 35%. By spell age, past halfway: 1.6 (<5 s), 1.8 (5-15 s), 3.4
  (15-30 s), 3.7 (30+ s), and 91% of the time there is under 15 s. The team
  gets up given time; the ball doesn't give it any.
- **settle-in-possession (89), wired:** on the ball, not pressed, fewer than
  `ahead_min` 5 mates ahead (U.S. Soccer U17+ "minimum 5 ahead of the ball")
  and more than `until_m` 20 from their goal: no ball in behind, no over the
  line, plays what's in front of their line or walks it (Why::Settle). Read
  once a possession per man; a lapse forces it. Demand 80 for Lighthouse APSL
  and Semi Pro Standard; Bielsa's school row stays 20.
- **counter-or-keep (140), wired:** in the counter window the deep ball still
  goes.
- Both rows had no `taught_from`, so nobody knew them and demand did nothing
  (the first A/B matched to the digit). Mind that on any queued concept.

10 matches LH v Ukies, scratch DB, same seeds, off → on: shots 53 / 49 → 31 /
23 (pro 12.9), goals 8.6 → 5.4 (pro 2.5), passes aimed past their last man 110 /
152 → 87 / 137 (pro ~26), Lighthouse breakaway goals 3.5 → 1.6, Lighthouse W8
D1 L1 → W5 D2 L3. `ahead_min` 3 was a half measure: shots 40 / 29, goals 9.9.
Mates ahead 2.17 / 1.16 / 0.32. Goldens unmoved: rating 0 without the DB row.

**Next mole:** spells did not lengthen (10.2 s, pro 46.7; 417 a match, pro 121)
and time on the ball did not move (0.63 s, pro 1.47). He stops forcing the ball
in behind but still plays forward in front of the line at once, or gets it
taken: 8+ of 10 passes inside 1 s. Then the shape, which still tops out under
pro with time (3.7 against 5.3).

### 8.100 G5.2 — the ball out is the officials' call (mig 922)

James: "we need out of bounds with throw ins. we need goal kicks and corner
kicks. refs should call them."

G3 had all three, as a silent teleport. The World decided on the tick, the ball
jumped, and the first touch made it live. A throw was a foot kick, a corner sat
1 m in, a goal kick sat outside the goal area, a carried ball never went out
(the owner kept it on the 2 m apron), offside was armed on all three (Law 11.3
forbids it), an opponent could steal from a taker, nobody kept any distance,
and `corner-left` / `corner-right` had no position rows.

**The sequence (World + core::Officials):** the whole ball over the line (Law 9;
goals too) stops play and the ball runs on, untouchable → `call_s` later the
official whose line it is calls it (each assistant his own touchline in his
half and his goal line; the far half of a touchline is the referee's, the
diagonal's other end) → the event fires, `retrieve_s` later the ball is on its
Law spot → the taker walks there → at `restartReadyTick()` he can touch it → it
stays dead until he PLAYS it (`heldRestart()`): he can't walk, can't be tackled
or robbed. Kick-offs and free kicks are still live at the first touch.

**The call can be wrong (judgement ball-out-last-touch):** a clean ball never;
a ball off a man (bobble, block, tackle, within `deflection_s`) goes the wrong
way at `wrong_pct_per_10m` per 10 m from the touch, capped. FH numbers: no
published rate found. The World keeps the truth; the line itself is still exact.

**The law on the pitch:** throw from the crossing point, in the hands overhead
(z 2 m), any kick button is a throw, `throw_max_m` 28 (pro p90), onto the pitch.
Corner in the arc, goal kick in the goal area on the side it went out. No
offside from any of the three. Brain::keepLawDistance: 2 m from a throw, 9.15 m
from a corner or free kick; Law 16's box stays Brain::ordersSeen's.

**Takers (Brain::takeRestart):** the keeper for a goal kick (his own concepts,
then long after `keeper_wait_s`); the man whose corner mark is on the ball; else
the nearest outfielder. Throw: most room plus a little ground gained, raced with
loftSafe, waits up to `throw_wait_s`. Corner: the freest man attacking the box,
else the penalty spot. Live corners stand in the phase rows, both teams
(GameServer::holdCornerShape); first numbers [FH], a coach's to change. Live
goal kicks stay brain-only (G4.72). A human who walks off a restart loses it to
the brain after 10 s past ready.

**Client:** thrower's hands overhead (player flags bit4); the caller and the
referee point (official flags bits 1-3: up for a throw, level at the goal area,
down at the arc); whistle synthesised in client.js, pip for a restart, longer
for a goal or a half.

Pro numbers: `scripts/benchmarks_statsbomb_restarts.py`, 60 PL 2015/16 matches,
seeded sample [StatsBomb Open Data]. Goal kicks predate the 2019 law.

10 matches LH v Ukies, scratch DB (919 + 922), per match unless "team":

| | game | pro |
|---|---|---|
| throw-ins a team | 47.5 / 19.7 | 23.1 |
| goal kicks a team | 5.3 / 10.9 | 8.5 |
| corners a team | 3.0 / 0.7 | 5.7 |
| dead median s: throw / goal kick / corner | 9.9 / 22.1 / 23.2 | 13.1 / 27.4 / 27.0 |
| throw length m, reaches a mate | 19.5, 95% | 15.4, 82% |
| goal kick length m, reaches a mate | 9.6, 97% | 60.1, 49% |
| corner length m, reaches a mate | 39.9, 76% | 34.4, 42% |
| corner: shot within 10 s | 65% | 31% |

Called by assistants 62%, referee 38%. Ball dead 22% of the time. Longest wait
23 s. Off a man 0.2 a match, wrong calls 0.00: the wrong-call path works (test)
but hardly ever runs, because almost nothing goes out off a defender.

**Open (answered in §8.101):** goals 5.4 → 8.7 and shots 31 / 23 → 35 / 25
against §8.99. This section said it wasn't the restarts: 0.30 goals a match
within 10 s of a throw, none of a corner or goal kick. **That count was wrong:**
the watch closed on the shot, before its goal landed. It was the corners.

**Next mole:** corners 3.7 a match against 11.4, with balls off a man 0.2 a
match. Blocks, parries and clearances should be putting it behind. Then throws
too safe (95%), corners with no aerial contest (no headers: reach stops at
1.5 m, the cross is taken on the way down), and no short corners. Concepts 146
throw-in-retain, 147 long-throw, 148 press-their-throw, 142-145 corners stay
teaching rows.

### 8.101 G5.3 — the ball in the air is contested (mig 929)

§8.100's open question, goals 5.4 → 8.7, had an answer in a table already
printed: 1.6 goals a match with a corner as the last pass, off 3.7 corners.
The restart line said 0.00 because its watch closed on the shot, before the
goal landed. Counted off the kick's own clock it reads 1.5.

**Why (GAME_TRACE_CORNER=n):** nobody could touch a ball above 1.5 m and the
nearest man under it simply had it, so the delivery to the freest man was a free
control 8.5 m out, a marker 0.6-1 m away doing nothing, and a shot.

**The rule (World::aerialWinner, headIt):** a ball in open play, coming down,
from `min_z_m` 1 m to the top of a man's header, within `radius_m` 1 m of him.
Keepers are out of it (their hands are unchanged). Both teams there: a duel,
50-50 between equals, `duel_slope` 0.6 points of chance per point of aerial
share, held to 5-95. One team there: he heads it only above his chest, and only
at their goal (`goal_range_m` 14, straight-line) or away from his own
(`own_range_m` 35); otherwise it drops to him as before. At goal it goes 14 m/s,
45° of error alone, 80° with a man on him (fit to the pro 28.7% on target). Away
it goes lofted, 16 m/s, 40°. In between it glances on at half speed. Wired:
techniques 202 header-attacking, 240 def-header-clear. The Brain doesn't know
yet: it reads a ball as reachable to 1.5 m, doesn't choose where a header goes,
and nobody attacks a cross on purpose.

**The two attributes that now play:** `jumping_reach` (top of his header 2.3 /
2.6 / 2.9 m) and `strength`; his aerial share is their mean. Both physical on
the sheet, appended to the attribute order (17, wire 0x37 append), with position
offsets from CB +10 / +8 to W -5 / -5. Unrolled = 50, the coin flip.

Off without the `radius_m` row, so the goldens run unchanged.

**The first cut was wrong, and the wrong table said it was right.** It read
"goals with a corner as the last pass: 0.1", but a header isn't a completed pass,
so header goals left that table; the corner still gave 1.3 goals a match. The
trace (GAME_TRACE_HEADER=n) showed `goal_range_m` measured depth only, so men on
the touchline headed "at goal", and men beside the kicker nodded rising balls.
Read "goals within 10 s of a corner" and "headers in", not the last-pass table.

Pro: `game/scripts/benchmarks_statsbomb_aerial.py`, the 60 PL 2015/16 matches of
the restarts sample [StatsBomb Open Data]. Not yet in game_benchmarks.

10 matches LH v Ukies, scratch DB (919 + 922 + 929), rolled sheets:

| | before | G5.3 | pro |
|---|---|---|---|
| goals a match | 8.7 | 5.0 | 2.5 |
| goals within 10 s of a corner | ~1.5 (2-match trace) | 0.20 | 0.22 |
| goals per corner | ~40% | 7% | 1.9% |
| headed shots a team | none | 1.9 / 0.4 | 2.3 |
| headed goals a match | none | 0.30 | 0.42 |
| headed clearances a team | none | 15.4 / 16.9 | 16.1 |
| aerial duels a match | none | 22 | ~44 |
| shots a team | 34.6 / 24.6 | 34.4 / 21.3 | 12.9 |
| corner: a shot within 10 s | 65% | 57% | 31% (43% by play pattern) |

SE on a 10-match goal figure is near 1, and the re-roll also moved 12 of 231
pace / passing / tackling rows because the sheet reads today's lineups. Margin
went from +2.70 to 0.00 ± 0.49: Lighthouse was living on corners. Shots did not
fall, and the goals fell only partly from corners: the rest of the 3.7 is
unexplained and may be noise or the re-roll.

**Next mole:** throw-ins 56.4 / 21.8 a team (pro 23.1) and corners 2.0 / 0.8
(pro 5.7): the ball goes over the touchline far too often and over the goal line
off a defender hardly ever. Then aerial duels at half the pro count, the keeper
claiming a cross (technique 266 gk-claim-cross), and the owed tracking lines
(mig 923).

### 8.102 G5.4 — pro only, from the data (migs 933, 934, 941, 942, 949, 951; IN PROGRESS, scratch DB only)

James 11/2: "pro only with Actual pro teams and player abilities", "lets re
model based on the data", "we can rip out whatever". Judge the game on real
sides against the numbers from those same matches, and replace hand rules
with measured rates. Semi-pro and youth are parked; rip-out not done yet.

**The league.** `scripts/load_pl1516.py` builds all 20 2015/16 Premier League
teams from StatsBomb Open Data (380 matches, free with attribution): usual
shape, usual XI + 7, abilities by rank inside the position group, rates shrunk
to the group mean. Passing is judged against the pass (league rate by length,
zone, height, pressure). The table reproduces (Leicester 81, Villa 17). Names
reach the DB only, never git. The 50 centre and 12-point spread are [FH] until
an FM export gives the spread by position. Pace, acceleration, deceleration,
agility, reaction, strength, communication and concentration have no event
source and stay unrated (the band); unrated top speed is 9.2 m/s [FH].

**The map (mig 933).** Every concept tied to what can test it: 118 events, 53
tracking, 15 nothing free. A first pass from the cues, nothing measured yet.

**Shooting (mig 934).** `benchmarks_statsbomb_decisions.py` measures the share
of open-play releases that are shots, by distance, central or wide, pressed or
free. ShotSelection rolls those rates when the rows exist (per spot per 3 s);
the range fallback and the touch-tight "the boot IS a shot" are off with them.

**What the tests showed (Leicester v Arsenal, 4-10 matches, thin):**

| Setup | Shots a team | Goals |
|---|---|---|
| Curriculum, old rule | 68 / 72 | 12.0 |
| Curriculum, real rates | 65 / 72 | 11.7 |
| Ukies model, old rule | 30 / 31 | 8.5 |
| Ukies model, real rates | 36 / 39 | 8.2 |
| Lighthouse model, real rates | 44 / 40 | 8.2 |
| Curriculum, all rates zero (1 match) | 0 / 0 | 117 |
| Pro (2015/16) | 12.9 | 2.5 |

The pro band and the ratings are not the cause (semipro band 74 / 79 shots;
ratings removed 29 / 29). Real rates did NOT bring shots down: the choice is
not the fault. With shooting off, carriers walked it in 117 times: the fault
is upstream, far too many men reach scoring spots and nobody, keeper included,
stops a carrier there. Curriculum doubles it. **Next:** measure the game's box
touches and final-third entries against the same 380 matches, then rebuild the
defending the data says is missing (mapped concepts: duel, keeper, press).

**Later on 11/2 (Leicester v Arsenal, Semi Pro Standard model, 4-6 matches each,
thin). Three of my causes were wrong, so the order matters:**

| Test | Passes a team | Spells | Cut out, a team | Entries | Shots a team | Goals |
|---|---|---|---|---|---|---|
| Real shot rates | 751 / 767 | 395 | 63 | 115 / 125 (old count) | 36 / 39 | 8.2 |
| + real time on the ball, press ends hold at 2.5 m (mig 941) | 705 / 702 | 375 | 60 | 108 / 121 (old count) | 36 / 41 | 8.2 |
| + cut_share 0.1 (experiment, no rows) | 613 / 677 | 276 | 7.4 | 107 / 120 (old count) | 38 / 37 | 10.2 |
| + hold ends only at 1 m | 593 / 603 | 301 | 7.5 | 95 / 95 | 36 / 38 | 7.0 |
| Pro (2015/16) | 378 | 121 | 7.2 | 44 | 12.9 | 2.5 |

Interceptions hit pro exactly and shots did not move: the cut-out rate cleans up
spells and own-third losses, it does not cause the goals. Holding the ball cut
passes by a fifth and did not cut entries or shots: a man holding it carries
toward goal (`seek(goal)`), so time on the ball became metres upfield.

The harness counted an entry on any ball won inside the third. Fixed in
match_main: same team across the line, as the benchmark counts. Corrected
rates: entries 95 v 44, shots per entry 0.38 v 0.29, goals per shot 9.6% v 9.7%.
**So finishing is right and the game gets forward twice as often as it should.**

**Next:** measure where real passes and carries go by zone (forward, square,
back; how far), and replace the carrier's run at goal and the forward-first
pass choice with those rates. Also open: Villa beat City (1W 1D 4L for City),
so team strength is not coming through; the ratings span only 47-54 by team.
cut_share is an experiment, not yet a decision.

**The carry (same day).** Real carries are short: ~5 m, gaining 2-3 m, 30%
forward (`benchmarks_statsbomb_direction.py`). A man holding it ran at goal at
full speed. Scaling his run while he holds it was the first real move:

| carry_share (with cut_share 0.1, press_m 1) | Shots a team | Goals | Entries | Passes |
|---|---|---|---|---|
| off | 36 / 38 | 7.0 | 95 / 95 | 593 / 603 |
| 0.35 | 23 / 22 | 5.8 | 88 / 85 | 657 / 647 |
| 0.15 | 20 / 22 | 4.8 | 78 / 81 | 631 / 668 |
| Pro | 12.9 | 2.5 | 44 | 378 |

4 matches each, so rough. carry_share, cut_share and press_m are fits, kept in
mig 941 as [FH]. Still wrong: passes twice pro at 89% complete (pro 79), time on
the ball 1.0 s (pro 1.5), spells 317 (pro 121), corners ~1 (pro 5.7).

**Pass direction (mig 942).** A man with time only passed if a forward ball was
on (80% forward in midfield, pro 55%), so he carried until closed down, then
played it back. Unpressed, his hold over, he now rolls the real square and back
shares for his third, to the open mate nearest 16 m [FH]; forward stays with the
ladder. An early reading that defenders stood too close was wrong: the carrier's
nearest opponent is 5.7 m with bands 21 / 33 / 29 / 17%, on pro tracking (4.4-5.3
m; 18-22 / 31-33 / 27-31 / 17-24). The 64% v 20% "pressed" gap compared 2.5 m in
the game with StatsBomb's own pressure tag: not the same measure.

| 4 matches each | Shots a team | Goals | Entries | Passes | Spells |
|---|---|---|---|---|---|
| Leicester v Arsenal | 17 / 15 | 4.2 | 67 / 62 | 674 / 666 | 291 |
| Man City v Villa | 16 / 17 | 5.2 | 57 / 75 | 648 / 708 | 307 |
| Pro | 12.9 | 2.5 | 44 | 378 | 121 |

Unpressed midfield passes now 55 / 14 / 31 (pro 55 / 18 / 27). Overshot: unpressed
final-third passes go back 58-63% (pro 30), because the ladder rarely fires a
forward ball there. Goals per shot rose to 13-16% (pro 9.7), so chance quality is
now the gap. Passes still twice pro at 90% complete, and losses near own goal 15-20
(pro 2.1). City still don't beat Villa: team strength is untouched.

**Pressed and final-third passes (mig 942 extended).** The direction rates now
cover pressed men, and forward is picked here when pressed or in the final third.
Shots 16 / 13 and 16 / 12, goals 3.5 and 5.8; City beat Villa 4 of 4 (thin). Pass
direction barely moved under pressure (55-76% back, pro ~31): the forward roll
finds no candidate and falls through to the old logic. Loosening the lane check
(`dir_forward_reach`, no row, default 1) changed little, and 0.5 and 0.2 are the
same because the margin clamps to zero below the control radius: safety is not
the block. In the final third only 0.43 mates stand ahead of the ball, so the
likely gap is bodies, not choice. No real number for that yet: measure mates
ahead by zone from tracking next.

Team shape on tracking: in possession 47.5 x 33.8 m (pro 42.5-47 x 34-36) is
right. Out of possession 35.5 wide is right, 25-26 m long is short (pro 29.6-32.9).
Real completion by direction, by third (60 matches): forward 66 / 73 / 63%,
square 82 / 87 / 59%, back 99 / 97 / 92%. Game 90% overall, so real players take
on far more failing forward balls than the game does.

**Bodies ahead of the ball (mig 949).** The harness's last zone is the final 17.5
m, not the final third. Real mates ahead of the ball, Euro 2020 360 frames (24
matches, visible men only, so a minimum): 4.3 / 3.3 / 1.3 by zone; game 3.4 / 1.4
/ 0.45. The team's middle followed only 45% of the ball's x. At 0.9: 3.8 / 2.6 /
1.5, offsides 1.5 a team in the 4-match run (pro 2.0). A fit, not a measurement.

**32 matches (8 each, 4 fixtures), the first sample big enough to trust:**

| Fixture | Stronger side W-D-L | Shots a team | Goals |
|---|---|---|---|
| Leicester v Arsenal | 3-2-3 | 16 / 17 | 4.4 |
| Man City v Villa | 1-2-5 | 16 / 17 | 5.4 |
| Spurs v Norwich | 3-2-3 | 15 / 19 | 6.0 |
| Chelsea v Sunderland | 4-0-4 | 18 / 17 | 6.2 |
| Pro | | 12.9 | 2.5 |

Average 5.3 goals, 16.9 shots, 15.7% goals per shot (pro 9.7), entries 55 (44),
passes 620 at 88% (378 at 79), spells 282 (121), own-end losses 21 (2.1), corners
3.5 (5.7), throw-ins 40 (23), offsides 3.5 (2.0). City's 4-0 in the earlier run was
noise: the league's better sides win 11 of 32, lose 15: **no team strength at all.**
Next: why shots go in so often, then why ability doesn't decide matches.

**Conversion by distance (24 matches, 3 fixtures; `CONVERSION BY DISTANCE` line).**

| From | Game goals per shot | Pro |
|---|---|---|
| Under 11 m | 33% (63 of 191) | 18.6% |
| 11-16 m | 13% | 11.5% |
| 16-22 m | 6.5% | 4.6% |
| 22-30 m | 5.7% | 2.2% |

The excess is mostly close range, and most of that one fixture: Chelsea v Sunderland
53% under 11 m, the other two 21-22%. Keeper ratings there are mid-table (61, 62).
A 1-11 traced goal by goal is no loop: ordinary shots. Real keepers stand 1.2-2.4 m
off the line and 0.4-0.6 m from the shot line (`benchmarks_statsbomb_keeper.py`);
ours stands ~2.6 m off (line at 52.5, keeper at 49.9), so narrow-angle is not the
fix. Open: real shots from under 11 m are 36-82% headers, which score less; the
game's are nearly all feet. Not yet tested.

**Measures that do not compare.** A game spell starts on any change of owner;
StatsBomb's possession survives a brief touch. So spells (282 v 121), spell length,
"spell began near goal" (48% v 5%) and own-third losses (21 v 2.1) overstate the gap
by an unknown amount. Fix the harness's spell before judging any of them.

**Spells as StatsBomb counts them.** The harness now also counts a spell only
once the other side keeps it 1 s or completes a pass (`SPELLS AS STATSBOMB`): 243
a match, 23 s (pro 121, 47 s, pro with dead time). Won within 35 m of the goal
attacked stayed 23 a team (pro 2.1): that gap was real. The conversion line counts
kicked shots only, so its pro column is feet: 25.2 / 12.6 / 4.6 / 2.0% by distance.
Real close shots are 53% headers at 12.8%, feet 25.2%. The game's real gap there was
share: 33% of its foot shots came from under 11 m, pro 16%.

**Clearing it (mig 951).** Pressed near his own goal a real outfielder clears: 93%
central in the box, 45% wide, 40 / 30% out to 35 m, and loses it under 9%. Ours
were robbed, 68% of them 1-3 s after taking it, held there by the G5.4 hold. He now
rolls those rates, hit first time, and near his goal any presser ends the hold.

| 32 matches, 4 fixtures | Before | After | Pro |
|---|---|---|---|
| Goals | 5.3 (4.4-6.2) | 4.0 (3.9-4.1) | 2.5 |
| Shots a team | 16.9 | 14.8 | 12.9 |
| Won near goal, a team | 23 | 16.5 | 2.1 |
| Better side W-D-L | 11-6-15 | 17-6-9 | |
| Foot shots under 11 m, goal % | 34 | 33 | 25.2 |
| Entries | 55 | 61 | 44 |
| Passes | 620 at 88% | 615 at 88% | 378 at 79% |
| Spells (StatsBomb count) | 244 | 232 | 121 |
| Corners | 3.5 | 1.9 | 5.7 |
| Throw-ins | 40 | 42 | 23 |
| Offsides | 3.5 | 3.8 | 2.0 |

Corners fell by half: clearances now go long and wide, and where they go out is
wrong. Next: where real clearances land, why the ball goes out over the touchline
twice too often, then team strength with the physical columns filled.

### 8.103 G5.5 — get in line with the ball; walk your shape (mig 958; scratch DB only)

Asked where clearances land and why the ball goes out so often.
`scripts/benchmarks_statsbomb_out.py` (380 matches, StatsBomb Open Data, free with
attribution) names the last on-ball event before each restart, and match_main now
counts the same (`OUT BY`, `CLEARANCES`, `GROUND PASS OUT`). A keeper who only
faced a shot touched nothing, so it counts as the shot.

| A team a match | Pro | Game |
|---|---|---|
| Throw-ins | 23.1 | 41.8 |
| from a ground pass | 1.4 | 30.8 |
| from an air pass | 5.9 | 1.5 |
| from a clearance | 4.7 | 0.0 |
| carried out (pro: Dribble, 1.3; not the same event) | 1.3 | 5.7 |
| Corners | 5.4 | 2.0 |
| Clearances | 28.4 | 55.1 |
| Share of clearances to a throw-in, corner | 16.5, 4.8% | 0, 0% |

**The excess is ground passes the receiver misses.** Real ground passes go out
0.4-0.7% of the time up to 30 m; ours 7-10%. Of 126 traced, 94 passed within 2 m of
him at about 10 m/s, he moving 2-4 m/s. Three of my causes were wrong again: a
touchline problem (no, the ball just carries on past him), a control-speed gate
(no, a mid player holds 16 m/s), braking onto a wait spot (no: `wait_through`
changed nothing and came out). Traces showed a man on the line at the kick walking
up it to the first spot he could only just reach, then missing it.

**Get in line.** The man a rolling pass is for takes the first spot he reaches
`early_s` ahead of the ball, body on it, and takes no spot short of the foot of his
perpendicular until within `on_line_m` of the line (`Brain::getInLine`,
`concept.meet-the-pass.early_s` 0.25, `on_line_m` 0.25, both [FH] fits, mig 958; no
row = off, goldens held).

| 32 matches, 4 fixtures | Off | early_s 0.25 | + stretch_m 0.9 | Pro |
|---|---|---|---|---|
| Pass completion | 88.0% | 80.0% | 91.5% | 79 |
| Passes a team | 611 | 539 | 671 | 378 |
| Entries | 61 | 50 | 71 | 44 |
| Throw-ins | 41.8 | 38.6 | 26.9 | 23.1 |
| Corners | 2.0 | 1.5 | 1.5 | 5.4 |
| Shots a team | 14.5 | 14.3 | 16.7 | 12.9 |
| Goals | 3.7 | 4.5 | 4.4 | 2.5 |
| Home (stronger) W-D-L | 13-5-14 | 16-6-10 | 15-7-10 | |

early_s moves completion, passes and entries toward pro. Goals rose 0.8; 32 matches
can't say if that is real. It did NOT fix the ball out: 39 throw-ins, half the
remaining misses 0.5-1 m off him. `physics.tempo.stretch_m` (the intended man's
reach, no row, off) took throw-ins to 27 by making passing too easy: an experiment
like cut_share, not a decision.

**Doubts.** Off here is 13-5-14 and 3.7 goals; §8.102 printed 17-6-9 and 4.0 for
what should be the same build. Not traced. Home wins ran 11-16 of 32 across these
runs, so "better sides win" is not established: don't lean on §8.102's 17-6-9.
Clearances out read 0 while the kick table says 1-3% dead: the count may be wrong,
check before believing "never out".

**The real cause: men run far too much.** A pass to a man standing still went into
touch 1-2% of the time, to one running across it 8-10%. The passer leads a moving man
on his straight line, or plays the spot he left. Two fixes from that end failed and
came out: the passer checking the man can get there (`passer_reads`, fired too rarely
to matter; passes 532, throw-ins 36.6) and charging his sideways speed in the reach
(`charge_turn`: throw-ins back to 41.8, completion 74.6). Then measured the man himself
(`scripts/benchmarks_tracking_receiver.py`, DFL open data, 7 matches, 3,833 completed
flat open-play passes; a sample of 2 matches for all-time speed):

| | Real | Game, off | shape_tau_s 4 |
|---|---|---|---|
| Receiver at the kick under 2 m/s | 37.9% | 17.4% | 37.3% |
| 2-5 m/s | 52.3% | 37.5% | 43.2% |
| 5+ m/s | 9.8% | 45.1% | 19.6% |
| All the time under 2 m/s | 69.4% | 20.6% | 33.5% |
| All the time 2-5 m/s | 27.3% | 31.9% | 40.0% |
| All the time 5+ m/s | 3.3% | 47.5% | 26.3% |

Not like for like: real receivers are of completed passes only (the event names no
receiver otherwise) with event clocks good to a few tenths; real all-time speed has
keepers, on-ball men and dead time in; game all-time is outfielders off the ball. None
of that closes a 14x gap. 58% of the game's 5+ running was plain "hold shape": every
shift of his spot and he ran at it.

**Walk your shape.** Holding shape he closes the gap in `physics.body.shape_tau_s` 4
s ([FH] fit, mig 958; no row = off), so the speed is what the gap asks.

| 32 matches, 4 fixtures, early_s on | tau off | tau 3 | tau 4 | Pro |
|---|---|---|---|---|
| Goals | 4.5 | 3.3 | **2.9** | 2.5 |
| Shots a team | 14.3 | 13.0 | **12.7** | 12.9 |
| Throw-ins | 38.6 | 22.8 | **19.4** | 23.1 |
| from a ground pass | 28.5 | 15.4 | 12.3 | 1.4 |
| Offsides | 3.2 | 2.6 | 3.0 | 2.0 |
| Entries | 50 | 60 | 57 | 44 |
| Pass completion | 80.0% | 85.3% | 86.6% | 79 |
| Passes a team | 539 | 617 | 643 | 378 |
| Corners | 1.5 | 0.6 | 0.5 | 5.4 |
| Goal kicks | 4.6 | 3.6 | 3.3 | 8.3 |
| Time on the ball | 1.0 | 0.9 | 0.9 | 1.5 |
| Home (stronger) W-D-L | 16-6-10 | 19-8-5 | 14-12-6 | |

Tau 4 over 3: it is the number the receiver and goal lines fit best, and throw-ins
under pro leave room for the air passes and clearances that still never go out.

Shots, goals and throw-ins came to pro through one change to how men move, with no
shooting, keeper or finishing rule touched. It costs passing: men standing still are
easy to find, so completion and passes went the wrong way. Corners and goal kicks fell
further from pro. Better sides did not lose a fixture on margin in tau 4 (City v Villa
-0.25 is the one miss, 3-2-3), but 32 matches swung 11-19 home wins today, so that is
a lead, not a result.

**The jog and the sprint.** With tau 4 what stayed over 5 m/s was mostly men far off
their target: hold shape 88% at 15 m+, recover goal-side 72%, two thirds out of
possession. So `shape_max_mps` 4.5 and `defend_max_mps` 6 ([FH] fits, mig 958; no row =
off; defend = recover, mark, mark tight, protect the middle).

| 32 matches, 4 fixtures | tau 4 | + shape 4.5 | + defend 5 | + defend 6 (kept) | Real |
|---|---|---|---|---|---|
| Time at 5+ m/s | 26.3% | 19.7% | 6.0% | 12.6% | 3.3% |
| under 2 m/s | 33.5% | 35.0% | 38.9% | 37.2% | 69.4% |
| Receivers at 5+ | 19.6% | 17.0% | 15.6% | 15.8% | 9.8% |
| Km a man in 96 min | | | | 16.5 | 10.0 |
| Goals | 2.9 | 3.3 | 3.3 | 3.4 | 2.5 |
| Shots a team | 12.7 | 13.6 | 15.8 | 15.8 | 12.9 |
| Entries | 57 | 56 | 63 | 60 | 44 |
| Home W-D-L | 14-12-6 | 7-11-14 | 14-7-11 | 15-6-11 | |

Defend 5 is a cap right at the line it is measured by, so its 6.0% is close to true by
construction; defend 6 leaves a sprint possible and the 5+ share measured. Km is the
number no cap can fake: the real figure is all players at all times (10.0 from 2
matches), the game's outfielders off the ball, so the true gap is a little smaller. Kept
under "correct behaviour first": movement is upstream of everything, but shots and goals
went the wrong way, because defenders now arrive late rather than leave early.

**Next (the mole):** men still stand 39% of the time against 69% and cover 16.5 km.
Recover goal-side is 37% of what's left at 5+: it fires too often. A defender should
already be there, so read the danger earlier instead of running later; that should
give back the shots. Then passing too easy, corners, goal kicks, clearances, air passes,
time on the ball, team strength.


### 8.104 G5.6 — recover to your shape, sprint only in danger (mig 959; scratch DB only)

§8.103's next mole: recover goal-side was 37% of all running over 5 m/s, 81% of
it 15 m+ from its target. Cause in the code: every beaten man aimed at the same
point 6 m in front of the ball, so a side piled in behind the ball and sat 25 m
off its shape. The cover man (second to the ball) already holds the ball-goal
line 7 m goal-side (§G4.4 rule 3), so the recovery run doubled him.

**Recover to shape** (`concept.recover-goal-side.to_shape`, switch, mig 959; no
row = off, goldens held): beaten, he runs to his own anchor, already goal-side
of the ball. Coaching: pressure-cover-balance, "get back into your shape", not
"get to the ball". [FH]

**Read the danger** (`sprint_within_m` 40, [FH] fit, mig 959): it is a recovery
sprint (Why::Recover, defend cap) only with the ball inside 40 m of our goal;
further out the same run is hold shape, at the shape's pace (§8.103 tau and
cap). A midfielder beaten 70 m from goal jogs back.

64 matches (4 fixtures × 8, seeds 1000+ and 5000+), pooled:

| | Off (§8.103 kept) | To shape | + danger 40 m (kept) | Pro |
|---|---|---|---|---|
| Goals | 3.1 | 3.45 | 3.6 | 2.5 |
| Shots a team | 15.2 | 14.1 | 14.6 | 12.9 |
| Passes a team | 636 | 659 | 659 | 378 |
| Entries | 62 | 58 | 63 | 44 |
| Throw-ins | 18.4 | 18.5 | 18.1 | 23.1 |
| Home W-D-L | 28-13-23 | 27-17-20 | 36-9-19 | |
| Off the ball 5+ m/s (seeds 5000+) | 12.8% | 12.1% | 9.5% | 6.3% (see below) |
| Recover share of 5+ running | 37% | 33% | 19% | |

The goal columns are noise: on the first seeds goals ran 3.4 / 2.9 / 4.0, on the
second 2.8 / 4.0 / 3.2, the order reversed. Movement numbers agree to a tenth
across all four fixtures and both seed sets. Kept on correct behaviour, not on
goals.

**§8.103 compared the wrong things.** Its "real" speeds (69% under 2 m/s, 10.0
km) were all players, all the time, dead time in; the game's were outfielders
off the ball, in play. Like for like (`scripts/benchmarks_tracking_shift.py`,
DFL, 7 matches, outfielders off the ball, both sides, in play, 0.2 s steps):

| In play, off the ball | Real | Game (kept) |
|---|---|---|
| under 2 m/s | 45.4% | 40.1% |
| 2-5 m/s | 48.3% | 50.5% |
| 5+ m/s | 6.3% | 9.4% |
| Mean, as km in 96 min | 2.49 m/s, 14.3 | 2.72 m/s, 15.7 |

So the game runs about 10% too much, not 65%; §8.103's "men run far too much"
was mostly the comparison. shape_tau_s, the caps and this change still hold on
their own receiver and sprint numbers.

**What is wrong is where the block goes.** The same script, the side without the
ball over 1 s windows (game: `BLOCK WITHOUT THE BALL`, possession spells only):

| Without the ball, 1 s | Real | Game |
|---|---|---|
| Middle moves, mean | 2.32 m/s | 2.28 m/s |
| Middle on the ball's x (slope) | 0.21 | 0.44 |
| Middle on the ball's y | 0.14 | 0.06 |
| Back line on the ball's x | 0.22 | 0.43 |

The real block slides across with the ball and gives ground slowly; ours runs
up and down twice as hard and hardly shifts across. Suspects, not traced: the
back line's height is set off the ball (ball − hold, line-hold §G4.56), the
compactness cap (ball + 10) moves 1:1 with it, and marking follows men, not the
ball (kShiftY 0.3 should give about 0.3 across). The spot a man holding shape is
told to stand on slides 5.4 m/s without the ball (32% over 4 m/s, every line
alike), 2.2 with it (`HOLD SPOT SLIDES`), so he can't stay on it under the 4.5
cap.

**Next (the mole):** the block's slope on the ball, from the data above. Then
passing too easy, corners, goal kicks, air passes, time on the ball.


### 8.105 G5.7 — slide across with the ball; one man wide on the far side (mig 976; scratch DB only)

§8.104's mole was the block's slope on the ball. First measured where it STANDS,
not only how fast it follows (`benchmarks_tracking_shift.py` now bins it; match_main
prints `BLOCK STANDS`, same definitions: side without the ball, outfielders, 5 Hz).

**Up and down is already right.** Ball metres from the defending side's own goal →
back line / middle, metres from the same line:

| Ball | 0-15 | 15-30 | 30-45 | 45-60 | 60-75 | 75-90 | 90-105 |
|---|---|---|---|---|---|---|---|
| Real back line | 7.8 | 16.2 | 24.8 | 32.8 | 39.7 | 45.5 | 50.5 |
| Game back line | 11.7 | 21.1 | 28.6 | 34.7 | 41.3 | 50.1 | 58.3 |
| Real middle | 19.3 | 27.8 | 37.0 | 45.6 | 53.5 | 61.3 | 69.4 |
| Game middle | 22.9 | 30.5 | 38.0 | 44.6 | 52.5 | 63.5 | 74.4 |
| Real share of time | 6% | 11% | 15% | 19% | 21% | 16% | 12% |
| Game share of time | 1% | 8% | 21% | 32% | 26% | 8% | 4% |

Within a few metres everywhere, so §8.104's 1 s slope (0.41 v 0.21) is about how
quickly the block reacts, not where it ends up. The last row is a separate problem:
our ball lives in midfield and rarely reaches either end (goal kicks, corners).

**Across is wrong.** The middle's y toward the ball's side, by the ball's |y|: real
2.1 / 6.0 / 9.8 / 12.4, game 1.0 / 3.5 / 4.9 / 7.0. With the ball wide (|y| 24+), the
ten defenders' y toward the ball, far touchline to near, and the ten attackers':

| | far | | | | | | | | | near |
|---|---|---|---|---|---|---|---|---|---|---|
| Real defenders | -10.0 | -3.6 | 2.1 | 6.2 | 10.2 | 14.3 | 17.7 | 21.2 | 25.2 | 28.4 |
| Game defenders | -15.4 | -10.7 | -1.5 | 1.5 | 4.7 | 8.7 | 12.0 | 16.4 | 21.9 | 26.2 |
| Real attackers | -16.6 | -7.5 | -1.1 | 3.8 | 8.8 | 13.4 | 17.6 | 22.0 | 26.6 | 31.1 |
| Game attackers | -20.7 | -17.3 | -2.3 | -0.2 | 4.6 | 9.9 | 13.0 | 17.8 | 24.6 | 28.7 |

By job, ball wide: the far-side attackers were 95% hold shape with targets at -22.7.
The cause is `width` (bit 13, spread_wide): every wide-based man in possession holds
10 + 16 × degree m of width on his own side, wherever the ball is, so the far
full-back and the far winger both sat on the far touchline. The defenders marking
them (protect the middle, 18% of men, at -2.1) stayed wide with them. Below that,
anchorFor slides every shape 0.3 of the ball's y, capped at 10 m, in both phases.

**One man wide on the far side** (`concept.width.far_one`, switch): ball 15 m+ to the
other side, only the highest wide man on my side holds the width; the rest take
their shifted spot. Coaching: the far winger keeps the pitch big for the switch,
the far full-back comes inside for balance and rest defence. [FH]

**Slide as a block** (`physics.shape.ours_shift_y` / `ours_cap_y_m` with the ball,
`theirs_shift_y` / `theirs_cap_y_m` without; 0.6 and 20 m, [FH] fits to the profile
above; no rows = anchorFor's 0.3 / 10 m, goldens held). Defending, Brain applies it
only with their ball; GameServer's HUD anchors keep the built-in slide.

| 32 matches each, 4 fixtures | Off (§8.104 kept) | far_one | + slide 0.45/16 | + slide 0.6/20 (kept) | + loose_m 9 | Real |
|---|---|---|---|---|---|---|
| Middle y, ball \|y\| 30+ | 7.0 | 7.1 | 8.8 | 10.7 | 11.0 | 12.4 |
| Far two defenders | -15.4, -10.7 | -14.8, -10.6 | -13.8, -9.2 | -12.2, -7.1 | -11.5, -6.6 | -10.0, -3.6 |
| Far two attackers | -20.7, -17.3 | -19.0, -15.0 | -17.9, -13.3 | -16.7, -10.9 | | -16.6, -7.5 |

Two seed sets (1000+, 5000+) agree on these to a few tenths. `near-tight-far-zone
loose_m` 9 (the far marker further off his man) moved the far defenders half a metre
and was left out.

| 64 matches pooled (seeds 1000+, 5000+) | Off | Kept | Pro |
|---|---|---|---|
| Goals | 3.6 | 2.95 | 2.5 |
| Shots a team | 14.6 | 14.0 | 12.9 |
| Passes a team | 659 | 642 | 378 |
| Pass completion | 87.0% | 85.9% | 79 |
| Entries | 63 | 58 | 44 |
| Throw-ins | 18.1 | 21.3 | 23.1 |
| Corners | 0.4 | 0.35 | 5.4 |
| Goal kicks | 3.9 | 3.7 | 8.3 |
| Home (stronger) W-D-L | 36-9-19 | 27-14-23 | |

Every column moved toward pro except corners and goal kicks (flat). Kept on correct
behaviour. **Doubt:** the stronger side won 9 fewer of 64. Earlier runs swung 11-19
home wins in 32 on their own, so it may be noise; watch it, don't tune for it.

**Next (the mole):** the ball never reaches either end — 5% of the defending side's
time with the ball inside 15 m of either goal line against 18% real; corners 0.35 v
5.4, goal kicks 3.7 v 8.3. Then the far two defenders (still 2-3.5 m wide), the block's
1 s reaction, passing too easy.


### 8.106 G5.8 — clear at the real rate, keep it otherwise; a clearance is hurried (mig 989; scratch DB only)

§8.105's mole: the ball never reaches either end, corners 0.35 v 5.4, goal kicks
3.7 v 8.3. First suspect, from §8.103's doubt: clearances never go out. The count
was right (dead 1.8-3.8%, mostly offsides). `benchmarks_statsbomb_clear.py` and
match_main's `RELEASES BY ZONE` / `CLEARANCES BY ZONE` found two faults.

**Far too many clearances.** Foot clearances as a share of foot releases (open-play
passes + clearances, no keepers). StatsBomb flags EVERY clearance under_pressure
(0 unflagged in 380 matches), so mig 951's pressed shares (93% in the box, 30-40%
to 35 m) were read off a tag the clearance itself sets. The 360 freeze frames (115
matches) give the nearest opponent instead:

| Nearest opponent | under 1.2 m | 1.2-3 | 3-6 | 6+ | all | Game before |
|---|---|---|---|---|---|---|
| Own box | 53.5% | 44.4% | 36.0% | 13.4% | 35.4% | 37% |
| Own third, outside the box | 6.9% | 5.4% | 2.0% | 0.4% | 2.8% | 28% |
| Midfield | 1.0% | 0.5% | 0.2% | 0 | 0.3% | 1.9% |
| Their third | 0.1% | 0 | 0 | 0 | 0 | 2.4% |

Even touch-tight in his own third a pro clears 7% of the time. Ours hoofed whenever
touch-tight with no back pass (G4.60 keep-it allowed it there), plus 951's roll.

**Clear the danger** (`concept.clear-the-danger.rate_*`, 16 rows, mig 989; no rows =
951's roll and the touch-tight hoof, goldens held): rolled once on the ball, before
any pass, for every release, as the data counts it. Losing it, a touch-tight man
keeps it: plays back or shields (keep-it's shield, now in his own third too). [FH
roll; rates StatsBomb 360]

**A clearance is aimed like a pass.** It finds a mate 41-45% (real foot 23.5%) and
went out 0.4% (real 29%: wide, 49% into touch). Two fixes: `physics.kick.clear_err_deg`
40 (a hurried boot, the headed clearance's number, World::step on a first-time loft)
and `concept.clear-the-danger.touch_from_y_m` 24 (struck that far off the middle it
goes up his own touchline — "if in doubt, put it out"). Both [FH].

| 64 matches pooled (seeds 1000+, 5000+) | §8.105 | + rates | + error 40, touch (kept) | Pro |
|---|---|---|---|---|
| Foot clearances a team | 57.7 | 18.6 | 18.4 | 12.7 |
| Clearance to a mate | 43% | | 40% | 23.5% |
| Clearance out (throw, corner) | 0.4% | | 15-20%, 0 | 23.3%, 5.7% |
| Throw-ins | 21.3 | 22.6 | 28.1 | 23.1 |
| Corners | 0.35 | 0.7 | 0.65 | 5.4 |
| Goal kicks | 3.7 | 3.3 | 3.65 | 8.3 |
| Passes a team | 642 | 712 | 694 | 378 |
| Entries | 58 | 50 | 47 | 44 |
| Goals | 2.95 | 3.5 | 3.35 | 2.5 |
| Shots a team | 14.0 | 13.6 | 13.9 | 12.9 |
| Home (stronger) W-D-L | 27-14-23 | 39-11-14 | 28-13-23 | |

Release shares by zone now match the 360 table on both seed sets (box 35-41%, own
third 3.4-4.6%, midfield 0.4-0.7%, their third 0-0.2%). Throw-ins overshoot pro
because ground passes still go out 11 a team (pro 1.4, §8.103), not clearances.
Passes rose: men keep it rather than hoof it, and passing was already too easy.
Home wins swung 27 → 39 → 28 across changes that touch 18 kicks a team: noise.

**Not modelled: the clearance behind.** 8.7% of real box clearances become corners.
A forward aim with 40° either side can't go behind its own line; the real ones are
slices, blocks and deflections.

**Next (the mole):** corners and goal kicks — slices and blocks behind (clearances,
blocked shots, deflected crosses) and shots wide; then ground passes out, passing
too easy, the far two defenders, the block's 1 s reaction.


### 8.107 G5.9 — the cross, the wide carry, the box (IN PROGRESS; no migration, all off)

§8.106's mole: corners 0.65 v 5.4, goal kicks 3.65 v 8.3. Real sources
(`benchmarks_statsbomb_out.py`): corners from clearances 1.38 a team, blocks 1.34,
shots 0.92, keeper saves 0.60; goal kicks from shots 4.28, air passes 2.18. The
game's body block (G4.25) only stops balls above capture speed (2.0 a team v ~19
real blocks) and always sends them back within ±60°, where real blocked passes turn
every way (26% under 45°, 31% back) and go behind 10.7% of the time — now
`physics.block.turn_deg` / `keep` (defaults 60 / 0.3 = G4.25), not yet changed.

**The game had no cross.** No branch, no Why. Real (`benchmarks_statsbomb_cross.py
crosses`): 11.5 a team, 68% in the air, landing 7.5 m off the line around the middle,
28% completed, 40% cleared next; the cross share of passes by where struck:

| m off their line | wide 24+ | half-space 14-24 | centre |
|---|---|---|---|
| 0-6 | 32% | 54% | 51% |
| 6-18 | 25% | 31% | 1% |
| 18-30 | 10% | 6% | 0 |

Built, all off without rows:
- **Cross it in** (`concept.cross`, 186): rolled once on the ball at those rates, in
  the air (or driven low, `low_share` 0.32) to the mate with most room 3-13 m off
  their line inside 10 m of the middle, else the 7.5 m spot. `Why::Cross`.
- **Drive down the line** (`concept.drive-the-line`, 187): the no-pass carry from wide
  goes at goal every time (about 30° in from the flank). Real wide carries
  (`carries`): down the line 31-36%, out 5-21%, in 20-50° ~15%, in 50°+ ~15%, back
  30%. Rolled once on the ball at the forward shares.
- **Attack the box** (`cross-zone-runs`, 100): ball wide within 18 m of their line,
  the three most advanced go near post, far post, penalty spot; 18-30 m, one.
  `Why::AttackBox`.
- **Defend the cross** (`defend-the-cross`, 125): their ball wide inside our 18 m, a
  back-line man not on the ball stands within `depth_m` 12 of our line and `width_m`
  18 of the middle.

How the ball gets into the crossing zone (18 m off their line, |y| 14+), and who is
in the box with it there (`benchmarks_tracking_box.py`, DFL; match_main `INTO THE
CROSSING ZONE`, `BOX PRESENCE`):

| A team | Real | Game | + cross, drive, runs |
|---|---|---|---|
| Carried in | 8.8 | 1.4 | 2.1-2.8 |
| Passed in (from wide) | 12.9 (8.5) | 1.25 (1.0) | 1.7-2.4 (1.0-1.4) |
| Crosses | 11.5 | 0 | 3.6-5.2 |
| Attackers in the box, ball wide 0-18 | 2.18 | 1.33 | 1.0-1.3 |
| ... in the 3-13 m target zone (none) | 1.10 (46%) | 0.25 (84%) | 0.2-0.45 (74-88%) |
| Defenders in the box | 4.04 | 2.73 | 2.2-2.6 |
| Deepest / next defender, m off the line | 9.1 / 11.0 | | 10.7 / 13.8 |

64 matches with cross, drive and runs (no defend): goals 3.35 → **5.2** on both seed
sets (5.1, 5.3), shots flat at 13.3, goal kicks 3.65 → 4.9, corners flat. Crosses
alone gave 0.39 goals a team, one per 10 crosses — real is far fewer — because the
cross finds a mate 36-64% (real 28%): our box has 2.4 defenders, not 4.

**Why not shipped.** Defend the cross fires (traced: the back four's targets sit 4 m
off the line, mostly recover goal-side), but the men don't get there: 4 matches with
it put the deepest defender at 12.4 m, not lower. They arrive late, not to the wrong
place — the open question. Attackers likewise run (attack the box 86% of the three
most advanced) and still aren't in the target zone. The ball is in the crossing zone
too briefly for runs that take seconds; real sides are already in the box.

**Next (the mole):** why men don't get into the box in time, both sides — time the
ball spends wide near goal (real v game), how long before a cross real attackers
are in the box, and whether the shape's pace caps (§8.103) or offside hold them.
Then ship cross + drive + runs + defend together, then blocks, then corners.

**G5.10 (same section): the late box is the shape's walking pace.** With the ball
wide 18-30 m out, the four deepest defenders were 52% hold shape, standing at 22.3 m
off the line with their spots at 12.9 — 9 m behind — and 17% recovering from 33.6 m.
The spots were right; §8.103's shape pace (tau 4 s, 4.5 m/s cap) walked them there.
`physics.body.shape_danger_m` (their ball inside it of our goal, hold shape skips the
tau and cap) with `shape_danger_sprint` 1 (no cap at all there; 0 = the 6 m/s defend
cap, which closed only half the gap). Both [FH], off without rows.

| Ball wide | Real | Off | danger 40, defend cap | danger 40, sprint |
|---|---|---|---|---|
| 18-30 m: deepest / next defender | 16.9 / 18.3 | 21.0 / 23.8 | 19.1 / 21.6 | 15.1 / 18.1 |
| 18-30 m: defenders in the box | 1.61 | 0.63 | 0.95 | 1.51 |
| 0-18 m: deepest / next | 9.1 / 11.0 | 10.7 / 13.8 | 10.6 / 13.5 | 7.5 / 10.7 |
| 0-18 m: defenders in the box | 4.04 | 2.51 | 2.61 | 3.10 |

All of G5.9-G5.10 on (cross, drive, runs 3 / 2, defend the cross 18 m, danger 40
sprint), 64 matches: goals 4.6 (cross alone 5.2, none 3.35, pro 2.5), shots 13.0,
corners 1.15 (0.65), goal kicks 4.6 (3.65; pro 8.3), throw-ins 28.9; defenders in
the box 3.0-3.3 and the line 8.5 / 10.7-11.2 m, near real; attackers in the box
1.1-1.2 (real 2.2), the target zone 0.4-0.46 (real 1.1). Off-ball time at 5+ m/s 8.9%
→ 12.2% (real 6.3%), 16.0 → 16.75 km: the sprint back costs it.

Crosses still find a mate 42-45% (real 28%) and goals stay ~2 over pro. Not the aim:
`concept.cross.aim_spread_m` 5 (the cross played into an area) moved it 45 → 42%.
The box has nearly real defenders now and they still don't win the ball.

**Next (the mole):** what a cross meets — who wins it at its first touch (attacker,
defender, keeper; head or foot) and what follows, real (StatsBomb: the next on-ball
event after a cross, 40% clearance) v game; the aerial duel and keeper claim on a
lofted ball into the box. Nothing in §8.107 ships until crosses are as hard as real.

### 8.108 G5.11 — what a cross meets (IN PROGRESS; no migration, all off)

Real first touch after an open-play cross (StatsBomb PL 2015/16, 380 matches, 11.5
crosses a team; the first on-ball event after an incomplete cross, any team; scratch
`crfirst.py`, to fold into `benchmarks_statsbomb_cross.py`):

| Share of the cross's kind | Attacker | Defender, head | Defender, foot / recovery | Keeper | Out |
|---|---|---|---|---|---|
| High (68%) | 27% | ~33% (headed clearance 25%, attacker lost the duel 8%) | ~20% | 8.5% | 9.5% |
| Low (32%) | 29% | 2% | ~66% (clearance 35%, recovery 12%, interception 7%, pass 5%) | 3% | 2.5% |

The game (G5.9-G5.10 all on, 32 matches, the four PL fixtures, match_main `CROSS FIRST
TOUCH`; a header = the ball above 1.5 m the tick before):

| Run | Low: attacker / defence / keeper / out | High: attacker foot+head / defender head / defender foot / keeper / out | Goals | Shots a team |
|---|---|---|---|---|
| G5.10 (B0) | 52 / 17 / 5 / 26 | 40+9 / 15 / 15 / 6 / 15 | 4.5 | 13.0 |
| + `cut_share_box` 1 (B1) | 41 / 40 / 5 / 14 | 25+11 / 14 / 27 / 5 / 19 | 4.3 | 12.0 |
| + `box_reach_m` 1 (B2) | 20 / 65 / 4 / 10 | 20+5 / 8 / 48 / 5 / 15 | 3.5 | 12.0 |
| + `read_header` 1 (B3) | 25 / 62 / 4 / 10 | 15+8 / 17 / 34 / 7 / 19 | 3.9 | 11.4 |
| + aerial radius 1.5 (B4) | 23 / 60 / 1 / 16 | 15+7 / 17 / 39 / 5 / 19 | 3.6 | 12.1 |
| Pro | 29 / 68 / 3 / 2.5 | 27 / 33 / 20 / 8.5 / 9.5 | 2.5 | 12.9 |

**The low cross went through the box's men.** Per cross, the nearest defender to the
ball's flight below 1.5 m (`CF DIAG`): in B0, 37 low crosses that reached an attacker
or went out passed within 0.5 m of a defender, inside his control radius, at a
controllable speed. The cause is G5.4's `physics.tempo.cut_share` 0.1 (mig 941, a fit
for midfield interceptions): an outfielder in reach takes only a tenth of their moving
passes, in his own six-yard box too. Two [FH] params, both off without a row:

- `physics.tempo.cut_share_box`: the share inside his own penalty area (1 = every
  ball he can reach; no row = `cut_share`). Coaching: in the box, play the ball.
- `physics.tempo.box_reach_m`: his reach there for their ball (a leg out, a block),
  in place of the 0.5 m control radius. 1 m fitted: B1's remaining misses were 0.5-1 m.

Both together put low crosses at pro (attacker 20-25% v 29, defence 62-65% v 68) and
goals 4.5 → 3.5-3.9 (pro 2.5), shots flat.

**The high cross is won when it drops, not in the air.** `concept.meet-the-pass.
read_header` (the flight read takes the head-height point of a dropping ball, within
`physics.aerial.radius_m`; committed 460e8e2c) doubles defenders' headers, 8 → 17%,
but real is ~33%, and defenders still win 34-39% on the ground (real 20%). A 1.5 m
aerial radius changes nothing, so reach is not the limit: the defender isn't under the
ball at head height when it gets there.

**Next (the mole):** where the defenders are when a high cross comes down to 2.4 m —
distance to the drop point and to the attacker they are marking, real (DFL tracking
at the frame of a cross's first touch) v game. Then the cross count: 3.3-4.3 a team
v 11.5 real. Nothing in §8.107-8.108 ships until high crosses are as hard as real.

**G5.11 continued (same section): the high cross comes down where nobody is.**
Where the men are when a high open-play cross first comes down through 2.4 m inside
the box (`benchmarks_tracking_drop.py`, DFL, 22 crosses in 7 matches, thin;
match_main `HIGH CROSS FIRST DROP`):

| Nearest to the ball | Real | B3 (box rules + header read) | + lead 1.2, meet 2.0 (M1) | + need mate (N1) |
|---|---|---|---|---|
| Defender, median (4 m+) | 2.2 m (14%) | 3.5-6.6 m (41-75%) | 5.0-6.9 m (53-72%) | 3.1-5.3 m (38-71%) |
| Attacker, median (4 m+) | 3.2 m (45%) | 8.4-18.1 m (65-94%) | 10.9-14.0 m (60-84%) | 1.2-2.0 m (0-14%) |

Two faults in the cross itself, both [FH] params on `concept.cross`, off without rows:

- **It was aimed to bounce on the target**, so it passed head height 4-7 m short of
  him (traced: every lofted cross). `meet_z_m`: struck so its descent passes that
  height at the target — `BallFlight::carryToMeet`, the same tick law with drag.
  2.0 m puts the drop on the aim (median under 1.5 m off it).
- **It was aimed at where the man stood.** `lead_s`: every man, ours and theirs, read
  that far along his run when picking the mate with most room and aiming at him.

With both (M1): attackers' headers on high crosses 8 → 19%, defenders' 17 → 7%, out
25% (real 9.5%), goals 3.5. But 70% of high crosses still have no mate in the 3-13 m
zone even read 1.2 s ahead, and go to the empty 7.5 m spot. `need_mate` 1 (no man
to find, no cross) puts the attacker on the drop (1.2-2.0 m) and halves the crosses
to 1.8 a team (real 11.5): a real crosser has men to find. Box presence with the ball
wide 0-18 m: attackers 0.84-1.04 (real 2.18), in the target zone 0.25-0.30 (1.10),
defenders 2.2-2.6 (4.04).

**Next (the mole):** the box is empty, both sides, when the ball is wide near their
line — §8.107's open question, now the one blocking the cross. Who should be in it
(real: which positions, DFL by role) and why ours aren't (their jobs at that moment,
the pace caps, offside). Then need_mate, the cross count, and defenders marking the
cross's target.

### 8.109 G5.12 — the box is empty because the ball never gets to the byline (mig 1022; scratch DB only)

**Harness fault first: the scratch DB had no position numbers.** `fh_game_scratch`
(pg_dump of the club DB minus big-table data) had `formation_slot_roles` and
`positions` empty, so `Brain::numberOf()` was 0 for every slot in every scratch run
from G5.1 on: no back line (`backLine()`), no wingers or midfield pairs, no
position-by-position marking (§8.98), no role demands. Copied both tables from the
club DB into scratch. And the 4-4-2 had no rows even in the club DB: mig 1022 adds
them (RB 2, CBs 5/4, LB 3, RM 11, CMs 6/8, LM 7, strikers 9 and 10, numbering as mig
694) — Leicester City and Watford play it. Re-run of G5.10 (x4, 32 matches) with
positions: goals 4.5 → 4.6, shots 13.0 → 12.1, crosses and first touches within
noise, defenders in the box 2.2-2.6 → 3.0-3.6 (real 4.04). The G5.x conclusions stand.

**Second harness fault:** BOX PRESENCE (§8.107) and the new per-role lines sit inside
the possession-spell branch of match_main, which runs only while a man is ON the ball
(~29% of in-play time); real frames count the ball in flight too. Shares are still
comparable, seconds are not. The new zone line counts the last team on the ball in
play, as DFL flags it.

**Who should be in the box** (`boxrole.py`, scratch, to fold into
`benchmarks_tracking_box.py`; DFL, 5857 frames at 5 Hz, ball 0-18 m off the line the
side on the ball attacks, |y| 14+), share of each role's frames in the box:

| Role | Attacking: real | game | Defending: real | game |
|---|---|---|---|---|
| Striker | 62% | 15-31% | 12% | 4-6% |
| AM / 10 | 29% | 15-24% | 14% | 4-12% |
| Wide, far side | 36% | 8-21% | 31% | 8-22% |
| Wide, ball side | 21% | 11-19% | 16% | 2-5% |
| DM / CM | 12% | 5-12% | 40% | 40-50% |
| CB | 11% | 1-4% | 78% | 52-58% |
| Full-back, far / ball side | 5 / 6% | 0-3 / 4-8% | 68 / 39% | 61-66 / 15-21% |
| In the box, a frame | 2.18 | 0.86-1.24 | 4.04 | 2.95-3.25 |

The men are sent to the right places and are late. Out of the box, an attacking
striker's target is in it 80-91% of the time, 24 m from him; a defending CB's 71-78%,
18 m from him (`BOX BY ROLE`, target-in-box line).

**Because the ball doesn't stay there.** Possession by zone, last touch in play
(`zones.py` scratch, DFL; match_main `POSSESSION BY ZONE, last touch in play`; shares
of possession, game 2210 s a team-match in play v real 1580):

| m off their line | Real centre / wide | Game centre / wide |
|---|---|---|
| 0-18 | 3.0% / 5.3% | 1.3% / 0.7% |
| 18-35 | 3.7% / 9.5% | 4.7% / 4.2% |
| 35-70 | 15.6% / 28.1% | 33.4% / 31.4% |
| 70+ | 19.7% / 15.2% | 14.4% / 10.0% |

Final-third entries are at pro (40 v 44), so per entry: the last 18 m holds the ball
1.1 s (real 3.0 s), the wide final 35 m 2.6 s (real 5.3 s), and the game plays the
18-35 m centre instead (104 s v 58 s a team) — and shoots from it. The ball gets into
the crossing zone 3.5 times a team (real 21.7: carried 8.8, passed 12.9, 8.5 of them
from wide). Real attacks go wide and to the byline and stay there while the box fills.

Also seen: in play 73.7 min a match (real ~53): restarts are taken too fast.

**Next (the mole):** the attack doesn't go wide and deep. Passes into the channel
behind the full-back and wide carries to the byline, real (StatsBomb: pass end in
the crossing zone, from where, to a man running or standing; carries) v game: what
the man on the ball in the wide 18-35 m zone does next and who is there to receive.

### 8.110 G5.13 — the wide man plays it back: keep-it near their line (no migration; off without rows)

**What the man on the ball wide 18-35 m off their line does** (`benchmarks_statsbomb_wide.py`,
PL 2015/16, 380 matches; match_main `WIDE 18-35 ON THE BALL`; a spell = one man's time on
the ball that starts there in open play; §8.109 config `x6` + positions, 32 matches):

| | Real | Game (W0) | + keep-it final third (K1) |
|---|---|---|---|
| Spells a team-match | 57.8 | 23-27 | 20-25 |
| On it: s / m carried | 1.54 / 4.4 | 0.85 / 1.9 | 1.17 / 3.1 |
| Carried on into 0-18 wide first | 11% | 3-6% | 8-11% |
| Pass into the channel (0-18 wide) | 14.5% | 1.3-1.9% | 1.8-3.0% |
| Pass along (18-35 wide) | 30% | 9-10% | 8-11% |
| Pass inside (18-35 centre) | 10% | 11-14% | 11-15% |
| Pass into 0-18 centre | 6% | 3-5% | 4-6% |
| Back (to 35+) | 17% | 50-57% | 29-34% |
| Cross / shot | 7.0 / 2.2% | 4-7 / 0.5-1.9% | 6-8 / 1-3% |
| Lost | 13% | 10-13% | 22-29% |

Real by pressure (StatsBomb `under_pressure` on the release): unpressed (75%) channel 16,
along 33, inside 18, back 18, cross 8, shot 3, lost 4%; pressed (25%) channel 9, along 23,
inside 10, back 13, cross 3, shot 1, lost 40%. A real wide man never plays it back more than
18% of the time. In the game 85% of his passes were `play it back` (50%) or `recycle` (35%).
`play it back` is keep-it-under-pressure (G4.60): touch-tight, no pass on, go back or shield
back toward his goal. That's right in midfield. Wide near their line, a real pressed man takes
his man on and loses it 40% of the time.

**[FH] two params on `concept.keep-it-under-pressure`, off without rows:**
`final_third_m` (within that many metres of their line...) and `final_third_back_share`
(...only that share of the touch-tight-with-nothing-on calls still play back or shield; the
rest fall through to dribble / drive the line at his man; one roll per spell on the ball,
salt 209). Coaching: in the final third, attack your man 1v1. K1 = 35 m, 0.25.
Golden unchanged (no rows), 23/23 ctests.

K1 overall: goals 3.3 → 4.5, shots 11.7 → 13.9 (pro 12.9), entries 39.5 → 34.6, arrivals in
the crossing zone 3.4 → 5.3 a team (carried 1.9 → 3.3; real 21.7), last 18 m 44 → 54 s a team
(real ~132). The behaviour is right and ships with its rows when the cross does (§8.108).
Lost doubled, past real: the game's men are touch-tight far more often than real ones are pressed.

**Who is there to receive** (`benchmarks_tracking_channel.py`, DFL, 7 matches, 5 Hz, ball wide
18-35 m off the line its side attacks, last touch in play; match_main `BALL WIDE 18-35`):

| A frame | Real | Game (W1) |
|---|---|---|
| Attackers in the channel (0-18, |y| 14+, ball side) | 0.26 | 0.10-0.16 |
| Defenders there | 0.44 | 0.43-0.65 |
| Attackers / defenders in the box | 0.65 / 1.25 | 0.21-0.23 / 0.79-1.03 |
| Attackers ahead of the ball on its side (|y| 10+) | 1.41 | 0.86-0.99 |
| ...of them ST / WIDE / FB / DM-CM / AM | 0.32 / 0.49 / 0.18 / 0.24 / 0.14 | 0.15-0.19 / 0.31-0.37 / 0.07-0.13 / 0.12-0.15 / 0.11-0.17 |
| ...running 4 m/s+ at the line | 0.17 | 0.13-0.16 |

The sprinting runners are about at real. The men standing ahead of the ball aren't: a third
fewer, half the strikers, a third of the box. Their jobs: hold shape 40-47%, meet the pass 27-32%.

**Next (the mole):** the pass along and into the channel (real 45% of his releases, game ~12%).
The picker passes only to a man's feet (`want` 0 forward needs gain ≥ 3 m to a mate's spot,
recycle ideal 16 m), and with half the strikers and a third of the box ahead of the ball, there
are few feet to find. Next: where the striker and the far men stand when the ball is wide
18-35 (hold shape's targets v DFL), then the pass into space ahead of a man on the ball side.
Also the touch-tight rate itself (game v DFL nearest-defender distance on the ball wide).

### 8.111 G5.14 — the side in possession moves with the play, not with every pass (no migration; off without rows)

§8.110's mole was where the men ahead of the ball stand with it wide 18-35 m off their line.
New measures, both sides like for like (DFL 7 matches v the game, §8.110 config x6 + K1, 32
matches): `benchmarks_tracking_channel.py` / match_main `WHERE THEY STAND` (every man by role,
ball side / far side, metres ahead of the ball and across) and `offside line`;
`benchmarks_tracking_possession.py` / `POSSESSION SHAPE` (the side in possession by the ball's
10 m band, each line's gap from its middle, the middle by possession age, which smoothing of the
ball the middle follows); match_main `holding shape in possession` (how far a holder is off his
spot, how fast he closes it, by role).

**Ball wide 18-35, attackers (metres ahead of the ball):** ST +3.0 real, −5.6 game; AM −2.3 v
−9.2; far winger −1.2 v −10.0; full-backs −10 / −15 v −17 / −23; centre-backs −23.5 v −23.0. The
offside line was right (8.7 v 8.9 m ahead of the ball), so offside wasn't holding them back.
Their own spots were: ST +8.6 (capped at the line), AM +9, CB −15.7, and they stood 8-20 m behind
them. CBs looked right only because their lag cancelled a spot 8 m too high.

**Why they lag.** In possession 63% of holders were 10 m+ off their spot (18 m on average),
closing it at 2.8 m/s; at 5-10 m off they walked at 1.2. Their spot was 13-15 m off every role,
but its net offset was only 0-8 m ahead and 6-7 m across: **it jumped with every pass.**
`possessionX` put the shape on the ball itself at `ours_slope` 0.9 (raised from 0.45 in §8.102
to make up for exactly this lag, "a fit, not a measurement") and `possessionY` at 0.6 of its y,
so a 20 m pass moved every spot 11-18 m, and a man eased over `shape_tau_s` 4 under the 4.5 m/s
cap could never stand on it. The game's men ran more than real (2.9 v 2.49 m/s, 5+ m/s 12.3 v
6.3%) and stood in the wrong place. Real sides don't sprint up after a regain either (middle +1
m/s, 3-5% of men 5+ m/s forward; game the same), and the block without the ball stands where the
real one does at every band (middle 45.6 v 45.6 at ball 45-60). So the possession spot was the
mole, not pace and not the defending block.

**What the real middle follows** (possession frames, fit of the middle on an exponential
smoothing of the ball over T s):

| T | x slope | R² x | y slope | R² y |
|---|---|---|---|---|
| 0 (the ball) | 0.56 | 0.699 | 0.35 | 0.616 |
| 2 | 0.64 | 0.784 | 0.43 | 0.790 |
| 3 | 0.66 | 0.785 | 0.46 | 0.836 |
| 4 | 0.67 | 0.770 | 0.47 | 0.855 |
| 8 | 0.65 | 0.662 | 0.49 | 0.804 |

Each line v the middle, ball 25-75 m off their line: CB −13.9, FB −3.6, DM/CM −1.7, AM +7.5, WIDE
+7.9, ST +13.5 m. The full-backs push on to the middle's level; the centre-backs stay.

**[FH] three params, off without rows** (coaching: the team moves together with the play, not
with every pass; centroids move in phase with the ball [Frencken, Lemmink, Delleman & Visscher
2011]; the smoothing is fitted here):
- `physics.shape.ours_ball_tau_s` / `ours_ball_tau_y_s`: in possession the shape anchors on the
  ball smoothed over this long (x / y). One per team (`Brain::shapeBall`), stepped once a tick at
  the top of `ordersFaced`, in or out of possession, restarted on the ball after a gap; Fixed64.
- `physics.body.shape_tau_ours_s`: with our ball a holder closes the gap to his spot in this long,
  not `shape_tau_s` (which stays for the block without the ball, §8.103). The 4.5 m/s cap stays.
- `physics.shape.ours_push_{cb,fb,dm,am,wide,st}_m`: in possession each line (by position number)
  stands this much further up, on top of the formation's spacing × `ours_depth_k`.

Config E4 (on top of x6 + K1): `ours_ball_tau_s` 3, `ours_ball_tau_y_s` 4, `ours_slope` 0.75,
`ours_offset_m` 3.9, `ours_shift_y` 0.47, `shape_tau_ours_s` 1.0, push fb +4.2, cb −3.8, dm −2.4,
st +2.1 (the measured gap misses). The slope is above the fitted 0.66 because the realised slope
comes out lower (0.49): the final third still lags (below). Golden unchanged (no rows), 23/23 ctests.

32 matches (4 PL fixtures × 8), K1 → E4:

| | Real | K1 | E4 |
|---|---|---|---|
| Holders within 5 m of their spot | | 11% | 48% |
| Holders 10 m+ off | | 63% | 29% |
| Line gaps v middle CB / FB / ST | −13.9 / −3.6 / +13.5 | −9.0 / −7.1 / +12.1 | −12.7 / −4.3 / +11.9 |
| Middle, ball 60-70 / 90-100 off their line (m deeper than real) | | +4.1 / +8.2 | +1.6 / +3.0 |
| Full-backs, same bands | | +8.5 / +9.3 | +3.1 / +0.9 |
| Middle, ball 0-10 / 20-30 | | +4.9 / +6.8 | +6.3 / +7.2 |
| Centre-backs, ball 20-30 | | +2.3 | +7.4 |
| Ball wide 18-35: ST / AM / far winger ahead of the ball | +3.0 / −2.3 / −1.2 | −5.6 / −9.3 / −10.0 | −4.3 / −7.4 / −8.4 |
| Off the ball 5+ m/s / mean | 6.3% / 2.49 | 12.3% / 2.90 | 12.6% / 3.00 |
| Goals / shots a team / entries | 2.5 / 12.9 / 44 | 4.5 / 13.9 / 34.6 | 4.5 / 15.1 / 36.7 |
| Offsides a team | 2.0 | 2.0 | 2.7 |

The behaviour is right in our half: men stand on a spot that moves like the real side, the lines
are spaced like real ones, the full-backs push on. In the final third it isn't yet: the whole
side is still 6-7 m deep and the centre-backs got 5 m deeper (the smoothed ball trails a fast
attack; their lag used to cancel a spot that was too high). Ships with its rows alongside K1's
(§8.110) and the cross (§8.108).

**Next (the mole):** the front three in the final third. With the ball wide 18-35 the AM, striker
and wingers stand 9-16 m behind spots at or just inside the offside line, holding shape at the
4.5 m/s cap (speed 3.3, wish 0.49). Find what they did in the seconds before (come short /
support / meet the pass pulling them back), then whether the front line's hold has to be the
line itself (real ST 5-6 m off it), not the shape plus a cap. Then the centre-backs' height in
the final third with the smoothed ball (real 48.8 m off their line at ball 20-30, game 56.2).

### 8.112 G5.15 — without the ball the block stands 25 m deep, the 9 on their centre-backs (no migration; off without rows)

**The mole (§8.111's next).** With the ball wide 18-35 m off their line our front three stood
9-16 m behind their spots. A 3 s look-back (THREE SECONDS BEFORE, both sides) showed it isn't the
last seconds: the ball came as far as real (11 v 10.3 m), our men came *further* (+5-7 v +4-5),
but three seconds earlier they already stood 5-7 m too deep v the ball (ST +2 v +9.5). By
possession age (front men AM/WIDE/ST): at the moment the ball is won real front men stand +9.2 m
ahead of their middle, ours +3.6, their spot 20 m ahead of them — then they sprint (31% of them
over 5 m/s at 3-4 s, real 11%). The cause is the shape **without** the ball.

**DEFENDING SHAPE (new, both sides; metres from its own line by the ball's band).** Real (DFL,
ball 50-60 m out): CB 36.3, FB 40.3, 6/8 46.5, 10 55.4, 7/11 52.0, 9 61.6 — 25 m deep. Ours: CB
42.9, FB 46.4, 6/8 48.3, 10 49.3, 7/11 50.0, 9 53.2 — 10 m deep. A probe of the anchor after
decide's block rules showed why: CB, FB and 6/8 at the same height (37.7/37.9/37.1). The
back-line rule (every base at -55% or deeper is line-held) caught the 6 and 8 (bases -58 to -65)
and in a 4-4-2 the 7 and 11 (-55); everyone else stood on the kick-off base slid 25% of the ball
(anchorFor, cap 14 m) — the 9 15 m inside our half with the ball on halfway.

**Real model (benchmarks_tracking_possession.py, DFL, Bassek et al. 2025, CC BY).** The side
without the ball: its middle on the ball smoothed ~2 s — attack-direction slope 0.65, offset
-9.3 m (goal-side), R² 0.80 (raw ball 0.71); each line off that middle, ball 25-75: CB -10.7, FB
-7.0, 6/8 -0.9, 10 +8.6, 7/11 +4.9, 9 +14.5. [Frencken, Lemmink, Delleman & Visscher 2011; FH
coaching: "the block moves as one; the 9 stays on their centre-backs".]

**Built (Brain; all off without rows):**
- `defendingX` / `defendBallX`: without the ball, in open play only, a man's x = slope × the
  ball smoothed over `physics.shape.theirs_ball_tau_s` + `theirs_offset_m` + his line's
  `theirs_gap_{cb,fb,dm,am,wide,st}_m` (no number: the formation's own spacing); gated on
  `physics.shape.theirs_slope` > 0. Dead balls keep their shapes — on a kick-off the model put
  both 9s over halfway and nobody took it (a stalled match: 174 s in play; GAME_DEAD_TRACE dumps
  restart state and every man's job).
- `holdsLine`: with `physics.shape.back_line_by_number` the line rules hold the numbered back
  four (2-5, as backLine()) instead of every base at -55% or deeper.
- With the model on, a held line takes the deeper of its height off the ball and its spot in the
  block (real back lines drop further off the ball the further out it is: CB 1 m behind it 15 m
  out, 19 m at 55, 40 m at 95).
- `physics.shape.theirs_ahead_cap_m`: the compactness cap (nobody further upfield of the ball
  than 10 m) as a row — real 9s stand 28 m upfield of a ball in their own box.

Config F1 (on top of E4): theirs_slope 0.65, theirs_offset_m -9.3, theirs_ball_tau_s 2,
back_line_by_number 1, theirs_ahead_cap_m 30, gaps -10.7/-7.0/-0.9/+8.6/+4.9/+14.5.

**16 matches a config (4 PL fixtures × 4), E4 → E4+F1:**

| | E4 | E4+F1 | Real |
|---|---|---|---|
| front men ahead of the middle when the ball is won (0-1 / 3-4 s) | +3.5 / +6.7 | +8.7 / +10.5 | +9.2 / +9.9 |
| front men over 5 m/s, 2-3 / 3-4 s into the spell | 24% / 31% | 23% / 26% | 9% / 11% |
| defending, ball 50-60: CB / 6-8 / 10 / 9 off real | +6.7 / +1.8 / -6.1 / -8.4 | +5.0 / +2.7 / +1.3 / -0.7 | 0 |
| defending, ball 0-50: middle off real | +2 to +3 | +5 to +6 | 0 |
| possession, ball 90-100: every line off real | +0.5 to +6.4 | -0.6 to +1.1 | 0 |
| possession, ball 0-30: middle off real | +6.7 / +7.2 | +7.1 / +7.9 | 0 |
| offsides a team | 2.4 | 4.0 | 2.0 |

Goals 4.5 → 4.4, shots 15.2 → 15.4, passes 613 → 623, entries 36.3 → 39.2. Shipped as correct
behaviour: the block has its real depth and the front men start every attack where real ones do;
offsides went the wrong way (our front men now start higher, our defending lines are still high).

**Harness lines (match_main):** THREE SECONDS BEFORE (ball wide 18-35); front men by possession
age (ahead of the middle, forward speed, 5+ m/s, holders' spot ahead of them); DEFENDING SHAPE
by band with the shape anchor, the anchor after the block rules, holders' target / where they
stand / speed toward their own line, the order target, and their jobs with the ball 40-70.
DFL side: benchmarks_tracking_channel.py (THREE SECONDS BEFORE), benchmarks_tracking_possession.py
(front men by age, DEFENDING SHAPE, lines off the defending middle, its fit on the smoothed ball).

**Next mole.** The block in our half stands 5-7 m high (CB +5 to +7). Holders there trail their
targets 5-14 m, backing off at only 3-4 m/s: the hold move is `seek(…, 1/2)`, half speed whatever
brakeToArrive allows, and markers (mark tight 24%, protect the middle 18% of CB time) lift the
centre-backs 5 m over their block spot. Then offsides (4.0 a team v 2.0), and the final third in
possession (middle still 7-8 m deep).

### 8.113 G5.16 — a clean start: pro only, the 2015/16 Premier League (mig 1042; scratch)

James 11/4: "since we are now modeling that premier league season we should … not have lh but
actual teams from that year as the test cases … blow it all up. i believe in fresh clean starts
… all teams should be pro right now … we can keep the concepts though right? and skills etc".

**Gone (mig 1042):** every game team that isn't one of the 20 PL 2015/16 sides — Lighthouse
APSL, Ukrainian Nationals, Lighthouse XI, the curriculum sides (Sunday Albion, Harbor Athletic,
Minnows U10, Tide U14) — with their 132 players and all their rows; the team-kind models
(Lighthouse, Lighthouse APSL and its "shadow the line" / "preventive marking" variants,
Ukrainian Nationals); the APSL / CASA team records and division quality (game_team_strength,
a view over them, is empty with them); scripts/load_squads.py (it built only the LH and Ukies
squads). The default fixture is Leicester City v Arsenal; tests use PL names.

**Renamed:** "Semi Pro Standard" → **"Premier League 2015/16"**, the model all 20 sides play. Its
concept demands are still the semi-pro standard 4-2-3-1's: they are the next thing to derive from
PL data only, concept by concept (which of them the 2015/16 sides actually show, and how often).

**Kept:** the taxonomy (concepts, techniques, attributes, skills, principles, phases, roles,
officials, laws, sources, benchmarks), the global game-model params, formations, the concept code
— LH's own tactics included (pack the middle, lock the door, shadow the line, the 9's chill,
book-ends) as concepts nobody plays until a model's rows ask for them — the level code (for
scaling down later), and the school / federation / formation models as a library no team plays.
Earlier migrations (628-886) and git hold everything removed.

**Why it helps the model.** One league, one season, real pro sides only: every gap between the
game and the 2015/16 benchmarks points at the model — no semi-pro offset, no level ladder, no
club's own tactic to explain it away.

**Live.** Applied to fh_game_scratch only, with the other game migrations (919+) that live hasn't
had. On live it is safe (no PL teams there: the daemon falls back to its built-in squads) and
belongs in the same ship as the PL teams' load.

### 8.114 G5.17 — what the "Premier League 2015/16" model's demands actually move (no migration)

§8.113's next: derive the model's concept demands from PL data. A player plays min(demand,
ability) and `applies()` fires a concept that share of seconds, so a demand is right when the
game does the concept's act as often as the league. Two things first: which acts StatsBomb tags,
and which demands the engine reads.

**Real rates (benchmarks_statsbomb_concepts.py, StatsBomb PL 15/16, 380 matches, a
team-match):** pressures 151.8, counter-press 21.0% of them (StatsBomb's flag: within 5 s of the
loss); open-play passes 433.8: switches (≥ half the width, 34 m) 10.69, crosses 11.47, cut-backs
1.03, through balls 2.11; dribbles 18.05 tried, 10.59 completed; return passes (B's next pass
within 5 s goes back to A) 42.11 = 15.7% of passes made straight after a receipt; carries
gaining 10 m+ 34.64.

**Game (CONCEPT ACTS harness line, ownership-driven, the same cuts; K1+E4+F1, 8 matches):**
pressures 532 (closing at 1 m/s+ within 4.5 m, once a man a spell), counter-press 42%; passes
619; switches 28.1; crosses 2.9; cut-backs 0.75; return passes 5.5%; carries 10 m+ 6.8;
take-ons 113 tried (an opponent within 1.5 m goal-side in the carrier's cone). The raw pressure
and take-on counts are NOT comparable — the geometric cut is looser than StatsBomb's tagger —
so only shares and act-for-act counts are read: counter-press share 2x real, switches 2.6x,
crosses a quarter, return passes a third, 10 m carries a fifth.

**Which demands move anything.** Of the model's 186 demand rows the engine reads 78 (58 asked,
20 at 0 — man-mark, libero, cover-shadow, the LH tactics …); 108 are read by no code, 76 of
them with a demand that changes nothing (switch-play, drive-into-space, wall-pass, third-man,
compact-block, press-as-unit, beat-man-1v1, cut-back …). GAME_DEMAND (match_main,
"name=value,…", every model) A/Bs a demand without the DB:
- switch-play 75 → 25: byte-identical match (not wired).
- counter-press 85 → 40: share 42 → 41%; → 0: 38%. give-and-go 100 → 0: return passes
  5.5 → 5.1%.

So the acts come from other mechanics (whoever is nearest presses after the loss; pass choice
runs on the fitted rates of §8.102), and fitting demands alone can't close the gaps. Demands are
left as they are until a wired concept's act is shown to follow its demand.

**Next mole.** The carry: 10 m+ carries 6.8 a team-match v 34.6 (the man on the ball wide
carries 3.0 m a spell, §8.110; time on the ball 1.0 s v 1.47). Then crosses (2.9 v 11.5) and the
counter-press share after a loss.

### 8.115 G5.18 — a man on the ball keeps it as long as real players do, and runs with it (no migration; off without rows)

§8.114's next: 10 m+ carries 6.8 a team-match v 34.6.

**Real (benchmarks_statsbomb_carry.py, StatsBomb PL 15/16):** 353 carries a team-match, 5.3 m
long, +2.4 m toward goal, 1.80 s, 3.26 m/s moving; speed rises with length (1-3 m 1.64 m/s,
6-10 m 3.23, 10-20 m 3.94, 20 m+ 5.22); pressed carriers carry *further* (6.6 v 4.8 m in
midfield). Time on the ball, receipt to his next release: free 1.53 s (27.7% one-touch, 45.3%
inside 1 s, 73.0% inside 2, 92.1% inside 4); pressed at the receipt (9% of them) 1.11 s (43.6%
one-touch, 65.7 / 82.9 / 94.9%).

**Game (CARRIES harness line, a spell on the ball = a carry):** speed at each length was already
real (10-20 m 4.0-4.4 m/s); the spells were short — 0.95 s, 54% moving under 1 m (real 26%),
10 m gains 1.1% (real 9.6%). How spells ended v the hold drawn at the receipt (mean 1.64 s):
16% inside 0.1 s (a first-time hit), 28% before the hold ran out (a presser within 1 m), 40% at
it. The draw IS the real time on the ball — every receipt, first-time and pressed ones included —
so ending it again on a presser or a first-time wish counted the short end twice. And inside the
hold he moved at carry_share 0.15 of his wish (§8.102's fit on the mean carry): he stood on it.

**Built (World; all off without rows):**
- `physics.tempo.hold_one_touch`: the draw's one-touch slice (no hold); the rest of < 1 s is
  0.3-1 s.
- `physics.tempo.hold_pressed_{one_touch,under1,under2,under4}` + `hold_pressed_m`: a receipt with
  a man within hold_pressed_m draws from the pressed curve.
- `physics.tempo.hold_strict`: only a shot (or losing it) ends the hold early.
- `physics.tempo.carry_share` (existing) refitted to the carry, not its mean: 0.6.

Config H1C = hold_one_touch 0.277, hold_under1/2/4 0.453/0.730/0.921, pressed 0.436 /
0.657/0.829/0.949, hold_pressed_m 2.5, hold_strict 1, carry_share 0.6 (on K1+E4+F1).

**16 matches a config:**

| | before | H1C | PL 15/16 |
|---|---|---|---|
| 10 m+ carries a team-match | 7.1 | 35.4 | 34.0 |
| carry length / forward gain | 1.6 / +0.6 m | 3.4 / +2.1 m | 5.3 / +2.4 m |
| time on the ball | 0.97 s | 1.40 s | 1.47 |
| open-play passes | 623 | 540 | 378-434 |
| goal kicks / throw-ins a team | 5.2 / 34.6 | 8.2 / 27.3 | 8.5 / 23.1 |
| final-third entries | 39.2 | 48.7 | 44.4 |
| shots / goals | 15.4 / 4.4 | 24.8 / 7.2 | 12.9 / 2.5 |

Shipped as correct behaviour: the man on the ball now keeps it and carries it like a pro. What it
exposed is the defending — carriers reach shooting spots (shots 24.8) and get past men (take-ons
completed 28 a team-match v 10.6 real; the take-on cut is loose, §8.114), 11% of spells lost to
a man.

**Next mole.** Defending the carrier: who engages a man driving at the block, how close, and how
often a real carrier in that spot is stopped (StatsBomb Dribbled Past / Duel / Dispossessed v the
game's), then shots back toward 12.9.

### 8.116 G5.19 — the defence isn't behind the ball near its own goal (measure only; no engine change)

§8.115 left shots at 24.8 (real 12.9). First, what is comparable: harness spells are not
StatsBomb possessions (≈350 a match v 121 — StatsBomb merges brief touches), so the
spell-based lines (shot within 5 s of the spell 36% v 2.1%, own-third losses 27.6 v 2.1, spell
began within 35 m 40% v 5%) do NOT compare and are not used. The shot freeze-frame lines do:
0-2 defenders goal-side of the shooter 81% of game shots v 27.7% real; nearest opponent under
1.5 m 21% v 33.5%.

**Goal-side of the ball (new, both sides; DEFENDING SHAPE, outfielders nearer their own line
than the ball; DFL v K1+E4+F1+H1C):**

| ball m out | real | game |
|---|---|---|
| 10-20 | 3.60 (4+ 52%) | 1.57 (16%) |
| 20-30 | 4.83 (68%) | 2.53 (31%) |
| 30-40 | 5.59 (79%) | 3.43 (45%) |

By role (share goal-side), ball 10-20 / 20-30: CB 70/85% real v 38/51%, FB 53/70 v 32/45, 6/8
30/47 v 6/20, 7/11 20/32 v 3/8. The game's centre-backs caught upfield are mostly recovering
goal-side (40%), the full-backs 59%: the attack is already past them. Their holders stand 10-16
m off their spots there (wish 0.85, 4.5-5 m/s), CB targets were deep enough (13 m at ball 20-30).

Tried and removed: `danger_hold_wish` (a full-speed wish for holders with their ball inside
shape_danger_m) — goal-side 1.57 → 1.75 at 10-20, 2.53 → 2.40 at 20-30: not the limit, so it
isn't kept (no ghost knobs).

**Next mole.** Where the gap opens: the moment the ball first gets inside 30 m of our goal —
how it got there (a pass in behind, a carry past the line, a cross), how many of ours were
goal-side 3 s before, and where the back line stood then (DFL v game, the THREE SECONDS BEFORE
pattern of §8.112).

### 8.117 G5.19b — where the gap opens: carriers walk into the zone (measure only; no engine change)

§8.116's next. ENTRIES (new, both sides: the attacking side's ball, in play, first inside 30 m
of goal, re-armed once back past 40 m; ball speed at the entry under 7 m/s = carried, 12+ =
passed — DFL tracking has no event tag, so both sides use the speed):

| | game (K1+E4+F1+H1C, 8 matches) | DFL real |
|---|---|---|
| entries a team-match | 47.9 | 47.9 |
| ball speed at the entry < 7 / 7-12 / 12+ m/s | 59 / 30 / 11% | 28 / 34 / 38% |
| goal-side outfielders at the entry | 1.41 | 3.51 |
| their deepest outfielder at the entry | 28.0 m (level with the ball) | 23.2 m |
| 3 s before: ball / goal-side / deepest / the line | 45.7 m / 4.87 / 33.0 / 36.0 m | 50.1 m / 6.69 / 31.0 / 32.6 m |

The same number of attacks get inside 30 m, but ours are carried in, onto a back line that is
level with the ball when it arrives; real ones are passed in, with 3.5 men still goal-side.

Levers tried (8 matches each), none moved goal-side 3 s before (4.87): near-tight-far-zone 0
(4.46), push-up + line-step 0 (4.94), shape_tau_s 1 (4.81), shape_tau_s 1 + shape_max 7 (4.93);
with §8.116's danger_hold_wish that is five. Rule (memory): a symptom that resists two fixes gets
its actors measured before more rules.

**Next mole.** The carrier through the block: for carries that start 35 m+ out and end inside 30
— who engages him (nearest defender's distance and job along the carry), how many defenders
goal-side at its start are behind him at its end, and the real figure for the same carries from
DFL (carrier = the attacker on a slow ball).

### 8.118 G5.20 — the carry through the block: the marking layer, not the block, sets the centre-backs' height (measure only; no engine change)

§8.117's next. CARRY THROUGH THE BLOCK (new, both sides, positions only so they compare: carrier =
the attacker nearest the ball within 2 m at 5 Hz, the same man, up to 2 frames out of 2 m while it
stays within 4 m; a carry that starts 35 m+ out and gets inside 30 m):

| | game (K1+E4+F1+H1C, 32 matches) | DFL real |
|---|---|---|
| carries a team-match (share of entries) | 15.2 (32%) | 8.4 (17%) |
| time / metres toward goal / speed | 3.0 s / 12.6 / 4.2 m/s | 2.8 s / 13.5 / 4.8 m/s |
| defenders goal-side at its start / left behind / goal-side at the entry | 2.43 / 1.59 / 1.11 | 5.44 / 0.98 / 4.68 |
| nearest defender at its start / closest along it | 4.7 / 1.8 m | 7.1 / 3.2 m |
| a defender within 2 m (share of frames) / first man within 2 m: nobody, a CB | 26% / 30%, 35% | 10% / 69%, 4% |
| at its start, CB goal-side / metres goal-side of the ball | 52% / +1.3 | 94% / +11.7 |
| FB; DM/CM | 37% / −1.8; 19% / −6.9 | 81% / +7.2; 58% / +1.9 |

By possession age (side on the ball <3 s / 3-10 / 10+), real CBs stand +12.7 / +9.5 / +12.5 m
goal-side; ours +6.2 / −1.0 / 0.0. The gap is the SETTLED block, not the transition.

Why: the CB holders' target is right (after the block rules 30.5 m off the line with the ball 40-50
out, real CB 30.9) but they stand 38.5; with the ball 40-70 out 42% of CB time is marking (mark
tight 28%, protect the middle 14%). Their man, the attacking striker, stands 6.7 m deeper than
real (POSSESSION SHAPE, ball 40-50 from their line: 40.2 v 33.5) and is pinned there by the very
line that marks him — the pair sit 7 m up the pitch together.

Levers (8 matches × 4 fixtures each), goal-side at the carry's start (real 5.44):

| lever | goal-side | CB at ball 40-50 (v real) |
|---|---|---|
| none | 2.43 | +7.6 |
| theirs_ball_tau_s 0.5 / 1 | 2.70 / 2.52 | — |
| shape_danger_m 70 | 2.81 | +6.0 |
| shape_tau_s 1 + shape_max_mps 7 | 2.48 | +6.5 |
| ours_offset_m 7 / 9.5 (possession shape up) | 2.49 / 2.42 | +8.6 / +9.1 (their back line fixed, the striker stays pinned) |
| a marker capped at his block spot + 2 / + 5 m (tried, removed) | 3.14 / 2.99 | +4.2 / +5.1 |

`seek(…, 1/2)` (§8.112's "half speed") is a 0.5 m arrive radius, not a speed: misread.

**Decision (James 11/5): clean slate.** "we should not let old code get in the way … i would just
delete old code so it don't corrupt. concepts i think are more universal" and "it all needs to be
using state machines, oop … c++". The G4-era decision code in `Brain::decide` (a 2,146-line
priority chain; the defending branch alone ~760 lines: compactness cap, pre-offside depth cover,
swarm, press/chase, counter-press, recover, cover man, man-orientation marking) is deleted, not
gated or capped. Concept rows, coaching descriptions, citations and skill ratings stay as the
vocabulary; a concept's code is re-attached only when a measured gap asks for it, with numbers
fitted to 2015/16 (StatsBomb events) or pro tracking (DFL — Bundesliga; no public PL 15/16
tracking exists, so spatial behaviour is "pro tracking", never quoted as a PL figure). Kept: the
G5.9+ fitted work (F1 block shape, E4 possession shape, crosses, hold curves, carry_share).

Shape of the rebuild ([Buckland] state machines; §5.1 promised the team layer, never built):
team state machine = the phases of play (InPossession, DefensiveTransition, DefendingBlock,
AttackingTransition, SetPiece), minimum dwell; a state machine per player (State: enter / execute
/ exit, current + global); team → player assignment messages (who steps, who covers, who tracks
whom) [HELIOS marking]; concepts plug into states; machine state is part of the hashed world state
(determinism). Phase order: defending block → off-ball in possession → on the ball. Each phase:
delete the old branch, the new states with DB params, harness v real, commit.

**Harness lines:** CARRY THROUGH THE BLOCK (match_main, benchmarks_tracking_channel.py): count and
share of entries, time/metres/speed, goal-side at its start / left behind / at the entry, nearest
defender, frames with a defender within 2 m, first man within 2 m (role, goal-side or not) and his
job; at its start by role (goal-side share, metres goal-side), the same by possession age; CB jobs
at its start.

### 8.119 G5.21 — state machines, and out of possession rebuilt clean (no migration; code defaults = real data)

§8.118's decision, phase 1 of 3. James 11/5: "delete old code so it don't corrupt" and "it all needs
to be using state machines, oop … c++".

**State machines** ([Buckland] ch. 2 and Simple Soccer): `ai/StateMachine.hpp` — State (id, name,
enter / execute / exit; stateless singletons) and StateMachine (current, previous, global, the tick
it entered). `Brain::think(world)` steps every machine once a tick, lazily on the first
`ordersFor()` of the tick (every driver gets it; probes later in the tick — dead-ball set-up, the
harness — only read; a tick that goes backwards restarts them).

**Team layer** (`ai/TeamPhase`): the phases of play — in possession, attacking transition,
defending block, defensive transition, our / their set piece. Possession = the man on the ball's
side, a loose ball the last toucher's (as DFL flags it), a dead ball its taker's; a change of side
counts after `physics.phase.min_dwell_s` (0.3); a transition lasts `physics.phase.transition_s`
(6 — the "six-second rule" of Guardiola's Barcelona counter-press [Perarnau, Pep Confidential
2014], a coaching convention, not a fit). PHASES harness line: in possession 25.7%, transitions
14.9% each, set pieces 9.5% each (a team).

**Player layer** (`ai/DefendingBlock`): a machine per man; his team's phase and the team's
assignments pick his state each tick.

| state | what | params (defaults) |
|---|---|---|
| attacking | his team has it: the possession code (phase 2 rebuilds it) | — |
| hold the block spot | his role's real spot for this ball (below); across: defendingY | physics.block.<role>_<band> |
| press the ball | the ONE man who steps to their carrier — the nearest outfielder, held until another is switch_m nearer; stand_off goal-side of him on his line to our goal; in reach and goal-side he dives at tackle_per_s | physics.press.stand_off_m 3, switch_m 2, tackle_per_s 0.5 |
| chase the ball | his team's first man to a loose ball (the race read); on our own dead ball the taker (held restarts: restartTaker; kick-off / free kick: the nearest man) | — |

The block spot is data, not a rule: by role (CB 4/5, FB 2/3, 6/8, 10, 7/11, 9) and ball band
(0-10 … 90-100 m off our line, interpolated between band centres), the mean metres off his own line
a pro defender stands — DFL DEFENDING SHAPE (benchmarks_tracking_possession.py), in code as the
default, a DB row overrides. DFL is Bundesliga; no public PL 2015/16 tracking exists.

**Deleted** (~1,400 lines of Brain.cpp, 4,769 → 3,356): the defending chain in `decide` (compactness
cap, pre-offside depth cover, cover man, swarm, their-restart man-marking, hurry/pounce, pack and
trap, delay / organize / step, dive eagerness, counter-press, traffic tackles, recover, the
mark-assignment and mark-position / near-tight / one-spot / play-off marking), the post-pass
`trackRunner`, `hurryOrPounce`, `packAndTrap`, `oneSpot`, `holdsLine`, `interceptPoint`, and the
G5.15 fitted block (F1: `defendingX`, `defendBallX`, physics.shape.theirs_*, back_line_by_number) —
two block models is the corruption this removes. Concept classes and rows stay (the vocabulary); none
is wired to defending until a measured gap asks. `seek` moved to `ai/Steering.hpp`.
Kept: `defendTheCross` (G5.9, fitted), the keeper, restarts (`takeRestart`, `keepLawDistance`), the
body speed rules (shape_tau / shape_max / danger, G5.5 / G5.10).

Bug found on the way: `World::awardKickoff` leaves `restartSpot` stale, so `restartTaker` measured a
kick-off from the last goal kick — the taker ran at the ball, away from that spot, and "nearest"
flipped every tick (kick-off stalled for the rest of the match). The chaser now uses the ball.

**Result** (K1 + E4 + H1C, 4 fixtures × 8; C2 = the old chain):

| | C2 | G5.21 | real (DFL) |
|---|---|---|---|
| goal-side at the carry's start / at the entry | 2.43 / 1.11 | 3.10 / 2.38 | 5.44 / 4.68 |
| CB goal-side at the carry's start | 52% | 78% | 94% |
| defending shape, CB with the ball 40-50 / 50-60 / 70-80 out (v real) | +7.6 / +5.7 / +5.2 | +4.1 / +1.9 / 0.0 | 0 |
| nearest defender at the carry's start / a defender within 2 m | 4.7 m / 26% | 3.9 m / 35% | 7.1 m / 10% |
| first man within 2 m a CB / nobody | 35% / 30% | 40% / 20% | 4% / 69% |
| goal-side 3 s before an entry | 4.82 | 5.25 | 6.69 |
| goals / shots a match | 7.6 / 46.5 | 6.6 / 41.1 | — |

Tests: test_phases, test_defending_block (the spot is the table, mirrored; one sticky presser);
goldens re-locked.

**Next moles.** (1) The holders stand 4 m above their spots with the ball 40-50 out though the
spot IS real: the G5.5 / G5.10 body caps (shape_tau 4 s, shape_max 4.5 m/s outside shape_danger 40
m) trail an advancing ball — measure holders' lag v DFL defenders' speed toward their line by band.
(2) The presser stands too tight and is a CB 40% of the time (real: nobody within 2 m in 69% of
carries): fit who steps and from how far on DFL (nearest defender to the carrier by band and role).
(3) Phase 2: in possession, same treatment.

### 8.120 G5.22 — the whole old brain purged; in possession and the keeper rebuilt as player states (mig 1080, scratch)

James 11/5: "we need to again purge old stuff and start anew! this will cause less problems". His
calls: skills → real, from each PL player's own 2015/16 StatsBomb events; concepts → keep the
catalogue, delete the code; coach-style models → purge, PL 2015/16 only; approach → big bang now.

**Deleted (code).** Everything left of the old `Brain` that decided: the on-ball chain (pass ladder,
keep-it, shield, over-the-top, recycle, dribble rules, shot selection, cross / cut-back / clear rules),
meet-the-pass branches, the keeper's G4 craft, off-ball possession (support spots, give-and-go,
blind-side runs, overlaps, come-short, check-in, false-nine drop, width), the post-passes (rest
defence, unmark, stay-onside, defend-the-cross), the call system (talk/hear), the look-age vision
model, lapses / tendencies / habits / per-concept ratings and rolls / levels' brain noise, the
direct-opponent pairing, and all 49 concept classes (`Concept.cpp/.hpp`, 2,189 lines) with
`test_concepts`. `Brain.cpp` 3,356 → ~560 lines; the brain reads no concept, rating or level.

**Kept.** The engine (World, ball flight, bodies, officials, the laws), the state machines and
team phases (§8.119), the defending block (§8.119), and — moved whole to `ai/Reads` because they
are prediction, not choices — the race, pass and loft safety, get-in-line, chance quality and kick
aiming. Restart taking (G5.2: StatsBomb-sized throws and corners), the law's distance, the goal-kick
box, naming and weighting a pass to its man (G4.81-G4.95), brake to arrive and the DFL-fitted shape
caps stay in the façade. The World still holds a player's level as physics (kick error, control
speed, reaction): everyone pro until the StatsBomb skills land.

**New player states** (`ai/Players` = the shared agent, one Pick for every man; `ai/Possession`):

| state | when | what |
|---|---|---|
| OnBall | he has it | the World times the release (StatsBomb hold curves, physics.tempo.*); each tick his best action: shot (inside shot_max_m 25, chance quality ≥ shot_q_min 0.2 rad, or inside 9 m with any angle) at the post away from their keeper; cross (inside 20 m of their line, \|y\| ≥ 18) to the freest man attacking the box, else the spot; the best safe pass (progress − 0.15 × length; ground, a loft past 25 m; the race read says ours); a clearance in our 25 m (keeper: 55 m long); else carry at goal, off the nearest man |
| Support | ours, off the ball | his role's real spot by the ball's band — DFL POSSESSION SHAPE (metres off THEIR line), across slideY, no further on than their second-last man − 0.5 m |
| Receive | the pass is his and he gets there first | get in line (G5.5), else the race spot |
| Keeper | keeper, ball not his | on the ball–goal line, 1 m + 0.08 × the ball's distance (max 12); dives at a shot on target he can't run to |

Params: physics.support.<role>_<band>, physics.onball.*, physics.keeper.*, physics.receive.* (code
defaults = the numbers above; the on-ball ones are [FH] starting points to fit).

**Deleted (data, mig 1080, fh_game_scratch; the live game DB takes it with the PL load):** every
model demand (game_model_concepts 2,790, game_model_concept_params, game_model_role_concepts,
game_role_concepts 170, game_model_ladder 135), the concept classes' numbers (245 concept.* rows),
the 14 coach-style models (only Premier League 2015/16 stays), mig 762's "every model states every
concept" triggers, and the 2,670 `derived` (made-up) player attribute values. The three receive
numbers moved to physics.receive.*. Kept: the 186-concept catalogue (descriptions, sources,
measures, links), techniques, principles, phases, moments, the 34-attribute list, skill.* mapping.

**Server:** the brain no longer takes ratings, habits, ladders, tendencies, levels or direct pairs;
`setMatchSeed` replaces `setLevels`; the HUD's concept ratings stay the server's own read. The
dead-ball "markers start on their marks" placement (G4.63) is gone with the marking.

**Result** (K1 + E4 + H1C, 4 fixtures × 8, the DB before mig 1080; N2 = §8.119):

| | N2 | G5.22 | real |
|---|---|---|---|
| goals / shots a match (both teams) | 6.6 / 41.1 | 0.91 / 47.8 | ~2.7 / ~25 (PL 15/16) |
| passes / pressures / crosses / 10 m+ carries a team-match | 640 / 690 / ~0 / 13 | 647 / 636 / 0.2 / 13.9 | 434 / 152 / 11.5 / 34.6 (StatsBomb) |
| entries inside 30 m a team-match | 52.6 | 72.9 | 47.9 (DFL) |
| goal-side at the carry's start | 3.10 | 3.40 | 5.44 (DFL) |
| possession middle on the ball: slope / offset | 0.53 / 22.4 | 0.60 / 18.2 | 0.56 / 24.8 (DFL) |

It plays: 90 minutes, restarts taken, the block and the support shape at real spots. It doesn't yet
play like the Premier League — that is now a list of measured gaps on clean code. Goldens re-locked.

**Next moles** (biggest first). (1) Shots: twice the real count and a third of the goals — shot
choice by distance and angle v StatsBomb PL 15/16 shot locations and xG. (2) Crosses 0.2 v 11.5:
carriers never reach the wide zone (where real crosses start, StatsBomb). (3) Pressures 4×: the
presser stands 3 m off every carrier — stand-off and who engages, DFL. (4) Passes 1.5×: pass choice
v StatsBomb length / direction. (5) Skills: each PL player's attributes from his 2015/16 events.

### 8.121 G5.23 — the rest of the old game deleted: levels, sheets, models, phases, the old harness; protocol 2.0 (mig 1092, scratch)

James 11/5: "again all old parts need to go. we keep going over this lol". Rule from here: keep
only the engine and the laws, real data and the benchmark scripts, the concept catalogue rows, and
code written since the clean slate (G5.21+); everything else is deleted, not inventoried.

**Deleted.** `core/Levels.hpp` (the u10 → world ladder, swarm, decision jitter, talk / listen dials,
concept abilities, preset overlays), `core/Skill.hpp` (attribute → physics bending),
`core/PlayerSheet.*` + `persistence/SheetStore.*` + `fh-game-roll` (character sheets),
`core/ConceptRegistry.*` (the curriculum in code), `fh-game-calibrate`, `scripts/draw_bodies.py`,
tests test_player_sheet / test_player_attributes / 8 server tests for removed features. The
server's levels, per-player ratings and attributes and their live edits, game models / demands /
params, phases of play and corner shapes (GameServer 1,017 → 444 lines). Persistence loads only
formations, teams (names, positions, kits, top speed), officials, admin ids, physics params and
benchmarks. The harness `fh-game-match` was rewritten lean (3,519 → ~520 lines): only lines with a
real figure — result, SHOTS (new: by distance, how each ended), CONCEPT ACTS, PHASES, ENTRIES, CARRY
THROUGH THE BLOCK, DEFENDING / POSSESSION SHAPE (+ the middle's fit). The overlay vocabulary
`Why` 84 → 17 names (what the clean states decide); `Orders` lost rung / read / vision / calls.

**Skill = physics, one block per player** (`core/PlayerSkill`): perception delay, kick and shot
error, control speed, tackle success, keeper fumble, kick range, cut-out control, the control
touch. A bare World is `PlayerSkill::perfect()` (engine tests stay independent); the server sets
everyone from physics.skill.* rows, defaults = the old "pro" band's [FH] numbers until fitted to
StatsBomb. Hashed per player. Correction (§8.120 called them "made up"): the 2,670 `derived`
attribute values were each PL player's own 2015/16 StatsBomb event rates ranked in his position
group (load_pl1516.py) — only their 0-100 spread was [FH]. Nothing is lost (scratch only; the
script regenerates them); the skills step maps those per-player rates straight onto PlayerSkill.

**Protocol 2.0** (`PROTOCOL.md`): frames 0x32 0x33 0x35-0x37 0x3A 0x3E-0x44 retired; SNAPSHOT
drops the level ids, ROSTER the ratings, BRAIN the rung / vision / call blocks; subprotocol
`fh-game.v2.bearer.<JWT>` so a 1.x client is refused, never desynced. The 2.0 browser client is
staged in `game/ship/frontend/` — the live `frontend/` is served straight from the repo and the
live daemon still speaks 1.x (editing the live client broke /game.html for ~10 minutes; reverted).
`game/ship/README.md` is the one-step ship: live DB migs, daemon, client, the club backend's
attribute endpoint.

**Deleted (data, mig 1092, fh_game_scratch):** game_phases + game_phase_positions (152 hand-placed
marks), game_direct_opponents, the sheet tables (game_sheet_tables, _position_profile, player
rolls / history / techniques), and 82 skill.* / sheet.* / technique.* params.

Tests 22/22; goldens re-locked (the hash mixes every player's skill).

### 8.122 G5.24 — shots: the real shot policy (mig 1093 = the fitted numbers as rows, scratch)

**Real** (benchmarks_statsbomb_shots.py, StatsBomb PL 2015/16, penalties out): 12.9 shots a
team-match, 1.20 goals, 9.3% scored; by distance <12 / 12-18 / 18-25 / 25+ m 31 / 26 / 30 / 13%,
scored 18.0 / 9.3 / 3.6 / 2.0%; ended goal 9.3%, keeper 23.1%, blocked 29.3%, off target 38.3%.
The decision: of the balls let go in open play at a spot, the share that are shots —

| distance \ goal angle | < 0.25 rad | 0.25-0.5 | 0.5+ |
|---|---|---|---|
| < 12 m | 29.3% | 77.8% | 92.2% |
| 12-18 | 8.2% | 61.0% | 67.5% |
| 18-25 | 6.6% | 35.8% | — |
| 25-35 | 1.8% | 18.3% | — |

**Change.** OnBall's guessed rule (inside 25 m with chance quality ≥ 0.2 rad) is replaced by that
table (physics.shot.p_<band>_<angle>): one roll per spell (on the tick he got it) against the share
for the spot he lets it go from — the World's release timing decides when. Harness: the SHOTS line
(by distance, how each ended) and the share of balls let go that were shots, by distance.
Mig 1093: the 17 fitted numbers the clean game reads (StatsBomb hold curves, carry share, cut-outs;
DFL shape pace and slide) were harness config only — now game_model_params rows.

**Result** (4 fixtures × 8): the shot share by distance is now real-shaped (85 / 74 / 38 / 5% v 87 /
44 / 23 / 3%); shots 24.1 → 19.0 a team-match (12.9). Scored 3.9% (9.3), keeper 57% (23), blocked 7%
(29). (Fixtures with the same formations now play identically: every player has the same skill
until the skills step.)

**Next moles.** (1) Where the ball goes: releases inside 12 m 1.0 a team-match (real 4.6), 12-18
2.2 (7.7), but 25-35 m 146 (44) — the attack circulates outside the box, crosses 0.6 (11.5).
(2) Shots don't score: the keeper keeps 57% (23%) and almost nothing is blocked (7% v 29%) —
shot and keeper skill, the bodies between. (3) Pressures 4×, passes 1.5×.

### 8.123 G5.25 — the pass policy and the press distance from real data (no migration)

**Pass policy** (benchmarks_statsbomb_passes.py, StatsBomb PL 2015/16 open play, 377.7 attempted a
team-match, 79.1% completed, 23.2 into the box from outside it): the pitch in 10 zones (their line
0-18 / 18-35 / 35-52 / 52-70 / 70+ m × centre |y| < 20.16 or wide); from each origin zone the share of
passes ending in each zone, and the share lofted and crossed. OnBall's guessed pass score (gain −
0.15 × length) and its hand cross rule are replaced: each mate is weighted by the real share from
this zone to his, split among the mates standing there; a pass the race read says we win (ground,
else lofted) keeps its weight, one it says they win keeps physics.pass.risk_weight of it ([FH] 0.25,
to fit to 79.1% completion); one roll a spell picks; a ball into the box from wide goes in the air at
the zone's crosses ÷ its passes into the box, any other at the zone's loft share. Params
physics.pass.to_<o>_<d>, loft_<o>, cross_<o>, risk_weight.

**Press distance** (benchmarks_tracking_press.py, DFL: the nearest defender to the man on the
ball, by the ball's metres from their line): median 2.1 / 3.0 / 3.9 / 5.5 / 8.0 m (0-18 … 70+); the
presser's stand-off (was 3 m everywhere) is a roll a spell between that band's p25 and p75.
Game after: 2.1 / 2.9 / 3.4 / 4.4 / 7.9.

**Fixed:** a keeper never took the ball played back to him (Pick put the keeper state before the
loose-ball man) — 11 of 16 goals in a 3-match run were own goals from passes rolling past him.
DefendingBlock / Possession load their real tables at construction (a Brain without
setModelParams, the tests, had zero tables and sent everyone to a goal line).

**Harness:** goals by the last kick before them (own goals), passes completed, PASS POLICY as
played (the StatsBomb grid), NEAREST DEFENDER by band.

**Where it stands** (3 matches, Leicester v Arsenal): passes 728 a team-match (377.7), completed 90%
(79.1); 0-1 goals a match. The mole the grid shows: from 18-35 m central real passes go into the box
32% of the time (21.3 central + 10.5 wide), the game's 0.8% — nobody is in it. The support spots are
real MEAN positions (a 9 averages ~22 m out with the ball 25 m out), and a mean has no runs.

**Next mole.** Runs into the box: how many attackers are in the box (and the box channels) by where
the ball is, from DFL, and who makes the run — a Run state that takes the man there.
Tests 22/22 (the 3-minute flow check widened to the last 3 s); goldens re-locked.

### 8.124 G5.26 — runs into the box (DFL box occupancy); the attack still can't get there

**Real** (benchmarks_tracking_box.py, DFL: the side in possession's outfielders in the box zone, 0-18
m off their line with |y| < 20.16, by the ball's zone): ball 0-18 central 3.45 (3+ in 69% of frames),
0-18 wide 2.29, 18-35 central 1.04 (none 60%), 18-35 wide 0.79, 35-52 0.13 / 0.09; mostly the 9
(0.40 with the ball 18-35) and the wide men (0.23); standing 11-15 m off the line, |y| 6-8 m.

**Change.** A team assignment (Possession::assignRunners, in Brain::think): with our ball inside 52
m of their line, how many go into the box is drawn from the real 0 / 1 / 2 / 3+ shares for the ball's
zone, re-drawn when it changes zone or every 3 s; who goes by the real mean count for his role ÷ the
men of that role in the team (nearer the box first among equals). A new player state AttackBox (why
"attack the box") takes him to the real depth and width for that zone, ball side first, then the
far side, then the middle — no further on than their second-last man (Law 11). Not capped as a
shape move. Params physics.box.k_<z>_<n>, role_<z>_<role>, depth_<z>, abs_y_<z>.

**Harness fix:** DEFENDING SHAPE banded the ball off the wrong goal line since the lean rewrite
(§8.121) — those tables were flipped; now right, with the holders' targets and their speed back.
New lines: IN THE BOX by the ball's zone (with the runners and their targets).

**Result** (1-3 matches): runners are assigned at about the real rate (0.6 with the ball 18-35 m out)
but stopped at their offside line — our defending line with the ball 20-30 m out stands 22.2 m
(target 20.5, real CB 19.6): legitimate. The ball itself hardly gets there: frames with it inside 20
m of the defenders' line 121 v 2,551 at 30-40 m (DFL 10,418 v 10,255).

**Next mole.** Getting in behind: every pass goes to where a mate stands, and nobody runs as it is
played. Real attacks get into the box with passes into space ahead of a runner timed against the
line (through balls, runs in behind, crosses to arriving runners): measure on DFL the runners'
speed and line-gap at the moment of a forward pass, and on StatsBomb the through balls; then a run
state that times the line and a led pass.

### 8.125 G5.27 — the ball in behind (DFL); a ball nobody could reach sat there for good (no migration)

**Real** (benchmarks_tracking_behind.py, DFL, 7 matches; every open-play pass naming the man it was
FOR — completed or not, 5,095): a ball is IN BEHIND when he meets it (the ball's nearest point to
him in the next 4 s) past their offside line as it stood at the kick (Law 11: second-last of theirs,
keeper in; or halfway; or the ball). 37.7 a team-match = 10.4% of passes, completed 47.5%, 58% in
the air. At the kick he stands 2.0 m short of the line (p25 0.1, p75 5.1), moving 3.8 m/s, 2.7
toward goal; he runs 10.2 m to it (7.9 forward); the ball takes 2.8 s, 24.6 m; met 5.2 m past the
line (p25 2.6, p75 9.7), 23.2 m off their line. By his gap short of the line, the share of passes for
him that go in behind: 0-2 m 50%, 2-4 32, 4-6 22, 6-8 18, 8-10 12, 10-12 7, 12-14 5, 14-16 3, 16-18 2.
By origin zone 22% (0-35 m central) down to 6% (own half). Runners sprinting at the line as the ball
is played are rare (0.06 a forward pass): the ball is played into space for a man near the line.
PL cross-check (StatsBomb 15/16, its narrower "through ball" flag): 2.1 a team-match, 34% completed,
24.9 m, ending 14 m off their line.

**Change.** OnBall: every pass for a mate short of their line splits by the real share for his gap
into the ball to feet (the pass policy, as before) and the ball IN BEHIND (new Why "ball in behind"):
into the space a real roll (p25-p75) past the line on his line of run; on the ground weighted to
arrive as his run does (his body's run time to the spot → the rolling ball's v0 → carry), in the air
at the real 58% (or whichever the race read says we win; else at risk_weight). Receive: a ball in
behind for him — he runs on to its spot while it is behind him and its roll gets there (it used to
take the earliest point of its line: he stepped back to it short of the line), and Pick keeps him on
it while it is loose even when their man is first on the race read. Params physics.behind.gap_<m>,
past_p25_m / past_p75_m, air, lead_s ([FH] 1 s of his across drift).

**Fixed — a frozen match.** A loose ball come to rest where nobody of either side can get to it
inside the race read's 3 s horizon had no chaser: it sat by the corner flag from minute 6 to full
time (club-DB params, seed 1000; HEAD too). Now our nearest man goes (DefendingBlock::assign).

**Harness:** IN BEHIND (count, share, completed, in the air, the medians above, by origin zone, the
man's gap distribution against DFL's, runners at the line), the led balls; GAME_BEHIND_TRACE (each
led ball tick by tick), GAME_PLAY_TRACE (the ball every 10 s). **Run it on the scratch DB**
(`POSTGRES_DB=fh_game_scratch game/scripts/match.sh …`): the club DB has 17 physics rows, not the
89 fitted ones (no hold curves, no carry share) — a first pass of this slice was measured there by
mistake and read passes 2.4× real.

**Result** (8 matches, Leicester v Arsenal, fh_game_scratch; in-behind off → on):

| | off | on | real |
|---|---|---|---|
| balls in behind a team-match | 7.9 | 24.9 (32.6 led) | 37.7 (DFL) |
| completed / in the air | 44% / 10% | 49% / 37% | 47.5% / 58% |
| his gap at the kick / speed / toward goal | 3.0 m / 3.7 / 2.5 | 3.2 m / 3.1 / 1.4 | 2.0 m / 3.8 / 2.7 |
| he runs to it / met past the line | 5.9 / 1.6 m | 8.7 / 3.3 m | 10.2 / 5.2 m |
| met, metres off their line | 36.3 | 34.0 | 23.2 |
| entries inside 30 m | 23.2 | 30.9 | — |
| shots a team-match / scored | 4.9 / 2.5% | 5.9 / 4.3% | 12.9 / 9.3% |

The men's gap to the line is now real-shaped (it was the club-DB run that piled them at 16-18 m).
Tests 22/22; goldens re-locked.

**Next moles.** Pressures 500 a team-match (151.8, 3.3×), take-ons tried 118 (18.1, 6.6×),
passes 694 (433.8, 1.6×), completion 87% (79.1): bodies on the man on the ball far too often. Shots
don't score: keeper 62% (23.1), scored 4.3% (9.3).

### 8.126 G5.28 — the ball is dead as long as a real match's: fouls and free kicks (Law 12); detNoise was correlated (no migration)

**Why.** §8.125's "pressures 3.3×" came from comparing the harness's own cut (a defender within 4.5
m closing at 1 m/s+, once a spell) with StatsBomb's hand-tagged pressures. Measured the same cut on
DFL (benchmarks_tracking_pressure.py): 375 pressures a team-match = **0.59 a spell on the ball — the
game's 0.54**. Take-ons by the same cut: 44 (game 141). What was 1.6× was the number of spells
(1,021 v 640), as were passes (694 v 434): **the ball was in play 87% of the match, real 55.2%**
(benchmarks_tracking_dead.py, DFL, 52.7 of 95.5 min).

**Real dead time** (DFL, each dead spell named by the restart that ends it; a team-match, median
s): throw-ins 19.9 / 13.8; goal kicks 7.1 / 23.2; corners 3.2 / 32.8; **free kicks 10.5 / 32.5
(28% of all dead time)**; kick-offs 1.0 / 64.2 (after goals: the celebration); penalties 0.2 / 119;
other (drop balls, injuries, VAR) 8.0 / 18.4. The game had no fouls at all. **Fouls** (StatsBomb PL
15/16, sb_fouls): 12.52 a team-match (advantage played on 1.73), by the fouler's own third / middle
/ their third 2.78 / 6.71 / 3.02; tackle duels 10.30 / 7.82 / 2.20; penalties 0.12; yellow cards
1.34.

**Change (World, Law 12).** A challenge (a tackle on the man on the ball, in reach) is a foul at the
real share of a team's challenges that are fouls in that third — fouls ÷ (tackle duels + fouls):
21.3% / 46.2% / 57.9% (physics.foul.p_own_third / p_middle_third / p_their_third). The referee plays
advantage at 13.8% (physics.foul.advantage: the carrier keeps it); else a free kick to the fouled
side where it happened (MatchEventType FreeKick 12; Foul 11 either way), dead for a real roll
between DFL's p25 and p75 (20.5-43 s, physics.restart.free_kick_dead_p25_s / _p75_s), then taken as
an offside free kick is (the law's 9.15 m). The kick-off after a goal waits a real roll too (35.7-76.1
s, goal_kickoff_dead_*). Not yet: a foul in the fouler's own penalty area would be a penalty — none
are given there until penalties exist; cards.

**Fixed — detNoise rolls were correlated.** The FNV-1a hash mixes the channel last, and its top bits
(the ones used) barely moved with it: on one tick for one man the tackle-won roll (ch 6) and the
clean-win roll (ch 14) correlated r = 0.81, the shot roll (40) and the pass pick (41) 0.36. Seen as
tackles won collapsing 13.1 → 1.6 in midfield once the foul roll (ch 15, r = 0.38 with 6) took them.
Now the splitmix64 finalizer [Steele, Lea & Flood 2014] avalanches the hash: every pair |r| < 0.02.
Deterministic as before; every roll in the game changes.

**Harness:** BALL IN PLAY and dead time by restart (real DFL alongside), TACKLES by third won / lost
and fouls, THE DFL CUT (spells by proximity at 5 Hz, pressures and take-ons by the real cut, by the
carrier's metres off their line), pressures by the presser's state.

**Result** (8 matches, fh_game_scratch, both with the noise fix; fouls off → on):

| | off | on | real |
|---|---|---|---|
| ball in play | 87.3% | 76.9% | 55.2% (DFL) |
| fouls / free kicks a team-match | 0 / 0 | 12.1 / 10.5 | 12.5 / 10.5 |
| free kick dead, median | — | 31.7 s | 32.5 s |
| passes a team-match | 693 | 619 | 434 |
| spells (the DFL cut) | 1,017 | 888 | 640 |
| pressures a spell | 0.54 | 0.54 | 0.59 |
| shots / scored | 7.4 / 6.8% | 5.4 / 9.2% | 12.9 / 9.3% |
| in behind a team-match | 25.1 | 21.3 | 37.7 |

Tests 22/22; goldens re-locked. Client: Foul 12 toasts "Foul — free kick home/away" (staged ship
client; PROTOCOL §7 event types 8-12 listed).

**Next moles.** (1) The rest of the dead time: goal kicks 1.1 a team-match (7.1) and corners 0.1
(3.2) — the ball almost never reaches their byline; the "other" stoppages (8 × 18 s). (2) Where
the ball is: pressures with the carrier 35-52 m out 198 a team-match (89), inside 18 m 3 (41) —
the attack lives in midfield. (3) Take-ons by the real cut 121 (44): a defender goal-side within 1.5
m twice as often a spell as real.

### 8.127 G5.29 — he carries it until he lets it go, and the kick goes where he aimed (no migration)

§8.126's next: the byline (goal kicks 1.1 a team-match v 7.1, corners 0.1 v 3.2), the attack in
midfield.

**Real.** Where the ball is (DFL, benchmarks_tracking_possession.py, the side in possession, frames
by the ball's 10 m band off their line, 0-10 … 90-100): 3.6 / 5.8 / 7.6 / 9.3 / 11.3 / 13.0 / 14.4 /
12.7 / 10.1 / 12.1%. The game: 0.1 / 0.8 / 4.3 / 10.7 / 21.7 / 19.8 / 17.4 / 11.4 / 8.2 / 5.3% — two
thirds of it in the middle 30 m. Carries 10 m+ 7.8 a team-match (StatsBomb 34.6). What put the ball
over the byline (benchmarks_statsbomb_out.py, PL 15/16): goal kicks 8.3 a team — a shot 4.28, a pass
2.65 (2.18 in the air), a miscontrol 0.64, a block 0.39; corners 5.4 — a clearance 1.38, a block
1.34, a shot 0.92, a keeper's save 0.60.

**Found.** Since G5.22 OnBall chose its pass on receipt and then *walked at the man* it was for (seek
at 0.1) until the World's hold let it go; the carry at goal (step 5) ran only when no pass was on —
almost never. He stood on it. Moving his run to the carry (at goal, off the nearest man within 4 m)
showed why the walk was there: the World kicks along the move intent (a human's push-and-press), so
the carry became the pass's direction — passes left at the byline, 13.2 goal kicks a team-match
from them (2.65 real). That first run looked like territory fixed; it was misdirected balls.

**Built.**
- OnBall: whatever he has chosen (pass, ball in behind), until the release he carries — `carryDir`,
  the step-5 carry as a helper.
- World::setAction takes an aim (the point he kicks at, latched with the action); the kick leaves at
  it from where he stands at the release. GameServer passes the order's target for the brain's
  kicks (ground, short, lofted, shot); a human's press has no aim and still kicks where he pushes.

**Harness:** goal kicks and corners by what put the ball out (the last kick's why, or carried out),
StatsBomb alongside; GAME_OUT_TRACE prints each such kick (why, action, from, target, receiver,
velocity); DEFENDING SHAPE adds "holders at" — where the men holding the block spot stand v their
target.

**Result** (8 matches, fh_game_scratch; before → after):

| | before | after | real |
|---|---|---|---|
| carries 10 m+ a team-match | 7.8 | 21.9 | 34.6 |
| passes a team-match | 619 | 580 | 434 |
| spells on the ball (the DFL cut) | 888 | 850 | 640 |
| shots a team-match | 5.4 | 8.1 | 12.9 |
| goal kicks / corners | 1.1 / 0.1 | 2.3 / 0.0 | 7.1 / 3.2 |
| ball in play | 76.9% | 72.4% | 55.2% |
| free kicks | 10.5 | 13.9 | 10.5 |
| ball 0-30 m off their line | 5.2% | 8.6% | 17.0% |

Scored 3.9% of shots (9.3%) on 0.31 goals a team-match — 8 matches, noise, but keepers save 65%.
Tests 22/22; goldens re-locked.

**Next moles.** (1) The block doesn't reach its own spot: the men holding it stand 2-3 m off their
target at every band (ball 40-50 m out: FB 37.3 v 34.4, ST 58.0 v 55.9), and with the ball deep in
the other half the CBs stay at 49.5 m v 60.7 — the line is compressed, too high near its goal (CB
+3.7 m at band 20-30) so our runners are held onside outside the box (in it 0.03 v 1.04 with the
ball 18-35 out), too low far from it. At their goal kicks they do reach it — the lag is in play.
(2) Crosses 0.1 a team-match (11.5): passes from 0-18 wide 0.6 (18.6). (3) Corners 0 (3.2): no
clearances or blocks out in their box. (4) Take-ons by the real cut 114 (44).

### 8.128 G5.30 — the block shifts on where the ball is going and runs with its spot (no migration)

§8.127's next: the block doesn't reach its own spot in play (2-3 m off at every band).

**Measured first.** Against the real table (DFL, `kRealSpotDm`, all the side's outfielders by
role and the ball's 10 m band) the block was not trailing evenly: it stood **2-3 m upfield** of
real at bands 20-80 and 5-8 m upfield at 0-10, and 5-8 m too deep only with the ball at their goal
(mean |error| 3.12 m over 60 cells). A GAME_HOLD_TRACE of the holders found three causes:
1. **The spot followed the ball where it was.** 57% of holder frames have the ball loose (a pass
   in flight); each pass moved every spot after the ball, not when it was kicked.
2. **Pursuit, not tracking.** A holder closes his gap at gap/τ (`shape_tau_s` 4) and never takes on
   his spot's own velocity, so he trails a moving spot by its speed × τ. In a possession the ball
   mostly comes toward the defending goal, so the trailing man is upfield of his spot.
3. **The recovery after a turnover is at the jog cap** (4.5 m/s, §8.103/§8.104): the men 4-28 m off
   their spot were running back at it.

**Real recovery** (new `scripts/benchmarks_tracking_recover.py`, DFL 7 matches, the side without the
ball, outfielders, 0.2 s steps, by seconds since it lost it). Columns: share of steps at 5+ m/s
running back (the back component 0.7+ of his speed), and mean back m/s:

| s since lost | real 5+ back | real back m/s | game before | game after |
|---|---|---|---|---|
| 0-2 | 1.9% | −0.12 | 4.8% / +0.45 | 3.6% / +0.29 |
| 2-4 | 5.2% | +0.79 | 5.2% / +1.18 | 5.4% / +1.34 |
| 4-6 | 7.4% | +1.16 | 4.6% / +0.93 | 5.6% / +1.16 |
| 6-10 | 7.2% | +1.18 | 4.3% / +0.75 | 4.3% / +0.73 |
| 10+ | 3.7% | +0.71 | 4.2% / +0.30 | 4.0% / +0.35 |
| all: under 2 / 2-5 / 5+ m/s, mean | 41.9 / 50.3 / 7.9%, 2.61 | | 46.6 / 43.0 / 10.4%, 2.51 | 42.3 / 47.6 / 10.1%, 2.59 |

Real sides don't drop in the first 2 s (the counter-press) and keep retreating hard from 4 to 10 s.

**Built.**
- `PlayerView::ball_to` (Brain::viewOf): a free ball in play, the point where the race read's first
  man (either side) takes it; else the ball. The block spot's depth and its slide (`slideY`) read
  it, so the block shifts while the ball travels. Coaching: "move while the ball is moving" [FH];
  real centroids move in phase with the ball [Frencken, Lemmink, Delleman & Visscher 2011].
- `Brain::blockLead`: the block spot's own velocity, (the spot for the ball 0.2 s on along their
  carrier's run − the spot now) / 0.2 s; only holding the block with their man carrying it in play
  (a free ball's spot is its meeting point, which stands still). `brakeToArrive` composes it:
  he runs at the lead + the gap closed over τ, capped at the shape's pace (the defending pace in
  danger) — tracking, not pursuit. Settled on a moving spot he still moves with it.
- Harness: RECOVERY (the table above, the script's cut); GAME_HOLD_TRACE.

**Tried and dropped.** (a) `shape_tau_s` 4 → 1: no better with the rest in (2.52 v 2.50 m),
kept at 4. (b) A recovery run — a holder 6 / 10 m+ off his spot at the defending pace (6 m/s), not
the jog cap: shape error 2.24 / 2.41 m, but off-ball 5+ m/s 18.4 / 14.2% (real 7.9) and its peak at
2-4 s, not 4-10; most of the extra speed wasn't even running back. Removed, no switch left behind.

**Result** (8 matches, fh_game_scratch, Leicester v Arsenal; HEAD → G5.30, the same harness):

| | before | after | real |
|---|---|---|---|
| block v real table, mean \|error\| | 3.12 m | 2.50 m | 0 |
| ball 0-10 m out, CB / FB / WIDE off real | +5.5 / +6.1 / +8.0 | +4.0 / +4.5 / +5.5 | 0 |
| ball 90-100 out, CB / AM off real | −5.8 / −7.7 | −4.3 / −6.4 | 0 |
| off the ball 5+ m/s (side without it) | 10.4% | 10.1% | 7.9% |
| back m/s 4-6 s after losing it | +0.93 | +1.16 | +1.16 |
| nearest defender 52-70 / 70+ m out | 4.0 / 5.9 | 4.0 / 5.7 | 5.5 / 8.0 |
| shots a team-match | 8.1 | 8.1 | 12.9 |

Goals 0.31 → 0.62 a team-match on 8 matches: noise. Tests 22/22 (block test: the spot for a ball
in flight is its meeting point's); goldens re-locked.

**Next moles.** (1) The 6-10 s retreat: real men still run back 1.18 m/s there, ours 0.73 — the
block spot itself (a 10 m band table on the ball) may move less than a real block that is still
getting goal-side; the cause is open, not a pace cap. (2) Full-backs and wide men stay +2-3 m
upfield at every band (holders +2.0-2.7 m off their own spot, ball 40-60 out) where the others
are within 1-1.5: their slide runs them across while the 4.5 m/s cap is shared with the depth.
(3) Off the ball 5+ m/s 10.1% (7.9), 10.8% in a settled block (6.7): running not back, so across or
up. (4) Crosses 0.06 (11.5), corners 0.1 (3.2) from §8.127.

### 8.129 G5.31 — holding shape, pace by direction: across at the shift's, back at the defending pace (no migration)

§8.128's next: off the ball 5+ m/s 10.1% (7.9), 10.8% in a settled block — running not back.

**Measured.** RECOVERY now splits the 5+ m/s steps by why, role and direction (back / up / across:
the back component 0.7+ of his speed, the up the same the other way, else across), and by where
the ball is; `benchmarks_tracking_recover.py` prints the real cut. 72% of our fast steps were
*hold shape*, 70% of all of them with their ball inside 40 m of our goal — the §8.108 danger zone,
where a holder ran uncapped. Share of the side's steps at 5+ m/s:

| | back | up | across |
|---|---|---|---|
| ball inside 40 m of its goal, real DFL (25.7% of steps) | 9.22% | 0.40% | 1.97% |
| the game before | 17.37% | 1.14% | 17.13% |
| further out, real (74.3%) | 2.81% | 1.45% | 2.32% |
| the game before | 0.63% | 1.40% | 1.11% |

One cap, switched at 40 m, was wrong both ways: inside it the block sprinted across the pitch 9×
as often as real (every switch of wing was a dash); outside it the 4.5 m/s jog held back the
real runs back goal-side (a fifth of real). The real gradient is by direction: getting back is
urgent, shifting across is not.

**Built.** `Brain::capAcross`, after the arrive brake, holding shape: across (|y|) and up the pitch
at the shift's pace (`shape_max_mps` 4.5); back toward our goal at the defending pace
(`defend_max_mps` 6; in danger as §8.108, uncapped), his total at most the defending pace outside
danger. Existing rows, no new parameter. `Brain::inDanger` is the §8.108 test, shared.
Coaching: "get goal-side first, then into your shape" [FH].

**Tried and dropped.** The danger zone capped at the defending pace too (`shape_danger_sprint` 0):
back 5+ inside 40 m 10.8% (9.2), but the block late near its goal, shape error 2.35 → 2.78 m.
`shape_tau_s` 4 → 2 with it: shape 2.06 m but under 2 m/s 29.6% (41.9) — men never still.

**Result** (8 matches, fh_game_scratch; G5.30 → G5.31):

| | before | after | real |
|---|---|---|---|
| off the ball (side without it) under 2 / 2-5 / 5+ m/s | 42.3 / 47.6 / 10.1% | 41.9 / 50.7 / 7.4% | 41.9 / 50.3 / 7.9% |
| mean m/s | 2.59 | 2.53 | 2.61 |
| 5+ across, ball inside 40 m | 17.1% | 2.6% | 2.0% |
| 5+ back, further out | 0.63% | 1.09% | 2.81% |
| back m/s 6-10 s after losing it | 0.73 | 0.84 | 1.18 |
| block v real table, mean \|error\| | 2.50 m | 2.41 m | 0 |
| shots a team-match | 8.1 | 9.3 | 12.9 |

Tests 22/22, goldens unchanged (the test rig has no shape_max row, so the caps are off there).

**Next moles.** (1) Back 5+ inside 40 m 17.5% (9.2) — the uncapped danger sprint; capping it costs
the shape, so the block is getting there late for another reason (it starts back late: 0-2 s
after losing it ours +0.38 m/s back, real −0.12 — real men counter-press first, then drop).
(2) Further out back 1.09% (2.81) and 6-10 s 0.84 m/s (1.18): the τ ease (gap/4 s) still holds a
man 15 m off to 3.75 m/s. (3) Crosses 0.06 (11.5), corners 0.1 (3.2).

### 8.130 G5.32 — get goal-side first: a spot behind him he closes in 2.5 s (mig 1116; scratch DB only)

§8.129's next: the danger back-sprint (back 5+ m/s 17.5% of steps with their ball inside 40 m of
our goal, real 9.2) and too little running back further out (1.09%, real 2.81).

**Measured.** RECOVERY adds 5+ back by seconds since lost, per zone, and the holders inside 40 m
by metres off their spot; `benchmarks_tracking_recover.py` the real by-time cut:

| 5+ m/s back, inside 40 m, s since lost | 0-2 | 2-4 | 4-6 | 6-10 | 10+ |
|---|---|---|---|---|---|
| real | 3.6% | 8.4 | 12.3 | 12.9 | 10.0 |
| game | 17.0 | 35.5 | 27.5 | 20.8 | 15.3 |

Inside 40 m 64% of holder steps were 3-15 m off the spot, a fifth of those at 5+ m/s back; a
trace of the centre-backs with the ball 0-20 m out found them sprinting 5-8 m/s from 7-12 m above
their spot. Not idle — **late**: further out the shape's ease (gap / `shape_tau_s` 4) let a man 8 m
off his spot ask 2 m/s, so the block reached the danger line behind its spots and sprinted from
there.

**Tried and dropped.** An ease inside the danger zone (`shape_danger_tau_s` 1 / 0.7, the sprint
eased instead of only the stopping limit): the 3-8 m bin's sprints 20.6 → 15.7%, nothing else
moved (shape 2.49 / 2.47 m). Removed.

**Built.** Without the ball, a spot goal-side of him (a metre+) he closes in `shape_tau_back_s`
(2.5 s, mig 1116, [FH] fit to the DFL cuts above and the real spot table); across and up he keeps
`shape_tau_s` 4. Coaching: "get goal-side first, then into your shape" [FH]. No row = off.

| `shape_tau_back_s` | off (G5.31) | 3 | **2.5** | 2 | 1 | real |
|---|---|---|---|---|---|---|
| block v real table, mean \|error\| m | 2.41 | 2.23 | **2.06** | 2.06 | 1.89 | 0 |
| off the ball under 2 / 2-5 / 5+ m/s | 41.9/50.7/7.4 | 39.7/52.6/7.7 | **38.7/53.2/8.1** | 37.0/54.2/8.7 | 35.8/54.3/9.9 | 41.9/50.3/7.9 |
| mean m/s | 2.53 | 2.61 | **2.66** | 2.72 | 2.79 | 2.61 |
| 5+ back, further out | 1.09 | 1.72 | **2.14** | 2.95 | 4.52 | 2.81 |
| 5+ back, inside 40 m | 17.5 | 17.0 | **16.4** | 15.6 | 13.7 | 9.2 |

2.5 keeps 2's shape for less running; 1 is too much running (5+ 9.9%, men never still).

**Result** (8 matches, fh_game_scratch; G5.31 → G5.32): block v real 2.41 → 2.06 m (ball 40-70 m
out now within ±1.5 at every role but FB/WIDE); back further out 1.09 → 2.14% (2.81); shots 9.3 →
7.9 a team-match (12.9: noise at 8 matches either way, watch it). Back m/s by s since lost:
0-2 +0.38 → +0.55 (−0.12), 2-4 +1.43 → +1.75 (+0.79), 6-10 +0.84 → +0.62 (+1.18). Tests 22/22,
goldens unchanged (the test rig has no shape rows).

**Next moles.** (1) The turnover timing, now plain: ours run back hardest at 0-4 s, real men at
4-10 s (they counter-press, then drop) — the first seconds after losing it want the nearest men on
the ball, not a retreat. (2) Inside 40 m the block is still +4-6 m high with the ball 0-10 m out
and sprints back 16.4% (9.2). (3) FB/WIDE +1.3-2.5 m upfield in midfield. (4) Crosses 0.12 (11.5).

### 8.131 G5.33 — the block spot is the real SETTLED block, not the all-frames blend (no migration)

§8.130's next: the turnover timing — ours run back hardest 0-4 s after losing it, real men 4-10 s.

**Tried first: delay the drop** (`physics.phase.read_s`, three ways, none kept):
| on losing it, for the first N s a holder… | 0-2 s under 2 / 2-5 / 5+ m/s | after | block v real |
|---|---|---|---|
| (G5.32) goes to his block spot | 40.0 / 53.6 / 6.4 | | 2.06 m |
| stops where he is (1 / 2 s) | 71.8 / 25.8 / 2.5 | 5+ back at 4-6 s 13.4 / 17.4% (7.4) | 2.29 / 2.48 |
| keeps his attacking spot (1 / 2 s) | 52.8 / 44.0 / 3.3 (real 48.0 / 46.4 / 5.6) | 14.2 / 20.1% | 2.25 / 2.57 |
| eases from his attacking spot onto the block's (4 / 6 s) | 51.2 / 45.0 / 3.8 | 15.1 / 11.8% | 2.45 / 2.73 |
Every realistic first second postponed the sprint, and the shape got worse each time. That pointed
at the target, not the timing.

**Found: the real table is two blocks.** `benchmarks_tracking_possession.py` now splits the real
defending shape by seconds since the side lost it. Half of all real defending frames are the first
6 s after a turnover, and with the ball far from their goal those men still stand 3-9 m higher
than the settled block (ball 60-70 m out: CB 43.8 v 38.6, FB 49.0 v 41.3, WIDE 62.3 v 53.5). The
block spot (§8.111/§8.118) was the mean of both, so a settled block standing on it was too high,
and a realistic transition on top would be higher still.

**Built.** `kRealSpotDm` is the real SETTLED table (6 s+ since it lost it, DFL). Harness: DEFENDING
SHAPE, SETTLED and TRANSITION (by seconds since the last touch changed side), for like-for-like
comparison with the real split; the all-frames table is no fair measure while our possessions
run long (22.6% of our defending frames are transition, real ~50%).

**Result** (8 matches, fh_game_scratch; old all-frames table → settled):

| | before | after | real |
|---|---|---|---|
| settled block v real settled: mean \|error\| / signed | 1.90 / +0.98 m | 1.81 / −0.12 m | 0 |
| transition v real transition | 4.06 / +3.51 m | 4.04 / +2.90 m | 0 |
| off the ball under 2 / 2-5 / 5+ m/s | 38.7 / 53.2 / 8.1% | 41.0 / 51.7 / 7.3% | 41.9 / 50.3 / 7.9% |
| 5+ back, ball inside 40 m / further out | 16.4 / 2.14% | 12.0 / 2.38% | 9.2 / 2.81% |
| balls met in behind a team-match | 17.2 | 13.8 | 37.7 |
| shots a team-match | 7.9 | 7.5 | 12.9 |

The deeper settled line leaves less room behind it (in behind 17.2 → 13.8): honest, the line is
where real lines stand now. Tests 22/22 (block test on the settled table); goldens re-locked.

**Next moles.** (1) In transition our men stand +2.9 m higher than real men do: the attacking shape
they lose it from, or how the game counts a turnover (its last-touch flips on loose balls; DFL's
possession flag doesn't) — measure the possession shape the same way first. (2) Possessions too
long: 22.6% of defending frames are transition (real ~50%) — real sides lose it twice as often.
(3) In behind 13.8 (37.7), crosses 0.1 (11.5).

### 8.132 G5.34 — shipped: the live game is the Premier League game (2026-11-06)

James: "why are the teams in game still ukies and lighthouse and not premier league teams …
get rid of ukies and lh … when we add them later it will be from degrading the abilities from
the standard of premier league". Since G5.23 every slice ran only in the harness on
fh_game_scratch; the live daemon was the old engine (levels, 293 params, Lighthouse APSL v
Ukrainian Nationals) and the v2 client sat in game/ship.

**Done.** Backup `/srv/footballhome-backups/pre-game-ship-20261106-102203.sql`. Live DB: migs
919-1116 (19 game migrations; 1042 / 1080 / 1092 purge the non-PL sides, models and made-up
attributes). The 20 PL 2015/16 sides and 360 players copied from fh_game_scratch (the only
game tables that differed). docker-compose: Leicester City v Arsenal, GAME_LEVEL_* gone. Image
rebuilt (22/22 inside), daemon up healthy on 90 physics params. `frontend/game.html` and
`js/game/{client,net,renderer,wire}.js` = the v2 client (`?v=20261106pl`).

**Owed.** (1) A matchup picker on the game page: any two of the 20 sides from a dropdown — the
daemon picks its teams from env at boot today. (2) The harness on rotating fixtures, not
Leicester v Arsenal only. (3) The backend cleanup in game/ship/README.md. Lighthouse and the
Ukies return later as PL abilities scaled down, never as hand-made sheets.

### 8.133 G5.35 — any matchup from a dropdown; the harness plays rotating fixtures (protocol 2.1)

James: "i should be able to select any matchup from a drop down"; "so you test with various
matchups". The daemon took its two teams from env at boot; every harness result since G5.24
was Leicester City v Arsenal.

**Built.**
- Protocol 2.1 (additive): TEAM_LIST 0x45 s→c on connect (every game_demo_teams name, A-Z —
  the 20 PL 2015/16 sides); NEW_MATCH 0x46 c→s admin (a TEAMS payload, names only). The server
  loads both teams and their own formations, drops claims, kicks off fresh on the next seed
  (`GameServer::startMatch`, now also the constructor's body), and answers every client with
  TEAMS + ROSTER + a SNAPSHOT. Unknown, empty or equal names change nothing.
- The page (admins): a matchup bar under the speed bar — home ▾ v away ▾, ⚽ Kick off.
  Everyone watching sees the new match: one match, one clock.
- Harness: fixtures rotate over every team unless GAME_TEAM_HOME / GAME_TEAM_AWAY pin one —
  match m is game m of a round-robin (circle method), so 8 matches = 8 fixtures, 16 sides;
  FIXTURES line. Codec test for TEAM_LIST; NEW_MATCH checked on a private daemon (local port,
  throwaway secret): HELLO admin → TEAM_LIST 20 → NEW_MATCH Chelsea v Tottenham Hotspur → TEAMS.
- Deploy note: `podman-compose up -d` left the old container running on the old image (the
  known recreate quirk); `--force-recreate` and check the container's image id.

**Rotating baseline** (8 fixtures, fh_game_scratch): settled block v real settled 2.03 m /
−0.09 signed (Leicester v Arsenal 1.81 / −0.12); off the ball 40.5 / 51.7 / 7.8% (41.9 / 50.3 /
7.9); shots 8.8 a team-match (12.9); **goals 0.12 a team-match, 1.4% of shots scored** (real PL
2015/16 ~10%) — the biggest problem in the game now.

**Next moles.** (1) Scoring: keepers save 65%+, 1.4% scored. (2) Crosses 0.0 (11.5). (3) Our
transition +2.8 m above real; possessions twice too long.

### 8.134 G5.36 — Westtown FC and Lighthouse as pro sides; roles from the slot; the wing-back (mig 1122)

James (via the club-app session): "make west town and lh same as pro team ability wise for now …
westtown runs standard pro tactics. lh runs this game model". Both are copies of ONE 2015/16 PL
side, **West Ham United** (4-3-3), so a difference is tactics, not talent: Westtown FC plays West
Ham's 4-3-3 on the standard behaviour; Lighthouse plays the 3-5-2 (3-R2) (royal blue, mig 851).
Lighthouse's own game model (the club's tactic plans, mig 1121) is not read by the engine yet.

**Roles from the slot.** A man's Role came from his shirt number alone (`roleOfNumber`), so a
3-5-2's 6 (the middle centre-back) played a holding midfielder and its 9 (midfield) a striker.
`roleOfSlot` reads formation_slot_roles.role first (centre-back, full-back, wing-back, single- /
double-pivot, eight, ten, wide-forward, nine), the number only where no role row exists. Side
effect: a 4-3-3's left "eight" numbered 10 now plays the DM/CM table, not the AM one.

**The wing-back** (`Brain::wingBack`) — James: "the ball-side wing-back goes, the far-side one
tucks in to make a back four". Without the ball the wing-back on the ball's side (where it is
going) takes a wide man's depth; the far one a full-back's, tucked to a back four's full-back
width (`physics.shape.wb_tuck_y` 0.7 of the half-width, the club 4-4-2's 15/85 — [FH], no real
back-three data in DFL's role split yet). With the ball both are the wide men. Mig 1122 gives the
3-R2 its slot roles by James's numbering (3 · 5 6 4 · 2, 10 9 8, 7 in the hole, 11) and adds the
`wing-back` role.

**Scratch DB.** Its `formations` was cloned before the club's formation migrations 1107-1120:
the 3-R2 didn't exist and Lighthouse silently played the env's 4-4-2. Formations and slot numbers
copied from live (new rows only).

**First look** (8 + 8, fh_game_scratch): Lighthouse 3-R2 v Westtown 4-3-3, same players, W0 D11
L5 for Lighthouse over both venues, shots 9.2 / 6.9 v 7.1 / 5.6. With goals at 0.1-0.5 a
team-match (the scoring mole) this is noise, not a verdict on the shape.

**Owed.** The engine reading the club's tactic plans (mig 1121: per matchup and moment, a state
tree from their keeper by passes, one job per our position — cover_shadow / mark / hold_between
with dist_m / press_m) — app and engine to share one geometry, documented here; the brain overlay
labelling each man's job.

### 8.135 G5.37 — shots go where real ones went; the keeper reacts to the strike (migs 1126, 1127)

§8.133's next: scoring — 0.12 goals a team-match, 1.4% of shots scored (real 9.3).

**Real** (new `scripts/benchmarks_statsbomb_placement.py`, StatsBomb PL 2015/16 open play):
shots end goal 9.4 / saved 22.5 / blocked 29.2 / off target 38.9%; keepers save 70.4% of those
on target. On target they spread across the mouth (0-1 m from the centre 24%, 1-2 26%, 2-3 32%,
3-3.66 19%; 43% under 0.5 m high, 20% over 1.5 m); 2 m+ from the centre scores ~45%, the middle
~20%. Misses: a median 2.4 m wide, 1.8 m over. A saved shot's end_location is where the keeper
stopped it, so the crossing table mixes P(on target) from the outcomes with the on-target spread
(goals and saves) and the off-target spread (misses at the line). The save curve (freeze frames:
the keeper's gap along the line to where it crossed): from 12-18 m half are saved at 2-2.5 m, 5%
at 3 m+; from 18-25 m half at ~3 m. Shot speed (new `scripts/benchmarks_tracking_shotspeed.py`,
DFL, the ball's peak in its first 0.6 s, anchored on the ball nearest the shot's spot — the event
clock is not the tracking clock): median 15.8 / 23.0 / 24.3 / 28.6 m/s by <12 / 12-18 / 18-25 /
25+ m; the game strikes at up to 24, so speed was not the problem.

**Found.** Every shot rolled along the ground to 0.5 m inside the far post with a few degrees of
error: on target 70% (real 32%), and the keeper — reacting on the strike's own tick and tracking
the ball-goal line in flight — reached 98% of those, 100% even 3 m+ from him.

**Built.**
- The shot's crossing point is drawn (one draw a spell) from where real shots from that distance
  went, `kShotXing` (lateral bin × height bin, on and off target); side of the goal 50/50 [FH].
  Orders carry `aim_z`; `World::shotLift` solves the lift that crosses there on the free-ball law
  (drag + gravity, bisection). A brain-aimed shot gets no extra angle error (the draw is its miss);
  a human's keeps it.
- The keeper pays his reaction time on their strike (Body::reaction, as every read does): he
  carries on as he was, no new line, no dive.
- `physics.keeper.reach_m` (1.2, the old constant) and `shot_reach_m` (0.7, mig 1126): against
  their ball at shot speed (12 m/s+) he takes it only within 0.7 m of his body. Fitted to the
  real 70.4% on-target save share: 1.2 → 87%, 1.0 → 83, 0.8 → 77, 0.7 → 71, 0.5 → 48%. One 0.5 m
  reach for every ball let back passes roll in (5.75 goals a team-match).
- Harness: shots BY AIMED CELL (real goal % alongside) and the SAVE CURVE (keeper's gap).
- Mig 1127: formation_slot_roles numbers on James's sides (5 left centre-back, 4 right, 11 left
  wing, 7 right) in 4-3-3, 4-2-3-1, 4-4-2 — found by the club-app session; roles and play unchanged.

**Result** (32 rotating fixtures, fh_game_scratch; G5.36 → G5.37):

| | before | after | real |
|---|---|---|---|
| shots end goal / keeper / blocked / off target | 1.4 / 68.6 / 11.4 / 18.6% | 10.0 / 24.4 / 8.9 / 56.8% | 9.4 / 22.5 / 29.2 / 38.9% |
| on target saved | ~98% | 71% | 70.4% |
| goals a team-match | 0.12 | 1.01 | 1.20 |
| shots a team-match | 8.8 | 7.4 | 12.9 |

Tests 22/22; the 11v11 golden re-locked (the 3v3 rig never shoots). Daemon redeployed.

**Next moles.** (1) Blocks 9% (29%): no bodies in the lane — off target reads 57% because shots
real defenders would block go through to miss. (2) Shots 7.4 a team-match (12.9). (3) Own goals
0-4 per 8 matches (real ~1 in 10 team-matches) — trace them. (4) The club's tactic plans (mig 1121).

### 8.136 The real goal-kick shape (DFL) for the club's tactic_buildout_shapes (no engine change)

The club-app session seeded `tactic_buildout_shapes` (mig 1129, club DB) from published
descriptions of the post-2019 Law 16 goal kick ([FH]). New `scripts/benchmarks_tracking_goalkick.py`
cuts it from DFL (7 matches): each GoalKick anchored on the frame the ball comes back into play
from inside the kicking side's goal area (event clock ≠ tracking clock), 65 of 85 found; the
kicking side by PlayingPosition, metres off its own line / to its own left, and the plan's
coordinates (0-100, our view, their goal y 100). For a 4-3-3 by James's numbers:

| # | role (DFL) | n | off their line, m | to their left, m | plan x, y |
|---|---|---|---|---|---|
| 1 | TW | 65 | 4.4 | 0.0 | 50, 96 |
| 4 | IVR | 65 | 13.7 | −12.1 | 32, 87 |
| 5 | IVL | 65 | 14.3 | +10.8 | 66, 86 |
| 2 | RV | 46 | 22.9 | −24.8 | 14, 78 |
| 3 | LV | 44 | 25.8 | +24.4 | 86, 75 |
| 6 | DMZ | 13 | 35.0 | +3.0 | 54, 67 |
| 8 / 10 | DMR / DML | 53 / 50 | 33.7 / 30.8 | −4.8 / +4.2 | 43, 68 / 56, 71 |
| 7 / 11 | ORM / OLM | 48 / 51 | 50.8 / 52.2 | −17.4 / +18.7 | 24, 52 / 78, 50 |
| 9 | STZ | 43 | 57.7 | +2.0 | 53, 45 |

Against the [FH] seed: the centre-backs split ~12 m off centre at the box's edge (not 17 m deep
in it), the pivot does not drop to the D on average (35 m out; a back three's middle man, IVZ,
does — 25 m), full-backs stand ~25 m wide and 23-26 m up, and the wingers are inside the
touchlines (~18 m off centre) on the halfway line. The engine's own goal kick (the keeper takes
it, the rest on their possession spots for a ball at their goal) is not yet this table.

### 8.137 The tactic plans — the shared spec (club app + engine; engine reader not built yet)

James: "one source of truth and then the game and the tactics on event center draw from it."
The club's tactic plans (club DB, migs 1121 / 1129 / 1132 / 1133) are edited in Game Center; the
engine will play them for the side whose plan matches (Lighthouse first). This section is the
contract both sides implement; a change to either side changes this section.

**Tables.** `tactic_plans` (our formation_id, opponent_formation_id, moment → game_moments,
block_height → tactic_block_heights with gk_y; one per matchup); `tactic_states` (plan_id,
parent_state_id NULL = the root "ball with their GK", ball_with = their number 1-11; a child =
"the ball was passed to their #N"); `tactic_state_opponents` (state, number, x, y); `tactic_jobs`
(state, our position_id 2-11, kind → tactic_job_kinds, target_a, target_b, partner_position_id);
`tactic_job_kinds` (code, concept_id → game_concepts, dist_m, press_m, partner_label);
`tactic_buildout_shapes` (formation, number, x, y — their goal-kick shape; 4-3-3 = the DFL cut,
§8.136). Numbers on both sides are James's scheme (formation_slot_roles.number, mig 1127).

**Coordinates.** 0-100 from OUR view as we attack: x left → right, y 0 = our goal line, their goal
at y 100; their right side is on our left. Measure in metres on a 68 × 105 pitch (x · 0.68,
y · 1.05) before any distance or direction.

**Spots, per job** (A, B = their men by number; dist_m, press_m from the job kind):
- *mark A* (concept 18 man-mark): dist_m goal-side of A, toward the centre of our goal (50, 0).
- *cover_shadow A, B* (concept 27): if their B has the ball, press_m from the ball on the ball → A
  line; otherwise dist_m off A, toward the ball.
- *hold_between A, B* (concept 186): the midpoint of A and B, dist_m toward our goal.
- *straddle A* with a partner (concept 187, paired: both partners carry it on the same A, each
  naming the other): u = unit vector from A toward the ball — or toward the centre of their goal
  (50, 100) when the ball is within 0.5 m of A; perp = u rotated 90°, pointed toward smaller x;
  the partner whose formation spot has the smaller x stands at A + u · press_m + perp · dist_m,
  the other at A + u · press_m − perp · dist_m. A straddled man counts once in coverage.
- *no job*: the engine's block spot — the real SETTLED table (DFL, by role and the ball's band,
  §8.131), to be exposed as rows the app reads, so both draw the same spot.
- *our keeper*: (50, the block height's gk_y).

**Which state.** Out of possession only (moment out_of_possession = the engine's settled
DefendingBlock; to_defend, the transition after we lose it, gets its own plans later). The root
when their keeper has it. The ball passed to their #N: the current state's child with
ball_with = N; else any state in the plan with ball_with = N (nearest the current one in the
tree); else the current state's jobs re-solved with the ball at #N. Default behaviour only when the
moment changes (we win it, a set piece).

**When the engine reads them.** At kickoff (daemon start, every NEW_MATCH) and on an admin
RELOAD_ROSTERS — between ticks, never inside the sim loop (determinism, replays). A Game Center
save reaches a running match on reload (Game Center may send it after saving).

**Amendments (2026-11-06, club migs 1135-1142).**
- *The 4-3-3 build-out shape* is now James's placements [FH, owner] except the GK (50, 96), the 6
  (50, 67) and the wide men's heights (DFL, §8.136): 4 at 28, 92 / 5 at 72, 92 (later moved to the
  8-yard line, y 93, mig 1139), 2 at 3, 78 / 3 at 97, 75 (touchline), 8 at 32, 61 / 10 at 68, 61
  (the half-spaces, [FH]), 7 at 3, 52 / 11 at 97, 50 (touchline), 9 at 50, 45.
- *Multi-man jobs* (mig 1139): `tactic_jobs.target_a` is gone — a job's men are a set S in
  `tactic_job_targets` (state, position, number, ord); `tactic_job_kinds.multi_a` marks the kinds
  that take more than one (cover_shadow, deter, read).
- *deter S* (concept 188, lane_t 0.45) and *read S* (concept 20 intercept, lane_t 0.65): the mean
  over S of ball + (S_i − ball) · lane_t — deter nearer the passer, read nearer the receivers.
- *cover_shadow S, B* with a set: B on the ball → ball + press_m along the mean of the unit vectors
  ball → S_i; otherwise the mean of (S_i + dist_m toward the ball).
- *The man on the ball is no lane* (11/7): lane and cover_shadow (the lanes branch) skip any
  target within 0.5 m of the ball (`JobRule::offBall`). If every target has the ball, the man
  stands press_m (else 1.5 m) goal-side of it (`JobRule::onTheBall`). Club app, 11/7: 3-R2, ball
  to their 5, 7 on deter 5 + 3 was drawn on top of 5.
- *cover_over_top A, B* (11/7, mig 1178; kind cover_over_top: concept cover, dist_m 8, lane_t
  0.33): lane_t of the way from A toward B, then dist_m toward our goal; with no B, dist_m
  straight goal-side of A (`CoverOverTopRule`). It covers both A and B.
- *sweep* (11/9, mig 1208, b6e2d593; the libero, concept 26; dist_m 8, lane_t 0.33): dist_m
  goal-side of their deepest outfielder (y in pitch %, so dist_m × 100 / L), across at
  x = 50 + (ball.x − 50) × lane_t, never below y 5 (`SweepRule`). He used to stand on 'home' and
  sat on our keeper (y 15-18) 30 m behind a high press; now he is behind the markers, ready for
  the ball over or through. `Placement.theirs` (their outfielders, #1 out) carries what he reads.
  [FH] geometry, not measured. Mig 1209 adds opponent-only formations 4-1-4-1, 5-3-2 and 5-4-1
  (no formation_slot_roles) and plans 25/26/27.
- *Stance* (`tactic_job_stances`, `tactic_jobs.stance`): goal_side by default; intercept (concept
  168 defend-your-man) — a mark stands dist_m BALL-side of his man instead of goal-side.
- *Restarts* (mig 1142, `tactic_restarts`; `tactic_states.restart`): every out_of_possession root
  (their keeper placing the ball) is restart = goal_kick (Law 16), and our spots are capped at
  y ≤ 84.29 until the ball is played (a child state lifts it). Since mig 1145 the cap follows the
  Law exactly: TacticGeometry.solve reads the row's zone_min_x / zone_max_x / zone_min_y and holds
  a spot at zone_min_y inside x 20.35-79.65 (the penalty area's width). Since 11/7 (owner: "on goal
  kicks no player on def can be past 18"), our_max_y also holds across the whole width, so both the
  zone and our_max_y apply (RestartLaw::cap). The engine's goal kick enforces the Law's area only
  (Brain::outOfTheirBox) and reads law_m, so the full-width line is the app's plan, not yet the
  engine's.

**Owed (engine).** The reader; the settled block-spot rows for the app; the engine's own goal-kick
shape from tactic_buildout_shapes; the brain overlay labelling each man's job ("cover-shadow #6 →
press #4").

### 8.138 G5.38 — the block narrows toward its goal: real settled widths by role and band (no migration)

§8.135's next: blocks 9% of shots (29%).

**Measured.** New `scripts/benchmarks_statsbomb_blocks.py` (StatsBomb PL 2015/16 freeze frames):
within 1 m of the ball → goal-centre line, between them, 71% of real shots have an outfield
opponent (0 / 1 / 2 / 3+ bodies: 28.6 / 50.7 / 17.0 / 3.8%, blocked 7.6 / 34.4 / 44.9 / 51.8%);
the nearest is a median 0.56 m off that line; the nearest opponent to the shooter a median 1.95 m
away, goal-side of him 70%. The game: ~10% of shots with a body in the lane, the nearest 7.8 m
off it; the nearest man as close (1.8-1.9 m) but goal-side only 44%. In open play (DFL, settled
6 s+, ball 10-35 m out and |y| < 12, `benchmarks_tracking_possession.py` LANE): a man within 1 m
43.6% (game 21%); the centre-back pair 7.1 m apart (game 10.1).

**Found: the block keeps its formation width.** Settled pair gaps by the ball's band off the
defenders' line, near → far (DFL v game before):

| pair | real | game before | game after |
|---|---|---|---|
| CB | 9.5 → 11.9 m | 11.0 → 14.4 | 9.6 → 11.8 |
| FB | 23.7 → 35.2 | 42.6 → 46.2 | 24.4 → 35.0 |
| WIDE | 24.5 → 29.9 | 37.2 → 34.9 | 27.1 → 33.0 |
| DM/CM | 9.6 → 9.1 | 10.8 → 12.5 | 9.9 → 10.7 |

The full-backs stood at their formation's 15/85 — 48 m apart — with the ball on our 18: real
ones 24.

**Built.** `BlockParams::width` (`physics.block.w_<role>_<band>`, defaults `kRealWidthPm`): his
share of his formation width by role and band, the real settled gap over the game's own gap with
no factor (its men stood ~20% inside formation width already: the slide and its caps); AM and ST
kept whole (no pair in the data). `Brain::acrossDef` scales the lateral offset before the slide —
the spot, its lead (G5.30) and the tucked wing-back alike. Each formation keeps its structure,
narrowed by the real amount.

**Result** (32 rotating fixtures, fh_game_scratch): widths as the table; settled depth and speeds
unchanged (−0.6 m signed v real settled, as G5.37's; off the ball 41.1 / 51.3 / 7.7%). **The lane
did not fill**: a man within 1 m in open play 21-24% (43.6), blocks 9.2% (29.2) — width was not
the cause. The tell is the nearest man goal-side 37-43% of shots (70): the presser closes on the
carrier from wherever he is, not goal-side first. Tests 22/22; goldens re-locked (the rig reads
the width defaults).

**Next moles.** (1) Goal-side first: the presser's approach (and the second man's cover) onto the
ball-goal line. (2) Penalties: a foul in our box gives a free kick on the spot (Law 14: a penalty).
(3) Shots 7-8 a team-match (12.9).

### 8.139 G5.39 — the presser tracks his moving spot; goal-side first is the 1v1 (no migration)

§8.138's next: the nearest man to their carrier goal-side.

**Real** (`benchmarks_tracking_press.py` now prints it; DFL, the nearest outfield defender to the
man on the ball, goal-side = nearer the defenders' goal line): 60.2 / 71.4 / 73.1 / 80.0 / 85.4%
with the ball 0-18 / 18-35 / 35-52 / 52-70 / 70+ m from their goal. The game: 31.8 / 54.2 / 66.9
/ 71.6 / 80.0%. Inside 35 m the not-goal-side nearest man is the presser 49% of the time (hold
shape 28, chasing 22), the carrier running at goal 2.8 m/s, on it 2.6 s. Traced: the presser
behind, running at 50-90% of his top speed — braked to arrive at 3 m/s on a spot that moves with
the carrier at 4-5.

**Built.** Pressing, he arrives at his spot no slower than their carrier runs (`brakeToArrive`,
Why::Press: v_end = max(arrive_through, carrier speed)) — tracking, not pursuit, as the block's
G5.30. Goal-side nearest with the ball 0-18 m out 31.8 → ~39% (4 seeds: 33-44); the other bands
unchanged; nothing else moved (shots, scoring, speeds, shape).

**Tried and dropped** (no effect, removed): the presser chosen as the nearest who is goal-side
(a man behind counts 3 / 6 m further: 0-18 m 28-40%); turning to run when retreating instead of
backpedalling facing the carrier (0-18 m ~42%, the rest unchanged); a route round the carrier
1.5 m to his side when behind him (unchanged).

**What it is.** Take-ons 107 a team-match by the DFL cut (44.2) through all of it: their carrier
beats our man 2.5× as often as real, and a beaten man is behind the ball. Goal-side is the 1v1 —
the jockey and the tackle — not the presser's choice or path.

**Next moles.** (1) The 1v1: take-ons 2.5×. (2) Law 14 — a foul in our area gives a free kick on
the spot, not a penalty. (3) The tactic plans' reader.

### 8.140 G5.40 — Law 14: penalties; the restarts' Laws as one shared statement (mig 1145)

James (via the club-app session): "tell 'game' about laws of the game to improve refs and
behaviour of players … ok just turn it over to game". The audit: Law 15 throw-in 2 m, Laws 13 / 17
9.15 m, Law 16 the area cleared, Law 11 offside (the assistant's call, G4.88), Law 12 fouls and
advantage (G5.28), Law 5/6 positioning — all in. Missing: **Law 14** (a foul in the fouler's own
area was never called at all), Law 8 (kick-off halves), Law 13 walls, cards.

**Real** (new `scripts/benchmarks_statsbomb_penalties.py`, StatsBomb PL 2015/16): in his own area
a side makes 1.61 tackle duels and 0.13 fouls a team-match — 7.6% of its challenges there are
fouls (the §8.126 cut); penalties 0.120 a team-match, scored 81.3%, saved 12.1%, missed 6.6%; on
target a median 2.38 m from the goal's centre (p25 1.83, p75 2.93), 0.64 m up (0.18, 1.28).

**Built.**
- World: a challenge in the tackler's own area is a foul at 7.6% (`physics.foul.p_own_area`);
  without advantage it is MatchEventType::Penalty (13) to the fouled side at the mark (11 m), a
  held restart (the taker on the spot, as a corner), dead the free kick's real roll; `penaltySetup()`
  until it is kicked.
- Brain: `playPenalty` — after the corner's look, a Shot at a point drawn from the real penalty
  (on target 93.4%: quartile-joined lateral and height; off 6.6%: wide or over). `penaltyPlaces`:
  everyone but the taker and the defending keeper outside the area and the arc, behind the ball (a
  line at 11 + 9.15 + 0.85 m); the keeper on his line between the posts. After the kick, play on.
- Client: event 13 "Foul in the box — penalty home / away", the long whistle. PROTOCOL §7: 13.
- Mig 1145 (club DB): `tactic_restarts` states every restart's Law — law_m, zone (penalty_area /
  area_and_arc / own_half / none) with zone_min_x / zone_max_x / zone_min_y in plan coordinates,
  who, until_event, the Law 13 wall (9.15 m, attackers 1 m from a wall of 3+) — rows goal_kick,
  free_kick, corner, throw_in, kick_off, penalty. The goal kick follows the Law exactly (the area,
  x 20.35-79.65, y ≥ 84.29), not a whole-width cap. The game reads law_m (throw-in, free kick /
  corner, the penalty arc) at load (`persistence::loadRestartLawsMilli`); absent table (scratch) →
  the same defaults.
- Harness: PENALTIES (a team-match, scored), tackles in his own area, penalty dead time.

**Result.** Forced (every area challenge a foul, 4 × 8 matches): 14 penalties, 13 scored (real
81.3%; 14 is too few to tell), Law 14 positions held at the kick (traced: only the taker and the
keeper inside). At the real 7.6%: 0 in 32 matches — our side challenges 0.44 times a team-match in
its own area (real 1.61 tackle duels), so ~0.03 penalties a team-match (0.12). The box defending
is the next mole, not the Law. Tests 22/22, goldens unchanged (no area foul in the rig).

**Next moles.** (1) Challenges in our own area 0.44 (1.61) — box defenders reach for balls, they
don't tackle carriers. (2) Law 8: kick-off halves. (3) Law 13 walls. (4) Cards. (5) The 1v1:
take-ons 2.5× (§8.139).

### 8.141 G5.41 — the box is empty, not the tackle; the back pair staggers (no migration)

§8.140's next: challenges in our own area 0.44 a team-match (real 1.61 tackle duels).

**It is exposure, not the tackle.** New `scripts/benchmarks_statsbomb_area_duels.py` (StatsBomb PL
15/16): a side's attackers in the opponents' area begin 12.83 receipts and 8.39 carries lasting
10.7 s a team-match; the defenders make 1.61 tackle duels there = 0.151 a second of carry. The
game (new harness line THEIR MAN ON THE BALL IN OUR AREA): 1.62 spells, 3.2 s, 0.138 tackles a
second — the rate is real, their man is hardly ever on the ball in our box. Why: with the ball
18-35 m out the attack has 0.07 men in the box (real 1.04, §8.124); every pass goes to a man, so
from 18-35 m central 4.5% of passes go into the box (real 21.3%), and crosses are 0.06 a
team-match (11.47).

**And the box is empty because the line is high.** `benchmarks_tracking_box.py` now prints the
defenders' offside line (second-last, keeper in) and the attack's most advanced outfielder by the
ball's zone (DFL): line 8.7 / 9.0 / 18.8 / 18.5 / 28.2 / 27.8 m off its goal line (ball 0-18 central /
wide, 18-35, 35-52), the front man 0.4-2.0 m short of it. The game: 15.4 / 13.2 / 23.0 / 22.8 /
30.9 / 30.8, its front man 1-5 m short. Runners into the box (§8.124) stop at that line, legally.
Why the line: the deepest outfielder against the CBs' mean, real 18.8 v 21.1 (ball 18-35 central),
the game 23.0 v 24.2 — the pair's mean 3 m high, and a flat pair (1.2 m, real 2.3).

**Real cover** (new `scripts/benchmarks_tracking_cover.py`, DFL, the defending pair when exactly
two CBs are on): the two stand 2.8 m apart in depth at every ball band (3.2 at 0-10, 3.7 at 90+).
The deeper is the far one from the ball only 37-54% of the time — no side rule — but he is the
one nearer their most advanced outfielder 60-72% at every band: the CB goes down with the 9.

**Built.** `DefendingBlock::assignCover`: with two CBs on, the one nearer their front man is the
deeper (held until the other is switch_m nearer); the pair's mean stays the real CB spot, the
deeper half the real gap below it, his partner half above (`physics.block.stagger_<band>`, mm).

**Result** (2 × 8 matches, A/B on seed 2000 with the stagger zeroed): the deepest man now stands
1.4 m under the pair's mean (1.2 off; real 2.3 — a FB or a third man is the deepest 15-35% of
real frames); the offside line 0-0.4 m deeper (23.0 → 22.6-23.0 at 18-35 m). Correct shape, small
effect: the line is the pair's MEAN. Shots, goals, tackles within the seed noise. Tests 22/22.

**What it is.** Settled to settled (6 s+ since it lost the ball), the game's CBs stand 5.7 / 3.1 /
2.4 / 1.6 m above the real spot with the ball 0-10 / 10-20 / 20-30 / 30-40 m out — their targets
ARE the real spots (holders' target 11.0 / 15.4 / 20.9 / 26.5): they trail the ball as it comes
toward goal. Real defenders drop first and get there before it.

**Next moles.** (1) The back line trails the ball toward its goal: 2-6 m behind its own real spots
inside 30 m (GAME_LINE_TRACE prints each frame's defenders, at / target). (2) Then runners into
the box and passes into it (21% from 18-35 m central; crosses 0.06 v 11.47). (3) Law 8, Law 13
walls, cards (§8.140). (4) The 1v1: take-ons 2.5× (§8.139).

### 8.142 G5.42 — the block spot is where real men stand with the ball still; the lag is the body's (no migration)

§8.141's next: the back line 2-6 m behind its own real spots inside 30 m, settled.

**Real men trail too.** New `scripts/benchmarks_tracking_lag.py` (DFL, the side without the ball,
settled 6 s+): each role's mean metres off its line by the ball's 10 m band AND the ball's speed at
that line over the last second (away < −2 m/s, still ±2, coming 2-5, coming 5+). With the ball
20-30 m out a real CB stands 14.0 / 17.0 / 19.8 / 23.5 m; at 0-10, 6.3 / 7.7 / 9.9 / 11.8. A real
block stands where the ball was ~1 s ago, both ways. So G5.33's spot table (§8.131, the mean over
every settled frame) already HAS the real lag in it — ours caught up with a spot that was itself
behind the ball, then trailed it as well. The harness (new line SETTLED SHAPE BY THE BALL'S SPEED
AT THEM) showed exactly that: with the ball coming at 5+ m/s our men stood where real ones do;
with it still, CB/FB/DM/WIDE stood 3.5-5 m high at every band inside 50 m (CB 21.0 v 17.0 at 20-30).

**Built.** `kRealSpotDm` = the real STILL rows (all ten bands, every role). The spot is where a man
stands once he has caught up; trailing a moving ball is the body (Locomotion, the shape caps,
G5.30's tracking), not the table. No new rule, no new param — the same physics.block.<role>_<band>
keys, now meaning the still-ball spot.

**Result** (8 matches, deterministic; before → after, real DFL):
- ball still, CB: 0-10 12.0 → 8.4 (7.7); 10-20 16.1 → 13.6 (11.6); 20-30 21.0 → 18.4 (17.0);
  30-40 26.7 → 23.4 (22.8); 40-50 30.9 → 27.7 (27.5). FB/DM/WIDE the same: within ~1.5 m.
- coming 5+, CB: 20-30 25.7 → 23.5 (23.5); 30-40 31.3 → 28.2 (29.8) — ours now lag ~1-2.5 m less
  than real at 30-50 m.
- settled table (all frames), CB 0-10 / 10-20 / 20-30: 15.5 / 17.8 / 22.3 → 11.6 / 15.9 / 19.9
  (10.0 / 14.5 / 20.1); further out now 1-3 m deep of the real blend (the mix of ball speeds
  differs: ours has twice the real share of still frames at 20-30).
- offside line, ball 18-35 central: 22.6 → 20.1 (18.8); 0-18 central 15.5 → 13.4 (8.7).
- what follows from a deeper line: balls met in behind 10.0 → 6.4 a team-match (37.7); entries
  inside 30 m 33.2 → 26.4; shots 7.8 → 6.6, goals 1.00 → 1.12 (one 8-match set).
- tests 22/22; goldens re-locked. `test_defending_block` compiles again (G5.41 changed assign()).

**Not done.** AM and ST: with the ball coming at 5+ m/s real ones stand 9-13 m higher than with
it still (they are the men it was just played past); ours only 3-5 — our front men drop with the
ball faster than real. Not the biggest problem.

**Next moles.** (1) The attack doesn't play on the line: our most advanced man 25.9 m off their
line with it at 20.1 (ball 18-35 central; real 20.2 v 18.8) — 5.8 m short (real 1.4). Balls in
behind 6.4 v 37.7 and the box at 18-35 m 0.09 v 1.04 both start there. (2) Passes into the box and
crosses (0.19 v 11.47). (3) Law 8, Law 13 walls, cards (§8.140). (4) The 1v1: take-ons 77 v 18.

### 8.143 G5.43 — the support spot is where real men stand with the ball still, too (no migration)

§8.142's next: our most advanced man 5.8 m short of their offside line (ball 18-35 central; real 1.4).

**The same double lag, on the ball.** `benchmarks_tracking_lag.py` now prints the side IN possession
(every in-play frame, as §8.111's POSSESSION SHAPE) by the ball's band off THEIR line and its speed
forward over the last second, with their offside line and our front man; the harness the same
(POSSESSION SHAPE BY THE BALL'S SPEED FORWARD). Real attackers trail the ball as real defenders do:
ball 20-30 m out, a real ST 15.2 / 19.5 / 22.8 / 26.3 m off their line with it going back / still /
forward 2-5 / forward 5+; the front man 1.2 m short of the line with it still, 1.9 going forward 5+.
The game before: going forward 5+ our CB/FB/DM/WIDE stood where real ones do (within ~1-2 m); with
it still or going back every role 5-8 m deep (ST 24.5 v 19.5, AM 31.2 v 23.6 at 20-30), the front
man 22.4 v 16.5 — §8.111's table (all frames) held the real lag and ours trailed on top of it.

**Built.** Possession's `kRealSpotDm` = the real still rows, all ten bands, every role (keys
physics.support.<role>_<band> unchanged, now the still-ball spot).

**Result** (8 matches, deterministic; §8.142 → now, real):
- ball still 20-30 m out: ST 24.5 → 22.5 (19.5), AM 31.2 → 28.3 (23.6), CB 50.3 → 46.8 (44.8);
  at 30-50 m within 1-4 m every role. Going forward 5+ ours now 1-3 m less far from goal than real
  (CB/FB) — as the block, ours lag a little less than real once the target is right.
- front man / their line, ball still 20-30: 22.4 / 17.2 → 21.1 / 17.2 (16.5 / 15.3); ball 18-35
  central (all frames) 25.9 → 23.9 with the line at 20.0 (20.2 / 18.8): 3.9 m short (real 1.4).
- possession shape, all frames, 20-30: ST 25.5 → 24.2 (22.1), CB 52.2 → 48.9 (48.8).
- shots 6.6 → 10.4 a team-match; balls met in behind 6.4 → 11.8 (37.7), completed 45% (47.5);
  entries inside 30 m 26.4 → 41.4; their man's spells begun in our area 1.38 → 3.62 (receipts
  12.83), on the ball there 3.0 → 4.8 s (10.7); in the box with the ball 18-35 central 0.09 → 0.13
  (1.04); goals 1.12 (one 8-match set). Tests 22/22; goldens re-locked.

**Amended — the harness's roles.** fh-game-match named every man's role by his shirt number
(`roleOfNumber`); the brain plays the formation's role name first (`roleOfSlot`: a "ten" in an 8
shirt is the AM, an "eight" in a 10 shirt a DM — mig 1127 numbered James's sides). Every by-role
line in the harness now reads `Brain::roleOf`. Same matches, re-measured: the AM "5 m deep" was the
mislabel — with the ball still 20-30 m out the side in possession now reads CB 46.7 (44.8), FB 35.5
(33.6), DM 33.7 (31.6), AM 26.0 (23.6), WIDE 26.0 (23.8), ST 21.8 (19.5); the block 18.5 / 20.9 /
24.5 / 31.6 / 27.7 / 41.1 (17.0 / 18.9 / 23.0 / 30.7 / 26.6 / 40.2) — every role within 1-2.5 m on
both sides. New harness line POSSESSION SIDE, BALL STILL: by role, the share holding shape /
attacking the box / else, each at v target — holders stand ~1 m behind their targets, not 3.

**Next moles.** (1) Nobody plays on the shoulder: with the ball still 20-30 m out the real front
man is 1.2 m short of the line, 3.0 m beyond the ST mean; ours 3.9 short, 0.7 beyond — every man
stands at his role's mean spot, and the mean is not the man on the last defender. Real data first
(who the front man is, how long he stays there), then the job. (2) Runners in the box 18-35 m
(0.13 v 1.04) and crosses (0.19 v 11.47). (3) Law 8, Law 13 walls, cards. (4) Take-ons 83 v 18.

### 8.144 G5.44 — on the shoulder: measured, one try dropped (no behaviour change)

§8.143's next: nobody plays on the shoulder.

**Real** (new `scripts/benchmarks_tracking_shoulder.py`, DFL, the side in possession): its most
advanced outfielder stands 1.6-2.2 m short of their offside line (second-last, keeper in, or the
ball) at every band; within 2 m of it 35-54% of frames, 4+ m short 8-25%, past it 15-29%; the
second man 2.7-4.5 m behind him; he is the ST 29-73% (rising with distance), a wide man 18-36%; a
man stays the front man a median 2.2 s (p75 4.2). Every ST on: median 3.2-3.6 m short of the line,
p10 ~0.5, p90 ~12 — a wide spread; the nearer of a two-ST side's pair a median 1.9.

**The game** (new harness lines FRONT MAN v THEIR LINE and every ST's spread): front man 3.0-6.7 m
short, within 2 m 3-29%, 4+ m short 28-84%, past it 0-9%, the second man 4-8 m behind, the ST
64-99%. Every ST median 3.4-4.4 (real 3.2-3.6) but narrow: p10 1.2-2.4, p90 8.5-8.9 (0.5 / 12).

**Tried and dropped.** The striker's spot as their line less a roll from the real every-ST spread
(one roll a spell on the ball), with G5.30-style tracking of the line's velocity. His spread came
right (p10 0.7-1.1, p90 10.7-13.1) and holders sat on their targets (0.3-0.7 m), but his median
went 4.4 → 4.6-5.5 and the front man got no nearer (30-50 m: 4.2 / 4.5 → 4.9 / 5.2): the real spread
is EVERY state a striker is in (receiving, running in, checking), and laid on his holding target
alone it counts those again — §8.142's lesson on the ball. Shots 10.4 → 8.1, in behind 11.8 → 10.9.
Reverted; the measurement stays.

**What it says.** The real front man is near the line because several men are (second man 2.8 m
behind, a wide man a quarter of the time), and 15-29% of the time he is past it — the line stepped
up or he is running. Ours is one striker at a spot with nobody else near: the next try is the
movement (runs onto and off the line, the wide man's run in behind — balls in behind 11.8 v 37.7),
measured per state, not a spread on one target.

**Next moles.** (1) The runs in behind and onto the line (above). (2) Runners in the box at
18-35 m (0.13 v 1.04), crosses (0.19 v 11.47). (3) Law 8, Law 13 walls, cards. (4) Take-ons 83 v 18.

### 8.145 G5.45 — runs onto their line: measured, the run added at the real rate; the strip by the line is a standing matter (no migration)

§8.144's next: the runs.

**Real** (new `scripts/benchmarks_tracking_runs.py`, DFL [Bassek et al. 2025], the side in
possession against their offside line — second-last, keeper in, or the ball). *Men by gap*: a frame
holds 0.54-0.82 of ours 0-2 m short of the line and 0.59-0.87 2-4 m short (58% / 47% STs, 26% / 32%
wide men), 0.14-0.19 just past it. *Each role's gap* (p10 / median / p90, ball 18-35 m out): ST
0.5 / 3.2 / 11.8, WIDE 1.9 / 8.2 / 20.2, AM 2.1 / 9.4 / 19.8 — wide spreads. *Runs* (a man 0-12 m
short or past, at their goal 4+ m/s for 0.6 s+): 209 a team-match (WIDE 74, ST 62, DM 25, AM 23, FB
17, CB 8); start a median 8.4 m short, get to 3.9 (p25 1.5), last 1.8 s, 8.9 m forward, |dy| 2.2,
past the line only 7%. **80% come with the ball going forward 2+ m/s** (167 a team-match: the side
moving up with it); with it not, 41.7, at per eligible man-second CB .042, FB .024, DM .022, AM .011,
WIDE .015, ST .009, getting to (p25 / median / p75) ST 1.1 / 2.9 / 5.6, WIDE 1.9 / 4.5 / 7.4, AM
2.1 / 4.4 / 6.7, all 1.6 / 4.3 / 7.2.

**The game, before** (new harness lines MEN BY GAP, EACH ROLE's gap, RUNS): runs 181.5 a team-match
— by role WIDE 79, ST 64, AM 28 right — but they get to 7.5 m short (3.9) and last 1.2 s (1.8). Each
role's MEDIAN gap is right (ST 4.4, WIDE 9.2, AM 9.4 at 18-35); the spread is not (WIDE p10 5.0,
real 1.9; ST p90 8.8, real 11.8). The strip by the line is a third full: 0-2 m 0.19 a frame (0.73),
2-4 m 0.35 (0.87); a lump 8-10 m short (1.02, real 0.57). Named passes to a man 0-2 m short 0.8%
of all (real 8.0%) — which is why balls in behind are 11.8 (37.7): the real share in behind is by
the man's gap (50% at 0-2 m, §8.125) and ours are not there.

**The change** [FH, fitted to DFL]. A new job, RunLine (`Possession::assignRuns`, once a tick per
team after the box runners): a man of ours 0-12 m short of their line, the ball ours (carried or
on its way, as DFL's BallPossession) and not going forward 2+ m/s, not on the ball nor the pass's
man, not a box runner, starts a run at his role's real rate a second (`physics.run.rate_<role>`);
he runs straight at their goal to a gap short of the LIVE line rolled through his role's real p25 /
median / p75 (`physics.run.end_p25|p50|p75_<role>`, tails as far again, never past it less
`onside_margin_m`); a run under `physics.run.min_m` (3 m) isn't one; done there, after
`run_max_s` (4 s), or when the ball isn't ours, he is back in Support. Only the ball-still runs: the
ones with the ball going forward are the shape moving with it, which Support already does
(ours 143 v 167). `Possession::offsideLine` is the shared Law 11 line. New `Why::RunLine`.

**After** (8 × 90, scratch DB): RunLine starts ~20 a team-match (WIDE 11.8, AM 4.1, ST 2.8 — STs
already stand 3-4 m short, so few runs of 3 m+ are left for them); runs with the ball not going
forward 44.9 (41.7), getting to 5.2 m short (4.3); all runs 188 (209). The strip by the line barely
moved (0-2 m at 18-35: 0.19 → 0.22, real 0.73), in behind 11.8 → 11.5, shots 10.4 → 10.6.

**What it says.** The run is real and now ours, at the real rate — but runs are not what fills the
strip by the line: a real ball-still run is ~1.5 s, a few a man a match. Real men simply *stand*
nearer the line — the gap is two moving things (their line steps up and drops; ours hold, check,
drift) and it spreads; ours are two near-fixed spots, so the gap is narrow. The next try is the gap
itself, measured per state: how the real gap moves when THEIR line steps up or drops (do our men
hold their ground and let the line come to them?), and the checking movement off the line.

**Next moles.** (1) The gap to their line when it moves (above) — balls in behind 11.5 v 37.7.
(2) Runners in the box at 18-35 m, crosses (0.19 v 11.47). (3) Law 8, Law 13 walls, cards.
(4) Take-ons 83 v 18.

### 8.146 G5.46 — each man's depth for the possession: the gap spreads as real (no migration)

§8.145's next: the gap to their line when it moves.

**Real, the line moving** (new `scripts/benchmarks_tracking_linegap.py`, DFL [Bassek et al. 2025],
the side in possession, men 0-15 m short of their offside line 1 s ago, ball 18-52 m out). Their
line steps up or drops; our men move with it at a slope dA/dL of 0.74-0.92 by role (1 = keeps his
gap). They do NOT hold their ground and let the line come to them. With the ball not going forward
the line is still (±0.5 m) a quarter of the time and the front man's gap is 2.4 / 1.7 / 1.2 / 0.5 /
-0.1 m (line dropping 2+ … stepping up 2+).

**Real, what spreads the gap** (new `scripts/benchmarks_tracking_gapspread.py`). The ball's band
explains ~0% of a role's gap variance once the role is known. The ball's side v the man adds 0-3%,
the man (his match mean) 6-19%. **The possession** explains 78-88%: over spells of 5 s+ a man's
between-spell sd is CB 8.0, FB 8.6, DM 7.8, AM 5.9, WIDE 6.3, ST 4.2 m, against within-spell 2.8-4.5.
A man takes his own depth for the spell, little shared with his mates (corr 0.25 with their mean
offset in the same possession). Spell offset from his role's band median, p10 / p25 / p50 / p75 /
p90: CB -10.4 / -3.5 / 0.2 / 3.0 / 5.7; FB -12.4 / -6.9 / -1.1 / 5.0 / 10.5; DM -11.2 / -5.6 / -0.3
/ 4.6 / 9.2; AM -7.3 / -4.9 / 0.2 / 4.1 / 7.6; WIDE -5.8 / -3.7 / -0.3 / 4.1 / 9.4; ST -2.5 / -1.5 /
0.2 / 3.1 / 6.6 (+ = further from their line).

**The game, before** (new harness lines EACH MAN's SPELL, THEIR LINE MOVES). Slopes already right
(0.55-0.93), so following the line is not the miss. But between-spell sd is 2.0-4.0 (real 4.2-8.6):
every man stands on his role's one spot every possession, so each role's gap is narrow (AM p10 / p90
6.7 / 12.9, real 2.1 / 19.8) and lumps 8-10 m short (1.00 a frame at 18-35, real 0.57).

**The change** [FH, fitted to DFL]. `Possession` marks when a team's live spell on the ball starts
(ball ours, no restart, in play: DFL's BallPossession, ball in play). `Possession::spellDepth` rolls each man
one depth offset a spell (`detNoise` on the match seed, the spell's start tick and his slot),
piecewise through his role's real p10 … p90 (`physics.support.depth_p10|p25|p50|p75|p90_<role>`,
tails held at p10 / p90). `Possession::spot` adds it to the role's band spot, never past their goal
line. A new possession is a new roll.

**After** (8 × 90, scratch DB, rotating fixtures; before = the same build with the depth params at 0).
Between-spell sd CB 2.0 → 4.8 (8.0), FB 4.0 → 6.9 (8.6), DM 2.3 → 5.7 (7.8), AM 2.4 → 4.5 (5.9), WIDE
3.1 → 4.9 (6.3), ST 2.2 → 3.0 (4.2); within-spell now 2.8-4.3 (2.8-4.5). Each role's p10 / p90 at
18-35: AM 2.8 / 17.5 (2.1 / 19.8), WIDE 3.1 / 18.6 (1.9 / 20.2), FB 7.5 / 30.4 (6.9 / 35.4). The
8-10 m lump is gone (0.74 v 0.57). Runs: DM 2.6 → 24.6 (24.9), all 188 → 226 (209). Ball-still
runs 44.9 → 67.7 (41.7): a man moving to a new spell's spot counts as a run. Balls in behind 15.8
→ 17.2 (37.7). The strip by the line is barely fuller (0-2 m 0.22 → 0.26, real 0.73). Shots 10.6 /
10.5, goals 1.50. Goldens re-locked.

**What it says.** The gap's spread is now real, because the real spread is the possession, not the
moment. The strip by the line is still empty, so a frame's front man stands 1.2-5.3 m short (real
-0.1-2.4) and the ST median went 4.3 → 5.0 (3.2). A man rolled nearer than the line can't stand
there (onside), so the near tail piles up just short of it and the median slides back. Real front men
live within 2 m of the line. That is a target off the live line, not a depth off a spot.

**Next moles.** (1) The front man on the line: whoever is nearest it stands 0-2 m short of the
live line (DFL front man gap by line move, above) — balls in behind 17.2 v 37.7. (2) Ball-still
runs 67.7 v 41.7 (spell re-rolls read as runs; ease the new spot in?). (3) Crosses 0.44 v 11.47.
(4) Law 8, Law 13 walls, cards. (5) Take-ons.

### 8.147 G5.47 — the front man on their line, tracking it (no migration)

§8.146's next: the front man on the line.

**Real** (`scripts/benchmarks_tracking_shoulder.py`, now with the front man's gap quantiles; DFL
[Bassek et al. 2025]). The side in possession's most advanced outfielder stands p10 / p25 / p50 /
p75 / p90 -0.7 / 0.5 / 1.6 / 3.0 / 4.8 m short of their offside line with the ball 10-60 m out.
That is nearly flat by band (median 1.2-1.8). He is past the line 15-29% of frames and holds the
job a median 2.2 s. He moves with the line: his median gap is 2.4 / 1.7 / 1.2 / 0.5 / -0.1 m as
it drops 2+ … steps up 2+ (`benchmarks_tracking_linegap.py`, §8.146).

**The game, before** (G5.46). The right men were front men (ST / WIDE shares within a few points),
but at 3.6-7.3 m short (mean), within 2 m 6-21% of frames (real 35-49), 4+ m short 43-69% (10-21).
Every man stood off his role's spot, and the line only capped him.

**The change** [FH, fitted to DFL]. `Possession::assignFront`, once a tick per team after
assignRuns, names the front man while the ball is live and ours. He is our most advanced
outfielder who is not on the ball, not the pass's man, not a box runner and not on a run; he keeps
the job until a mate is `physics.front.swap_m` (1 m) further on. In Support his spot's depth is the
live line less his gap (`Possession::frontGap`): one roll a tenure through the real p10 … p90
(`physics.front.gap_p10|p25|p50|p75|p90`). The gap is never under `onside_margin_m`, because no
pass avoids a man past the line yet, and one past it is flagged when the ball comes. He keeps his
role's across.
**Tracking** (as the block's G5.30): `Brain::blockLead` hands brakeToArrive the line's own velocity
for him (`Possession::offsideLineVelX`: their second-last man's, or the ball's when it is past
him). He runs with the line and closes the gap on top. Without it he trailed the line every time it
moved: caught 2.1 m past it as it stepped up 2+ (real -0.1), 5.4 m short as it dropped 2+ (2.4).

**After** (8 × 90, scratch DB, the same fixtures and seeds as §8.146's after).
- Front man gap by the line's move (ball not going forward): -0.8 / 0.5 / 1.3 / 2.2 / 4.2 (real
  -0.1 / 0.5 / 1.2 / 1.7 / 2.4).
- Front man within 2 m of the line with the ball 40-70 m out: 36-39% (35-38). At 20-40 m out:
  30-32% (40-49).
- Past the line 7-13% (15-29). 4+ m short 25-33% (15-21).
- The strip by the line at 18-35, 0-2 m: 0.26 → 0.42 a frame (0.73).
- Balls in behind 17.2 → 20.2 (37.7). Offsides 0.3 → 0.5 a team-match (~1.1). Shots 10.5 → 10.4.
- Goldens re-locked.

**What it says.** The front man is now on the line as real ones are, in the median and as the line
moves. The tail is still long: 4+ m short a third of the time. Part of that is frames where the
most advanced man is a runner, the carrier or the pass's man, so he isn't the front man in Support.
In behind is still half real. Real passers play 50% of balls to a man 0-2 m short in behind
(§8.125), so the share of passes finding him is the measure to read next. Ours stand there now; is
the ball played to them?

**Next moles.** (1) In behind 20.2 v 37.7: passes named to a man 0-2 m short (§8.145 had 0.8% of
all, real 8.0%), re-read with the front man on the line. (2) Ball-still runs 67.9 v 41.7 (§8.146).
(3) Crosses 0.69 v 11.47. (4) Law 8, Law 13 walls, cards. (5) Take-ons.

### 8.148 G5.48 — the strip by their line, per man: measured (no behaviour change)

§8.147's next: is the ball played to the man on the line? First, how many men should be there.

**The role mix.** The 7 DFL matches' 14 sides start CB 2.21, FB 1.57, DM 2.07, AM 0.79, WIDE 2.00,
**ST 1.36** (two-striker sides are common). Our 20 PL 15/16 sides, in their own formations, field
CB 2.06, FB 2.00, DM 2.31, AM 0.75, WIDE 1.88, **ST 1.00** (8 × 90, new harness line ROLES ON).
The real strip 0-2 m short of their line is 58% strikers (`benchmarks_tracking_runs.py`), so its
count a frame (0.73 at 18-35) is partly a Bundesliga role mix. It is not a target for our sides as
it stands. The like-for-like measure is **a man of each role**: the share of his frames past
(-2..0) / 0-2 / 2-4 m short (new `benchmarks_tracking_runs.py` EACH MAN by role, new harness line).

| ball 18-35 | ours | real |
|---|---|---|
| ST  | 6.1 / 19.6 / 22.8 | 4.4 / 26.3 / 25.7 |
| WIDE | 2.2 / 6.6 / 9.3 | 1.6 / 8.6 / 13.1 |
| AM  | 1.9 / 7.1 / 11.7 | 1.1 / 7.9 / 11.8 |
| CB  | 0.0 / 0.0 / 0.0 | 0.6 / 2.6 / 2.1 |

With the ball 52+ m out, the wide man is 0.9 / 3.8 / 3.6 (real 2.1 / 7.0 / 10.0). Real per-man
rates on our role mix give ~0.62 men 0-2 m short a frame at 18-35. Ours is 0.42, so about a third
of the gap to 0.73 is the mix and two-thirds is behaviour: strikers 0-2 m short three quarters as
often as real, wide men two thirds, centre-backs never (real CBs up for a ball in play after a
set piece). By the same sum, passes named to a man 0-2 m short should be ~5% of all on our mix.
Ours are 3.2% (real 8.0% on theirs).

**Next moles.** (1) The pass to the man on the line: 3.2% v ~5% expected, in behind 20.2 v 37.7
(on their mix). (2) Wide men nearer the line, every band. (3) Ball-still runs 67.9 v 41.7.
(4) Crosses. (5) Law 8, Law 13 walls, cards. (6) Take-ons.

### 8.149 G5.49 — the second man on their line; the pass to the line man measured (no migration)

§8.148's next: the pass to the man on the line, and why the strip is thin per man.

**The pass, measured.** In a temporary chooser trace (4 × 90, not kept), a mate 0-2 m short of their
line is ground-safe 26% of the times he is a candidate (everyone else 53%); 60% of his candidacies
fall to `risk_weight`. That parameter was still its [FH] start, 0.25, never fitted, with completion
82.8% (79.1). Tried 0.4 / 0.6 / 0.8: completion 82.2 / 81.1 / 80.8%, passes to the man 0-2 m short
3.5 / 3.5 / 3.8% (3.2), in behind 21.1 / 22.9 / 22.5 (17.2). Completion barely answers, so it does
not identify the parameter. Even with no safety at all, the line man holds ~4% of candidate weight
(the zone-to-zone table split among the mates in his zone), about his share of men near the line.
So the pass is not the lever; how many men stand there is. `risk_weight` stays 0.25.

**Real, the second man** (`benchmarks_tracking_shoulder.py`, now with his quantiles; DFL). The
side's second most advanced outfielder stands 1.2 / 2.5 / 4.2 / 6.7 / 9.9 m short of their line
(p10 … p90, ball 10-60 m out), 2.7-3.4 m behind the front man. Ours stood 3.6-4.6 m behind him.

**The change** [FH, fitted to DFL]. `Possession::assignFront` now names two: the front man and the
second (the most advanced eligible man other than the front man, with the same swap_m to take the
job). The second man's spot depth is the live line less a gap rolled a tenure from the real
second-man spread (`physics.front.second_p10..p90`), never nearer than the front man's gap.
`Possession::onLine` marks both, and both track the line's velocity (§8.147).

**After** (8 × 90, the same fixtures and seeds as §8.148).
- Second man behind the front man 3.4 m at every band 20-50 (real 2.8-3.2; was 3.6-4.6).
- 2-4 m short a frame at 18-35: 0.56 → 0.61 (0.87 on their mix).
- WIDE 2-4 m share 9.3 → 10.7% (13.1). 0-2 m unchanged (0.43).
- In behind 17.2 → 19.8 (37.7). Offsides 0.5 → 0.8 (~1.1). Completion 81.4%.
- **Cost:** ball-still runs 67.5 → 84.7 (41.7). A man taking the second job crosses to it at the
  forward shape cap, 4.5 m/s, which counts as a run (4+ m/s at goal). G5.46's spell re-rolls do the
  same.
- Goldens re-locked.

**What it says.** The top two are now shaped as real ones, but the 0-2 m strip did not fill. The
front man is still within 2 m only 31-37% of frames at 20-50 m out (38-49), and 4+ m short 26-28%
(10-18). Those are frames where the most advanced man isn't in Support (the carrier, the pass's
man, a runner), or he trails a line dropping 2+ m in a second (4.2 v 2.4, §8.147).

**Next moles.** (1) Ball-still runs 84.7 v 41.7: a man whose spot jumps (a new spell's depth, a new
line job) should walk or jog into it, not sprint. Real runs are the few at 4+ m/s. (2) The front
man's 4+ m tail. (3) Crosses 0.88 v 11.47. (4) Law 8, Law 13 walls, cards. (5) Take-ons.

### 8.150 G5.50 — a line job walks into a jumped spot (no migration)

§8.149's next: ball-still runs 84.7 v 41.7.

**Measured** (new harness line BALL-STILL RUNS by his order at the start; `Brain::possession()` lets
the harness see the line jobs). Of 84.7 ball-still runs a team-match, the front man made 19.2 and
the second man 24.4: 43.6 from §8.147-8.149's line jobs alone. Then hold shape 19.9, attack the
box 11.0, RunLine 5.6. A man taking a line job, or whose tenure roll jumps, closed on his new spot
at the 4.5 m/s forward shape cap, and that reads as a run (4+ m/s at goal, 0.6 s+).

**The change** [FH, fitted to DFL's ball-still runs]. In `Brain::brakeToArrive`, a line-job man's
closing speed, on top of the line's own velocity, is capped at `physics.front.close_mps` (1.0),
**only with the ball not going forward 2+ m/s**. Capped always (tried first), the ball-forward runs
fell 167 → 112-145 (real 167.4) and the front man dropped back off the line. With the ball going
forward the shape moves with it, and real men run then. The line-velocity part is never capped:
he still keeps up with a moving line.

**Fit** (8 × 90 each, GAME_PARAMS). close_mps 1.0 / 1.5 / 2.0 → ball-still runs 43.8 / 47.5 / 49.8
(41.7). Ball-forward runs 167.9 / 159.4 / 164.9 (167.4). The front man's gap and shares are the
same at all three within noise (2.1-3.3 m short at 10-50 m out, as §8.149). 1.0 is taken.

**After** (close_mps 1.0 v §8.149).
- Ball-still runs 84.7 → 43.8 (41.7): front man 19.2 → 2.9, second man 24.4 → 1.6. The rest is
  hold shape 17.0, attack the box 11.4, RunLine 6.8.
- Ball-forward runs 167.0 → 167.9 (167.4).
- In behind 19.8 → 17.1 (37.7), within the 8-match spread of §8.147-8.149 (17-20).
- Shots 9.9 → 9.1. Completion 81.4 → 83.5% (79.1).
- Goldens re-locked.

**Next moles.** (1) The front man's 4+ m tail (30-33% of frames at 20-50 m out, real 10-18): the
frames where the most advanced man is the carrier, the pass's man or a runner. (2) In behind
17 v 37.7 (on their role mix). (3) Crosses 0.7 v 11.47. (4) Completion 83.5 v 79.1. (5) Law 8,
Law 13 walls, cards. (6) Take-ons.

### 8.151 G5.51 — the front man's deep tail: measured (no behaviour change)

§8.150's next: our most advanced man is 4+ m short of their line 26-33% of frames with the ball
20-50 m out (real 10-18).

**Measured** (new harness line FRONT MAN 4+ m SHORT; `Brain::teamOfSlot`, `Possession::frontSince`).
On those frames the most advanced man is:

| He is | Share | Mean gap |
|---|---|---|
| the FRONT job man (Support) | 67% | 6.3 m short |
| the pass's man | 10% | |
| a box runner | 7% | |
| the SECOND job man | 7% | |
| on the ball | 6% | |

So the deep tail is mostly the front man himself, short of his own spot. His target is 2.7 m short,
and he is 6.3 m short. The line is dropping away at 1.5 m/s and he moves at 1.8 m/s: ordered 2.3
(the line's velocity + a closing capped at §8.150's 1.0 m/s). The body delivers ~0.5 m/s less than
it is told, so he gains only ~0.3 m/s. He has held the job 1.3 / 3.1 / 6.5 s (p25 / median / p75).
Uncapped (close_mps 0, 4 × 90): ordered 3.2, moving 2.3, the tail 26-27% at 30-50 m out (32-33
capped). Ball-still runs double back (§8.150). The cap stays.

**What it says.** He only reacts to a dropping line. Real front men read it (the carrier looking up,
the line dropping as he does) and are with it at 2.4 m short as it drops 2+ (ours 4.2, §8.147).
That is anticipation, a bigger step, and in behind did not answer the front man's gap through
§8.147-8.150 (17-20 every run). Parked as a known gap.

**Next moles.** (1) **Crosses 0.7 v 11.47 a team-match**, the largest single miss left. (2) In
behind 17 v 37.7. (3) Completion 83.5 v 79.1 and passes 538 v 434 (61% to men 18+ m short v 53).
(4) The front man reading the line (above). (5) Law 8, Law 13 walls, cards. (6) Take-ons.

### 8.152 G5.51 — a ball in behind is played as real ones are, 50/50s and all (no migration)

§8.151's next: crosses 0.7 v 11.47 a team-match.

**Crosses are a symptom** (`benchmarks_statsbomb_passes.py`, StatsBomb PL 15/16, v the harness
PASS POLICY). Real sides play 18.6 open-play passes a team-match from 0-18 m out wide (29.6% of
them crosses) and 11.0 from 0-18 centre; ours 3.2 and 4.2. At the real cross shares, ours could make
~1 cross, so the miss is the ball reaching their last 18 m: 7.4 passes from there v 29.6. Ours play
far more in our own half (70+ m out centre 124 v 57). From 18-35 m out real sides play 20.3 a
team-match into the last 18 m, ours 9.3. A zone with no mate in it has no weight, and with the ball
18-35 m out our box holds 0.25-0.27 men (1.04 / 0.79 real). Box runners are drawn (0.71) but held
onside at ~20 m: their line stands just outside the box then.

**In behind, by where it is played from** (harness, DFL in brackets). The central 18-52 m balls
are real (18-35c 4.62 (4.79), 35-52c 4.94 (6.14)). The miss is deep, 52+ m out: 3.7 v 14.9, the
long ball over the top. Then wide 18-52: 3.4 v 8.4. Then inside 18: 0.4 v 3.4. A temporary trace
(4 × 90, not kept): of in-behind options from 70+ m out, 0.9% are lofted and safe by the race read
and 38% out of reach. From 52-70, 3.9% lofted and safe. So 68-77% were judged risky and weighted at
`risk_weight` 0.25. A real ball over the top is a 50/50; the race read says they win it, and it is
played anyway.

**The change** [FH, fitted to DFL]. A ball in behind the race read says they win is still a
candidate at `physics.behind.risk_weight` (its own, no longer the short pass's 0.25).

**Fit** (8 × 90 each). 0.5 / 0.75 / 1.0 → in behind 21.0 / 26.3 / 29.3 (37.7), completed 46 / 52
/ 50% (47.5). Completion is real at every value, so the read does not pick out the balls that fail.
Real passers' in-behind choice is by the man's gap alone (§8.125's shares). 1.0 is taken.

**After** (1.0 v §8.151).
- In behind 17.1 → 29.3 a team-match (37.7), completed 50% (47.5).
- From 70+ centre 1.12 → 3.25 (4.57). From 52-70 centre 1.94 → 4.19 (4.79).
- Wide origins still short: 18-35w 2.81 (4.43), 52-70w 1.25 (3.36), 70+w 0.31 (2.21).
- In the air 35% (58).
- Completion 83.5 → 80.7% (79.1). Shots 9.1 → 12.0. Offsides 0.7 → 1.1 (~1.1). Crosses 0.75.
- Goldens re-locked.

**Next moles.** (1) The ball into their last 18 m: men in the box with the ball 18-35 m out
(0.25 v 1.04, held onside outside the box), and wide men beyond their line. Crosses follow (0.75 v
11.47). (2) In behind from wide (a third of real) and in the air (35 v 58%). (3) Passes 548 v 434,
the extra in our own half. (4) The front man reading the line (§8.151). (5) Law 8, Law 13 walls,
cards. (6) Take-ons.

### 8.153 G5.52 — the block's depth for their possession: their line drops as real ones do (no migration)

§8.152's next: men in the box with the ball 18-35 m out (0.25 v 1.04).

**Real** (`benchmarks_tracking_box.py`, now with who is past the line and the line's spread; DFL).
With the ball 18-35 m out, only 8-15% of the side's men in the box are past their offside line.
On the frames they are there, the line stands 12.3 m off its goal (the median frame 18.8). Men
are in the box when the line has dropped into it. The line with the ball 18-35 m out is p10 / p25 /
p50 / p75 / p90 11 / 14 / 18 / 22 / 26 m off its goal, inside 16 m 35-38% of frames.

**Real, why it spreads** (new `scripts/benchmarks_tracking_linespell.py`). A defending line's
height goes about half by the possession, as §8.146 found for the attackers' depth: between-spell sd
4.2 m, within 3.6 (spells of 5 s+, ball 18-52 m out). The spell offset from the line's median at
the ball's band is -5.6 / -3.5 / -0.8 / 2.4 / 5.4 m (p10 … p90, + = higher).

**The game, before** (new harness line: their line's p10 … p90 and the share inside 16 m). With the
ball 18-35 m out, 14 / 16 / 19 / 22 / 25 m, inside 16 m 17-23% (35-38). With it 0-18 m out, a
median of 10-11 m (7-8): every block man stood on his band spot every possession, so the line
seldom dropped. Box runners were drawn (0.66-0.69) and held onside at ~20 m, outside the box.

**The change** [FH, fitted to DFL]. `DefendingBlock` marks when their live spell on the ball
starts (as `Possession` does for ours). `DefendingBlock::spot` adds one offset for the whole block
a spell: `detNoise` on the match seed, that tick and the team, piecewise through the real p10 …
p90 (`physics.block.line_p10..p90`). The table's spot is unchanged. The offset is full from 18 m
out and fades to nothing at 9 m [FH] (the fit is 18-52 only), and no man goes nearer than 1 m off
his line. `test_defending_block` holds the offsets at 0 to check the table.

**After** (8 × 90, the same fixtures and seeds).
- Their line with the ball 18-35 m out: 12 / 14 / 18 / 22 / 26 (11 / 14 / 18 / 22 / 26), inside
  16 m 32-33% (35-38). At 35-52 m out: 19 / 22 / 26 / 31 / 35 (19 / 22 / 27 / 33 / 37). At 0-18:
  median 9 (7-8).
- Ours in the box with the ball 18-35 m out: centre 0.26 → 0.37 (1.04), wide 0.29 → 0.39 (0.79).
- Passes from their last 18 m: 8.5 → 8.8 a team-match (29.6). In behind 29.3 → 28.6. Crosses
  0.75 → 0.44. Completion 82.3%. Shots 11.8.
- Goldens re-locked.

**What it says.** Their line now drops as real lines do, and more of ours stand in the box with it.
The box is still a third full at 18-35 and the ball still doesn't reach the last 18 m. Real box
presence at 18-35 m is lumpy: 60% of frames have none, 18% have 3+. Ours draw ~0.7 runners for
the zone whatever the line does.

**Next moles.** (1) How many go into the box when their line is deep. (2) The ball into the last
18 m (8.8 v 29.6 passes) and crosses. (3) In behind from wide. (4) Passes 548 v 434. (5) The
front man reading the line. (6) Law 8, Law 13 walls, cards. (7) Take-ons.

### 8.154 G5.53 — how many go into the box goes by their line (no migration)

§8.153's next: how many go into the box when their line is deep.

**Real** (`benchmarks_tracking_box.py`, the box shares split by their line inside 16 m or not;
DFL). With the ball 18-35 m out centrally, their line is inside 16 m on 35% of frames. Then the
box holds 2.71 men (0 / 1 / 2 / 3+ 5 / 20 / 25 / 49%); with the line 16+ m, 0.15 (90% none). Wide:
1.97 v 0.09. With the ball 0-18 m out the line is inside 16 m 97% of the time.

**Before.** `assignRunners` drew the count from the zone's unconditional shares, which already hold
the line's effect (a high line, an empty box). The onside clamp then held the runners out when the
line was high, so the effect counted twice. Box runners stood at a mean ~20 m target at 18-35,
outside the box.

**The change** [FH structure, DFL shares]. The count is drawn from the shares for the ball's zone
and whether their line (`offsideLine`) is inside `physics.box.line_deep_m` (16): `physics.box.kl_
<zone>_<deep>_<k>`. It is redrawn when either changes, or every 3 s as before. 3+ is still 3.

**After** (8 × 90).
- Box runners' target with the ball 18-35 m out: 19.7 → 15.7 m (inside the box).
- Ours in the box with the ball 18-35 m out: centre 0.37 → 0.41 (1.04), wide 0.39 → 0.47 (0.79).
  0-18 wide 1.53 → 1.36 (2.29).
- Passes from the last 18 m 8.8 (29.6). Crosses 0.69. In behind 27.8. Completion 80.7%.
- Goldens re-locked.

**What it says.** Who goes in now follows the line as it does in real play, but the box still holds
half the real men. A deep-line spell is short, and runners drawn at its start take seconds to get
there. Real deep-line boxes hold 3+ men half the time (ours cap at 3), and real box occupants
include men already there. The ball reaching the last 18 m is unchanged.

**Next moles.** (1) The ball into the last 18 m (8.8 v 29.6 passes a team-match): how does it get
there in real play (passes into zone 0/1 from 18-35, carries), and what do ours do instead (548
passes, the extra in our own half)? (2) Crosses 0.69 v 11.47 follow. (3) In behind from wide.
(4) The front man reading the line. (5) Law 8, Law 13 walls, cards. (6) Take-ons.

### 8.155 G5.54 — the ball into an empty zone ahead: down the line and crosses to space (no migration)

§8.154's next: how the ball reaches their last 18 m (8.8 v 29.6 passes a team-match).

**Real** (`benchmarks_statsbomb_wide.py`, StatsBomb PL 15/16). Spells starting wide (|y| 14+)
18-35 m out: 57.8 a team-match, let go from there 78% (0-18 wide 11%). Let go as, % of spells:
pass to 18-35 wide 30.2, to 35+ 16.9, to 0-18 wide 14.5 (70% completed), lost 13.3, to 18-35
centre 9.7, cross 7.0, to 0-18 centre 5.9, shot 2.2. From 18-35 wide, 14.1% of passes go into the
box zone and 13.7% into the wide channel 0-18 m out (`benchmarks_statsbomb_passes.py`).

**The game, before** (new harness line SPELLS STARTING WIDE, the same cuts). 28.1 a team-match. Let
go as: to 35+ 33.4%, to 18-35 centre 18.9, to 0-18 wide 7.6 (2.2 completed), cross 1.1. The pass
policy gives each end zone its real share, split among the mates standing in it. A zone with no
mate (their wide channel, the box: the usual case there) lost its share, and the options behind
and inside took it. Real passes into those zones go to space for a man arriving, and real crosses
land ~7.5 m out around the middle (§8.107, `benchmarks_statsbomb_cross.py`).

**The change** [FH, DFL / StatsBomb shares]. In the chooser, a zone with no mate in it, ahead of
the ball's band (or level with it, not the ball's own), keeps its real share as a ball into space.
- The spot: the band's middle depth (9 / 26 / 43 / 61 / 80 m out; the box: `physics.cross.depth_m`
  7.5), at y 0 for central zones or `physics.space.wide_y_m` (27) on the ball's side for wide ones.
- The receiver: the mate who gets there first (0.3 s steps; `physics.space.max_s`, 4.5).
- Into the box from wide it is a cross (lofted to the spot, `Why::Cross`). Otherwise a ground ball
  weighted to arrive as he does (as the ball in behind, `Why::InBehind`, so he runs onto it).
- Weight: the zone's share if the race read says we win, else `physics.space.risk_weight` (0.25)
  of it.

**Tried.** Capping his run at 1.2 / 2.1 / 3.0 s: crosses 0.56 / 1.00 / 2.31, completion 81.0 /
79.2 / 77.1%. Passes into the channel completed ~26% at every cap. A ball into space only when the
read says we win (weight 0): crosses 1.06, completion 79.4%, the mechanism gone, because the read
says we lose nearly every one. At 0.1: crosses 2.19, completion 76.2%.

**After** (8 × 90, v §8.154).
- Spells starting wide 18-35 m out 28.1 → 31.1 (57.8).
- Let go as: to 0-18 wide 7.6 → 14.5% (14.5), cross 1.1 → 6.8% (7.0), to 35+ 33.4 → 23.9% (16.9),
  to 18-35 centre 18.9 → 14.5% (9.7).
- From 18-35 wide into the box / channel 10.4 / 5.7 → 13.9 / 13.3% (14.1 / 13.7).
- Crosses 0.69 → 3.88 a team-match (11.47). Cut-backs 0.19 → 1.06 (1.03). Passes from 0-18 wide
  3.6 → 7.2 (18.6).
- In behind 27.8 → 40.8 (37.7), in the air 21% (58).
- **Cost:** completion 80.7 → 75.3% (79.1). Our passes into the channel complete 4.2 of 14.5%
  (real 10.2): defenders win them, and they do not go out (goal kicks 7.0, throw-ins 27.8 barely
  moved). Shots 11.8 → 10.1.
- Goldens re-locked.

**What it says.** The choice is now real: down the line and the early cross at the real shares.
The ball is not, because the spot is a fixed point in the zone. Real balls into the channel go where
a runner is beating his man (70% completed); ours go to the middle of an empty zone for whoever is
nearest, and a defender is nearer the spot.

**Tried after, dropped (G5.55 attempt, 7 Nov).** The spot on each mate's own line: the zone's depth
at his across, the first he wins by the race read, else the nearest man's (a cross held within 6 m
of the middle). Completion 75.3 → 73.9%. Channel passes completed 3.8 of 18.0% (still ~21%,
real 70%). Crosses 4.06, in behind 44.0. No better, so reverted. The spot is not the cause: the
ball is lost with his own line as the spot too. Next is to trace those passes (who meets them,
where, the receiver's order and speed on the way) before another change.

**Next moles.** (1) Trace the ball into space: why 70-80% of ours are lost (real 30%), so
completion comes back to 79.1. (2) Crosses 3.88 v 11.47: crosses
from 0-18 wide (passes from there 7.2 v 18.6) and corners (0.3 v 3.2; real crosses get deflected
out). (3) Spells starting wide 31 v 58. (4) Passes 492 v 434. (5) The front man reading the line.
(6) Law 8, Law 13 walls, cards. (7) Take-ons.

### 8.156 G5.55 — a ground ball into space only for a man who gets there first (no migration)

§8.155's next: why 70-80% of our balls into space are lost (real channel passes complete 70%).

**Traced** (new `Why::IntoSpace` for G5.54's ground ball into space: the receiver still runs onto it
as for a ball in behind, `Brain` notes it led; new harness line BALLS INTO SPACE). G5.54 played
65.1 a team-match, far more than the real ~8 into the wide channel. At the kick our receiver,
the first of ours by run time, stood 17.8 m from the spot and their nearest 11.5 m. Ends: him 32%,
a mate 18%, them 41%, out 8%. "Ours first" was first among ours, not first.

**The change** [FH, the real choice]. A ground ball into space is a candidate only if no man of
theirs gets to the spot before ours (the same run-time steps; `physics.space.margin_s`, 0). A
cross is not raced: real crosses are struck whoever is first (28% completed, 40% cleared next,
§8.107).

**Tried.** The race for crosses too: crosses 0.69, completion 79.4%. The cross went with it.

**After** (8 × 90, v §8.155).
- Completion 75.3 → 79.7% (79.1).
- Balls into space 65.1 → 17.2 a team-match. Ends: him 41%, a mate 6%, them 28%, out 25%. At the
  kick him 13.4 m from the spot, their nearest 15.1. His closest to the ball 2.4 m after 2.2 s.
- Crosses 3.88 → 3.56 (11.47). Wide spells: cross 5.2% (7.0); down the line 14.5 → 7.3% (14.5);
  back to 35+ 32.5% (16.9).
- In behind 40.8 → 29.2 (37.7). Cut-backs 0.50 (1.03). Shots 9.9.
- Goldens re-locked (the 3v3's unchanged: no wide zone ahead there).

**What it says.** Completion is real again with the cross kept. Down the line fell back to the
G5.53 share, because the ball we now play is only the one ours wins. A quarter of those roll out:
the ground ball is weighted to arrive as he does, at the arrive speed, and runs on past a man still
2.4 m off it.

**Found after: a physics limit.** A ground kick's speed is `weightedPassSpeed(carry_m)` =
`kPassArriveSpeed` (9 m/s) + (1 − r)/dt per metre of carry (`World.cpp`, GroundKick / ShortPass),
and carry_m ≥ 1. So the softest weighted ground ball is ~9.4 m/s, and it rolls ~24 m before it stops
(r 0.987 a tick at 30 Hz). Any ball into space shorter than ~21 m reaches its spot at 9 m/s and runs
on ~23 m unless it is met. A ball weighted to die at the spot needs a new kick encoding in the
World (a softer floor, or a target "stop here" distance). That is a core physics change touching
every pass, so it is a deliberate next step, not a tweak.

**Next moles.** (1) The ball into space that runs out (25%): a weighted ground kick that dies at
its spot (World kick encoding, above). (2) Down the line 7.3 v 14.5% and back 32.5 v 16.9%: real wide men stand in the
channel (0.20-1.35 men there, §8.153's box script), so the pass to feet there exists. (3) Crosses
3.56 v 11.47. (4) The front man reading the line. (5) Law 8, Law 13 walls, cards. (6) Take-ons.

### 8.157 G5.56 — a man in their wide channel when their line is deep (no migration)

§8.156's next (with the softer kick left for a deliberate World change): real wide men stand in the
channel, so the pass down the line to feet exists.

**Real** (`benchmarks_tracking_box.py`, the wide channels 0-18 m out, |y| 20.16+; DFL). With the
ball 18-35 m out, their channel holds 0.12 (centre) / 0.20 (wide) men a frame. With their line
inside 16 m that is 0.31 / 0.50; with it 16+, 0.02 / 0.01. 81-97% are on the ball's side. By
role (wide ball, a frame): WIDE 0.064, FB 0.045, DM 0.035, ST 0.031, AM 0.020. They stand 14-15 m
off the line at |y| 26-28. With the ball 0-18 m out wide: 1.35 a frame (0.31 with the line 16+).

**The game, before** (new harness line ours in their WIDE CHANNELS). With the ball 18-35 m out,
0.03 / 0.07. 0-18 wide 1.05 (1.35).

**The change** [FH structure, DFL numbers]. `Possession::assignChannel`, called with every box-runner
draw (the same zone and line-deep flag, §8.154), names the men who go to their wide channel on the
ball's side. How many: the real mean for the zone and the line (`physics.chan.n_<zone>_<deep>`,
whole part sure, the rest a roll). Who: the real role counts per man of the role, nearest the spot
first (`physics.chan.role_*`), never a box runner. Where: the real depth and |y|
(`physics.chan.depth_* / ay_*`), onside as the box runner (they run `AttackBox`; `channel()` gives
the channel spot, and `runnerIndex` counts only box runners).

**After** (8 × 90).
- Ours in their channel with the ball 18-35 m out: 0.03 → 0.08 (0.12) / 0.07 → 0.10 (0.20). 0-18
  wide 1.11 (1.35).
- Wide spells: down the line 7.3 → 9.9% (14.5), cross 5.2 → 6.7% (7.0), back to 35+ 33.4% (16.9).
- Crosses 3.56 → 4.12 (11.47). Cut-backs 0.50 → 1.06 (1.03). Completion 78.7% (79.1). In behind
  28.7. Shots 10.1.
- Goldens re-locked.

**Next moles.** (1) Back to 35+ from wide 33 v 17%. (2) Crosses 4.1 v 11.5: crosses from 0-18 wide
(passes from there 5.1 v 18.6) and corners (0.1 v 3.2). (3) The weighted ground kick that dies at
its spot (World encoding, §8.156). (4) Spells starting wide 29 v 58. (5) The front man reading the
line. (6) Law 8, Law 13 walls, cards. (7) Take-ons.

### 8.158 G5.57 — a ground kick that dies at its spot (World), and what it showed (no migration)

§8.156's physics limit, with James's go-ahead ("continue yes", 7 Nov): the softest weighted ground
kick was ~9.4 m/s and rolled ~24 m, so a ball into space ran past its spot unless met.

**The change, World** [FH physics]. `World::setAction` takes `die`. A GroundKick with it is struck
at `core::dieAtSpeed(carry_m)`, so its roll comes to rest carry_m away (v0 = d(1 − r)·30 / r, r
the 0.987 roll decay, capped at 20 m/s), instead of arriving there at `kPassArriveSpeed`. `Orders`
carries `die`, and `GameServer` passes it. Every other kick is unchanged (`die` defaults off).
New `test_ball` die_at_ground_kick_stops_near_carry: asked 8 / 15 / 25 m, it rests at 8.08 /
15.17 / 25.30 m.

**Used by the ball into space** (`Why::IntoSpace`). Tried in order (8 × 90 each):
1. **Die 2 m past the spot** (`physics.space.roll_m`). Out 29% → 0%, throw-ins 29.4 → 23.4 (19.9),
   but them 26% → 51%: a slow ball gives their man time, and ours is 4.0 m off it at his closest.
   The trace also showed balls into space played sideways or backward: a band's middle depth can
   be behind the passer in his own band. Now **forward only**, the spot 3 m+ ahead of the ball.
   With that: them 64%, completion 79.7%.
2. **Timed to reach the spot as he does** (the G5.54 weight), never softer than dying 2 m past it,
   struck die-at so it rests d_tot away. Out 30%, them 25%, him 39%. Completion 79.3% (79.1).
   Crosses 3.06, in behind 29.7, throw-ins 29.4. Taken: it is G5.56's ball with the backward ones
   gone and a floor on the weight.

**What it says.** The kick was not the cause. A slow ball is won by the man of theirs who gets to
it; a timed one is missed. Our receiver gets within ~2 m (closest 2.1 m after 2.3 s) and does not
take it, then it runs on. The miss is in the meeting: `Receive`'s meet point and his run onto a
ball that is still moving.

**Next moles.** (1) The receiver meeting the ball into space (2.1 m closest; in behind completes
46-54%, real 47.5, so the same meet works there; why not here?). (2) Back to 35+ from wide 28 v
17%. (3) Crosses 3-4 v 11.5. (4) Spells starting wide 28 v 58. (5) The front man reading the line.
(6) Law 8, Law 13 walls, cards. (7) Take-ons.

### 8.159 G5.58 — the receiver meeting the ball into space, and the ball into a man's path (no migration)

§8.158's next: our receiver gets within ~2 m of a ball into space and doesn't take it.

**Traced** (`GAME_BEHIND_TRACE`, now every tick of a ball into space once he is near it). Three faults,
all ours, none the kick's:
1. **Beside it, slowing.** He closed to 0.6-0.9 m and ran alongside a ball doing 5 m/s for a second,
   braking, outside the 0.5 m reach, until it crossed the touchline. `brakeToArrive` braked him to
   arrive at a meet point that itself rolled on.
2. **Back to the spot.** `Receive`'s led branch (G5.27) tested "the ball still behind him" on x only.
   Played across or down the wide channel, that stayed true after the ball had passed the spot, and
   he turned back to the spot with the ball 0.9 m from him running out.
3. **The wrong man.** With 1 and 2 fixed, the rest were balls to a spot 18 m *behind* the receiver:
   "ours first there" picked a man upfield who sprinted back across the ball's line at 7 m/s, at it
   0.1-0.2 s late, carried 2-3 m past.

**The changes** [FH].
- **Tracking** (`Brain::blockLead` / `brakeToArrive`). Meeting a rolling ball within
  `physics.receive.track_m` (3 m; 0 = off), he runs with the ball's velocity, less any part of it
  coming at him, and closes the gap on top of that. This is G5.30's tracking for the block (§8.128),
  applied to the ball.
- **Short of the spot** (`Receive`). The led branch holds only while the ball is still short of the
  spot it was played to (the spot minus the ball, dotted with its velocity, is positive).
- **Into his path** (`Possession`, the ball into space). A ground ball into space is never for a mate
  more than `physics.space.back_m` (2 m) past the spot. Crosses are unchanged.

**After** (8 × 90, v §8.158's numbers re-run).
- Balls into space 11.8 → 9.2 a team-match. Ends: him 39 → 41%, a mate 5 → 11%, them 25 → 35%,
  out 30 → 11%.
- Tracking and short-of-the-spot alone (without the path rule): out 25%, him 41%. The path rule did
  most of the work.
- Wide spells: down the line completed 2.9 → 5.2% (10.2), let go as down the line 9.2% (14.5); back
  to 35+ 31.7% (16.9); cross 3.8% (7.0).
- Completion 79.3 → 79.9% (79.1). Crosses 3.31 (11.47). In behind 30.6, completed 46% (47.5).
  Throw-ins 29.4 → 27.2 (19.9). Shots 11.1, goals 1.94.
- Goldens unchanged (neither 2000-tick rig meets a rolling ball within 3 m or plays a ball into space).

**What it says.** The ball into space now goes out about as often as a real one might (11%). Theirs
win more, 35%: men already past the spot no longer count, so the race is closer. A real down-the-line
ball goes into the stride of a man running past his full-back, and ours still go to a fixed spot
(|y| 27, the band's middle) rather than to where the runner beats his man.

**Next moles.** (1) Back to 35+ from wide 32 v 17%. (2) The ball into space to the runner's path
rather than a fixed spot (theirs win 35%). (3) Crosses 3.3 v 11.5 (0-18 wide passes, corners 0.3 v
3.2). (4) Spells starting wide 31 v 58. (5) The front man reading the line. (6) Law 8, Law 13 walls,
cards. (7) Take-ons.

### 8.160 G5.59 — the pass chooser's weights when a zone is held (no migration)

§8.159's next: from wide 18-35 m out ours play back to 35+ 32% of spells (17).

**Measured first** (a one-off counter in the chooser, 8 × 90, the passer in 18-35 wide). Of the
weight the chooser held: forward 3%, level 36%, back 35%, in behind 24%, into space 1.5%. The real
row (StatsBomb end zones) is 28 / 52 / 20. On average half the row sat in zones with no mate. The box
centre was empty 79% of these moments, the wide box 93%, his own wide zone 56%. The share of an empty
zone fell to whichever zones were held, and the zones behind him are always held.

**Real** (new: `scripts/benchmarks_tracking_passzone.py`, DFL 7 matches [Bassek 2025]: open-play
passes naming a Recipient, every man's zone at the kick, 25 Hz). From 18-35 wide, n 313: forward
18%, own zone 34%, level other 20%, back 27%. With his own zone empty (27% of passes): back 39%.
A real wide man with nobody beside him goes back too, but his zone is empty less often.

New: `scripts/benchmarks_tracking_zonemates.py` and the harness line **MATES BY ZONE** (5 Hz, the
man on the ball not counted). With the ball 18-35 wide, ours v real, mean (none):
- box centre 0.47 (72%) v 0.86 (58%);
- his own wide zone 0.63 (48%) v 0.84 (38%);
- 18-35 centre 2.87 v 2.47;
- 35-52 centre 2.94 v 2.13.

Ours are too central, too short of the box and too rarely beside him.

**The change** [FH method on DFL data]. The chooser picks only among held zones, so a zone's weight
must be its weight *when held*, not its share of all passes. The two differ most where occupancy
differs most: 35-52 centre is almost always held, so its share overstates it; the wide box is rarely
held, so its share understates it. The script fits that weight by iterative proportional fitting
over the real frames. A zone's weight is the probability of being picked divided by the summed weight
of the held zones, matched to the real Recipient zones. kappa = fit ÷ share is scaled so the cells
with 10+ passes pool to 1, clamped to 0.25-4. Cells under 10 passes are 1. `Possession` multiplies
`pass_to[oz][ez]` by `physics.pass.kappa_<o>_<d>` for a man standing in the zone. Balls into space
and in behind are unchanged. `physics.pass.kappa_on` 0 turns it off. From 18-35 wide: box 1.25,
wide box 3.2, level centre 0.53, 35-52 centre 0.51.

Caveat: kappa is DFL Recipient zones at the kick, applied to StatsBomb end-zone shares. It is the
nearest matched pair we hold; one source for both would be cleaner.

**After** (8 × 90).
- Passes from 18-35 wide (as played, end zones): forward 23.7 → 30.2% (27.8), level 42.7 → 34.9%
  (51.7), back 33.5 → 34.9% (20.3). Balls from there 20.5 → 23.8 a team-match.
- Wide spells: cross 3.8 → 8.6% (7.0), down the line 9.2 → 11.8% (14.5), back to 35+ 31.7 → 33.8%
  (16.9), to 18-35 wide 23.0 → 17.5% (30.2).
- Crosses 3.31 → 4.94 (11.47). Balls into space 9.2 → 11.9, got by him 46%.
- Completion 79.9 → 79.0% (79.1). Shots 11.1 → 9.4, goals 1.94 → 1.69 (8 matches; noisy).
- 11v11 golden re-locked; 3v3 unchanged.

**What it says.** Forward is now right, and back is not. Back is a support problem, not a chooser
problem: his own wide zone is empty half the time, and the level weight it should hold goes
elsewhere. The box runners are drawn about right (0.70 a moment v 0.79 real), but only 0.39 are in
the box when it counts.

**Next moles.** (1) Box runners drawn but not there: with the ball 18-35 wide, 0.70 assigned and 0.39
in (0.79), so do they arrive late, or does the onside cap hold them out? (2) A mate in his own wide
zone (0.63 v 0.84) and fewer central (18-35 centre 2.87 v 2.47, 35-52 centre 2.94 v 2.13). (3) Then
back to 35+ again. (4) Crosses 4.9 v 11.5. (5) Spells starting wide 32 v 58. (6) Law 8, Law 13
walls, cards. (7) Take-ons.

### 8.161 G5.60 — box runners: kept, nearest spot, gone as the pass is played (no migration)

§8.160's next: with the ball 18-35 wide, 0.70 box runners are drawn but only 0.39 are in the box
(0.79 real).

**Measured first** (a one-off per-runner counter in the harness, 4 × 90). Of runner samples with
the ball 18-35 wide:
- 14% at their spot. The rest were 12.8 m away (72% of that across the pitch), running 4.6 m/s.
- The onside cap clipped 32%. The cap is not the cause.
- 52% of runner time was in a run's first second, 79% in its first two. The ball stays in that
  zone 1.5 s.
- Their line drops inside 16 m 34% of the time (38% real), so the line is not the cause either.

The runs start too late and go too far. Three faults, all in `Possession::assignRunners`:
1. **Redrawn from scratch.** Every 3 s, every new zone and every flip of the line's depth
   re-rolled who runs as well as how many. A man halfway into his run was dropped and another
   started.
2. **Spots by slot number.** The k-th runner by slot index got the k-th spot (ball side, far side,
   middle). The far-side winger could get the near post and cross the whole box.
3. **Drawn as the ball lands.** The zone was the ball's, so a pass out wide started the runs only
   when it arrived.

**The changes** [FH].
- **Kept** (`physics.box.sticky`). A redraw rolls the count as before. Then the men already
  running (box or channel) are picked first, before the role weight.
- **Nearest spot** (`physics.box.spot_near`). At the draw, the n spots go to the n runners with
  the least total distance (n ≤ 3, every order tried), fixed for the run.
- **From the pass** (`physics.box.from_pass`). With our pass on its way, the zone is that of the
  man it is played to.

**After** (8 × 90, v §8.160's run).
- In the box, ours (real): ball 0-18 wide 1.76 → 1.95 (2.29), 0-18 centre 2.09 → 2.13 (3.45),
  18-35 wide 0.39 → 0.42 (0.79), 18-35 centre 0.36 → 0.41 (1.04).
- Runners with the ball 18-35 wide: at their spot 14 → 21%, gap 12.8 → 9.7 m, across share
  0.72 → 0.64.
- Wide spells: back to 35+ 33.8 → 30.3% (16.9), to 18-35 wide 17.5 → 21.9% (30.2), cross
  8.6 → 6.5% (7.0).
- Balls into space: them 34 → 26%, a mate 7 → 13%.
- Completion 78.6% (79.1). Shots 9.7, goals 1.69. Crosses 4.2 (11.5).
- Both goldens re-locked.

**What it says.** All three were wrong behaviour, and fixing them moved every box number toward
real, but only a little. The bigger fault is still there: runs die young (49% of runner time
under 1 s, ball 18-35 wide). A redraw with the line not deep rolls zero runners 92% of the time
(DFL `box_kl`), and the line hovering around 16 m flips `deep` back and forth. Real men attacking
the box are why the line drops; ours run only once it has dropped. Our most advanced man also
stands 2-4 m further from their line than the real one in every zone (18-35 wide 22.1 v 20.2,
0-18 centre 13.2 v 9.1).

**Next moles.** (1) What ends a box run (a zero roll, `deep` flicker, another state taking him),
and whether the count should follow the line's depth with a lag rather than per draw. (2) The most
advanced man 2-4 m short of their line. (3) Back to 35+ 30 v 17 (own wide zone 0.63 v 0.84).
(4) Crosses 4.2 v 11.5. (5) Spells starting wide 32 v 58. (6) Law 8, Law 13 walls, cards.
(7) Take-ons.

### 8.162 G5.61 — box runs: one roll per 3 s, deep hysteresis, men in the box stay, held through our restarts (no migration)

§8.161's next: what ends a box run, and whether the count should follow the line's depth with a lag.

**Measured first** (a one-off tracer in `assignRunners`, 8 × 90, every box run's end). 60% ended
with the ball lost or dead, 27% at a redraw that rolled zero, 11% at one that rolled fewer. Zone
changes set off 873 of the 1,310 redraws with a runner on. Each redraw rolled a fresh count, so
the ball moving one zone could cancel a man mid-run. Line-depth flips set off 235 more; 63% of
those rolled zero (the line hovering at 16 m).

**The changes** [FH].
- **One roll per 3 s of the spell** (`physics.box.spell_roll`; the channel count too). A new zone
  or a deep flip re-reads the count from the same roll through that zone's real shares. The count
  falls only where the real shares fall. Each zone's per-frame marginal is unchanged. One roll for
  the *whole* spell was tried first: it cut 0-18 presence (centre 2.13 → 1.92, wide 1.95 → 1.64),
  because spells that rolled low stayed near the box longest. The roll now refreshes every 3 s.
- **Deep hysteresis** (`physics.box.line_deep_out_m` 18). Once their line is inside 16 m it stays
  "deep" until it is back past 18 m.
- **Men in the box stay** (`physics.box.stay`). On a redraw, a runner already in the box keeps
  his run even if the count drops below the number of runners there.
- **Held through our restarts** (`physics.box.restart_keep`). With the restart ours, or the call
  still to come after their touch, the runners hold and nothing is redrawn. Before, every dead
  ball cleared them.

**Real** (new, DFL 7 matches [Bassek 2025]):
- `scripts/benchmarks_tracking_boxprior.py`: of the men in the box, the share already in it 2 s
  before is 68% (ball 0-18 centre), 74% (0-18 wide), 70% (18-35 centre), 71% (18-35 wide) and
  91% (35-52). They moved 3.6-5.8 m in those 2 s. Real box presence is men who are already there,
  not late sprints.
- `scripts/benchmarks_tracking_boxsince.py`: by seconds since the ball was last dead. With the
  ball 18-35 wide: <3 s 1.46 in the box, 3-6 s 0.92, 6+ s 0.70. With it 0-18 centre: 5.24 / 4.06 /
  2.97.

Both are new harness lines under IN THE BOX.

**After** (8 × 90, v a HEAD-equivalent run).
- Run ends at a redraw 38.6 → about 21%; ended with the ball lost or dead 60 → 74%; mean run
  2.1 → 2.8 s.
- In the box, ours (real): 0-18 centre 2.13 → 2.17 (3.45), 0-18 wide 1.95 → 1.77 (2.29),
  18-35 centre 0.41 → 0.45 (1.04), 18-35 wide 0.42 → 0.38 (0.79). This is within run-to-run noise:
  box presence did not move.
- Under 3 s from a dead ball: 0-18 centre 2.30 → 2.67 (5.24), 18-35 centre 0.43 → 0.65 (2.52),
  18-35 wide 0.50 → 0.50 (1.46). After a ball out off them we never had runners to hold.
- In the box 2 s before: 43-51% → 43-51% (68-91%), moved 6.0-7.0 m (3.6-5.8).
- Wide spells: back to 35+ 30.3 → 29.0% (16.9), cross 6.5 → 7.9% (7.0). Crosses 4.2 → 4.7
  (11.5), cut-backs 0.88 → 1.38 (1.03). Shots 9.7 → 9.2, goals 1.69 → 1.62.
- Both goldens re-locked.

**What it says.** All four were wrong behaviour, and fixing them stopped runs from being cancelled
by churn. They did not fill the box. The new lines show why. Of ours in the box, 80% are box
runners (ball 18-35 wide), and fewer than half were there 2 s before. Our box is fresh sprinters
arriving as the ball does. The real box is men who are already in it, walking (3.6 m in 2 s), and
loaded at every set piece. A draw on the ball's zone can't produce that: whatever the count, the
men start too late.

**Next moles.** (1) Occupancy, not runs: who stands in the box as a resting position (the
striker's home spot in the final third, held through zone changes and turnovers), against
boxprior's 70-91%. (2) Our set-piece shape: men into the box for our throw-ins, free kicks and
corners in the final third whoever touched it last (boxsince <3 s 1.46 v 0.50). (3) Their line
3 m high with the ball in the box (0-18 centre 11.4 v 8.7). (4) Back to 35+ 29 v 17. (5) Crosses
4.7 v 11.5. (6) Law 8, Law 13 walls, cards. (7) Take-ons.

### 8.163 G5.62 — support men follow their line in as it drops (no migration)

§8.162's next: who stands in the box as a resting position.

**Real** (DFL 7 matches [Bassek 2025]). Box presence is almost all "their line has dropped inside
16 m" (`benchmarks_tracking_box.py`, G5.53 lines). With the ball 18-35 wide: 1.97 men in the box
with the line inside 16 m, 0.09 without. With the ball 18-35 centre: 2.71 / 0.15. The men in it
stand 14.5 m out, on the line. New `scripts/benchmarks_tracking_linegaps.py` counts the side in
possession by metres short of their line. When the line drops (ball 18-35 wide), real men follow
it in: 0-5 m short 1.61 → 2.35, 10+ m 6.79 → 5.75.

**Measured first** (new harness lines, 8 × 90).
- In the box with the line inside 16 m (ball 18-35 wide): 1.13 (1.97). It drops about as often
  as real (30% v 38%).
- Ours 0-5 m short when it drops: 1.40 → 1.17, the wrong way. 10+ m short 6.76 → 7.21.

The Support spot is by the ball (`spot[role][band]`). A line deeper than usual for that ball
leaves every man where the table put him.

**The change** [FH, DFL table]. In `Possession::spot`, the line's usual depth for the ball comes
from new `scripts/benchmarks_tracking_linebyball.py`: the DFL mean in 5 m bins, interpolated
between bin centres (`physics.support.line_usual_*`). When the live line is deeper than that, a
man goes on by the difference. The weight is 1 at or ahead of the usual line, falling linearly to
0 at `physics.support.follow_line_m` (10) behind it. A higher line moves nobody, since the onside
cap already holds them. 0 turns it off.

**Tried, not shipped: `front.close_mps`.** With the line deep, the front man stands 8.4 m short
against a target of 2.2, and the second man 14.9 against 5.2. The 1 m/s close cap (§8.150) looked
like the cause. Refit 1.0 / 2.0 / 3.0:
- front gap 8.4 / 7.9 / 7.7;
- ball 18-35 wide in the box 0.42 / 0.54 / 0.57;
- ball-still runs from the line jobs 7.6 / 12.6 / 18.2, on a total already about 57 (41.7).

The cap is not the cause. The front job churns (in it p25 / median 1.3 / 3.3 s), so each new
holder starts several metres back. Left at 1.0.

**After** (8 × 90, v the run before).
- Ball 18-35 wide: in the box 0.38 → 0.52 (0.79); with the line inside 16 m 1.13 → 1.34 (1.97);
  0-5 m short with it deep 1.17 → 1.33 (2.35).
- Ball 18-35 centre: in the box 0.45 → 0.39 (1.04), within noise; deep 1.34 → 1.23 (2.71).
- 0-18: centre 2.17 → 2.10 (3.45), wide 1.77 → 1.84 (2.29).
- Ball-still runs from hold shape 28.9 → 21.8. Shots 9.2 → 10.7, goals 1.62 → 1.88 (8 matches;
  noisy). Crosses 4.2 (11.5).
- Both goldens re-locked.

**What it says.** Following the line is right, and it moved the wide numbers, but only the third
man on is free to follow. The front two are line jobs already, and they are the gap: target
2.2 m short, standing 8.4 m. The job passes on every 3 s, and the new man walks in.

**Next moles.** (1) Front-job churn: why the job changes hands every 3.3 s (box draws taking the
front men, the pass's man, front_swap_m 1 m), and the new holder starting 6+ m back. Measure
first. (2) Our set-piece box shape. (3) Their line 3 m high with the ball in the box (0-18 centre
11.2 v 8.7). (4) Back to 35+ 28 v 17. (5) Crosses 4.2 v 11.5. (6) Law 8, Law 13 walls, cards.
(7) Take-ons.

### 8.164 G5.63 — a busy front man keeps the front job (no migration)

§8.163's next: front-job churn.

**Real** (DFL 7 matches [Bassek 2025]). New `scripts/benchmarks_tracking_frontjob.py`: the front
man is the outfielder of the side in possession nearest their goal, not the man on the ball
(nearest it within 2 m). He keeps the role until a mate is h m further on. With h = 1 m:
- 192.5 hand-overs a team-match, one per 8.2 s in possession;
- tenure p25 / median / p75 1.4 / 3.0 / 5.8 s;
- why: the old man went on the ball 22.8%, dropped 22.8%, the new man came on 42.5%, drift 11.9%;
- at the hand-over the new man is 2.7 m short of their line (p25 1.2, p75 5.2), the old man
  3.8 m. The new man moved on a median 3.2 m over the last 2 s.

So real men hand over as often as ours did. What differs is that the next man is already near.

**Measured first** (the same cut as a new harness line, 8 × 90).
- Hand-overs 167.8 a team-match (192.5), tenure 1.0 / 2.6 / 6.0 s: the churn is real.
- On the ball 34% (22.8). The new man is 4.7 m short (2.7), the old 6.3 (3.8), and the new man
  moved on 6.1 m over 2 s (3.2).
- The engine's front JOB changed hands 183.9 a team-match. Why: the holder became the pass's man
  27%, a box runner 24%, was overtaken by a man just freed from those 23%, plain overtaken 21%. The
  new holder started a median 7.3 m short. The job went to a man 7 m back, then went back to the
  first man when he was free.

**The change** [FH]. In `Possession::assignFront`, a holder who is only busy for a moment (the
pass is his, or he is running into the box or a channel) keeps the job. Others still cannot take
it up while busy. Going on the ball still hands it on. `physics.front.keep_busy` (default on; 0
turns it off).

**After** (8 × 90, v the run before).
- The engine's job changes 183.9 → 90.8 a team-match, tenure 2.6 → 3.2 s. The pass's man and box
  runner causes went to 0-1%.
- Runs with the ball going forward 196.8 → 180.6 (167.4). Ball still 53.9 → 56.2 (41.7), within
  noise.
- The front man by the shoulder table: 4+ m short 30-35% (8-21% real), unchanged. The new man at
  the hand-over 5.0 m (2.7).
- In the box: 18-35 centre 0.39 → 0.44 (1.04), wide 0.52 → 0.54 (0.79). Shots 10.7 → 9.3, goals
  1.88 → 2.00 (8 matches; noisy).
- Both goldens re-locked.

**Traced** (1 match, the front-job holder every 0.2 s). In hold shape 88% of the time, and 3+ m
behind his spot in 27% of those frames. A lag lasts a median 1.6 s (p90 6.6 s), mostly with the
ball 50-90 m out. 65% of lag spells start with a new holder. He closes on the spot only about 1 m/s
faster than their line drops, and his actual speed is 2.8 m/s against 4.5 ordered (acceleration).

**Tried again, not shipped: `front.close_mps` 3.0** with keep_busy on. 4+ m short 30-35 → 28-30%.
Ball-still runs from the line jobs 12.7 → 23.0. Left at 1.0.

**What it says.** Keeping the job was right (the job no longer swaps for a pass or a run), but it
was not the gap. The front man lags because the man who takes over comes from further back than
real. Our second man stands 3.6-5.9 m behind the front man (real 2.7-4.1), so when the front man
gets the ball nobody near is ready to step in.

**Next moles.** (1) The second man's depth: why he stands 1-2 m deeper than his rolled gap, and
whether real side-in-possession men keep a third man near the line too. (2) Our set-piece box
shape. (3) Their line 3 m high with the ball in the box (0-18 centre 11.5 v 8.7). (4) Back to 35+
28 v 17. (5) Crosses 4.2 v 11.5. (6) Law 8, Law 13 walls, cards. (7) Take-ons.

### 8.165 G5.64 — tactics trainer step 1: each man says what he's doing (mig 1199)

docs/tactics-trainer.md step 1 (owner 11/9: Premier League sides teach first; nothing from the
club's tactic plans reaches a PL side). The trainer labels men in the board's vocabulary: the
`game_concepts` id the 🎯 Tactics board uses for a job (mig 1153).

**What the engine labels is what it runs.** `ai::Act` (Orders.hpp) names the clean engine's
out-of-possession behaviours by code, and `Brain::actOf` reads them from the man's state and the
orders he was just given:
- `press_ball`: PressBall, the one man on their carrier at the real stand-off (G5.25);
- `chase_ball`: ChaseBall, the loose ball's man (G5.21);
- `block_cover`: the deeper centre-back of the pair (G5.41);
- `block_recover`: his block spot 5 m+ goal-side of him (`physics.trainer.recover_m` [FH]), which he
  closes at the back pace first (G5.32);
- `block_spot`: his block spot by role and band (DFL).

Only while his side's phase is a defending one (block, transition to defend, their set piece), so
a loose ball in our own phase is not labelled. Keepers are not labelled. The label follows the
engine: a side that has just won the ball keeps its block labels until its phase flips. The engine
has no man-marking, cover-shadow or trap yet, so no label claims one.

**Which concept is a DB row.** New `game_engine_acts` (code → concept id, mig 1199):
block_spot → 67 compact-block, block_recover → 11 recover, block_cover → 2 cover, press_ball →
164 pressing-distance, chase_ball → 131 nearest-decides. fh-game loads it at boot
(`persistence::loadActConcepts`). Titles come from `game_concepts`, so the wording is the board's.
A new engine behaviour = a new code + a row.

**Wire 2.2.** A BRAIN entry gains `u8 concept` (the game_concepts id, 255 none). The new
CONCEPT_LEGEND (0x47) sends id, name and title on connect. The brain rows show the concept's title
(blue) in place of the decision name, and the engine's decision with the concept id when a row is
opened. Label only: never fed back into the sim, so goldens are unchanged.

Tests: codec round-trips (BRAIN concept, CONCEPT_LEGEND titles past the 40-byte NAMES cap); in
2000 ticks of 11v11, labels appear only in defending phases and never on a keeper, with at most one
presser a side.

Next: step 2, a practice match between two PL sides from their goal kick, separate from the live
match.

### 8.166 G5.65 — tactics trainer step 2: a practice match of your own (no migration)

docs/tactics-trainer.md step 2: two Premier League sides from their goal kick, separate from the
one live match.

**One process, rooms.** The live match keeps its socket path and its clock. `server::RoomRouter`
(Rooms.hpp) owns the real WebSocket transport and hands each client to a room by the request
target it upgraded on (`WebSocketTransport::requestPath`):
- `/game`: room 0, the live match, as before;
- `/game?trainer=1&home=<team>&away=<team>&gk=home|away`: a new room of that viewer's own.

Each room's GameServer sees a `RoomTransport` that sends to and closes its own members only, and
each room ticks at its own speed (`RoomRouter::step`: a running room on its own next tick, a paused
one on a 200 ms heartbeat). A practice room closes with its last viewer. At most 4 are open; a
fifth link, or a team that is not in `game_demo_teams`, is refused. nginx's `location = /game`
already passes the query, so there is no new container or route.

**The practice match.** `GameServer::Config::practice`: whoever is in the room runs it (the admin
capability, so the existing pause, speed and matchup controls work), and every match in it starts
from a goal kick (Law 16). `practiceStart` puts the ball at the front of the kicking side's goal
area and runs 300 ticks (10 s) with the taker held, so every other man takes the engine's own
shape for it. Then the room is paused: the coach sees the shape and plays it. A new matchup in the
room starts from its goal kick again. Teams and formations are the PL sides' own (as NEW_MATCH),
with a seed of their own per room.

**The link** (for the board's 🎮 3D view pill):
`/game.html?trainer=1&home=<game_demo_teams.name>&away=<…>&gk=away`. Names are URL-encoded; left
out, they are the live match's teams; `gk` defaults to away. The page shows a "Tactics trainer"
badge and the matchup button reads "Goal kick".

Not changed: the engine, the live match, the goldens. `GAME_SPEED=0` (flat out, never used live)
now runs room 0 paced at 100%.

Tests: the link parses (encoded names, defaults); a practice room starts paused on the away goal
kick after its 10 s, its viewer has the admin capability and gets the concept legend, and played on
the keeper takes it; a RoomTransport sends only to its own members. Smoke (a local fh-game on a
spare port): `/game` live at 100%, a trainer link paused, Chelsea v Arsenal, match id 1001, admin;
an unknown team refused; at 4× the room ticks.

Next: step 3, freeze and step. Every man labelled on the pitch with his concept and target, step
pass by pass, play on.

### 8.167 G5.66 — tactics trainer step 3: freeze, every man labelled, step pass by pass (no migration)

docs/tactics-trainer.md step 3. Freeze frame and play-practice-play are the design input.

**Every man labelled.** A trainer room turns the brain overlay on for all 22. Each man shows his
target (line and ring), the man he's acting on (dashed), and a label above him. Out of possession
the label is his concept's title from `game_concepts` (blue, §8.165); otherwise it's the engine's
decision (yellow). The same labels show in the live match's brain overlay. A paused room still
gets the labels: BRAIN_WATCH sends the last orders at once, and the pre-roll leaves them set.

**Step pass by pass.** New c→s STEP (0x48, admin, so the trainer room's viewer): from the freeze,
play on at the slider's pace until the pass ends, then pause again.
- `GameServer::stepWatch`, stage 1: the ball with its man (or dead, e.g. the goal kick) waits for
  it to go live and loose.
- Stage 2: it travels until a man has it or it goes dead.
- A tackle in stage 1 (a new owner without the ball going loose) ends the step too.
- 20 s at most.

The ⏭ Next pass button shows only while paused. ▶ plays on live.

Tests: STEP round-trips (0 = 1×). In a trainer room two steps each end paused with the ball owned
or dead. A live-match viewer can't step. Smoke (local fh-game, Arsenal v West Ham, their goal
kick): paused → step → 1× → paused 10.3 s later (the keeper's wait plus the kick), → step → paused
1.8 s later.

Next: step 4, copy a frozen moment to our tactics board (club API, one-way PL → board). Then the
trainer is as good as the engine's defending: the labels show only what it runs (block, press,
chase, cover, recover). Marking, cover-shadow and traps are engine work, and the realism moles in
§8.164 continue.

### 8.168 G5.67 — tactics trainer step 4, the game half: copy a frozen moment (no migration)

docs/tactics-trainer.md step 4 (owner: "except right to copy it over to … the event center"). This
is the one bridge, PL → our 🎯 Tactics board, never back.

`client.js trainerMoment()` builds the frozen frame in the plan frame of shared/tactics/
TacticGeometry.hpp:
- 0–100 from "us"'s view, x left → right as we attack, y 0 = our goal line, 68 × 105 m;
- left/right as the 3D view shows it (three.js z = game y: attacking +x, left is −y);
- each side's end from its keeper (ends swap at half time).

"Us" is the side whose men carry concept labels, i.e. the side without the ball. "Them" is the side
with it. The copy carries:
- their 11 by formation position number (the ROSTER numbers);
- ours with each man's concept id and target (the man he's acting on, if theirs);
- the ball, and ball_with: their man on it, or within 2 m of a loose ball;
- team names. The club server resolves formations from `game_demo_teams.formation_code`.

The 📋 Copy to our tactics button sits in the freeze beside ⏭ Next pass and POSTs to
`/api/tactic-plans/copies` (club session, footballhome-3c). That endpoint always adds a fresh state,
so nothing authored is overwritten. The endpoint went live in club commit 5092f607 (mig 1202) and the button is on. The reply names the plan ("Copied to our tactics: 4-2-3-1 v 4-3-3, high block"). The copy lands as a 📋 step under the plan's root, found with the board's "Ours:" formation dropdown. Concepts with no fitting job kind (11 recover without a target) come back as skipped and are counted on the button.

### 8.169 G5.68 — the away side turned 180°, not reflected (no migration)

Found by the trainer's first copy to the board (footballhome-3c, state 84). Ours came out right
(Arsenal 2 at x 74, 3 at 23). Theirs came out with West Ham's right side on our right: 2 at 84,
7 at 79, so our right-back met their right winger. The copy transforms all 22 men one way, so the
mirror was in the engine.

A formation's `base.y` is across the pitch as the side attacks (the club board's x, left → right,
`mapClubPosition`). Every spot reads it as world y, but the away side attacks −x, so its left is +y.
Its shape must be the home shape turned 180°: x and y both mirrored. Only x was (the spot tables
are by distance from our own line). So the away side played as a reflection, with its right-back on
its own left. Ends never swap, and the old `anchorFor` (which had the same flaw) has no callers.

The change: `Brain`'s constructor negates the away side's `base.y` once. Nothing else reads a
formation's y.

Effect: the away side's men stand on the flanks their numbers say, so facing sides meet (our 2 v
their 11). The real tables are side-symmetric, so the realism numbers barely move (8 × 90 v §8.164):
shots 9.3 → 9.8, goals 2.00 → 1.56 (noise), box 0-18 wide 1.63 → 1.80, front man 10-20 4+ m short
32% → 32%. Both goldens re-locked.

### 8.170 G5.69 — the trainer's goal kick: the keeper walks to the ball (no migration)

Found by the trainer's second copy (footballhome-3c, state 85). The away keeper was at his spawn
spot, out wide at midfield, with nobody within 9 m of the ball. `practiceStart` held the taker
completely through the 10 s pre-roll (empty orders), so the keeper never left the spawn line. Now
only his kick is held (`action = None`): he walks to the ball and waits for the coach. Test: after
the pre-roll, the away keeper is within 6 m of the ball (in a run 4.6 m off it, at his run-up). The
live match is not affected.

### 8.171 G5.70 — forwards out of possession: one stays up, another drops in (no migration)

§8.164's next: the second man's depth.

**Measured first** (new harness lines, 8 × 90; DFL in brackets).
- The front two by seconds since our spell began (`benchmarks_tracking_frontjob.py`, new cut). The
  front man is 7.2 m short of their line in the first 3 s (2.1), 6.6 at 3-6 s (2.1), 4.2 at 6-10
  (1.7), 2.4 at 10-20 (1.3). The second man behind him: 7.9 (3.6), 6.3 (3.1), 4.3 (2.5), 2.2 (2.1).
  Settled play is near real; the gap is the turnover.
- In the spell's first second, metres off their goal, their line / our front man: ball 70+ m out
  56.7 (50.5) / 65.6 (53.0); 35-52 32.9 (25.2) / 40.3 (27.7). Both are wrong. Their line is 6-9 m
  high, and our front man is further back still.
- Our block's most advanced outfielder (the man a turnover finds furthest up), metres off his own
  line: 38.4 (42.0) with the ball 0-10 m out, 38.8 (45.7) at 10-20, 42.4 (49.8) at 20-30, 47.8
  (53.6) at 30-40. Real: a striker 74% of the time.

**Real** (new `scripts/benchmarks_tracking_blockspread.py`). Each defending man's offset off his
role's mean spot, net of the block's own offset (line_q, G5.52), held over the opponents' spell. By
role p10 / p90: about ±7 m, and wider with the ball inside 20 m of goal, where one forward stays up
and another drops in (ST −15.9 / +13.2, AM −9.3 / +12.7, WIDE −8.7 / +12.3). Our block had no
per-man spread: every man stood at his role's mean, so the most advanced man was the mean striker.

(A first run of the script measured depth from the wrong goal, `half + x·g`. The tell was "the most
advanced is a CB 80%". Fixed before any number was used.)

**The change** [DFL table, FH scope]. `DefendingBlock::spot`: each forward (AM, WIDE, ST) adds his
own offset, one roll a man a spell of theirs, through the real p10 … p90.
- `physics.block.man_*` applies with the ball 25 m+ out, `man_near_*` inside 15 m, blended between.
- No fade near goal (the near-goal spread is the larger one).
- Defenders' rows are 0. Their real spread is who they mark, which the block doesn't model, and a
  random roll there is holes, not marking. With it on (all roles, corrected table), goals went 1.56
  → 2.88 and shots 9.8 → 13.4 with no gain at the front.

**After** (8 × 90, v the run before).
- Most advanced block man: 0-10 38.4 → 41.7 (42.0), 10-20 38.8 → 41.8 (45.7), 20-30 42.4 → 43.6
  (49.8), 30-40 47.8 → 48.4 (53.6). Further out, about as before and real.
- Second man behind the front man: <3 s 7.9 → 5.6 (3.6), 3-6 6.3 → 4.4 (3.1), 6-10 4.3 → 3.2 (2.5),
  settled 2.2 → 2.0 (2.1), 20+ 1.9 → 1.8 (2.0).
- Front man <3 s 7.2 → 6.7 (2.1), settled 2.2-2.4 → 2.1-2.3 (1.2-1.3).
- At the turnover, ball 70+: our front man 65.6 → 62.2 (53.0).
- Shots 9.8 → 9.1, goals 1.56 → 1.75 (noise).
- Goldens unchanged: the test rig's built-in formation has no forwards. test_defending_block holds
  the roll at 0, as it does line_q.

**What it says.** The second man is fixed when settled and much better at the turnover. The front
man after a turnover is still 4-5 m short, for two reasons. Their line is 6-9 m too high at the
moment we win it (the side in possession's back line). And the block's top man is still 4-6 m deep
with the ball 10-50 m out. `kRealSpotDm` is "settled, ball still" (G5.42), while blockspread's role
means (all frames) put the ST higher (45 v 40 at 20-30): transition frames, when forwards are still
up, aren't in the spot table.

**Next moles.** (1) Their line at the turnover, 6-9 m high: the possession side's back line height
when it loses the ball (DFL by ball band v ours). (2) The block's top man 4-6 m deep with the ball
10-50 m out: the spot table is settled and ball-still; transition frames. (3) Our set-piece box
shape. (4) Their line 3 m high with the ball in the box. (5) Back to 35+ 28 v 17. (6) Crosses 4.2 v
11.5. (7) Law 8, Law 13 walls, cards. (8) Take-ons.

### 8.172 G5.71 — the scrappy phase: real sides give the ball straight back; ours contest no high ball (no migration)

§8.171's next (1): their line 6-9 m high at the turnover.

**Measured first** (new harness lines, 8 × 90; real in brackets).
- The side in possession's own line (second-last, keeper in), m off its goal, in every possession
  frame: within 1-2 m of real at every 5 m ball bin (new `scripts/benchmarks_tracking_turnline.py`,
  DFL [Bassek 2025]). So the shape in possession is not the fault.
- In the last frame before it loses the ball, the real line is 2-7 m *below* its usual height for
  that ball (−6.3 / −7.4 / −4.6 / −2.2 by the ball's band 0-35 / 35-52 / 52-70 / 70+ m off its goal).
  The ball came forward 13-17 m in the 3 s before, and the spell was 2-5 s old (median). Ours: −0.9 /
  −0.7 / −2.4 / 0.0, spells 6-18 s old. Ours loses the ball in settled play. Real sides mostly lose
  it seconds after winning it, before the line has stepped up.
- Losses a team-match (ball to the other side in play): 98 (165). Counting only losses the winner
  keeps 2 s+ (DFL's flag can flicker): 80 (108). By the losing spell's age: <3 s 14 (68), 3-6 s 11
  (39), 6 s+ 73 (58). The whole gap is the short spells.
- Of spells won in play and kept 2 s+, lost again by 3 / 6 / 10 s: ours 2-12 / 13-24 / 23-39%, real
  13-20 / 40-50 / 55-62%.
- It is not bolder first passes. Real passes in the first 3 s after an open-play win go forward a
  little more than settled ones (median +5.2 m v +3.8) and complete *more* often (87.3% v 82.3%; new
  `scripts/benchmarks_statsbomb_loss.py`, StatsBomb PL 15/16). StatsBomb merges brief touches into
  the other side's possession, so its spell ages are not compared. Only the mix of how losses end is:
  passes ~65%, duels ~20%, miscontrols ~11%.
- With the ball in the air (1.5 m+) at the change: 4% of our short-spell losses, real 22%.
- Headers: aerial duels 18.4 a match (44.1, `benchmarks_statsbomb_aerial.py`), while 36.6 a match
  are headed with no one challenging. About as many balls are headed as real; few are contested.

**Real** (new `scripts/benchmarks_tracking_aerial.py`, DFL). Every high ball in open play (rose past
4 m since it was last under 0.5 m), at its first frame down through 2.4 m: 85 a team-match. The
nearest opponent to the ball, median, by its zone (m off the kicker's own goal) 0-35 / 35-70 / 70+:
2.0 / 1.6 / 1.2 m, and an opponent is within 2 m 50 / 57 / 65% of the time. Ours: 17.3 / 5.7 / 4.0 m,
4 / 12 / 24%. Our receiver is under the ball as often as real (1.9 m v 1.8 in midfield).

**The change** [FH, read from the DFL drop table]. `DefendingBlock::assign`: their high ball in the
air (`physics.block.contest_min_z_m`, 1.5 m; 0 = off) that their man meets first. Our nearest
outfielder to where he meets it (the race read's point; held until another is `switch_m` nearer) is
the chaser, and runs to that point, to contest the header or be on him as it lands (Brain::viewOf
`chase_to` = `contestAt`). Before, our chaser ran to where *he* could first take the ball, past their
man, so nobody challenged the meeting point. Coaching: compete for the first ball.

**After** (8 × 90, v the run before).
- Midfield high balls (35-70): nearest opponent 5.7 → 3.6 m (1.6), within 2 m 12 → 22% (57), both
  sides within 2 m 3 → 9% (39). Their final third (70+): 4.0 → 2.7 (1.2).
- Aerial duels 18.4 → 24.9 a match (44.1).
- Losses 98 → 106 a team-match (165); kept 2 s+ 80 → 88 (108). <3 s 14 → 16 (68), 3-6 s 11 → 12.5
  (39). Spells won and lost again by 6 s 13-24 → 15-27% (40-50).
- Shots 9.1 → 9.4, goals 1.75 → 1.56, completion 78.5 → 77.8% (79.1): noise.
- 11v11 golden re-locked (behaviour change); 3v3 unchanged.

**What it says.** The challenger goes every time, aims within 1.8 m of the drop and arrives at 5.6
m/s, but is still 3.7 m off when it comes down. He starts too far away: our block holds zonal spots
and marks nobody, so their receiver is free at the kick. The rest of the scrappy phase waits on that.
Two other findings from the same trace. Throw-ins are 25-44% of our high balls by zone (throws
looping past 4 m). And in our own third, short lofted passes come down with nobody of either side
near (kicker's side 6.6 m, real 1.7). The receiver meets them after the bounce.

**Next moles.** (1) Marking: the receiver of their high ball is free at the kick. Where is his nearest
defender at the kick, real v ours (DFL)? Defenders' spread off their spots is marking (§8.171). (2)
Throw-ins past 4 m: the throw's launch v real (DFL ball height after a throw). (3) Own-third lofted
passes landing where no one is. (4) The block's top man 4-6 m deep, ball 10-50 m out (§8.171 (2)).
(5) Our set-piece box shape. (6) Crosses 4.2 v 11.5. (7) Law 8, Law 13 walls, cards. (8) Take-ons.

### 8.173 G5.72 — marking: the man in his zone, goal-side (mig 1206, trainer label only)

§8.172's next (1): the receiver of their high ball is free at the kick.

**Measured first** (new `scripts/benchmarks_tracking_marking.py`, DFL events + tracking; new harness
line RECEIVER'S MARKER AT THE KICK). Completed open-play passes (DFL tags a Recipient of the passer's
own side only on completed passes; on lost ones the tag is the opponent who took it, dropped). The
receiver's nearest opponent where he stood at the kick, and every other outfielder of the passer's
side in the same zone (the men he could have picked).
- Flat passes: as real at every zone (midfield receiver 7.1 m v 8.3, within 2 m 4.6% v 4.5).
- High passes go to a *marked* man in real football: 4.7 m v 5.3 for his mates (midfield), within
  2 m 15.1%. Ours loft only to free men: 7.4 v 6.5 for his mates, within 2 m 4.8%. That is the
  passer's choice, a mole of its own.
- The mates column is the defence. Midfield is near real. In the final third ours are free: within
  2 m 9% v 19-22%.

**Real** (new `scripts/benchmarks_tracking_markers.py`, every 5 Hz frame, the side without it). Each
attacker's nearest defending outfielder by his metres off their goal, ball within 20 m of him / not:
inside 18 m 2.5 / 2.6 m median, within 2 m 39 / 37%, that man goal-side 73%. Each CB's nearest
attacker 3.2-5.0 m by the ball's band, within 3 m 47-24%. Ours (purely zonal block, nobody marks):
box, ball far 4.7 m, 13% within 2 m, goal-side 51%; CB 5.4-7.7 m, 23-6% within 3 m.

**The change** [FH, fitted to the DFL tables; coaching: goal-side, see man and ball].
`DefendingBlock::assignMarks`, in play on their ball. Every CB / FB / DM who is not the chaser,
presser or contester is paired with each of their outfielders (not the carrier: the presser has him)
within `physics.block.mark_r_<band>` of his *block spot* (his zone). Pairs are taken nearest first by
where our men actually are, one marker a man. A pair already on counts `switch_m` nearer and holds to
`mark_r + 2·switch_m`. New state `MarkMan` (Why::Mark, Act::Mark `block_mark`): stand
`physics.block.mark_d_<band>` off him on his line to our goal's centre, run with his velocity
(Brain::blockLead), face the ball. Bands by his metres off our goal 0-18 / 18-35 / 35-52 / 52+:
radius 12 / 8 / 8 / 6 m, stand-off 1.5 / 3 / 3 / 4 m.
- First cut (cost by spot distance) jumped the mark between men every few ticks. The spot slides with
  the ball, so a man 13-17 m away was given him. Markers were 5.7 m off their man, 43% goal-side.
- A wider stand-off (2 / 3.5) left the box loose with the ball far (28% within 2 m v 37).

**After** (8 × 90, v the run before; real in brackets).
- Attacker inside 18 m, ball near: 2.9 → 2.1 m (2.5), within 2 m 29.9 → 47.0% (39.0), goal-side
  52 → 59% (73). Ball far: 4.7 → 2.7 (2.6), 12.9 → 38.9% (36.7), goal-side 51 → 67% (72.5).
- 18-35: ball near 3.9 → 3.1 (3.8), a little tight; ball far 5.4 → 4.1 (4.6), 7.7 → 14.4% (13.3).
  35+ unchanged and near real.
- CB nearest attacker 5.4-7.7 → 4.4-7.1 m (3.2-5.0); FB 5.7-9.3 → 4.7-8.4; DM/CM 4.1-6.3 (4.1-5.7).
- Marked men in the box: 76% have a marker, 2.7 m off, 62% goal-side.
- Shots 9.4 → 9.8, goals 1.56 → 1.50, completion 77.8 → 78.3%: noise. Shooter's nearest opponent
  1.87 → 1.51 m.
- Aerial duels 24.9 → 22.0 (44.1); midfield high balls, other side within 2 m 21.8 → 16.1% (56.8).
  The markers stay on their men while the ball drops.
- Both goldens re-locked. New test: marking_nearest_in_zone_goal_side.

**Trainer** (mig 1206). `block_mark` → game_concepts 18. The BRAIN entry's `other` is the man he
marks, so a copied PL moment carries the job and its target. 18 is "man-oriented, follow him
anywhere"; the engine's is zonal with a man (hands him on), as the row's note says. Cover-shadow (27)
is not engine behaviour, so it has no row.

**Next moles.** (1) The aerial contest lost ground: their high ball's meeting point v the marker of
the man meeting it. Should the marker of the receiver be the contester? (2) The passer lofts only to
free men (real: to a marked target man, 4.7 m). (3) Goal-side 59-67% v 73 in the box: markers trail
runners. (4) CBs still 1-2 m loose with the ball 35+ m out. (5) Throw-ins past 4 m. (6) Own-third
lofted passes landing where nobody is. (7) Crosses 3.8 v 11.5. (8) Law 8, Law 13 walls, cards.

### 8.174 G5.73 — high passes: high at the real share for the pass's length, never a chip because the lane is shut (no migration)

§8.173's next (1) and (2): the aerial contest lost ground when marking landed, and the passer lofts
only to free men.

**Measured first** (new harness lines, 8 × 90, seed 1000; real in brackets).
- At a midfield high ball's drop (35-70 m off the kicker's goal) the other side's nearest man is
  their chaser 93% of the time, 3.5 m off it. The kicker's side's man nearest the drop has a
  marker only 8% of the time, 13.6 m off him. Nobody is marking the man it drops to, because he was
  picked for being free.
- HIGH PASSES (new; open play, crosses out, by the aim's metres off the passer's own goal): aimed
  in our own third 35.8 a team-match (3.3), 94% completed (57), median 22.8 m; aimed in midfield
  48.8 (26.3), 86% completed (46), 21.8 m (36.2); aimed in their third 26.1 (29.3), 40% (36).
  An aerial duel at the aim within 5 s: 1 / 5 / 6% (4 / 16 / 12).
- HIGH BY LENGTH (new; origin 35-70, length 0-10 / 10-20 / 20-30 / 30-40 / 40-50 / 50+ m): high
  11.7 / 18.0 / 23.3 / 29.1 / 34.6 / 16.4% (5.3 / 5.4 / 12.3 / 41.9 / 77.5 / 92.7). Those high
  passes completed 99 / 94 / 73 / 47 / 72 / 82% (50 / 51 / 46 / 47 / 49 / 40). Own third the same
  shape: short passes high 19-31% (5-14), 40 m+ passes 0-19% (90-98).

**Real** (new `scripts/benchmarks_statsbomb_highpass.py`, StatsBomb PL 15/16, 380 matches). Open-play
passes, crosses out. Whatever its origin, a pass under 20 m goes high about 5% of the time, 20-30 m
12-21%, 30-40 m 42-54%, 40-50 m 74-90%, 50 m+ 87-98%. A high pass completes 35-57% at every length
and origin; a ground pass of the same length 74-95%. An aerial duel (Duel "Aerial Lost" or any
`aerial_won`, either side) within 5 s and 6 m of a high pass's end: 16% aimed in midfield, 12% in
their third. A first window of 3 s missed half of them: long balls fly 2-3 s (median duel 2.9 s
after the kick, at the end location ±0.1 m).

So the length of a pass decides whether it goes high, not whether the ground lane is open. Ours went
high when a blocked ground lane had a loft the race read called safe: a chip over the presser to
a free man, nearly always arriving. Long passes stayed on the ground.

**The change** [StatsBomb table, FH scope]. `Possession` OnBall, a pass to feet (not the cross into
the box, not in behind, not into space): each mate is two candidates. On the ground, his share ×
(1 − high share). High, his share × high share. The high share is `physics.pass.high_<origin>_<band>`
(origin 0-35 / 35-70 / 70+ m off our goal, band middles 5 … 55 m, linear between, held past the ends).
- The race read sets each mode's risk, never the mode. An unsafe ground pass is × `risk_weight`
  (0.25, as before). An unsafe high one is × `physics.pass.high_risk_weight`, fitted 0.25 / 0.6 / 1.0
  → aerial duels 29.8 / 40.8 / 55.1 a match (44.1): 0.6. A high ball is a contest by nature, and as
  with balls in behind (G5.51) the read doesn't pick the ones that fail. Completion barely moves
  with it.
- Past the passer's loft range the high share is dropped, not handed to the ground. Nobody drives a
  55 m pass along the floor.
- The old roll (`pass_loft` by origin zone, then loft if safe) stays only for the ball into the box
  (the cross share). `physics.pass.high_0_0` 0 = the old behaviour.

**After** (8 × 90, seed 1000 v the run before; seed 2000 on v off in the second column).
- Aerial duels 22.0 → 44.6 a match; 24.4 → 47.2 (44.1).
- Origin 35-70, high by length: 5.4 / 8.1 / 19.4 / 45.1 / 67.8 / 36.8% (5.3 / 5.4 / 12.3 / 41.9 /
  77.5 / 92.7). Own third: 6.3 / 9.1 / 17.6 / 55.5 / 62.8 / 9.1% (5.5 / 5.2 / 14.3 / 53.9 / 90.2 / 97.9).
  50 m+ passes from our third 5.3 → 2.8-4.6 a team-match (9.5); the rest are in-behind and
  into-space balls, which have their own air share.
- High passes aimed in midfield 48.8 → 42.3 (26.3), completed 86 → 73% (46), 21.8 → 31.3 m (36.2),
  duel at the aim 5 → 24% (16). Their third 26.1 → 26.6 (29.3), 40 → 32% (36).
- Midfield high balls coming down: the other side within 2 m 16.1 → 23.8%, 20.6 → 28.1% (56.8); both
  within 2 m 5.7 → 10.7%, 9.4 → 14.0 (39.3).
- Passes completed 78.3 → 74.8%, 78.9 → 75.5% (79.1). Shots 9.8 → 8.4, 9.9 → 9.3; goals 1.50 → 1.69,
  1.69 → 1.25: noise.
- Both goldens re-locked. New test: pass_high_share_by_origin_and_length. A run is ~10% slower: every
  pass to feet with a high share now runs the loft race read.

**What it says.** The mode is real now, and the contest follows from it. Completion fell because the
pass *policy* is off. Our high passes aimed in our own third are still 30 a team-match (3.3), median
34 m: long lateral passes across our own third, which are now high at their real share for that
length. Our own-third passes run 20-40 m twice as often as real (68 a team-match v 26), and
switches are 26.9 v 10.7 a team-match (§8.160). The high ones still complete 74-94% there, so the
receiving end (first touch, duel outcome) is too kind to a lofted ball.

**Next moles.** (1) Long lateral passes in our own third: 20-40 m from 0-35 m out 68 v 26 a
team-match, switches 26.9 v 10.7. (2) High passes complete too often (own third 74-94% v 35-49):
the aerial receive and duel outcome. (3) Ground passes in their third complete 50-70% (real 74-87%).
(4) Throw-ins are 41% of midfield high balls: throws past 4 m. (5) Goal-side 59-67% v 73 in the
box. (6) Crosses 3.8 v 11.5. (7) Law 8, Law 13 walls, cards.

### 8.175 G5.74 — pass pick: a zone's share goes mostly to the nearer of the men standing in it (no migration)

§8.174's next (1): long lateral passes across our own third, switches 26.9 v 10.7 a team-match.

**Measured first** (new PASS PICK harness line; 8 × 90, seed 1000; real in brackets). The pass policy
gives each end zone its real share (G5.17+), then split it *evenly* among the mates standing there.
Take an open-play pass whose receiver's zone holds 2+ mates at the kick. By the passer's metres off
his own goal, 0-35 / 35-70 / 70+, the receiver is the nearest of them 28.5 / 36.4 / 38.5% of the
time. That is exactly the even-split rate, 30.9 / 36.8 / 37.7 (real 49.5 / 61.8 / 62.4). Wide to wide
with a mate on each flank, the far flank's man took half of every such pass.

**Real** (new `scripts/benchmarks_tracking_passpick.py`, DFL 7 matches, Bassek et al. 2025). Open-play
passes that name a Recipient, positions at the kick, on the pass policy's own zone grid. With 2+
mates in his zone the man it is for is the nearest 49.5 / 61.8 / 62.4% of the time (even 37-40). He
is 20.6 / 16.8 / 14.1 m off, against the zone's mean of 23.7 / 21.4 / 18.5. Wide to wide with both
flanks held, the passer's own flank gets it 95-100% (n 37 / 90 / 25). The share fits
e^(-d/lambda), d being the passer-to-man distance. By maximum likelihood, lambda = 15 / 10 / 8 m.

**The change** [DFL, FH original]. `Possession` OnBall splits a zone's share among its mates by
e^(-d/lambda) instead of evenly. Lambda is `physics.pass.pick_lambda_<origin>`, 15 / 10 / 8 m by the
passer's m off our goal; 0 = the old even split. The zone shares themselves are untouched.

**After** (on v lambda 0; seed 1000, then seed 2000).
- Nearest 28.5 / 36.4 / 38.5 → 41.3 / 54.5 / 54.9%; seed 2000 30.7 / 38.4 / 38.2 → 41.0 / 53.3 /
  60.1 (49.5 / 61.8 / 62.4). The lift over even is +10 / +17 / +18 points v real +12 / +22 / +24.
  Wide to wide, own flank 100% (95-100).
- Switches 32.6 → 20.2; 30.9 → 19.9 a team-match (10.7).
- Own-third passes 20-40 m 69 → 59; 64 → 66 a team-match (26). High passes aimed in our third 30.0 →
  24.4; 30.8 → 27.6 (3.3), still completing 93-95% (57).
- Passes completed 74.8 → 76.5%; 75.5 → 77.7% (79.1). Passes 473 → 495; 479 → 496 (434).
- Aerial duels 44.6 → 42.6; 47.2 → 41.1 (44.1). Shots 8.4 → 9.3, 9.3 → 10.0; goals noise.
- 11v11 golden re-locked; the 3v3 is unchanged. New test: pass_pick_lambda_by_origin.

**What it says.** A pass now goes to the man near the passer, as in the real game. Switches fell
by a third, but they are still twice real, and own-third 20-40 m passes barely moved. So the
far man is no longer the problem. The likely suspect, not yet measured, is where our men stand
when we have the ball in our third: the zone shares are real, but they send long balls whenever
someone is standing in a far zone. The high ones still nearly always arrive.

**Next moles.** (1) High passes complete too often (own third 93-95% v 57): the aerial receive and
duel outcome. (2) Own-third 20-40 m passes 59-66 v 26 a team-match, switches 20 v 10.7: where our
men stand when we have it in our third. (3) Ground passes in their third complete 50-70% (74-87).
(4) Throws past 4 m. (5) Goal-side 59-67% v 73 in the box. (6) Crosses 3.8-4.4 v 11.5. (7) Law 8,
Law 13 walls, cards.

### 8.176 G5.75 — high passes by direction: a long ball goes up forward, not across or back (no migration)

§8.175's next (1), high passes completing too often. Looked at where they come down first.

**Measured first** (8 × 90, seed 1000, G5.74; real in brackets). HIGH BALLS COMING DOWN in the
kicker's own third: 24.1 a team-match (15.5), and the nearest of the kicker's side is 17.7 m off
(1.7), the other side's 19.5 m (2.0); nobody within 3 m 63% (24). These are not contests at all.
Lofted balls drop into empty grass in our own third and our man runs onto them, hence 93% arrived.
New HIGH BY DIRECTION line: from our third, 30-40 m passes go high 52-56% whether forward, lateral
or back (real 73 / 12 / 4); from midfield 42 / 47 / 46% (64 / 21 / 8). G5.73's table is by length
only, and our long passes from deep are lateral far more often than real ones.

**Real** (`scripts/benchmarks_statsbomb_highpass.py --dir`, StatsBomb PL 15/16, 380 matches;
direction forward = within 60° of straight at their goal, back = within 60° of our own). A 30-40 m
pass from our third goes high 72.9% forward, 12.2% lateral, 4.4% back; 40-50 m 93 / 47 / (8
passes). From midfield 30-40 m 64 / 21 / 8, 40-50 m 84 / 69 / 21. From their third 63 / 39 / 14.
Under 20 m: 8-11% forward, 2-8% lateral, 2-3% back. A long ball goes up when it goes forward.

**The change** [StatsBomb table, FH scope]. `PossessionParams::highShare(own, len, dir)` reads
`pass_high_dir[origin][dir][band]` (`physics.pass.high_<o>_<d>_<l>`, permille; a cell under 30
real passes holds the shorter band's value, as the script prints it). Possession's pass to feet
passes the direction of the pass to its man. `physics.pass.high_dir_on` 0 = G5.73's length-only
table.

**After** (on v off; seed 1000, then seed 2000).
- Our third, 30-40 m high: lateral 51 → 23%, 59 → 21% (12); back 47 → 0%, 46 → 1% (4); forward
  56 → 65%, 52 → 59% (73). Midfield 30-40 m lateral 47 → 34% (21), back 46 → 4%, 33 → 15% (8).
- High balls aimed in our third 24.4 → 16.3, 27.6 → 17.3 a team-match (3.3), median 35 → 27 m
  (22.7). Coming down in our third 24.1 → 14.9, 24.5 → 15.2 (15.5): the kicker's side's nearest
  17.7 → 2.6 m, 17.6 → 3.1 (1.7), the other side's 19.5 → 6.2, 18.5 → 6.6 (2.0); nobody within
  3 m 63 → 38%, 62 → 40% (24).
- High passes aimed in midfield 36.9 → 32.8, 39.1 → 32.4 (26.3), completion unchanged 70-73% (46).
- Passes completed 76.5 → 76.8%, 77.7 → 76.3% (79.1). Aerial duels 42.6 → 38.4, 41.1 → 41.9 (44.1).
  Switches 20.2 → 20.5, 19.9 → 21.9 (10.7). Shots and goals: noise.
- 11v11 golden re-locked; the 3v3 is unchanged. New test: pass_high_share_by_direction.

**What it says.** The empty-grass drops in our own third are mostly gone: a ball coming down there
now has our man 3 m off, as real. Still 17 high balls a team-match are aimed into our own third
(3.3). The forward ones from deep stay short of real at 40 m+ (63% v 93), and 50 m+ passes from deep
are 3.4 v 9.4: we play the short-forward ball, not the long one. Midfield high passes still arrive
70% (46). That is the receive and the contest, unchanged by this.

**Next moles.** (1) Back passes of 40-50 m from midfield, 9-10 a team-match (real 0.3), most of
them high (30%): balls back to our keeper from the halfway line. (2) High passes aimed in midfield
complete 70-73% (46): the aerial receive. (3) Own-third 20-40 m passes 2-3× real; switches 20-22
v 10.7. (4) Ground passes in their third complete 50-70% (74-87). (5) Throws past 4 m. (6) Goal-side
in the box 59-67% v 73. (7) Crosses 4 v 11.5. (8) Law 8, Law 13 walls, cards.

### 8.177 G5.76 — our keeper takes his real share of the passes, not a whole zone's (no migration)

§8.176's next (1), 40-50 m back passes from midfield, 9-10 a team-match v 0.3.

**Measured first** (8 × 90, seeds 1000 and 2000, G5.75; real in brackets). New TO OUR KEEPER line,
passes by the passer's 10 m off his own goal: 31.7 / 31.8 a team-match to our keeper (7.8), 12-14
of them from 40-60 m out (1.2), 22-28% of those high. The cause: the pass policy splits each zone's
real share among the mates standing in it (§8.175), and when our back line pushes up the keeper is
often alone in the deep zone, so he takes all of that zone's share. The balls back to him from the
halfway line were the "40-50 m back passes" of §8.176.

**Real** (`scripts/benchmarks_statsbomb_gkpass.py`, StatsBomb PL 15/16, 380 matches; open play,
crosses out, the keeper's own passes out). The share of an outfielder's passes that go to his own
keeper, by his 10 m off his goal: 5.4% (0-10), 12.1% (10-20), 9.8% (20-30), 4.8% (30-40), 1.5%
(40-50), 0.4% (50-60), 0.1% past. 7.8 a team-match, median 16-41 m, 1-15% high, 96-100% completed.

**The change** [StatsBomb table, FH scope]. Our keeper is out of the zone split. He gets his own
weight: his real share s for the passer's bin (`physics.pass.gk_<bin>`, permille), set as
s/(1-s) of the summed weight of every other candidate actually on offer, after risk and the
in-behind split. As a bare share beside mates already cut by risk_weight, he won far above s (an
earlier try: 10-30 m out 15.6 a team-match v 4.1). If nothing else is on, he is the pass.
`physics.pass.gk_on` 0 = him back in the zone split.

**After** (on v off; seed 1000, then seed 2000).
- To our keeper 31.7 → 16.1, 31.8 → 15.1 a team-match (7.8). Share of the bin's passes now real
  every bin: 10-20 m 13.6 / 13.9% (12.1), 20-30 m 10.2 / 9.5% (9.8), 30-40 m 3.5 / 5.6% (4.8),
  40-50 m 1.4 / 1.1% (1.5), 50-60 m 0.3 / 0.2% (0.4).
- From 40-60 m out 12.4 → 1.4, 12.1 → 1.1 a team-match (1.2).
- Midfield back passes 40-50 m 9.6 → 1.2, 9.1 → 1.1 (0.3); 50 m+ 3.0 → 0.4, 3.2 → 0.1 (0.0).
- High balls aimed in our own third 16.3 → 9.1, 17.3 → 8.6 a team-match (3.3).
- Passes completed 76.8 → 76.4%, 76.3 → 76.7% (79.1); switches 20.5 → 20.7, 21.9 → 21.1 (10.7);
  aerial duels 38.4 → 39.1, 41.9 → 41.1 (44.1); goals 1.81 → 2.12, 1.75 → 1.69. Noise.
- 11v11 golden re-locked; the 3v3 unchanged. New test: pass_to_own_keeper_share.

**What it says.** The share is right; the count from 10-30 m is still 9.6 v 4.1 because we play
far more passes from there than real teams do: 36 a team-match from 10-20 m (11.8) and 46 from
20-30 m (26.7). That is the old mole (3), now isolated: our own-third volume, not who it goes to.

**Next moles.** (1) Pass volume from our own third, 10-30 m out ~3× / 1.7× real. Possession is
held there too long, or recycled there instead of carried or played long (carries 10 m+ 15 v 34.6;
50 m+ from deep 3 v 9.4). (2) High passes aimed in midfield complete 70% (46): the aerial receive.
(3) Switches 20-22 v 10.7. (4) Ground passes in their third complete 50-70% (74-87). (5) Throws
past 4 m. (6) Goal-side in the box 59-67% v 73. (7) Crosses 4.6 v 11.5. (8) Law 8, Law 13 walls,
cards.

### 8.178 G5.77 — the footstep body: velocity changes only through a planted foot (no migration; protocol 2.3)

James 11/10: "is it possible for movement of players to be completely depending on their legs? or are
we sliding them there and just making leg animations?" We were sliding them: a point mass whose velocity
relaxed toward the wanted one every tick (Locomotion.hpp), legs drawn after the fact by the viewer. He
chose, over full physics bodies (MuJoCo + RL from motion capture: no elite limb data to check it against,
GPU training, slow harness), a FOOTSTEP body: every part checkable against our data, cheap, and the
targets a full body could learn later. The first of seven slices (memory: body engine roadmap): footsteps
→ dribble touches → kicks off a plant foot → headers → keeper → body contact with fouls and cards → laws
by body part. Target: elite (PL) first, scaled down later.

**Measured first** — new BODY ENVELOPE line v `scripts/benchmarks_tracking_envelope.py` (DFL 7 matches,
outfielders, ball in play, v and a by central differences over ±0.24 s, the harness the same over ±7
ticks). Real p99 by speed: speeding up 4.4 m/s² from a walk falling to 2.4 at 7-8 m/s; braking ~5 flat;
lateral 4.2 rising to ~6; tightest turn at 5-6 m/s a 4.7 m radius. Ours (G5.76, seed 1000): braking p95
5-6 (real ~3), p99 6-7 (4.7-5.3); lateral p99 at 4-8 m/s 3.9-4.5 (5.8-6.1); turn radius at 4-5 m/s 4.5 m
(3.2). Time at speed: 19% at 4-5 m/s (9.3), 17% at 1-2 (32.0) — we run too much (a brain mole).

**The change** [FH original on Weyand 2000, Novacheck 1998, LIPM (Kajita 2001)]. `core::Footsteps`: each
player has two feet on a stride cycle — walking stride 0.75 + 0.55 v m, duty 0.62; running contact length
0.95 m, swing 0.50 → 0.34 s with speed, blended 1.9-2.6 m/s. `Body::accel` is the G4.51 law with the
footstep caps at his speed (the DFL p99 table, `physics.body.acc_/brk_/lat_<band>`, each scaled by his
own brake/turn against a 50-rated body's), and World applies it ONLY while a foot is down, at 1/cf of the
stride-average (cf = share of the stride with a foot down: 1 walking, 0.44 at 8 m/s), nothing in flight.
The fall of the speeding-up envelope with speed is the fall of the contact share (0.39 → 0.22 duty =
0.56×; real p99 4.4 → 2.4 = 0.55×). A foot lands half a contact ahead, 0.11 m to his side of his facing,
offset by −a/ω² (ω² = g/0.9 m: behind to speed up, ahead to brake, outside to turn); planted, it never
moves; in the air the engine re-reads where it will land. Standing, the feet stay put until the body is
0.3 m off them; a man set down 4 m away (a restart) gets new feet. `physics.body.steps_on` 0 = the G4.51
point mass. Protocol 2.3: an 11-byte feet tail per player on SNAPSHOT (PROTOCOL.md); players.js plants
the engine's feet exactly and swings each from where it lifted to where it will land (its own gait stays
for officials and 2.2 servers).

**After** (on v off; seed 1000, then seed 2000).
- Braking p99 6.0-6.9 → 5.0-5.7 every band (4.7-5.3); p95 5-6 → 4.7-5.1 (~3).
- Speeding up p99 inside the real envelope every band (e.g. 1-2 m/s 5.1 → 4.4 (4.2)).
- Lateral p99 at 4-8 m/s 3.9-4.5 → 4.1-4.7 (5.8-6.1): the body now allows ~6, the brain never asks;
  turn radius at 4-5 m/s 4.5 → 4.3 (3.2).
- Pressures 352 → 326, 361 → 333 a team-match (152). Aerial duels 39.1 → 35.6, 41.1 → 35.9 (44.1).
  Passes completed 76.4 → 75.2, 76.7 → 74.4% (79.1). Goals 2.12 → 1.69, 1.69 → 1.31.
- New tests: footsteps_velocity_changes_only_through_a_planted_foot (no change in flight, a planted foot
  never moves, flight at speed), footsteps_envelope_falls_with_speed, snapshot_feet_tail_round_trips.
  world_integrates_exactly now runs with steps off. Goldens re-locked (determinism, 3v3, 11v11).

**What it says.** The body is now right where the data can see it (braking and speeding up at the real
p99); what stays off is what the BRAIN asks of it — hard stops far too often (braking p95 5 v 3), sharp
turns at speed never (lateral 4.5 v 6), too much time at 4-6 m/s. Aerial duels fell: a man in flight can
no longer adjust under a high ball — the headers slice gives him a real take-off.

**Next moles.** (1) Dribble touches: the ball glued 0.4 m ahead; real carries touch every 0.7-0.9 s,
ball median 0.44 → 0.79 m ahead by speed (`benchmarks_tracking_carry.py`) — roadmap slice 2. (2) The
brain's braking (p95 5 v 3) and its turns at speed (lateral 4.5 v 6). (3) Time at speed 4-6 m/s twice
real. (4) Aerial duels 36 v 44. (5) §8.177's own-third pass volume.

### 8.179 G5.78 — dribble touches: the carried ball rolls, and he touches it (no migration)

Roadmap slice 2 (§8.178). James watching: "ball is stuck in player feet lol" — it was: World glued a
carried ball 0.4 m ahead of his facing every tick [v1], no touches at all.

**Real** (`scripts/benchmarks_tracking_carry.py`, DFL 7 matches: the possessing side's nearest within
1.5 m of a ball on the ground, the same man 1 s+, moving 1 m/s+). By his speed 1-2 … 7+ m/s: the ball
ahead along his travel median 0.44 → 0.79 m (p25 0.03 → 0.60, p90 0.93 → 1.24), 0.18-0.28 m to the side;
a touch about every 0.7-0.9 s (0.88-0.99 a second); between touches it runs out to a median 0.57 →
0.95 m. Pressed (an opponent within 3 m) it sits 0.1-0.2 m closer at low speed (1-2 m/s 0.26 v 0.47),
the same at speed. Open-play losses (`benchmarks_statsbomb_loss.py`, StatsBomb PL 15/16): by a
miscontrol 4.1 a team-match, by a duel / dispossessed 8.0.

**The change** [FH original on the DFL and StatsBomb tables]. A carried ball (not a keeper's, not a
held restart) now rolls under the same roll decay as any ball. He touches it when it is within 1 m and
back to his touch gap for his speed (the DFL p25, `physics.dribble.touch_<band>`; less the pressed
offset `press_<band>` with an opponent inside 3 m), or drifting off his line while still short of the
peak — never more than once in 0.3 s. The touch goes the way he is running, 30% steered toward his wish,
at the slower of his speed and his wanted speed (the G5.4 hold included) plus just enough to roll out to
the real farthest-ahead (`peak_<band>`) under the roll's own deceleration. Wanting to turn back at speed
he rolls it on along his run to die where his footstep braking stops him; under 1.5 m/s he drags it the
new way. A carrier whose ball is out of reach (0.9 m+) steers to it first (3:1 over the brain's wish,
which still thinks it at his feet). 2.5 m off he has lost it: loose. On receipt the first touch still
settles it at his feet for the control time (first touches: slices 3-4). A kick aims from where the
ball is. Off: `physics.dribble.on` 0. The viewer arms a small strike on each touch (the ball's velocity
jumps while he keeps it).

**Measured on the way** (seed 1000; each step diagnosed by logging every loss): touch aimed at the wish,
ball off his line → touched every 0.2 s, passes completed 75.2 → 61.1%; aimed at his run and kicks from
the ball → 64.5%; first touch settled → 69.7%, 30 losses a team-match to a heavy touch (4.1): all in the
G5.4 hold, whose scaled wish the touch never read → 11.9; a ball stopped dead behind a man still
running 4-5 m/s (braking ~5.5 m/s², 2.5 m to stop) → rolled on to where he pulls up → 2.0.

**After** (on v off; seed 1000, then seed 2000).
- Ball ahead at 3-4 m/s p25 / med / p90 0.30 / 0.40 / 0.71 m (0.35 / 0.59 / 1.06), 4-5 m/s 0.39 /
  0.57 / 0.79 (0.41 / 0.63 / 1.07); side 0.18-0.22 (0.24-0.25); farthest between touches 4-5 m/s 0.69
  (0.79); touches 1.1-1.6 a second (0.9-1.0); at 2-3 m/s short (0.26 v 0.52). At 5 m/s+ still mostly
  the settled first touch (a fast carrier has just received it).
- Lost to a heavy touch 0 → 2.0, 0 → 2.6 a team-match (4.1); stolen off his feet 2.4 → 7.3, 1.8 → 8.0
  (8.0).
- Passes completed 75.3 → 75.2, 74.8 → 74.4% (79.1); counter-press 36.4 → 38.1, 36.6 → 39.6% (21.0);
  carries 10 m+ 20.3 → 17.5, 18.3 → 16.2 (34.6); goals 1.69 → 2.00, 1.12 → 1.94.
- New test: dribble_ball_rolls_and_is_touched. Determinism golden re-locked; the AI goldens are unchanged
  (their 2000 ticks keep every carry inside a settled first touch).

**What it says.** The ball now leaves his feet the way an elite carrier's does, and losing it costs what
it costs in the Premier League: steals rose from 2 to the real 8 a team-match because a ball out in front
can be nicked. Touches come a little too often (1.1-1.6 v 0.9-1.0): the touch gap is the DFL p25, so a
ball slowing back inside it is touched at once — the next lever is the touch's own timing by step.

**Next moles.** (1) The first touch is still a settle at his feet for the control time — roadmap slices
3-4 (kicks off a plant foot, receiving). (2) Touch rate 1.1-1.6 v 0.9-1.0; at 2-3 m/s the ball sits
close (0.26 v 0.52). (3) Carries 10 m+ 16-18 v 34.6 a team-match (the brain). (4) §8.178's brain braking
and turns at speed. (5) Aerial duels 35 v 44.

### 8.180 G5.79 — kicks off a plant foot: ball in reach, the other foot down, strong foot and weak foot (no migration)

Roadmap slice 3 (§8.178). Until now a kick left the instant the brain asked, from wherever the ball
was, with no foot at all.

**Real** (`scripts/benchmarks_statsbomb_foot.py`, StatsBomb PL 15/16, 336 outfielders with 100+ footed
open-play passes; strong foot = the foot of most of them). 24.1% are left-footed. A man plays 12.7% of
his footed passes off his weak foot (p10 5.1, p25 8.9, p75 17.3, p90 24.2%); 13.8% of all passes, 21.9%
of open-play shots. Elite players choose when to use it, so it costs little: completion strong / weak
0-15 m 87.6 / 85.4%, 15-30 m 86.3 / 85.2, 30 m+ 58.8 / 54.2; shots on target and goals per shot level
(34.0 / 33.9%, 9.9 / 9.9%).

**The change** [FH original on the StatsBomb table and the footstep body]. Each man has a strong foot
(left at 24.1%) and a weak-foot habit drawn from the real spread (by slot and match seed until the
roster carries real feet). A kick he asks for picks its foot (weak at his habit's rate) and is struck
only with the ball within `physics.kick.reach_m` (1 m) and his OTHER foot planted (§8.178's feet); not
yet, it waits — still on the ball, still dribbling — up to `physics.kick.wait_ms` (500), carried tick to
tick (a new wish replaces it); never in reach by then, the wish is gone. A first-time ball needs only the
reach (he set his feet before it came). Struck after a wait, he re-reads his mate: the aim moves with the
receiver. Off the weak foot a pass strays `physics.kick.weak_deg` (3°) either side; shots don't. Held
restarts and keepers as before; `physics.kick.plant_on` 0 = off. The kicking foot goes on the wire
(players[i].flags bit5 = his left) and the viewer swings that leg.

**Measured on the way** (seed 1000): short-pass completion 85.0 → 80.2% with the plant on; re-reading
the mate on a delayed strike and the first-time exemption took it to 81.6. A split by set-up wait showed
the wait is not the cause: short passes struck at once complete 81.2%, after 1-3 / 4-8 / 9+ ticks 83.2 /
82.6 / 84.8.

**After** (on v off; seed 1000, then seed 2000).
- Weak foot 12.2%, 14.4% of passes (13.8). Completion strong / weak, 0-15 m 81.6 / 83.3, 80.4 / 82.0
  (87.6 / 85.4); 15-30 m 81.8 / 82.3, 81.0 / 84.2 (86.3 / 85.2); 30 m+ 51.4 / 51.0, 52.0 / 46.3 (58.8 /
  54.2). Off (no foot) 0-15 m 85.0, 83.0; 30 m+ 48.3, 51.2.
- 146 kicks a team-match waited for reach and a plant, 144 ms on average; 2.9 given up.
- Passes 466 → 446, 460 → 453 a team-match (434); completed 75.2 → 74.8, 74.4 → 74.1% (79.1).
- Lost to a heavy touch 2.0 → 4.9, 2.6 → 4.8 (4.1): waiting to strike he dribbles on. Stolen 7.3 → 8.6,
  8.0 → 8.5 (8.0). Goals 2.00 → 1.81, 1.94 → 1.69.
- New test kicks_strong_foot_share_and_plant (left share across 60 seeds, a kick only with the plant
  down). AI goldens re-locked (determinism unchanged: its scripted run has no kicks).

**What it says.** Every strike now stands on a planted foot with the ball in reach, and the foot it
comes off is a real footballer's foot. The heavy-touch losses land on the real rate because a man
setting up a pass is still on a rolling ball. Strong-foot short passes complete 2.6-3.4 points less than
with no plant model on both seeds, not because of the wait — a mole to find.

**Next moles.** (1) Strong-foot short passes 80-82% v 85 without the plant (and 87.6 real). (2) The
first touch: still settled at his feet for the control time — roadmap slice 4 with headers. (3) Real
feet per player (the roster's own strong foot and habit) instead of drawn. (4) Touch rate 1.1-1.6 v
0.9-1.0. (5) Aerial duels 35 v 44.

### 8.181 G5.80 — the first touch, measured and built, left OFF; the carrier chases his rolling ball (no migration)

Roadmap slice 4, first half (§8.178). A received pass still settles at the receiver's feet for his
control time (G4.92) — the last glue left.

**Real** (`scripts/benchmarks_tracking_firsttouch.py`, DFL 7 matches: a free ground ball 3 m/s+ that
nobody was within 1.5 m of for 0.4 s reaches a man — his closest frame over the next 0.32 s; CONTROLLED
= the ball leaves under 0.7× its incoming speed, 147 a team-match). Off the touch at a share of the
incoming speed p25 0.20 / med 0.33 / p75 0.48 (pressed, an opponent inside 3 m: med 0.47), about 2-4 m/s;
his gap to it 0.5 s later p25 0.59 / med 0.81 / p75 1.13 / p90 1.51 m (pressed 0.62 / 1.08 / 1.80 /
3.66), 1 s later 0.94; touched on along his line 59%, dead 26%, across 11%, back 5%; still his 1 s on
72% (pressed 46%).

**Built** (`World::firstTouch`, on receipt, a won tackle and a steal; `physics.first_touch.on`): the
ball off his touch the way he wants to go, to a gap drawn from the real spread (capped at p75: past it
the data is mostly slow one-touch passes and balls off a man), at the speed his body will have half a
second on (his footstep braking bounds how fast he sheds pace); standing he lets it die at the gap,
moving he gives it the dribble touch's push (§8.179). Steals and won tackles take it with the winner's
own touch instead of the old carrier's roll. A new FIRST TOUCH harness line (the same measure).

**Measured, step by step by logging every loss** (seed 1000; slice 3 had 4.9 heavy-touch losses, 8.6
steals): a third of the incoming pace for a receiver standing waiting → 33 losses a team-match, 18
steals; the half-second gap instead → 26; the follow-up touch one tick later read the hold's ease-up
→ the first touch counts as his touch, and every touch plays it at the speed he can actually be at;
"a touch never adds pace" left a man running onto a still ball behind → removed; steals kept the old
carrier's roll (5-8 m/s) → the winner's touch; the gap's tail capped; the reflex chased at the hold's
pace → at least the ball's; a ball he runs past re-touchable after 0.1 s → 15 losses, 16 steals,
kept 1 s 54% (72.3).

**Why OFF.** Two-thirds of what is still lost has his wish pointing away from where the touch sent it:
at the moment of the touch the brain's wish is still "go to the ball". A real receiver's oriented touch
goes where his NEXT action wants it; our brain decides that only once he has it. The first touch needs
the brain's decision before the ball arrives — that is the next step, not more tuning here. Until then
the settle stays, and the general fixes found on the way stay on:
- a carrier chasing his rolling ball goes at least as fast as it (+15%), not at the hold's pace;
- a ball he is running past (behind him, in reach) can be touched again after 0.1 s, not 0.3;
- a dribble touch plays it no slower than his body can be half a second on.

**After** (G5.79 v G5.80 with the first touch off; seed 1000, then seed 2000). Lost to a heavy touch
4.9 → 2.7, 4.8 → 3.4 a team-match (4.1); stolen 8.6 → 9.1, 8.5 → 8.7 (8.0); passes completed 74.8 →
75.2, 74.1 → 74.6% (79.1); FIRST TOUCH (settle): gap 0.5 s 0.40 every time (0.81), kept 1 s 58-59%
(72.3). Goldens re-locked (determinism, 3v3, 11v11).

**Next moles.** (1) The receiver's next action decided before the ball arrives, so the first touch can
go where it is wanted — then `physics.first_touch.on`. (2) Headers and aerial duels (35 v 44): roadmap
slice 4's second half. (3) Strong-foot short passes (§8.180). (4) Real feet per player.

### 8.182 G5.81 — the first touch waits for his carrier wish and is played from where his body will be; pressed, his line comes from the real pressed touches (no migration)

The §8.181 mole: at the touch his wish was still the receive's ("meet the pass").

**Built.**
- **The touch waits one tick** (`physics.first_touch.defer`, 33 ms): the receipt is in `tickFreeBall`,
  after the carry step, so on the next tick his intents are OnBall's — the touch is played then, the
  ball sitting where he met it meanwhile (a tackle won this tick: next tick too).
- **From where his body will be** (`physics.first_touch.body`): his velocity goes toward his wish at the
  footstep caps (§8.178: braking shedding pace, speeding up otherwise) for 15 ticks; the ball is played
  to that spot plus the real gap the way he wants to go, timed to be there in the half second (standing
  at the end, let die there). Traced first: with the wish in but the touch from where he stood, 51
  heavy-touch losses a team-match — running in at 5 m/s, a touch the other way that dies a metre off
  is 2.5 m behind him before he has stopped. Now a man still running the wrong way plays it on along
  his run and turns with it (the real touch goes along his line 59%).
- **Pressed, his line** (`Possession` carryDir, `physics.onball.press_*`): a man of theirs inside 3 m,
  the line he carries it on is drawn once a spell from the real pressed first touches — new
  PRESSED TOUCH measure (`benchmarks_tracking_firsttouch.py`, DFL controlled first touches with an
  opponent inside 3 m, 10.0 a team-match): the touch's line v the line to him, toward (< 60°) 14%,
  across 27%, away (> 120°) 56%, still 2%; 0.5 s on the ball is nearer him than the receiver 19%, his
  gap to it med 2.16 m. A line already in the drawn cone stays; else it turns, on its own side of the
  man, into it. "At goal + 0.7 × away" (G5.29) still pointed into a marker standing goal-side. In the
  brain, not the touch: put in the World's touch alone (traced), the ball went away from the man while
  his wish ran at goal — steals 21 → 13, heavy-touch losses 11 → 36. The brain decides; the World plays it.
- Harness: a PRESSED TOUCH line (the same measure). Test `first_touch_from_where_his_body_will_be`
  (running in, turning back: worst gap 0.91 m v 1.65 from where he stands).

**Measured** (8 matches, seed 1000; real in brackets). First touch ON: G5.80 → defer → + body → + pressed
line: lost to a heavy touch 15.1 → 51 → 10.9 → 9.9 (4.1); stolen 16.4 → 15.7 → 15.7 → 13.0 (8.0);
completion 73.5 → 69.9 → 72.9 → 74.0 (79.1). With it off: 2.7 / 9.1 / 75.2. **Still OFF** —
`physics.first_touch.on` stays 0; the defer and the body ride along for when it goes on.

**After** (first touch off; pressed line off → on; seed 1000, then 2000). Stolen 9.06 → 8.19, 8.69 →
7.88 (8.0); heavy-touch losses 2.69 → 3.94, 3.44 → 3.06 (4.1); completion 75.2 → 74.1, 74.6 → 75.0
(79.1); kept 1 s 59.0 → 57.4, 57.8 → 57.1 (72.3). 11v11 golden re-locked (3v3 unchanged).

**The mole under it.** PRESSED TOUCH: our receivers have a man inside 3 m at a controlled first touch
50-56 times a team-match (10.0) — five times real (pressures already read 2× real, §8.178). Most of what
the first touch loses (and the steals) is a receiver met by a man real defenders don't have there.
The out-of-possession side's distance to the receiver at the receipt is the next measure, before any
more touch work.

**Next moles.** (1) Defenders on the receiver at the receipt (5× real). (2) Then the first touch on,
with what is left of the heavy touches (a man outrunning a ball rolling 1-2 m/s on his line; a touch
running 6-8 m/s ahead). (3) Headers and aerial duels (§8.181). (4) Strong-foot short passes (§8.180).

### 8.183 G5.82 — their pass: nobody chases what their man reaches first; the presser steps out as it travels (no migration)

The §8.182 mole: our receivers had a man inside 3 m at a controlled first touch 50-56 times a team-match
(10.0). That harness line counted every ball that became a man's, scrambles included; matched first.

**Real** (`benchmarks_tracking_firsttouch.py`, new RECEIVER SPACE block; DFL 7 matches, the same
receptions as FIRST TOUCH: a free ground ball 0.4 s+, 3 m/s+, reaching a man). Controlled, 146.8 a
team-match: the receiver's nearest opponent at the touch 0-1.5 / 1.5-3 / 3-5 / 5-8 / 8+ m = 2 / 4 / 10
/ 23 / 60% (med 9.25), at the release (the first free frame) 1 / 2 / 5 / 15 / 77% (med 11.94). From a
mate's pass (134.2) inside 3 m 5.5%; by the ball's travel 0-10 / 10-20 / 20-30 m, 10 / 5 / 2% at the touch,
4 / 1 / 1% at the release. The man nearest at the touch was 0-5 / 5-10 / 10-15 / 15+ m off at the
release 5 / 25 / 36 / 33% of the time and closed 1.07 / 1.68 / 2.99 / 4.58 m while the ball travelled.

**Ours, matched** (new harness RECEIVER SPACE, the same cuts; G5.81, seed 1000): 181 controlled a
team-match; from a mate's pass inside 3 m 16.1% (5.5) — 3×, not 5×. By travel 12 / 18 / 22% at the
touch (10 / 5 / 2) but 8 / 6 / 5% at the release: on a 10-30 m pass our man got to the receiver while
the ball was on its way. The man inside 3 m was chasing the ball 43%, meeting it 23%. Our first man to
their pass (`DefendingBlock::assign`, G4.81) ran to where HE could first take it — down its line,
past their receiver, onto him — whoever the race read said got there first.

**The change** [FH original on the DFL tables; coaching: "don't dive in — press as the ball travels"].
- **No chaser for a pass they win** (`physics.block.their_pass_margin_s`, 0): their pass (they touched it
  last, played to one of theirs), their first man to it by the race read ahead of ours by more than the
  margin → nobody of ours chases it. Ours first (or within the margin), our first man goes as before.
  High balls keep G5.71's contest. −1 = off.
- **The presser steps out as it travels** (`physics.press.on_pass`, 1): in that case our nearest to
  where their man meets it (held until another is `switch_m` nearer) is the presser now, not once the
  ball is his: `PressBall` aims at its stand-off (§8.139's table) goal-side of the meet point, facing
  the ball, no tackle until it is his.
- Harness: RECEIVER SPACE (all / controlled; from a mate's pass or not; the inside-3 m man's job; by
  the receiver's third; by the ball's travel; the man nearest at the touch by his metres at the release).
  Test `their_pass_no_chaser_presser_steps_out`. AI goldens unchanged: their 2000 ticks hold no pass of
  theirs their man wins the race to.

**Measured on the way** (seed 1000). The chaser rule alone: inside 3 m from a mate's pass 16.1 → 5.8%
(5.5), but our men no longer closed at all while it travelled (by release distance −0.74 / 0.03 / 0.52
/ 0.69 m v 1.07 / 1.68 / 2.99 / 4.58). With the presser stepping out: −0.09 / 1.17 / 2.33 / 3.99.

**After** (G5.81 → G5.82; seed 1000, then seed 2000; real in brackets).
- From a mate's pass, inside 3 m at the touch 16.1 → 8.9%, 15.2 → 8.4% (5.5); by travel 10-20 m 18 → 8%,
  16 → 9% (5); 20-30 m 22 → 8%, 22 → 6% (2).
- Passes completed 74.1 → 81.0%, 75.0 → 80.9% (79.1); 30 m+ strong / weak 48.3 / 50.7 → 66.9 / 68.4,
  49.6 / 52.1 → 63.7 / 62.6 (58.8 / 54.2); 0-15 m 82.5 → 85.7, 83.6 → 86.6 (87.6). In behind completed
  41 → 49%, 42 → 49% (47.5).
- Pressures (DFL cut) 404 → 364, 403 → 372 (375.2); StatsBomb cut 340 → 304, 341 → 308 (151.8);
  counter-press 39.1 → 30.0%, 37.9 → 31.5% (21.0). Take-ons tried 82.7 → 56.7, 79.6 → 57.7 (18.1).
- Stolen off his feet 8.19 → 6.75, 7.88 → 6.12 (8.0); heavy-touch losses 3.94 → 1.75, 3.06 → 3.06 (4.1).
  Goals 1.38 → 1.94, 1.44 → 1.56.

**What it says.** A pass their man reaches first is now left to him: the nearest of ours steps toward
where he'll take it and the rest keep their jobs — the closing during the flight is near the real one
from every distance. Completion rose past real (81 v 79): the pass chooser's `risk_weight` was fitted to
79.1% while our men still ran onto every receiver, and long passes now arrive too often (64-68 v
54-59). What is left of the tight receivers comes from the pass itself: the man nearest at the touch was
within 5 m at the release 18% of the time (5) — we pass to men already marked.

**Next moles.** (1) The pass chooser picks receivers with a man inside 5 m at the release 18% v 5% —
real passers pick free men; then `risk_weight` re-measured. (2) Long-pass completion 64-68 v 54-59%.
(3) FIRST TOUCH / PRESSED TOUCH still count scrambles (269 v 147 a team-match): match them to RECEIVER
SPACE's cut. (4) Headers and aerial duels (35 v 44). (5) Take-ons 57 v 18.

### 8.184 G5.83 — the pass picks the free man: within his zone a marked mate gets less of the share (no migration)

§8.183's mole: our receivers had a man near them at the release far more than real ones. RECEIVER'S
MARKER AT THE KICK showed it cleanest in the final third: the man a completed pass was for had nobody
within 5 m 30.7% of the time (50.3), while every mate in that zone had nobody within 5 m 38.4% (39.0)
— real passers pick the free man of those there; ours picked the marked one.

**Real** (`benchmarks_tracking_passpick.py`, new MARKED PICK; DFL 7 matches, open-play passes naming a
Recipient, his zone at the kick holding 2+ mates). Each mate there by his nearest opponent 0-2 / 2-3.5 /
3.5-5 / 5-8 / 8+ m; the split ~ e^(-d/λ) (§8.175's λ) × a lift by that bin, fitted by iterative scaling
(8+ m = 1). By the receiver's m off his own goal: 0-35 0.25 / 0.20 / 0.23 / 0.33 / 1 (log-likelihood
+94 over the distance split alone); 35-70 0.27 / 0.26 / 0.27 / 0.41 / 1 (+91); 70+ 0.24 / 0.22 / 0.31 /
0.42 / 1 (+23). A man with theirs inside 5 m is picked about a quarter as often as a free one his distance
away, in every third. Raw shares, mates / receivers: 0-35 8+ m 56 / 75%, 35-70 35 / 43, 70+ 17 / 19.

**Ours** (G5.82, harness MARKED PICK, the same cut on completed passes): the receiver shares sat on the
mates' — 0-35 8+ m 54 / 64%, 35-70 41 / 40, 70+ 19 / 13. The chooser split a zone's share by distance
only (§8.175); marking reached it only through the pass-safety read.

**The change** [FH original on the DFL fit]. `Possession` pick: each mate's distance weight × the lift
for his nearest opponent's bin and his third (`physics.pass.mark_lift_<third>_<bin>`, x1000;
`physics.pass.mark_on` 1, 0 = off). The zone keeps its real share; only its split moves. Harness: MARKED
PICK (completed passes || all passes). Test `pass_pick_marked_lift`; 11v11 golden re-locked, 3v3 unchanged.

**After** (G5.82 → G5.83; seed 1000, then seed 2000; real in brackets).
- MARKED PICK receivers 0-2 / … / 8+ m (seed 1000): 0-35 3 / 5 / 7 / 21 / 64 → 2 / 4 / 6 / 17 / 71% (3 / 5
  / 5 / 12 / 75); 35-70 6 / 12 / 13 / 28 / 40 → 3 / 9 / 11 / 27 / 49 (7 / 12 / 13 / 25 / 43); 70+ 20 / 37 /
  12 / 18 / 13 → 17 / 29 / 16 / 18 / 20 (16 / 24 / 18 / 22 / 19).
- RECEIVER'S MARKER AT THE KICK, 5 m+ free: 0-35 85.8 → 87.9, 86.0 → 90.0 (89.7); 35-70 71.3 → 74.7, 71.8 →
  77.2 (75.6); 70+ 30.7 → 34.1, 32.5 → 36.4 (50.3).
- RECEIVER SPACE, from a mate's pass inside 3 m at the touch 8.9 → 7.2, 8.4 → 7.2% (5.5); the man nearest at
  the touch within 5 m at the release 18 → 16, 18 → 15% (5).
- Passes completed 81.0 → 81.1, 80.9 → 81.6% (79.1); take-ons tried 56.7 → 51.3, 57.7 → 50.9 (18.1);
  pressures (DFL cut) 364 → 356, 372 → 359 (375); counter-press 30.0 → 30.0, 31.5 → 29.0% (21.0).

**What it says.** Within a zone the pass now goes to the free man at the real rate in our third and the
final third; in midfield the marked man is now picked too seldom (0-2 m 3% v 7) — the pass-safety read
already cut marked men there, and the two now stack. The final third's receivers are still tight (5 m+
free 34-36 v 50): that is not the split but which ZONE gets the ball — with one mate in a zone, its
share goes to him marked or not.

**Next moles.** (1) `risk_weight` (the share a pass the race read says they win keeps, fitted to 79.1%
completion when our men still ran onto every receiver): re-measure, completion 81-82 v 79, and midfield's
marked picks 3 v 7%. (2) The final third's zone choice: a zone whose only mate is marked keeps its full
share. (3) Long-pass completion (§8.183). (4) FIRST TOUCH / PRESSED TOUCH counting scrambles.
(5) Aerial duels 35 v 44; take-ons 51 v 18.

### 8.185 G5.84 — a loft's angle by carry: real long balls hang, ours were flat (no migration)

§8.184's list had aerial duels 35 v 44 a match. HIGH OUTCOME (new) showed where: high passes from our
own third and midfield came to our side 93% / 73% of the time (real 57 / 46), and the real ones lost
in the air (27% in midfield) and on the ground (22%) barely happened (11 / 7). HIGH BALLS COMING DOWN:
their nearest man was 3.7 m off a midfield drop (1.6).

**Measured on the way.** (1) The race read's 3 s horizon (a flight beyond it sends the chaser to the
ball's shadow): 5 s changed nothing useful (duels 35 → 29) — not it. (2) New AT THE LAUNCH line
(`benchmarks_tracking_aerial.py`, DFL: the men nearest at the drop, where they stood at the launch):
in midfield our defender starts 8.0 m off the drop (8.4) and closes 2.3 m/s (1.9) — he is not late
or slow; the ball is quick: 1.9 s from the ground to the drop (3.0). (3) A harness trace of that
defender through the flight (5 Hz): his target is 2 m off the drop from the first half-second, he
chases 94% of drops; he just runs out of time. Throw-ins were polluting both lines (the launch never
reset on a dead ball) — fixed.

**Real** (`benchmarks_tracking_loft.py`, new LOFT FLIGHT; DFL 7 matches, TRACAB 25 Hz ball with
height): lofts past 4 m, in play, launch (last frame under 0.5 m) → landing (next under 0.5 m) or a
touch. By carry 10-20 / 20-30 / 30-40 / 40-50 / 50-70 m: a team-match 5.9 / 8.9 / 16.7 / 11.1 / 12.6;
peak med 5.6 / 5.9 / 5.8 / 7.3 / 9.9 m; down through 2.4 m 2.52 / 2.24 / 2.20 / 2.64 / 3.28 s;
landing 2.88 / 2.48 / 2.48 / 2.92 / 3.60 s; launch speed 13.0 / 19.4 / 23.8 / 26.3 / 30.1 m/s. (The
launch angle column reads low — the first 0.12 s can hold the ball still — so it is not a target.)

**Ours** (G5.83, same cut): every aimed loft at one 27° launch (`kLoftLaunchRatio` ½): 20-30 / 30-40 /
40-50 m down through 2.4 m at 1.53 / 1.73 / 2.03 s, landing 1.73 / 1.93 / 2.23 — half a second to 0.7 s
quick, a defender's last 3 m.

**The change** [FH, fitted to DFL; the flight law stays Goff & Carré's drag, §G4.87]. `BallFlight`
solves, per carry, the ratio (rise / ground speed) whose flight is back down through 0.5 m at the real
landing time — `physics.ball.loft_time_<15|25|35|45|60>` (s ×1000 at each bin's middle, linear
between) — the speed for the carry re-solved at each try. Under 15 m the 15 m angle; past 70 m the
70 m one. `ratio()` / `launchRise()` serve the World's aimed loft, `loftSafe` and `descendDist`;
throw-ins keep the flat law (`throwSpeed`). Solved once per process per param set (static cache).
`physics.ball.loft_time_on` 0 = the flat law. Result: 25 / 35 / 45 / 60 m at 48 / 38 / 39 / 41°, 16 /
22 / 26 / 33 m/s off the boot (real launch speeds 19 / 24 / 26 / 30). Test
`ball_flight_loft_time_by_carry`; `ball_flight_drag_loft_lands_at_carry` reads each carry's angle;
both goldens re-locked.

**After** (flat → by carry; seed 1000, then seed 2000; real in brackets).
- LOFT FLIGHT down through 2.4 m: 20-30 1.53 → 2.23 (2.24); 30-40 1.73 → 2.33 / 1.77 → 2.30 (2.20); 40-50
  2.03 → 2.70 / 2.73 (2.64). Peaks now high: 30-40 5.2 → 8.0 (5.8), 40-50 6.6 → 10.2-10.5 (7.3).
- Aerial duels 34.9 → 46.8, 35.6 → 50.2 a match (44.1); headed clearances 23.4 → 25.2 / 21.9 → 26.0 (16.1).
- High passes completed, 0-35 / 35-70 / 70+: 92.7 / 72.6 / 29.9 → 75.4 / 60.4 / 42.0; 94.1 / 71.3 / 30.8 →
  83.2 / 61.6 / 41.8 (57.0 / 46.0 / 36.0). Midfield lost in the air 11.4 → 18.7 / 12.6 → 20.1 (26.8);
  aerial duel at it 35-38% (16.2).
- AT THE LAUNCH, midfield: flight 1.93 → 2.37 / 1.87 → 2.33 s (3.04); defender off the attacker 8.7 →
  9.1 / 8.4 → 9.1 m (7.1).
- Passes 468 → 438 / 466 → 445 (434), completion 81.1 → 80.4 / 81.6 → 80.5% (79.1).
- Goals 1.50 → 1.94 / 1.50 → 2.06 a team-match, scored 19-20 → 29% — from balls in behind: 2 → 8 / 1 → 6
  goals over 8 matches by last kick.

**What it says.** The ball now hangs as long as a real one and our defender gets under it: duels at
the real rate, midfield completion two-thirds of the way to real. One angle per carry is a compromise
— real lofts mix driven and hung balls (their median peak at a carry sits under the parabola their
median landing implies), so ours peak 2-3 m high. Short lofts went over 4 m (10-20 m 0 → 11 a
team-match, real 5.9) and 50-70 m lofts still never happen (0.1 v 12.6).

**Next moles.** (1) The ball in behind: a hung ball over their line now drops for our runner and
scores (6-8 goals in 8 matches v 1-2) — who meets a ball dropping in behind (keeper off his line, the
covering CB). (2) Lofts a mix of driven and hung, not one angle (peaks 2-3 m high). (3) No 50-70 m
lofts (kick range or the chooser). (4) The defender off the attacker at the launch 9 v 7 m — marking
before the high ball. (5) `risk_weight` (§8.184).

### 8.186 G5.85 — goal-side near our goal: measured, the rule built and left OFF; the men trail right targets (no migration)

§8.185's next (1): a hung ball in behind scoring for our runner, 6-8 goals in 8 matches v 1-2.

**Measured first** (new harness lines, 8 × 90, seeds 1000 / 2000; real in brackets).
- IN BEHIND THEN (`benchmarks_tracking_behind.py`, DFL [Bassek 2025]: a shot / goal by the passer's
  side within 10 s of a ball played in behind). High: 19.5 / 19.3 a team-match (22.0), shot 7.4 / 6.5%
  (6.8), goal 1.0 / 1.3% (1.3). Flat: 22.6 / 22.9 (15.7), shot 10.5 / 9.8% (18.6), goal 2.5 / 1.6%
  (3.6). Counted per ball, the high ball in behind is at the real rate. §8.185's "6-8 goals" counted
  the last kick before a goal, with nothing to compare it to. Mole (1) is not a mole.
- SHOT CONTEXT (new `benchmarks_statsbomb_shotcontext.py`, StatsBomb PL 15/16 freeze frames: outfield
  opponents nearer the goal centre than the shooter). Shots with 0 goal-side 18.5 / 19.5% (4.8),
  4+ 38.9 / 36.3% (62.3). By the shot's distance, median goal-side <12 0 / 1 (2), 12-18 2 / 2 (4),
  18-25 5 / 4 (6). This is the real gap: our shots are struck past a defence that isn't there.
  It is not counters. 62 / 53% of our shots come 20 s+ into the possession (37.7); there the median is
  3 goal-side (5).
- GOAL-SIDE (new `benchmarks_tracking_goalside.py`, DFL, 5 Hz, ball under 7 m/s, by its distance to
  the goal centre). Median <12 m 0 / 1 (2), 12-18 2 / 2 (3), 18-25 4 / 4 (5), 25-30 6 / 6 (6). 5+
  goal-side at 12-18 m: 11.4 / 12.6% (31.4). So the gap opens inside 25 m.

**Built** [FH coaching: in our box, between ball and goal]. `DefendingBlock::spot`: with the ball within
`physics.block.gs_r` of our goal centre, a holder whose spot is within `gs_w` of the ball, and not
`gs_m` nearer the goal centre than it, slides straight toward the goal centre until he is. gs_r / gs_w
20 / 10, 20 / 15 and 25 / 10 m, and 30 / 40 m as a check (everyone told to drop): goal-side moved within
noise at every band. With 30 / 40, 73% of frames with the ball inside 12 m still had nobody goal-side.

**Why** (`GAME_GS_TRACE=all`, 2 × 90). Every defender's position against his order's target. Goal-side
by TARGET v by POSITION, mean per frame: ball <12 m 2.69 v 0.80; 12-18 4.68 v 1.92; 18-25 5.13 v 3.48;
25-30 6.43 v 5.61. Real medians are 2 / 3 / 5 / 6. **The targets already put as many men goal-side
as real. The men don't get there.** Holders whose target is goal-side and position isn't: 1,397
frames, 937 of them 7 m+ off, running back at 6.2-6.7 m/s, toward the target 6.0-6.4, asked for
8.6-9.2. Not a cap: in danger they may sprint (`shape_danger_sprint` 1); `capAcross` holds across at
4.5 m/s, and the real side barely goes faster. New real line in `benchmarks_tracking_recover.py`:
with the ball within 20 m of the goal centre, 5+ m/s back / up / across 6.98 / 0.05 / 1.64% of
steps; across component 4+ / 5+ / 6+ m/s 3.22 / 0.95 / 0.19%. Real men don't sprint into their box
shape. They are already in it.

The RECOVERY line shows where it goes wrong (seed 1000; real in brackets). 5+ m/s share by s since
losing the ball: 0-2 6.2 (5.6), 2-4 31.8 (8.9), 4-6 32.8 (11.1), 6-10 18.7 (10.6), 10+ 15.0 (6.7).
5+ back: 2.5 (1.9), 28.3 (5.2), 28.7 (7.4), 12.8 (7.2), 7.4 (3.7). Our side without the ball runs
back hard 2-5× as often as real, even 10 s+ into their possession. Its spots keep moving behind it,
and it chases. Also §8.172's standing gap: possessions twice too long (10 s+ since a loss 69% of
steps, real 37%), losses half the real rate.

**Shipped.** The three harness lines, the new real line in `benchmarks_tracking_recover.py`, and
`GAME_SHOT_TRACE` / `GAME_GS_TRACE` (=all: out to 30 m). The rule stays in `DefendingBlock` behind
`physics.block.gs_r`, fallback 0 = off, no row. Behaviour and both goldens are unchanged from G5.84
(seed 1000 / 2000 outputs identical).

**Next moles.** (1) **The holder trails a right target**: 4-5 m median lag even with the ball 25-30 m
out (7 m inside 12 m). Likely cause: the spots jump when their ball moves (a pass re-aims `ball_to`;
the lead covers only a carried ball). Measure each spot's speed against the holder's, and real men's
distance off a role-mean spot, before building. (2) Possessions twice too long, losses half (§8.172).
(3) Lofts a mix of driven and hung (§8.185 (2)). (4) No 50-70 m lofts. (5) The defender off the
attacker at the launch, 9 v 7 m. (6) `risk_weight` (§8.184).

### 8.187 G5.86 — the gap at our goal is where their ball is, not where our men are: measured (no migration)

§8.186's next (1): the holder trails a right target.

**The trail is the body's, by design.** New HOLD SPOT line (5 Hz, the side without the ball, holders;
seeds 1000 / 2000). With their ball carried, his spot moves under 2 m/s 67% of the time and 10+ m/s
1.6%. Median lag CB 5.5, FB 6.5, DM/CM 6.3 m. With their ball free (a pass or loose), 60% of these
frames, the spot moves 10+ m/s 10.6%: it jumps at the kick to where the first taker will meet it
(`ball_to`). Median lag CB 10.8, FB 11.5, DM/CM 12.3 m. The jumps add 0.48 of the 0.62 m of lag per
0.2 s. That is §8.142's design: the spot is where a real man stands once the ball is still (the real
STILL rows), and trailing a moving ball is the body, as real men trail. The SETTLED SHAPE BY THE
BALL'S SPEED line still matches real by role and band, so the trail is not the fault.

**The fault is the ball's position.** New in GOAL-SIDE (and `benchmarks_tracking_goalside.py`, DFL):
the depth-only count (outfielders nearer the goal line than the ball), the count in their box, how far
across from the ball the deeper men stand, and the ball's |y|. Ours (seed 1000 / 2000) v real. Ball
<12 / 12-18 / 18-25 / 25-30 m from the goal centre:
- in their box, median: 6 / 6 (6); 4 / 5 (5); 3 / 3 (4); 2 / 2 (2) — about real.
- deeper than the ball, median: 0 / 0 (1); 2 / 1 (2); 4 / 3 (3); 4 / 4 (4) — about real.
- those deeper, m across from the ball, median: 3.0 / 2.7 (4.1); 6.0 / 6.7 (4.8); 8.4 / 8.1 (7.8);
  8.6 / 8.8 (9.0) — about real.
- **the ball's |y|, median: 5.8 / 5.8 (5.2); 6.0 / 7.3 (10.1); 7.3 / 9.8 (15.4); 14.6 / 16.3 (18.7).**

Coming closer, a real attack stays wide; ours comes inside between 30 and 12 m. Count by distance to
the goal centre, and a defence that would be goal-side of a wide ball is not goal-side of a central
one. Hence §8.186's shots with nobody goal-side, 4× real. It ties to the standing gap in SPELLS
STARTING WIDE 18-35 m out: 31.5 a team-match (57.8 real, StatsBomb).

**Shipped.** The HOLD SPOT line and the new GOAL-SIDE row, harness only. Outputs and goldens are as
G5.85; tests 22/22.

**Next moles.** (1) **The attack comes inside near goal**: which part does it — the carrier's run (in
v along v out by his place, real from DFL), passes ending central, or the block leaving the middle open.
Measure each against real first. (2) Possessions twice too long, losses half (§8.172). (3) Lofts a mix of
driven and hung. (4) No 50-70 m lofts. (5) The defender off the attacker at the launch, 9 v 7 m.
(6) `risk_weight` (§8.184).

### 8.188 G5.87 — how their ball comes inside: few releases from wide near goal, so few crosses — measured (no migration)

§8.187's next (1): what brings the attack inside near goal.

**INWARD** (new `scripts/benchmarks_tracking_inward.py`, DFL; harness line INWARD). Ball-only, so ours
and real cut the same: 5 Hz steps with the same side on the ball, within 35 m of the goal line it
attacks, by the ball's |y| at the start (centre 0-9 / mid 9-20 / wide 20+) and carried (under 7 m/s)
or passed (7+). A team-match, seed 1000 / 2000 (real):
- carried time: centre 42.5 / 38.0 s (25.9), mid 34.7 / 37.9 (46.7), wide 83.4 / 77.3 (108.2).
  Carried from the centre, toward the line +93 / +77 m (+42): ours drive at goal through the middle.
- passed from wide, toward the line +81 / +111 m (+235); |y| −123 / −124 (−189).
- entries into the last 35 m by |y| there, centre / mid / wide: carried 4.3 / 4.4 / 6.8 (2.6 / 4.5 /
  9.8); passed 13.1 / 14.4 / 16.3 (9.4 / 15.1 / 22.1). Totals are real (carried 15.5 v 16.9, passed 44
  v 47). The mix is not: 40% more come in through the centre and a quarter fewer down the wings. The
  ball is central before 35 m, not brought inside after.

**RELEASES BY ZONE** (harness, against `benchmarks_statsbomb_cross.py crosses`, StatsBomb PL 15/16;
open-play passes by m off their line × |y|, a team-match and cross %). Seed 1000 (real):
- 6-18 m: wide 24+ 5.1 (12.0) cross 11% (25); half-space 14-24 2.1 (7.6) cross 6% (31); centre 1.9 (4.6).
- 18-30 m: wide 10.5 (18.2) cross 9% (10); half-space 7.5 (15.3) cross 3% (6); centre 10.2 (14.3).
- 0-6 m: wide 1.5 (2.5) cross 4% (32); half-space 0.6 (3.0) cross 0% (54).
Crosses 3.1 / 3.5 a team-match (11.5). The choice from 0-18 m wide is real as played (to the box 40%,
`pass.to_1_0` 41.9%; in the air 71% of those, `cross_1` / `to_1_0`). **The gap is the volume**: under
half the real releases from wide inside 18 m (zone 1 7.8 a team-match), so under a third of the crosses.
Some of the cross % gap is the label. StatsBomb tags ground and low crosses (32% of its crosses);
ours is `Why::Cross` only when lofted. Also take-ons 50 / 55 tried (18.1).

`benchmarks_statsbomb_cross.py` reads `<dir>/matches.json` + `<dir>/events/`. The PL 15/16 copy on
the host is flat files, so build a shim dir (matches.json listing the ids, events → the dir).

**Shipped.** INWARD, its ENTRIES row, RELEASES BY ZONE, the new script. Harness only. Outputs and
goldens are as G5.85; tests 22/22.

**Next moles.** (1) **The ball gets central before the last 35 m**: entries 40% too central, a quarter
too few wide — which passes from 35-70 m go wide too seldom (as played, 35-52 wide → 18-35 wide 11% v
`to_5_3` 17%), and whether our wide men are there to take them. (2) Carriers drive through the middle
(carried centre time 1.6×, take-ons 3×). (3) Crosses labelled lofted only (ground / low crosses).
(4) Possessions twice too long (§8.172). (5) Lofts a mix of driven and hung. (6) No 50-70 m lofts.

### 8.189 G5.88 — who is ahead of a wide ball: the static width fits real and makes it worse — measured (no migration)

§8.188's next (1): the ball gets central before the last 35 m.

**MATES BY ZONE by role** (new role and on-the-ball rows in `benchmarks_tracking_zonemates.py` and
the harness). With the ball 35-52 m out and wide, seed 1000 / 2000 (real DFL):
- ahead on the wing (18-35 wide): 0.43 / 0.36 (0.60), empty 66 / 69% (54). By role: ST 0.03 (0.14),
  WIDE 0.22 / 0.20 (0.23), FB 0.09 / 0.06 (0.08), DM 0.08 / 0.05 (0.09). **Real strikers drift into
  the channel ahead of a wide ball; ours don't.**
- beside it in the middle (35-52 centre): 2.92 / 2.97 (2.09). CB 0.45 (0.19), FB 0.48 (0.21), DM/CM
  1.06 (0.70).
- on the ball: FB 44 / 42% (29), WIDE 33 / 36 (22), DM/CM 13 (22), CB 7 (10), ST 2-3 (9).

**SLIDE BY ROLE** (new `scripts/benchmarks_tracking_slide.py`, DFL; harness line). In possession,
ball 25-60 m off their line, the man on the ball out. Each man's slope of y on the ball's y (within
him), and his median |y| with the ball wide (|y| 14+) on his side / the far side. Seed 1000 (real):
CB 0.44 (0.33) 10.4 / 1.8 (14.2 / 6.9); FB 0.36 (0.24) 31.4 / 12.3 (27.2 / 15.9); DM/CM 0.44 (0.40)
11.1 / 2.3 (14.3 / 7.9); AM 0.41 (0.34) 11.4 / 2.6 (13.4 / 5.8); WIDE 0.36 (0.32) 29.8 / 9.3 (20.0 /
10.8); ST 0.37 (0.30) 10.6 / 3.1 (10.8 / 4.5). Ours slide more, the wide pair hugs the touchline,
and the middle is narrow. The real winger stands at 20 m with the full-back outside him at 27, and
the real centre-backs and midfielders are ~4 m wider. Real men level off: half the gap between the
ball-side and far-side man is 3.2-5.7 m with the ball wide, while the slope over all balls is
0.24-0.40.

**Tried, not shipped.** Per-role possession width (formation y ×), slide and slide cap in
`Brain::viewOf` (`physics.shape.ours_width_<role>`, `ours_shift_y_<role>`, `ours_cap_y_<role>_m`),
fitted to the table. Width CB 1.6, FB 0.93, DM 1.6, AM 1.8, WIDE 0.75, ST 1.5; slide 0.35 / 0.31 /
0.43 / 0.39 / 0.42 / 0.38; cap 3.65 / 5.65 / 3.2 / 3.8 / 4.6 / 3.15 m. Ball-side / far-side |y| then
real for CB 14.5 / 7.2, FB 27.1 / 16.6, DM 14.1 / 7.7, WIDE 20.0 / 10.7, but slopes half real (0.17-0.23;
the cap bites too early for one linear slide). And the target got worse: ahead on the wing 0.43 →
0.18 (0.60), the middle beside it 2.92 → 3.45 (2.09); wide passed entries 16.3 → 12.1 (22.1); 6-18 m
wide releases 5.1 → 3.5 (12.0). Uncapped (A / B): no gain either. Removed — the real shape's wide
occupancy is men moving into the space ahead (the striker's channel drift, the full-back outside
the winger), not where the spots stand.

**Shipped.** The role rows in MATES BY ZONE, SLIDE BY ROLE, the slide script. Harness only. Outputs
and goldens are as G5.85; tests 22/22.

**Next moles.** (1) **The striker's channel drift ahead of a wide ball** (0.03 v 0.14 in 18-35 wide) —
a run job like `assignChannel` (G5.56, the last 18 m only), one band out, by the real role counts.
(2) Our back men and DMs crowd the middle beside a wide ball. (3) Carriers through the middle (take-ons
3×). (4) Crosses labelled lofted only. (5) Possessions twice too long (§8.172).

### 8.190 G5.89 — the striker and the AM drift wide: into their channel on the ball's side (no migration)

§8.189's next (1): real strikers drift into the channel ahead of a wide ball; ours don't.

**Real** (`benchmarks_tracking_zonemates.py`, new rows: each role's share of his frames in each
ball-side wide zone, his depth off their line and |y|; DFL). Ball 35-52 m out and wide: ST wide ahead
(18-35 m) 9.7% at 29.3 m / |y| 26.0, wide level (35-52 m) 7.1%; AM 6.7% / 8.9%. Ball 35-52 central:
ST 4.1 / 3.6%, AM 4.4 / 4.6%. Ball 52-70 wide: ST level 12.7%, AM 8.9%. The wingers stand there
about as often as real (WIDE 11.7 / 15.4% v 11.8 / 11.9).

**Ours before** (the same rows in MATES BY ZONE): ball 35-52 wide, ST ahead 3.4%, level under 2%; AM
never; ball central, neither.

**The change** [FH, fitted to DFL]. `Possession::spot`: a striker or AM, with the ball 35-52 m out
(centre or wide) or 52-70 wide, rolls once per man per spell per ball zone (`detNoise` on the spell's
start) against `physics.drift.<zone>_<st|am>_<ahead|level>_p` and takes the real spot: their line minus
`_m`, `_y` toward the ball's side. The roll is the real share × 2.2. At ×1 the measured share came out
at about half real (5.1 / 2.7 / 5.0 / 7.3%): a man rolled wide spends part of the spell running
there. `physics.drift.on` 0 = off. The goldens are untouched: the test rig loads no drift.

**After** (seed 1000 / 2000; real in brackets).
- Ball 35-52 wide: ST ahead 7.6 / 8.3% (9.7), level 3.8 / 5.7 (7.1); AM ahead 6.6 / 7.4 (6.7), level 9.9 / 7.7
  (8.9). The ST's level spot comes up short: the front-man job takes him onto their line.
- Ahead on the wing (18-35 wide), mates 0.43 / 0.36 → 0.55 / 0.51 (0.60), empty 66 / 69 → 58 / 62% (54).
- ENTRIES into the last 35 m, passed, centre / wide: 13.1 / 16.3 → 12.8 / 19.9; 11.7 / 17.4 → 11.1 / 19.2
  (9.4 / 22.1). The ball's |y| at 18-25 m from the goal centre 7.3 / 9.8 → 9.8 / 9.9 m (15.4).
- Crosses 3.06 / 3.50 → 3.50 / 3.62 (11.47). Shots 6.8 / 7.1 → 5.7 / 6.4, goals 1.94 / 2.06 → 1.69 / 1.75.
  Completion 80.4 / 80.5 → 80.7 / 81.1% (79.1).
- Shots with nobody goal-side 18.5 / 19.5 → 19.8 / 21.4% (4.8): not moved.

**What it says.** Wide occupancy ahead of the ball is now about real, and the ball reaches the last 35
m down the wings more often. But crosses and the open shot barely moved. Having a man out wide is not
enough. Releases from 6-18 m wide stay at 4.6 / 4.8 a team-match (12.0): the ball still seldom gets
down there.

**Next moles.** (1) **Down the line**: from 18-35 wide, who carries or passes on to 0-18 wide (releases
there 4.6 v 12.0). (2) The ST's level drift lost to the front-man job. (3) Carriers through the middle
(take-ons 50 v 18). (4) Crosses labelled lofted only. (5) Possessions twice too long (§8.172).

### 8.191 G5.90 — down the line: the channel ball, measured; dying it inside the line tried and not shipped (no migration)

§8.190's next (1): from wide 18-35 m out, the ball on to 0-18 wide (releases there 4.6 v 12.0).

**ARRIVE** (new harness line, against `benchmarks_statsbomb_cross.py arrive`, StatsBomb PL 15/16): into
their crossing zone (0-18 m off their line, |y| 14+), a team-match, seed 1000 (real): carried in 2.25
(8.76); completed passes in 5.88 (12.89), from wide 3.62 (8.53); passes within it 1.06 (5.79). A third
to a quarter of real on every route in.

**DOWN THE LINE** (new harness line): spells starting wide 18-35 m, their passes to 0-18 wide by kind
— a team-match, completed %, median length, and how the failed ones failed. Seed 1000 / 3000 (16 matches):
- balls in behind 2.06 / 2.12, completed 39 / 32%, 21 / 19 m; failed out of play 36 / 37%, to an outfielder
  21 / 31%;
- passes to feet 1.25 / 1.59, 50 / 57%; balls into space 0.50 / 0.38, 38 / 42%.
Real: 14.5% of these spells pass to 0-18 wide, 70% completed (SPELLS STARTING WIDE). Ours 11.5-14.4%,
43%. Half of ours are balls in behind, and a third of those run out.

**Tried, not shipped** [FH]: `physics.behind.die_in`. A ground ball in behind is weighted to reach its
spot as the runner does, so it arrives at `kPassArriveSpeed` (9 m/s) and rolls on ~20 m. When that roll
would leave the pitch, weight it like the ball into space instead: die inside the line, ≤ 2 m past
the spot. Seed 1000 / 2000 / 3000 (16 matches), off → on:
- out of play 36 → 14%, 31 → 26%, 37 → 19%;
- completed 39 → 37%, 53 → 33%, 32 → 32%;
- to an outfielder 21 → 49%, 16 → 40%, 31 → 48%.
The ball stays in and their defender gets to it. And goal kicks are already short of real (ours ~5.2 a
team-match, StatsBomb 8.3; off passes ~2.0 v 2.65), so fewer balls out goes the wrong way. Removed.

**Shipped.** ARRIVE and DOWN THE LINE (with the release's why on Rel), harness only. Outputs and goldens
are as G5.89; tests 22/22.

**Next moles.** (1) **Our runner loses the race for the channel ball.** The ball in behind down the line
goes to their man 21-31% (48% once it stays in): who wins it (their FB / CB / keeper), from where, and
the race read's verdict at the kick. (2) Spells starting wide back to 35+ 26-32% (16.9). (3) Spells
starting wide 18-35 m: 30-33 a team-match (57.8). (4) Carries into the crossing zone 2.3 (8.8). (5) Take-ons
3×. (6) Possessions twice too long (§8.172).

### 8.192 G5.91 — the ball in behind to the man already running (no migration)

§8.191's next (1): our runner loses the race for the channel ball.

**Measured** (new harness line RACE, for the ball in behind down the line, seed 3000, 16 matches, 68
balls). At the kick: our runner 10.4 m from the spot, their nearest outfielder 8.7 (a CB 36 times, an
FB 25), their keeper 24.6. Our runner was moving toward it at 1.8 m/s. Ours minus theirs: < −3 m 7%
(completed 60%), −3..0 16% (27), 0..3 47% (41), 3+ 29% (15). Most are played when their man is nearer.
The existing IN BEHIND line has the same across all balls in behind: receiver speed at the kick 2.4
m/s (real 3.8), toward goal 1.4 (2.7).

**Real** (new BEHIND PICK in `benchmarks_tracking_behind.py`, DFL, 242 balls in behind). At the kick,
every attacking outfielder −1..18 m short of their line (the men a ball in behind could be for), by his
speed toward their goal, and the one it was for. Lift = share of receivers / share of candidates:
<0 m/s 0.42; 0-2 0.65; 2-4 1.04; 4-6 1.73; 6+ 2.95. The candidates' mean lift is 1, so the volume
holds where the speeds are real.

**The change** [FH method on DFL data]. `Possession`: the ball-in-behind candidate's weight × the lift
for its man's speed toward their goal (`physics.behind.lift_<0-4>`; `behind.lift_on` 0 = off).

**After** (seed 1000 / 2000 / 3000; real in brackets).
- IN BEHIND: 39.4 → 35.1 / 36.2 / 36.7 a team-match (37.7); receiver speed at the kick 2.4 → 2.7 / 2.6 /
  2.7 m/s (3.8), toward goal 1.4 → 1.8 / 1.7 / 1.8 (2.7); completed 52 → 50 / 49 / 48% (47.5).
- RACE, seed 3000: our runner toward the spot 1.8 → 2.3 m/s; ours 3 m+ nearer 7 → 20%.
- Down the line: balls in behind completed 32 → 43 / 32 / 32% — within noise (25-68 balls a run).
  Passes completed 80.8-81.2% (79.1).
- Tests 22/22; both goldens re-locked.

**What it says.** The pick now prefers the runner, as real passers do. But our men run less: the
receiver is still 1 m/s slower than real, and runners at the line at a forward pass were 0.01 a pass
(0.06, §8.142). The channel race is limited by how few men are running, not by whom the passer picks.

**Next moles.** (1) **Runs**: men on the move at their line when the ball can be played forward (0.01
v 0.06 a pass; receiver at the kick 2.7 v 3.8 m/s). (2) Spells starting wide back to 35+ (28-32 v 17%).
(3) Carries into the crossing zone 2.3 (8.8). (4) Take-ons 3×. (5) Possessions twice too long.
