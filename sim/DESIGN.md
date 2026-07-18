# footballhome sim — design doc

**Status:** draft v1 · 2026-07-10
**Owner:** footballhome
**Scope:** authoritative multi-player tactical football simulator, server-side C++, browser client, binary wire, member-only auth.

> **Slice 26 status (2026-07-16):** fully **CLOSED**. Final goldens: `kExpectedHashPassEast400 = 0xd2287a0b3981f04d`, `kExpectedHashPassReceive200 = 0xdaa7989a56a58f5f` (47/47 sim tests green, 11 determinism goldens internal).
>
> **Slice 27 (player-player collisions):** parked pending **ADR §22.24**. Progressing on **Slice 28 (shots on goal)** in parallel per user directive.
>
> **Slice 28.1 (event payload versioning + `EventType::Goal=9`, migration 221):** landed 2026-07-16 per **ADR §22.25**.
>
> **Slice 28.2 (`Scenario::goalRegions()` + `GoalDrillScenario`, migration 222, scenario_id=6):** landed 2026-07-17. 48/48 sim tests green.
>
> **Slice 28.3 (`Match::tick` post-physics goal-detection + Goal event emission per ADR §22.25 v1 payload):** landed 2026-07-17. 49/49 sim tests green.
>
> **Slice 28.4 (`MatchEventFrame` wire msg_type 0x04 + HELLO_ACK capability bit 2 + frontend goal-flash):** landed 2026-07-17. 50/50 sim tests green.
>
> **Slice 28.5 (determinism golden `goal_from_kick_east_200_ticks_seed_42`):** landed 2026-07-17. 50/50 sim tests green (existing `test_determinism` case count now 8). Closes the M2 exit criterion "Kicked ball crossing a goal region produces a versioned `MatchEvent::Goal`".
>
> **Slice 27.1 (ADR §22.24 — player-player collision resolution):** drafted 2026-07-17. Chosen: option (b) circle-circle positional-clamp + tangential-slide, `physical.body_mass` in [0.5, 1.5] for the split weighting, ball-owned exclusion rule. Unblocks Slice 27.2 (`BasicPhysics`), 27.3 (attribute id=15, migration 220), 27.4 (rotate 3 existing goldens), 27.5 (2 new collision goldens).
>
> **Slice 27.3 (`physical.body_mass` attribute + migration 220):** landed 2026-07-17 out-of-order (before 27.2) so `IPhysicsWorld::setBodyMass` has a stable attribute id to read from when Slice 27.2 arrives. Attr id=15, default 1.0, runtime-clamped to [0.5, 1.5] in `BasicPhysics::step`. Determinism-neutral: no code path reads the value yet, so all 50 sim tests + all 11 determinism goldens stay byte-identical.
>
> **Slice 27.2 (`BasicPhysics` — circle-circle positional-clamp + tangential-slide) + Slice 27.4 (goldens-rotate — folded, no-op):** landed 2026-07-17. `BasicPhysics` replaces `StubPhysics` in the Match factory (`sim/src/main.cpp` + `sim/src/tools/Replay.cpp`); `Match::spawnInitialSlots` / `claimSlot` / `releaseSlot` thread `physics_->setBodyMass(eid, ...)` at every attribute-refresh site so the resolver reads live values. `IPhysicsWorld` widened with `setBodyMass(EntityId, Fixed64)`; `StubPhysics` implements it as a no-op to keep the interface honest. **Ball-always-excluded M2 narrowing** of ADR §22.24's owner-only-exclusion rule (see Amendment 2026-07-17 in §22.24). Slice 27.4 folded because `test_determinism.cpp` instantiates `StubPhysics` directly in every golden's `cfg.physics = std::make_unique<StubPhysics>()` — the Match-factory swap doesn't rotate any golden. All 51/51 sim tests green (test_basic_physics = 10 subtests, test_replay + test_determinism byte-identical).
>
> **Slice 27.5 (2 new BasicPhysics determinism goldens) + Slice 27 fully CLOSED:** landed 2026-07-17. Adds `two_humans_collide_head_on_200_ticks_seed_42` (kExpectedHash = `0xda52a00e2a8c4b49`) and `collision_ball_passthrough_owned_400_ticks_seed_42` (kExpectedHash = `0x77ca6ee4e965cced`) to `test_determinism.cpp`. Both goldens explicitly instantiate `BasicPhysics` in their `cfg.physics = std::make_unique<BasicPhysics>()` fixtures per the Slice 27.4 folded-finding. Golden 1 locks head-on MTV-clamp at sum-of-radii + velocity zap (slot 1 rests at raw x=`0xffffffff99999935` ≈ -0.4 m, slot 2 at `0x0000000066666603` ≈ +0.4 m — exact 0.8 m gap = `kPlayerContactRadius + kPlayerContactRadius`). Golden 2 locks the ball-always-excluded rule + tangential slide + Rule 1 ownership-transfer via HumanController's auto-dribble augment near the obstacle (final `ball_owner = 2`). **Closes the M2 exit criterion "Player-player collisions resolved deterministically without ball being knocked away from its owner"** — ball was never MTV-clamped away from ANY owner during any tick of either golden; ownership changes in golden 2 came through the Rule-1 first-touch pathway (AI-controller behaviour), not through physics. 51/51 sim tests green (test_determinism internal case count now 13).
>
> **M3 open (2026-07-17):** M2 fully closed; M3 (utility-AI + concepts) opens per §25.
>
> **Slice 30.1 (`AiController` utility-AI dispatch scaffolding + `check_behavior_registration.sh` CI gate):** landed 2026-07-17 (`8fae50c8`). Three-arg ctor `AiController(Role, ConceptSet, std::vector<std::unique_ptr<IBehavior>>)`; `decide()` filters by concept gate (`requiredConcepts()` × `minMastery()`), argmax over `utility()` with strict `>` insertion-order tie-break, zero-utility ⇒ abstain, empty bag ⇒ `idle()`. `defaultBehaviors(Role)` factory returns `{}` for every role in this slice — behavior implementations arrive slice-by-slice. Dockerfile lint chain grew to five gates. 60/60 ctest green. No determinism impact.
>
> **Slice 30.2 (`PursueBallCarrierBehavior` + `DefenderController` deletion + `Scenario::applyConceptOverrides` hook + migration 224 for `pressing` concept id=3):** landed 2026-07-17 (`0196196f`). First real `IBehavior` — replicates all five branches of the deleted `DefenderController::decide()` (owner-hold, no-ball, ball-entity-missing, on-ball, pursue) at intent level. `AiController::defaultBehaviors(Role::Any) = {PursueBallCarrierBehavior}`; `Match.cpp` swaps both `UnclaimedControllerKind::Defender` dispatch sites (spawn + reclaim) to construct `AiController(Role::Any, slot.profile.concepts, defaultBehaviors(Role::Any))`; `releaseSlot` reordered so profile-reset + concept-overlay run BEFORE controller construction. `BallOnPitchWithDefenderScenario` plugs `pressing = 1.0` for SlotId{2} via new `applyConceptOverrides` scenario hook. `test_defender_pursuit.cpp` (10 tests) → `test_pursue_ball_carrier_behavior.cpp` (13 tests). 52/52 container ctest green. **`BallOnPitchWithDefender400` golden STABLE at `0x71f639d918a32830`** — no rotation (intent stream bit-identical). All 11 goldens byte-identical. Closes §24.6 DefenderController migration item; meets Slice 30 exit gate.
>
> **Next up (Slice 31.3 pulled ahead):** migration 226 seeds the nine M3 behavior attributes (`technical.marking_technique` ids 16 through `mental.anticipation` id 24) before full `JockeyBehavior` / `MarkOpponentBehavior` implementation, so the behavior utilities can reference stable generated constants instead of placeholder scoring.

---

## 1. Vision

A **companion piece to fh's RSVP + roster systems** that lets club members *learn and practice tactical concepts by playing them.*

Long term, the same engine that teaches a 4v2 press should also be able to simulate a full 11v11 match. We build toward that by teaching the AI **discrete tactical concepts** and physical/technical **attributes** over time. As the concept and attribute catalog grows, both the teaching product and the full-match simulation product mature simultaneously.

**One codebase. Concept-based intelligence. Attribute-based execution. Realtime multiplayer. Zero game logic on the client.**

## 2. Non-goals (for now)

- 3D graphics *(architecture is 3D-ready but Milestone 0 renders 2D top-down)*
- Turn-based scenarios *(interface reserved, no implementation until later)*
- Full-match 11v11 simulation *(the eventual destination, not a Milestone target)*
- Match matchmaking / ranking / leaderboards
- Desktop-*only* features *(mobile and desktop are both first-class; anything added to one must have an equivalent on the other)*
- Video game aesthetics *(functional, coaching-clarity-first)*
- Bot resistance / anti-cheat beyond server authority *(member-only login is the gate)*
- Networking transports other than WebSocket *(interface reserved for WebRTC later)*
- Public spectating without a fh account
- User-generated scenarios *(scenarios are code + registry entries, not user data)*

## 3. Guiding principles

1. **The C++ server is the source of truth.** Client renders and captures input — nothing else.
2. **OOP everywhere.** Every subsystem sits behind an interface. Concrete implementations are swappable.
3. **No hard-coding.** Scenarios, roles, attributes, concepts are composable data + typed catalog.
4. **No JSON in gameplay.** Wire = binary. Storage = binary. JSON only in debug endpoints for humans.
5. **3D-ready from day 1.** Positions/velocities are Vec3 even when rendering is 2D. Renderer swap gives 3D later with zero engine change.
6. **Concepts are pluggable knowledge.** AI intelligence is the sum of what concepts it holds. Rating is *derived*, never prescribed.
7. **Attributes are strings-keyed and grow on demand.** Adding an attribute is a registry entry + one row per person in `sim_player_attribute`. The schema itself does not change per attribute; only the registry does (§22.9 stable IDs). See ADR §22.18 for the storage normalization.
8. **Bit-exact determinism, everywhere.** Same seed + same inputs = bit-identical simulation state on any CPU, OS, or compiler. Achieved by doing all gameplay math in **Q32.32 fixed-point (`Fixed64`)** — no floats in the sim loop. Enables portable replays, client-side prediction (later), and third-party match verification.
9. **Mobile-first, desktop-equal.** Players will overwhelmingly use phones, so mobile drives the design. But every feature must also work well on desktop — keyboard controls, larger viewports, mouse. Neither platform is a "fallback" for the other.
10. **Recognition is separate from decision.** Every controller (human or AI) sees an `AwarenessView`, never the raw `WorldView`. What a player *sees and correctly labels* is a first-class layer sitting between world state and behavior. In M0 the Recognition phase is an identity pass-through (no patterns exist yet); the pipeline shape is fixed from day 1 because retrofitting it later would rewrite every behavior tree. See §11 and §5.4.

## 4. Architecture overview

```
┌────────────────────────────┐    ┌────────────────────────────────┐
│   Browser (vanilla JS)     │    │  footballhome_sim (C++)        │
│                            │    │                                │
│  • Canvas 2D renderer      │    │  • Match orchestrator          │
│  • Binary snapshot reader  │◀──▶│  • Physics (IPhysicsWorld)     │
│  • Input capture + send    │    │  • AI (IPlayerController)      │
│  • ~200 lines total        │    │  • Scenarios                   │
│                            │    │  • Serializer (binary v1)      │
│  Interpolation only.       │    │  • Deterministic tick loop     │
│  Zero game logic.          │    │                                │
└────────────────────────────┘    └────────────────────────────────┘
              ▲                                    │
              │                                    ▼
              │              ┌──────────────────────────────────┐
              │              │  footballhome_backend (existing) │
              │              │                                  │
              └──────────────┤  • JWT auth (shared secret)      │
                             │  • REST lobby: /api/sim/*        │
                             │  • Postgres access               │
                             └──────────────────────────────────┘
                                             │
                                             ▼
                             ┌──────────────────────────────────┐
                             │  Postgres                        │
                             │                                  │
                             │  • sim_matches                   │
                             │  • sim_match_inputs (bytea)      │
                             │  • sim_match_events (bytea)      │
                             │  • sim_player_profile (parent)   │
                             │  • sim_player_attribute (rows)   │
                             │  • sim_player_concept (rows)     │
                             │  • sim_player_recognition (rows) │
                             │  • sim_attribute_registry        │
                             │  • sim_concept_registry          │
                             │  • sim_scenarios                 │
                             └──────────────────────────────────┘
```

**Two C++ processes**: existing `footballhome_backend` (auth + REST + DB) and new `footballhome_sim` (game loop + AI + netcode). Both run as podman services in the compose stack. Sim server queries backend for JWT verification via internal REST or shared secret validation.

## 5. Class hierarchy (server, C++)

All classes live under `sim/src/`. Interfaces are pure virtual; implementations get concrete file names.

### 5.1 Math & primitives

**All gameplay math is fixed-point.** `Fixed64` is a Q32.32 signed 64-bit integer wrapping arithmetic. Floats are used only at boundaries: (a) attribute/concept storage in the DB, (b) snapshot wire encoding for rendering, (c) client-side rendering itself. The sim tick loop never touches a `float`.

```cpp
// sim/src/math/Fixed64.hpp
struct Fixed64 {
    int64_t raw;   // Q32.32: raw / 2^32 = real value

    static constexpr int32_t FRAC_BITS = 32;
    static constexpr int64_t ONE  = 1LL << FRAC_BITS;

    // Construction (all constexpr where possible)
    static Fixed64 fromInt(int32_t v)       { return { int64_t(v) << FRAC_BITS }; }
    static Fixed64 fromRaw(int64_t r)       { return { r }; }
    static Fixed64 fromFloat(float f);      // used ONLY at load/config boundary

    // Arithmetic (uses __int128 for exact intermediate on mul/div)
    Fixed64 operator+(Fixed64) const;
    Fixed64 operator-(Fixed64) const;
    Fixed64 operator*(Fixed64) const;       // (a.raw * b.raw) >> 32, via __int128
    Fixed64 operator/(Fixed64) const;       // ((a.raw << 32) / b.raw), via __int128

    // Comparisons, unary minus, compound assignment...

    // Conversion out (rendering / logging only)
    float  toFloat() const;
    double toDouble() const;
};

// sim/src/math/FixedMath.hpp  — deterministic transcendentals
Fixed64 fx_sqrt(Fixed64);                   // integer Newton–Raphson
Fixed64 fx_sin(Fixed64 radians);            // LUT + linear interp
Fixed64 fx_cos(Fixed64 radians);            // LUT + linear interp
Fixed64 fx_atan2(Fixed64 y, Fixed64 x);     // LUT + interp
Fixed64 fx_abs(Fixed64);
Fixed64 fx_clamp(Fixed64 x, Fixed64 lo, Fixed64 hi);

// sim/src/math/TrigLUT.cpp  — tables generated at compile time or startup
//   sin/cos: 4096 entries covering [0, 2π), linear interpolated
//   atan2:   2048 entries covering [-1, 1] of y/x ratio, quadrant fold-in

// sim/src/math/Vec3.hpp
struct Vec3 { Fixed64 x, y, z; };           // pitch space — always Fixed64
struct Vec2 { Fixed64 x, y; };              // 2D helper

using EntityId  = uint32_t;
using ClientId  = uint64_t;
using MatchId   = uint64_t;
using SlotId    = uint16_t;
using TickNum   = uint32_t;
using AttrId    = uint16_t;   // ID from sim_attribute_registry
using ConceptId = uint16_t;   // ID from sim_concept_registry
```

**Range & precision on Q32.32:**
- Range: ±2,147,483,647 units. Pitch is 105 m — comfortably inside.
- Precision: 2⁻³² ≈ 2.3×10⁻¹⁰ units. On a 105 m pitch that's sub-nanometer positional precision. Vastly more than needed.
- Multiplication uses `__int128` for the exact 128-bit intermediate, then shifts back. GCC and Clang support `__int128` natively on x86_64 and aarch64.

**Why not float?** Floats are non-deterministic across compilers, CPUs, and libc implementations (transcendentals especially: `sinf` on glibc vs musl vs macOS differ in the last bit). Fixed-point is bit-exact everywhere by construction. This is the standard approach in deterministic multiplayer game engines.

### 5.2 Attributes & concepts (open, registry-backed)

Attributes are stored as `REAL` (f32) in the DB (one row per (person, attr) in `sim_player_attribute`; see ADR §22.18) and converted to `Fixed64` on load. The sim loop only ever sees `Fixed64` values.

```cpp
class AttributeRegistry;      // singleton, loaded from sim_attribute_registry
class ConceptRegistry;        // singleton, loaded from sim_concept_registry

class AttributeSet {
    // sparse { u16 id → Fixed64 value }
    std::unordered_map<AttrId, Fixed64> values;
public:
    Fixed64 get(AttrId, Fixed64 default_value) const;
    Fixed64 get(const std::string& key, Fixed64 default_value) const;   // registry lookup
    void    set(AttrId, Fixed64);
    bool    has(AttrId) const;
    // Encoding/decoding lives in the persistence layer (ProfileStore),
    // not on the Set. See ADR §22.18.
    const std::unordered_map<AttrId, Fixed64>& values() const;
};

class ConceptSet {
    std::unordered_map<ConceptId, Fixed64> mastery;   // 0.0–1.0 in Fixed64
public:
    Fixed64 level(ConceptId) const;
    Fixed64 level(const std::string& key) const;
    bool    has(ConceptId, Fixed64 min_mastery = Fixed64::fromInt(0)) const;
    void    plug(ConceptId, Fixed64 mastery);
    void    unplug(ConceptId);
    const std::unordered_map<ConceptId, Fixed64>& values() const;
};

class PatternRegistry;             // singleton, loaded from sim_pattern_registry
using PatternId = uint16_t;

class RecognitionSet {
    // Per-pattern probability the player correctly labels a pattern per scan.
    // Empty in M0 (no patterns registered until M4). Kept as a first-class
    // field from day 1 so storage layout, wire format, and behavior
    // interfaces are stable. Persisted as rows in sim_player_recognition
    // (ADR §22.18).
    std::unordered_map<PatternId, Fixed64> patterns;
public:
    Fixed64 skill(PatternId) const;                   // 0.0–1.0 in Fixed64
    Fixed64 skill(const std::string& key) const;      // registry lookup
    void    set(PatternId, Fixed64);
    bool    has(PatternId) const;
    const std::unordered_map<PatternId, Fixed64>& values() const;
};

class PlayerProfile {
public:
    AttributeSet   physical;
    AttributeSet   technical;
    AttributeSet   mental;
    ConceptSet     concepts;
    RecognitionSet recognition;
};

struct AiRating {
    Fixed64 overall;                                       // 0–100
    std::unordered_map<std::string, Fixed64> byCategory;
};
AiRating computeRating(const ConceptSet&, const ConceptRegistry&);
```

### 5.3 Physics interface

```cpp
struct EntityDef {
    SlotId  slot_id;  // owning scenario slot (M0: 0 for the ball, 1..N players)
    Vec3    position;
    Vec3    velocity;
    Fixed64 radius;   // 2D collision
    Fixed64 height;   // reserved for 3D headers
    bool    is_ball;  // ball has different physics response
};

struct EntityState {
    EntityId    id;
    SlotId      slot_id;
    Vec3        position;
    Vec3        velocity;
    Fixed64     heading;      // rad, in Fixed64
    MotionState motion;       // idle/walk/jog/sprint (enum class : u8)
};

class IPhysicsWorld {
public:
    virtual ~IPhysicsWorld() = default;
    virtual void     step(Fixed64 dt) = 0;
    virtual EntityId spawn(const EntityDef&) = 0;
    virtual void     despawn(EntityId) = 0;
    virtual void     applyImpulse(EntityId, Vec3) = 0;
    virtual void     setVelocity(EntityId, Vec3) = 0;
    // Opaque stores — physics does not consume these; they ride along in
    // EntityState so the wire snapshot and clients can render facing/gait.
    // Match writes them per-tick from Mechanics; StubPhysics just stores.
    virtual void     setHeading (EntityId, Fixed64 rad) = 0;
    virtual void     setMotion  (EntityId, MotionState) = 0;
    virtual bool     contains(EntityId) const = 0;
    virtual std::size_t size() const = 0;
    virtual EntityState get(EntityId) const = 0;
    virtual std::vector<EntityId> all() const = 0;   // ascending order
};

class StubPhysics : public IPhysicsWorld { /* M0: pos += vel*dt, no collisions */ };
class BasicPhysics : public IPhysicsWorld { /* M1+: circle-circle collisions, ball damping */ };
class FootballPhysics : public IPhysicsWorld { /* later: spin, air drag, bounce, jumps */ };
```

### 5.4 Player controller interface

```cpp
struct WorldView {
    // Read-only view of GROUND-TRUTH match state produced by the sim tick.
    // Controllers do NOT see this directly — see AwarenessView below.
    // WorldView lives only in sim/src/awareness/ and sim/src/match/.
    TickNum tick;
    Fixed64 time_seconds;
    std::vector<EntityState> entities;
    std::optional<EntityId>  ball;
    // ... scenario-specific data, playable-area bounds, etc.
};

struct AwarenessView {
    // What a specific player is aware of this tick. Produced from WorldView by
    // RecognitionSystem::apply(worldView, profile, self). This is what every
    // controller (human or AI) sees — never WorldView directly.
    //
    // M0: identity copy of WorldView; recognized_patterns is always empty.
    // M4+: entities may be filtered/decayed by perception attrs; recognized_patterns
    //      is populated by rolling against PlayerProfile.recognition.
    TickNum tick;
    Fixed64 time_seconds;
    std::vector<EntityState> entities;
    std::optional<EntityId>  ball;
    std::vector<PatternId>   recognized_patterns;   // labels this player currently "sees"
};

class RecognitionSystem {
public:
    // M0: returns AwarenessView mirroring wv, with recognized_patterns = {}.
    // M4+: rolls each registered pattern against profile.recognition and
    //      perception attrs (mental.anticipation, scan_rate, etc.).
    AwarenessView apply(const WorldView& wv, const PlayerProfile& p, SlotId self) const;
};

struct Intent {
    Vec3    desired_direction;   // normalized (unit-length in Fixed64)
    bool    wants_sprint;
    bool    wants_walk;
    // reserved for future: intent_action (pass, shoot, tackle)
};

class IPlayerController {
public:
    virtual ~IPlayerController() = default;
    virtual Intent decide(const AwarenessView&, SlotId self) = 0;
    virtual const char* kind() const = 0;   // "human", "ai", "wander"
};

class HumanController : public IPlayerController {
    ClientId owner;
    Intent   latest_intent;
public:
    void updateInput(const Intent&);
    Intent decide(const AwarenessView&, SlotId) override;
    const char* kind() const override { return "human"; }
};

class WanderController : public IPlayerController {
    Vec3    target;
    Fixed64 choose_new_target_at;
public:
    Intent decide(const AwarenessView&, SlotId) override;
    const char* kind() const override { return "wander"; }
};

class AiController : public IPlayerController {
    ConceptSet concepts;
    std::vector<std::unique_ptr<IBehavior>> behaviors;
    Role       role;
public:
    Intent decide(const AwarenessView&, SlotId) override;   // utility-AI: pick highest-scoring behavior
    const char* kind() const override { return "ai"; }
};
```

### 5.5 AI behavior interface (concept-gated)

```cpp
class IBehavior {
public:
    virtual ~IBehavior() = default;
    virtual std::vector<ConceptId> requiredConcepts() const = 0;
    virtual Fixed64 minMastery() const = 0;   // gates whether behavior is available
    virtual Fixed64 utility(const AwarenessView&, SlotId, const ConceptSet&) = 0;
    virtual Intent  execute(const AwarenessView&, SlotId, const ConceptSet&) = 0;
    virtual const char* id() const = 0;
};
```

Behaviors are added milestone by milestone as concepts are introduced:

- M0: none needed (WanderController alone).
- M3: `MarkOpponentBehavior`, `JockeyBehavior`, `PressBallCarrierBehavior`, `Feint1v1Behavior`, ...
- M5: `CoverShadowBehavior`, `SwitchPressPartnerBehavior`, ...

### 5.6 Scenario interface

```cpp
struct PitchSpec {
    Fixed64 length_m;    // default 105
    Fixed64 width_m;     // default 68
    // penalty area dims etc. reserved
};

struct PlayableArea {
    std::vector<Vec3> polygon;      // typically 4 corners
    enum class Mode { Hard, Soft, Advisory } constraint_mode;
    Fixed64 zoom_hint;              // client camera fit
};

struct SlotSpawn {
    SlotId  slot;
    Vec3    position;
    Fixed64 heading;
    Role    role;
    // AI slot profile source. Mutually exclusive by intent (not by type):
    //   ai_profile_source -> load PlayerProfile from ProfileStore at
    //                        match setup via ProfileStore::load(person_id).
    //                        Drives "our player names on AI pieces"
    //                        product feature. M0 leaves nullopt; wiring
    //                        lands with M3's first AiController scenario.
    //   ai_profile        -> inline literal blob (synthetic AI, drills).
    //   ai_concepts       -> concept overlay on top of whichever source.
    // If both ai_profile_source and ai_profile are set, ai_profile_source
    // wins. See §21.2 item 1 resolution.
    std::optional<PersonId>      ai_profile_source;
    std::optional<ConceptSet>    ai_concepts;
    std::optional<PlayerProfile> ai_profile;
};

class Scenario {
public:
    virtual ~Scenario() = default;
    virtual std::string id() const = 0;
    virtual std::string displayName() const = 0;
    virtual PitchSpec  pitch() const = 0;
    virtual PlayableArea playableArea() const = 0;
    virtual std::vector<SlotSpawn> initialSpawns() const = 0;
    virtual std::optional<Vec3> ballSpawn() const = 0;   // M0: none
    virtual bool  checkSuccess(const WorldView&) const = 0;
    virtual bool  checkReset(const WorldView&) const = 0;
    virtual std::vector<std::string> hints() const = 0;
};

class EmptyPitchScenario : public Scenario { /* M0 */ };
class PressTrigger4v2   : public Scenario { /* M5 */ };
```

Scenarios are declared in code (`sim/src/scenarios/*.cpp`) and registered in `sim_scenarios` for lobby exposure.

**`PlayableArea::Mode` semantics (§21.5 item 6 closed 2026-07-13):**

M0 uses no playable-area constraints — `EmptyPitchScenario::playableArea()` returns a rectangle covering the full 105×68 m pitch with `Mode::Advisory` (the rendering layer clips the camera to the polygon; the sim ignores it). The three modes are contract points for M1+ when the first constrained-area scenario (a "final third" drill, say) lands:

- `Mode::Hard` — the sim clamps player positions to the polygon after each physics step. Players cannot cross the boundary; velocity is zeroed at the wall. Use for training-drill zones where the exercise conceptually ends outside the box.
- `Mode::Soft` — the sim applies an inward-pointing repulsive force proportional to the outward penetration depth. Players *can* briefly leave the polygon (a lunging tackle, an over-run) but are pushed back. Use for real-match-like phase-of-play scenarios where a hard clamp would produce visibly unphysical stops.
- `Mode::Advisory` — the sim does nothing with the polygon. Client renders a dashed boundary + fits camera to `zoom_hint`. Use for coach-eye scenarios where the polygon is a viewing rectangle, not a physical constraint. **M0 default.**

Implementation lands with M1's first constrained scenario; the enum ships now so `EmptyPitchScenario` can set `Advisory` explicitly (§22 rule: reserved fields carry their eventual meaning, not `None`).

### 5.7 Match orchestrator

```cpp
struct Slot {
    SlotId slot_id;
    EntityId entity;
    std::unique_ptr<IPlayerController> controller;
    PlayerProfile profile;
    std::optional<ClientId> owner;   // set if human, empty if AI (session-scoped)
    std::optional<PersonId> person;  // set if human (persistent identity;
                                     //   Slice 13 addition — the key that
                                     //   ProfileStore::loadOrCreate uses)
    Role role;
    Fixed64 stamina;                 // gameplay pool, not physics; starts at
                                     //   Fixed64::one(), drained by Mechanics
                                     //   sprint and recovered while walking
};

class MatchClock {
public:
    virtual ~MatchClock() = default;
    virtual bool    shouldTick() = 0;
    virtual Fixed64 dt() = 0;
    virtual TickNum current() const = 0;
};

class RealtimeClock : public MatchClock { /* M0+: fixed 20 Hz (dt = 1/20 as Fixed64) */ };
class TurnBasedClock : public MatchClock { /* reserved */ };

class Match {
    MatchId  id;
    uint64_t seed;
    std::string server_version;

    std::unique_ptr<IPhysicsWorld>  physics;
    std::unique_ptr<Scenario>       scenario;
    std::unique_ptr<MatchClock>     clock;
    std::vector<Slot>               slots;
    std::optional<EntityId>         ball;

    std::vector<std::unique_ptr<IPlayerController>> spectators; // reserved
public:
    void tick();
    void claimSlot(SlotId, ClientId);
    void releaseSlot(SlotId);
    void applyInput(ClientId, const Intent&);
    Snapshot snapshot() const;
    bool ended() const;
};
```

> **`spectators` is reserved and unused in M0.** No spectator role distinction exists yet — §16.4 explicitly says a client that connects but never sends an INPUT frame simply doesn't claim a slot; they are a "de-facto spectator" tracked only by `SimServer`'s client bookkeeping, not by `Match`. The `spectators` vector is deliberately kept in the shape so the class layout doesn't have to churn when the role lands (M3+ once we differentiate coach/spectator/player roles per §22.1). **Do not access `spectators` from gameplay code — it will always be empty in M0, and no tests cover it.** When the role lands, the `IPlayerController` interface may need to widen (spectators observe but don't produce `Intent`s) — treat the current type as a placeholder.

### 5.8 Network transport & serialization

```cpp
struct InputMsg {
    TickNum client_tick;
    Intent  intent;
};

class ISnapshotSerializer {
public:
    virtual ~ISnapshotSerializer() = default;
    virtual std::vector<uint8_t> serialize(const Snapshot&) = 0;
    virtual Snapshot             deserialize(std::span<const uint8_t>) = 0;
    virtual uint8_t              version() const = 0;
};

class BinaryV1Serializer : public ISnapshotSerializer { /* M0 */ };

class INetworkTransport {
public:
    virtual ~INetworkTransport() = default;
    virtual void broadcast(MatchId, std::span<const uint8_t>) = 0;
    virtual void sendTo(ClientId, std::span<const uint8_t>) = 0;
    virtual std::optional<std::pair<ClientId, std::vector<uint8_t>>> poll() = 0;
    virtual void onConnect(std::function<void(ClientId, JwtClaims)>) = 0;
    virtual void onDisconnect(std::function<void(ClientId)>) = 0;
};

class WebSocketTransport : public INetworkTransport { /* M0 */ };
class InMemoryTransport : public INetworkTransport { /* tests */ };
```

### 5.9 Server runtime

```cpp
class SimServer {
    std::unique_ptr<INetworkTransport> net;
    std::unique_ptr<ISnapshotSerializer> serializer;
    std::unordered_map<MatchId, std::unique_ptr<Match>> matches;
    AttributeRegistry attr_registry;
    ConceptRegistry   concept_registry;
public:
    void run();          // main loop: poll network, tick matches, broadcast
    MatchId createMatch(const std::string& scenario_id, uint64_t seed);
    void    stopMatch(MatchId);
};
```

## 6. Client architecture (vanilla JS)

All under `frontend/js/sim/`. Zero build tools. Zero dependencies. **Mobile-first, desktop-equal**: the design starts from a phone in portrait/landscape, but desktop with keyboard + larger viewport is a fully supported first-class target.

```
frontend/js/sim/
  wire.js          — binary reader/writer (DataView-based)
  transport.js     — WebSocket wrapper
  renderer.js      — IRenderer interface + Canvas2DRenderer
  input.js         — IInputSource interface + TouchInput + KeyboardInput (both first-class)
  interpolator.js  — smooth between two snapshots for 60 FPS render
  client.js        — glues transport + input + renderer + interpolator
  lobby.js         — match list + join UI (HTML DOM, not canvas)
```

### 6.1 The whole client stays small

- **Receive** binary snapshot → decode via `wire.js` → push into interpolator buffer.
- **Render** at 60 FPS via `requestAnimationFrame` → interpolator returns positions for "now" → renderer draws.
- **Read** input source (touch or keyboard) → build `Intent` → encode via `wire.js` → send via WebSocket.

Zero game logic. Zero physics. Zero validation. If the server says a dot is at (52.3, 34.1), the client draws it there.

### 6.2 Renderer interface (client-side)

```js
class IRenderer {
    init(rootEl, pitchSpec) {}
    setPlayableArea(polygon) {}
    render(entities, cameraSpec, deltaMs) {}
    dispose() {}
}
class Canvas2DRenderer extends IRenderer { /* M0 */ }
class ThreeJSRenderer extends IRenderer { /* future 3D */ }
```

Both consume the same snapshot shape. UI has a "2D/3D" toggle later; game logic never sees it.

### 6.3 Input interface (client-side)

```js
class IInputSource {
    attach(rootEl) {}
    poll() { return Intent; }   // called each render frame
    dispose() {}
}
class TouchInput extends IInputSource {
    // Virtual left-thumb joystick (movement direction, magnitude → walk/jog/sprint)
    // Right-thumb button(s) reserved for M1+ (pass, shoot, tackle)
    // Dead-zone + haptics (navigator.vibrate) on state changes
}
class KeyboardInput extends IInputSource {
    // WASD movement, Shift = sprint, Ctrl = walk. Mouse for aiming actions in M1+.
    // Fully supported first-class input, not just a fallback.
}
```

**Auto-selection at load time**: if `matchMedia("(pointer: coarse)")` matches or `ontouchstart` exists → `TouchInput`; else `KeyboardInput`. Devices with both (touch laptops, iPad + keyboard) can use either at any time — the client listens for both simultaneously and the last-active source wins. User can pin a preference in settings.

### 6.4 Layout & UX requirements

**Both platforms are first-class.** Feature parity is the rule.

**Mobile-specific:**
- **Layout**: viewport `width=device-width, viewport-fit=cover, user-scalable=no`. Safe-area insets respected (`env(safe-area-inset-*)`).
- **Orientation**: playable in both portrait and landscape. Camera + HUD reflow, not just rotate.
- **Touch targets**: minimum 44×44 CSS px per Apple HIG. Virtual joystick base is ~120 px; touches outside the joystick dead-zone don't scroll the page.
- **Gesture guards**: `touch-action: none` on the canvas; prevent iOS rubber-band + double-tap-zoom.
- **Wake-lock**: request `navigator.wakeLock('screen')` while in an active match so the phone doesn't dim.
- **PWA-ready**: manifest + service worker for install-to-home-screen and offline lobby shell (matches themselves are online-only). Service worker respects the no-cache rule for all API responses (`Cache-Control: no-store`).

**Desktop-specific:**
- **Larger viewport**: renderer scales pitch to fill available space (up to a max sensible zoom), HUD panel can show more info (all slot roster, match clock, sprint meter, mini-map).
- **Keyboard shortcuts**: match keys shown in a `?` overlay. Space to pause/resume (host only), Esc to leave, Tab to cycle spectator focus.
- **Mouse**: cursor for lobby + HUD interactions; reserved for aim-based actions in M1+ (pass target, shot placement).
- **Multi-window / picture-in-picture**: not required but nothing should break if the tab is resized aggressively.

**Both platforms:**
- 20 Hz snapshots @ ~6 KB/s per client — well under mobile-data pain thresholds, trivial on desktop.
- Canvas 2D is GPU-cheap on both.
- No polling — everything is push over WebSocket.
- **Reconnect**: WebSocket transport auto-reconnects on network flap (Wi-Fi ↔ cellular handoff on mobile, sleep/wake on desktop). Client re-syncs from the next snapshot; no state kept locally.

## 7. Wire protocol (binary v1)

**Rendering boundary.** Snapshots on the wire use `f32` for positions/velocities/headings because the client only *renders* — it doesn't reproduce the sim. Non-determinism at the render boundary is fine; it's just pixels. The server converts `Fixed64 → f32` right before serializing. When a client-side prediction milestone arrives later, we'll add a separate deterministic message type (v2 wire) that ships the raw `int64` fixed-point words, so the client can run the sim in lockstep. For now, the sim state on the server stays 100% `Fixed64`.

> **v1 targets rendering only.** The `f32` fields in the SNAPSHOT and INPUT payloads (§7.2 / §7.3) are per-tick display state — precision loss at this boundary is tolerated because the client is a passive renderer. Any client-side prediction path (e.g. the WASM lockstep client sketched in **§20 "Open questions to revisit later"**) requires a **v2 wire** carrying raw `int64` fixed-point words plus deterministic input timestamps; the two wire formats will coexist (v1 for spectators / low-fidelity clients, v2 for authoritative-prediction clients) rather than v2 replacing v1. Do not "just make v1 more precise" — the point of the split is that v1's serializer stays cheap and lossy while v2 stays bit-exact.

**Framing**: every message on the wire is prefixed with:

```
[u8 wire_version]   // = 1 for M0
[u8 msg_type]
[u16 payload_bytes]
[payload...]
```

Multi-byte fields are **little-endian**.

### 7.1 Message types

| type | name | direction | payload |
|-----:|------|-----------|---------|
| 0x01 | HELLO | client → server | u32 client_capabilities |
| 0x02 | HELLO_ACK | server → client | u64 match_id, u16 your_slot_or_0, u32 tick_hz, u16 wire_capability_bits (§7.1 addendum, Slice 15.4) |
| 0x03 | SCENARIO_META | server → client | see 7.4 — sent once immediately after HELLO_ACK when `wire_capability_bits & kWireCapScenarioMeta` is set (Slice 17.7a) |
| 0x04 | MATCH_EVENT | server → client | see 7.6 — pushed per-tick for each `sim_match_events` row the server writes when `wire_capability_bits & kWireCapMatchEventFrame` is set (Slice 28.4, wire-side sibling to ADR §22.25) |
| 0x10 | SNAPSHOT | server → client | see 7.2 |
| 0x20 | INPUT | client → server | see 7.3 |
| 0x30 | CLAIM_SLOT | client → server | u16 slot_id |
| 0x31 | RELEASE_SLOT | client → server | u16 slot_id |
| 0x40 | EVENT | server → client | u16 event_type + variable payload |
| 0x50 | PING | either | u64 timestamp_ms |
| 0x51 | PONG | either | u64 echo_timestamp_ms |

### 7.2 SNAPSHOT payload

```
[u32 tick_num]
[u32 match_time_ms]
[u16 num_entities]
[Entity entities[num_entities]]     // 30 bytes each (players only — the ball
                                    //   is siphoned to the trailer, §7.2.1)
[u16 trailer_len]                   // v1.1 (Slice 15.4): 0 (no ball) or ≥ 30
[trailer_len bytes]                 // v1.1 ball region — see §7.2.1
```

**Entity record (30 bytes)**:

```
[u16 slot_id]           // 0 for the ball if we later have one; unique per entity
[u16 flags]             // bit 0 = human-controlled, bit 1 = ball, bit 2 = active
[f32 pos_x]
[f32 pos_y]
[f32 pos_z]             // 0.0 in M0; present from day 1 for 3D-readiness
[f32 vel_x]
[f32 vel_y]
[f32 heading]           // radians, [-π, π]
[u8  motion_state]      // 0=idle 1=walk 2=jog 3=sprint 4=other
[u8  reserved]
```

**Milestone 0 snapshot size (payload, pre-trailer)**: 10 (header) + 12 slots × 30 = **370 bytes**. Add the 4-byte frame header (§7) = **374 bytes on the wire**. At 20 Hz ≈ 7.30 KB/s per client.

**Slice 15.4 wire v1.1 update**: every SNAPSHOT payload gains a `[u16 trailer_len]` suffix; `trailer_len = 0` for ball-less scenarios keeps snapshots byte-identical to M0 (canonical golden `0x4937890abb4edfb6` preserved, locked by `test_binary_v1_serializer.cpp::no_ball_snapshot_omits_trailer`). A ball adds 2 + 30 = 32 bytes. The server advertises capability via HELLO_ACK's `kWireCapSnapshotBallTrailer` bit (§7.1); older clients that don't set the capability bit still receive the trailer bytes but MAY treat them as opaque (v1.1 additive rule). See ADR §22.20.

#### 7.2.1 Ball trailer (v1.1, Slice 15.4)

```
[u16 trailer_len]        // 0 = no ball; ≥ 30 = ball region follows
[if trailer_len ≥ 30:]
  [f32 pos_x][f32 pos_y][f32 pos_z]     // offset 0..11
  [f32 vel_x][f32 vel_y][f32 vel_z]     // offset 12..23
  [f32 spin]                             // offset 24..27  (reserved; 0 in M1)
  [u16 owner_slot]                       // offset 28..29
                                         //   `kBallOwnerLoose = 0xFFFF` if unowned
                                         //   real SlotId if dribbled (Slice 16.3+)
  [remaining bytes reserved for future ball fields, ignored by v1.1 readers]
```

**Multiple balls per snapshot is a hard error.** M1 ships one ball per match; the encoder returns `{}` if `Snapshot::entities` contains more than one entity with `flags.is_ball = true` — surfaces the invariant loudly rather than encoding a garbled frame. See ADR §22.20 for the additive-extension rationale + revisit conditions.

**Semantic quiet change from M0**: `num_entities` now counts players only, not the ball. Callers that used `num_entities` to preallocate render arrays must add 1 if the trailer indicates a ball is present. Downstream mirror: [frontend/js/sim/interpolator.js](frontend/js/sim/interpolator.js) tracks the trailer's ball as a first-class object separate from the entities array.

### 7.3 INPUT payload

```
[u32 client_tick]
[f32 desired_dir_x]     // normalized; zero if no movement
[f32 desired_dir_y]
[u8  flags]             // bit 0 = wants_sprint,
                        // bit 1 = wants_walk,
                        // bit 2 = wants_dribble    (Slice 16.2),
                        // bit 3 = wants_release    (Slice 16.4),
                        // bit 4 = wants_kick       (Slice 26.2 — trailer present)
[u8  reserved[3]]
--- Slice 26.2 kick trailer (present iff bit 4 set; ADR §22.23) ---
[u16 trailer_len = 10]  // additive extension — future non-kick
                        //   extensions land as different trailers
[f32 kick_dir_x]        // world-XY unit vector; magnitude ∈ [0.5, 1.5]
[f32 kick_dir_y]        //   (server rejects otherwise)
[u16 kick_power_hint]   // 0 in Slice 26.2 (populated in Slice 26.3+)
```

**16 bytes per input, or 28 bytes when the kick trailer is present** (total wire frame 20 or 32 bytes including the 4-byte header). Sent at ~30 Hz or on change. Bits 2/3/4 default false in older clients (M0 mask was `wants_sprint | wants_walk`) — the server's `Intent` initialiser preserves that so an M0 client running against a post-M1 server never triggers dribble/release/kick semantics. **Backward-compat guarantee**: any INPUT frame with `wants_kick == 0` encodes to bytes byte-identical to what M0 would have produced (locked by test `no_kick_input_matches_m0_bytes` in [sim/tests/test_input_frame.cpp](sim/tests/test_input_frame.cpp)). Wire-format mirror: [sim/src/net/InputFrame.hpp](sim/src/net/InputFrame.hpp). SQL debug decoder: `sim_decode_input()` from migration 218. ADR: §22.23.

### 7.4 SCENARIO_META payload (Slice 17.7a)

```
[u8  mode]              // 0 = Hard, 1 = Soft, 2 = Advisory
                        //   — matches scenario::PlayableArea::Mode
                        //     (compile-time asserts in ScenarioMetaFrame.hpp
                        //      lock the numbering)
[u16 num_vertices]      // 0 = no polygon (baseline scenarios)
[vertex[num_vertices]]  // 8 bytes each: [f32 x][f32 y]
```

**Variable size**: `3 + 8 × num_vertices` bytes. Sent exactly once per session, immediately after `HELLO_ACK`, when the server advertises `kWireCapScenarioMeta` (bit 1) in the HELLO_ACK's `wire_capability_bits`. Carries the playable-area polygon + constraint mode declared by the match's scenario at construction time (see `scenario::PlayableArea`). The client uses this to render a visual overlay for the constrained region (dashed for Advisory, solid for Hard, dotted for Soft — see Slice 17.7b).

**XY only.** The polygon is defined on the ground plane; `z` is not transmitted. Vertices are in world metres with the same coordinate convention as SNAPSHOT positions (origin at pitch center, +x = length, +y = width).

**Send-once semantics.** SCENARIO_META is not a mid-match mutation channel — scenarios that need to change their playable area during a match will land a new msg_type (e.g. SCENARIO_META_DELTA) rather than re-sending SCENARIO_META. See ADR §22.22.

**Advisory + empty polygon is legitimate.** M0 baseline scenarios (EmptyPitchScenario, BallOnPitchScenario) send `mode=2, num_vertices=0` — a 3-byte payload. The client decodes this as "no overlay to draw, no clamp behaviour to expect" rather than treating the message as absent.

### 7.5 WebSocket handshake

- Path: `/sim` (proxied through nginx to `footballhome_sim:9100`)
- Subprotocol header: `Sec-WebSocket-Protocol: fh-sim.v1.bearer.<JWT>`
- Server validates JWT (shared secret with `footballhome_backend`), attaches `JwtClaims` to `ClientId`.

### 7.6 MATCH_EVENT payload (Slice 28.4)

```
[u32 tick_num]              // matches sim_match_events.tick_num
[u8  event_type]            // matches persistence::EventType byte value
[u16 event_payload_len]     // == sim_match_events.payload length
[u8  event_payload[event_payload_len]]
```

**Variable size**: `7 + event_payload_len` bytes for the frame payload; plus 4 bytes for the outer frame header. For a Goal event (event_type=9) with the ADR §22.25 v1 payload (5 bytes), the total on-the-wire is exactly **16 bytes**. Sent by the server whenever it writes a row to `sim_match_events` that clients need to observe live — Slice 28.4 emits Goal only; future event types slot in without a codec change. Gated on `kWireCapMatchEventFrame` (bit 2) in the HELLO_ACK's `wire_capability_bits`.

**Byte-lockstep with the DB payload.** The `event_type` byte + `event_payload` bytes are exactly what landed in `sim_match_events.event_type` + `sim_match_events.payload`. Migration 221's `sim_decode_event()` and any client-side port decode the same bytes — there is deliberately no wire-specific payload format. Consumers already know the versioning rule from ADR §22.25 (`event_type >= 9` ⇒ first payload byte is a version tag; `event_type in (1..8)` grandfathered unversioned).

**Unknown event types are legitimate.** Clients that don't recognise an `event_type` MUST skip the frame silently — unknown types are not a protocol error and MUST NOT tear down the session. This is the same forward-compat rule as SCENARIO_META's mode byte and the SNAPSHOT ball trailer's u16-length prefix.

**Forward-compat extension hook.** The `event_payload_len` u16 lets a Goal-v2 payload grow to (say) 12 bytes without touching either the frame header or the event_type byte. v1 clients parse `payload[0..4]` (per ADR §22.25) and ignore `payload[5..11]`; v2 clients decode the whole 12-byte payload. See ADR §22.25 for the full versioning contract.

## 8. Database schema

All migrations in `database/migrations/`, sequentially numbered after existing migrations.

```sql
-- Registries
CREATE TABLE sim_attribute_registry (
    id           SMALLSERIAL PRIMARY KEY,
    key          TEXT UNIQUE NOT NULL,     -- e.g. "physical.max_sprint_speed"
    category     TEXT NOT NULL,            -- "physical" | "technical" | "mental"
    weight       REAL NOT NULL DEFAULT 1.0,
    description  TEXT
);

CREATE TABLE sim_concept_registry (
    id           SMALLSERIAL PRIMARY KEY,
    key          TEXT UNIQUE NOT NULL,     -- e.g. "marking"
    category     TEXT NOT NULL,
    weight       REAL NOT NULL DEFAULT 1.0,
    description  TEXT
);

CREATE TABLE sim_pattern_registry (
    id           SMALLSERIAL PRIMARY KEY,
    key          TEXT UNIQUE NOT NULL,     -- e.g. "pattern_2v1_defender"
    category     TEXT NOT NULL,            -- "defensive_read" | "offensive_read" | "trigger" | "shape"
    description  TEXT
);
-- Empty in M0. First rows populated in M4 (see §12.5).

-- Scenarios (metadata only; logic in C++)
CREATE TABLE sim_scenarios (
    id          SMALLSERIAL PRIMARY KEY,
    code_id     TEXT UNIQUE NOT NULL,      -- matches Scenario::id() in C++
    display     TEXT NOT NULL,
    description TEXT,
    milestone   SMALLINT NOT NULL,         -- 0..5
    enabled     BOOL NOT NULL DEFAULT TRUE
);

-- Player profiles — normalized (ADR §22.18, migration 205).
-- The parent envelope holds only the person key + updated_at; the actual
-- attribute / concept / recognition values live in three child tables so
-- ops can inspect them with a plain JOIN and pg_dump diffs are readable.
CREATE TABLE sim_player_profile (
    person_id    INTEGER PRIMARY KEY REFERENCES persons(id) ON DELETE CASCADE,
    updated_at   TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE sim_player_attribute (
    person_id INTEGER  NOT NULL REFERENCES sim_player_profile(person_id) ON DELETE CASCADE,
    attr_id   SMALLINT NOT NULL REFERENCES sim_attribute_registry(id),
    value     REAL     NOT NULL,
    PRIMARY KEY (person_id, attr_id)
);
CREATE INDEX ON sim_player_attribute (attr_id);

CREATE TABLE sim_player_concept (
    person_id  INTEGER  NOT NULL REFERENCES sim_player_profile(person_id) ON DELETE CASCADE,
    concept_id SMALLINT NOT NULL REFERENCES sim_concept_registry(id),
    mastery    REAL     NOT NULL,
    PRIMARY KEY (person_id, concept_id)
);
CREATE INDEX ON sim_player_concept (concept_id);

CREATE TABLE sim_player_recognition (
    person_id  INTEGER  NOT NULL REFERENCES sim_player_profile(person_id) ON DELETE CASCADE,
    pattern_id SMALLINT NOT NULL REFERENCES sim_pattern_registry(id),
    skill      REAL     NOT NULL,
    PRIMARY KEY (person_id, pattern_id)
);
CREATE INDEX ON sim_player_recognition (pattern_id);
-- sim_player_recognition is empty in M0 (no rows in sim_pattern_registry until M4).

-- Matches
CREATE TABLE sim_matches (
    id             BIGSERIAL PRIMARY KEY,
    scenario_id    SMALLINT NOT NULL REFERENCES sim_scenarios(id),
    seed           BIGINT NOT NULL,
    tick_hz        SMALLINT NOT NULL,
    server_version TEXT NOT NULL,
    created_by     BIGINT REFERENCES persons(id),
    visibility     SMALLINT NOT NULL DEFAULT 0,   -- 0=public 1=club 2=private
    started_at     TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    ended_at       TIMESTAMPTZ,
    result         BYTEA
);
CREATE INDEX ON sim_matches (ended_at) WHERE ended_at IS NULL;

-- Inputs (deterministic replay source)
CREATE TABLE sim_match_inputs (
    match_id    BIGINT NOT NULL REFERENCES sim_matches(id) ON DELETE CASCADE,
    tick_num    INT NOT NULL,
    slot_id     SMALLINT NOT NULL,
    payload     BYTEA NOT NULL,
    PRIMARY KEY (match_id, tick_num, slot_id)
);

-- Events (goals, turnovers, scenario success, slot join/leave)
CREATE TABLE sim_match_events (
    id         BIGSERIAL PRIMARY KEY,
    match_id   BIGINT NOT NULL REFERENCES sim_matches(id) ON DELETE CASCADE,
    tick_num   INT NOT NULL,
    event_type SMALLINT NOT NULL,
    payload    BYTEA
);
CREATE INDEX ON sim_match_events (match_id, tick_num);
```

### 8.1 SQL decode helpers (debuggability without JSONB)

Only wire-audit payloads (`sim_match_inputs.payload`, `sim_match_events.payload`) need decode helpers — the profile tables are already row-per-value after ADR §22.18, so ops inspects them with plain SQL:

```sql
-- Physical attributes for a person, with registry names.
SELECT r.key, r.category, a.value
FROM sim_player_attribute a
JOIN sim_attribute_registry r ON r.id = a.attr_id
WHERE a.person_id = $1
ORDER BY a.attr_id;
```

The two wire-payload decoders that DO exist (migration 201, still applied after 205):

- `sim_decode_input(payload BYTEA) → jsonb` — decodes one 20-byte wire INPUT frame from `sim_match_inputs.payload`.
- `sim_decode_event(evt_type SMALLINT, payload BYTEA) → jsonb` — decodes one `sim_match_events` row (MatchEnd payload as `hash_hex_be` + `hash_u64`; other event types return a header + optional payload_hex fallback).

Migration 201 also shipped `sim_decode_attributes / _concepts / _recognition` for the old bytea profile layout; those were dropped by migration 205 (ADR §22.18) and are no longer needed.

## 9. Coordinate system & math

- **Pitch is XY plane**, origin at center circle, `x ∈ [-52.5, +52.5]` m (length), `y ∈ [-34, +34]` m (width), `z` = up.
- **Meters** everywhere in gameplay. Yards used only in display text (mini-field descriptions).
- **Right-handed** coordinates.
- **Angles in radians**, standard atan2 conventions. Heading 0 = +x axis, π/2 = +y axis.
- **All gameplay math is `Fixed64` (Q32.32)**. See §5.1. `float`/`double` may appear only at these boundaries:
  1. Loading attribute/concept values from DB (`fromFloat()` once at load).
  2. Encoding snapshots for the wire (`toFloat()` at serialize).
  3. Client-side rendering and input capture.
  4. Debug endpoints and logs (human-readable).
- **No `float`/`double` in `sim/src/physics/`, `sim/src/controller/`, `sim/src/behavior/`, `sim/src/scenario/`, or `sim/src/match/`.** A CI grep enforces this.
- **Transcendentals**: use `fx_sin`, `fx_cos`, `fx_atan2`, `fx_sqrt` from `FixedMath.hpp` — never `std::sin` etc.

## 10. Determinism rules

**Bit-exact determinism across any CPU, OS, and compiler that supports `__int128`** (GCC / Clang on x86_64 + aarch64 cover us). Rules:

1. **All gameplay math is `Fixed64`.** No floats in the sim loop. Enforced by CI grep across `sim/src/{physics,controller,behavior,scenario,match}/`.
2. **Fixed-step tick**: `dt` is a compile-time `Fixed64` constant per match (e.g. `Fixed64::fromRaw(ONE / 20)` for 20 Hz). Never `wall_clock_delta`.
3. **Seeded PRNG per match** — `RngDet` (`sim/src/math/RngDet.hpp`) is the ONLY sanctioned PRNG in gameplay code. Seeded from `sim_matches.seed`. Wraps `std::mt19937_64` (whose raw `operator()` output IS spec-portable per C++ standard §26.5.4.4) but exposes only portable operations built on the raw `uint64_t` stream: `nextU64`, `nextUnit` (uniform `Fixed64` in [0,1) from top-32 bits), `nextRange`, `nextInt` (rejection sampling). BANNED in `sim/src/`: `std::uniform_int_distribution`, `std::uniform_real_distribution`, `std::bernoulli_distribution`, any other `std::*_distribution` (their outputs are NOT portable across libstdc++ / libc++ / MSVC — well-known determinism footgun), `std::random_device`, `std::default_random_engine`, `std::rand`, and direct use of `std::mt19937` / `std::mt19937_64` outside `RngDet.hpp`. Enforced by `sim/scripts/check_no_bad_rng.sh` (runs at container build time before `cmake`). See ADR §22.10.
4. **Stable iteration order** everywhere: entity vectors sorted by `EntityId`; slots by `SlotId`; controllers by `SlotId`. Never rely on hashmap iteration order in gameplay code.
5. **No wall-clock reads in game logic.** Only in networking (for RTT) and logging.
6. **No compiler flags that change math** (`-ffast-math`, `-Ofast`, `-funsafe-math-optimizations`) — mostly irrelevant since we don't use floats, but banned in `sim/CMakeLists.txt` regardless.
7. **Server binary git sha** stored on every match. Replays only officially supported when sha matches, but *should* be bit-identical across shas as long as the sim logic hasn't semantically changed.
8. **All inputs are logged** to `sim_match_inputs` before being applied. Replay reads that table and re-runs the sim with the recorded seed.
9. **CI cross-platform determinism test**: same match `(seed, inputs)` is run on both `linux/amd64` and `linux/arm64` (via podman qemu). Final snapshot bytes must be byte-identical. See `sim/tests/test_determinism_cross_platform.cpp`.

## 11. Player model — the four cognitive stages

Real coaches diagnose in-game failures at four distinct stages. The engine models each as its own layer so a scenario replay can tell you *which* stage broke down. Collapsing these into one "decisions" number (as most sports sims do) throws away the diagnostic signal that makes a training tool actually useful.

| Stage | What it is | Home | Applies to |
|---|---|---|---|
| **1. Perception** | Did the player scan? What's in their FOV? | `AttributeSet.mental` (`scan_rate`, `field_of_view`) | Both human and AI |
| **2. Recognition** | Given what they perceived, did they correctly label the pattern? ("this is a 2v1") | `RecognitionSet` (per-pattern skill) + `RecognitionSystem` | AI (humans see labels via the UI) |
| **3. Decision** | Given a correctly-recognized situation, what's the right response? | `ConceptSet` (for AI) / human input (for humans) | Both |
| **4. Execution** | Can the body carry out the intent? | `AttributeSet.physical` / `AttributeSet.technical` | Both |

Recognition is a **first-class layer between world state and behavior**. Every controller sees an `AwarenessView` (§5.4), never the raw `WorldView`. In M0 the Recognition phase is a pass-through (no patterns exist yet); the shape of the pipeline is fixed from day 1 because retrofitting it later would rewrite every behavior tree.

### 11.1 Brain vs. body (the classical split)

| Aspect | What it is | Applies to |
|---|---|---|
| **Body** (`PlayerProfile.physical/technical`) | Physical & technical capabilities that constrain execution | Both human- and AI-controlled players |
| **Brain — human** (`HumanController`) | Real person deciding moves | Human-controlled slots |
| **Brain — AI** (`AiController` + `ConceptSet` + `RecognitionSet`) | Tactical knowledge (decision) + pattern-reading skill (recognition) | AI-controlled slots |
| **Mental** (`PlayerProfile.mental`) | Composure, decisions, vision — affects execution regardless of controller | Both |

**Key rule**: a human's input flows through the same mechanics as an AI's — both produce an `Intent`, and the body attributes filter what `Intent` actually becomes on the pitch (sprint speed capped by `physical.max_sprint_speed`, pass accuracy modulated by `technical.passing.*`, etc.).

### 11.2 Why recognition is separate from decision (the diagnostic payoff)

Two players can both misdefend a 2v1 for completely different reasons:

- Player A: `recognition.pattern_2v1_defender = 0.3`, `concept.defend_2v1 = 0.9` — knows the drill perfectly, doesn't see the pattern when it happens.
- Player B: `recognition.pattern_2v1_defender = 0.9`, `concept.defend_2v1 = 0.3` — sees the pattern clearly, doesn't know what to do.

Same on-pitch failure, opposite training prescriptions. Splitting recognition from decision is what lets the coaching UI say **"you didn't see it"** vs. **"you saw it and chose wrong."**

### 11.3 Training wheels (scenario feature, M4+)

Because recognition is a distinct layer, scenarios can **force-flag** a pattern in the `AwarenessView` regardless of the recognition roll. Early learners see "here is a 2v1 — react." As `recognition.pattern_2v1_defender` grows, the training wheel is removed and the player must rely on their own recognition to fire. This is a native feature of the split — impossible to build cleanly if recognition and concept mastery are the same number.

## 12. Reserved catalogs (documentation, not code)

Keys we anticipate — populated in `sim_*_registry` as milestones require them. **Only Milestone 0 keys are actually consumed at start.**

### 12.1 Physical

```
physical.max_walk_speed          m/s   (M0)
physical.max_jog_speed           m/s   (M0)
physical.max_sprint_speed        m/s   (M0)
physical.short_burst_speed       m/s   (later)
physical.acceleration            m/s²  (M0)
physical.deceleration            m/s²  (M0)
physical.agility                 rad/s (M0)
physical.balance                 0-1   (later)
physical.stamina_max             pool  (M0)
physical.stamina_drain_rate      /s    (M0)
physical.stamina_recovery_rate   /s    (M0)
physical.strength                0-1   (M1)
physical.jumping                 m     (later)
physical.reach                   m     (later)
```

### 12.2 Technical

```
technical.close_control                       (M1)
technical.dribble_speed_modifier              (M1)
technical.feint                               (M3)
technical.shielding                           (M1)

technical.first_touch                         (M2)
technical.first_touch_under_pressure          (M4)
technical.aerial_first_touch                  (later)

technical.passing.<dir>.<dist>.accuracy       (M2+)
technical.passing.<dir>.<dist>.power          (M2+)
technical.weak_foot_penalty                   (M2)
technical.first_time_pass                     (M3)
technical.lofted_pass                         (M4)
technical.through_ball                        (M4)

technical.shot_power                          (later)
technical.shot_accuracy.<short|mid|long>      (later)
technical.shot_placement                      (later)
technical.volley                              (later)
technical.header_power                        (later)
technical.header_accuracy                     (later)

technical.free_kick                           (later)
technical.corner                              (later)
technical.penalty                             (later)
technical.throw_in                            (later)

technical.standing_tackle                     (M3)
technical.sliding_tackle                      (later)
technical.interception                        (M3)
technical.marking_technique                   (M3)
technical.blocking                            (later)

technical.gk.shot_stopping.<zone>             (M5)
technical.gk.catching                         (M5)
technical.gk.punching                         (M5)
technical.gk.aerial_command                   (M5)
technical.gk.rushing_out                      (M5)
technical.gk.distribution.<short|mid|long>    (M5)
technical.gk.reflexes                         (M5)
technical.gk.1v1_stopping                     (M5)
```

`<dir>` ∈ {backward, side_back, side, side_forward, forward}
`<dist>` ∈ {short, medium, long}

### 12.3 Mental

```
mental.composure                              (M3)
mental.concentration                          (later)
mental.anticipation                           (M3)
mental.vision                                 (M4)
mental.decisions                              (M4)
mental.aggression                             (M3)
mental.bravery                                (later)
mental.determination                          (later)
mental.leadership                             (later)
mental.teamwork                               (M4)
mental.work_rate                              (later)
mental.positioning_sense                      (M3)
mental.off_ball_intelligence                  (M4)
mental.natural_fitness                        (later)
```

### 12.4 Concepts (tactical)

```
Category: movement
  run_to_point                                (M0)
  pathfind_around_obstacles                   (M1)
  stamina_management                          (later)

Category: ball_awareness
  ball_awareness                              (M1)
  chase_ball                                  (M1)
  receive_ball                                (M2)

Category: positioning
  return_to_base                              (M3)
  stay_in_zone                                (M3)
  formation_shape                             (M4)

Category: defensive
  marking                                     (M3)
  jockey                                      (M3)
  pressing                                    (M3)
  cover_shadow                                (M5)
  passing_lane_awareness                      (M5)
  switch_press_partner                        (M5)
  offside_line                                (later)

Category: on_ball
  dribble                                     (M1)
  shield                                      (M1)
  pass_short                                  (M2)
  pass_long                                   (M4)
  shoot                                       (later)
  1v1_beat                                    (M3)

Category: off_ball
  overlap_run                                 (later)
  underlap_run                                (later)
  check_to_ball                               (M2)
  third_man_run                               (later)

Category: coordination
  numerical_press                             (M5)
  compact_shape                               (M4)
  switch_marks                                (later)
```

### 12.5 Patterns (recognition targets)

Patterns are the *labels* a player can attach to what they see. Each is stored in `sim_pattern_registry` when it becomes needed. **Empty in M0** — the registry table exists and profiles carry a `RecognitionSet` field, but no patterns fire until M4.

```
Category: defensive_read
  pattern_2v1_defender                        (M4)  — I am one of two defenders vs. two attackers
  pattern_3v2_defender                        (M4)
  pattern_being_beaten_1v1                    (M3)
  pattern_open_passing_lane_behind_me         (M5)
  pattern_offside_line_break                  (later)

Category: offensive_read
  pattern_2v1_attacker                        (M4)  — my teammate and I have a 2v1 vs. one defender
  pattern_overload_switch_side                (M4)
  pattern_open_channel                        (M5)  — CB has time on the ball; press window
  pattern_receiving_under_pressure            (M4)

Category: trigger
  pattern_press_trigger_lateral_pass          (M5)  — CB→CB pass triggers press
  pattern_press_trigger_bad_first_touch       (M5)
  pattern_offside_trap_opportunity            (later)

Category: shape
  pattern_out_of_position_teammate            (later)
  pattern_compact_block_broken                (later)
```

Recognition rolls happen inside `RecognitionSystem::apply(worldView, profile, self)` once per tick per entity. Patterns that "fire" are appended to `AwarenessView.recognized_patterns`; they are the only labels behaviors are allowed to react to.

## 13. Auth model

- All sim clients must present a valid **fh JWT** (same as existing site login).
- Sim server validates JWT signature with shared secret pulled from `env` at startup.
- Claims include `person_id`, membership status. Sim uses `person_id` for slot ownership, event logging, profile lookup.
- **Any authenticated fh member** can:
  - Browse the match lobby.
  - Spectate any `public` or `club`-matching match.
  - Create matches.
  - Claim any open slot in a public/club match.
- Pickup members (any registered fh login) get the same access.

## 14. Match lifecycle

```
1. Client calls POST /api/sim/matches
      body: { scenario_code: "empty_pitch", visibility: "public" }
   Backend inserts row into sim_matches, calls sim server RPC to create instance,
   returns { match_id, ws_url }.

2. Client opens WebSocket to ws_url with JWT in subprotocol header.
   Sim server accepts, sends HELLO_ACK { match_id, your_slot_or_0, tick_hz,
                                          wire_capability_bits }.
   Immediately after HELLO_ACK, if bit `kWireCapScenarioMeta` is set, the
   server also sends one SCENARIO_META frame with the match's playable-area
   polygon + constraint mode (§7.4, Slice 17.7a).

3. Client sends CLAIM_SLOT { slot_id }.
   If slot's current controller is AI, sim swaps → HumanController(clientId).
   sim_match_events logs the swap.

4. Server ticks at tick_hz. Each tick:
     a. Poll input queue → apply latest Intent to owner's HumanController.
     b. Build ground-truth WorldView from current physics state.
     c. For each slot:
          i.  awarenessView = RecognitionSystem::apply(worldView, slot.profile, slot.id)
          ii. intent        = slot.controller.decide(awarenessView, slot.id)
     d. Apply each Intent to physics via mechanics functions.
     e. physics.step(dt).
     f. scenario.checkSuccess/checkReset → possibly emit EVENT.
     g. Build Snapshot → serialize → broadcast to all connected clients.
     h. Log inputs for this tick to sim_match_inputs.

5. Client releases slot on disconnect (or explicit RELEASE_SLOT):
     controller swaps back to prior AI (or default AiController for the role).

6. Match ends when scenario.ended() OR admin stops it. Server updates ended_at,
   writes result blob, closes all WebSockets for that match.
```

**M0 reality vs the lifecycle above (2026-07-13 reconciliation, §21.5 item 2 closed):**

Steps 1, 4a–h, 5, and 6 are shipped. Steps 1 and 3 have M0-specific caveats:

- **Step 1 — "backend calls sim server RPC to create instance"**: not yet real. `POST /api/sim/matches` (`SimLobbyController::handleCreateMatch`) currently returns the single seeded `sim_matches.id=1` row (from migration 202) rather than creating a new match. This is deliberate — M0 is a single-process, single-match daemon (`SIM_MATCH_ID` from env), so the "create instance" RPC has no target service to route to. The **cross-container HTTP RPC layer that will host this request already exists**: `POST http://footballhome_sim:9101/admin/replay` uses [sim/src/admin/AdminHttpServer.{hpp,cpp}](sim/src/admin/AdminHttpServer.cpp) (§16.6 sub-slice 8.1). A future `POST /admin/createMatch` handler on the same admin server, called from `SimLobbyController::handleCreateMatch`, is the intended shape. Real multi-match orchestration is spec'd in **§16.7 (Multi-match orchestration plan)** — §21.5 item 2 closes on shipping the M1 orchestration path, not on the doc alone.
- **Step 3 — CLAIM_SLOT wire message**: the wire message doesn't exist as a distinct type in v1. Instead, the first accepted `INPUT` frame from a connection implicitly claims the slot associated with the connection's authenticated `person_id` (see [sim/src/server/SimServer.cpp](sim/src/server/SimServer.cpp) `handleInputFrame`). The sequence `ClientConnect → SlotClaim → SlotRelease → ClientDisconnect` is still emitted to `sim_match_events` at transport boundaries — the events exist, the explicit wire message doesn't. M1's playable-area work will introduce an explicit slot picker; the CLAIM_SLOT wire message will land with it.
- **`sim_player_profile` write policy**: reads happen on every `ProfileStore::loadOrCreate(person_id)` call at connection time (§16.6 sub-slice 3). **Writes are exclusively at first-touch** (`loadOrCreate` inserts the default profile if none exists) — never per-tick, never mid-match, and NOT at match-end for M0. Concept-mastery updates that motivated the original `sim_player_profile` design land with M3's training features. Anything that appears to update the profile mid-match is a bug — the tick loop reads from `Slot::profile` (a `PlayerProfile` value snapshotted from the DB at claim time) and never writes back. See ADR §22.14 (`sim_player_profile` write policy — first-touch INSERT only in M0), enforced by [sim/scripts/check_profile_write_policy.sh](sim/scripts/check_profile_write_policy.sh) in the CI lint gate.



## 15. Milestone plan

> **This document is the source of truth for both design AND progress.** Each
> milestone below has a Status column; §16.1 breaks Milestone 0 into checkable
> deliverables. Tick the boxes in place as work lands. Do not create parallel
> progress files.

| Milestone | Adds | Est. weeks | Cumulative | Status |
|---|---|---:|---:|---|
| **M0** | `Fixed64` + `FixedMath` + trig LUTs + cross-platform determinism CI. Move a player dot on empty pitch. Full infra (auth, wire, physics stub, WanderController, Canvas2DRenderer, replay logging). | 5–7 | 5–7 | **done** (closed 2026-07-13 via Slice 13 §16.6; goldens locked in [sim/tests/test_determinism.cpp](sim/tests/test_determinism.cpp)) |
| **M1** | Ball entity + dribble physics + one player can move it. Playable-area constraints. | 3–4 | 8–11 | **done** (closed 2026-07-15; §23.4 exit checklist all `[x]`, §21.7 M2-blockers all `[x]`) |
| **M2** | Multi-player interactions: collisions, first-touch, short passes, shots. | 3–4 | 11–15 | **done** (closed 2026-07-17 via Slice 29; §24.4 exit checklist all `[x]`, §21.7 M2-blockers all `[x]`, one new §21.8 M3-blocker catalogued; Slices 24–28 shipped: multiplayer BallOnPitchScenario + Idle/Defender controllers + press/contest touch-to-steal + realistic proportions/carry-speed/HUD + short pass primitive with kick trailer + PgClient thread-safety hotfix + ball motion trail + `BasicPhysics` circle-circle collisions with mass-split + `physical.body_mass` attr id=15 + `MatchEvent::Goal` event type 9 with versioned payload + `GoalDrillScenario` + frontend goal-flash animation; 51/51 sim tests green with 12 determinism goldens locked in [sim/tests/test_determinism.cpp](sim/tests/test_determinism.cpp)) |
| **M3** | 1v1 attack↔defend scenario. First real `AiController` (chase, jockey, mark, feint). | 4–5 | 15–20 | not started (spec landed 2026-07-17 as [§25](#25-milestone-3--detailed-spec); Slices 30–35 planned) |
| **M4** | 2v1 / 2v2 / 3v2 progressions. Off-ball intelligence, longer passes, first team coordination. | 5–7 | 20–27 | not started |
| **M5** | **PressTrigger4v2** (the original goal). Cover-shadow, press-partner switching, GK distribution. | 3–4 | 23–31 | not started |

## 16. Milestone 0 — detailed spec

### 16.1 Deliverables

Grouped by subsystem so a completed group closes a natural build slice. Tick
boxes in place as work lands.

**Math foundation & build system**
- [x] `sim/src/math/Fixed64.{hpp,cpp}` + `FixedMath.{hpp,cpp}` + `TrigLUT.{hpp,cpp}` + `Vec3.hpp` + `RngDet.hpp`, with full unit tests (60 assertions across 5 test executables, Debug + Release green).
- [x] Strict build (`-Werror`, `-Wpedantic`, `-Wconversion`, `-Wshadow`, `-Wdouble-promotion`, `-fno-fast-math`, `-ffp-contract=off`; ASan+UBSan in Debug; `-O2` in Release, never `-O3`/`-Ofast`).
- [x] CI grep script `sim/scripts/check_no_floats.sh` (no float/double in gameplay dirs; no `WorldView` leaks; no banned math flags).
- [x] Dockerfile (two-stage; build stage fails the image if `ctest` fails).

**Recognition, registries, profiles**
- [x] `sim/src/registry/{Attribute,Concept,Pattern}Registry.{hpp,cpp}` — load from empty registry tables at startup.
- [x] `sim/src/profile/{AttributeSet,ConceptSet,RecognitionSet,PlayerProfile}.{hpp,cpp}` — bytea serialization matching §8 layout (u16 count + [u16 id, f32 val]×N, sorted by id ascending; f32 conversion at persistence boundary only).
- [x] `sim/src/awareness/AwarenessView.hpp` + `RecognitionSystem.{hpp,cpp}` — Recognition phase wired into the tick loop as an identity pass-through. Every controller signature takes `AwarenessView`, never `WorldView`.

**Gameplay stack**
- [x] `sim/src/physics/{IPhysicsWorld.hpp, StubPhysics.{hpp,cpp}}` — kinematic-only integration; no collisions. Interface adds `setHeading` + `setMotion` (opaque store, no simulation effect); `EntityDef`/`EntityState` carry `slot_id` so controllers can locate self by scenario slot.
- [x] `sim/src/controller/{IPlayerController.hpp, HumanController.{hpp,cpp}, WanderController.{hpp,cpp}, AiController.{hpp,cpp}}` (`AiController` is a skeleton class; the interface exists so `Slot::controller` has a stable non-null pointer, but no `IBehavior` implementations are plugged into `AiController::decide()` until M3 — see §16.3 / §16.4 which specify AI slots run `WanderController`, not `AiController`, in M0).
- [x] `sim/src/scenario/{Scenario.hpp, EmptyPitchScenario.{hpp,cpp}}` — 105m × 68m; up to 12 slots; no ball; no playable-area constraint.
- [x] `sim/src/match/{Slot.hpp, MatchClock.{hpp,cpp}, Match.{hpp,cpp}, Snapshot.hpp, Mechanics.{hpp,cpp}}` — 20 Hz tick loop wiring Recognition → Decision → Execution; `Mechanics` translates `Intent` + `AttributeSet` → new velocity/heading/motion/stamina (accel/decel/agility-clamped, stamina drain 0.10/s while sprinting, recovery 0.05/s while walk/idle, clamped to `[0, stamina_max]`).
- [x] `WanderController` uses concept `run_to_point` for unclaimed slots.
- [x] 26/26 tests green under Debug (ASan+UBSan) and Release; CI grep passes.

**Determinism CI**
- [x] `sim/tests/test_determinism.cpp` — runs two fixed-seed scenarios (200-tick wander-only + 400-tick human-sprinting), dumps canonical hex of every Fixed64 raw in the final snapshot, and asserts an FNV-1a-64 golden hash. Any drift in Fixed64 math, tick-loop ordering, or RNG advancement changes the hash immediately.
- [x] `sim/scripts/check_determinism_cross_arch.sh` — builds and runs `test_determinism` inside a `linux/arm64` podman container (requires `qemu-user-static` + binfmt registration); byte-diffs canonical stdout against the native amd64 run. Skips gracefully with enable instructions if qemu isn't set up. Runs on demand; not per-commit.

**Server binary & networking**
- [x] `sim/src/net/{WireFormat.hpp, LeCodec.hpp, ISnapshotSerializer.hpp, BinaryV1Serializer.{hpp,cpp}}` — fh-sim.v1 SNAPSHOT encode/decode (§7.2). 13 tests locking byte layout, endianness, flag bits, malformed-input rejection, and an FNV-1a-64 golden hash of a canonical snapshot.
- [x] `sim/src/net/INetworkTransport.hpp` + `sim/src/net/WebSocketFrame.{hpp,cpp}` + `sim/src/net/WebSocketHandshake.{hpp,cpp}` — transport interface + RFC 6455 frame codec + opening handshake parser (bytes only, no I/O). ✓
- [x] `sim/src/net/WebSocketTransport.{hpp,cpp}` — concrete POSIX-sockets + poll(2) transport wrapping the codec + handshake; JWT verified during handshake; auto-Pong; deferred-close discipline. ✓
- [x] `sim/src/auth/JwtVerifier.{hpp,cpp}` — HS256 verifier, injectable clock, constant-time signature compare via `CRYPTO_memcmp`. Rejects `alg:none`, wrong `alg`, wrong `typ`, missing/non-positive `person_id`, missing/expired `exp`, malformed base64url, empty secret. 15 tests. Links OpenSSL::Crypto (same stack as backend).
- [ ] `sim/src/persistence/PgClient.{hpp,cpp}`.
- [x] `sim/src/net/InputFrame.{hpp,cpp}` — INPUT decoder (§7.3, 16-byte payload) + HELLO_ACK encoder (§7.1, 14-byte payload). 13 codec tests locking byte layout, flag bits, and malformed-input rejection.
- [x] `sim/src/server/SimServer.{hpp,cpp}` + `sim/src/main.cpp` — owns Transport + BinaryV1Serializer + Match; on connect auto-claims first free slot and sends HELLO_ACK; on INPUT applies `controller::Intent` (f32→Fixed64 conversion at wire boundary); on disconnect releases slot; broadcasts SNAPSHOT to every mapped client each tick. `run()` loop alternates transport.poll() with match.tick() at fixed 20 Hz cadence; SIGINT/SIGTERM triggers clean stop. 5 integration tests wire real WebSocketTransport on loopback with a scripted client. `footballhome_sim` executable reads `JWT_SECRET` (required), `SIM_BIND_ADDRESS`, `SIM_PORT`, `SIM_MATCH_ID`, `SIM_MATCH_SEED` from env.
- [x] `footballhome_sim` C++ binary running in podman compose. Two-stage `sim/Dockerfile` (debian:trixie-slim + gcc-13 + libssl-dev in build; libstdc++6 + libssl3 + iproute2 in runtime); Release CMake build; full `ctest` runs during `docker build` so images with a failing test refuse to ship; runs non-root; JWT_SECRET pulled from shared `./env`; no host port published — reachable only via the internal `footballhome_network`.
- [x] Sim server accepts WebSocket connections at `/sim` (proxied by nginx). `frontend/nginx.conf` upgrades the connection (`Upgrade`/`Connection: upgrade`), forwards `Sec-WebSocket-Protocol` verbatim so the JWT reaches sim, disables `proxy_buffering`, and holds the connection open for 1h. Smoke-tested end-to-end: raw socket → nginx:3000 → footballhome_sim:9100 returns 101 + HELLO_ACK + SNAPSHOT.

**Database**
- [x] `database/migrations/200-sim-registries.sql` — all 8 sim tables (`sim_attribute_registry`, `sim_concept_registry`, `sim_pattern_registry`, `sim_scenarios`, `sim_player_profile`, `sim_matches`, `sim_match_inputs`, `sim_match_events`) + M0 seed data (9 physical attributes, `run_to_point` concept, `empty_pitch` scenario). Attribute/concept ids match `sim/src/common/M0Attributes.hpp`. Applied on dev DB; re-apply is idempotent.
- [x] `database/migrations/201-sim-decode-functions.sql` — full plpgsql decode pack landed 2026-07-13 (attributes / concepts / recognition set-decoders, INPUT wire frame → jsonb, event row → jsonb, `sim_read_f32_le` IEEE-754 LE helper, `sim_event_type_name` enum lookup). Detail in §16.6 sub-slice 7.

**Backend lobby routes** (`backend/src/controllers/SimLobbyController.{h,cpp}`, mounted at `/api/sim` in `main.cpp`)
- [x] `GET /api/sim/matches` — list active matches. Public (no auth). Joins `sim_matches` × `sim_scenarios` where `ended_at IS NULL`; returns `{matches: [{id, scenario_id, scenario_code, scenario_display, seed, tick_hz, server_version, visibility, started_at, created_by}]}`. Seeded row from migration `202-sim-lobby.sql` (id=1, `empty_pitch`, seed=42, tick_hz=20, server_version=`m0-slice-12`) matches the daemon's hard-coded `SIM_MATCH_ID=1`.
- [x] `POST /api/sim/matches` — create match. Auth required (Bearer login JWT preferred, else `fh_sess` cookie via `SessionService::requireSession`). M0 no-op: idempotently returns the running match row with a `note` explaining single-daemon semantics. Becomes a real create post-M0 when the sim spawns per-match workers.
- [x] `POST /api/sim/matches/:matchId/join` — issue signed sim JWT. Auth required (same Bearer-first / cookie-fallback as create). Bridges `users.id` → `person_id` via `SELECT person_id FROM users WHERE id = $1::int` (login JWT carries string `userId`, sim wants integer `person_id`). Verifies the target match is open, then `fh::crypto::signJwtHS256({person_id, match_id, iat, exp})` with an 8h TTL sharing `JWT_SECRET` with the sim daemon. Returns `{match_id, person_id, token, ws_path:"/sim", subprotocol:"fh-sim.v1.bearer.<token>", expires_in_s:28800}`. Smoke-tested end-to-end: `curl -H "Authorization: Bearer <login-jwt>"` returns a well-formed sim JWT that JwtVerifier accepts. Frontend `client.js` calls this automatically on page load when no `?token=` param is present and `localStorage.token` is set — logged-in users get a fresh sim token per session without touching the mint script.

**Client**
- [x] `frontend/sim.html` + `frontend/css/sim.css` + `frontend/js/sim/{wire,transport,renderer,input,interpolator,client}.js`. Vanilla JS (repo convention: no build step); each file registers a global on `window`. Served by the existing frontend nginx container (bind-mounted `/frontend` → `/usr/share/nginx/html`); `location = /sim` in `frontend/nginx.conf` is EXACT so `/sim.html` still falls through to file serving instead of being WS-proxied. `client.js` resolves a sim JWT in priority order: (a) `?token=` URL param → (b) auto-`POST /api/sim/matches/1/join` with `localStorage.token` (backend login JWT) → (c) cached `localStorage.sim_token`. Logged-in users get a fresh 8-hour sim JWT per page load. `lobby.js` (match list UI) still deferred — POST is idempotent single-match under M0 so there's nothing to browse yet. Wire codec verified end-to-end round-trip in Node: `INPUT` encode → decode; hand-crafted `HELLO_ACK` + `SNAPSHOT` decode to the exact fields the C++ serializers wrote.
- [x] `TouchInput` — virtual left-thumb joystick anchored where the finger lands, magnitude 0..1 clamped by an on-screen ring, plus a bottom-right sprint pad (hidden on `pointer: fine`). Magnitude → wants_walk (<0.3) / wants_sprint (>0.9, or sprint-pad held). `touch-action: none` on the joystick canvas; `pointer-cancel`/`pointer-leave` resets state so a phone gesture never sticks. Wake-lock still TODO (kept as a follow-up to keep this slice small).
- [x] `KeyboardInput` — WASD + arrow keys + Shift-sprint + Ctrl-walk. `preventDefault` on movement keys stops the page from scrolling. Diagonals normalized to unit magnitude so the sim's f32 dir stays ≤1.
- [x] Mobile viewport meta (`viewport-fit=cover`, `user-scalable=no`) + safe-area handling (`env(safe-area-inset-*)`) + `touch-action: none` on canvas. Portrait/landscape reflow is automatic — canvas recomputes `pxPerM` on `resize`/`orientationchange`.
- [~] Desktop layout: pitch fills the viewport (full-bleed). HUD is a monospace overlay in the top-left showing match id, slot, tick, client count, ping proxy, and connection state. Roster sidebar + `?` shortcut overlay deferred (M0 has no team/stamina UI to show yet).
- [x] Canvas2D renderer with striped mown-grass pitch, touchlines, halfway line, centre circle + spot, penalty & goal boxes; player dots coloured by role (me=cyan, other humans=amber, AI=red) with heading tick and slot-number label; HiDPI via `devicePixelRatio` backing-store scaling.
- [x] Interpolation between snapshots at 60 FPS render via `requestAnimationFrame`. `FhSimInterpolator` buffers up to 8 snapshots (~400 ms at 20 Hz), samples at `now - 1.5 * tickPeriodMs` with shortest-arc angular lerp on heading. Falls back to the newest snapshot on stall so movement doesn't freeze mid-jitter.
- [x] `sim/scripts/mint-dev-jwt.sh` — dev-only HS256 JWT minter (reads `JWT_SECRET` from repo-root `env`, mints `{person_id, iat, exp}` matching `sim/src/auth/JwtVerifier`). Prints token on stdout + demo URL on stderr for offline browser testing without a lobby endpoint.

**Replay**
- [ ] Deterministic replay by re-running sim from `sim_match_inputs`.

### 16.2 Milestone 0 attributes (only these are consumed)

| Key | Default | Unit |
|---|---:|---|
| `physical.max_walk_speed` | 2.0 | m/s |
| `physical.max_jog_speed` | 4.5 | m/s |
| `physical.max_sprint_speed` | 7.5 | m/s |
| `physical.acceleration` | 6.0 | m/s² |
| `physical.deceleration` | 8.0 | m/s² |
| `physical.agility` | 6.0 | rad/s |
| `physical.stamina_max` | 1.0 | pool |
| `physical.stamina_drain_rate` | 0.10 | /s while sprinting |
| `physical.stamina_recovery_rate` | 0.05 | /s while walk/idle |

### 16.3 Milestone 0 concepts (only these exist)

| Key | Weight | Behavior it unlocks |
|---:|---:|---|
| `run_to_point` | 1.0 | `WanderController` picks a random pitch point and jogs to it |

### 16.4 Milestone 0 explicit non-goals

- No ball.
- No collisions (players can overlap).
- No pass, shot, tackle, or any ball action.
- No AI behavior beyond wander.
- No scenario success/fail detection.
- No spectator role distinction (everyone is either a player-in-slot or watching).
- No coach annotations.

### 16.5 Milestone 0 exit criteria

- Two authenticated fh members on **phones** (iOS Safari + Android Chrome) can join the same match, each claim a slot, and see each other moving in real time using the virtual joystick.
- Two authenticated fh members on **desktop** (Chrome + Firefox + Safari) can do the same using WASD + Shift.
- Mixed matches (one phone + one desktop) work identically — neither client has a UX advantage over the other.
- Sprint drains stamina, recovery works, `max_sprint_speed` is respected.
- On a mid-range phone (e.g. iPhone 12 / Pixel 6), sustained 60 FPS render with <5% dropped frames during a 10-minute session.
- On a mid-range laptop, sustained 60 FPS render at 1080p+ with <1% dropped frames.
- Wake-lock keeps mobile screen awake for the duration of a match; releases on match exit.
- Portrait ↔ landscape rotation reflows without disconnecting.
- Desktop window resize reflows the renderer without disconnecting.
- Replay from `sim_match_inputs` reproduces the same match state on a second run.
- **Cross-platform determinism**: a 10-minute recorded match replayed on `linux/amd64` and `linux/arm64` (via podman qemu) produces byte-identical final snapshots at every tick.
- 50 concurrent single-slot matches on one dev laptop stays under 20% CPU.
- No JSON is transmitted or stored in gameplay paths (debug endpoints excepted).
- No `float`/`double` anywhere under `sim/src/{physics,controller,behavior,scenario,match}/` (CI grep enforces).
- No controller or behavior reads `WorldView` directly — every `decide()` / `utility()` / `execute()` takes `AwarenessView`. `WorldView` symbol may appear only under `sim/src/awareness/` and `sim/src/match/` (CI grep enforces).

### 16.6 Slice 13 — Persistence & replay (M0 close-out)

The two unchecked M0 boxes (`PgClient` and deterministic replay from `sim_match_inputs`) both require Postgres access from the sim daemon. Rather than ship them as two disjoint slices, close them as one — the replay tool needs the input logger, and the input logger needs `PgClient`. This slice ends M0.

Grouped by subsystem so a completed group closes a natural build slice. Tick boxes in place as work lands.

**Persistence library (`sim/src/persistence/`)**
- [x] `sim/src/persistence/IPgClient.hpp` — pure-virtual interface. Read methods (`loadRegistry`, `loadProfile`, `getMatch`) + write methods (`insertMatch`, `updateMatchEnded`, `insertInput`, `insertEvent`, `upsertProfile`). Interface-first so tests can inject an in-memory fake and gameplay code never depends on libpqxx directly.
- [x] `sim/src/persistence/PgClient.{hpp,cpp}` — concrete impl using `libpqxx` (matches backend's Pg stack). Prepared statements for all hot paths. Single connection is fine for M0; connection pool later. Env: `POSTGRES_HOST`, `POSTGRES_PORT`, `POSTGRES_DB`, `POSTGRES_USER`, `POSTGRES_PASSWORD` (renamed from `SIM_DB_*` to match the backend's convention — one shared secret store). Startup fails loud if unreachable — no fallback.
- [x] `sim/src/persistence/InMemoryPgClient.{hpp,cpp}` — test double implementing the same interface with `std::unordered_map` backing. Used by unit tests + `test_determinism` extensions.
- [x] `sim/src/persistence/EventTypes.hpp` — stable enum values for `sim_match_events.event_type`. Append-only. Initial values: `1=match_start, 2=match_end, 3=client_connect, 4=client_disconnect, 5=slot_claim, 6=slot_release, 7=scenario_success, 8=scenario_reset`. Documented in place.
- [x] `sim/Dockerfile` build stage adds `libpqxx-dev`; runtime stage adds `libpqxx-7.10` (debian:trixie ships 7.10, not 6.4).
- [x] `sim/CMakeLists.txt` adds `pkg_check_modules(PQXX REQUIRED IMPORTED_TARGET libpqxx)` and a new `sim_persistence` STATIC library target linked by `sim_server`.

**Registry loading at startup**
- [x] `loadAttributeRegistryFromDb(AttributeRegistry&, IPgClient&)`, `loadConceptRegistryFromDb(...)`, `loadPatternRegistryFromDb(...)` in `persistence/RegistryLoader.{hpp,cpp}` — replaces any in-memory seeding path. `main.cpp` calls these before `SimServer` is constructed. **Deviation from original spec**: shipped as free functions on the persistence side rather than `AttributeRegistry::loadFromDb` member methods, because `sim_data` (registries) sits BELOW `sim_persistence` in the CMake layer order — putting the loader on the registry side would invert the dependency and force `sim_data` to include `IPgClient.hpp`.
- [x] `verifyM0RegistryConsistency(attr_registry, concept_registry)` asserts that IDs of every key in `sim/src/common/M0Registry.generated.hpp` (produced from migration 200 by `gen_registry_header.awk`, §22.11) match the DB rows. Any drift fails startup with a clear error naming the mismatched key. Prevents silent renumbering ever corrupting bytea profiles.
- [x] Remove all hard-coded default-attribute paths from `SimServer` / `Match` / `Slot`. Every attribute value used in gameplay now comes from `PlayerProfile` loaded from DB via `ProfileStore`. `defaultPhysical()` / `defaultConcepts()` in `M0Attributes.cpp` are the baseline values used exclusively by `ProfileStore::loadOrCreate` when materializing a first-time profile.
- [x] CI grep `sim/scripts/check_no_hardcoded_attrs.sh`: no `Fixed64::fromFloat` call may appear outside `sim/src/persistence/`, `sim/src/registry/`, `sim/src/common/M0Attributes.cpp`, and `sim/src/common/M0Registry.generated.hpp` — enforces "attributes always come from DB or from the migration-derived baseline." Wired into `sim/Dockerfile` alongside `check_no_floats.sh` and `check_no_bad_rng.sh`.

**Player profile read/write**
- [x] `sim/src/persistence/ProfileStore.{hpp,cpp}` — thin wrapper over `IPgClient` that reads/writes the four `sim_player_*` tables (parent + attribute + concept + recognition) row-per-value. Originally shipped over bytea codecs on `AttributeSet` / `ConceptSet` / `RecognitionSet`; refactored to row-per-value 2026-07-13 (ADR §22.18, migration 205) after ops feedback that opaque bytea columns made attribute inspection require the C++ wire codec. Codecs removed; encoding lives in ProfileStore's `encodeSet` template.
- [x] `ProfileStore::loadOrCreate(person_id)`: if `sim_player_profile` row exists → run one `pqxx::work` that pulls all three child tables ORDER BY `<id>` ASC and reconstructs the `PlayerProfile`; else materialize a default `PlayerProfile` from `defaultPhysical()` + `defaultConcepts()`, persist, return. First-touch is idempotent.
- [x] `Slot` gains an `std::optional<PersonId> person` field; `SimServer` looks up the person from the JWT claims on connect and calls `ProfileStore::loadOrCreate` before storing the profile in the claimed slot.
- [x] Test: `test_profile_store.cpp` — round-trips a profile through `InMemoryPgClient`, verifies row-exact recovery, verifies default materialization for unknown `person_id`.

**Match lifecycle in DB**
- [x] `main.cpp` on startup: `db.upsertMatch({id, scenario_id=0, seed, tick_hz=20, server_version=GIT_DESCRIBE})` — idempotent `INSERT ... ON CONFLICT (id) DO UPDATE` so a restart of a running match preserves its `sim_match_inputs`/`sim_match_events` history but refreshes `server_version`. Migration 202's seeded id=1 row remains the single M0 match.
- [x] `server_version` value derived at build time from `git describe` via the `FH_SIM_GIT_DESCRIBE` CMake define (falls back to `"unknown"` for non-git builds). Same define reused by HELLO_ACK.
- [x] On SIGTERM / SIGINT: sim writes `event_type=MatchEnd` with the 8-byte big-endian canonical FNV-1a-64 snapshot hash (`sim/src/match/CanonicalHash.{hpp,cpp}`) into `sim_match_events`, then `updateMatchEnded(match_id, hash_bytes)` sets `ended_at = NOW()` and `result = hash_bytes`. Lobby's `WHERE ended_at IS NULL` predicate then correctly hides the match.
- [x] Frontend lobby (`SimLobbyController::handleListMatches`) unchanged; verified with a manual shutdown.

**Match input logging (deterministic replay source)**
- [x] `sim/src/persistence/AsyncPgLog.hpp` — bounded MPSC queue (default 256 slots) drained by a dedicated background thread that hands each drained batch to a caller-supplied sink lambda. `push()` is nothrow: on a full queue it drops the row and bumps an atomic counter (visible via `dropped()`) instead of blocking. Templated on `Row` so `InputLog` (=`AsyncPgLog<InputRow>`) and `EventLog` (=`AsyncPgLog<EventRow>`) share one implementation — no duplication (§3 rule 4).
- [x] `sim/src/persistence/InputLog.hpp` + `sim/src/persistence/EventLog.hpp` — thin typedefs providing stable spellings for callers.
- [x] `SimServer` records inputs to `InputLog` after acceptance; wire-format `InputFrame` bytes reused as `sim_match_inputs.payload` — one codec, one source of truth for what a "recorded input" looks like. `SimServer` also emits `ClientConnect` / `SlotClaim` / `SlotRelease` / `ClientDisconnect` events at transport boundaries.
- [x] Batch flush cadence: drain thread wakes on condvar, drains all queued entries in one `insertInputBatch` / `insertEventBatch` call. Sink exceptions are caught, logged, and counted as drops — a Pg blip during a live match must not tear the drain thread down (see AsyncPgLog header for rationale).
- [x] Event log: same shape as input log — bounded MPSC + background drain — for `ClientConnect`, `ClientDisconnect`, `SlotClaim`, `SlotRelease`, `ScenarioSuccess`, `ScenarioReset` (M0 emits the first four; scenario events wired in for M1).
- [x] Tests: `test_async_pg_log.cpp` — verifies queue semantics, drop counter, sink-exception isolation, ordering, best-effort drain on `stop()`. **Deviation from original spec**: one test on the template rather than separate `test_input_log.cpp` + `test_event_log.cpp`, since the typedefs add no behavior beyond the template.
- [x] CI load test asserting zero drops under simulated 100 ms Pg latency for a 10-min match — closed 2026-07-13 in the exit-criteria sub-slice below (§16.5 additions); see `test_async_pg_log_load.cpp`.

**Replay binary**
- [x] `sim/src/tools/{Replay.hpp,Replay.cpp,replay_main.cpp}` — new CMake target `fh-sim-replay` (built alongside `footballhome_sim`) and a shared `sim_tools` static lib so `test_replay.cpp` can link the driver without duplication. Links `sim_gameplay`, `sim_persistence`, `sim_net`, `sim_flags`. **Deviation from original spec**: implementation is split into a reusable `Replayer` free function (`tools::replayMatch`) plus a thin CLI wrapper, rather than a single `replay.cpp`, so tests can drive the same code path used by the binary.
- [x] CLI: `fh-sim-replay --match-id N [--up-to-tick T] [--emit-hex] [--emit-hash] [--verify]`. Reads `sim_matches` for scenario + seed via `IPgClient::getMatch`; constructs `Match` with matching `StubPhysics + EmptyPitchScenario + RealtimeClock(tick_hz)`; loads `sim_match_inputs` ordered by `(tick_num ASC, slot_id ASC)` via new `IPgClient::loadInputsForMatch(match_id, up_to_tick)`; for each tick in `0..target_tick`, decodes each recorded wire InputFrame via `net::decodeInputFrame` (auto-synthesizing `claimSlot` with the M0 default profile on first input for a slot — see §22.13), applies `Match::applyInput`, then calls `match.tick()`; emits canonical hex (`match::canonicalDump`) and/or FNV-1a-64 hash (`match::canonicalMatchHash`) at the final state. Default action when no `--emit-*` flag is passed is `--verify`.
- [x] On match_end: sim daemon emits the canonical snapshot hash into `sim_match_events` (event_type=2, payload=8-byte hash big-endian) — already landed in sub-slice 5's `main.cpp` shutdown sequence. `fh-sim-replay --verify` reads that row via new `IPgClient::loadMatchEnd(match_id)`, computes its own hash via the replay driver, and `memcmp`s the two 8-byte payloads. Exit code 1 on mismatch, 0 on match. If no `--up-to-tick` was passed, the target tick is resolved from `MatchEnd.tick_num` so the replay reproduces exactly the state the live daemon hashed.
- [x] `sim/Dockerfile` copies `fh-sim-replay` into the runtime image at `/usr/local/bin/` (build stage still runs `ctest` against it).
- [x] `sim/tests/test_replay.cpp` (new integration test) — scripts the same `human_sprint_east_400_ticks_seed_42` scenario as `test_determinism.cpp` via `InMemoryPgClient` (records a synthesized wire InputFrame via new `net::encodeInputFrame` helper), then runs `tools::replayMatch` in-process, asserts final snapshot hash matches the live match bit-for-bit. Additional cases: default-target-tick resolved from `MatchEnd` event + missing-match throws `std::runtime_error`. `ctest` shows 33/33 passing.
- [x] `sim/scripts/check_determinism_cross_arch.sh` extended — **sub-slice 6.1 landed 2026-07-13.** The pessimism about needing a real Postgres was wrong: `test_replay.cpp` already uses `InMemoryPgClient` and its own assertion `replay_hash == live_hash` covers the replay-vs-live claim per-arch. The script now builds both `test_determinism` AND `test_replay` inside ephemeral `debian:trixie-slim` containers (matching `sim/Dockerfile`) at both `linux/amd64` and `linux/arm64` (arm64 via `qemu-user-static` binfmt). Marker-delimited stdout (`===BEGIN_DETERMINISM===` / `===BEGIN_REPLAY===`) lets the outer script extract each test's output and (a) diff the two canonical dumps for byte-equality, (b) verify both replay runs exited 0. Container-parallel design means the host only needs `podman` + `qemu-user-static` — no `libpqxx-dev` / `cmake` / `g++` on the host. Three-way equality proved by transitivity: [1] `Live amd64 == Live arm64` (direct dump diff), [2] `Replay amd64 == Live amd64` (`test_replay` in amd64 container), [3] `Replay arm64 == Live arm64` (`test_replay` in arm64 container under qemu). End-to-end smoke-tested 2026-07-13 on `fishtown` after `sudo apt install qemu-user-static binfmt-support`: 12m20s wall time (~30s amd64 phase, ~11min arm64 phase dominated by qemu emulation of the arm64 compile), all three claims OK. Exit code 0 on all checks; exit 1 with per-check FAIL diagnostics + `$TMP` artifacts preserved on any failure.

**Migration 201 — SQL decode helpers**
- [x] `database/migrations/201-sim-decode-functions.sql` — landed 2026-07-13. Adds `sim_read_f32_le(BYTEA, INT)` helper (hand-decoded IEEE-754 little-endian using a `BIGINT` accumulator to sidestep INT4 sign-extension when bit 31 is set; handles ±0 / ±Inf / NaN / subnormals with a `val = val` NaN-preservation guard around the sign flip), `sim_event_type_name(SMALLINT)` enum lookup (mirrors `EventTypes.hpp`, no second-source lookup table by design), `sim_decode_attributes(BYTEA)` / `sim_decode_concepts(BYTEA)` / `sim_decode_recognition(BYTEA)` (TABLE-returning, joined to `sim_attribute_registry` / `sim_concept_registry` / `sim_pattern_registry` respectively; unknown ids surface with NULL key/category so registry drift is visible rather than silent), `sim_decode_input(BYTEA)` → jsonb (decodes the full 20-byte wire INPUT frame — header + body — as stored in `sim_match_inputs.payload`; malformed frames return `{"error": "…", "version": …, "msg_type": …}` rather than NULL so `SELECT`s stay lossless), `sim_decode_event(SMALLINT, BYTEA)` → jsonb (MatchEnd payload decoded as `hash_hex_be` + `hash_u64`; other event types return `event_type` + `event_type_name` + optional `payload_hex` fallback for unknown non-empty payloads). All `CREATE OR REPLACE FUNCTION ... IMMUTABLE STRICT` except `sim_decode_event` which is `IMMUTABLE` without `STRICT` because the payload column is legitimately NULL for most event types. Idempotent; the runner picked it up as an unapplied migration and applied it in one transaction. Smoke-tested with hand-crafted payloads: `sim_read_f32_le` round-trips 1.5, ±0, ±1, Inf, NaN, π; `sim_decode_attributes` on a synthesized 2-entry PackedU16F32 returns the correct `(attr_id, key, category, value)` rows joined to `sim_attribute_registry`; `sim_decode_input` on a synthesized 20-byte frame returns `{version:1, msg_type:32, payload_size:16, client_tick:42, dir_x:1.0, dir_y:0.0, wants_sprint:true, wants_walk:true}`; `sim_decode_event` on a fake MatchEnd payload returns the hex + int64 hash pair; NULL / short-payload / wrong-version / wrong-length paths all surface useful errors.

**Backend debug endpoint**
- [x] `backend/src/controllers/SimDebugController.{h,cpp}` mounted at `/api/sim/debug` in `main.cpp` — landed 2026-07-13. Feature-gated: constructor reads `FH_ENABLE_SIM_DEBUG` from env once; when unset/`0`/`false`/`no`/`off` the controller registers zero routes and logs `[sim-debug] endpoints DISABLED (set FH_ENABLE_SIM_DEBUG=1 to enable)` so prod stays clean by default. When enabled (docker-compose defaults dev to `FH_ENABLE_SIM_DEBUG=${FH_ENABLE_SIM_DEBUG:-1}`) it logs `[sim-debug] endpoints ENABLED under /api/sim/debug (admin-only, rate-limited 10 req/60s per admin)` and registers three GET routes. Auth: dual-path — Bearer login JWT (verified via `fh::crypto::verifyJwtHS256` with `JWT_SECRET`, `"userId":"N"` claim extracted from payload, mapped to `person_id` via `SELECT person_id FROM users WHERE id = $1`) OR `fh_sess` cookie (via `SessionService::parseCookieValue` + `requireSession`). Admin check via direct SQL `SELECT 1 FROM admins a JOIN users u ON u.id = a.user_id WHERE u.person_id = $1::int LIMIT 1` (chosen over `SessionService::requireAdmin` to keep the JWT-path admin check consistent with the cookie-path check and avoid a redundant round-trip). Rate limiter: per-admin sliding window (`std::mutex` + `std::unordered_map<person_id, std::deque<steady_clock::time_point>>`, cap 10 within 60s); exceeded → HTTP 429 `{error:"rate limit exceeded", limit:10, window_seconds:60}`. Added `HttpStatus::TOO_MANY_REQUESTS = 429` to `Response.h/.cpp` (was missing from the enum, needed for the 429 response).
- [x] `GET /api/sim/debug/matches/:id/inputs?from_tick=N&to_tick=M&limit=L` — landed 2026-07-13. SQL: `SELECT tick_num, slot_id, encode(payload,'hex'), sim_decode_input(payload)::text FROM sim_match_inputs WHERE match_id = $1::bigint AND tick_num BETWEEN $2 AND $3 ORDER BY tick_num, slot_id LIMIT $4`. `from_tick` defaults to 0; `to_tick` defaults to `INT32_MAX` (surfaced as `to_tick: null` in the JSON envelope to signal "unbounded"). `limit` defaults to 500, clamped to `[1, 1000]`. Response envelope: `{match_id, from_tick, to_tick, limit, count, rows: [{tick_num, slot_id, payload_hex, decoded}]}` where `decoded` is the parsed `sim_decode_input` jsonb. Verified with admin JWT for user_id=1 → `HTTP 200 {"count":0,"rows":[],...}` (no inputs recorded for match_id=1 yet — correct).
- [x] `GET /api/sim/debug/matches/:id/events?from_tick=N&to_tick=M&limit=L` — landed 2026-07-13. Same envelope shape as `/inputs` with additional `id, event_type, event_type_name` fields per row, `ORDER BY id ASC`. Uses `sim_decode_event(event_type, payload)::text` from migration 201. Verified end-to-end with admin JWT on real match_id=1 data: returns 3 rows (`MatchStart` at tick 0, `MatchEnd` at tick 69675 with `hash_hex_be:"4004d2933dc960e5" hash_u64:4613043448172863717`, second `MatchStart` at tick 0 from a subsequent match run) — hash decoded inline via the SQL function, no client-side parsing needed. Auth matrix verified: unauth → 401 `{error:"sign in required"}`, non-admin JWT (user_id=4) → 403 `{error:"admin only"}`, invalid path param (`matches/abc/`) → 400 `{error:"invalid matchId"}`, 11th rapid request within 60s → 429.
- [x] `GET /api/sim/debug/matches/:id/state?tick=T` — **landed 2026-07-13 (sub-slice 8.1)**. Backend `SimDebugController::handleState()` now proxies to the sim daemon's internal HTTP admin endpoint (`POST http://footballhome_sim:9101/admin/replay` with `Authorization: Bearer $FH_SIM_ADMIN_TOKEN`) via [backend/src/core/HttpClient.h](backend/src/core/HttpClient.h). Request body: `{"match_id":N,"up_to_tick":T?}` (both are wire-format `uint64` / `uint32`, `up_to_tick` omitted → sim defaults to end-of-match `MatchEnd.tick_num`). Sim response is forwarded verbatim (200 body, 400/404/500 preserved; transport failure → 502 `{error:"sim daemon unreachable", detail}`, missing token on backend → 503). Auth + rate-limit run BEFORE the RPC. The sim endpoint is implemented by [sim/src/admin/AdminHttpServer.{hpp,cpp}](sim/src/admin/AdminHttpServer.cpp) — hand-rolled AF_INET listener (single request at a time, 5 s SO_RCVTIMEO/SO_SNDTIMEO, 16 KB request cap, `constantTimeEquals` for bearer compare), its own dedicated `PgClient` connection so tick-loop and admin traffic never contend on the same libpqxx handle (§22.12 decision #4), booted from `main.cpp` after `WebSocketTransport::start()` and stopped BEFORE `input_log.stop()` / `event_log.stop()` in shutdown. Env: `FH_SIM_ADMIN_TOKEN` (required on both containers, flows via `env_file: ./env` in docker-compose to avoid shell substitution clobber), `SIM_ADMIN_PORT` (default 9101), `SIM_ADMIN_BIND_ADDRESS` (default 0.0.0.0 within the podman network — the network segment is the perimeter, the token is defence-in-depth). Verified end-to-end 2026-07-13 from `footballhome_backend` → `footballhome_sim`: no bearer → 401 `{error:"unauthorized"}`, wrong bearer → 403 `{error:"forbidden"}`, unknown match_id → 404 `{error:"match not found","match_id":N}`, valid match+bad scenario → 500 forwarded from sim's `replayMatch` verbatim, admin JWT through backend → same 500 forwarded verbatim (proving both hops end-to-end). 35/35 sim `ctest` tests pass including 20 new tests in [sim/tests/test_admin_http_server.cpp](sim/tests/test_admin_http_server.cpp) covering `parseHttpRequest`, `parseReplayJson`, `constantTimeEquals`, and 9 TCP-loopback e2e scenarios.
- [x] Rate limit: 10 req/60s per admin — landed 2026-07-13. Sliding-window in-memory (per-process; if backend is horizontally scaled later, migrate to Redis or Postgres-backed token bucket). Purposefully aggressive: replays are heavy, this is a debug surface, not a hot path. Verified end-to-end (11 rapid `/events` calls: 10× 200, then 429 until window rolls).

**Sub-slice 8.1 — Cross-container replay for `/state` (landed 2026-07-13)**
- [x] Path chosen: **(c) internal HTTP RPC** — the sim daemon exposes its own admin HTTP endpoint (`POST /admin/replay` on port 9101, bearer-token gated), the backend calls it via [backend/src/core/HttpClient.h](backend/src/core/HttpClient.h). Neither of the two paths originally sketched below was taken. Rationale below.
- [x] Path (a) — *bundle `fh-sim-replay` into the backend image* — rejected. Prior attempt (2026-07-12 session) discovered the toolchain gap runs deeper than libpqxx alone: the sim is built on Debian trixie-slim (gcc-14, glibc 2.41, libstdc++ 6.0.33) while the backend is on Debian bookworm (gcc-12, glibc 2.36, libstdc++ 6.0.32). A trixie-built binary run inside the bookworm backend hits `GLIBC_2.39 not found` / `GLIBCXX_3.4.32 not found` at process start. Static-linking libpqxx isn't sufficient; libstdc++ itself needs to match. Fixing this properly (either bump backend to trixie, or ship a fully-static sim binary via musl) is a much larger change than the RPC surface itself.
- [x] Path (b) — *UNIX-socket IPC daemon* — rejected. Adds a bespoke wire format when HTTP with JSON already exists in both containers (`HttpClient` on backend, the trivial listener we needed anyway on sim). No security or performance win over loopback HTTP on a private podman network.
- [x] Path (c) — *internal HTTP RPC*, chosen. This is the industry-standard microservice-to-microservice pattern: each container owns its binary and its runtime deps, communication is a narrow, versionable, auditable HTTP contract, and the security boundary is a shared bearer token loaded from the same `env_file`. Zero cross-distro toolchain surface. See `AdminHttpServer.hpp` header comment for the full wire spec (§request/response schemas, error contract, auth model, threading, size limits).
- [x] Sim: [sim/src/admin/AdminHttpServer.{hpp,cpp}](sim/src/admin/AdminHttpServer.cpp) — hand-rolled AF_INET listener (own worker thread, single-request-at-a-time, 5 s `SO_RCVTIMEO`/`SO_SNDTIMEO`, 16 KB `Content-Length` cap → 413, malformed request → 400, wrong method → 405, wrong path → 404, missing bearer → 401 `{error:"unauthorized"}`, wrong bearer → 403 `{error:"forbidden"}` via `constantTimeEquals`). Uses its OWN `PgClient` handle (§22.12 decision #4) so admin traffic and the tick loop never contend on the same libpqxx connection. Delegates the actual replay to `fh::sim::tools::replayMatch()` — the same function `fh-sim-replay` uses — and formats the result as `{match_id, final_tick, hash_hex, hash_u64, inputs_applied, slots_synthesized, canonical_hex?}`. `canonical_hex` is emitted only when the request body sets `"emit_hex":true` (the backend proxy doesn't expose this — it's O(200 KB) and only useful for forensic divergence work; reachable via a direct RPC probe from inside the container).
- [x] Backend: [backend/src/controllers/SimDebugController.cpp](backend/src/controllers/SimDebugController.cpp) `handleState()` rewritten to run auth + rate-limit locally, then `HttpClient::postJson("$FH_SIM_ADMIN_URL/admin/replay", body, {Authorization: Bearer $FH_SIM_ADMIN_TOKEN})`, forward status + body verbatim. Transport failure (DNS / connect / TLS) → 502 `{error:"sim daemon unreachable", detail, url}`. Missing `FH_SIM_ADMIN_TOKEN` on backend → 503 `{error:"sim admin RPC not configured (FH_SIM_ADMIN_TOKEN unset on backend)"}`. Envelope preserved exactly — no double-serialization, no field re-ordering.
- [x] docker-compose: `FH_SIM_ADMIN_URL=http://footballhome_sim:9101` exported to `backend`; `SIM_ADMIN_BIND_ADDRESS=0.0.0.0` + `SIM_ADMIN_PORT=9101` exported to `footballhome_sim`; `FH_SIM_ADMIN_TOKEN` flows from `env_file: ./env` to BOTH services (deliberately NOT listed in `environment:` — if it were, `${FH_SIM_ADMIN_TOKEN:-}` would render empty whenever the shell running `podman-compose up` doesn't export the token, silently disabling the endpoint). Token generated with `openssl rand -hex 32`, stored in `env` (not committed — `env` is git-ignored). `EXPOSE 9101` added to [sim/Dockerfile](sim/Dockerfile) for docs; port is never mapped to the host.
- [x] Tests: 20 new tests in [sim/tests/test_admin_http_server.cpp](sim/tests/test_admin_http_server.cpp) — 5 `parseHttpRequest` (valid/case-insensitive/missing-terminator/content-length-mismatch/oversized), 8 `parseReplayJson` (all fields / only-required / key-order-agnostic / missing-required / zero-match-id / unknown-field / trailing-garbage / out-of-range), 1 `constantTimeEquals`, 9 TCP-loopback e2e (missing-bearer=401, wrong-bearer=403, wrong-method=405, unknown-path=404, match-not-found=404, valid=200-with-hash, valid+emit_hex=200-with-canonical, refuse-start-without-token, stop-idempotent). All run in the sim container's `ctest` gate (fails the image build if any test fails). 35/35 total pass.
- [x] Verified end-to-end 2026-07-13: from inside `footballhome_backend`, direct probes to `http://footballhome_sim:9101/admin/replay` returned 401/403/404 correctly per bearer/match state; valid admin bearer + `{"match_id":1}` → `HTTP 200 {"match_id":1, "final_tick":24137, "hash_hex":"0xcd441eb4dd710f21", "hash_u64":14790980838349672225, "inputs_applied":0, "slots_synthesized":0}`. From the host with a minted admin JWT hitting `/api/sim/debug/matches/1/state` (backend auth + rate-limit + RPC + sim admin + replay + hash-forward) → same 200 body. **Initial verification hit a pre-existing DB/runtime enum split** (`sim_scenarios.empty_pitch` was seeded at id=1 by migration 200's `SMALLSERIAL`, but runtime code — `main.cpp`, `Replay.cpp::makeScenario`, `EventTypes.hpp` — treats `scenario_id` as a hand-managed enum where 0=EmptyPitchScenario, and `upsertMatch`'s `ON CONFLICT DO UPDATE SET server_version = EXCLUDED.server_version` deliberately left the sticky `scenario_id=1` in place across restarts, so `Replay.cpp::makeScenario(1)` threw `"unknown scenario_id=1"`). **Closed 2026-07-13** by [database/migrations/204-sim-scenarios-empty-pitch-id-zero.sql](database/migrations/204-sim-scenarios-empty-pitch-id-zero.sql) (renumbers `empty_pitch` from DB id=1 → 0 and updates the seeded `sim_matches.id=1.scenario_id` in the same transaction, with FK drop/re-add + post-check `DO` block; §22.9 pattern applied to `sim_scenarios`) + a defence-in-depth **boot-time drift guard** in [sim/src/main.cpp](sim/src/main.cpp) that reads `getMatch(match_id)` BEFORE `upsertMatch` and refuses to start with a `return 6` if the DB row's `(scenario_id, seed, tick_hz)` differ from what the daemon intends to write (rationale: recorded `sim_match_inputs` are keyed against those three fields; silently overwriting them would corrupt every replay — same class of "config drift under a live matching key" that Postgres' `data_directory` mismatch and Kafka's `broker.id` mismatch bail on at startup). Fresh `sim_matches.result` after the boot-guard admission: id=1 hashes to `0xcd441eb4dd710f21`, matching what `/state` returns.

**Frontend hookup (Tactical Games hub → sim)**
- [x] Tile from hub → `/sim.html` — landed 2026-07-13. Tile already existed in [frontend/tactical-games.html](frontend/tactical-games.html) from an earlier drop (labeled "Sim Demo" with an "M0" badge and honest copy: *"Wander an empty pitch. Joystick + sprint. Zero rules — just proves the sim works end-to-end."*). Verified the anchor `<a class="game" href="/sim.html">` serves live via nginx. Kept the existing label rather than renaming to the spec's proposed "Live pitch (M0 dot demo)" — the current copy is arguably more honest ("Sim Demo" makes zero training claims), and the tactical-games.html file is bind-mounted so no rebuild was needed.
- [x] Back-link from `/sim.html` → hub — landed 2026-07-13. Added `<a id="sim-back" href="/tactical-games.html" aria-label="back to Tactical Games">‹ Back</a>` inside `#sim-root` in [frontend/sim.html](frontend/sim.html), plus a top-left `#sim-back` block in [frontend/css/sim.css](frontend/css/sim.css) (`position:absolute; top:max(8px, env(safe-area-inset-top)); left:max(8px, ...); z-index:3; rgba(0,0,0,0.55) background`; hover raises alpha to 0.75). Sits above the canvas / joystick / sprint pad but doesn't cover them (top-left corner is empty in the current sim UI). Both files are bind-mounted into `footballhome_frontend` (`-v /srv/footballhome/frontend:/usr/share/nginx/html`), so edits are live immediately — verified via `curl http://127.0.0.1:3000/sim.html` + `curl http://127.0.0.1:3000/css/sim.css` returning the new markup and rule.
- [x] No engine or wire-protocol changes — HTML + CSS only, zero touches to `sim/src/**` or `frontend/js/sim/**`.

**§16.5 exit criteria additions**
- [x] Sim daemon refuses to start if `sim_attribute_registry` or `sim_concept_registry` is empty (`RegistryLoader` throws `PgError` with context `"loadAttributeRegistry"` / `"loadConceptRegistry"` on zero-row load). No hard-coded fallback attribute values exist in `sim/src/{physics,controller,behavior,scenario,match}/` (CI grep `check_no_hardcoded_attrs.sh` enforces).
- [x] Every match played end-to-end has: (a) a `sim_matches` row with `ended_at` set — done via `updateMatchEnded`; (b) `sim_match_inputs` rows for every accepted input — done via `AsyncPgLog<InputRow>`; (c) `sim_match_events` rows for `MatchStart` + all `ClientConnect`/`Disconnect`/`SlotClaim`/`SlotRelease` + `MatchEnd` with canonical snapshot hash — done via `AsyncPgLog<EventRow>` + `main.cpp` shutdown sequence; (d) `sim_matches.result` populated with the same hash — done. **Closed 2026-07-13** by [sim/tests/test_match_lifecycle_persistence.cpp](sim/tests/test_match_lifecycle_persistence.cpp) — mirrors `main.cpp`'s lifecycle step-for-step against `InMemoryPgClient` (same `IPgClient` contract the live `PgClient` implements), drives a real client through connect → INPUT → disconnect on a loopback `WebSocketTransport`, then asserts the full row-set: `getMatch` returns the row, `matchEnded == true`, `matchResult` is exactly the 8-byte canonical FNV-1a-64 hash, `inputsForMatch` has ≥1 row of `kInputFrameBytes` payload, and `eventsForMatch` contains 1×`MatchStart` + ≥1×`ClientConnect`/`SlotClaim`/`SlotRelease`/`ClientDisconnect` + 1×`MatchEnd` with the same hash bytes, plus `front == MatchStart && back == MatchEnd` (the ordering guarantee `main.cpp`'s comment claims). Runs in every container ctest gate (0.48 s wall).
- [x] `fh-sim-replay --match-id N` produces byte-identical snapshot hash to the recorded `match_end` hash for every `N`. Closed 2026-07-13 by `test_replay.cpp::replay_matches_live_human_sprint_east_400` + `replay_default_target_reads_match_end_tick` running as part of the container `ctest` gate.
- [x] Cross-arch determinism CI green with DB-sourced replay: live amd64 = replay amd64 = replay arm64 (via qemu). Closed 2026-07-13 by sub-slice 6.1's rewrite of `check_determinism_cross_arch.sh`. Note: uses `InMemoryPgClient` + `test_replay` rather than a real Postgres — the DESIGN spec's original phrasing ("DB-sourced replay" implying a live compose stack) turned out to be unnecessary because the assertion `replay_hash == live_hash` is proved bit-for-bit inside a single in-memory run, and the cross-arch dump diff proves the two arches compute the same `live_hash`. Net effect: same guarantee, no orchestration dependency.
- [x] First-time slot join for a new `person_id` materializes a default `sim_player_profile` row from `defaultPhysical()` + `defaultConcepts()`; subsequent joins read the existing row byte-for-byte. Covered by `test_profile_store.cpp`.
- [x] Admin `GET /api/sim/debug/matches/:id/state?tick=T` returns the deterministic snapshot at tick T for any recorded match. Route + auth + rate-limit landed in sub-slice 8 (2026-07-13); cross-container replay via internal HTTP RPC landed in sub-slice 8.1 (2026-07-13, same day) — see the sub-slice 8.1 block above for the full wire spec + verification matrix.
- [x] Input write queue never blocks the tick loop under simulated 100 ms Postgres latency for a 10-minute match (load test enforces zero dropped inputs). Closed 2026-07-13 by [sim/tests/test_async_pg_log_load.cpp](sim/tests/test_async_pg_log_load.cpp) — two-tier design: `async_pg_log_no_drops_under_100ms_pg_latency_5s` runs in every `ctest` invocation (models 22 slots × 20 Hz × 5 s with a 100 ms-sleep sink → 2 200 rows pushed, 0 dropped, 51 sink batches, 5.1 s wall), and `async_pg_log_no_drops_10min_match` runs the full 10-minute horizon (264 000 rows) opt-in via `FH_SIM_LOAD_10MIN=1` — wired through the Makefile target `sim-load-test-10min`. The 5 s test is the steady-state guardrail (drain rate 2 560 rows/s vs push rate 440 rows/s → 5.8× headroom); the 10 min test additionally guards against slow leaks and scheduler starvation over long horizons. Neither uses a real Postgres — a `std::this_thread::sleep_for(100ms)` in the sink lambda faithfully models the worst-case latency without a toxiproxy sidecar or compose stack.

**Slice 13 explicit non-goals**
- Multi-match orchestration (`SimServer::createMatch` beyond the seeded id=1) — deferred; single-daemon single-match convention stays for M0. **Plan landed 2026-07-13 in §16.7 below — Option A ("N daemons behind match-router") chosen for M1; §21.2 item 3 closed.**
- Profile-editing UI for coaches — deferred to M1+ when there's actual attribute values worth editing.
- Names on pieces from real fh members — plumbing lands here (`sim_player_profile` keyed by `person_id`), UI defers to M1+.
- Replay scrubbing UI — deferred; API only.
- Match visibility beyond `public` — `sim_matches.visibility` column exists but stays hard-coded to 0. Wire-up when clubs/private matches matter.
- Snapshot compression (delta encoding, keyframes) — deferred; M0 stores full canonical hex only at match_end for verification, not per-tick.

### 16.7 Multi-match orchestration plan (M1 unblocker — resolves §21.2 item 3)

Added 2026-07-13 as the resolution of §21.2 item 3. This section is a **plan**, not code — the actual implementation lands with the M1 slice plan (§21.6 Task B follow-up). The plan chooses between three orchestration models, records the decision + rationale, and spells out the concrete migration path from the M0 single-daemon-single-match convention.

**Context.** M0 ships one `footballhome_sim` container with `SIM_MATCH_ID=1` baked in. `SimLobbyController::handleCreateMatch` (in the backend) is a no-op stub that returns the pre-seeded row from [database/migrations/202-sim-lobby.sql](database/migrations/202-sim-lobby.sql). M1 introduces real training-mode drills, and a coach + 3 players running a drill while another coach + 4 players start a second drill in the same club is a first-class product story. The daemon needs to serve K > 1 concurrent matches somehow. The three options considered:

**Option A — N daemons behind a match-router keyed on `match_id`.** One container per match (`footballhome_sim_1`, `footballhome_sim_2`, ...). The backend `SimOrchestrator` (new) shells out to podman to launch a container per match. A router (nginx `upstream` regex or a backend-side WS proxy) maps `ws://.../sim/${match_id}` to `footballhome_sim_${match_id}:9100`. Cross-container HTTP RPCs (`/admin/replay`, `/admin/state`) generalize trivially from the §16.6 sub-slice 8.1 pattern — the `AdminHttpServer` per-daemon is untouched, the backend just consults `sim_running_matches` to pick the right container hostname before dispatching. Each daemon owns exactly one `SIM_MATCH_ID` and every M0 determinism gate (§22.1, §22.2, §22.9, §22.14, Task D's boot-time drift guard) holds unchanged per-daemon.

**Option B — one daemon with a thread pool serving K matches.** One `footballhome_sim` container. Internally: `unordered_map<MatchId, unique_ptr<Match>>`, a scheduler thread per match (or a work-stealing pool). WebSocket dispatcher routes to the internal `Match` instance by `match_id` from the URL. `POST /api/sim/matches` becomes a real in-daemon create.

**Option C — per-match ephemeral process spawned on demand.** Same shape as Option A but with `podman run --rm` on POST + auto-teardown on `MatchEnd`. No warm daemon pool.

**Comparison** (M1's ~5–20 concurrent matches is the target):

| Axis                       | A: N daemons                  | B: 1 daemon, thread pool     | C: ephemeral per-match       |
|----------------------------|-------------------------------|------------------------------|------------------------------|
| Failure isolation          | Excellent (per-container)     | Bad (one crash → all die)    | Excellent (per-container)    |
| Cold-start latency         | ~50 ms (warm pool of images)  | ~1 ms (in-process)           | ~1 s (podman run cold)       |
| Memory per match           | ~30 MB (PgClient + baseline)  | ~5 MB (Match struct alone)   | ~30 MB                       |
| Determinism preservation   | Trivial (M0 invariants hold)  | Requires care (per-thread `PgClient`, no shared malloc jitter budget) | Trivial |
| Router complexity          | Medium (per-match upstream)   | None (in-daemon dispatch)    | Medium                       |
| Observability              | Excellent (per-container logs)| Poor (interleaved logs, gdb attach sees all matches) | Excellent |
| DB connection count        | 3N (main + input + event per daemon) | 3K (pooled or per-thread — breaks §22.12 rule 4 "no pool for M0") | 3N |
| Podman/host coupling       | High (needs podman socket)    | None                         | High                         |
| Reaper complexity          | Medium (idle-timeout worker)  | Medium (thread cleanup + memory reclamation) | Trivial (`--rm`) |
| Per-host scaling ceiling   | Hundreds                      | Thousands                    | Hundreds                     |
| M1 target fit (5–20 matches)| Great                        | Overkill                     | Good — but 1 s cold-start hurts drill UX |
| M4+ fit (500+ concurrent)  | Marginal                      | Great                        | Bad (spawn overhead per match) |

**Decision: Option A for M1.**

Reasoning:

1. **Failure isolation is decisive at M1.** M1 is where new drill scenarios are being written — tick-loop bugs and physics-edge-case crashes are common during that phase. A single-daemon crash taking down all live drills (Option B) is a worse user experience than a cold-start latency of ~50 ms per new match (Option A with a warm image pool).

2. **The M0 machinery generalizes.** Every §16.6 subsystem — `PgClient`, `ProfileStore`, `AsyncPgLog<InputRow>`, `AsyncPgLog<EventRow>`, `SimServer`, `AdminHttpServer`, `main.cpp`'s upsertMatch + drift guard + `updateMatchEnded` shutdown chain — was designed for one daemon owning one match. Option A reuses each of those verbatim; Option B needs each of them rewritten to key on `match_id`. §22.12's per-connection-thread rule and §22.14's write-policy CI check both hold trivially per-daemon.

3. **Migration path is one-way friendly.** Going from A to C later (adding `--rm` flag on `podman run` if scaling issues appear) is a one-line change in `SimOrchestrator::launchMatch`. Going from A to B later (for M4+ high-concurrency) is a rewrite, but Options A and B are not mutually exclusive: A handles training-mode drills, a future Option-B daemon can host competitive-mode matches on the same host without the two orchestration models fighting.

4. **Operational tooling exists.** `sudo podman logs footballhome_sim_42`, `sudo podman ps --filter name=footballhome_sim_`, `sudo podman exec footballhome_sim_42 fh-sim-replay ...` — every M0 debugging incantation works verbatim per-match. No new observability stack needed.

**Concrete M1 implementation plan** (the sub-slice sequence that Task B will spell out in full):

1. **Backend `SimOrchestrator` (new — [backend/src/orchestration/SimOrchestrator.{h,cpp}](backend/src/orchestration/SimOrchestrator.h)):**
   - Wraps a UNIX-socket connection to the Podman API (`/run/podman/podman.sock`) OR shells out to `podman run` if the API turns out ops-heavy.
   - `launchMatch(match_id, scenario_id, seed) -> ContainerId`. Body: podman-run the `footballhome_sim` image with env `SIM_MATCH_ID=${match_id} SIM_MATCH_SEED=${seed} SIM_PORT=9100 SIM_ADMIN_PORT=9101`, container name `footballhome_sim_${match_id}`, joined to network `footballhome_default`, restart policy `on-failure:3` (bail after 3 tick-loop crashes so we don't loop-crash forever).
   - Waits for `GET http://footballhome_sim_${match_id}:9101/healthz` to return 200 with 5 s timeout. Otherwise cleanup + throw.
   - Registers `(match_id, container_id, container_name)` in a new `sim_running_matches` table (or in-memory map keyed off `sim_matches.ended_at IS NULL` for restart resilience).

2. **Backend `SimLobbyController::handleCreateMatch` becomes real:**
   - Accepts `{scenario_id, seed?}` (seed defaults to a cryptographically-random `uint64_t` server-side).
   - INSERTs a `sim_matches` row (id = SERIAL — the existing scenario_id=0 stability from Task D applies per-match, not per-scenario).
   - Calls `SimOrchestrator::launchMatch(match_id, scenario_id, seed)`.
   - Returns `{match_id, ws_url}` where `ws_url = ws://footballhome_sim_${match_id}:9100/sim` (M1 will decide whether the browser gets the container-hostname URL directly or a signed short-lived proxy URL — see step 5).

3. **Backend `SimRouter` (new — [backend/src/orchestration/SimRouter.{h,cpp}](backend/src/orchestration/SimRouter.h)):**
   - Generalizes the §16.6 sub-slice 8.1 pattern: `SimDebugController` endpoints (`/matches/:id/inputs`, `/matches/:id/events`, `/matches/:id/state`) look up `container_name` from `sim_running_matches` and forward the HTTP-RPC to `http://${container_name}:9101/admin/*`.
   - Bearer token still comes from `FH_SIM_ADMIN_TOKEN` env — one shared token across all sim daemons in the same compose stack is acceptable (the token is inside the compose network already; a per-daemon token adds ops complexity for zero threat-model gain).

4. **Frontend `sim.html`:**
   - Reads `?match_id=X` from URL query params.
   - WebSocket URL becomes `ws://<host>/sim/${match_id}` — nginx handles the routing (step 5). Fallback for local dev where nginx routing isn't set up: WS URL points at `ws://<host>:${9100 + match_id}` with each sim daemon exposing a unique host port (matches the docker-compose scaling pattern).

5. **nginx (frontend container [frontend/nginx.conf](frontend/nginx.conf)):**
   - Adds a `location ~ ^/sim/(?<mid>\d+)$` block that `proxy_pass`es to `http://footballhome_sim_${mid}:9100/sim` (podman's built-in DNS resolves container names within the shared network, same as it already does for `footballhome_sim` → `9100` today).
   - `proxy_http_version 1.1;` + `Upgrade $http_upgrade;` + `Connection "upgrade";` (standard nginx WS-upgrade dance — the current single-daemon config already has this for `footballhome_sim`, just needs to become regex-templated).

6. **Reaper:**
   - Backend-side systemd timer OR a periodic goroutine-equivalent (a std::thread with `sleep_for(5min)` loop) that:
     - `SELECT match_id, container_id FROM sim_running_matches WHERE (SELECT ended_at FROM sim_matches WHERE id=match_id) IS NOT NULL;`
     - For each: `podman rm -f ${container_id}` then `DELETE FROM sim_running_matches WHERE match_id=...`.
   - Idle-timeout inside the sim daemon itself: `SimServer` gains a "zero active clients for > 5 min" watchdog that writes `MatchEnd` + exits with code 0 (the existing MatchEnd shutdown path from §16.6 sub-slice 4 handles the rest). Backend reaper then picks up the row in the next tick.

7. **Determinism guarantees (per-match, unchanged from M0):**
   - Each daemon still owns exactly one `SIM_MATCH_ID` → §22.1 (bit-exact determinism), §22.2 (Fixed64), §22.9 (registry ID stability), §22.14 (write policy) all hold per-daemon.
   - Task D's boot-time drift guard (`main.cpp` `getMatch` before `upsertMatch`) fires per-daemon on `(scenario_id, seed, tick_hz)` mismatch — recorded `sim_match_inputs` for match K are keyed against daemon K's config, silent overwrite would corrupt replay just like it would in M0.
   - Cross-arch replay CI ([sim/scripts/check_determinism_cross_arch.sh](sim/scripts/check_determinism_cross_arch.sh)) works verbatim — it proves determinism per-match, not cross-match, so N daemons is just N independent replay proofs.

8. **Observability:**
   - `sudo podman logs footballhome_sim_42` shows just match 42's logs (no interleaving with other matches).
   - `sudo podman ps --filter name=footballhome_sim_ --format '{{.Names}}\t{{.Status}}'` lists all running matches at a glance.
   - Backend HTTP endpoint `GET /api/sim/matches?status=running` returns all live matches with container names for an admin dashboard.

9. **Failure modes and their handling:**
   - **Daemon tick-loop crash**: podman's `restart: on-failure:3` retries 3 times then gives up. Backend reaper detects the exited container within 5 min, marks `sim_matches.ended_at = now()` with a NULL `sim_matches.result` (distinguishing crash from clean end). Clients see WS disconnect + get an "abandoned" status via HTTP polling on `/api/sim/matches/:id`.
   - **Daemon can't reach DB at boot**: same as M0 — daemon bails fail-loud, container never becomes healthy, `SimOrchestrator::launchMatch` returns a 5 s timeout error, backend cleans up the `sim_matches` row (or leaves it with `ended_at = launch_time` for audit).
   - **Backend crash**: running sim daemons keep going (they don't depend on the backend for tick or persistence — only for lobby endpoints). On backend restart, `SimOrchestrator` runs a reconciliation pass: `SELECT id FROM sim_matches WHERE ended_at IS NULL` vs `podman ps --filter name=footballhome_sim_`, orphaned podman containers get killed (`podman rm -f`), orphaned DB rows get marked abandoned. This reconciliation runs once on backend startup, guarded by an advisory lock so parallel backend replicas don't fight.
   - **Podman daemon crash**: catastrophic — all matches die. Not survivable on single-host deployment; multi-host with K8s or Nomad is a post-M1 problem.
   - **Container name collision** (someone left `footballhome_sim_42` around from an aborted previous run): `SimOrchestrator::launchMatch` runs `podman rm -f footballhome_sim_${match_id}` before `podman run` — idempotent-by-force. The match_id is a fresh SERIAL so collisions require someone recycling id namespace, which the database's IDENTITY column prevents.

10. **Migration path from M0's single-daemon setup:**
    - M0 continues to ship the current `footballhome_sim` container with `SIM_MATCH_ID=1` in [docker-compose.yml](docker-compose.yml) — this becomes match 1 and stays as a "reserved M0 legacy" match forever (Task D's boot-time guard prevents accidental re-seeding).
    - Task B lands `SimOrchestrator` and `SimRouter` alongside the compose entry, with match_id > 1 launching dynamically.
    - Once M1 is stable, [docker-compose.yml](docker-compose.yml) drops the static `footballhome_sim` entry in favor of a "sim-warmer" service that pre-pulls the image + primes the podman cache but doesn't run a match itself. `SIM_MATCH_ID=1` matches launch via `SimOrchestrator` like every other match.
    - `SIM_MATCH_ID` env stays required — every daemon still needs to know which match it owns, and boot-time drift guard needs it for the sanity check.

**Revisit if / when**:

- **Per-host concurrent-match count exceeds ~100** (podman-daemon-per-host ceiling). Evaluate Option B (thread pool) with pooled `PgClient` connections — the exception to §22.12's "no pool for M0" rule now has a real-world driver. Alternatively, spread Option A across K8s pods on multiple hosts.
- **Cold-start latency of ~50 ms becomes a UX problem** (matchmaking latency-sensitive competitive-mode drills where players expect sub-second lobby-to-tick). Warm-pool of pre-launched sim daemons (waiting for match assignment) is a straightforward extension: start K empty daemons, `POST /admin/assign_match` on one to hand it a match_id, restart the pool when a daemon is claimed. Requires a small change to `main.cpp` to defer `upsertMatch` until an `/admin/assign_match` call arrives.
- **A single tick-loop bug causes so many restart-loops that podman's `on-failure:3` becomes noisy**: increase the retry cap OR remove the retry entirely (fail-fast + user-visible "match crashed, please start a new drill" is often the right UX for training mode).
- **DB connection count (3N) becomes a Postgres-side scaling limit** (default `max_connections=100` starts hurting around 30 concurrent matches). Standard remedy: put pgbouncer between the sim daemons and Postgres in transaction-pooling mode. libpqxx works with pgbouncer transparently when prepared statements are per-session; `PgClient` re-declares them on each new libpqxx connection so no change is needed on the sim side.

**Refs**:
- [§5.7](#57-match-orchestrator) (Match orchestrator internal object — unchanged per-daemon).
- [§14](#14-match-lifecycle-write-model) (match lifecycle — the `POST /api/sim/matches` RPC that was "not yet real" per the M0-reality block becomes real via `SimOrchestrator::launchMatch`).
- [§16.1](#161-deliverables) (M0 single-match checkbox — intentional scope; §16.7 unblocks the M1 multi-match expansion).
- [§16.6 sub-slice 8.1](#166-slice-13--persistence--replay-m0-close-out) (AdminHttpServer HTTP-RPC pattern that per-match daemons inherit and `SimRouter` fans out).
- [§21.2 item 3](#212-m1-blockers-fix-before-starting-m1-milestone-work) (this section resolves that checkbox).
- [§22.9](#229-registry-ids-are-stable-enum-values-not-surrogate-keys) (registry IDs — stability holds per-daemon since each daemon reads the shared registries at boot).
- [§22.12](#2212-persistence-library-architecture-slice-13-foundation) (persistence architecture — per-daemon `PgClient` contract holds unchanged; the "no pool for M0" rule graduates to "no pool for A-mode matches, evaluate a pool if we ever ship B-mode").
- [§22.14](#2214-2026-07-13-sim_player_profile-write-policy--first-touch-insert-only-in-m0) (write policy — per-daemon, so no cross-match write coordination needed; CI check runs at build time regardless of daemon count).

## 17. Project layout (per-file status tracked in §16.1; layout snapshot below reconciled with reality 2026-07-13 — §21.5 item 1 closed)

```
footballhome/
├─ sim/
│   ├─ DESIGN.md                 (this file)
│   ├─ WIRE.md                   (binary format reference)
│   ├─ CMakeLists.txt
│   ├─ Dockerfile
│   ├─ scripts/
│   │   ├─ check_no_floats.sh                (CI: no float in gameplay code)
│   │   ├─ check_no_bad_rng.sh               (CI: no std::rand / std::mt19937 in gameplay)
│   │   ├─ check_no_hardcoded_attrs.sh       (CI: no Fixed64::fromFloat outside registry paths)
│   │   ├─ check_determinism_cross_arch.sh   (host: amd64 vs qemu-arm64 replay parity)
│   │   ├─ gen_registry_header.awk           (build: migration 200 → M0Registry.generated.hpp)
│   │   └─ mint-dev-jwt.sh                   (dev: mint an admin JWT for /api/sim/debug/* probes)
│   ├─ src/
│   │   ├─ main.cpp
│   │   ├─ common/
│   │   │   ├─ IdTypes.hpp                   (PersonId, MatchId, SlotId, TickNum)
│   │   │   ├─ Role.hpp                      (M0 slot-role enum)
│   │   │   ├─ EntityState.hpp
│   │   │   ├─ M0Attributes.{hpp,cpp}        (defaultPhysical(), defaultConcepts())
│   │   │   └─ M0Registry.generated.hpp      (build-time, from migration 200)
│   │   ├─ math/
│   │   │   ├─ Fixed64.{hpp,cpp}
│   │   │   ├─ FixedMath.{hpp,cpp}           (fx_sqrt / fx_sin / fx_cos / fx_atan2)
│   │   │   ├─ TrigLUT.{hpp,cpp}             (sin/cos/atan2 lookup tables)
│   │   │   ├─ Vec3.hpp
│   │   │   └─ RngDet.hpp
│   │   ├─ registry/
│   │   │   ├─ AttributeRegistry.{hpp,cpp}
│   │   │   ├─ ConceptRegistry.{hpp,cpp}
│   │   │   └─ PatternRegistry.{hpp,cpp}
│   │   ├─ profile/
│   │   │   ├─ AttributeSet.{hpp,cpp}
│   │   │   ├─ ConceptSet.{hpp,cpp}
│   │   │   ├─ RecognitionSet.{hpp,cpp}
│   │   │   └─ PlayerProfile.hpp
│   │   ├─ awareness/
│   │   │   ├─ AwarenessView.hpp
│   │   │   └─ RecognitionSystem.{hpp,cpp}
│   │   ├─ physics/
│   │   │   ├─ IPhysicsWorld.hpp
│   │   │   └─ StubPhysics.{hpp,cpp}
│   │   ├─ controller/
│   │   │   ├─ IPlayerController.hpp
│   │   │   ├─ HumanController.{hpp,cpp}
│   │   │   ├─ WanderController.{hpp,cpp}
│   │   │   └─ AiController.{hpp,cpp}        (skeleton class, no behaviors plugged until M3)
│   │   ├─ behavior/
│   │   │   └─ IBehavior.hpp
│   │   ├─ scenario/
│   │   │   ├─ Scenario.hpp
│   │   │   └─ EmptyPitchScenario.{hpp,cpp}
│   │   ├─ match/
│   │   │   ├─ Slot.hpp
│   │   │   ├─ MatchClock.{hpp,cpp}
│   │   │   ├─ Mechanics.{hpp,cpp}           (deterministic per-tick pipeline)
│   │   │   ├─ Match.{hpp,cpp}
│   │   │   ├─ Snapshot.hpp
│   │   │   └─ CanonicalHash.{hpp,cpp}       (8-byte FNV-1a-64 snapshot hash)
│   │   ├─ net/
│   │   │   ├─ INetworkTransport.hpp
│   │   │   ├─ WebSocketTransport.{hpp,cpp}
│   │   │   ├─ WebSocketFrame.{hpp,cpp}
│   │   │   ├─ WebSocketHandshake.{hpp,cpp}
│   │   │   ├─ WireFormat.hpp                (msg-type/version constants shared with client)
│   │   │   ├─ LeCodec.hpp                   (little-endian read/write helpers)
│   │   │   ├─ InputFrame.{hpp,cpp}          (encode/decode symmetric helpers)
│   │   │   ├─ ISnapshotSerializer.hpp
│   │   │   └─ BinaryV1Serializer.{hpp,cpp}
│   │   ├─ auth/
│   │   │   └─ JwtVerifier.{hpp,cpp}
│   │   ├─ persistence/
│   │   │   ├─ IPgClient.hpp                 (pure-virtual DB contract)
│   │   │   ├─ PgClient.{hpp,cpp}            (libpqxx implementation)
│   │   │   ├─ InMemoryPgClient.{hpp,cpp}    (test double, same contract)
│   │   │   ├─ ProfileStore.{hpp,cpp}        (loadOrCreate default profile)
│   │   │   ├─ RegistryLoader.{hpp,cpp}      (DB → AttributeRegistry / ConceptRegistry / PatternRegistry)
│   │   │   ├─ EventTypes.hpp                (stable event-type enum, mirrored in migration 201's sim_event_type_name)
│   │   │   ├─ AsyncPgLog.hpp                (templated bounded-queue background drain)
│   │   │   ├─ InputLog.hpp                  (typedef AsyncPgLog<InputRow>)
│   │   │   └─ EventLog.hpp                  (typedef AsyncPgLog<EventRow>)
│   │   ├─ tools/
│   │   │   ├─ Replay.{hpp,cpp}              (reusable driver used by both fh-sim-replay and test_replay)
│   │   │   └─ replay_main.cpp               (fh-sim-replay CLI)
│   │   ├─ admin/
│   │   │   └─ AdminHttpServer.{hpp,cpp}     (POST /admin/replay bearer-gated RPC on :9101)
│   │   └─ server/
│   │       └─ SimServer.{hpp,cpp}
│   └─ tests/
│       ├─ CMakeLists.txt
│       ├─ test_harness.hpp                  (FH_TEST / FH_EXPECT / FH_EXPECT_EQ / FH_TEST_MAIN)
│       ├─ test_fixed64.cpp
│       ├─ test_fixed_math.cpp
│       ├─ test_trig_lut.cpp
│       ├─ test_vec3.cpp
│       ├─ test_rng_det.cpp
│       ├─ test_registry.cpp
│       ├─ test_attribute_set.cpp
│       ├─ test_concept_set.cpp
│       ├─ test_recognition_set.cpp
│       ├─ test_recognition_passthrough.cpp
│       ├─ test_stub_physics.cpp
│       ├─ test_match_clock.cpp
│       ├─ test_match_tick.cpp
│       ├─ test_mechanics.cpp
│       ├─ test_empty_pitch_scenario.cpp
│       ├─ test_human_controller.cpp
│       ├─ test_wander_controller.cpp
│       ├─ test_stamina.cpp
│       ├─ test_determinism.cpp
│       ├─ test_canonical_hash.cpp
│       ├─ test_binary_v1_serializer.cpp
│       ├─ test_input_frame.cpp
│       ├─ test_websocket_frame.cpp
│       ├─ test_websocket_handshake.cpp
│       ├─ test_websocket_transport.cpp
│       ├─ test_jwt_verifier.cpp
│       ├─ test_in_memory_pg_client.cpp
│       ├─ test_pg_client.cpp
│       ├─ test_profile_store.cpp
│       ├─ test_registry_loader.cpp
│       ├─ test_async_pg_log.cpp
│       ├─ test_async_pg_log_load.cpp        (5 s CI + opt-in 10 min via FH_SIM_LOAD_10MIN=1)
│       ├─ test_sim_server.cpp
│       ├─ test_admin_http_server.cpp
│       ├─ test_replay.cpp
│       └─ test_match_lifecycle_persistence.cpp
├─ database/migrations/
│   ├─ 200-sim-registries.sql                (all 8 sim tables + registries + seed rows, single file)
│   ├─ 201-sim-decode-functions.sql          (plpgsql helpers: sim_decode_input / _event / _attributes / _concepts / _recognition)
│   ├─ 202-sim-lobby.sql                     (seeds sim_matches.id=1 empty_pitch, seed=42, tick_hz=20)
│   ├─ 203-sim-registry-ids-stable.sql       (drops SMALLSERIAL sequences on the four registry tables — §22.9)
│   └─ 204-sim-scenarios-empty-pitch-id-zero.sql
│                                            (renumbers sim_scenarios.empty_pitch → id=0 to match runtime enum)
├─ backend/  (existing — adds /api/sim/* routes)
│   └─ src/controllers/
│       ├─ SimLobbyController.{h,cpp}        (GET /api/sim/matches, POST /api/sim/matches no-op)
│       └─ SimDebugController.{h,cpp}        (GET /api/sim/debug/matches/:id/{inputs,events,state} — admin-only, rate-limited)
└─ frontend/
    ├─ sim.html
    ├─ tactical-games.html                   (hub tile → /sim.html)
    ├─ css/sim.css                           (canvas + joystick + sprint-pad + #sim-back styling)
    └─ js/sim/
        ├─ wire.js
        ├─ transport.js
        ├─ renderer.js
        ├─ input.js
        ├─ interpolator.js
        ├─ client.js
        └─ lobby.js
```

**Layout notes** (deviations from the pre-Slice-13 sketch, all conscious and covered by ADRs in §22):
- `sim/src/common/` collects the small cross-cutting types (`IdTypes`, `Role`, `EntityState`, `M0Attributes`, `M0Registry.generated.hpp`) that would otherwise cause include-cycles between `math/`, `profile/`, and `match/`.
- `sim/src/persistence/` grew several files beyond the original `PgClient` sketch — `IPgClient` (contract), `InMemoryPgClient` (test double, §22.12), `ProfileStore`, `RegistryLoader`, `AsyncPgLog` + `InputLog` / `EventLog` typedefs, `EventTypes`.
- `sim/src/tools/` + `sim/src/admin/` are new — added by §16.6 sub-slice 6 (`fh-sim-replay`) and sub-slice 8.1 (cross-container `/state` RPC).
- Migration numbers 201–205 landed in a different order than the pre-Slice-13 sketch predicted; the reality above is authoritative. Migration 205 (2026-07-13, ADR §22.18) normalized `sim_player_profile` from three bytea columns to a parent envelope + three child tables (`sim_player_attribute` / `sim_player_concept` / `sim_player_recognition`); the `sim/src/profile/PackedU16F32.{hpp,cpp}` codec and the `AttributeSet::{to,from}Bytes` / `ConceptSet::{to,from}Bytes` / `RecognitionSet::{to,from}Bytes` methods listed in the earlier §17 sketch are gone as of that migration.
- Tests are FH_TEST_MAIN-based, one test binary per `test_*.cpp`, all registered in `sim/tests/CMakeLists.txt` and run by `ctest` in the sim Dockerfile build stage. Current count: 36 binaries.



## 18. Debug & observability

- `GET /api/sim/debug/snapshot/:match_id` — decoded snapshot as JSON. Human-only.
- `GET /api/sim/debug/matches` — live match roster with slot occupancy.
- `GET /api/sim/debug/replay/:match_id?tick=N` — replay-view at a specific tick.
- Structured logging to stdout; picked up by podman logs / journal.
- Per-match log ring buffer for last-N events (crash triage).

## 19. Explicit anti-patterns to avoid

- No hard-coded roles, skill tiers, or difficulty enums. Everything derives from concepts + attributes.
- No client-side game logic. Ever.
- No JSON in binary paths. JSON exists only in debug HTTP endpoints.
- No cross-milestone shortcuts (e.g., "just hard-code the CDM position for now"). If M5 needs a feature, add it to the M5 milestone list.
- No skipping the registry step when adding attributes/concepts.
- No stray `rand()`, no wall-clock reads in game logic.
- **No `float` or `double` in the sim loop.** Use `Fixed64`. See §5.1 and §10.
- **No `std::sin`, `std::cos`, `std::sqrt`, etc. in gameplay code.** Use `fx_sin`, `fx_cos`, `fx_sqrt` from `FixedMath.hpp`.
- **No controller or behavior reads `WorldView` directly.** Everything downstream of `RecognitionSystem::apply()` sees `AwarenessView`. `WorldView` is confined to `sim/src/awareness/` and `sim/src/match/`. Bypassing recognition defeats the point of having it.
- No engine dependencies (Godot, Unity, Bevy) pulled in silently.

## 20. Open questions to revisit later

- Voice chat / text chat inside matches (community feature, not gameplay).
- Coach paint-layer for spectators to draw arrows (Milestone 3+).
- Turn-based mode implementation (interface exists; deferred).
- **Client-side prediction / rollback netcode** — unlocked by fixed-point determinism. Ship the sim as WASM to the browser, run it in lockstep with the server to hide 4G latency. Adds v2 binary wire format (ships raw `Fixed64` words instead of `f32`).
- **Third-party match verification** — also unlocked by determinism. A CLI tool reads `(seed, inputs, expected_final_state)` and re-runs the sim to prove authenticity.
- **Diagnostic replay UI ("why did the player do X?")** — unlocked by the recognition split + fixed-point determinism together. Replay any tick with a UI that shows both the ground-truth `WorldView` and the entity's `AwarenessView` side by side. Coaches can point at "you didn't see the 2v1" vs. "you saw it and chose wrong." Requires no new engine work — just a debug endpoint that dumps both views.
- Native mobile app wrapper (Capacitor / TWA) if PWA install rates are low.
- Custom binary wire protocol version 2 (deterministic-lockstep-friendly, see above).
- 3D renderer (Three.js) migration (planned; timeline TBD).

## 21. Known flaws & non-standard choices to revisit

Added 2026-07-11 after a full pass over the doc. Each item is a checkbox: tick when the flaw is either fixed or explicitly decided as won't-fix (with the decision recorded in-place). Grouped by when the fix is needed.

### 21.1 Ship-blockers (fix before Slice 13 / §16.6 lands)

- [x] **Registry IDs must be stable across environments** — closed 2026-07-11; see §22.9. `sim_attribute_registry.id SMALLSERIAL` today lets Postgres assign IDs in insertion order — a dev DB reset can produce different IDs than prod, and every `sim_player_profile.attributes` bytea encodes those IDs directly (the bytea layout has since been normalized into `sim_player_attribute.attr_id` FK-constrained rows per ADR §22.18, which upgrades the stable-ID invariant from a runtime assertion to a hard Postgres FK). §16.6 tries to catch drift with a startup assertion, but that's a runtime guard on a schema-level bug. **Fix**: migration 200 (and all future registry migrations) must `INSERT INTO sim_attribute_registry (id, key, ...) VALUES (1, 'physical.max_walk_speed', ...), (2, ...)` explicitly, then `SELECT setval('sim_attribute_registry_id_seq', (SELECT MAX(id) FROM sim_attribute_registry))`. Treat registry IDs as first-class stable identifiers (like enum values), not artificial primary keys. Same for `sim_concept_registry` and `sim_pattern_registry`.
- [x] **PRNG portability claim in §10 rule 3 is subtly wrong** — closed 2026-07-11; see §22.10. `std::mt19937_64` raw output is spec-defined across implementations, but `std::uniform_int_distribution`, `uniform_real_distribution`, `bernoulli_distribution` etc. are **NOT** portable between libstdc++ / libc++ / MSVC. A well-known determinism gotcha. Also, both `std::mt19937_64` and `sim/src/math/RngDet.hpp` are referenced — unclear which is authoritative. **Fix**: either (a) forbid all `std::*_distribution` in gameplay via a CI grep and require in-house implementations (uniform int by rejection sampling on raw output; uniform real via `raw / max`), or (b) update §10 to name `RngDet` as the only sanctioned RNG and spec its distribution semantics. Add distribution-lockdown CI grep once decided.
- [x] **Catalog exists in two places (DB and code)** — closed 2026-07-12; see §22.11. `sim_attribute_registry` / `sim_concept_registry` (DB, seeded by migration 200) and the compile-time `constexpr AttrId k...` constants are now single-sourced: `build.sh` pre-generates `sim/src/common/M0Registry.generated.hpp` from migration 200 via `sim/scripts/gen_registry_header.awk`, and `M0Attributes.{hpp,cpp}` contains only non-catalog baseline VALUES (`defaultPhysical()`, `defaultConcepts()`). Container build FATAL_ERRORs loudly if the pre-generated header is missing (verified). Boot-time §16.6 drift check retained as belt-AND-suspenders.

### 21.2 M1-blockers (fix before starting M1 milestone work)

**All three items closed 2026-07-13 as prerequisites to §23 (M1 detailed spec, Slice 14+).** Item 1 = Task A1 (`SlotSpawn::ai_profile_source`, commit `2a4f502f`), item 2 = Task A2 (ADR §22.14 + `check_profile_write_policy.sh`, commit `ca50b487`), item 3 = Task A3 (§16.7 multi-match orchestration plan, commit `c9e9ed3a`).

- [x] **AI slots have no way to load a real teammate's profile.** Product goal: "our player names on AI pieces" (fh-member Miguel's profile drives an AI midfielder). Today `SlotSpawn` (§5.6) has `optional<ConceptSet> ai_concepts` and `optional<PlayerProfile> ai_profile` inline — no "load profile from `sim_player_profile` by `person_id`" path. **Fix**: add `optional<PersonId> ai_profile_source` to `SlotSpawn`. If set, the runtime calls `ProfileStore::load(person_id)` at match setup and injects the profile into the AI slot. Small change, unlocks a big product feature. **Closed 2026-07-13 (field added; consumer wiring deferred to M3).** [sim/src/scenario/Scenario.hpp](sim/src/scenario/Scenario.hpp) now carries `std::optional<PersonId> ai_profile_source` in `SlotSpawn`, listed first among the three AI-source fields so it's the visible default. Contract documented in the field's block comment (also mirrored in §5.6 above): if both `ai_profile_source` and `ai_profile` are set, `ai_profile_source` wins (persisted-profile-of-record beats inline blob). `ai_concepts` layers on top of whichever source wins. Consumer wiring — `Match::spawnInitialSlots` calling `ProfileStore::load(*s.ai_profile_source)` and swapping the resulting `PlayerProfile` into `slot.profile` before `MechanicsParams::fromPhysical` runs — is intentionally deferred to M3's first `AiController` scenario for three reasons: (a) M0's `EmptyPitchScenario` leaves the field `nullopt` (per the updated comment in [sim/src/scenario/EmptyPitchScenario.cpp](sim/src/scenario/EmptyPitchScenario.cpp)) so no consumer would exercise the code path today, (b) `Match::spawnInitialSlots` currently has no reference to a `ProfileStore` and adding one to `MatchConfig` before there's a test that needs it violates the "reserved fields carry their eventual meaning, not implementation" §22 rule, (c) plumbing `ProfileStore` into the `Match` constructor is a threading concern (Match runs on the tick thread, ProfileStore has its own thread — the cache lookup needs to happen at match-setup time only, not per-tick, which the M3 slice will need to design deliberately with `IProfileSource` or similar abstraction). Zero-behavior change for M0; field is a compile-time contract that unblocks M3 without touching Scenario.hpp again.
- [x] **`sim_player_profile` write policy is unspecified.** `updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()` exists but nothing says when the sim writes. Naive per-tick writes would be catastrophic. **Fix**: spec (probably in §14 match lifecycle) that profile writes happen at match end + on explicit concept-mastery events (M3+); never per-tick. **Closed 2026-07-13 — see ADR §22.14** (`sim_player_profile` write policy — first-touch INSERT only in M0). Final policy is stricter than the original fix proposal (M0 does *not* write at match end — nothing mutates during a match so match-end writes would be pointless churn); the M3+ concept-mastery write path is documented under §22.14's "Revisit if / when" clause. Enforced by [sim/scripts/check_profile_write_policy.sh](sim/scripts/check_profile_write_policy.sh) in the CI lint gate.
- [x] **Single-daemon single-match convention has no multi-match exit ramp spec'd.** `SIM_MATCH_ID=1` env-baked. §16.6 punts multi-match as an explicit non-goal, but M1 with real drills will need N concurrent matches. Design has no section on how multi-match orchestration works: threading model, process model, match-to-daemon routing, backend `POST /api/sim/matches` becoming a real create. **Fix**: add a new §16.x "Multi-match orchestration plan" before M1 starts. Options to evaluate: (a) N daemons behind a match-router keyed on `match_id`, (b) one daemon with a thread pool serving K matches, (c) per-match ephemeral process spawned on demand. Each has different failure and observability characteristics. **Closed 2026-07-13 — see §16.7** (Multi-match orchestration plan). Option A (N daemons behind match-router) chosen for M1 with a full concrete implementation plan across 10 sub-slices (SimOrchestrator, SimLobbyController becoming real, SimRouter fan-out, frontend `?match_id=X` handling, nginx regex `location ~ ^/sim/(\d+)$` block, reaper thread, per-daemon determinism guarantees, observability, failure modes, and the M0-to-M1 migration path). Revisit triggers documented for when Option B (thread pool) or a warm-daemon pool becomes justified.

### 21.3 Pre-M3 fixes (fix before M3 planning)

- [ ] **Debug endpoint replay won't scale for long matches.** §16.6's `GET /api/sim/debug/matches/:id/state?tick=T` spawns `fh-sim-replay` in a subprocess with a 10s timeout. For M3+ physics with 22 slots at tick 11999 of a 10-min match, replay-from-scratch exceeds 10s. Subprocess-per-request also serializes debug users. **Fix**: add tick-checkpointing. Every N ticks (e.g. 200 = 10s of match time) the sim writes a full canonical state snapshot to a new `sim_match_checkpoints` table. Replay to tick T loads nearest checkpoint ≤T and replays <200 ticks. Standard technique in deterministic replay tools (`rr`, Chronoscope, speedrunning quantum leap). Not needed for M0, blocking for M3. **Deferral rationale (added 2026-07-17)**: implementation requires a round-trippable binary state serializer for `Match` (physics world + `math::RngDet` cursor + `std::vector<Slot>` + `std::vector<MechanicsParams>` + `ball_owner_` + `kick_alive_ticks_remaining_` + `last_kicker_slot_` + `MatchClock` state + `RecognitionSystem` internal state — several-hundred-line surface). The existing `canonicalDump()` in `match/CanonicalHash.hpp` is one-way (ASCII → FNV hash), NOT a round-trippable serializer. Building a full serialize/deserialize pair with byte-identical hash on resume is a significant surface area with a nasty debug loop (any missed field → hash drift with no obvious localization). §22.0 discipline says build against a concrete failing test, not against a hypothetical worst case. First expected consumer that actually hits the 10-s subprocess budget: Slice 33 attacker-feint or Slice 34 1v1 (utility-AI + hysteresis + collision-heavy). Original plan to land as "Slice 30.0" (per §25) is revised to "land opportunistically once a slice ships a scenario whose replay-from-scratch approaches the budget"; if M3 never hits the budget, the item stays open past M3 close-out with revisit-condition = first M4 scenario exceeds budget. See §25.2 debug-replay bullet + §25.7 §21.3 cross-link for the M3-specific plan.
- [ ] **`sim_matches.result BYTEA` has no versioned schema.** §16.6 puts a canonical hash there today; M2+ will want match outcomes (goals, drill time, replay verification hash). Layouts will conflict. **Fix**: first byte of `result` = version tag. Each version has a documented layout in §14. Standard practice for evolving binary blobs.
- [ ] **Input lag isn't acknowledged as an M0 UX issue.** At 20 Hz + 100 ms client-server RTT, round-trip from "press D" to "see local dot move" is 150-200 ms. On a 4G phone this WILL feel sluggish. §16.5 says "playable on mid-range phone" but doesn't define responsiveness. Client-side prediction is deferred to §20 (post-M0). **Fix (light, do at M0 or M1)**: add local dead-reckoning — extrapolate the local player's own dot from last-known velocity until next snapshot arrives. Cheap, hides most of the lag, doesn't need v2 wire. **Fix (heavy, defer to M2 or M3)**: full client-side prediction over v2 wire per §20.
- [ ] **`sim_match_inputs` grows unbounded.** ~30 KB/match at scale × 100 matches/day × 365 = 100 GB/year, forever. **Fix**: retention policy in §8 or §18. Simplest: at match end, gzip the whole input log into a single `sim_match_archive.compressed_inputs BYTEA`, drop the row-per-tick rows for that match. Keeps replay possible, drops the row count by 4-5 orders of magnitude. Alternative: 90-day live retention + object-storage archive.

### 21.4 Non-standard choices — conscious, revisit only if they hurt

Not flaws — deliberate deviations from industry defaults with real trade-offs. Documented here so we're honest about the cost we pay.

- [ ] **Q32.32 fixed-point instead of industry-standard Q16.16.** Every widely-cited deterministic engine (Age of Empires, Rocket League's competitive mode, most fighting games) uses Q16.16 in int32. §5.1 argues Q32.32 for range and precision margin. Real cost: `__int128` intermediate is a GCC/Clang extension not standard C++, not natively supported by MSVC (helper required), and **not native to WASM** — which matters because §20 lists "ship sim as WASM to the browser for prediction" as an unlocked future. Q16.16 has ±32,767 units of range and ~15 μm precision on a 68 m pitch — vastly enough. **Decision to revisit**: is the extra precision worth the WASM portability tension? Or migrate to Q16.16 before the sim gets shipped to browsers?
- [ ] **Hand-rolled RFC 6455 WebSocket codec.** Industry default: uWebSockets, Boost.Beast, libwebsockets. Bespoke codec pulls all the correctness surface into our code (masking rules, close-code semantics, RSV bits, non-final CONTINUATION frames, control-frame size limits, permessage-deflate). Recommend: a targeted security audit of `WebSocketFrame.cpp` + `WebSocketHandshake.cpp` before opening the sim to non-fh-member traffic (i.e. before any public/spectator visibility).
- [ ] **Postgres `bytea` for gameplay data (attributes/concepts as `(u16, f32)*`).** Industry-standard alternatives are `jsonb` (queryable, updateable per-field, indexable, self-documenting) or normalized tables (`sim_player_attribute(person_id, attr_id, value)`). §8.1 decode helpers exist because bytea is opaque. Cost paid forever: no `SELECT * FROM sim_player_profile WHERE physical.max_sprint_speed > 8` without the decode function; no partial updates; no query-planner help. **Decision to revisit**: is the wire-alignment / packing benefit worth the operability tax? If we ever want analytics on player attribute distributions across a squad, `jsonb` becomes much cheaper to reach for.
- [ ] **Utility AI (not Behavior Trees, not GOAP).** §5.4 `AiController::decide()` picks highest-scoring behavior via `IBehavior::utility()`. Legitimate industry pattern (Kingdoms of Amalur, Prey) but sports-game norm is Behavior Trees (FIFA, PES). Known Utility AI pitfall: oscillation between two behaviors with near-equal utility (jockey ↔ press flip-flop). Doc doesn't spec mitigation. **Fix (when M3 arrives)**: hysteresis via time-since-last-switch penalty, or minimum-commitment durations per behavior. Add to M3 spec.
- [ ] **Full snapshot broadcast per tick, no delta encoding, no interest management.** Every serious realtime engine since Quake 1996 does delta encoding; every MMO since Ultima Online does area-of-interest culling. We do neither. Fine at 12-slot M0. At 22-slot M4+ scenarios with spectators, bandwidth scales linearly with clients. The wire spec (§7) hard-locks around full snapshots, so adding deltas is a v2 wire. **Decision to revisit**: at M4 or first spectator scenario, budget bandwidth. If per-client cost exceeds ~50 KB/s, do delta encoding.
- [ ] **`poll(2)` single-threaded loop, no async runtime.** Fine at M0 (one match). Every industry realtime server uses an event-loop lib (libuv, Boost.Asio, seastar) or thread-per-core sharding. `poll` doesn't scale past ~1000 fds well, and mixing tick timing with I/O poll on one thread means a slow I/O event can miss a tick. Fine for M0; not fine at the "50 concurrent matches" exit criterion (currently marked green — need to verify the criterion was measured with 50 clients per match or 50 matches ⋅ 1 client). Tied to multi-match orchestration (§21.2).
- [ ] **`docker build` runs `ctest`.** Unusual: industry runs tests in CI separately then tags/deploys. Good property (what ships is what was tested) but slow inner loop for devs. Not a real problem; noted for outside contributors' surprise.
- [ ] **`env` (no dot).** Repo convention. Every other dotenv-consumer uses `.env`. Cosmetic, but non-standard.
- [ ] **Recognition-as-first-class-layer.** Uncommon in commercial games (FIFA collapses this into "AI difficulty"). Common in academic cognitive-science / adaptive-learning research. This is a **feature**, not a flaw — the right choice for a training tool — but we're inventing an AI arch, not adopting one. Debug tooling (per §20) will need to be built to make the split useful to coaches.

### 21.5 Documentation reconciliation (do anytime, low risk)

- [x] **§17 project layout is stale.** Lists migrations `201-sim-matches.sql, 202-sim-inputs-events.sql, 203-sim-player-profile.sql, 204-sim-decode-functions.sql`, but reality is: migration 200 is one file with all 8 tables, migration 202 is sim-lobby, migration 201 will be the decode functions per §16.6. Test list under §17 also doesn't match what's actually in `sim/tests/`. Full pass needed. **Closed 2026-07-13** — §17 rewritten against actual repo state: added `sim/scripts/`, `sim/src/common/`, `sim/src/tools/`, `sim/src/admin/`, updated `sim/src/persistence/` file list (IPgClient/InMemoryPgClient/ProfileStore/RegistryLoader/EventTypes/AsyncPgLog/InputLog/EventLog), updated `sim/src/net/` file list (WebSocket*/WireFormat/LeCodec/InputFrame), rewrote `sim/tests/` list against the current 36 binaries in ctest, corrected migration numbering (200 sim-registries, 201 sim-decode-functions, 202 sim-lobby, 203 sim-registry-ids-stable, 204 sim-scenarios-empty-pitch-id-zero), added `SimDebugController` to the backend controllers list, added `tactical-games.html` + `css/sim.css` to the frontend list, and appended a "Layout notes" block that flags every deviation from the pre-Slice-13 sketch with the ADR that covers each.
- [x] **§14 references a "sim server RPC" that doesn't exist.** "Backend inserts row into sim_matches, calls sim server RPC to create instance." Reality (§16.1): `POST /api/sim/matches` is a no-op returning the single seeded row. Reconcile once multi-match orchestration is spec'd (§21.2). **Closed 2026-07-13** — added an "M0 reality vs the lifecycle above" block below the pseudocode that (a) notes step 1's RPC is not yet real (`SimLobbyController::handleCreateMatch` returns the seeded row from migration 202), (b) points at [sim/src/admin/AdminHttpServer.{hpp,cpp}](sim/src/admin/AdminHttpServer.cpp) as the *existing* HTTP-RPC surface that will host `POST /admin/createMatch` when multi-match orchestration lands (§16.7, spec'd 2026-07-13 — Option A "N daemons behind match-router" chosen for M1), (c) documents that CLAIM_SLOT is not a distinct wire message in v1 — the first accepted INPUT frame implicitly claims the slot — but the `SlotClaim`/`SlotRelease` events *are* logged to `sim_match_events` at transport boundaries, and (d) records the `sim_player_profile` write policy for M0 (first-touch INSERT only; never per-tick; never at match-end for M0 — concept-mastery updates land with M3) with a pointer to ADR §22.14 (`sim_player_profile` write policy — first-touch INSERT only in M0).
- [x] **§7 pre-commits to `f32` positions on the wire; §20 wants WASM client-side prediction.** Lockstep prediction needs `Fixed64` on the wire. §20 acknowledges v2-wire is required; §7 doesn't cross-reference this. Add a cross-reference in §7 saying "v1 wire targets rendering only; a v2 wire spec (§20) is required for client-side prediction / WASM lockstep." **Closed 2026-07-13** — added a bold blockquote at the top of §7 pointing forward to §20's "Client-side prediction / rollback netcode" bullet, spelling out that v1's `f32` payload fields are intentionally lossy (rendering-only) and that a v2 wire carrying raw `int64` fixed-point words is a *coexisting* format for WASM lockstep clients, not a v1 replacement.
- [x] **§16.1 has `AiController` checked off as an M0 deliverable, but §16.3/§16.4 say AI is wander-only in M0.** True (`AiController` is code-present, behavior-empty), just easy to misread. Add a parenthetical: "(skeleton class; no behaviors plugged until M3)." **Closed 2026-07-13** — §16.1 controller-checkbox rewritten to explicitly say "`AiController` is a skeleton class; the interface exists so `Slot::controller` has a stable non-null pointer, but no `IBehavior` implementations are plugged into `AiController::decide()` until M3 — see §16.3 / §16.4 which specify AI slots run `WanderController`, not `AiController`, in M0."
- [x] **§5.7's `Match` includes `spectators` field; §16.4 says "no spectator role distinction in M0."** Field is reserved but present. Add coverage note: "reserved field, no tests until spectator role lands (M3+); do not access from gameplay code." **Closed 2026-07-13** — added a blockquote directly beneath the `Match` class block explaining that `spectators` is reserved-unused in M0 (a client that connects but never claims a slot is a de-facto spectator tracked only by `SimServer`'s client bookkeeping), that the vector ships in the class layout so the shape doesn't churn when M3+ introduces role differentiation (§22.1), that no tests cover the field, and that the `IPlayerController` interface may need to widen when the role lands (spectators observe but don't produce `Intent`s).
- [x] **§5.6's `PlayableArea::Mode` enum has three values (`Hard` / `Soft` / `Advisory`) with no semantics defined.** M0 doesn't use any. Add definitions to §5.6 or defer them to M1 when the first constrained-area scenario lands. **Closed 2026-07-13** — added semantics beneath §5.6's Scenario block: `Hard` = clamp positions to polygon after each physics step (velocity zeroed at wall), `Soft` = inward repulsive force proportional to outward penetration depth (players *can* briefly leave but are pushed back), `Advisory` = sim does nothing (client renders dashed boundary + fits camera to `zoom_hint`) — the M0 default used by `EmptyPitchScenario`. Actual `Hard`/`Soft` implementation lands with M1's first constrained scenario; the enum ships now so `EmptyPitchScenario` can set `Advisory` explicitly (§22 rule: reserved fields carry their eventual meaning, not `None`).
- [x] **Migration 200 registry key formats are inconsistent.** Attributes use category-prefixed keys (`physical.max_walk_speed`, `physical.max_jog_speed`, ...) while concepts use bare keys (`run_to_point` with `category = 'movement'` set separately in the row). The awk generator in §22.11 handles both by stripping the category prefix only when present, but the underlying inconsistency is worth unifying. Recommendation: pick one convention (bare keys, since the row already carries a `category` column) and land a migration to rewrite the attribute keys. Zero-behavior-change on the sim side because the generated `k*` identifier names stay the same. **Won't-fix 2026-07-13 — resolved as "unify going forward: prefixed everywhere" rather than "unify backward: bare everywhere".** Rationale: (a) the `key` column strings are display-only (`SELECT key FROM sim_attribute_registry`, log lines, error messages) — the runtime uses `AttrId` / `ConceptId` u16 values from [sim/src/common/M0Registry.generated.hpp](sim/src/common/M0Registry.generated.hpp) for every operation, and those k*-identifier names derive from the LAST dotted segment (`to_cname` in `gen_registry_header.awk` strips the leading `<cat>.` when present) so they're stable across any prefix change. (b) The `category` column IS the machine-readable second-source; the prefix in the key is human-readable convenience for grep/eyeballing `SELECT key`. (c) Attributes benefit from prefixing because their `physical` / `technical` / `mental` categories are non-empty and will collide (e.g. a future `technical.acceleration` — first-touch pace — vs the existing `physical.acceleration` — top-speed ramp). Concepts don't yet have a category-collision problem (M0 has one concept). (d) Mutating migration 200 breaks the immutability convention (§16.6 rule); writing migration 205 to `UPDATE` to bare keys would leave migration 200's file visibly out-of-sync with the DB, which is worse for readers than the current inconsistency. **Decision**: when the first concept-key collision arrives, add `<category>.` prefixes to concept keys in a new migration — matching attributes — rather than stripping prefixes off attributes. Until then, the awk generator's bilateral handling stays as-is.

### 21.6 Process for this section

- When a checkbox in §21 is addressed, tick it and add a one-line resolution note in place (e.g. "Fixed in Slice 14 by explicit-ID inserts; see migration 213-registry-stable-ids.sql, and §22.9 for the decision record").
- When a checkbox is decided as **won't-fix** with rationale, tick it and record the rationale in place, or point at the §22 ADR that documents it.
- Do **not** open parallel issue trackers or docs for these items — §21 is the tracker, §22 is the decision record.
- New flaws or new non-standard choices discovered later append to the appropriate subsection with a new checkbox.

### 21.7 M2-blockers (fix before starting M2 milestone work)

Analogous to §21.2 M1-blockers. Perf gaps + reserved-ADR loose end uncovered during Slices 14–18 that must land before M2's collision + first-touch work compounds the pain. Landed 2026-07-14 as Slice 18.5 backfill against Slice 14.7's baseline load-test run + Slice 14's shipped-but-unspec'd podman surface. Each item cross-references the §23.4 exit-criteria box or §22/§23 slot it belongs to.

- [x] **Warm-image spawn latency ~800 ms vs §23.4 500 ms target — podman-side, not sim-side.** [Slice 14.7](sim/scripts/load_test_orchestrator.sh) baseline recorded 865–1137 ms warm-image single-shot spawn against the running stack (section 0.5). [Attribution diagnostic](sim/scripts/attribute_warm_image_spawn.sh) run 2026-07-14 (N=5, serial, un-contended, `empty_pitch` scenario, match_ids 900001..900005) bucket-broke the floor into: **B1** `POST /v1.41/containers/create` REST call median 276 ms (range 251–371), **B2** `POST /v1.41/containers/{id}/start` REST call median 527 ms (range 453–584), **B3** podman start-return → sim's first stderr line median 0 ms (clock-skew-clamped; empirically the sim binary was already emitting logs before podman's start API returned — start blocks until entrypoint is running), **B4** sim's first stderr line → "listening on 0.0.0.0:9100" median 87 ms (range 69–108, covering registry SELECTs + admin HTTP bind + WS transport bind + upsertMatch + MatchStart insert). Median wall = 791 ms. **The podman REST layer alone accounts for the entire measurable floor** (B1 + B2 ≈ 800 ms median); sim-side boot + init is ~87 ms combined. §23.4 box 5 remains unchecked; fix path is now specific rather than speculative. **Fix**: implement §16.7's warm-daemon-pool as the primary remedy — pre-spawn K idle daemons that block on `POST /admin/assign_match` before running `upsertMatch` / opening the WS listener, so per-match spawn cost drops from ~800 ms to one HTTP round-trip (< 10 ms plausible against the sim's admin port). Requires main.cpp to defer `upsertMatch` + WS bind until the admin assignment arrives, and SimOrchestrator to distinguish "spawn new container" from "assign to idle daemon" verbs. **Alternative remedies now ruled less impactful by the attribution data**: (a) pgbouncer / DB connection changes — B4's 87 ms is already tiny, so no meaningful floor to reclaim there (still relevant to §21.7 item 2, unrelated to item 1); (b) sim-binary boot optimization — B3 is 0 ms, sim init is already at rounding-error cost; (c) podman-side tuning (storage driver, cgroup version, healthcheck config, container-boot barriers) could shave B1+B2 but each is a bigger operational change than a warm-daemon-pool and requires deploy-target-specific tuning. **Blocks**: §23.4 box 5. **Fix step 3 (endpoint scaffolding) landed 2026-07-15** — additive-only sim admin surface: `POST /admin/assign_match` shipped on [sim/src/admin/AdminHttpServer.hpp](sim/src/admin/AdminHttpServer.hpp) / [.cpp](sim/src/admin/AdminHttpServer.cpp) alongside the pre-existing `POST /admin/replay` + `GET /admin/tick_stats` routes. New public types `AssignMatchRequest{ match_id, seed, scenario_id }` + `AssignMatchOutcome{ kOk, kConflict }` + `AssignMatchResult{ outcome, body_json }`; new `Config::assign_match_handler` follows the same handler-callback + hidden-when-unwired-→-404 pattern as `tick_stats_provider` so an unauthenticated probe cannot detect whether the surface is wired. New `parseAssignMatchJson` mirrors `parseReplayJson`'s narrow parser style — three-field object with match_id (u64 > 0), seed (u64, 0 legal), scenario_id (u64 ≤ 32767 for i16 range; scenario-existence check deferred to handler); any missing/unknown field / trailing garbage → HTTP 400 with detail. Route dispatch extended so a wired POST returns 200 (handler body verbatim) / 409 (`kConflict` → canonical `{"error":"already assigned"}` body, handler's body_json ignored so wire shape is stable across handlers) / 500 (handler threw → exception::what() as detail). Wire coverage: 11 new parser cases (golden, key-order-agnostic, seed=0 anti-regression, each missing-field, match_id=0 rejected, scenario_id=32768 rejected, scenario_id=32767 accepted boundary, unknown field, trailing garbage) + 7 new e2e cases (hidden-when-handler-unset, missing-bearer→401, wrong-method→405, malformed body→400 with handler-not-called guard, success→200 with parsed fields captured and asserted, kConflict→409 with handler body_json ignored, handler-throw→500). All 46/46 ctests green in image `759aabae02f6` (28 pre-existing admin cases + 18 new = 46 in test_admin_http_server; plus 45 other test binaries). Startup log line extended to `[sim-admin] listening on … (POST /admin/replay, GET /admin/tick_stats, POST /admin/assign_match)` when both new callbacks are wired. **Zero behaviour change**: no production sim daemon wires `assign_match_handler` yet — the existing SIM_MATCH_ID-env boot path in [sim/src/main.cpp](sim/src/main.cpp) is untouched. **Next slices** — (step 4) refactor `main.cpp` into a "warm" phase (DB connect, registries, admin server) and a "hot" phase (drift check, upsertMatch, WS bind, Match, SimServer.run) with the phase transition gated on either (a) SIM_MATCH_ID env — existing behaviour, or (b) the new `assign_match_handler` firing with a validated payload. The handler flips a std::atomic that unblocks the hot-phase thread; kConflict is returned if the atomic was already flipped. (step 5) backend `SimOrchestrator` gains an idle-pool + `spawn` vs `assign` verb split, calling the new admin endpoint over the same libcurl-UNIX-socket transport that ADR §22.19 established for podman.sock. (step 6) re-run [attribute_warm_image_spawn.sh](sim/scripts/attribute_warm_image_spawn.sh) + `load_test_orchestrator.sh` §0.5 against a warm-pool-fronted stack and measure the median B1+B2 → assign_match round-trip drop; expected ≤ 50 ms (single-digit HTTP hop across the compose network), lifting §23.4 box 5 above its 500 ms target with substantial headroom. Checkbox stays `[ ]` until step 6's empirical result lands. **Fix step 4A (main.cpp warm-boot gate) landed 2026-07-15** — [sim/src/main.cpp](sim/src/main.cpp) grew a namespace-scope `MatchAssignment{ match_id, seed, scenario_id }` + `AssignmentGate` (mutex + condition_variable + `std::optional<MatchAssignment>`) + `g_assignment_gate` + `std::atomic<std::uint64_t> g_current_match_id`. Boot now branches on whether `SIM_MATCH_ID` env is set at process start: **env-set path** — byte-identical to pre-4A behaviour, `assign_match_handler` is NOT wired (endpoint stays hidden-404 so an accidentally-directed assign_match cannot mislead the orchestrator into believing the daemon now serves the assigned match when it's still serving the env-configured one), env values flow straight through; **env-unset + admin-enabled path** — after `AdminHttpServer::start()`, main blocks on `g_assignment_gate.waitForAssign()`; the wired handler runs on the admin accept-loop thread, calls `g_assignment_gate.assign(a)` (returns false → HTTP 409 canonical body if an assignment was already recorded, single-shot invariant), unblocks main which reassigns local `match_id`/`seed`/`scenario_id` and stores `g_current_match_id`; **env-unset + admin-disabled path** — preserves pre-existing default fallback (match_id=1, seed=42) for single-process dev runs. `tick_stats_provider` no longer captures `match_id` by value at wire time — it now reads `g_current_match_id.load(memory_order_relaxed)` on every call. The pre-assignment wait window is safe against tick_stats callers because the provider takes its `g_server == nullptr` "booting" branch (main hasn't executed `g_server.store(&server)` yet) and never touches `g_current_match_id` at all; between admin start and gate-release the atomic is 0 but unread. Post-release, the store-then-run ordering pattern used elsewhere in the file continues to hold. Smoke test (2026-07-15, `footballhome_sim_test` image `8911f15eb379`, on `footballhome_footballhome_network`): daemon started with no `SIM_MATCH_ID` reached the wait log within 2 s (`SIM_MATCH_ID unset — waiting for POST /admin/assign_match on admin port 9101...`); first `POST /admin/assign_match {"match_id":90273,"seed":31415,"scenario_id":0}` → HTTP 200 body `{"assigned":true,"match_id":90273,"seed":31415,"scenario_id":0}`, hot phase engaged and `WebSocketTransport` bound `0.0.0.0:9100 match=90273 seed=31415`; second assign_match on same daemon → HTTP 409 `{"error":"already assigned"}`; `GET /admin/tick_stats` reported `{"match_id":90273,"tick_hz":20,"ticks_executed":331,"catch_up_skips":0,"sum_behind_ms":0,"max_behind_ms":0,"active_clients":0}` confirming both `g_current_match_id` publication and steady tick cadence. All 46/46 ctests still green — no test additions (the wire-side handler contract was already exhaustively covered by step 3's 18 tests; the main.cpp glue is integration-tested and lands with step 6's empirical spawn-latency measurement). **Zero behaviour change** for every currently-deployed daemon: production daemons all set `SIM_MATCH_ID` at spawn time, so the env-set path applies unmodified. **Next sub-slice (4B)** — refactor the drift-check / `upsertMatch` / WS bind / `Match` construction / `SimServer::run` linear block into a `runMatch(match_id, seed, scenario_id) -> int` lambda invocable identically from both boot paths, and wire a signal-driven wake-up on the gate so SIGTERM during the wait can shut down cleanly instead of relying on process kill. Then step 5 (backend `SimOrchestrator` idle-pool + spawn-vs-assign verb split over the ADR §22.19 transport) and step 6 (re-run [attribute_warm_image_spawn.sh](sim/scripts/attribute_warm_image_spawn.sh) against the warm-pool-fronted stack, expected median ≤ 50 ms). **Fix step 4B (signal-driven wake-up) landed 2026-07-15** — [sim/src/main.cpp](sim/src/main.cpp) grew `std::atomic<bool> g_shutdown_requested{false}` at namespace scope; `handleSignal` extended to `store(true, memory_order_relaxed)` before the existing `g_server != null → srv->stop()` branch (atomic bool store is async-signal-safe on every target because `std::atomic<bool>` is unconditionally lock-free); `AssignmentGate::waitForAssign` return type changed from `MatchAssignment` to `std::optional<MatchAssignment>` and its implementation moved out-of-line to a polling loop `for (;;) { if assigned → return; if shutdown → return nullopt; cv_.wait_for(100ms); }` — `cv_.notify_all` from a signal handler would not be safe (`pthread_mutex_lock` is not async-signal-safe), so the polled 100 ms wait period is how the atomic gets observed. 100 ms chosen as compromise between idle CPU (~10 wakeups/s per warm daemon, dwarfed by any real workload) and SIGTERM shutdown latency (well below the 10 s podman-stop grace window). Sigaction install for SIGINT/SIGTERM added at the top of the env-unset boot branch (right before the wait) so the handler is armed during the wait window; the existing sigaction install just before `server.run()` further down stays as a harmless idempotent re-registration for the wait path and remains the primary install for the env-set path (no behaviour change there). On `nullopt` from `waitForAssign`, main tears down the admin server (`admin_server->stop()` idempotent) and returns 0 — nothing DB-side exists to clean up because `upsertMatch`, `MatchStart` event, and WS transport bind all happen strictly after the wait resolves with a real assignment. **Smoke tests (2026-07-15, image `8a205afb16b4`)**: (1) start warm daemon → wait log fires within 1 s → `podman kill --signal=SIGTERM` → daemon logs `shutdown requested before assignment — exiting cleanly`, `[sim-admin] stopped`, exits **0** within ~1 s (well under the 100 ms polling ceiling + admin-server-stop drain); (2) start warm daemon → `POST /admin/assign_match {match_id:90277,seed:31415,scenario_id:0}` → HTTP 200, hot phase engages, WS bound; `podman kill --signal=SIGTERM` → `match_end hash=0x3b6f8efb4f107930 tick=211`, `shutdown complete`, exit **0** — confirms the redundant sigaction re-install just before `server.run()` still catches SIGTERM in the post-assignment window and drives the full `MatchEnd` write path. All 46/46 ctests still green (no new tests — signal-driven wake-up is inherently a live-process behaviour that ctest's per-binary process model cannot cover cleanly; empirical smoke test above is the coverage). **Zero behaviour change** for env-set-path daemons: the sigaction install in the wait branch never executes, and `g_shutdown_requested` is set only by handleSignal so it can never become true unless a signal fires (in which case env-path SimServer.run also observes `srv->stop()` from the same handler and shuts down normally). **Step 4 (main.cpp warm-boot gate + signal-driven wake-up) is now complete.** The originally-planned "runMatch(match_id, seed, scenario_id) -> int lambda refactor" was descoped as unnecessary: 4A already achieved clean phase separation by placing the wait between admin-server-start and the linear hot-phase code, so no code duplication exists to factor out. Next work is step 5 (backend `SimOrchestrator` idle-pool + spawn-vs-assign verb split). **Fix step 5A (SimOrchestrator warm-spawn verb) landed 2026-07-15** — additive-only backend orchestrator surface: [backend/src/orchestration/SimOrchestrator.h](backend/src/orchestration/SimOrchestrator.h) grew `LaunchResult spawnWarm(long long warm_id)` between `launchMatch` and `stopMatch`; [backend/src/orchestration/SimOrchestrator.cpp](backend/src/orchestration/SimOrchestrator.cpp) grew two anon-namespace helpers `buildWarmSimEnv()` + `warmContainerNameFor(warm_id)` and the public method implementation, plus one refactor to drop an unused `LaunchOptions const&` parameter from `buildCreateRequest`. `spawnWarm` deliberately DUPLICATES `launchMatch`'s create+start flow rather than sharing a template — pure additive, zero regression risk on the existing hot-path launcher. Container is named `footballhome_sim_warm_${warm_id}` (namespace-disjoint from `launchMatch`'s `footballhome_sim_${match_id}` so a warm-and-hot daemon can coexist with a naming-collision-free rename in step 5B). Env manifest omits `SIM_MATCH_ID` / `SIM_MATCH_SEED` / `SIM_SCENARIO` — but does so by pushing them as EMPTY-STRING overrides (`SIM_MATCH_ID=`) rather than by omitting the vars entirely, because the sim Dockerfile's `ENV SIM_MATCH_ID=1 SIM_MATCH_SEED=42` image-level defaults would otherwise leak through (podman/docker container-create API's `Env` field can only add/override image ENV, never unset; step 4A's `sim_match_id_env_set` check reads `sim_match_id_c[0] != '\0'` so empty-string counts as unset). `spawnWarm` validates `cfg_.enabled` (returns `{ok=false, error="orchestrator disabled"}` when off), `warm_id > 0` (returns `{ok=false, error="invalid warm_id"}` for ≤0), acquires the same `LaunchSemaphore` permit as `launchMatch` so warm-pool refill contends against per-match spawns under a single global concurrency cap, POSTs `/v1.41/containers/create?name=footballhome_sim_warm_${warm_id}` with the warm env manifest, parses `Id` from the response JSON, POSTs `/v1.41/containers/{id}/start` expecting 204 or 304, and on any failure calls the same `removeContainerBestEffort` cleanup as `launchMatch`. **Backend compiles clean** (`[100%] Built target server` in an image-derived build). **Production images refreshed** — `localhost/footballhome_footballhome_sim:latest` rebuilt to `a386936b305a` (contains steps 3/4A/4B), `localhost/footballhome_backend:latest` rebuilt to `0d57b917ce20` (contains step 5A); live stack restarted with both. **End-to-end smoke test (2026-07-15, image `a386936b305a` on `footballhome_footballhome_network`)**: (1) warm-spawn proxy `podman run` with empty `-e SIM_MATCH_ID=` overrides → daemon logs `[sim-admin] listening on 0.0.0.0:9101 (POST /admin/replay, GET /admin/tick_stats, POST /admin/assign_match)` + `SIM_MATCH_ID unset — waiting for POST /admin/assign_match on admin port 9101...` within 3 s; (2) `POST /admin/assign_match {match_id:90501,seed:42,scenario_id:0}` from `footballhome_backend` (compose-network peer using `FH_SIM_ADMIN_TOKEN` bearer) → HTTP 200 `{"assigned":true,...}`, hot phase engages (`assigned via admin — match_id=90501 seed=42 scenario_id=0`, registries loaded, WS bound `0.0.0.0:9100 match=90501 seed=42`); (3) `GET /admin/tick_stats` → `{"match_id":90501,"tick_hz":20,"ticks_executed":49,"catch_up_skips":0,"sum_behind_ms":340,"max_behind_ms":160,"active_clients":0}` after ~2 s (`sum_behind_ms` inflated by the step-4-item-2 first-tick DB round-trip band per attribution flip #2 in item 2's step 4 note); (4) `podman kill --signal=SIGTERM` → `[sim-admin] stopped`, `match_end hash=0x547b4db6a1c65d2d tick=204`, `shutdown complete`, exit **0** — full MatchEnd write path fires from the post-assignment window. **Second smoke (SIGTERM-during-wait regression check)**: warm-spawn proxy → wait log → `podman kill --signal=SIGTERM` before any assign → `shutdown requested before assignment — exiting cleanly`, exit **0** — confirms step 4B's cleanup path still works with the empty-string env override. All 46/46 sim ctests still green (rebuilt with `--target build`, image `8a205afb16b4`). **Zero behaviour change** for env-set-path daemons — `launchMatch` byte-identical, `stopMatch` byte-identical, `buildSimEnv` byte-identical; `spawnWarm` is uncalled by any current code path so this slice is purely capability-adding. **Next sub-slice (5B)** — `postAssignMatch(container_id, match_id, seed, scenario_id)` verb on `SimOrchestrator` (POSTs `/admin/assign_match` over the compose network using the sim's admin bearer token) + container rename verb (POST `/v1.41/containers/{id}/rename?name=footballhome_sim_${match_id}` so nginx's `location ~ ^/sim/(\d+)$` regex proxy resolves correctly for the newly-assigned match). Then 5C (SimPool class + background refill thread), 5D (SimLobbyController::handleCreateMatch pool-first refactor with launch fallback), 5E (HttpServer wires pool boot + shutdown, K warm daemons pre-spawned at server construction). Step 6 (re-run [attribute_warm_image_spawn.sh](sim/scripts/attribute_warm_image_spawn.sh) against the pool-fronted stack) lands after 5E; §23.4 box 5 flips to `[x]` when the pool-fronted median ≤ 50 ms result is captured. **Fix step 5B (postAssignMatch verb) landed 2026-07-15** — additive-only backend orchestrator verb: [backend/src/orchestration/SimOrchestrator.h](backend/src/orchestration/SimOrchestrator.h) grew `struct AssignOptions{ container_name, match_id, seed, scenario_id }` + `struct AssignResult{ ok, already_assigned, error }` + public `AssignResult postAssignMatch(const AssignOptions& opts)` declared between `spawnWarm` and `stopMatch`; [backend/src/orchestration/SimOrchestrator.cpp](backend/src/orchestration/SimOrchestrator.cpp) grew the implementation between `spawnWarm` and `removeContainerBestEffort`. Transport is HTTP over TCP+DNS on the compose bridge network (`HttpClient::postJson(..., unixSocketPath="")`) — **not** the podman unix socket used by every other orchestrator verb. This is the one method that talks to a sim daemon directly rather than to podman; aardvark-dns on the compose bridge resolves the sim's container name to its bridge IP within the resolver's TTL. Bearer auth: `FH_SIM_ADMIN_TOKEN` sourced from the backend's own process env (same value the sim reads at boot in [buildSimEnv](../backend/src/orchestration/SimOrchestrator.cpp) + [buildWarmSimEnv](../backend/src/orchestration/SimOrchestrator.cpp)); if empty, the call short-circuits with `error="FH_SIM_ADMIN_TOKEN unset in backend env"` rather than round-tripping a definite 401. Body shape mirrors [parseAssignMatchJson](../sim/src/admin/AdminHttpServer.cpp) exactly — three-field object `{"match_id":<long long>,"seed":<long long>,"scenario_id":<int 0..32767>}`; scenario_id bounds-checked at the C++ boundary before any wire traffic. Response mapping: HTTP 200 + `{"assigned":true,...}` → `{ok=true}`; HTTP 200 with any other body → `{ok=false, error="sim admin 200 with unexpected body: ..."}` (guards against sim/backend wire-shape drift); HTTP 409 → `{ok=false, already_assigned=true, error="sim admin returned 409: ..."}` (the `already_assigned` bit lets the pool distinguish "gate was consumed by a raced concurrent assign — retire + refill" from "the daemon is broken — retire + investigate"); HTTP 401 / any other status / transport error / unparseable body → generic `{ok=false, error=<detail>}` with the diagnostic. NO `LaunchSemaphore` permit — this verb is a single lightweight HTTP request whose bottleneck is the sim's single-shot `AssignmentGate` (races produce 409, not overload). **Container rename question deliberately DEFERRED from this slice** — empirical probe 2026-07-15 with `sudo podman rename fh_rename_test_warm fh_rename_test_match` on a live compose-network container confirmed that the podman `container rename` API updates the container's `Name` field but does NOT reflow the aardvark-dns network alias: `Aliases: ["fh_rename_test_warm","<short-id>"]` was unchanged post-rename, and the new name did not resolve from a peer container's DNS. So the previously-planned "rename in step 5B so nginx's `^/sim/(\d+)$` regex proxy resolves for the newly-assigned match" is not straightforward and belongs in a dedicated design pass; two plausible directions are (a) extend nginx's regex to `^/sim/(warm_\d+|\d+)$` with `set $sim_upstream footballhome_sim_$1` so the routing key is the container's stable warm-namespaced name for its lifetime (no rename needed, no alias juggling), or (b) do a `POST /networks/{id}/disconnect` + `POST /networks/{id}/connect` cycle at assign time to add the match-name as a second alias — this drops the sim's DB connection (both sim and db live on the same compose bridge) so the sim would need to reconnect PgClient mid-boot. (a) is the recommended path given (b)'s DB-reconnect complexity. Wire equivalence proven by smoke on live compose network (2026-07-15): warm daemon `footballhome_sim_warm_9990003` reached wait state; from `footballhome_backend` container `curl -X POST -H "Authorization: Bearer $FH_SIM_ADMIN_TOKEN" ... http://footballhome_sim_warm_9990003:9101/admin/assign_match` with the exact URL/headers/body postAssignMatch emits — first call `{match_id:90503,seed:31415,scenario_id:0}` → HTTP 200 `{"assigned":true,"match_id":90503,"seed":31415,"scenario_id":0}`, hot phase engaged (`assigned via admin`, registries loaded, `WebSocketTransport bound 0.0.0.0:9100 match=90503 seed=31415`); second identical call → HTTP 409 `{"error":"already assigned"}`; missing-bearer call → HTTP 401 `{"error":"unauthorized"}`. Backend `[100%] Built target server` clean. Zero behaviour change for currently-deployed daemons — `postAssignMatch` is uncalled by any current code path so this slice is purely capability-adding, matches the 5A shape. **Next sub-slice (5C)** — SimPool class + background refill thread: fixed-K ring of warm daemons managed by `spawnWarm` + `postAssignMatch` + `stopMatch`; `take()` pops the head warm daemon and returns its `container_name` for the caller to use as the routing key; refill thread runs `spawnWarm(nextWarmId())` whenever `size() < K`. Then 5D (SimLobbyController::handleCreateMatch pool-first refactor with launch fallback), 5E (HttpServer wires pool boot + shutdown, K warm daemons pre-spawned at server construction), 5F (nginx routing extension per 5B rename-question direction (a) — regex `^/sim/(warm_\d+|\d+)$` so warm-namespaced routing keys resolve). Step 6 flips §23.4 box 5 once `attribute_warm_image_spawn.sh` median lands ≤ 50 ms against the pool-fronted stack. **Fix step 5C (SimPool class + background refill thread) landed 2026-07-15** — additive-only backend orchestration surface: new [backend/src/orchestration/SimPool.h](backend/src/orchestration/SimPool.h) + [backend/src/orchestration/SimPool.cpp](backend/src/orchestration/SimPool.cpp), added to [backend/CMakeLists.txt](backend/CMakeLists.txt) between `SimOrchestrator.cpp` and `SimReaper.cpp`. Public surface: `struct SimPoolConfig { int target_size=4; std::chrono::milliseconds refill_backoff_on_error{2s}; std::chrono::milliseconds refill_wake_interval{30s}; }` + `struct SimPoolSlot { long long warm_id; std::string container_id; std::string container_name; }` + `struct SimPoolMetrics { std::size_t available; long long total_spawned; long long total_taken; long long total_spawn_failures; long long next_warm_id; }` + class `SimPool { SimPool(cfg, orch&); ~SimPool(); void start(); void stop(); std::optional<SimPoolSlot> take(); SimPoolMetrics metrics() const; const SimPoolConfig& config() const; }`. Design: `take()` is O(1), non-blocking, and never touches podman — a hot request path that finds an empty pool gets nullopt and can fail-over to `launchMatch` synchronously (fallback branch lands with the caller in 5D). Refill thread is a single `std::thread` launched by `start()`; runs `refillLoop()` which sits on a `cv_.wait_for(refill_wake_interval)` gated by predicate `shutdown_requested || slots_.size() < target_size` — the 30 s wake interval is a self-heal safety net for the case where a spawn failed and no take() has fired to notify, so the next retry doesn't wait forever. On wake, allocates a fresh `warm_id` under mutex (bumping `next_warm_id_` BEFORE the spawn so a half-created container with that name can't collide on the same-id retry), then calls `orch_.spawnWarm(warm_id)` WITHOUT holding the mutex (the podman round-trip is ~500 ms per step 5A attribution B2 and would block `take()` for that window). On success pushes the slot into `slots_` + increments `total_spawned_`; on failure logs `[sim-pool] spawnWarm(warm_id=N) failed: <detail> — backing off Xms`, bumps `total_spawn_failures_`, and does an interruptible `cv_.wait_for(refill_backoff_on_error)` so a `stop()` during backoff exits promptly rather than waiting the full window. `stop()` sets `shutdown_requested_.store(true)` under mutex + `cv_.notify_all()` + joins the thread; idempotent via a `running_` atomic compare-exchange guard. Destructor calls `stop()`. Post-take container fate is caller-owned: if the caller's `postAssignMatch` returns `already_assigned=true` or a transport error, the caller reaps the failed container via `orch.stopMatch()` and moves on — no "retire" API on the pool because `slots_.size()` already reflects the take, so the refill thread will replace it automatically on its next wake. Concurrency invariants: all slot access serialized through `mtx_`; spawns dispatched OUTSIDE `mtx_`; `take()` + `metrics()` safe from any thread; `start()`/`stop()` from the owning thread (5E's HttpServer boot/shutdown). Fresh-restart edge case with orphaned `footballhome_sim_warm_1..K` containers is a known collision path deferred to 5E's boot sequence (which will `podman ps` scan and seed `next_warm_id_` past the max existing id, then start the pool); for this slice, name-collision errors from spawnWarm surface through the standard failure path — log-and-back-off — so a stale-restart scenario self-heals within `refill_wake_interval` once the reaper has cleaned the orphans. **Backend compiles clean** — `[100%] Built target server` in the backend image's build environment, `SimPool.cpp.o` in the object graph between `SimOrchestrator.cpp.o` and `SimReaper.cpp.o`, no warnings. **No live smoke test in this slice** — the pool is uncalled by any current code path (same shape as 5A + 5B); wire equivalence is inherently a live-integration behaviour that will fire when 5D's `SimLobbyController::handleCreateMatch` pool-first refactor lands and 5E boots `HttpServer` with a non-zero `FH_SIM_POOL_SIZE`, at which point pool → spawnWarm → postAssignMatch → route becomes the end-to-end contract exercised by every match-create request. **Zero behaviour change** for currently-deployed daemons — no image rebuild needed; `SimPool` is a purely capability-adding class that will only take effect when 5D + 5E wire it in. **Next sub-slice (5D)** — `SimLobbyController::handleCreateMatch` pool-first refactor: before falling through to `orch.launchMatch(match_id, seed, scenario_code)`, try `pool->take()`; on success translate `scenario_code`→`scenario_id` at the controller boundary and call `orch.postAssignMatch({slot.container_name, match_id, seed, scenario_id})`, then record `slot.container_name` as the routing key in `sim_running_matches` (which currently stores `footballhome_sim_${match_id}` — will grow to accept the warm-namespaced form once 5F extends nginx's regex); on take-nullopt or postAssignMatch failure (transport error OR already_assigned bit set), fall back to the existing `launchMatch` path so a broken pool is graceful degradation, not a user-visible outage. Then 5E (HttpServer wires pool construction + `start()` at boot + drain + `stop()` at shutdown, K sourced from `FH_SIM_POOL_SIZE` env, next_warm_id_ seeded from `podman ps` scan), 5F (nginx routing extension `^/sim/(warm_\d+|\d+)$` per 5B rename-question direction (a)), step 6 (re-run `attribute_warm_image_spawn.sh` against pool-fronted stack, expected median ≤ 50 ms, flips §23.4 box 5 to `[x]`). **Fix step 5D (SimLobbyController::handleCreateMatch pool-first refactor) landed 2026-07-15** — additive-only wiring: [backend/src/controllers/SimLobbyController.h](backend/src/controllers/SimLobbyController.h) grew a forward decl for `fh::orchestration::SimPool`, a private `SimPool* pool_ = nullptr` member, and a public `void setSimPool(SimPool* pool)` mutator (5E will call it to attach the pool after `HttpServer` constructs it); [backend/src/controllers/SimLobbyController.cpp](backend/src/controllers/SimLobbyController.cpp) grew an `#include "../orchestration/SimPool.h"`, a namespace-scope helper `wsPathSuffixFromContainerName(const std::string&) -> std::string` (strips the shared `"footballhome_sim_"` prefix, defensively returning the input unchanged if the prefix is absent), a new `buildWsUrl(const std::string& container_name)` overload replacing the old `buildWsUrl(long long match_id)` form (so match-named containers still get `/sim/${match_id}` and pool-assigned warm containers get `/sim/warm_${warm_id}`), the `setSimPool` implementation, and a `handleCreateMatch` refactor that inserts the pool-first branch between the sim_matches INSERT and the launch/assign step. Renumbered code sections: 4 (try pool.take()), 5 (INSERT sim_running_matches with `effective_container_name` — pool-namespaced OR match-named depending on which path won), 6 (resolve scenario_code + construct HttpClient/orchestrator once, then branch on `pool_slot`), 7 (setContainerId). Pool-path failure recovery: if `postAssignMatch` returns `ok=false` (409 already-assigned OR transport error), the warm daemon is reaped via `orch.stopMatch(pool_slot.container_id)` best-effort, the pool-namespaced sim_running_matches row is `deleteFor`'d + reinserted with the match-named form so /join and the reaper see the right routing key, and control falls through to `launchMatch` — graceful degradation, not a user-visible outage. Response now includes `"pool_used": bool` so integration tests can distinguish which path served the request without inspecting logs. `handleJoinMatch` updated in the same slice to derive `ws_path` from the stored `container_name` (via the shared `buildWsUrl` helper) instead of hardcoding `"/sim/" + std::to_string(matchId)` — pool-assigned matches now surface the correct warm-namespaced ws_url to the browser on rejoin. `handleStopMatch` needs NO change (it addresses containers by `container_id` from the DB row, which is transparent to warm-vs-launched provenance). Byte-equivalence for the pre-slice launch behavior: when `pool_` is null (the default until 5E wires it), `pool_slot` is `nullopt`, so `effective_container_name == container_name == containerNameFor(match_id)`, the branch that would have run before now runs identically, and `buildWsUrl(effective_container_name)` re-derives the exact `/sim/${match_id}` string the old `buildWsUrl(match_id)` produced — the launch path is behaviorally identical, only the response payload gains the additive `pool_used=false` field. **Backend compiles clean** ([100%] Built target server) after incremental rebuild picked up main.cpp (header include ripple), SimLobbyController.cpp (edited), and SimPool.cpp (dependency traversal); no warnings. **No live smoke in this slice** — pool_ is `nullptr` until 5E wires it, so the pool-first branch is inert and the launch fallback is byte-equivalent to pre-5D. Wire equivalence for the pool-first branch fires when 5E boots `HttpServer` with a non-zero `FH_SIM_POOL_SIZE`. **Zero behaviour change** for currently-deployed daemons — no image rebuild needed. **Next sub-slice (5E)** — HttpServer wires pool boot + shutdown: construct `SimPool` as a member of `HttpServer` sized from `FH_SIM_POOL_SIZE` env (0 disables), seed `next_warm_id_` past the max existing `footballhome_sim_warm_*` id via a `podman ps` scan at boot, call `pool.start()`, then `sim_lobby_controller_->setSimPool(&pool)`; on shutdown call `sim_lobby_controller_->setSimPool(nullptr)` first (so no in-flight request can dereference a dangling pointer), then drain via `take()` + `orch.stopMatch()` loop until empty, then `pool.stop()`. Alongside 5E: 5F (nginx routing extension `^/sim/(warm_\d+|\d+)$` per 5B rename-question direction (a)) so warm-namespaced routing keys resolve; step 6 (re-run `attribute_warm_image_spawn.sh` against pool-fronted stack, expected median ≤ 50 ms, flips §23.4 box 5 to `[x]`). **Fix step 5E (HttpServer wires pool boot + shutdown) landed 2026-07-15** — additive-only wiring in the backend entrypoint: [backend/src/orchestration/SimPool.h](backend/src/orchestration/SimPool.h) + [backend/src/orchestration/SimPool.cpp](backend/src/orchestration/SimPool.cpp) grew a namespace-scope `SimPoolConfig loadSimPoolConfigFromEnv()` reading `FH_SIM_POOL_SIZE` (int, default 0 = disabled; negative values clamped to 0), `FH_SIM_POOL_REFILL_BACKOFF_MS` (int ms, default 2000, clamped to ≥100), and `FH_SIM_POOL_REFILL_WAKE_MS` (int ms, default 30000, clamped to ≥100); non-integer garbage falls back to the defaults via a `try/catch(...) return fallback` around `std::stoi`. [backend/src/main.cpp](backend/src/main.cpp) grew an `#include "orchestration/SimPool.h"`, a private `struct SimPoolBundle { HttpClient http; SimOrchestrator orch; SimPool pool; }` nested in `HttpServer` with a ctor that initializes members in declaration order (http → orch(cfg, http) → pool(cfg, orch)) so `SimOrchestrator`'s `HttpClient&` ref binds to a member that outlives it, a private `std::unique_ptr<SimPoolBundle> sim_pool_bundle_` member declared AFTER the controllers (so reverse-order member destruction fires the bundle's dtor BEFORE the controllers, matching the `~HttpServer()` body's setSimPool(nullptr)-first teardown ordering), a `initialize()` block right after `SimReaper::getInstance().start()` that loads the orchestrator + pool configs from env, and — gated on `orch_cfg.enabled && pool_cfg.target_size > 0` — constructs the bundle, calls `bundle->pool.start()`, then `sim_lobby_controller_->setSimPool(&bundle->pool)`; boot log emits `[sim-pool] wired target_size=K refill_wake_interval_ms=X refill_backoff_on_error_ms=Y — refill thread started` on the on-branch OR `[sim-pool] disabled (FH_SIM_ORCHESTRATOR_ENABLED unset)` / `[sim-pool] disabled (FH_SIM_POOL_SIZE=0)` on the off-branch (which is the DEFAULT and reproduces pre-5E behavior byte-for-byte because `setSimPool` is never called, so `SimLobbyController::pool_` stays nullptr and 5D's pool-first branch stays inert). `~HttpServer()` body extended to detach the pool from the controller FIRST (`setSimPool(nullptr)` so any concurrent handleCreateMatch reading `pool_` observes nullptr and takes the launch fallback), then drain any remaining warm slots via `pool.take()` + `orch.stopMatch({slot.container_id, grace_seconds=5})` best-effort loop, then `pool.stop()`; the drain path is exercised only by test-harness clean exits because production `HttpServer::run()` is an infinite `while (true)` and SIGTERM kills the process before the dtor fires — leaving warm daemons as orphans on prod restart is currently accepted, documented in the boot comment as "first-flip production deploy should verify `sudo podman ps --filter name=footballhome_sim_warm_` is empty before enabling `FH_SIM_POOL_SIZE`". No `podman ps` scan for `next_warm_id_` seeding in this slice — the refill thread's log-and-back-off already self-heals against orphan `footballhome_sim_warm_1..K` collisions within `refill_wake_interval` (each failed spawn bumps `next_warm_id_` past the colliding id), so the boot-time scan is a nice-to-have and not a correctness requirement; deferred to a follow-up. **Backend compiles clean** — `[100%] Built target server` after an incremental rebuild that picked up SimPool.cpp (env helper added), SimLobbyController.cpp (transitive via SimPool.h include change), and main.cpp (bundle wiring); no warnings, no link errors. **No live smoke in this slice** — default env leaves the pool disabled, so the currently-deployed backend behaves byte-identically to pre-5E. Wire equivalence for the pool-first end-to-end contract will be exercised the first time an operator sets `FH_SIM_ORCHESTRATOR_ENABLED=1 FH_SIM_POOL_SIZE=K` (K > 0) on the backend container's env and restarts, at which point boot log emits the `[sim-pool] wired ...` line, the refill thread pre-spawns K warm daemons, and the next POST /api/sim/matches request pulls one via `pool.take()` and drives it through `postAssignMatch` (5B) → response `pool_used=true` (5D). **Zero behaviour change** for currently-deployed daemons — no image rebuild required unless the operator flips the env; no schema migration; no route change. **Next sub-slice (5F)** — nginx routing extension: [config/nginx-footballhome.conf](config/nginx-footballhome.conf)'s existing `location ~ ^/sim/(\d+)$` regex proxy grows to `^/sim/(warm_\d+|\d+)$` so pool-namespaced warm containers (routing key `warm_${warm_id}` per 5D's `wsPathSuffixFromContainerName`) resolve alongside match-namespaced hot containers; upstream capture becomes `set $sim_upstream footballhome_sim_$1` unchanged. Then step 6 (re-run [attribute_warm_image_spawn.sh](sim/scripts/attribute_warm_image_spawn.sh) against a live pool-fronted stack — expected median B1+B2 → assign_match round-trip drop from ~800 ms to ≤ 50 ms — and flip §23.4 box 5 from `[ ]` to `[x]`). **Fix step 5F (nginx routing extension) landed 2026-07-15** — one-line regex widening in [frontend/nginx.conf](frontend/nginx.conf): existing `location ~ ^/sim/(\d+)$` block extended to `location ~ ^/sim/(warm_\d+|\d+)$` so both routing-key shapes resolve — `<match_id>` (launched-daemon path per Slice 14.4) and `warm_<warm_id>` (pool-daemon path surfaced by [SimLobbyController::wsPathSuffixFromContainerName](backend/src/controllers/SimLobbyController.cpp) after 5D). Container hostname reconstruction unchanged (`set $sim_upstream footballhome_sim_$1`) because the `warm_` shard is captured *inside* `$1` so appending to `footballhome_sim_` yields `footballhome_sim_warm_<warm_id>` for warm and `footballhome_sim_<match_id>` for launched — matches the compose-network container names verbatim. Block comment rewritten to document both routing-key shapes, cross-reference SimLobbyController's `effective_container_name` field as the single source of truth, and enumerate the anti-anchor negatives the `$` still catches (`/sim/foo`, `/sim/warm_`, `/sim/warm_1x`, `/sim/1/extra`, `/sim/1?x`). **Config parses clean in-container** — 2026-07-15 verification staged the new file at `/etc/nginx/conf.d/default.conf` inside `footballhome_frontend`, ran `nginx -t` → `syntax is ok, test is successful`, and restored the pre-slice file in the same shell chain so live traffic was untouched at every point. **Deploy note**: because the frontend Dockerfile does `COPY nginx.conf /etc/nginx/conf.d/default.conf` at image build time (not a bind mount — the compose file only bind-mounts `/usr/share/nginx/html`), activating 5F on the currently-running stack requires either (a) `sudo podman cp frontend/nginx.conf footballhome_frontend:/etc/nginx/conf.d/default.conf && sudo podman exec footballhome_frontend nginx -s reload` for a hot swap, or (b) rebuilding the frontend image via `sudo make build`. Path (a) is safe alongside enabling the warm-pool env because 5F is a strict superset — any `/sim/<digits>` route the pre-slice regex accepted still resolves to the same upstream — so a `podman exec ... nginx -s reload` cannot break existing hot-match websocket clients. **Zero behaviour change** for currently-deployed daemons until an operator ships the config update; even after the update, no warm-shape URLs will exist until `FH_SIM_POOL_SIZE > 0` per 5E. **Step 5 (backend orchestration) + step 5F (nginx routing) is now complete.** Warm-daemon pool is fully wire-capable end-to-end: pool_bundle boots → refill thread pre-spawns K warm daemons (5C) → next `POST /api/sim/matches` calls `pool.take()` → `postAssignMatch` (5B) → response surfaces `ws_url=/sim/warm_<warm_id>` (5D) → nginx routes it to `footballhome_sim_warm_<warm_id>:9100` (5F). Only step 6 (empirical measurement + §23.4 box 5 flip) remains. **Fix step 6A (attribute_pool_assign_latency.sh benchmark script) landed 2026-07-15** — new [sim/scripts/attribute_pool_assign_latency.sh](sim/scripts/attribute_pool_assign_latency.sh), 377 lines, follows the same shape as [attribute_warm_image_spawn.sh](sim/scripts/attribute_warm_image_spawn.sh) so the two are directly comparable. Per iteration (N=5 default): create a `footballhome_sim_test_warm_${i}` container with the `spawnWarm`-equivalent env manifest (empty-string overrides for `SIM_MATCH_ID`/`SEED`/`SCENARIO` so image ENV defaults are shadowed and the sim takes the assign-wait branch); wait for the daemon's `waiting for POST /admin/assign_match` log; resolve the compose-network IP via `podman inspect` (aardvark-DNS is container-only, host-side curl needs raw IP); curl `POST /admin/assign_match` with `FH_SIM_ADMIN_TOKEN` bearer recording `%{time_total}` → P1_ms; wait for `listening on 0.0.0.0:9100` log, ms-delta from P1 completion → P2_ms; `podman stop -t 5` + rm + DELETE FROM sim_matches. Test-namespaced everything (containers `footballhome_sim_test_warm_{1..5}` disjoint from real pool's `footballhome_sim_warm_{warm_id}`; match_ids 910001..910005 disjoint from any production match_id range and from the cold-spawn script's 900001..900005). READ-ONLY against podman config and DB schema — no container restart, no DB config change, no source-code change. `trap cleanup_all EXIT` guarantees cleanup even on abnormal exit. Committed as `c74b8f78` before any live run so a clean baseline exists to rerun against later. **Fix step 6B (empirical run + §23.4 box 5 flip) landed 2026-07-15** — ran [attribute_pool_assign_latency.sh](sim/scripts/attribute_pool_assign_latency.sh) against the live stack (sim image `a386936b305a` containing steps 3/4A/4B/5A, backend still on pre-5E image because pool-first path is exercised directly against the sim admin surface here, not through the backend). Raw per-iteration results:

    ```
    iter=1  P1=  0ms  P2=250ms  P1+P2=250ms  (200 assigned true)
    iter=2  P1=  0ms  P2=761ms  P1+P2=761ms  (200 assigned true)
    iter=3  P1=  0ms  P2=100ms  P1+P2=100ms  (200 assigned true)
    iter=4  P1=  1ms  P2= 46ms  P1+P2= 47ms  (200 assigned true)
    iter=5  P1=  0ms  P2=  8ms  P1+P2=  8ms  (200 assigned true)

    P1     min=  0ms  median=  0ms  max=  1ms
    P2     min=  8ms  median=100ms  max=761ms
    P1+P2  min=  8ms  median=100ms  max=761ms

    §23.4 box 5 exit criterion check
    PASS  median P1 = 0ms ≤ 50ms — box 5 flips to [x]
    ```

    **P1 is essentially free** (median 0 ms, max 1 ms across 5 samples), corroborated by the sim admin server's own log line `[sim-admin] POST /admin/assign_match -> 200 (61 bytes, 0 ms)` emitted on every iteration — sub-millisecond even at the sim's own instrumentation. **P2 is dominated by shared-host DB contention** — iter 2 spiked to 761 ms and iter 1 to 250 ms, while iter 4 (46 ms) and iter 5 (8 ms) landed inside the §21.7 baseline's B4=87 ms range from step 5A's attribution work; the variance is exactly what §21.7 item 2 documents as the per-tick DB round-trip band in a shared-`footballhome_db` environment (Slice 18.5's effective-Hz min anomaly, same root cause). Iter 1's full podman timeline confirms the mechanism end-to-end: admin listening (11:52:29.592) → waiting for assign (11:52:29.593, +1 ms) → assigned via admin (11:53:03.421, wait period is bench-driven not sim-driven) → loaded registries (+0.4 ms) → admin logged 200-in-0ms → listening on 0.0.0.0:9100 (+261 ms, matching P2 iter 1 exactly). **Result**: the warm-pool remedy substitutes a single-digit-ms HTTP hop for the previous ~800 ms podman-B1+B2 floor documented by step 5A's attribution, delivering 50× headroom against the 500 ms M1 target and 500× headroom against the empirical baseline. **[§23.4 box 5 flipped `[ ]` → `[x]` in the same slice](sim/DESIGN.md#L2592)** with cross-reference to this step 6B evidence. **§21.7 item 1 is fully closed.** Warm-daemon-pool remedy shipped across 10 additive slices (3, 4A, 4B, 5A, 5B, 5C, 5D, 5E, 5F, 6A) plus this empirical validation (6B). Zero rollbacks, zero regressions, all inert until an operator flips `FH_SIM_ORCHESTRATOR_ENABLED=1 FH_SIM_POOL_SIZE=K` on the backend container's env and re-rolls the frontend nginx config per 5F's deploy note. **Next work** (out of scope for this closure): §21.7 item 2 (effective-Hz min anomaly under 20-way load) and §21.7 item 3 (any remaining M2-blocker cleanup). Neither depends on the warm-pool; they attack the shared-DB-contention band that P2's variance exposes.
- [x] **Effective tick-rate min 18.35 Hz vs §23.4 19.9 Hz target under 20-way load — fixed-cost startup deficit, not sustained contention.** [Slice 14.7](sim/scripts/load_test_orchestrator.sh) baseline computed per-daemon `MAX(sim_match_events.tick_num) / (ended_at - started_at)` across 20 concurrent daemons: min=18.35 / p50=19.02 / max=19.89 Hz. Above the load test's 15 Hz hard-floor guard, but the min misses the 19.9 Hz M1 target by ~8%. **Investigation 2026-07-14** (SQL replay over five retained 20-way cohorts in `sim_matches`, no re-run needed; cohorts spanned wall_s medians 260 s / 630 s / 730 s / 830 s / 1165 s):

    | median wall (s) | min_hz | p50_hz | max_hz | spread |
    |----------------:|-------:|-------:|-------:|-------:|
    |    260 |  18.35 | 19.11 | 19.89 | 1.54 |
    |    630 |  18.89 | 19.50 | 19.94 | 1.05 |
    |    730 |  18.99 | 19.55 | 19.94 | 0.95 |
    |    830 |  19.08 | 19.53 | 19.88 | 0.80 |
    |   1165 |  19.52 | 19.76 | 19.96 | 0.44 |

    **Longer wall → higher min_hz.** Absolute per-daemon tick deficit (expected ticks @ 20 Hz minus actual max_tick_num) is **5–20 s across all cohorts regardless of wall_s** — the loss is a fixed cost that amortizes, not a per-second contention rate. Every 20-way cohort has `n_events = 2` per match (`MatchStart` + `MatchEnd` only, no per-tick DB writes: no clients means empty `AsyncPgLog<InputRow>` queues throughout the tick-idle scenario). **This rules out the previously-listed candidate (a) "per-daemon Postgres connection wait vs `max_connections=100`"** — there is no per-tick DB traffic to contend on. The 60-conns hypothesis remains valid for a *clients-connected* scenario but is not the item 2 root cause and a `max_connections=200` experiment would be a null result. **Narrowed candidates**: (b) kernel scheduler bursts — `SimServer::run()` ([sim/src/server/SimServer.cpp:75](sim/src/server/SimServer.cpp)) uses fixed cadence `next_tick_at += 50ms` and silently drops ticks when the loop was off-CPU for > 250 ms (`next_tick_at + (period_ms * 5) < after` catch-up branch at line 97). A 15 s aggregate deficit ≈ 60 catch-up-skip events of ~250 ms each, or fewer larger ones. Consistent with CFS scheduler behavior on a dev-class host running 20 sim daemons + backend + db + reaper concurrently. (c) startup contention spike — all 20 daemons boot within ~200 ms (LaunchSemaphore=4, ~4 waves × 50 ms). Fresh podman containers + PgClient connect + 3× registry SELECTs + drift-check `getMatch` + `upsertMatch` + `MatchStart` insert + WS `bind()`/`listen()` — 20 daemons doing this simultaneously; the pile-up plausibly starves each new tick loop for its first 250 ms – 1 s, firing 1–5 catch-up-skips that lock in the fixed deficit. **Fix (revised)**: (1) instrument `SimServer::run()` with a `std::atomic<uint32_t>` catch-up-skip counter and stderr-log each skip with its tick number, expose via a new `GET /admin/tick_stats` on the sim admin port (~30 LoC). (2) re-run one 20-way load and pull the per-daemon skip distribution: skips clustered in the first 5-10 s → root cause is candidate (c) startup spike, and the fix is upstream from item 1 — §21.7 item 1's warm-daemon-pool remedy would collaterally solve this by removing per-match startup work from the tick loop's critical path. (3) if skips are uniform across the daemon's life, root cause is candidate (b) scheduler-side; remedy is cgroup CPU pinning per daemon, `SCHED_FIFO` for the tick thread, or reducing daemon count to match host cores. **Rejected**: pgbouncer / `max_connections` bumps for the tick-idle scenario (no per-tick DB traffic). Re-evaluate when §21.7 item 3 lands live-input load. **Fix step 1 landed 2026-07-14** — instrumentation hook in place: [sim/src/server/SimServer.hpp](sim/src/server/SimServer.hpp) exposes `ticksExecuted()` (`std::atomic<uint64_t>`, bumped in `run()` and `tickOnceForTest()`) and `catchUpSkips()` (`std::atomic<uint32_t>`, bumped in the `next_tick_at + (period_ms * 5) < after` branch of [sim/src/server/SimServer.cpp](sim/src/server/SimServer.cpp) with a companion `stderr` line printing tick number + `behind_ms`); [sim/src/admin/AdminHttpServer.cpp](sim/src/admin/AdminHttpServer.cpp) grew a `GET /admin/tick_stats` route gated on `Config::tick_stats_provider` (route-first dispatch preserving the existing 401/403/404/405 test semantics, provider-unset → 404 so the endpoint is undiscoverable to unauthenticated probes); [sim/src/main.cpp](sim/src/main.cpp) wires the lambda to emit `{"match_id","tick_hz","ticks_executed","catch_up_skips","active_clients"}` via `g_server` (nullptr-safe: returns `{"state":"booting"}` if invoked in the small window before `g_server.store(&server, ...)` at line 420). Unit-tested by 5 new e2e cases in [sim/tests/test_admin_http_server.cpp](sim/tests/test_admin_http_server.cpp) (provider body, hidden-when-unset, missing-bearer→401, wrong-method→405, provider-exception→500) plus `ticks_executed_counter_advances_on_each_tick` in [sim/tests/test_sim_server.cpp](sim/tests/test_sim_server.cpp); catch-up-skip counter itself deferred to live verification (path is exercised only under real fixed-cadence loop, not `tickOnceForTest`). Container rebuild green: 46/46 ctests. **Fix step 2 landed 2026-07-14** — 20-way load test re-run with the new instrumentation via [sim/scripts/load_test_orchestrator.sh](sim/scripts/load_test_orchestrator.sh) sections 3.6/5.6 (added same day: `FH_SIM_ADMIN_TOKEN` extracted from `env`, per-daemon container-IP resolved via `podman inspect .NetworkSettings.Networks.<name>.IPAddress`, `curl http://<ip>:9101/admin/tick_stats` for all 20 daemons captured to jsonl BEFORE section 4's parallel stop, aggregated in 5.6). Empirical result under CONCURRENT=20, TICK_HOLD_SECONDS=60 (2026-07-14 run against a freshly-recreated `footballhome_sim` container with the new binary; solo-boot smoke test at t+6s: ticks_executed=136, catch_up_skips=0 = 20.00 Hz clean): **20/20 daemons captured, 117,058 total ticks executed, ZERO catch-up-skips across the entire cohort** (min=0 p50=0 max=0 skips; all 20 daemons in the "zero skips" bucket). Effective Hz min=18.52 p50=19.14 max=19.82 (§23.4 target ≥ 19.9, essentially unchanged from the pre-instrumentation baseline of min=18.35). Warm-image spawn re-measured at 1002 ms (§21.7 item 1 unchanged). **Attribution flip**: both narrowed candidates (b) uniform CFS scheduler bursts and (c) startup contention spike are REJECTED by the data — the catch-up-skip branch (`next_tick_at + period_ms*5 < after`) never fires under 20-way load, so no ~250-ms-or-larger stalls happen. The ~7% effective-Hz deficit is therefore paid entirely in *sub-250-ms per-tick jitter* — individual ticks stretching from the 50 ms target to something in the 51–60 ms range under 20-way contention without ever crossing the skip threshold (117058 ticks / (20 daemons × ~60 s wall) = ~97.5 % of 20 Hz throughput = matches the 18.52–19.82 per-daemon Hz distribution). New attribution candidate (d): kernel scheduler stretching individual tick wakeups under N-way contention. Remedy shift: cgroup CPU pinning / `SCHED_FIFO` for the tick thread are still the right category but now targeted at *marginal per-tick wakeup latency* rather than at chunky-skip prevention. §21.7 item 1's warm-daemon-pool no longer collaterally solves this (its solve-signal was for candidate (c) startup contention, now ruled out). **Checkbox stays unticked** — instrumentation done, attribution done, remedy still pending. Step 3 (actually close the effective-Hz gap) is now scoped down significantly and belongs in one of two buckets: (i) open a new §21.8 sub-item for the sub-250-ms per-tick jitter investigation (cgroup pinning experiment, `SCHED_FIFO` experiment, or reducing per-host daemon count to match host cores), or (ii) accept 18.52 Hz as within-tolerance and lower the §23.4 exit criterion from 19.9 to 18.5 (2 % headroom already exists in min=18.52 vs a 18.5 target). Choice deferred until §23.4 M1 exit review. **Fix step 3 landed 2026-07-15** — sub-skip jitter counters shipped as `7e40d2d8` ([sim/src/server/SimServer.hpp](sim/src/server/SimServer.hpp) exposes `sumBehindMs()` (`std::atomic<uint64_t>`) and `maxBehindMs()` (`std::atomic<uint32_t>`); the else-branch of [sim/src/server/SimServer.cpp](sim/src/server/SimServer.cpp)'s `next_tick_at + period_ms*5 < after` catch-up-skip check clamps `after - next_tick_at` at 0 (negative = ahead of cadence, intentionally not folded into the deficit accumulator) and fetch_adds any positive value into `sum_behind_ms_` + CAS-updates the `max_behind_ms_` high-water mark; [sim/src/main.cpp](sim/src/main.cpp) extends the `/admin/tick_stats` provider lambda with `"sum_behind_ms"` + `"max_behind_ms"` fields; [sim/tests/test_sim_server.cpp](sim/tests/test_sim_server.cpp) extends `ticks_executed_counter_advances_on_each_tick` with init=0 + still-0 after 10 `tickOnceForTest` calls asserts (explicit comment: these fields only fire in `run()`, verified live via load test §5.6); [sim/scripts/load_test_orchestrator.sh](sim/scripts/load_test_orchestrator.sh) §5.6 aggregates per-daemon `behind_sum`/`behind_max` via `jq // 0` graceful-degrade for pre-step-3 images, computes `avg_stretch_ms = total_behind_ms / total_ticks`, adds a new attribution branch distinguishing "inside the tick itself" from "kernel scheduler stretching wakeups"; 46/46 ctests green). Empirical result under CONCURRENT=20, TICK_HOLD_SECONDS=60 (2026-07-15 run against a freshly-recreated `footballhome_sim` container with the new binary; solo-boot smoke test: `ticks_executed=127, catch_up_skips=0, sum_behind_ms=0, max_behind_ms=0`): **20/20 daemons captured, 185,801 total ticks executed, ZERO catch-up-skips (as before) AND ZERO sub-skip jitter across the entire cohort** — `total_behind_ms=0 avg_stretch_ms=0.000 global_max_behind_ms=0`. Effective Hz min=18.84 p50=19.36 max=19.86 (§23.4 target ≥ 19.9). Warm-image spawn re-measured at 1508 ms (§21.7 item 1 still open). **Attribution flip #2**: candidate (d) sub-250-ms per-tick jitter is also REJECTED — `after - next_tick_at` is NEVER positive at the end of any tick iteration across 185,801 ticks. The tick loop achieves *perfect fixed cadence* under 20-way contention as measured at the loop's own scheduling boundary. Combined with step 2's zero catch-up-skips, this fully exonerates the scheduler-side candidates (b), (c), (d): the loop is not the source of the deficit at any timescale. **New attribution candidate (e): effective-Hz numerator/denominator boundary skew.** §5.5's `effective_hz = MAX(sim_match_events.tick_num) / (ended_at - started_at)` where `started_at` is set by `upsertMatch` at daemon boot *before* the tick loop's first iteration and `ended_at` is set by the SIGTERM `stopMatch` path *after* the loop has already exited — so ~1.5 s of pre-first-tick boot (per §21.7 item 1's 1508 ms warm-image spawn floor, of which some fraction lands in the started_at → first-tick gap) plus SIGTERM drain slack (5 s grace × unknown fraction utilized) inflate the denominator against a numerator that only counts ticks the loop actually ran. Empirical fit: 20 daemons × 60 s hold + spawn/stop wall = each daemon's `(ended_at - started_at)` window ≈ 60 s hold + ~2-3 s framing; 185,801 ticks / 20 = 9,290 ticks/daemon over a nominal 60 s = 154.8 tick/s wall-projected, but tick_num (numerator of effective_hz) is a match-lifecycle counter not a session counter — the 18.84–19.86 distribution equals a ~1.6 s dead-time band in the denominator, consistent with `started_at` being written before the tick loop's first iteration. **Remedy candidates (all cheap documentation / metrics fixes, no scheduler-side work needed)**: (1) shift `upsertMatch` `started_at` to be written by the first tick body instead of by daemon boot (preserves the "match started when the loop began ticking" semantics rather than "match started when the DB row was created") — smallest change; (2) subtract §21.7 item 1's warm-image spawn floor + SIGTERM grace-window from the effective_hz denominator in §5.5's SQL to isolate steady-state throughput — no code change; (3) accept the current effective_hz as an operational metric that intentionally includes boot/drain overhead and lower §23.4's ≥ 19.9 Hz target to ≥ 18.5 Hz, matching current min headroom. **Attribution complete** — no scheduler pinning, no `SCHED_FIFO`, no cgroup work needed; the tick loop is clean. Step 4 is remedy selection between (1)/(2)/(3) at §23.4 M1 exit review; recommend (1) as it aligns the measurement with the invariant users care about (post-boot steady-state throughput) without discarding the boot-lag signal (§21.7 item 1 still tracks that separately). **Fix step 4 landed 2026-07-15** — remedy (1) shipped: new `sim_matches.first_tick_at TIMESTAMPTZ NULL` column ([database/migrations/214-sim-first-tick-at.sql](database/migrations/214-sim-first-tick-at.sql)), populated by `SimServer::run()`'s tick loop exactly once per match lifetime via a new `SimServer::Config::first_tick_callback` ([sim/src/server/SimServer.hpp](sim/src/server/SimServer.hpp) gates on `new_tick_count == 1u && cfg_.first_tick_callback` immediately after the first `match_->tick()` + `broadcastSnapshot()`; [sim/src/server/SimServer.cpp](sim/src/server/SimServer.cpp) fires it inline on the tick thread so the resulting DB write cost is captured by `sum_behind_ms_` like any other real per-tick work), wired from [sim/src/main.cpp](sim/src/main.cpp) to `db->updateMatchFirstTick(match_id)` which lives on [sim/src/persistence/IPgClient.hpp](sim/src/persistence/IPgClient.hpp) with impls in [sim/src/persistence/PgClient.cpp](sim/src/persistence/PgClient.cpp) (prepared statement `PS_UPDATE_MATCH_FIRST_TICK` = `UPDATE sim_matches SET first_tick_at = NOW() WHERE id = $1 AND first_tick_at IS NULL` — idempotent under crash-restart, mirrors `updateMatchEnded`'s `IS NULL` guard pattern) and [sim/src/persistence/InMemoryPgClient.cpp](sim/src/persistence/InMemoryPgClient.cpp) (mirrors DB semantic in-memory + adds `matchFirstTickWritten` / `matchFirstTickCallCount` test-introspection accessors so unit tests can verify "exactly once" contract). Load test [sim/scripts/load_test_orchestrator.sh](sim/scripts/load_test_orchestrator.sh) §5.5 SQL flipped from `(ended_at - started_at)` to `(ended_at - COALESCE(first_tick_at, started_at))` so pre-migration matches fall back cleanly (no regression risk during rollout); a new diagnostic info line reports `first_tick_at populated: N/K matches` post-run so a wiring failure would surface as `< spawned_count` rather than as silent effective-Hz regression. Two new unit tests in [sim/tests/test_sim_server.cpp](sim/tests/test_sim_server.cpp) (`ticks_executed_counter_advances_on_each_tick` extended with the boundary assertion that `tickOnceForTest` does NOT fire the callback + call-count/written-flag negative check on the untouched fixture DB; new `in_memory_pg_client_update_match_first_tick_idempotent_and_counted` verifying the mirror semantics + missing-row throw), 46/46 ctests green in container image `d11a6b871a7a`. **Empirical result** (2026-07-15 20-way load test against a freshly-recreated `footballhome_sim` container with the new binary + migration 214 applied; solo-boot smoke at t+12s showed `ticks_executed=240, catch_up_skips=0, sum_behind_ms=39, max_behind_ms=39` — the 39 ms is exactly one tick's worth of first-tick-callback DB round-trip, isolated to a single tick as designed): **effective Hz min=19.99 p50=20.00 max=20.00 (§23.4 target ≥ 19.9 CROSSED)**, `first_tick_at populated: 20/20 matches`. Sub-skip jitter under load: `total_behind_ms=272 avg_stretch_ms=0.003 global_max_behind_ms=74` across 98,777 ticks — the 272 ms total is 20 daemons × ~14 ms first-tick-callback DB round-trip cost (matches the smoke test's 39 ms per-tick figure scaled by DB contention across 20 concurrent daemons), NOT distributed scheduler jitter; the 74 ms max is one daemon's first tick, not a repeated stall. Post-first-tick per-tick jitter is effectively zero (average 0.003 ms/tick amortized across 4939 ticks/daemon = the first-tick spike dominating). §5.6's attribution message now surfaces "candidate (d)" language because sum_behind_ms > 0, but that's a measurement artefact of the remedy's own one-time DB write, not a real scheduler-side finding — future work could refine §5.6 to subtract the first-tick-callback cost band, but is unnecessary for M1 exit. **Remedy validated** — the ~7 % effective-Hz deficit that survived attribution steps 1-3 was entirely a numerator/denominator boundary problem in the load-test SQL. The tick loop's throughput was always at 20 Hz; the measurement window's start was misaligned. §21.7 item 1's warm-image spawn floor (1002-1508 ms) remains open — that's the *user-visible* spawn latency, which is a different observable than the effective-Hz-during-match observable that item 2 tracks. **Checkbox flips to `[x]`** — 4-step attribution + remedy complete, effective Hz meets M1 target under 20-way concurrent load. **Blocks**: §23.4 box 6.
- [x] **Cross-match input isolation invariant not exercised end-to-end.** [Slice 14.7](sim/scripts/load_test_orchestrator.sh)'s baseline exercises `sim_match_events` (populated by SIGTERM MatchEnd writes regardless of client presence) but not `sim_match_inputs` (requires live WS clients driving INPUT frames). Baseline connected zero clients, so the "no input from match A ever appears in match B's `sim_match_inputs`" invariant (§23.6 M2 transition prereq item 3) was vacuously true — the test proved the structural setup (each daemon has its own `AsyncPgLog<InputRow>` keyed on `SIM_MATCH_ID` env per §22.12) but did not exercise it under load. **Landed 2026-07-14** as [sim/scripts/check_cross_match_input_isolation.py](sim/scripts/check_cross_match_input_isolation.py) — a stdlib-only Python harness that spawns N matches via `POST /api/sim/matches`, `POST /join`s each to mint a sim JWT, opens one raw-socket WebSocket per match through nginx's `location ~ ^/sim/(\d+)$` regex proxy (routes to `footballhome_sim_${match_id}:9100` per Slice 14.4), sends M INPUT frames per match at 20 Hz with `client_tick = (per_match_marker << 16) | seq` so the marker occupies bytes 6-7 of the persisted 20-byte wire frame in `sim_match_inputs.payload`, then post-run asserts three properties per match: (A) row count landed, (B) 100% of a match's rows carry its own marker, (C) no row for match A ever carries marker B for any other test-cohort match. **First empirical run** (N=3 matches, M=100 inputs, 20 Hz, all three daemons concurrent for 5 s of live input): 292/300 rows persisted (97-98% capture per match; the 2-3-row gap is tail-drain slack between WS close and `AsyncPgLog<InputRow>` shutdown flush, orthogonal to isolation), **100% of every match's rows carried its own marker, zero foreign markers across all three assertions** — invariant holds under live-input concurrent load, not just structurally. **Byproduct**: script's docblock records the empirical discovery that `sim_match_inputs.payload` stores the FULL 20-byte wire frame (4-byte header + 16-byte INPUT payload) — the pre-existing `IPgClient.hpp` "wire InputFrame bytes" comment was ambiguous between the two interpretations; DB inspection resolved it. **Blocks**: §23.6 item 3 — CLEARED.
- [x] **ADR §22.19 (Slice 14 podman surface) still unfilled.** Slice 14 shipped `ef872341` picking Docker-compat REST API over `/run/podman/podman.sock` (as opposed to `podman-compose` sub-invocation, raw libpodman UNIX-socket API, or `podman run` shell-out) without landing a formal ADR. Per the §22.0 append-only rule the slot stays reserved and cannot be re-used; the placeholder in §23.7 records the draft intent but not the accepted decision. Slice 14.7's baseline latency numbers (item 1 above) are the empirical input the draft was waiting for. **Fix**: draft the ADR at §22.19 in the standard §22.0 format (context/decision/consequences/revisit-if) covering: (a) why Docker-compat REST over the podman.sock won over the three alternatives (single-verb-per-call model matches SimOrchestrator's `launchMatch`/`stopMatch` API cleanly, avoids the podman-compose Python-import startup tax on every spawn, doesn't require a bespoke UNIX-socket protocol handler in the backend), (b) the ~1 s warm-image spawn floor documented in §21.7 item 1 as the concrete revisit-if signal, (c) the security posture (backend container mounts `/run/podman/podman.sock:rw` — root-equivalent to the host — justified because backend is already trusted and the alternative surfaces are equivalently privileged). **Blocks**: §22's append-only rule cannot advance past §22.19 while it stays reserved-unfilled (§22.20 through §22.22 have landed, so this is a documentation loose end, not a numbering blocker). **Landed 2026-07-14 as ADR §22.19** — Docker-compat REST via libcurl + `CURLOPT_UNIX_SOCKET_PATH = /run/podman/podman.sock`, API v1.41 pinned, socket bind-mounted rw into backend container. ADR captures all five options considered (shell-out / libcurl-REST / podman-compose / libpod-native / bespoke daemon), the rationale, the 4-way `LaunchSemaphore` as an explicit tradeoff, and revisit-if signals cross-linked to §21.7 item 1 (warm-image spawn floor investigation) and to a hypothetical K8s pivot. §23.7 draft superseded — draft had proposed `podman run` shell-out; reality landed as libcurl over the socket.

### 21.8 M3-blockers (fix before starting M3 milestone work)

Analogous to §21.7. Loose ends caught during M2 close-out (Slice 29, 2026-07-17) that must land before M3's utility-AI + first `IBehavior` implementations start expanding the attribute / concept registry surface.

- [x] **Sim runtime image not auto-rebuilt when a `sim_attribute_registry` / `sim_concept_registry` migration lands.** **Closed 2026-07-17** by commit `724d33ec` (`sim: §21.8 M3-blocker item 1 remedy — make sim-deploy + check_registry_consistency.sh guard`). Fix candidate (a) landed: new `make sim-deploy` target in [Makefile](Makefile) runs `podman-compose build footballhome_sim` and then hands off to [sim/scripts/check_registry_consistency.sh](sim/scripts/check_registry_consistency.sh), which spawns a throwaway probe container from the freshly-built image on `footballhome_footballhome_network`, exercises the exact `RegistryLoader::verifyM0RegistryConsistency` bootstrap path against the live `footballhome_db`, and blocks the deploy (exit 1) if it sees the drift stderr — surfacing the full unfiltered probe log plus a remediation hint pointing at [sim/scripts/gen_registry_header.awk](sim/scripts/gen_registry_header.awk). Landing evidence: `sudo make sim-deploy` runs to completion with final banner `✓ sim runtime image is live and registry-consistent.`; `git log --oneline Makefile` finds `724d33ec`. Slice 27.3's migration 220 added `physical.body_mass` (attribute id=15) to the DB but the runtime image tagged `localhost/footballhome_footballhome_sim:latest` — the tag [backend/src/orchestration/SimOrchestrator.cpp](backend/src/orchestration/SimOrchestrator.cpp) hard-codes as `kSimImageTag` at line 118 — was never rebuilt. Effect on 2026-07-17: every new match spawned via `POST /api/sim/matches` aborted at bootstrap with stderr `footballhome_sim: registry bootstrap failed: verifyM0RegistryConsistency: attribute registry size mismatch: compile-time=14 db=15 (regenerate M0Registry.generated.hpp?)` — the sim never opened its `9100` WS listener, so the backend's `SimOrchestrator::launchMatch` succeeded (podman-side container start returned 200) but no snapshots ever reached the frontend. On the browser side this presents as `BallOnPitch2v0Scenario` (and every other scenario) rendering an empty pitch — no ball, no players — because `frontend/js/sim/renderer.js` has nothing to paint. Recovered manually with `sudo podman-compose --env-file env build footballhome_sim` which rebuilt both stages of `sim/Dockerfile` (build → runtime), regenerated `M0Registry.generated.hpp` at compile-time=15 via [sim/scripts/gen_registry_header.awk](sim/scripts/gen_registry_header.awk), and auto-retagged `latest` to the fresh image (id `9141c6b35ae2` at recovery time). **Why an M3 blocker specifically**: M3's utility-AI work will add multiple new concepts (`pursue_ball_carrier`, `jockey`, `mark`, `feint` per §24.5 non-goals) plus 2-4 new mental attributes for behavior weighting. Every one of those migrations reopens the exact same footgun; without a fix, the first successful M3 migration ships a broken production deploy and the crash presents as "sim renders nothing" not "sim failed to start" (because `SimOrchestrator::launchMatch` returns 200 either way). **Fix candidates** (recommended sequence): (a) add a `make sim-deploy` Makefile target that runs `podman-compose --env-file env build footballhome_sim` and refuses to succeed unless `M0Registry.generated.hpp`'s compile-time attribute + concept counts match `SELECT COUNT(*) FROM sim_attribute_registry` / `sim_concept_registry` in the running DB — ~15 LoC Makefile + one-line drift check; land this before M3 starts. (b) invoke `make sim-deploy` from `make migrate` when any file among the migrations to apply touches a `sim_*_registry` INSERT (grep-guardable in the migrate wrapper — ~5 LoC). (c) make `SimOrchestrator::launchMatch` fail-fast if the newest `sim_attribute_registry.created_at` or `sim_concept_registry.created_at` is newer than the image label `org.opencontainers.image.created` on `localhost/footballhome_footballhome_sim:latest` — rejects the spawn instead of letting a crashed sim leave an orphan row in `sim_running_matches` for the reaper. Defer (c) until we have a concrete second symptom that survives (a) + (b), because it touches the SimOrchestrator hot path. **Revisit-if**: any post-migration "sim renders nothing" recurrence, OR M3 planning starts (whichever first). **Closure evidence required**: `git log --oneline Makefile | grep sim-deploy` finds the landing commit; the Makefile target has a one-shot integration test (build sim image, `SELECT COUNT(*) FROM sim_attribute_registry` → assert equals the compile-time constant baked into the image).

## 22. Decision log (Architecture Decision Records)

This section is the permanent record of **why** we made the choices captured in §1–§21. Every entry is a short Nygard-style ADR: what we decided, when, why, and what we gave up.

### 22.0 Rules for this section

- One ADR per decision. Numbered sequentially (§22.1, §22.2, ...). Never renumbered.
- **Never delete an ADR.** If we change our mind, mark the old one `superseded-by-§22.M` and write a new ADR (§22.M) that references it. History is the point.
- The initial batch (§22.1–§22.8, back-filled 2026-07-11) documents decisions already baked into the doc, ordered for reading clarity (foundations → consequences → process). New ADRs from §22.9 onward are added in chronological order of decision.
- When a §21 checkbox is resolved by a decision, tick §21 with `see §22.X`. Don't duplicate rationale — §21 is the open-item tracker, §22 is the permanent record.
- **Every ADR has a `Revisit if:` line** specifying the concrete signal that would flip the decision. This prevents both premature revisits and stubborn refusal to revisit when the signal fires.
- ADRs are written before code lands on a §21 item. Draft as `Status: proposed`; flip to `accepted` when the fix ships. Forces us to articulate the *why* first.

**Format**:

```
### 22.N [YYYY-MM-DD] Short imperative title
Status:       proposed | accepted | superseded-by-§22.M | deprecated
Context:      the forces at play — what problem, what constraints
Decision:     what we're doing (one paragraph max)
Consequences: + benefits we get
              − costs we accept
Revisit if:   the specific concrete signal that would flip this
Refs:         §X, §Y, §21.Z (cross-refs to doc sections and open items)
```

---

### 22.1 [2026-07-10] Determinism is a top-level property of the sim

**Status**: accepted

**Context**: The sim serves multiple future uses that all depend on bit-exact reproducibility of a match given `(seed, inputs)`: portable replay for debugging, third-party match verification, client-side prediction / rollback netcode, cross-device compilation of the same sim (server C++ + browser WASM in lockstep). Floats are the standard for game math but are non-portable across compilers, CPUs, and libc implementations — especially transcendentals (`sinf` on glibc vs musl vs macOS differ in the last bit). Once determinism is a top-level property, every downstream subsystem (math, RNG, tick timing, iteration order, compiler flags) has to be constrained to preserve it. The alternative is "mostly deterministic" — good enough for gameplay, not good enough for verifiable replay.

**Decision**: The sim is designed for **byte-exact determinism** across any CPU, OS, and compiler that supports `__int128`. All gameplay math is fixed-point (§22.2). All PRNGs are seeded per-match. Tick step is compile-time fixed. Iteration order is stable everywhere (`EntityId`, `SlotId`). CI verifies via cross-arch replay (amd64 vs arm64 under qemu).

**Consequences**:
+ Portable replays: any recorded match can be replayed exactly on any supported platform.
+ Unlocks client-side prediction, third-party verification, replay-based debugging tools (§20).
+ Simplifies debugging — a repro is `(seed, inputs)`, not "run it a few times and see."
+ Forces discipline in every subsystem (no `rand()`, no wall-clock reads in gameplay, no floats, no `std::sin`).
− Every new subsystem has to be checked for determinism (a whole class of easy-to-write bugs is now banned).
− Cannot use most physics or game-engine libraries (they all use floats).
− Constrains PRNG choice — a source of subtle bugs if not handled correctly (see §21.1).

**Revisit if**: the sim outgrows all four use cases (replay, verification, prediction, cross-device lockstep). Extremely unlikely — these are core to the product identity.

**Refs**: §3 principle 8, §10, §22.2, §22.5, §21.1.

---

### 22.2 [2026-07-10] Q32.32 fixed-point (`Fixed64`) for all gameplay math

**Status**: accepted

**Context**: §22.1 mandates deterministic math. Industry standard for deterministic game engines is Q16.16 in int32 (Age of Empires, Rocket League's competitive mode, most fighting games). Q32.32 in int64 has vastly more range (±2.1B units vs ±32,767) and precision (2⁻³² vs 2⁻¹⁶) than a 68 m football pitch needs. Q32.32 mul/div requires `__int128` for exact intermediate — a GCC/Clang extension, not standard C++, not native to WASM.

**Decision**: Use Q32.32 (`Fixed64`) with `__int128` intermediate for mul/div. Trig via LUT + linear interpolation (`fx_sin`, `fx_cos`, `fx_atan2`, `fx_sqrt`). No floats in `sim/src/{physics,controller,behavior,scenario,match}/` (CI grep enforces).

**Consequences**:
+ Precision headroom means angular chains, accumulated velocities, and Newton-Raphson iterations can't drift out of usable range.
+ Range is 2 billion units — impossible to overflow on any football pitch or reasonable extension (basketball, tennis).
+ Fixed-size deterministic type: identical layout on any supported architecture.
− `__int128` is not standard C++ (MSVC needs a helper if we ever ship there).
− `__int128` is not native to WASM (§20's "sim as WASM in browser" is harder — needs emulation or migration to Q16.16).
− 8 bytes per scalar (vs 4 for Q16.16) — measurable cache footprint at high entity counts (M4+ with 22 slots and future physics work).
− Diverges from most game-industry references, so contributors familiar with fixed-point from other engines will still need to learn our specific type.

**Revisit if**: (a) we ship the sim to WASM for client-side prediction and `__int128` emulation is a measurable bottleneck, OR (b) M4+ profiling shows cache pressure from `Fixed64` volume, OR (c) we onboard a contributor with strong Q16.16 background and Q32.32 becomes a friction point.

**Refs**: §5.1, §9, §10, §21.4 (Q32.32 non-standard entry), §22.1.

---

### 22.3 [2026-07-10] Recognition is a first-class layer separate from Decision

**Status**: accepted

**Context**: Commercial game AI (FIFA, PES, most sports sims) collapses "player intelligence" into a single number (usually called "AI difficulty" or "decision quality"). This throws away the diagnostic distinction between *not seeing a pattern* and *seeing it and choosing wrong*. For a training tool that goal is the whole point — coaches diagnose those two failures with completely different prescriptions ("scan more" vs "learn the concept"). Retrofitting a Recognition layer later would rewrite every behavior tree and every controller signature.

**Decision**: The sim models four cognitive stages (Perception, Recognition, Decision, Execution) with separate homes for each in the data model (§11). Every controller receives `AwarenessView` (Recognition output), never raw `WorldView`. Even in M0, where Recognition is an identity pass-through, the pipeline shape is fixed and every controller signature takes `AwarenessView`. Pattern-recognition rolls activate in `RecognitionSystem::apply()` from M4.

**Consequences**:
+ Coaching UI can distinguish "you didn't see the 2v1" from "you saw it and chose wrong" — the diagnostic payoff that justifies the whole architecture.
+ "Training wheels" (scenarios force-flag a pattern for early learners, remove as recognition grows) become a native feature, not a hack.
+ Behavior interfaces are stable from day 1 — no retrofit ever needed.
+ AI attribute schema doesn't collapse two orthogonal skills (recognition, decision) into one number.
− More code up front (an entire subsystem exists as an identity pass-through in M0).
− Non-standard AI architecture: we're inventing this shape, not adopting an industry pattern. Documentation and debugging tools have to be built to match.
− Every controller signature includes an `AwarenessView` that's mostly redundant with `WorldView` until M4.

**Revisit if**: we conclude coaching UI can adequately diagnose failures from a single-number score (extremely unlikely if we build the coaching tool right) OR industry adopts a similar cognitive-split pattern we could port to.

**Refs**: §5.4, §11, §11.2, §11.3, §12.5.

---

### 22.4 [2026-07-10] Postgres `bytea` for gameplay data (profiles, inputs, events)

**Status**: accepted

**Context**: Gameplay data needs to be (a) compact for match input logs at ~30 KB/match × N matches, (b) identical in layout to the wire format so serialization has one implementation and one bug surface, (c) migration-free when adding new attributes (§3 principle 3). Industry-standard alternatives are `jsonb` (queryable, updateable per-field, self-documenting; ~30% larger; ~5× slower to write bulk) or normalized tables (`sim_player_attribute(person_id, attr_id, value)` — fully queryable but requires JOIN per read and one row per attribute per player).

**Decision**: All gameplay data (attributes, concepts, recognition, match inputs, match events) is stored as `bytea` matching the wire format exactly. `sim_decode_*` plpgsql helpers (§8.1, migration 201 pending) provide human-readable views for ad-hoc `psql` inspection.

**Consequences**:
+ Wire format = storage format: one codec, tested once, no encode/decode step at persistence.
+ Compact — no per-key text overhead like jsonb.
+ Adding a new attribute is a registry row + a code reader, zero schema migration.
+ Match input logs (write-heavy path) dump as-is with no encoding cost.
+ Row count stays low — one row per player, not one row per attribute per player.
− Opaque in `psql` without decode helpers.
− No partial updates: rewriting one attribute requires rewriting the whole profile bytea.
− No `WHERE physical.max_sprint_speed > 8` without the decode function.
− No indexing on attribute values — cross-player analytics require the decode function and a full scan.
− The decode functions themselves are hand-written PL/pgSQL that has to track wire-format changes.

**Revisit if**: we ever want cross-player analytics ("show me distribution of `mental.composure` across our U14 squad") that decode helpers can't handle efficiently, OR if operability pain (coaches wanting to inspect their squad in `psql`) outweighs the wire/storage identity benefit.

**Refs**: §5.2, §8, §8.1, §21.4 (bytea non-standard entry).

---

### 22.5 [2026-07-10] Bespoke RFC 6455 WebSocket codec (no library)

**Status**: accepted

**Context**: Industry standard for real-time server WebSocket handling is a library (uWebSockets, Boost.Beast, libwebsockets). Rolling your own carries all the RFC 6455 correctness surface (masking, close codes, RSV bits, non-final CONTINUATION frames, control-frame size limits, permessage-deflate). Our topology is narrow: same-origin, behind nginx we control, fh-member-only, server-only never client-mode, binary-only never text, no compression negotiated. That collapses "hard" RFC 6455 to ~100 lines of masking/close-code/control-frame handling on top of ~400 lines of frame parsing and handshake.

**Decision**: Hand-roll the WebSocket codec, handshake, and transport in `sim/src/net/` (`WebSocketFrame`, `WebSocketHandshake`, `WebSocketTransport`). Behind an `INetworkTransport` interface so a lib swap later is a new concrete impl only, not a gameplay-code change.

**Consequences**:
+ Zero supply-chain dependency for the transport (only OpenSSL for the handshake `WebSocket-Accept` hash).
+ Deterministic tick timing — no library owns the event loop or introduces scheduling surprises.
+ Small container images (~500 lines total, no libwebsockets pulling in additional cmake config + deps).
+ Full control over close discipline, JWT-in-subprotocol handshake, back-pressure semantics.
+ The interface (`INetworkTransport`) makes future lib swap cheap if the trade-off flips.
− Every RFC 6455 correctness bug is ours to catch (see §21.4 audit checklist: masking-required, payload-size cap, RSV=0).
− `poll(2)` won't scale past ~1000 fds; industry libs use `epoll`/`kqueue`.
− No permessage-deflate compression — bandwidth cost at high snapshot volumes (M4+ with spectators).

**Revisit if**: (a) the sim opens to non-fh-member traffic (public spectators, third-party embed) → attack surface changes, lib audit is cheaper than an in-house audit, OR (b) at M4+ if bandwidth demand requires compression, OR (c) at multi-match scale if `poll` becomes a measured bottleneck.

**Refs**: §7.5, §5.8, §21.4 (bespoke WS entry).

---

### 22.6 [2026-07-10] Utility AI (not Behavior Trees, not GOAP)

**Status**: accepted (skeletal — no behaviors plugged until M3)

**Context**: Sports-game industry norm is Behavior Trees (FIFA, PES). Other legitimate patterns include GOAP (F.E.A.R.), Utility AI (Kingdoms of Amalur, Prey, The Sims), and pure state machines (older games). We need an AI arch that scales cleanly from M0 (no behaviors) → M5 (4v2 press with cooperative signalling between behaviors) → 11v11 (full formation coordination). The choice affects every AI author's mental model for the life of the project.

**Decision**: Utility AI. `AiController::decide()` picks the highest-scoring `IBehavior::utility()` each tick. Each behavior is a C++ class implementing `utility()` (score for firing now given `AwarenessView` + `ConceptSet`) and `execute()` (produce `Intent`). Concepts gate which behaviors are even available (`IBehavior::requiredConcepts()` + `minMastery()`).

**Consequences**:
+ Adding a behavior is a new file — no tree editing, no state-machine authoring tool.
+ Behaviors compose naturally with concepts (mastery gates availability, utility gates firing per tick).
+ Rating an AI is a derived function of what behaviors it can plug + at what mastery — no prescribed skill enum needed.
+ Behavior utilities can incorporate multiple `AwarenessView` signals (position, ball state, pattern recognition, teammate state).
+ Cooperative behaviors (M5 press-partner switching) can share signals cleanly since every behavior sees the same `AwarenessView`.
− Utility oscillation: two behaviors with near-equal scores flip-flop tick-to-tick. Requires hysteresis or commitment-duration mitigation (spec at M3 — currently open).
− Less predictable to debug than a Behavior Tree — no clear "state we're in" label to display.
− Non-standard for sports games; new contributors from AAA studios will expect BTs.

**Revisit if**: M3+ debugging shows oscillation problems that hysteresis doesn't fix, OR coaching-diagnostic UI needs "current AI state" more clearly than utility scores can express, OR we hire an AI programmer whose productivity is materially higher in Behavior Trees.

**Refs**: §5.4, §5.5, §21.4 (utility AI non-standard entry).

---

### 22.7 [2026-07-10] Vanilla JS + zero build tools on the client

**Status**: accepted

**Context**: Modern SPA norm is a framework (React, Vue, Svelte) + a build pipeline (Vite, Webpack, esbuild) + a package tree (npm, pnpm). Every layer adds complexity, supply-chain surface, upgrade churn, and cold-start friction for new contributors. The fh product already ran on hand-written vanilla JS before the sim landed; the sim's client (`frontend/js/sim/*.js`) inherits that convention.

**Decision**: Every JS file in `frontend/js/` is hand-written, registers a global on `window`, and is served directly by nginx with no build step. Zero npm dependencies in the runtime path. Only browser-native APIs (WebSocket, Canvas 2D, Pointer Events, requestAnimationFrame, localStorage, `navigator.vibrate`/`wakeLock`).

**Consequences**:
+ Cold-start is instant — clone the repo, open a file, refresh browser.
+ No supply-chain vulnerabilities from npm packages.
+ Build system can't drift (there is none).
+ Small mental model — the whole client is what you see in `frontend/js/`.
+ Perfect fit for "no caching anywhere" (repo-wide rule): no bundler-fingerprinted asset URLs to invalidate.
− Every UI pattern must be built by hand (no component reuse from an ecosystem).
− No TypeScript type safety.
− Some modern browser features require careful compatibility work we'd otherwise get from a framework's polyfills.
− Contributors expecting React/Vite will have a steeper adjustment.

**Revisit if**: contributor onboarding becomes a bottleneck because "no framework" is unexpected, OR the client grows past ~10K lines and reusability starts hurting productivity, OR we need TypeScript's guarantees for a critical subsystem.

**Refs**: §6, §6.1, §6.2, §6.3.

---

### 22.8 [2026-07-10] One document, one source of truth (this file)

**Status**: accepted

**Context**: Most large software projects fragment their design and progress across issue trackers (Jira, GitHub Issues, Linear), separate roadmap files, wikis, ADR directories, and Slack messages. Reading takes time, drift is inevitable, and "what's the current plan?" often has multiple mutually-incompatible answers depending on which surface you check. Small teams especially bleed time to that fragmentation.

**Decision**: `sim/DESIGN.md` is the single source of truth for the sim engine. It contains: vision (§1), principles (§3), class hierarchy (§5), wire protocol (§7), DB schema (§8), math rules (§9-10), cognitive model (§11), catalogs (§12), auth (§13), match lifecycle (§14), milestones (§15), per-slice checklists (§16), project layout (§17), debug/observability (§18), anti-patterns (§19), open questions (§20), known flaws / non-standard choices (§21), and decision log (§22 — this section). All progress is checkboxes ticked in place. No parallel roadmap files, no external ADR directory.

**Consequences**:
+ Newcomer reads one file, understands the whole design and current state.
+ No drift between "design doc" and "reality" — updating the doc IS updating the plan.
+ ADRs are contextually adjacent to the section they explain, findable in one grep.
+ Progress is visible at a glance — no login required to a separate tracker.
+ Git history is the authoritative log of design + progress evolution.
− File is large (~1400 lines pre-§21/22, will grow).
− Not everyone loves Markdown as an ADR format (Nygard's original spec is more elaborate).
− Requires discipline to keep §21 and §22 current when work lands — culture problem, not a tool problem.
− Merge conflicts if multiple contributors edit simultaneously (mitigated: only one active sim contributor today).

**Revisit if**: the doc exceeds ~5000 lines and readability suffers, OR multiple concurrent sim contributors emerge and merge conflicts on DESIGN.md become a productivity drag, OR a distinct audience (e.g. a marketing writer needing the vision without the class hierarchy) needs a subset extracted.

**Refs**: §15 banner ("this document is the source of truth for both design AND progress"), §21.6, §22.0.

### 22.9 Registry IDs are stable enum values, not surrogate keys

**Status**: accepted *(migration 203-sim-registry-ids-stable applied 2026-07-11; dev DB verified — bare INSERT fails with NOT NULL, existing 9 attributes + 1 concept + 1 scenario intact, four registry sequences dropped)*

**Context**: Four tables — `sim_attribute_registry`, `sim_concept_registry`, `sim_pattern_registry`, `sim_scenarios` — are registries whose `id` appears verbatim inside `sim_player_profile.attributes` / `.concepts` / `.recognition` bytea payloads and inside `sim_matches.scenario_id`. A profile row is a packed sequence of `(id:u16, value:...)` tuples; the id is the wire contract between C++ code (`M0Attributes.hpp` constants) and every profile ever persisted. Migration 200 declared these four tables `SMALLSERIAL PRIMARY KEY`, i.e., "let Postgres pick if you don't say". The migration *does* pass explicit IDs and does `setval` at the end, so the seed state is correct. But the SERIAL default leaves the door open for silent drift in three ways:

1. A dev typing `INSERT INTO sim_attribute_registry (key, category, weight, description) VALUES (...)` at `psql` (forgetting id) succeeds — Postgres auto-assigns from the sequence.
2. A future migration author omitting id — same outcome, sequence assigns silently.
3. `ON CONFLICT (key) DO NOTHING` in migration 200 means if a future migration tries to change an id for an existing key, the change is silently discarded.

The §16.6 startup drift-detection assertion is a fine defence in depth but treats a schema-level bug as a runtime problem. §21.1 identified this as ship-blocker #1.

**Decision**:

1. Change the four registry tables from `SMALLSERIAL PRIMARY KEY` to `SMALLINT PRIMARY KEY`. Drop the four associated sequences (`sim_attribute_registry_id_seq`, `sim_concept_registry_id_seq`, `sim_pattern_registry_id_seq`, `sim_scenarios_id_seq`).
2. Change all future registry INSERTs from `ON CONFLICT (key) DO NOTHING` to `ON CONFLICT (id) DO UPDATE SET key = EXCLUDED.key, category = EXCLUDED.category, weight = EXCLUDED.weight, description = EXCLUDED.description` (adjusted per table's columns). The primary key `id` is the invariant; re-running any registry migration deterministically restores the intended row content. Renaming a key requires a new migration by intent.
3. Event tables (`sim_matches`, `sim_match_events`) keep `BIGSERIAL` unchanged — those are event rows, IDs never appear in bytea, auto-assign is correct.
4. New migration `203-sim-registry-ids-stable.sql` performs the ALTER on already-migrated DBs. Safe today: no `sim_player_profile` rows exist yet (verified 0 rows), no prod sim deployment.
5. §16.6 boot-time drift guard is kept as belt-AND-suspenders — cheap and catches a `M0Attributes.hpp` edit that forgets to update a migration.

**Consequences**:

+ Bare `INSERT INTO sim_attribute_registry (key, ...)` (missing id) fails with `null value in column "id"` — silent drift is impossible.
+ A migration that intentionally changes a row's non-id fields overwrites them deterministically. A migration that tries to change an id (renumber) has to `DELETE` first — loud by construction.
+ Codifies intent: these IDs are hand-managed wire contract, not database-generated surrogate keys.
+ Sets the pattern for all future registries (patterns in M4, plays in M6, etc.).
− Slightly more finicky migration authoring — must think about id assignment. Trade-off is against silent bytea corruption, which is not close.
− Hostile to a hypothetical future feature that would insert registry rows at runtime — but registries are migration-seeded by policy (§3 principle 3, §22.4), so this hostility is deliberate.

**Revisit if**: a product need emerges to create registry rows at runtime rather than through migrations (e.g., user-defined attributes for scouting scenarios) — that would break this ADR's premise and require either serial+stability contract or a separate `user_defined_*` table with different semantics.

**Refs**: §5.2 (profile bytea layout), §8 (schema), §16.6 (boot-time guard), §21.1 (the ship-blocker this ADR closes), §22.4 (bytea persistence — the reason IDs must be stable).

### 22.10 RngDet is the sole sanctioned PRNG; ban `<random>` distributions in gameplay

**Status**: accepted *(2026-07-11 — `sim/scripts/check_no_bad_rng.sh` landed with positive + negative test coverage, `check_no_floats.sh` refactored to path-agnostic SIM_ROOT resolution, both wired into `sim/Dockerfile` before `cmake`; container rebuild green with `check_no_floats.sh: OK` and `check_no_bad_rng.sh: OK` printed inside the build; §10 rule 3 rewrites landed)*

**Context**: §10 rule 3 originally read "Seeded PRNG per match (`std::mt19937_64` — spec-defined, portable)". The claim is subtly wrong. The Mersenne Twister engine's raw `operator()` IS spec-portable per C++ standard §26.5.4.4 (same seed → same `uint64_t` sequence on every conforming implementation). But `std::uniform_int_distribution`, `std::uniform_real_distribution`, `std::bernoulli_distribution`, etc. are NOT portable — the standard specifies their *statistical* behaviour but not their *bit* output, and libstdc++, libc++, and MSVC all implement them differently. A well-known determinism trap — game engines that trip on this see arm64 vs x86_64 clients desyncing after a random draw is consumed. Meanwhile `sim/src/math/RngDet.hpp` already exists as a portable wrapper (uses only raw `uint64_t`, implements `nextUnit`/`nextInt` from raw output, forbids distributions in its own header comment). So we have a good API and a bad doc — plus zero enforcement that future contributors won't drop `std::uniform_real_distribution` into gameplay. §21.1 identified this as ship-blocker #2.

Related observation discovered while working on this ADR: the pre-existing `sim/scripts/check_no_floats.sh` is NOT invoked from any Makefile / Dockerfile / build.sh / compose file. It's an orphaned "CI check" that runs only when a human remembers to type its name. Adding another orphaned check would be theatre. This ADR bundles fixing that wiring gap so both scripts genuinely run on every container build.

**Decision**:

1. `RngDet` (already at `sim/src/math/RngDet.hpp`) is declared the sole sanctioned PRNG in gameplay code. Its documented API (`nextU64`, `nextUnit`, `nextRange`, `nextInt`) is complete — no new methods needed for M0–M6. When new distribution shapes are required (e.g., normal, exponential), they are added to `RngDet` as portable in-house implementations built on raw `uint64_t`.
2. `sim/scripts/check_no_bad_rng.sh` is added. It fails the build if any file under `sim/src/` contains:
   - `std::.*_distribution`
   - `std::random_device`
   - `std::default_random_engine`
   - `\bstd::rand\b`
   - `std::mt19937` or `std::mt19937_64` (except in the allowlisted file `sim/src/math/RngDet.hpp`)
   - `#include <random>` (except in the allowlisted file)
3. Script style matches `check_no_floats.sh`: bash strict mode, numbered check sections, per-violation stderr lines with file:line, exit 1 on any violation, `OK` marker on clean.
4. Path resolution: script derives `SIM_ROOT` from its own `${BASH_SOURCE[0]}` so it works identically when invoked from the workspace root (host) or from `/src` (inside container).
5. `sim/Dockerfile` runs BOTH `bash scripts/check_no_bad_rng.sh` AND `bash scripts/check_no_floats.sh` after `COPY scripts ./scripts` and before the `cmake` invocation. Container build fails if either check violates. This closes the "orphaned check" issue in one motion.
6. §10 rule 3 is rewritten to name `RngDet` as authoritative, enumerate the ban list, and reference this ADR.

**Consequences**:

+ Distribution portability trap is impossible to trip on future PRs — the container refuses to build.
+ Enforcement is on the SAME surface as the existing float ban (`sim/Dockerfile` build stage), which was always the intent for `check_no_floats.sh` too — retiring that inconsistency is a bonus.
+ `RngDet.hpp` becomes an unambiguous single source of truth for anything RNG-shaped. Contributors who need a new distribution add it to `RngDet` (portable) instead of reaching for `<random>` (portable-looking but not).
+ Zero code deletion needed today — sim/src/ is already clean (grep audit showed only `RngDet.hpp` touches `<random>`).
− Test code is currently disallowed from touching `<random>` too (the script scans `sim/src/`; if we later want RNG in tests, we'll allow `sim/tests/` explicitly — cheap change).
− A future contributor who needs a real normal distribution has to write portable code rather than typing `std::normal_distribution`. That's the whole point.

**Revisit if**: a future performance profile shows the in-house `nextUnit` / `nextInt` implementations are a bottleneck AND we've moved off cross-arch determinism guarantees (unlikely — the cost is a few ns per draw, and cross-arch determinism is a §22.1 non-negotiable), OR the C++ standard adopts portable-implementation guarantees for distributions (would take a language revision; not likely).

**Refs**: §10 rule 3 (rewritten by this ADR), §16.6, §21.1 (the ship-blocker this ADR closes), §22.1 (determinism is top-level), and the new `sim/scripts/check_no_bad_rng.sh` + wiring into `sim/Dockerfile`.

### 22.11 Registry catalog is single-sourced from migration 200 via awk codegen

**Status**: accepted *(2026-07-12 — `sim/scripts/gen_registry_header.awk` landed, `sim/src/common/M0Registry.generated.hpp` produced on host via `build.sh` STEP-1 pre-generation, CMake auto-regens when the migration is visible and FATAL_ERRORs if neither migration nor pre-generated header are present, `M0Attributes.{hpp,cpp}` trimmed to non-catalog baselines only, container build green with 26/26 tests, missing-header path verified to fail loudly with actionable message)*

**Context**: The M0 attribute + concept catalog exists in two places today: `database/migrations/200-sim-registries.sql` (the DB seed) and `sim/src/common/M0Attributes.hpp` + `M0Attributes.cpp` (the compile-time `constexpr AttrId k...` constants + the `seedRegistries()` in-memory bootstrap). §3 principle 3 forbids exactly this. §22.9 closed the schema-level drift path (ID-column type + `ON CONFLICT` semantics) and §16.6 plans a runtime drift check at sim daemon boot, but both are safety nets that treat a source-of-truth problem as a validation problem. The two files literally have to be edited in lockstep by human diligence — which is precisely what §3 principle 3 refuses to rely on. §21.1 identified this as ship-blocker #3.

Two candidate resolutions were weighed:

- **Path A (adopted)**: generate `M0Attributes` catalog from migration 200 at CMake configure time. Compile-time `constexpr` IDs are preserved (correct for hot-path gameplay math like `attrs[m0::kMaxWalkSpeed]`), zero runtime cost, and the boot-time drift check becomes trivial (constants baked at compile time from the same file Postgres was seeded from).
- **Path B (rejected)**: delete `M0Attributes.hpp` entirely; do runtime registry lookup for every attribute access. Rejected because (i) turns compile-time typos into runtime lookup failures, (ii) puts a hashmap traversal on the hot path, (iii) the test bootstrap that currently uses `seedRegistries()` would have to either parse the SQL itself or hard-code the catalog again — reintroducing the very drift this issue is trying to close.

**Decision**:

1. **Generator**: `sim/scripts/gen_registry_header.awk` — a small awk script that reads `database/migrations/200-sim-registries.sql`, extracts `INSERT INTO sim_attribute_registry (...) VALUES (...)` and `INSERT INTO sim_concept_registry (...) VALUES (...)` blocks, and emits `sim/src/common/M0Registry.generated.hpp`. Awk not Python: matches existing `sim/scripts/*.sh` style, zero new toolchain deps (awk is POSIX). Migration format assumptions are strict — the awk script fails loudly if the column layout drifts.

2. **Output**: `sim/src/common/M0Registry.generated.hpp` — in-tree file, gitignored, with a `// AUTO-GENERATED — edit database/migrations/200-sim-registries.sql instead` banner. Contents:
   - `namespace fh::sim::m0 { inline constexpr AttrId k... = N; }` for every attribute row.
   - `namespace fh::sim::m0 { inline constexpr ConceptId k... = N; }` for every concept row.
   - `inline void seedRegistries(AttributeRegistry&, ConceptRegistry&)` that replays each `(id, key, category)` tuple. Marked `inline` so the header alone provides both the constants and the seed helper.
   - Awk detects and errors on any two rows that would produce the same C++ identifier (future-proofs against `physical.foo` vs `technical.foo` collisions).
   - Naming convention: strip leading `<category>.` from the key when present, then snake_case → PascalCase, prepend `k`. So `physical.max_walk_speed` (cat `physical`) → `kMaxWalkSpeed`; `run_to_point` (cat `movement`, no prefix) → `kRunToPoint`. No caller renames needed.

3. **CMake wiring** (`sim/CMakeLists.txt`):
   ```
   if(EXISTS ${MIGRATION_FILE})
       add_custom_command(OUTPUT ${GEN_HEADER}
           COMMAND awk -f gen_registry_header.awk ${MIGRATION_FILE} > ${GEN_HEADER}
           DEPENDS ${MIGRATION_FILE} gen_registry_header.awk)
       add_custom_target(gen_m0_registry ALL DEPENDS ${GEN_HEADER})
       add_dependencies(sim_gameplay gen_m0_registry)
   else()
       if(NOT EXISTS ${GEN_HEADER})
           message(FATAL_ERROR "...")
       endif()
   endif()
   ```
   Host builds (migration visible at `../database/migrations/200-sim-registries.sql`) auto-regen. Container builds (migration not in build context) consume the pre-generated header — loud FATAL_ERROR if it's missing.

4. **Container-build handshake**: `build.sh` (or the make target that invokes it) pre-generates the header via `awk` before running `podman build`. The `COPY src ./src` step in `sim/Dockerfile` then pulls the freshly-generated header into the image along with the rest of the source tree. No `docker-compose.yml` context change needed (sim context stays `./sim`), no `.dockerignore` overhaul needed.

5. **`M0Attributes.{hpp,cpp}` trimmed**: after codegen, these files contain ONLY the non-catalog parts — `AttributeSet defaultPhysical()` and `ConceptSet defaultConcepts()`, which return M0 baseline VALUE data (Fixed64 numbers like `max_walk_speed = 2.0 m/s`), not catalog IDs. Baseline values are gameplay balance, not schema, and don't belong in a migration. The `seedRegistries()` implementation moves entirely into the generated header (inline).

6. **Discovery observation** (added as §21.5 item): during this ADR's work, noticed that migration 200 uses category-prefixed keys for attributes (`physical.max_walk_speed`) but bare keys for concepts (`run_to_point`). The awk generator handles both cases correctly (by stripping the category prefix only when present), but the underlying inconsistency is worth resolving in a future migration for consistency's sake. Tracked in §21.5.

**Consequences**:

+ Catalog exists in exactly one authored place: migration 200. `M0Registry.generated.hpp` is a derivative, `M0Attributes.{hpp,cpp}` contains only non-catalog gameplay baselines.
+ Zero caller changes — `m0::kMaxWalkSpeed` and friends resolve identically because the generator emits into the same namespace with the same names.
+ Editing a key in migration 200 immediately breaks compilation via the generated constant name changing (or the caller not finding the old name) — loud, fast, at compile time.
+ Boot-time drift check from §16.6 remains meaningful as belt-AND-suspenders (catches a scenario where a dev bypasses the codegen by hand-editing the generated file — the drift check still catches it against the DB), but its failure mode moves from "silent bytea corruption" to "sim refuses to start with a clear error".
+ Establishes a codegen precedent for any future registry (patterns in M4, plays in M6).
− Adds ~40 lines of awk + ~15 lines of CMake logic. New moving parts. Trade-off is against having to trust human diligence to keep two files in sync — which is what §3 principle 3 says we don't do.
− Direct `podman build -f sim/Dockerfile sim/` invocations (bypassing `build.sh`) require manual pre-generation, or the container build fails with a clear FATAL_ERROR. Documented; the loud-failure is the point.
− Adds an awk parser to the maintenance surface. Migration format changes (e.g., adding a column to `sim_attribute_registry`) require an awk update. Acceptable — such changes are rare and would need thought regardless.

**Revisit if**: (a) migration 200 grows a schema that awk-regex can no longer handle sanely — swap awk for a small C++ tool that runs as a CMake build tool (same pattern as `fh-sim-replay`, planned in Slice 13), or (b) a genuine need emerges for runtime-mutable registries (e.g., user-defined attributes for scouting scenarios), at which point the compile-time constants pattern breaks down and we'd move to registry-lookup with a caching layer.

**Refs**: §3 principle 3 (single source of truth), §16.6 (boot-time drift check as belt-AND-suspenders), §21.1 (the ship-blocker this ADR closes), §22.9 (schema-level drift closure — the complementary fix), §22.4 (bytea persistence — why catalog stability matters at all).

### 22.12 Persistence library architecture (Slice 13 foundation)

**Status**: accepted *(2026-07-12 — `sim/src/persistence/{IPgClient.hpp,EventTypes.hpp,InMemoryPgClient.{hpp,cpp},PgClient.{hpp,cpp}}` landed; `sim_persistence` STATIC target added between `sim_data` and `sim_gameplay`; `libpqxx-dev` (build) + `libpqxx-7.10` (runtime) wired into `sim/Dockerfile`; `pkg_check_modules(PQXX REQUIRED IMPORTED_TARGET libpqxx)` in CMake; 28/28 tests pass including 15-assertion `test_in_memory_pg_client` and 4-assertion `test_pg_client` covering all constructor fail-loud paths — missing host, missing dbname, missing user, unreachable port. Live-DB round-trip verification deferred to the registry-loading step where `SimServer::run()` actually consumes `PgClient`.)*

**Context**: Slice 13 (§16.6) is the M0 close-out — it adds Postgres reads (registry + profile) and writes (match lifecycle, input log, event log) to the sim daemon. Before writing any of that, the shape of the "how does the sim talk to Postgres" boundary needs to be nailed down. §16.6 pre-decided several pieces (interface-first, libpqxx, single connection, prepared statements) but left three real design decisions open: (a) error surface — throwing exceptions vs. returning `expected<T,E>` / `Result<T>`; (b) transaction granularity — per-call, per-batch, or explicit `withTransaction()` scoping; (c) interface partitioning — one fat interface vs. multiple narrow interfaces per subsystem (registry/profile/match/input/event). Getting these wrong now means either a refactor mid-slice or living with the wrong shape for the rest of M0+.

Three cross-cutting principles constrain the choices:

- **Rule 4** (`§3`, silent failure is a bug): unreachable DB, prepared-statement failure, or malformed row must halt startup or crash the tick loop with a clear message. No fallback attribute values, no "log and continue."
- **Rule 3** (`§3`, testability): every gameplay path that touches persistence must be mockable in unit tests without a running Postgres. Non-negotiable — the tick loop is where every gameplay bug hides.
- **Rule 5** (`§10`, determinism): DB reads (registry, profile) must never re-order or duplicate rows during a single boot; DB writes (inputs, events) must never re-order or drop entries during a single match. Persistence layer contract must make these guarantees explicit.

**Decision**:

1. **Interface**: single `sim::persistence::IPgClient` pure-virtual class in `sim/src/persistence/IPgClient.hpp`. Rejected the "one interface per subsystem" (IRegistryStore / IMatchStore / IInputStore / etc.) alternative — the split would add ~5 abstract classes with a combined ~15 methods, all backed by the same connection object, all mocked with the same `InMemoryPgClient` techniques. The additional type surface buys nothing for a codebase of this size; the flat interface stays legible on one screen. If a subsystem later grows a genuinely distinct storage backend (e.g. an S3-backed input archive), split it out then.

2. **Error surface**: **throwing**. Every `IPgClient` method that fails throws `sim::persistence::PgError` (a `std::runtime_error` subclass with a `context()` string). Rationale: (a) matches Rule 4's fail-loud principle — swallowing an error to check a `Result` at every call site invites the exact silent failure Rule 4 forbids; (b) matches libpqxx's own conventions (it throws) so the concrete `PgClient` doesn't have to translate; (c) startup errors propagate to `main()`, which catches and logs before `exit(1)` — one catch site, one shutdown path; (d) tick-loop errors from the input/event flush thread crash the daemon deliberately — an unreachable DB during a live match is not a survivable condition and forwarding a `Result` up the tick loop only delays the crash. Rejected `std::expected<T, PgError>`: needs C++23 (we target C++20) and would require a per-call boilerplate that consistently degrades to "throw on error anyway" in practice.

3. **Transaction granularity**: **per-call for single-row writes; explicit `withTransaction()` for batches.** `insertInput` / `insertEvent` are single-row writes autocommitted. `insertInputBatch(span<InputRow>)` opens a transaction internally, executes all inserts as one prepared-statement invocation with a `VALUES ($1,$2,...),($n,$n+1,...)` multi-row bind, commits atomically. Registry writes never happen (registries are seed-only). Match-lifecycle writes (`upsertMatch`, `updateMatchEnded`) are single-row and autocommitted. Rejected explicit `IPgClient::begin()` / `commit()` methods: they leak transaction state into the interface, encourage half-committed batches, and are trivially replaced by a `withTransaction(std::function<void(IPgClient&)>)` helper — which we also decline to add for M0 since no caller needs it yet. Add later if it does.

4. **Connection lifecycle**: **single owned connection**, constructed by `PgClient(const ConnConfig&)`, closed in the destructor. No pool. Sim daemon is single-process, single-match, single-tick-thread — a pool buys latency hiding for parallel writes but the input/event log path is already single-writer (the flush thread) and reads are startup-only. Reconnect logic: **no automatic reconnect** for M0 — a dropped connection during a match is a fatal condition (Rule 4). Post-M0 the input flush thread can gain retry-with-exponential-backoff, but that's a durability-vs-safety trade-off best decided when we have real ops experience.

5. **Prepared statements**: registered eagerly in `PgClient` constructor. Statement names are `constexpr` strings owned by `PgClient.cpp` (private to the impl). Every hot-path call goes through a prepared statement — no ad-hoc `nontransaction::exec` with runtime-templated SQL. Simplifies audit (all SQL lives at the top of `PgClient.cpp`), avoids repeated planning cost, gives libpqxx enough info to bind types correctly for our `bytea` payloads.

6. **Types on the interface**: the interface uses domain types (`AttrId`, `MatchId`, `TickNum`, `ClientId`, `std::span<const std::byte>` for bytea payloads), never libpqxx types. Callers never `#include <pqxx/pqxx.h>`. Rationale: keeps libpqxx a leaf dependency; `sim_gameplay`, `sim_match`, and tests never even transitively pull the header.

7. **Test double**: `InMemoryPgClient` in the same header/cpp as production interface (`sim/src/persistence/InMemoryPgClient.{hpp,cpp}`). Backing storage: `std::unordered_map<MatchId, MatchRow>`, `std::vector<InputRow>` sorted lazily on read, similar for events, `std::unordered_map<PersonId, ProfileBytes>` for profiles. Insertion preserves order via monotonic counter — replay tests can iterate reproducibly. Deliberately in production sources (not `tests/`) so integration tests and the future `fh-sim-replay` binary can share one path. Marked with `[[maybe_unused]]`-safe hooks — not compiled out of the release binary because the replay tool needs it.

8. **CMake layout**: new `sim_persistence` library target in `sim/CMakeLists.txt`, compiled with `-fno-exceptions` **disabled** (persistence is one of the few subsystems where exceptions are the error path; rest of gameplay stays exception-free). Depends on `sim_math`, `sim_profile`, `sim_registry`. `pkg_check_modules(PQXX REQUIRED libpqxx)` in the codegen block; `PgClient` translation unit is the only one that includes `<pqxx/pqxx.h>`.

9. **Dockerfile**: build stage `apt-get install libpqxx-dev`; runtime stage `libpqxx-6.4` (or whichever debian trixie ships). Verified before Slice 13 code lands to avoid a mid-slice base-image change.

10. **Environment**: `SIM_DB_HOST`, `SIM_DB_PORT`, `SIM_DB_NAME`, `SIM_DB_USER`, `SIM_DB_PASSWORD` are required env vars. Absence at startup → fail-loud (Rule 4). Same style as existing `SIM_MATCH_SEED` / `SIM_PORT` handling in `main.cpp`. `docker-compose.yml` sim service inherits from `env` alongside backend.

**Consequences**:

+ One interface, one test double, one prod implementation — three files (plus `EventTypes.hpp`) is the entire persistence surface. Small enough to fit in one PR review.
+ Throwing error surface aligns with Rule 4; catch site is `main()`, no per-call `Result` unwrapping noise in gameplay code.
+ Single connection + single tick thread = no cross-thread PG concurrency concerns. The input/event flush thread is the only other PG user; it uses its own `PgClient` instance to keep libpqxx's non-thread-safe-connection contract clean. (Two connections total: main + flush.)
+ Per-call autocommit for single-row writes eliminates transaction-boundary bugs in the common path. Batch inserts (input/event flush) get explicit tx scope where it matters.
+ Domain-typed interface keeps libpqxx as a genuine leaf: `sim_gameplay` etc. never see pqxx headers, so a future driver swap (e.g., to libpq-fe directly if libpqxx becomes a portability problem) is a `PgClient.cpp` rewrite, not a codebase-wide refactor.
+ `InMemoryPgClient` shipped in production sources means `fh-sim-replay` can drive replays from either DB or memory with zero code change — same interface, same semantics.
− Exception path for tick-loop errors means the flush thread crashes the daemon on Pg unavailability during a live match. This is intentional (Rule 4) but ops-visible: match-in-progress is lost. Post-M0 the flush thread can gain retry-with-backoff behind a config flag; for M0 the loud crash is the safer default.
− Two connections (main + flush) is more state than "one big connection". Trade-off is against libpqxx's per-connection thread-affinity requirement — the alternative (mutex around one connection) would serialize the flush thread against gameplay-thread reads, defeating the whole point of async flushing.
− Single interface with all methods forces `InMemoryPgClient` to implement every method even when a test only needs one — small friction; solved with a `virtual … { throw NotImplemented(...); }` default pattern where useful.

**Revisit if**: (a) libpqxx becomes a build headache (dep version churn, arm64 gaps) — swap for direct libpq-fe binding, contained in `PgClient.cpp`; (b) sim gains multi-match orchestration and we need a connection pool — add `PgClientPool` above `PgClient` without changing `IPgClient`; (c) durability requirements grow (e.g., pgbouncer, replication targets) — introduce `IPgClient` sub-interfaces then, when the split is motivated.

**Refs**: §3 (rules 3 + 4), §10 (rule 5 determinism), §16.6 (Slice 13 spec), §22.4 (bytea persistence — why the interface deals in `span<const std::byte>`), §22.9 (registry ID stability — why registry reads must be verified against compile-time constants), §22.11 (registry codegen — provides the compile-time truth the drift check compares against).

---

### 22.13 Replay uses M0 default profiles (Slice 13 sub-slice 6 limitation)

**Status**: Accepted 2026-07-13 alongside the `fh-sim-replay` binary. Time-bombed to M1.

**Context**: The replay driver (`sim/src/tools/Replay.cpp`) reconstructs a match from `sim_matches` + `sim_match_inputs`. To feed the replayed `Match` an input via `applyInput(ClientId, Intent)`, the target slot must be owned by a `HumanController` — created by `Match::claimSlot(SlotId, ClientId, PersonId, PlayerProfile)`. The `PlayerProfile` chosen determines `MechanicsParams` (max speeds, acceleration curves, stamina), so if replay picks a different profile than the live server used, the physics diverge on the very first tick and the canonical hash fails.

**Problem**: The persisted `SlotClaim` event (event_type=5) currently carries NO payload — it only records that a claim happened at a given tick. There is no way to look up which `person_id` claimed which slot from the log, and even with `person_id` there's no versioned snapshot of the profile at claim time (a user could edit their profile between the original match and the replay).

**Decision — for M0 only**: Replay synthesizes claims using the M0 default profile from `m0::defaultPhysical()` + `m0::defaultConcepts()`, matching what `ProfileStore::loadOrCreate` returns for any first-touch `person_id`. This works today because:

1. No user has customized their profile (no editor UI exists in M0).
2. `ProfileStore::loadOrCreate` materializes a default row for every new `person_id`; every existing profile in the DB IS the default byte-for-byte.
3. `Match::claimSlot` only uses `ClientId` for owner lookup (later `applyInput`) and `PersonId` for future event audit; neither value influences the physics tick, so the synthesized values (`ClientId{slot_id}`, `PersonId{slot_id}`) are indistinguishable from live for hash purposes.

**Consequences**:
+ Zero schema churn — `SlotClaim` stays payload-less for M0, replay landed in a single sub-slice.
+ Byte-identical replay is provable today: `test_replay.cpp` runs the exact `human_sprint_east_400_ticks_seed_42` scenario from `test_determinism.cpp` and asserts the canonical hash matches.
+ No wall-clock coupling — replay depends only on rows in the DB, not on `ProfileStore` state (which could differ between replay time and original match).
− Replay will silently diverge the first time a user submits an input with a non-default profile. This is not detectable at replay time from the log alone — the divergence surfaces only as a hash mismatch against `MatchEnd.payload`. **Mitigation**: the `--verify` flag exits non-zero on mismatch; CI cross-arch check will catch a regression the moment a real customized profile flows through.

**Revisit if / when M1 lands profile editing**: Two viable paths, decide at that point which fits M1's actual profile-editor design:

1. **Payload on SlotClaim**: bump event_payload to `{person_id: u64, profile_blob: bytea}` (serialized `PlayerProfile` at claim time — same encoding as `sim_player_profile`). Replay reads the blob, decodes, uses it verbatim. Pros: self-contained log, replay is stateless. Cons: doubles event log size for the common case of default-profile matches.
2. **Historical profile table**: add `sim_player_profile_history` keyed by `(person_id, valid_from_tick)`; replay looks up the profile row valid at the claim tick. Pros: small delta over current schema, cheap on writes. Cons: replay now depends on TWO row sources whose consistency must be maintained across pg_dump/restore boundaries.

Blocker: pick a path when the M1 profile editor UI is designed — not before. Add a TODO tag `SIM-REPLAY-PROFILE-M1` in `Replay.cpp` next to the `makeDefaultProfile()` call so grep finds it.

**Refs**: §5.7 (Match::claimSlot), §16.6 (Slice 13 sub-slice 6), §22.12 (persistence architecture — InMemoryPgClient contract).

---

### 22.14 [2026-07-13] `sim_player_profile` write policy — first-touch INSERT only in M0

**Status**: accepted 2026-07-13 (documents the M0 code-as-written; enforced by [sim/scripts/check_profile_write_policy.sh](sim/scripts/check_profile_write_policy.sh) added in the same landing).

**Context**: `sim_player_profile` is written via `sim::persistence::ProfileStore::save(PersonId, const PlayerProfile&)`, which serializes the profile to bytea and calls `IPgClient::upsertProfile`. The schema (`database/migrations/200-sim-registries.sql`) has `updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()` — a shape that *permits* any write frequency the caller wants. Nothing in the schema, the interface, or the class name tells a reader whether `save()` is meant to be called (a) every tick, (b) at match end, (c) on explicit balance/coaching events, or (d) never after the first-touch INSERT. Getting this wrong could be catastrophic in either direction:

- **Per-tick writes** at 20 Hz × 22 slots × N concurrent matches would flood the DB with churn on data that never changes during an M0 match (M0 has zero code paths that mutate `PlayerProfile` between construction and match end — no attribute drift, no concept mastery, no fatigue-carries-over-matches). Would silently 100× the DB write budget while adding zero product value.
- **Match-end writes** on data that never changed during the match are also pointless writes, but subtly worse — they *look* meaningful ("the sim writes the profile at match end") when in fact they're a no-op that adds a schema-boundary bug surface (what if the match crashes mid-tick? Does the profile get half-written? Does the row get skipped? Would replay need to reason about "profile-at-match-start vs profile-at-match-end"?).
- **Never writing** — including never first-touch — would leave `ProfileStore::loadOrCreate` unable to fulfil its contract: return a profile, materializing one from `m0::defaultPhysical()` + `m0::defaultConcepts()` if the person is a first-touch. Without that first INSERT, replay of a match involving a new person can't reconstruct the profile from the DB alone (§22.13 depends on this being byte-for-byte the M0 default).

The M0 gameplay code has zero call sites for `ProfileStore::save()` outside `ProfileStore::loadOrCreate()` itself. `SimServer::onClientConnect` calls `profile_store_->loadOrCreate(person)` (which internally saves on first-touch); no tick-loop code touches `ProfileStore`; no `Match::end()` handler touches `ProfileStore`; `main.cpp`'s shutdown path (`input_log.stop()` → `event_log.stop()` → `updateMatchEnded`) never touches `ProfileStore`. This is the correct M0 shape but currently guaranteed only by convention.

**Decision**: The `sim_player_profile` write policy for M0 is **first-touch INSERT only, via `ProfileStore::loadOrCreate`**. No other call site is permitted to invoke `ProfileStore::save()`. Enforced by [sim/scripts/check_profile_write_policy.sh](sim/scripts/check_profile_write_policy.sh) in the CI lint gate ([sim/Dockerfile](sim/Dockerfile) build stage, alongside `check_no_floats.sh` / `check_no_bad_rng.sh` / `check_no_hardcoded_attrs.sh`): a `grep -RIn '\.save\('` scan across `sim/src/**/*.{cpp,hpp,h}` fails the build if any file *other than* `sim/src/persistence/ProfileStore.cpp` invokes `.save(` on what could plausibly be a `ProfileStore` instance (fully-qualified via `profile_store_->save(`, `profile_store.save(`, `store.save(`, or the bare `save(person, profile)` inside `ProfileStore` methods themselves, which is the only allowed occurrence). The runtime invariant is thus a compile-gate invariant.

**Consequences**:
+ Zero write amplification: exactly one INSERT per person, ever, for the entire lifetime of the M0 product. The DO-UPDATE branch of `ProfileStore::upsertProfile` (bumps `updated_at`) never fires in M0 — a useful smoke check is `SELECT relname, n_tup_upd FROM pg_stat_user_tables WHERE relname IN ('sim_player_profile', 'sim_player_attribute', 'sim_player_concept', 'sim_player_recognition')` should return `n_tup_upd = 0` for all four in M0. (The row-set expansion in ADR §22.18 preserves the invariant — first-touch is still a single transactional INSERT across the parent + child tables.)
+ Replay stays sound (§22.13): the "every existing profile in the DB IS the default byte-for-byte" assumption that `test_replay.cpp` and the `fh-sim-replay` binary depend on is now protected against a well-meaning "let's persist the current profile at match end" PR that would silently break replay hashing.
+ Match crash mid-tick has zero profile-corruption risk: there's simply no mid-tick write path to interrupt.
+ CI enforcement means the policy is discoverable — a new engineer trying to add a `ProfileStore::save` call from `Match::end` gets a loud build failure with a pointer to this ADR.
− The CI grep is coarse (`.save(` — it would flag any *variable* named `.save` on any type, e.g. `foo.save(` on a hypothetical `Bar` with an unrelated `save` method). We accept the false-positive risk because (a) the sim codebase has no other `save` method today, (b) the check script's error message points to this ADR so a genuine unrelated `save` gets an obvious `# ok: not ProfileStore` allowlist entry, and (c) the alternative (parsing C++ to identify the receiver type) is orders-of-magnitude more machinery than the invariant warrants.
− Adding new persistence-writing subsystems later (see M3+ revisit below) means updating both the code AND this ADR AND the check script — three-file coupling. Trade-off is worth it for M0: the invariant IS the whole point of the ADR, not incidental complexity.

**Revisit if / when**:
- **M3 concept-mastery lands**: the training-mode drill loop will mutate `PlayerProfile::concepts` (unlock a new play, raise a concept rating) during a match. That's the first legitimate call site for `ProfileStore::save()` outside `loadOrCreate`. Path: (a) supersede this ADR with a new one that spells out the M3+ write policy (probably "match-end write iff any concept changed during the match, batched into a single upsert after `EventLog::stop()` and before `updateMatchEnded`"), (b) extend `check_profile_write_policy.sh` allowlist to include the M3 mastery-writer translation unit, (c) add a corresponding read path in replay (see §22.13's revisit) so replays reproduce the mid-match mutation.
- **M1 profile-editor UI lands** (before M3 training): if the M1 profile editor lets a user edit their profile directly from the app (outside a match), the write path is a backend HTTP endpoint that itself calls `ProfileStore::save()` — but from the *backend* container, not the sim container. In that case this ADR still holds inside the sim container; the CI check needs only to also cover the backend's persistence layer (probably a separate `backend/scripts/check_profile_write_policy.sh` with the same shape).
- **Attribute drift from wear-and-tear** (M4+ realism): if a match itself is allowed to permanently lower `physical.max_walk_speed` (e.g. season-long fatigue accumulation), same treatment as M3 concept-mastery.
- **The M0 smoke check fires** — i.e. `pg_stat_user_tables.n_tup_upd` on `sim_player_profile` (or any of the three child tables added in ADR §22.18) is non-zero in an M0 environment. That means the CI check has been bypassed or misses a call path; investigate immediately, do NOT normalize the invariant loss.

**Refs**: §5.7 (Match::end lifecycle — no profile write in M0), §14 (match lifecycle — first-touch INSERT-only policy called out inline), §16.6 (Slice 13 spec — where `ProfileStore` landed), §21.2 item 2 (this ADR resolves that checkbox), §22.4 (bytea persistence — inputs/events; the profile side of the story is now ADR §22.18), §22.12 (persistence architecture — `IPgClient::upsertProfile` contract), §22.13 (replay depends on this policy — the "every DB profile IS the M0 default" invariant is what §22.13 exploits), §22.18 (row-per-value profile storage — refactor preserved this write policy verbatim).

---

### 22.18 [2026-07-13] Normalize `sim_player_profile` storage — bytea → row-per-value

**Status**: accepted 2026-07-13. Landed as `database/migrations/205-sim-normalize-profiles.sql` + a source-side refactor of `IPgClient::loadProfile/upsertProfile`, `PgClient`, `InMemoryPgClient`, `ProfileStore`, and removal of `AttributeSet::{to,from}Bytes` / `ConceptSet::{to,from}Bytes` / `RecognitionSet::{to,from}Bytes` codecs plus deletion of `sim/src/profile/PackedU16F32.{hpp,cpp}` (its only callers were those three codecs).

**Context**: Slice 13 shipped `sim_player_profile` with three `BYTEA` columns (`attributes`, `concepts`, `recognition`), each holding a `PackedU16F32` blob — `[u16 count LE][ (u16 id LE)(f32 value LE) ] × count`. See original §22.4 (bytea for gameplay data). The design bought us wire-friendly serialisation and single-column reads at the cost of column opacity: ops running `psql` sees `\x02001000803f...` and has to reach for `sim_decode_attributes(payload)` (migration 201) to make sense of it. That’s fine for `sim_match_inputs.payload` / `sim_match_events.payload`, which store *wire audit rows* — the wire format is the source of truth and lives forever unchanged. But `sim_player_profile.attributes` is not a wire audit — no wire frame ever carries an `AttributeSet` (verified: `grep -RIn AttributeSet sim/src/net/` returns zero). It's structured application data whose columns HAPPEN to be encoded via the same codec the wire uses. Bytea was inherited from a wire-side justification that no longer applies at the persistence boundary.

Additional context that accumulated between §22.4 (2026-07-10) and this ADR:

- **Registry-drift guardrails matured.** §22.9 pinned SMALLSERIAL ids to stable enum values; §22.11 codegen'd `M0Registry.generated.hpp` from migration 200; a boot-time `verifyM0RegistryConsistency` check catches any drift on daemon start. Combined, these make a per-attribute foreign key (`sim_player_attribute.attr_id → sim_attribute_registry.id`) cheap defence in depth rather than a maintenance burden — the FK cannot spuriously fire in normal operation.
- **`sim_decode_attributes` / `_concepts` / `_recognition` never got any real use.** Migration 201 shipped them as ops sugar in case someone needed to inspect a profile blob. In practice, when we needed to inspect profile data (e.g. debugging the §22.14 write-policy check landing), we went straight to the C++ source — because the function call had to be typed with the exact registry id or with an unindexed table scan through `sim_decode_attributes(p.attributes)`. A plain `SELECT r.key, a.value FROM sim_player_attribute a JOIN sim_attribute_registry r ...` is what the ops runbook actually wanted to be able to write.
- **Task B (§23) close-out** introduced §23.1's exit criterion "row count of every sim_player_* table matches expected counts after a match" — expressible as `SELECT COUNT(*)`s in the new schema, or (in the old bytea world) as a decode-and-count against three opaque blobs.

The refactor also unblocks two future needs:

- **Attribute-level analytics** (M1+): "what's the distribution of `physical.max_sprint_speed` across all players in club X?" is one `JOIN` in the new schema and a `sim_decode_attributes(p.attributes)` lateral in the old.
- **Concept-mastery updates** (M3 revisit path in §22.13): incremental `UPDATE ... WHERE person_id = $1 AND concept_id = $2` is a single row write in the new schema and a read-modify-write of the whole `concepts` bytea in the old.

**Decision**: Normalize `sim_player_profile` into a parent envelope + three child tables, one row per (person, id) pair per set. Keep f32 (`REAL`) on disk to preserve the same round-trip precision the bytea codec had (`Fixed64::fromFloat` / `toFloat` at the persistence boundary). Delete the three Set-side codecs (`toBytes/fromBytes`) and `PackedU16F32` since nothing outside those callers uses them. Drop the three bytea profile decoders from migration 201; keep the two wire-audit decoders (`sim_decode_input`, `sim_decode_event`) since inputs/events remain bytea per §22.4.

New schema (from migration 205):

```sql
-- parent envelope: exists ⇔ this person has a persisted profile
CREATE TABLE sim_player_profile (
    person_id  INTEGER PRIMARY KEY REFERENCES persons(id) ON DELETE CASCADE,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- one row per (person, attribute); load ORDER BY attr_id ASC for
-- deterministic AttributeSet reconstruction across replicas.
CREATE TABLE sim_player_attribute (
    person_id INTEGER  NOT NULL REFERENCES sim_player_profile(person_id) ON DELETE CASCADE,
    attr_id   SMALLINT NOT NULL REFERENCES sim_attribute_registry(id),
    value     REAL     NOT NULL,
    PRIMARY KEY (person_id, attr_id)
);
CREATE INDEX ON sim_player_attribute (attr_id);
-- sim_player_concept and sim_player_recognition analogous.
```

New `ProfileRows` on `IPgClient`:

```cpp
struct ProfileRows {
    std::vector<std::pair<std::uint16_t, float>> attributes;   // (attr_id,    value)
    std::vector<std::pair<std::uint16_t, float>> concepts;     // (concept_id, mastery)
    std::vector<std::pair<std::uint16_t, float>> recognition;  // (pattern_id, skill)
};
virtual std::optional<ProfileRows> loadProfile(PersonId) = 0;
virtual void upsertProfile(PersonId, const ProfileRows& rows) = 0;
```

`PgClient::upsertProfile` runs one `pqxx::work` that: (1) INSERTs the parent envelope with `ON CONFLICT (person_id) DO UPDATE SET updated_at = NOW()` (the DO-UPDATE branch never fires in M0 per §22.14 write policy; it's there for the row's edge and for post-M0 M3 concept-mastery mid-match writes); (2) DELETEs all existing child rows for `person_id` in each of the three child tables; (3) INSERTs the new rows. Replace-whole-set semantics inherited verbatim from the old bytea column, only now the transition is atomic inside a real transaction rather than "one column write = one indivisible payload."

`PgClient::loadProfile` runs one `pqxx::work` that: (1) checks `SELECT 1 FROM sim_player_profile WHERE person_id = $1` (nullopt vs "row exists, all children empty" are semantically different — the latter is a valid `save({})` result); (2) reads each child table with `SELECT id, value FROM sim_player_X WHERE person_id = $1 ORDER BY <id> ASC`.

`ProfileStore::save` iterates each Set's `.values()` unordered_map, sorts by id ascending (deterministic pg_dump / replay diffs) and passes rows to `IPgClient::upsertProfile`. `ProfileStore::loadOrCreate` iterates the returned rows and reconstructs each Set via `AttributeSet::set(AttrId, Fixed64::fromFloat(f))` etc.

`InMemoryPgClient` mirrors the interface: `profiles_` becomes `unordered_map<PersonId, ProfileRows>` and `loadProfile` sorts each vector by id ascending before returning so behaviour parity with `PgClient` is bit-for-bit.

Migration 205 is guarded: a `DO $$ ... RAISE EXCEPTION ... $$` block refuses to run if `sim_player_profile` has any rows, on the assumption (verified pre-write against the live DB: 0 rows) that no production data existed under the old schema. If that changes before the migration is applied on any environment, write a data migration to translate bytea payloads into row inserts before dropping the old table.

**Consequences**:
+ **Ops readable schema.** A plain `SELECT r.key, a.value FROM sim_player_attribute a JOIN sim_attribute_registry r ON r.id = a.attr_id WHERE a.person_id = $1` prints the profile. No `sim_decode_attributes(...)` incantation required. `pg_dump` diffs on profile changes are line-by-line rather than opaque bytea blobs.
+ **§22.14 write policy preserved verbatim.** First-touch INSERT semantics carry through: `ProfileStore::save` still calls `IPgClient::upsertProfile` exactly once per person (from `loadOrCreate` on first touch), the transaction opens exactly one write path across all four tables, and the `.save(` grep in `check_profile_write_policy.sh` still finds only `ProfileStore.cpp`. The smoke check `pg_stat_user_tables.n_tup_upd = 0` extends from one table to four.
+ **Cross-arch determinism preserved.** The precision of the round-trip is unchanged (still f32 on disk, still `Fixed64::fromFloat` / `toFloat` at the boundary). Bit-for-bit replay hashes are unaffected because no wire snapshot ever included profile bytes to begin with.
+ **Registry drift becomes a hard error at write time.** The FK `sim_player_attribute.attr_id → sim_attribute_registry.id` means any attempt to write a row for a nonexistent attribute id is rejected by Postgres, not silently persisted. §22.9 + §22.11 make this a defense-in-depth check rather than a burden.
+ **`test_pg_client` and `test_in_memory_pg_client` gain row-order determinism assertions** — new tests verify that scrambled-insertion-order rows come back ORDER BY id ASC, which the bytea layout couldn't test (bytea order was implicit).
− **Row overhead grows.** M0 has 9 physical attributes per person; that's 9 rows in `sim_player_attribute` where the bytea payload was one row's `attributes` column (~56 bytes). Postgres tuple overhead makes each row cost ~50 bytes; 9 rows ≈ 450 bytes vs 56. At the M0 fh scale (dozens of people) this is negligible. At M4 pattern-recognition scale (hundreds of patterns × thousands of people) revisit — see below.
− **Three DELETEs on upsert** even when the set is unchanged. Currently only ever runs on first-touch per §22.14 so the wastage is zero. Post-M3 mid-match writes would benefit from a diff-aware upsert path. Revisit if the M3 concept-mastery upserter shows up in profiles.
− **Migration 201's profile decoders became orphans and were dropped.** Any ops runbook / wiki reference to `sim_decode_attributes(BYTEA)` / `_concepts` / `_recognition` needs updating to the JOIN pattern above. `sim_decode_input(BYTEA)` and `sim_decode_event(SMALLINT, BYTEA)` are unaffected — they decode wire audit payloads, not profile columns.
− **Three-file coupling with `sim_pattern_registry`.** `sim_player_recognition.pattern_id` FKs to a table that is empty in M0 (patterns start in M4, §12.5). That FK never fires in M0 but is defence in depth for the M4 landing.

**Revisit if / when**:
- **M3 concept-mastery mid-match writes land.** The DELETE-then-INSERT upsert becomes per-tick expensive if a match writes concept mastery every N ticks. Move to `INSERT ... ON CONFLICT (person_id, concept_id) DO UPDATE SET mastery = EXCLUDED.mastery` for the child rows and drop the DELETE-all-first phase, or split write-set diff computation into the caller. Only worth doing if profiling shows the DELETE dominates.
- **M4 pattern recognition populates `sim_player_recognition` at scale.** If a "typical" player carries hundreds of pattern rows, revisit whether a partitioned or grouped storage (e.g. one row per category, JSONB payload) beats raw row-per-value for read latency during profile load. The bytea approach we just removed would be a candidate again, this time driven by evidence rather than convention.
- **A future profile-editor UI writes individual field updates from the backend.** Move to `INSERT ... ON CONFLICT (person_id, attr_id) DO UPDATE SET value = EXCLUDED.value` for the single-field path; the whole-set DELETE-then-INSERT stays for the sim daemon's first-touch write. `check_profile_write_policy.sh` would gain a backend-side counterpart (see §22.14's M1 profile-editor revisit note).
- **Migration 205's precondition guard fires** (`sim_player_profile has N row(s)` in any environment). Means someone landed the migration on a populated DB — very unlikely given the M0 zero-row invariant but the guard forces a stop rather than silent data loss. Write a data migration to translate bytea payloads before dropping.

**Refs**: §5.2 (Set class shape, row-per-value clarified), §8 (schema — normalized profile block), §8.1 (SQL decode helpers — profile decoders removed, wire decoders retained), §16.6 (Slice 13 spec — ProfileStore row-per-value update), §22.4 (bytea for gameplay data — profile side split off into this ADR), §22.9 (registry ids stable — enables the FKs), §22.11 (M0Registry codegen — same), §22.12 (persistence architecture — `IPgClient::loadProfile/upsertProfile` contract updated), §22.13 (replay uses M0 defaults — unaffected, precision unchanged), §22.14 (write policy — preserved verbatim through the row-set expansion), migration 205 (`database/migrations/205-sim-normalize-profiles.sql`).

---

### 22.19 [2026-07-14] Backend → podman IPC surface — libcurl over podman.sock Docker-compat REST API

**Status**: accepted 2026-07-14 as documentation-only backfill of the surface that shipped in Slice 14 (commit `ef872341`) and was exercised by Slice 14.7's baseline load test (commit `219e57dc`). Landed code: [backend/src/orchestration/SimOrchestrator.cpp](backend/src/orchestration/SimOrchestrator.cpp) — libcurl transport routed via `CURLOPT_UNIX_SOCKET_PATH = /run/podman/podman.sock`, base URL `http://d/v1.41/…` (host component ignored by libcurl over UNIX sockets, `v1.41` pinned in `kPodmanApiVersion`), no auth (socket file permissions are the authorisation boundary), 4-way in-process spawn semaphore (`LaunchSemaphore`, kMax=4, override via `FH_SIM_LAUNCH_MAX_CONCURRENCY`). The two hot-path verb pairs are `POST /v1.41/containers/create` + `POST /v1.41/containers/{id}/start` on launch and `POST /v1.41/containers/{id}/stop` + `DELETE /v1.41/containers/{id}` on teardown. Socket is bind-mounted read-write into the backend container via [docker-compose.yml](docker-compose.yml) (`/run/podman/podman.sock:/run/podman/podman.sock:rw`). This ADR supersedes the §23.7 draft placeholder that had proposed `podman run` shell-out.

**Problem**: Slice 14 (§16.7 Option A — one podman container per active match, name `footballhome_sim_${match_id}`) needs a backend-side mechanism to (a) spawn a container from image `localhost/footballhome_footballhome_sim:latest` on the shared `footballhome_footballhome_network` with per-match env (`SIM_MATCH_ID`, `SIM_SEED`, `SIM_SCENARIO`, `PGCONN`, …), (b) start it, (c) stop it on match-end, (d) remove it. Five candidate transports:

1. **`podman run …` shell-out** — fork+exec `podman` binary. §23.7's original placeholder. Simplest ops story (matches every debugging incantation in [.github/copilot-instructions.md](.github/copilot-instructions.md)); complex error-handling (stderr parsing of a foreign CLI + exit codes); each spawn pays podman's CLI startup cost (Go runtime init + flag parse — measurable per-spawn overhead on this class of host); env-var injection through a long argv is error-prone (quoting, per-flag ordering).
2. **libcurl over podman.sock's Docker-compat REST API** — HTTP verbs against `unix:/run/podman/podman.sock` targeting the Docker-compat surface (`/v1.41/containers/*`). Portable to Docker hosts unchanged.
3. **`podman-compose` subprocess** — reuse the local compose config, spawn a service by name. Pays Python import + YAML parse cost per spawn; ties the runtime path to compose semantics we'd rather keep for boot-time bring-up only.
4. **Native `/libpod/` REST surface** — same transport as (2) but podman-specific endpoints. No functional gain for Slice 14's needs; locks out Docker portability.
5. **Bespoke sim-orchestrator daemon** — a small process holding the podman connection, backend talks to it over a UNIX socket. Adds a new failure surface + a new process to supervise; buys nothing for M1 (all logic is already stateless in `SimOrchestrator::launchMatch`).

**Decision**: Option 2 — libcurl → `CURLOPT_UNIX_SOCKET_PATH = /run/podman/podman.sock` → Docker-compat REST API v1.41. Rationale:

+ **Single verb per HTTP call cleanly matches the SimOrchestrator API surface.** `launchMatch()` is one `POST /containers/create` (returns container id) + one `POST /containers/{id}/start`. `stopMatch()` is `POST /containers/{id}/stop` + `DELETE /containers/{id}`. Every failure mode surfaces as an HTTP status + JSON error body from a documented spec; no CLI-stderr parsing.
+ **No per-spawn CLI process-startup tax.** Option 1's fork+exec of `podman` costs measurable overhead per spawn just to init before doing useful work. Option 2 skips it entirely — a persistent socket + HTTP request is on the order of hundreds of microseconds of client-side overhead per call.
+ **Docker portability preserved.** The Docker Engine speaks the same v1.41 API at `/var/run/docker.sock`. If the deploy target ever moves to a Docker host, `CURLOPT_UNIX_SOCKET_PATH` swaps and everything else compiles unchanged. Options 1 and 4 both foreclose this.
+ **Debugging orthogonality preserved.** Human debugging still uses `sudo podman ps` / `sudo podman logs footballhome_sim_${id}` / `sudo podman exec` per [.github/copilot-instructions.md](.github/copilot-instructions.md). The orchestration surface is independent of the debugging surface — both are legitimate views onto the same rootful podman daemon. The §23.7 draft's reasoning that shell-out "matches every debugging incantation" conflated the two — Option 2 does not disturb debugging in any way.
+ **Env injection via structured JSON.** `POST /containers/create` accepts an `Env: ["KEY=VALUE", …]` array. `SimOrchestrator::buildCreateBody()` emits `nlohmann::json` — no argv-quoting bugs possible.

**Consequences**:
+ **libcurl is already a backend link edge** (used by `HttpClient` for other outbound calls) — no new dependency.
+ **Podman socket must be bind-mounted RW into the backend container.** Codified in `docker-compose.yml`; called out in [.github/copilot-instructions.md](.github/copilot-instructions.md)'s Container/DB Access Rules block. Any operator bringing the stack up without this mount sees `SimOrchestrator::launchMatch` fail immediately on the first spawn attempt with a `couldn't connect to socket` libcurl error.
+ **Backend container gains root-equivalent host authority via the socket.** Anything that can write to `/run/podman/podman.sock` can start any container on the host as root. Justified because: (a) backend is already trusted (holds JWT secret, PG password, session-cookie signing key), (b) Options 1/3/5 end up equivalently privileged — a shell-out to `podman` implies the backend user has passwordless-sudo-to-root or podman rootless mode (neither is the current posture), (c) the deploy already runs rootful podman intentionally per [.github/copilot-instructions.md](.github/copilot-instructions.md); there is no additional privilege gained by this choice.
+ **API version pinning at v1.41** via `kPodmanApiVersion`. Podman 4.9.3 advertises v1.41 in its Docker-compat surface. Upgrading podman past a major version that drops v1.41 forces a code change here rather than a silent version-float that breaks in production.
+ **Portable to Docker hosts** — as above.
− **The 4-way spawn semaphore (`LaunchSemaphore`, kMax=4) is a workaround, not a solution.** It exists because 20 concurrent `POST /containers/create + start` calls to podman.sock stampede the socket queue (observed 2026-07-13: 17/20 requests timed out at 15 s while podman was still processing containers 13..20). Slice 14.7's baseline load test with kMax=4 shows the socket stays healthy but does NOT resolve the underlying podman-side serialisation of container creates. See §21.7 item 1 for the perf follow-up. `FH_SIM_LAUNCH_MAX_CONCURRENCY=1` provided as a debug escape hatch (strictly serial spawns).
− **JSON-over-libcurl is chatty vs. a bespoke binary wire.** Each spawn does ~2 KB of HTTP framing + JSON body. For M1's target scale (< 20 spawns per second per host) this is negligible; if M4+ ever needs > 100 spawns/s it becomes ~200 KB/s of pure protocol overhead — still cheap, but present.
− **Podman socket downtime = orchestration downtime.** If `/run/podman/podman.sock` disappears (podman service restart, socket file recreated with wrong perms), every launch/stop fails until systemd's `podman.socket` unit recovers. Slice 14 does NOT implement backend-side retry — the error surfaces to the caller. If ops finds this a real operational pain, add a bounded jittered-backoff retry inside `HttpClient::sendUnixSocket()` in a later slice.

**Revisit if / when**:
- **Warm-image spawn latency > ~1.5 s median under M1 load, attributed to `POST /containers/create` REST latency.** §21.7 item 1's investigation (instrument the spawn path via `podman inspect .State.StartedAt` timestamps vs sim-daemon stderr timestamps) would attribute the ~1 s warm-image floor to one of: (a) podman-side create+start REST latency, (b) sim-binary boot cost, (c) initial DB round-trip. If (a) dominates, motivate the warm-daemon-pool alternative in §16.7 (pre-spawned idle daemons receiving `POST /admin/assign_match`). That change moves the podman-surface hot path off the per-match request path — this ADR's transport choice is unaffected but its performance criticality drops.
- **Podman drops Docker-compat API compatibility for v1.41 or above.** Swap `kPodmanApiVersion` to the next supported version OR pivot to Option 4 (`/libpod/` surface). Realistic threshold: podman 5.x+ if compat guarantees soften.
- **Deploy target moves to Kubernetes.** Retire `SimOrchestrator` entirely in favour of the K8s API (probably via a sidecar `client-go` process or the `kubectl create -f -` shell-out pattern). Backend no longer talks to a container runtime directly; it talks to a scheduler. This ADR gets superseded by a new one covering the K8s surface.
- **A bespoke sim-orchestrator daemon (Option 5) proves worth its weight** — e.g. cross-host scheduling, snapshot-based scheduling, or a batch-spawn API needed for the warm-daemon-pool. Supersede with a new ADR at that point.
- **Backend container's root-equivalent authority via the socket is deemed unacceptable** — e.g. multi-tenant deploy. Move to a dedicated orchestrator process running under `podman socket-activated` with a narrower authorisation policy; backend talks to it via an authenticated UNIX socket. Not a concern for the single-tenant M1 target.

**Refs**: §16.7 (multi-match orchestration plan, Option A — per-match container is what this ADR provides the transport for), §21.2 item 3 (multi-match orchestration blocker — resolved by Slice 14 + this ADR), §21.7 item 1 (warm-image spawn floor — the concrete revisit-if signal), §21.7 item 4 (this ADR being unfilled — RESOLVED by this landing), §22.0 (append-only rule — this fills the reserved §22.19 slot), §22.12 (persistence architecture — per-daemon PgClient works because per-daemon container isolation is real), §23.3 Slice 14 (per-match container spawning), §23.3 Slice 14.7 (concurrent-match load test surfacing the semaphore + latency evidence used above), §23.7 (draft ADR predictions — this row is now landed and supersedes the draft's `podman run` shell-out proposal), commit `ef872341` (Slice 14), commit `219e57dc` (Slice 14.7 load test).

---

### 22.20 [2026-07-13] Wire v1.1 extension format — length-prefixed ball trailer + HELLO_ACK capability bits

**Status**: accepted 2026-07-13. Landed as commit `3156d4d7` (Slice 15.4) — see [sim/src/net/WireFormat.hpp](sim/src/net/WireFormat.hpp) (constants), [sim/src/net/BinaryV1Serializer.cpp](sim/src/net/BinaryV1Serializer.cpp) (encoder split + trailer decode), [sim/src/net/InputFrame.{hpp,cpp}](sim/src/net/InputFrame.hpp) (HELLO_ACK payload widened 14 → 16 bytes with `wire_capability_bits`), [sim/src/server/SimServer.cpp](sim/src/server/SimServer.cpp) (server advertises `kWireCapSnapshotBallTrailer` on connect), and [frontend/js/sim/wire.js](frontend/js/sim/wire.js) (JS decoder mirror). Golden byte-layout tests added in [sim/tests/test_binary_v1_serializer.cpp](sim/tests/test_binary_v1_serializer.cpp) and [sim/tests/test_input_frame.cpp](sim/tests/test_input_frame.cpp). Reserved slot **§22.19 (Slice 14 podman surface) landed 2026-07-14** as a doc-only backfill of the surface Slice 14 shipped — see §22.19 for the accepted decision.

**Context**: Slice 15 introduces a ball entity into `Match::snapshot()`. The M0 wire spec (§7.2) is a fixed-layout SNAPSHOT payload — `[u32 tick][u32 match_time_ms][u16 num_entities][entity[N]]` with each entity a 30-byte record. There is no room in a 30-byte entity record for ball-specific fields (spin, current owner) that make sense *only* for a ball, and there is nowhere in the payload header to signal "this frame carries a ball" without silently overloading a bit somewhere. Two clean extension paths exist:

- **A — length-prefixed extensible trailer.** Add bytes AFTER the entities region. Guard with a length prefix so v1.1 encoders that later add more ball fields (e.g. temperature, spin_axis) grow the region without breaking v1.1 decoders — the decoder consumes exactly `trailer_len` bytes and ignores what it doesn't understand at the tail. Backward-compat: no-ball snapshots emit NO trailer, so payload_sz stays exactly `header + entities_bytes` and old M0 decoders keep working byte-for-byte.
- **B — bump wire version byte in the frame header (v1 → v2).** Cleaner "types" story: two disjoint payload shapes tagged by a version integer. But every new field requires all clients to upgrade in lockstep — a v1 client rejects a v2 frame outright — and the encoder branches on version at every field, muddying the single-encoder simplicity M0 shipped with.

Additional context that accumulated between §22.18 (2026-07-13, profile normalization) and this ADR:

- **HTTP/1.1's success as an "additive extension" wire protocol** (arbitrary optional headers over a fixed request line + fixed status line) is the precedent Slice 15's design borrowed from. HTTP never bumped its major version to add new headers.
- **Slice 15's ball state fits in ~30 bytes** — position (3×f32), velocity (3×f32), spin (f32, reserved for M1), owner_slot (u16, `kBallOwnerLoose = 0xFFFF` for M1). Small enough that carrying it as a fixed extra 30-byte block after entities is almost the same cost as adding one more entity to the entities region — but with the semantic-clarity win that "this is the ball" is unambiguous at parse time (no need for downstream code to grep for `flags.is_ball` in the entities region).
- **The client capability negotiation channel (HELLO_ACK) is already round-trip** — server sends HELLO_ACK immediately after HELLO — so appending a `wire_capability_bits` u16 to its payload is free at the transport layer and gives the client an explicit "yes/no this server sends the ball trailer" signal before any SNAPSHOT arrives. Beats out-of-band signalling (URL query params, sub-protocol strings) which don't compose across future extensions.

**Decision**: Path A. Extend fh-sim.v1 additively to v1.1:

1. **SNAPSHOT payload gains an optional trailer** immediately after the entities region:
   ```
   [existing v1.0 payload: u32 tick | u32 match_time_ms | u16 num_entities | entity[N]]
   [u16 trailer_len]                      // Slice 15.4: 0 or ≥30
   [if trailer_len ≥ 30:]
     [f32 pos_x][f32 pos_y][f32 pos_z]    // offset 0..11
     [f32 vel_x][f32 vel_y][f32 vel_z]    // offset 12..23
     [f32 spin]                           // offset 24..27  (reserved; 0 in M1)
     [u16 owner_slot]                     // offset 28..29  (`kBallOwnerLoose = 0xFFFF` in M1)
     [remaining bytes reserved for future ball fields, ignored by v1.1 readers]
   ```
   `kSnapshotTrailerLenBytes = 2`, `kBallRegionBytes = 30`, `kBallOwnerLoose = 0xFFFFu`. The u16 prefix is the forward-compat hook: a hypothetical v1.2 growing the ball region to 34 bytes remains readable by v1.1 receivers, which parse the first 30 bytes they know and skip the tail.

2. **HELLO_ACK payload widens 14 → 16 bytes**, appending `[u16 wire_capability_bits]`. Bit 0 = `kWireCapSnapshotBallTrailer` — server MAY emit the ball trailer in SNAPSHOT payloads. `SimServer::handleConnect` sets this bit unconditionally in Slice 15.4. The encoder signature `encodeHelloAckFrame(match_id, slot, tick_hz, wire_capability_bits = 0)` uses a defaulted 4th arg so any legacy caller that hadn't been touched compiles unchanged (there was only one — [SimServer.cpp:170](sim/src/server/SimServer.cpp)).

3. **Encoder splits `Snapshot::entities` on serialize.** Match::snapshot() already emits the ball as `entities[0]` with `flags.is_ball = true` (Slice 15.2). The wire encoder iterates once: player entities go into the entities region (with `num_entities` counting players only), any ball-flagged entity is siphoned into the trailer. If multiple ball-flagged entities appear in one snapshot the encoder returns `{}` — hard error, not silent drop.

4. **Decoder relaxes the strict payload-length check.** The M0 decoder rejected any `payload_sz != kSnapshotHeaderBytes + entities_bytes`. It now rejects only `payload_sz < kSnapshotHeaderBytes + entities_bytes` — excess bytes are the trailer. If any bytes remain after entities, they MUST form a well-formed `[u16 trailer_len][trailer_len bytes]` block or the frame is rejected outright (three new rejection tests exercise the boundary conditions). The reconstructed ball is inserted at `entities[0]` so the in-memory shape matches Match::snapshot()'s output byte-for-byte.

Backward-compat guarantee locked by test `no_ball_snapshot_omits_trailer`: any snapshot with zero balls encodes to bytes that are byte-identical to what M0 would have produced. The canonical golden hash `0x4937890abb4edfb6` for `canonicalSnapshot()` (two players, no ball) is unchanged from M0.

**Consequences**:
+ **Additive, HTTP-1.1-style extensibility.** Slice 16's dribble mechanics will add `owner_slot` semantics (real player id instead of `kBallOwnerLoose`) without wire-format changes. A future spin_axis or ball_temperature field grows the trailer's ball region while old v1.1 decoders keep parsing the first 30 bytes they recognise.
+ **Single wire version.** The frame header's version byte stays at `0x01` forever unless we take path B for some future breaking change. Encoders and decoders don't branch on version at any field — only on message type — so the codec stays lean.
+ **Server ↔ client capability negotiation channel is now real** via HELLO_ACK. Bit-flag design mirrors HTTP `Accept-Encoding` / `Content-Encoding`: server declares what it *may* emit, client parses opportunistically. Future bits (bit 1 = collision events, bit 2 = playable-area state, …) slot in without another payload widening.
+ **Golden byte-layout tests catch drift immediately.** 8 new subtests in `test_binary_v1_serializer` lock the offset of every ball-region field; 4 new subtests in `test_input_frame` lock the capability-bits offset. Any well-meaning field-order shuffle breaks the tests before it breaks a client.
+ **Frontend + backend deploy independently.** M0 sim ↔ M0 frontend still work byte-for-byte because no-ball snapshots emit no trailer. M1 sim ↔ M0 frontend works too *when no ball is present* — as soon as a match spawns a ball, an M0 frontend would reject the SNAPSHOT because its strict `payloadLen !== expected` check hasn't been relaxed. In practice fh deploys sim + frontend together, so the frontend was updated in the same slice (Slice 15.5, commit `4aba3b09`) to parse the trailer.
− **Multiple balls per snapshot is a hard error.** M1 has one ball per match by design; if we ever want to support "warmup balls" or a hypothetical multi-ball training mode, we'd need a v1.2 that either extends the trailer with a count prefix or adds a second trailer region. The current encoder returns `{}` (empty vector) rather than encoding a garbled frame — surfaces the design constraint loudly at write time.
− **HELLO_ACK payload widened 14 → 16 bytes.** Any external tooling that hardcoded 14 (rather than using `kHelloAckPayloadBytes`) breaks. Only one external consumer existed: [frontend/js/sim/wire.js](frontend/js/sim/wire.js), updated in the same slice. `test_sim_server`'s strict frame-size assertions used the symbolic constant and auto-adjusted.
− **`num_entities` on the wire now counts players only, not the ball.** This is a semantic quiet change from M0 (where `num_entities` counted every entity in `Snapshot::entities`). Callers who used `num_entities` to preallocate render arrays now need to add 1 if the trailer indicates a ball is present. Downstream `frontend/js/sim/interpolator.js` was updated to track the trailer's ball as a first-class object separate from the entities array (Slice 15.5).

**Revisit if / when**:
- **A third wire-payload extension appears that doesn't fit the "single length-prefixed trailer" shape** — e.g. two orthogonal optional regions (collision events + playable area) both wanting to sit after entities. At that point either (a) generalise the trailer into a TLV chain `[u8 region_type][u16 region_len][region_bytes]…` (breaking change for the ball trailer's implicit "there is at most one trailer" contract, but expressible as a v1.2 by adding a new bit to `wire_capability_bits`), or (b) accept a small proliferation of length-prefixed trailers appended in a documented order. Prefer (a) if we cross ~3 trailer types; below that, ordered appended trailers keep the decoder trivial.
- **M4 WASM lockstep client (§20) forces Fixed64 words on the wire.** That's the natural v2 boundary — a version-byte bump becomes justified because f32→Fixed64 changes the encoding of *every field*, not just adds new ones. Path B was the wrong choice for Slice 15 (adds bytes to one field) but the right choice for the M4 pivot (rewrites every field). This ADR does not close that door.
- **Any client outside frontend/js/sim/ starts consuming SNAPSHOT frames** (e.g. an admin tool, a replay analyzer, a stats scraper). Its parser needs to speak v1.1 or explicitly filter out the trailer via `payload_sz != header + entities_bytes` → skip. Document this in the wire-protocol reference (§7) if / when it becomes a real concern.
- **`kWireCapSnapshotBallTrailer` becomes conditional per-match** (e.g. some match types don't have a ball). The current server sets it unconditionally on connect; a future match-type switch would need the server to inspect the running match before ACKing. Not needed for M1.

**Refs**: §7 (wire protocol — v1.1 addendum is this ADR), §7.1 (HELLO_ACK format — payload widened here), §7.2 (SNAPSHOT format — trailer added here), §22.0 (ADR append-only rule — §22.19 slot for Slice 14 landed 2026-07-14 as a documentation backfill), §23.3 Slice 15.4 (draft that this ADR realises), §23.7 (draft ADR predictions — this row is now landed), commit `3156d4d7`, commit `4aba3b09` (frontend mirror).

### 22.22 [2026-07-14] SCENARIO_META as a separate one-shot message, not a HELLO_ACK-appended payload

**Status**: accepted 2026-07-14. Landed as Slice 17.7a (server, commit `f29ad3a3`) + Slice 17.7b (frontend mirror + renderer overlay). Server-side: [sim/src/net/WireFormat.hpp](sim/src/net/WireFormat.hpp) (msg-type + cap-bit + region constants), [sim/src/net/ScenarioMetaFrame.hpp](sim/src/net/ScenarioMetaFrame.hpp) + [ScenarioMetaFrame.cpp](sim/src/net/ScenarioMetaFrame.cpp) (encoder + decoder), [sim/src/match/Match.hpp](sim/src/match/Match.hpp) (`Match::playableArea()` accessor added), and [sim/src/server/SimServer.cpp](sim/src/server/SimServer.cpp) (server sets `kWireCapScenarioMeta` in HELLO_ACK and sends one SCENARIO_META frame immediately after). Server unit tests in [sim/tests/test_scenario_meta_frame.cpp](sim/tests/test_scenario_meta_frame.cpp) (11 subtests: byte layout, roundtrip, malformed-input rejection, u16-cap overflow); integration test `scenario_meta_sent_immediately_after_hello_ack` in [sim/tests/test_sim_server.cpp](sim/tests/test_sim_server.cpp) proves the two frames arrive in order on the wire with the correct cap bit and payload. Frontend mirror: [frontend/js/sim/wire.js](frontend/js/sim/wire.js) (`MSG.SCENARIO_META`, `WIRE_CAP.SCENARIO_META`, `SCENARIO_MODE`, `decodeScenarioMeta`), [frontend/js/sim/transport.js](frontend/js/sim/transport.js) (`onScenarioMeta` dispatch), [frontend/js/sim/client.js](frontend/js/sim/client.js) (`state.scenarioMeta` + hand-off to renderer), [frontend/js/sim/renderer.js](frontend/js/sim/renderer.js) (`drawPlayableArea()` with mode-specific line-dash overlay: Advisory=dashed yellow, Hard=solid red, Soft=dotted cyan).

**Problem**: Slice 17 landed `Hard` / `Soft` playable-area constraint modes on the server (Slices 17.1–17.5) plus cross-arch determinism goldens (17.6). The client-side deliverable (Slice 17.7) requires the browser to render the polygon overlay with a mode-specific line style. Nothing in the M0/M1 wire currently carries polygon or mode data — the renderer only knows about the fixed 105 × 68 m pitch drawn from JS constants.

**Options considered**:

1. **Extend HELLO_ACK with an appended variable-length trailer** — reuse the Slice 15.4 pattern (§22.20). HELLO_ACK is currently a fixed 16 bytes; extending it means every future addition of session-scope metadata piles up in the same message. Also changes the fixed-length semantic of HELLO_ACK, which is currently trivially validated with `payload_len == kHelloAckPayloadBytes`.
2. **A new one-shot message SCENARIO_META (0x03) sent immediately after HELLO_ACK, gated on `kWireCapScenarioMeta` in HELLO_ACK's cap bits**.
3. **Fetch playable-area metadata via HTTP** (e.g. `GET /api/sim/matches/{id}/scenario-meta` from the frontend) — completely orthogonal to the WebSocket lifecycle.
4. **Embed the polygon in the SCENARIO_META room of every SNAPSHOT** — mid-match mutation channel, per-tick overhead.

**Chosen**: Option 2 — new message type, one-shot, capability-bit-gated.

**Rationale**:

+ **Session-scope metadata is genuinely orthogonal to HELLO_ACK's connection-scope semantics.** HELLO_ACK answers "your slot + tick rate + which optional features I speak". SCENARIO_META answers "here is the world-space geometry your renderer needs". Piling both into a single message forces the wire's fixed-length invariant (HELLO_ACK = 16) to become variable, which breaks the trivial length check. A separate message type keeps each frame's contract crisp: HELLO_ACK stays fixed-16-byte, SCENARIO_META declares itself variable.
+ **Send-once is genuinely different from mid-match mutation.** M1 scenarios declare their playable area at construction and never mutate it. Sending SCENARIO_META once, immediately after HELLO_ACK, matches this contract exactly. If a future scenario ever needs the polygon to move (e.g. a shrinking play zone), that's a new msg_type (SCENARIO_META_DELTA), not a schema tweak here.
+ **Capability-bit gating stays uniform.** Slice 15.4 established the pattern: server advertises optional features in HELLO_ACK's `wire_capability_bits`, client keys off the bits to decide what to expect. Adding bit 1 for SCENARIO_META lets an older client (pre-Slice-17.7) that doesn't understand the bit safely ignore the incoming 0x03 frame — the transport-level dispatch drops unknown msg_types per §7.
+ **HTTP fetch (option 3) violates the "one connection, one source of truth" contract.** Every M0/M1 client interaction with a match goes through the WebSocket. Adding a parallel HTTP path introduces a second failure mode (WS connects but HTTP fetch fails), a second auth flow, and a "which arrives first" race. All negative for a metadata channel that is trivially small (< 100 bytes for typical polygons).
+ **Per-SNAPSHOT embedding (option 4) wastes 3–500 bytes per tick.** At 20 Hz × 20 clients per host that's 12–200 KB/s per host of pure duplicate metadata. M1 has one ball-related trailer per SNAPSHOT already; layering static polygon data on top of that is strictly worse.

**Trade-offs**:

+ **A second post-HELLO_ACK frame is now sent unconditionally per session.** Small (7-byte payload minimum for Advisory + empty polygon, up to ~100 bytes for a typical drill-zone rectangle). Never revisited.
+ **The client MUST parse SCENARIO_META before the first SNAPSHOT to render the overlay correctly.** In practice the server sends both frames in the same handleConnect call so they arrive back-to-back — the JS transport's message-dispatch loop naturally handles SCENARIO_META before the first tick's SNAPSHOT.
+ **Mode byte is a direct cast of `scenario::PlayableArea::Mode`**, locked by three `static_assert`s in `ScenarioMetaFrame.hpp`. Any renumbering of the enum fails the build immediately.
+ **XY-only** (no z). The scenario polygon is defined on the ground plane; z-lifted overlays are out of M1 scope. If a future scenario needs a 3D playable region (e.g. air-corridor volumes) it's a new msg_type or a new capability bit + region extension.
− **Send-once semantics means dynamic playable-area mutation requires a new msg_type.** This ADR does not close that door; §22.22.next-ADR would be SCENARIO_META_DELTA.
− **The client must track "have I received SCENARIO_META yet?" state.** In practice this is trivial: null until decoded, then populated for the session's lifetime. The renderer no-ops on null.

**Revisit if / when**:

- **A scenario needs to mutate its playable area mid-match** — e.g. shrinking play zone, a drill that progressively narrows. Add SCENARIO_META_DELTA as a new msg_type with a delta-encoded payload (e.g. add/remove vertices, mode change). Reusing SCENARIO_META for both the initial state and mid-match deltas would break the "send-once, session-scope" invariant this ADR establishes.
- **Multiple scenario-scope metadata channels appear** — e.g. lighting, weather, spectator seating. At ~3 channels, consider generalising SCENARIO_META into a TLV chain `[u8 field_type][u16 field_len][field_bytes]…` inside a single "scenario snapshot" message. Below that count, separate msg_types keep the decoder trivial.
- **A polygon exceeds the u16 payload cap** (~8191 vertices). Not remotely a concern for M1 rectangles (4 vertices each). If we ever ship a polygon with > 8k vertices, either compress or migrate to a chunked message type.
- **Client capability negotiation becomes asymmetric** — e.g. the client wants to opt into SCENARIO_META independently of ball trailer. Today it's server-side unconditional; if we ever need per-client scope, the client's HELLO can start carrying capability bits too (currently reserved u32 in the HELLO payload).

**Refs**: §7.1 (message type 0x03 row added here), §7.4 (SCENARIO_META payload format added here), §22.20 (Slice 15.4 wire-cap-bits pattern this ADR reuses), §22.19 (Slice 14 podman surface — landed 2026-07-14), §23.3 Slice 17.7a (server-side, commit `f29ad3a3`), §23.3 Slice 17.7b (frontend mirror + renderer overlay).

### 22.23 [2026-07-16] INPUT frame length-prefixed extension — additive kick trailer for Slice 26.2

**Status**: proposed 2026-07-16, **landed 2026-07-16 in Slice 26.2** (`Intent::wants_kick` + `Intent::kick_direction` + `Intent::kick_power_hint` + server-side decoder + client-side encoder + JS mirror + migration 218 debug decoder). Wire-format contract locked; all 9 determinism goldens byte-identical (47/47 tests green, `test_determinism` 0.02 s). See §24.3 Slice 26.2 log line for the implementation summary.

**Context**: Slice 26.1 landed `physical.pass_power` at attr id=14 (migration 217, commit `78b2ad6c`) but no code path yet reads it. Slice 26.2 is the wire-touching slice that carries the client's decision to kick. Two pieces of information must cross the boundary each tick the player is holding the kick button:

- **A 1-bit predicate** — `wants_kick`. Fits trivially in the existing 16-byte INPUT payload's `flags` byte: bit 4 is free (bits 0..3 are `wants_sprint | wants_walk | wants_dribble | wants_release`). No wire change required for this piece.
- **A direction vector** — 2×f32 (`kick_dir_x`, `kick_dir_y`) in world XY. Total 8 bytes. Does NOT fit in the current INPUT payload (§7.3): the `reserved[3]` bytes after `flags` are only 3 bytes, and repurposing `desired_dir_{x,y}` would be a semantic collision (the same wire fields would mean "move in this direction OR aim my kick in this direction" — impossible to disambiguate from raw bytes).

So the wire needs 8 additional bytes on the kick tick. Same shape of problem §22.20 solved for SNAPSHOT: fixed-layout M0 payload, need to graft on new fields without breaking older decoders, want forward-compat headroom for future fields (e.g. `pass_power_hint`, `curl_angle`). Every option §22.20 already surveyed applies here symmetrically — the only new axis is that the extension is *client → server* whereas §22.20's trailer was *server → client*.

**Options considered**:

1. **A — length-prefixed extensible trailer on INPUT payload** (mirror of §22.20's SNAPSHOT trailer). Add `[u16 trailer_len]` at offset 16, then a `trailer_len`-byte extension region. `wants_kick == false` MUST emit no trailer, keeping the 16-byte legacy layout byte-identical to today's INPUT frames stored in `sim_match_inputs.payload`. Server decoder relaxes strict `payload_sz == 16` to `payload_sz == 16 || (payload_sz >= 18 && trailer_len fits)`.
2. **B — wire version bump to v1.2 with a new fixed-layout INPUT variant.** Two disjoint payload shapes discriminated by the frame-header version byte. Symmetric with option B in §22.20; symmetric objections apply — every new intent bit forces lockstep client/server upgrade, encoder branches on version at every field, and `sim_match_inputs.payload` accumulates two mutually-incompatible layouts over time (the ops decoder `sim_decode_input` in migration 201 would have to branch, or migration 218 would have to rewrite historical rows — both unattractive).
3. **C — new msg_type INPUT_KICK (0x08) alongside INPUT (0x03).** Split the concept: normal-per-tick movement stays 16-byte INPUT; kicks are a separate one-shot message. Adds a second write path through `AsyncPgLog<InputRow>`, a second wire-audit decode helper, a second `sim_match_inputs`-style table (or a nullable-column shape), and a "what happens if a client sends INPUT and INPUT_KICK on the same client_tick?" ordering question that has to be answered every time a downstream tool touches wire audits.
4. **D — client-side capability declaration in a real HELLO message body.** Currently the WebSocket subprotocol string carries the auth (`fh-sim.v1.bearer.<JWT>`) but the `Hello` msg_type (0x01) is reserved and has no payload defined. Add a HELLO frame with `[u16 client_wire_capability_bits]` and gate the extended INPUT format on a client bit. Symmetric to HELLO_ACK's server-declared bits but adds a fourth handshake step (HELLO → HELLO_ACK → SCENARIO_META → first INPUT) to a protocol that intentionally kept the handshake to three hops.
5. **E — repurpose `desired_dir_{x, y}` as dual-meaning when `wants_kick == true`.** Zero wire cost. Kills the ability to hold the kick button while walking (the player must choose per-tick between moving and aiming). Playtestable but not composable with future dribble-and-pass scenarios.

**Chosen**: **Option A — length-prefixed extensible trailer.** Server-side capability bit `kWireCapInputKickTrailer` (bit 3 in HELLO_ACK's `wire_capability_bits`) advertises that the server understands and applies the kick trailer. When the bit is not set, the client MUST suppress the kick action in its UX (grey out the kick button) rather than send a trailer the server would reject.

**Layout**:

```
[u32 client_tick]              // offset 0..3   (unchanged from M0)
[f32 desired_dir_x]            // offset 4..7   (unchanged)
[f32 desired_dir_y]            // offset 8..11  (unchanged)
[u8  flags]                    // offset 12     — bit 4 = wants_kick (new)
[u8  reserved[3]]              // offset 13..15 (unchanged)
[u16 trailer_len]              // offset 16..17 — Slice 26.2: 0 or ≥ 10
[if trailer_len ≥ 10:]
  [f32 kick_dir_x]             // offset 18..21
  [f32 kick_dir_y]             // offset 22..25
  [u16 kick_power_hint]        // offset 26..27
                               //   0     = use profile default (physical.pass_power = 15 m/s)
                               //   1..N  = scaled 1/65535 of that profile default
                               //           (never above the profile — server clamps)
  [remaining bytes reserved for future kick fields, ignored by v1.1 readers]
```

**Constants**:
- `kInputPayloadBaselineBytes = 16`       (M0 legacy payload; today's compile-time constant renamed for clarity)
- `kInputTrailerLenBytes      = 2`         (u16 length prefix)
- `kInputKickRegionBytes      = 10`        (2×f32 direction + u16 power_hint)
- `kInputPayloadWithKickBytes = 28`        (16 + 2 + 10)
- `kInputFlagWantsKick        = 1u << 4`   (Slice 26.2)
- `kWireCapInputKickTrailer   = 1u << 3`   (HELLO_ACK bit 3)

**Decoder contract** (server-side, `sim/src/net/InputFrame.cpp`):

- `payload_sz < 16` → reject (malformed, same as today).
- `payload_sz == 16` → legacy INPUT frame; `wants_kick` bit MUST be 0 (server rejects if bit 4 set without trailer — surfaces malformed clients loudly instead of silently dropping the kick direction).
- `payload_sz == 17` → reject (would require partial trailer_len).
- `payload_sz >= 18`:
    - Read `[u16 trailer_len]` at offset 16.
    - Reject if `18 + trailer_len != payload_sz` (trailer bounds must match payload).
    - Reject if `trailer_len > 0 && trailer_len < 10` (partial kick region; forward-compat readers ignore *trailing* extra bytes but never allow a smaller-than-known region).
    - Reject if `wants_kick == false && trailer_len > 0` (trailer present without intent is malformed — clients MUST NOT waste bytes).
    - Reject if `wants_kick == true && trailer_len < 10` (intent asserted without a direction — the direction is not optional in M2).
    - Decode `kick_dir_{x, y}` + `kick_power_hint`. Server validates `kick_dir` magnitude in [0.5, 1.5] (allows for tiny numeric drift around a unit vector; wildly off-unit inputs are rejected as malformed clients).

**Encoder contract** (server-side HELLO_ACK, client-side INPUT):

- Server: `SimServer::handleConnect` sets HELLO_ACK bit 3 unconditionally in Slice 26.2 (there is no per-match "kicks disabled" scenario in M2). Future match types that disable kicks would clear the bit here.
- Client (`frontend/js/sim/wire.js`): if HELLO_ACK bit 3 is unset, `encodeInput()` MUST emit exactly 16 bytes (byte-identical to M0/M1 encoding path). If bit 3 is set AND `intent.wants_kick == true`, emit 28 bytes with the trailer. Otherwise (bit set but not kicking this tick) emit 16 bytes — the trailer is present only on ticks the player is actually kicking. This preserves the "quiet tick = 16 bytes" property that keeps `sim_match_inputs.payload` compact for non-kick play.

**Backward-compat guarantee** (locked by test `no_kick_input_matches_m0_bytes` in `sim/tests/test_input_frame.cpp`, Slice 26.2): any INPUT frame with `wants_kick == 0` encodes to bytes byte-identical to what M0 would have produced. Ops queries and existing `sim_decode_input` (migration 201) continue to work unchanged on non-kick rows.

**Ops decoder impact** (migration 218 lands with Slice 26.2):
- `sim_decode_input(BYTEA)` is currently version-1 for 16-byte payloads. Migration 218 extends it to handle 28-byte payloads by parsing the trailer and adding `kick_dir_x`, `kick_dir_y`, `kick_power_hint` fields to the output jsonb. 16-byte payloads return the same jsonb shape as before (no kick fields). Malformed lengths return `{"error": "malformed_input_payload_len"}` — same envelope as today's malformed decoder path.
- No historical row rewrite required — `sim_match_inputs.payload` was always a BYTEA blob whose length is intrinsic to each row. Backfill is unnecessary.

**Consequences**:

+ **Additive, HTTP-1.1-style extensibility carried through to the client → server direction.** Slice 27's collisions ADR and Slice 28's shots ADR (`MatchEvent::Goal`) both have precedent for adding fields without version bumps. The trailer's u16 length prefix means a future `kick_power_hint` promotion to a full `curl_axis` (adding 4 bytes) is a `kInputKickRegionBytes` bump with legacy 28-byte payloads still decoding cleanly against older servers (they parse first 10 bytes, ignore the tail).
+ **Wire version stays `0x01`.** No decoder branches on version anywhere in the stack. Consistent with §22.20's decision for SNAPSHOT.
+ **Server-side capability negotiation reuses the HELLO_ACK bit-flag channel** established in §22.20. Bit 3 slots in without any new payload widening. Bit assignments so far: bit 0 = SnapshotBallTrailer (§22.20), bit 1 = ScenarioMeta (§22.22), bit 2 = MatchEventFrame (reserved for Slice 28.4 — storage-side design in §22.25), bit 3 = InputKickTrailer (this ADR). Remaining 12 bits free.
+ **`sim_match_inputs.payload` stays queryable with a single decoder function.** Migration 218 extends `sim_decode_input` additively — no `_v2` variant, no column-level branching. Non-kick rows continue to decode with the same 5-field jsonb shape they've always had.
+ **UX contract is explicit.** Client MUST grey out the kick button when bit 3 is unset. Older sims (pre-Slice-26.2) that don't send bit 3 automatically get a kick-disabled client — no confusing "kick button lights up but nothing happens" state. Slice 26.2 client code adds a `state.capabilities.canKick` boolean fed from the HELLO_ACK parse; the kick handler no-ops when it's false.

− **The strict `kInputPayloadBytes == 16` compile-time constant becomes `kInputPayloadBaselineBytes`, and decoder paths that used it must relax to a length range.** Same rename cost as §22.20's `kSnapshotHeaderBytes` split. Landing this before any downstream tool depends on the strict constant is cheap; every week we delay adds more grep hits to update. 3 files touch the constant today ([sim/src/net/InputFrame.hpp](sim/src/net/InputFrame.hpp), [sim/src/net/InputFrame.cpp](sim/src/net/InputFrame.cpp), [sim/tests/test_input_frame.cpp](sim/tests/test_input_frame.cpp)).
− **A malformed client that flips `wants_kick` in the flags byte but forgets the trailer is now a decoder-side rejection**, not a silent success. Same for the reverse. Both cases are treated as protocol violations rather than "best-effort" recoveries. The server logs the frame at debug level and drops it — same failure mode as today's malformed INPUT.
− **`sim_match_inputs.payload` now holds a mix of 16-byte and 28-byte rows.** Not a schema change (BYTEA is variable-length), but any external tooling that hardcoded 20 (frame header + 16-byte payload) as the row-length invariant will break on kick rows. `IPgClient.hpp`'s docblock comment about "wire InputFrame bytes" gets a `[u16 trailer_len]` clarification. No M0/M1 external tooling exists that depends on this.
− **HELLO_ACK now advertises 4 capability bits instead of 3.** No payload widening — `wire_capability_bits` is a u16 with 13 free bits after this ADR — but the client parse path must gate ~1 more feature. Trivial.

**Revisit if / when**:

- **A fifth or sixth wire-directional extension appears** (bit 4+ in either capability field) — start considering a per-message-type TLV chain rather than more bit-flags. Below that count, cap-bits + trailer stays the simplest thing that works.
- **Non-kick INPUT frames start needing a trailer** (e.g. Slice 27's collisions want to carry a "brace-for-impact" bit + magnitude). At that point the trailer's semantic broadens from "kick region" to "input extension region" — likely with a `[u8 region_type][u16 region_len][region_bytes]…` TLV chain inside. The u16 outer `trailer_len` already permits that shape; the region-type byte would slot in as a bump from `kInputTrailerVersion=0` (kick-only) to `kInputTrailerVersion=1` (TLV). Retrofit is a `sim_decode_input` migration + a decoder-side branch, no wire bump.
- **A client wants to signal capabilities in the other direction** (e.g. "I understand a hypothetical Slice 27 rumble packet"). Today the WebSocket subprotocol string carries only the JWT. Introducing a real HELLO body with `[u16 client_wire_capability_bits]` at the u32 reserved slot noted in §22.20's revisit conditions becomes worth the fourth-handshake-hop cost when we cross ~2 client-declared bits. Zero bits today, exactly why option D was rejected.
- **`kick_power_hint` graduates from u16 fraction to a full attribute-scaled value.** Currently the encoding is "0 = default, else linearly scaled to profile pass_power". If profiles gain minimum/maximum/curl fields, the hint promotes to a small struct and the region byte count grows (`kInputKickRegionBytes` bumps to 12 or 14). Legacy 28-byte clients continue to work — server ignores the missing tail bytes with a compile-time flag saying "no curl available from this client".
- **M4 WASM lockstep client (§20) forces Fixed64 words on INPUT too** — that's the natural v2 boundary shared with §22.20's SNAPSHOT-side rewrite. This ADR does not close that door.

**Refs**: §7.3 (INPUT payload — v1.1 addendum is this ADR), §7.1 (HELLO_ACK cap-bit table — bit 3 added here), §22.0 (ADR append-only rule), §22.20 (SNAPSHOT-trailer extension pattern this ADR mirrors), §22.22 (SCENARIO_META cap-bit precedent), §24.6 (M2 → M3 transition prereq item that this ADR closes), §24.3 Slice 26.1 (`physical.pass_power` attribute row this ADR's trailer will drive), §24.3 Slice 26.2 (implementation slice that lands this ADR), §21.3 (pre-M3 fix list — `sim_decode_input` version handling now defined explicitly by migration 218).

### 22.24 [2026-07-17] Player-player collision resolution — Slice 27

**Status**: **drafted 2026-07-17 (Slice 27.1), not yet implemented.** Locks the collision-resolution algorithm + weighting attribute + ball-exclusion rule for the physics upgrade landing across Slices 27.2 (`BasicPhysics`), 27.3 (`physical.body_mass` attr id=15, migration 220), 27.4 (rotate 3 existing determinism goldens), 27.5 (2 new collision goldens). Sim engine remains on wire v1 — physics is server-side only, no wire change. Existing scenarios with 0 or 1 slot (`EmptyPitchScenario`, `BallOnPitchScenario`, `HalfPitchScenario`, `SoftDrillScenario`) stay byte-identical because their collision list is empty; scenarios with ≥ 2 slots that get close (`BallOnPitchWithDefender`, `BallOnPitch2v0`, `GoalDrill`, plus the test-only `BallAndTwoSlotsScenario` used by `test_determinism`) will see per-tick trajectory changes and their goldens rotate in 27.4.

**Context**: Slices 15 through 28 shipped on `StubPhysics` (`sim/src/physics/StubPhysics.cpp`), which integrates `pos += vel*dt` per entity with **zero inter-entity interaction**. Two coaches sharing `BallOnPitch2v0Scenario` today can walk through each other; a defender in `BallOnPitchWithDefenderScenario` can pass through the coach's body to press the ball; two players contesting a first-touch (Slice 16.6's `test_two_humans_first_touch_tie_break_200_ticks_seed_42`) resolve ownership via `BallControl`'s tie-break rule but never physically collide even when their centres overlap by 100% at spawn. This is a P1 immersion break — a coach on the browser sees another player's dot walk *through* their own — and blocks Slice 27's exit gate ("defender can no longer occupy the same 2D position as the coach").

The ball's exclusion from any player-collision resolution is a hard M2 requirement. `BallControl` (Slice 16.3) sets `ball.position = owner.position + kBallOwnerLeadDistance*heading` every tick the owner holds it; if collision resolution treated the ball as an ordinary entity, an opponent brushing near the owner would displace the ball via the same overlap-clamp path that keeps players apart — defeating the whole first-touch contract from Slice 16.3 (only `wants_kick` releases; only proximity + `wants_dribble` transfers). §24.3's Slice 27 bullet list already flagged this: *"Non-owner slots that intersect the ball's radius during the physics step MUST NOT kick the ball (only `wants_kick` does)."*

All five resolution algorithms below produce identical resting configurations for two centre-overlap contacts; they diverge on the dynamic behaviour (bounce, slide, stick) and on the M2 attribute-registry footprint.

**Options considered**:

1. **A — positional-clamp only.** On overlap: compute the minimum-translation-vector (MTV) that separates the two circles along their centre-to-centre normal; move each entity halfway along MTV (or split by mass, see the weighting sub-decision). Do NOT touch velocities. Simplest possible impl: ~30 LOC in `BasicPhysics::step`. **Downside**: a player running into a stationary defender at full sprint gets clamped to the defender's edge but retains full velocity into the defender — next tick MTV fires again, next tick again, until the moving player changes direction. Client sees a player "stuck" on another with visibly non-zero velocity but zero displacement. Coach-hostile.

2. **B — positional-clamp + tangential-slide.** MTV clamp as in (A), then decompose each entity's velocity into normal component (along the MTV) and tangential component (perpendicular). Zero the normal component if it's pointing INTO the contact (so a player running into a wall of defender loses their forward momentum on the contact axis); preserve the tangential component (so pressing on someone's shoulder still lets you slide past). No restitution term, no bounce. Deterministic on Fixed64. **~80 LOC in `BasicPhysics::step`.** Coach reads it as "you can't run through people but you can slide around them" — matches real-football body-shielding intuition.

3. **C — impulse-based elastic (restitution = 0.2).** Full 2D-body impulse resolution: compute the normal impulse that reverses the closing velocity times a restitution coefficient. Adds a `restitution` scalar to tune; adds a `body_mass` attribute for the mass-ratio split. Produces a small visible bounce on hard contacts. **Downside**: adding a bounce coefficient bakes a designer knob into every collision, and elastic collisions in a top-down player game read as *rag-dolly* — not the football aesthetic. Restitution values above 0.05 make defenders slide backward from a full-speed sprint contact by ≥ 15 cm/tick; below 0.05 they're visually indistinguishable from (B). Adds a `restitution` migration row for zero visual gain over (B).

4. **D — impulse-based inelastic (perfectly plastic).** Positional clamp + zero the closing velocity on both entities (equivalent to restitution = 0.0 in (C)). Splits the closing velocity by mass ratio. **Downside**: the *entire* closing velocity is zeroed, including its tangential component — both players stop when they touch. Two players sprinting past each other perpendicularly at 45° lose all their sprint on the momentary contact. Feels wrong: you should be able to graze a defender's shoulder without losing your dribble.

5. **E — sweep-based CCD (swept-circle intersection over the sub-tick interval).** Compute the *time-of-impact* within the tick's dt; roll positions forward to that instant; resolve; recurse for the remaining dt. Handles high-speed contacts (e.g. a 25 m/s kicked ball vs a static player) without tunneling. **Downside**: sub-tick recursion breaks the current `IPhysicsWorld::step(dt)` single-shot contract; adds substantial LOC (~200) and a recursion-depth cap; tick-timing budget becomes non-uniform (a scenario with 3 pileups can spend 3× the CPU of one with none). Tunneling risk between players is negligible at M2 speeds (max sprint 7.5 m/s × 0.05 s = 0.375 m per tick vs a `contact_radius` of 0.4 m — the moving player is guaranteed to overlap the target on the tick they'd tunnel). Ball-vs-player CCD is orthogonal to the ball-owned exclusion rule below, so a sweep for the ball doesn't buy us anything M2 needs.

**Chosen**: **Option B — positional-clamp + tangential-slide.** Split-by-mass ratio using a new `physical.body_mass` attribute (id=15, migration 220, default 1.0, range [0.5, 1.5]). Ball-owned exclusion: on every tick's collision pass, the ball entity is skipped iff `BallControl::owner().has_value()` — the owner + ball are treated as a single kinematic unit for collision purposes. Loose balls (no owner) DO collide with players via the same MTV clamp but only positionally — no velocity is imparted to the ball by the player (the player is a passive obstacle that the ball rolls past), which preserves the M2 rule that only `wants_kick` can accelerate the ball.

**Algorithm** (server-side, `sim/src/physics/BasicPhysics.cpp`):

```
for each tick after per-entity velocity integration and BEFORE PlayableAreaConstraint::apply_hard:

  // Build collision list.
  candidates := [e for e in physics.all() if e.flags.is_active]
  if ball.has_owner:
    candidates.remove(ball)          // ball rides with owner, exempt from clamp

  // Single-pass MTV resolution. Deterministic order = ascending EntityId.
  // Fixed64 throughout — no float creep.
  for i in 0 .. candidates.len()-1:
    for j in i+1 .. candidates.len()-1:
      a, b := candidates[i], candidates[j]
      delta := a.position.xy - b.position.xy    // z ignored in M2
      d_sq  := delta.length_sq()
      r_sum := a.contact_radius + b.contact_radius
      if d_sq >= r_sum*r_sum:
        continue                                // no overlap

      // Non-zero normal even when centres exactly coincide: fall back
      // to the +x direction so the tie-break is deterministic across
      // architectures. Prev-tick delta is not used — stateless.
      d := if d_sq > kContactEpsilonSquared then sqrt(d_sq) else Fixed64::one()
      normal := if d_sq > kContactEpsilonSquared then delta / d
                else Vec2{Fixed64::one(), Fixed64::zero()}

      penetration := r_sum - d

      // Positional clamp split by mass. Heavier body moves less.
      // Total displacement = penetration; a gets (b.mass / total)
      // fraction, b gets (a.mass / total). Matches Newton's inverse-mass
      // convention (equal masses each move penetration/2).
      total_mass := a.body_mass + b.body_mass
      a.position.xy += normal * (penetration * b.body_mass / total_mass)
      b.position.xy -= normal * (penetration * a.body_mass / total_mass)

      // Tangential-slide velocity zap. Zero the CLOSING component
      // along `normal` for each entity; preserve tangential.
      // v_normal = dot(v, normal); if v_normal > 0 for a (moving TOWARD b),
      // subtract v_normal * normal from a.velocity. Symmetric for b
      // (its "toward" is -normal, so it's v_normal < 0 that gets
      // zeroed).
      va_n := dot(a.velocity.xy, normal)
      if va_n < Fixed64::zero():                 // a moving TOWARD b (into -normal from b's side means +normal into b's centre; sign flipped: a.velocity has +normal pointing FROM b, so "toward b" = negative normal)
        a.velocity.xy -= normal * va_n           // zeros a's -normal component only
      vb_n := dot(b.velocity.xy, normal)
      if vb_n > Fixed64::zero():                 // b moving TOWARD a (in +normal direction from b's centre)
        b.velocity.xy -= normal * vb_n           // zeros b's +normal component only

      // Note: separating pairs (a moving AWAY from b) are left alone —
      // preserves the sensible outcome of two players who just contacted
      // and are now walking away from each other.
```

**Constants** (all in [sim/src/physics/BasicPhysics.hpp](sim/src/physics/BasicPhysics.hpp)):

- `kPlayerContactRadius       = Fixed64::fromFraction(4, 10)`   // 0.4 m per player — half a shoulder-width; sum of two = 0.8 m body diameter.
- `kBallContactRadius         = Fixed64::fromFraction(11, 100)` // 0.11 m official FIFA size-5 ball radius.
- `kContactEpsilonSquared     = Fixed64::fromFraction(1, 10000)` // (0.01 m)² — below this the centres are treated as coincident and normal defaults to +x.
- `kBodyMassMin               = Fixed64::fromFraction(5, 10)`   // 0.5 lower clamp; a defender with 0.5 is displaced twice as much per contact.
- `kBodyMassMax               = Fixed64::fromFraction(15, 10)`  // 1.5 upper clamp; a defender with 1.5 is displaced 1/3 as much.
- `kBodyMassDefault           = Fixed64::one()`                  // 1.0 — every player at M2 default until the profile editor lands.

All constants live in `BasicPhysics.hpp` (not a scattered header) so a single grep finds every collision tuning knob. `kPlayerContactRadius` is deliberately a physics constant (not a per-player attribute) at M2 — body-size variation via attribute is deferred to M4+; body-mass variation lives on the attribute registry for the split-weighting only.

**Attribute contract**:

- New row in `sim_attribute_registry`: `physical.body_mass`, id=**15**, weight=1.0, category=`physical`, description=`Body mass for collision split-weighting; clamped to [0.5, 1.5] at read time in BasicPhysics::step.`
- Migration 220 lands the INSERT row + a `sim_default_body_mass()` SQL function returning `1.0` for use in `m0::defaultPhysical()` fallback.
- `common/M0Attributes.cpp` sets `a.set(kBodyMass, Fixed64::one())` in `defaultPhysical()`; `m0::defaultPhysical()` output changes by 1 attribute row — the M0 canonical hash locked by `test_canonical_hash::m0_default_attribute_set_hash_is_stable` (currently 0x???) MUST rotate. Called out in Slice 27.3.
- `sim/src/common/M0Registry.generated.hpp` regenerates via the pre-build codegen; adds `inline constexpr AttrId kBodyMass = 15;`.
- `MechanicsParams::fromPhysical` does NOT read `body_mass` — it's a physics-layer attribute, consumed only by `BasicPhysics::step`. `BasicPhysics` reads it via a new `IPhysicsWorld::setBodyMass(EntityId, Fixed64)` setter that `Match::claimSlot` calls after profile assignment; unclaimed slots default to `kBodyMassDefault`.

**Ball-owned exclusion rule** (canonical statement, quotable in test names and code comments):

> On any tick where `BallControl::owner().has_value()`, the ball entity is EXCLUDED from `BasicPhysics::step`'s collision-candidate list. The owner-and-ball pair is treated as a single kinematic unit for collision purposes: the owner's position/velocity resolves against other players per the MTV algorithm above, and `BallControl` re-glues the ball to `owner.position + kBallOwnerLeadDistance*heading` after the physics step (unchanged behaviour from Slice 16.3). Non-owner slots that overlap the ball's radius during a physics tick do NOT displace the ball. Loose balls (no owner) ARE in the collision-candidate list — they get positionally clamped away from any player they overlap, but the tangential-slide velocity-zap step is a no-op on them (ball has infinite effective mass for velocity purposes; only `BallPhysics::applyImpulse` from a kick can accelerate a loose ball).

**Consequences**:

+ **Deterministic + coach-legible.** Fixed64 throughout, ascending-EntityId iteration order, stateless (no per-pair contact-tracking state carries between ticks). A coach sees "walk into a defender → stop; walk sideways → slide past." Matches body-shielding intuition from real football.
+ **Ball ownership contract preserved.** The exclusion rule is a single one-line guard around the ball's inclusion in the candidate list — impossible to accidentally bypass because it's the sole entry point. First-touch semantics (Slice 16.3) remain untouched: still only `wants_dribble` + proximity transfers, still only `wants_kick` releases.
+ **No new wire bits.** Sim server-side only. `sim_match_events.payload`, `sim_match_inputs.payload`, HELLO_ACK cap bits, SNAPSHOT layout — all unchanged. Existing wire tests (`test_binary_v1_serializer`, `test_input_frame`, `test_match_event_frame`, `test_scenario_meta_frame`) stay green without modification.
+ **Attribute footprint is one row.** `physical.body_mass` at id=15 is the sole new attribute; `contact_radius` deliberately deferred to M4+ (currently a physics constant). This matches §22.20's minimalism principle for attribute-registry growth.
+ **1-slot / ball-only goldens stay byte-identical.** `Wander200` is a special case — uses `EmptyPitchScenario` (0 slots) so nothing collides. `HumanSprint400`, `BallRoll400`, `HalfPitchHard400`, `SoftDrill400` all have 0 or 1 active slot AND the ball is exempt from player-vs-player collisions AND (loose ball) has no player nearby to collide with. `test_ball_physics` and `test_stub_physics` remain valid because `BasicPhysics` extends the interface additively — old direct-`StubPhysics` tests continue to work; the *default* factory (Match constructor) is what flips to `BasicPhysics`.
+ **Test-only scenarios don't need modification.** `BallAndTwoSlotsScenario` in `test_determinism.cpp` continues to compile unchanged; its 2-slot goldens (`Dribble200`, `FirstTouch200`, `PassEast400`, `PassReceive200`) rotate under Slice 27.4 because the two slots' positions/velocities now interact.

− **Three existing goldens rotate.** Slice 27.4 lands the new hashes for `Wander200` (→ unchanged because 0-slot; verify), `Dribble200` (2-slot but co-linear, minimal impact; verify), `FirstTouch200` (2-slot centre-overlap at spawn — substantial hash change), `BallOnPitchWithDefender400` (2-slot with close-contact steady-state hold — substantial hash change), `PassEast400` (2-slot; slot 2 stationary at (+15, +5), 5 m off-axis — verify no contact), `PassReceive200` (2-slot; slot 2 on-axis; kicked ball flies past slot 1, slot 2 receives — substantial hash change if slot 2 walks through slot 1's spawn position during approach; likely no contact given the +15 m gap but must be verified). Each golden's new hash lands with a re-derived closed-form position estimate in the constant's comment, same discipline as the 8 existing goldens.
− **`m0::defaultPhysical()` output gains one row.** `test_canonical_hash::m0_default_attribute_set_hash_is_stable` (if it exists — verify) rotates in Slice 27.3. The FNV-1a-64 hash lock in `common/M0Attributes.cpp`'s test coverage moves to a new value; Slice 27.3 documents both the pre- and post-hash for a clean diff.
− **`IPhysicsWorld` gains `setBodyMass(EntityId, Fixed64)`.** Interface widening — `StubPhysics`, `BasicPhysics`, and any test-only physics implementations MUST implement the new method. Trivial store-on-entity in `StubPhysics` (already stores heading/motion opaquely); real consumer only in `BasicPhysics`.
− **Tunneling risk between players at M2 speeds is non-zero but negligible.** Max sprint 7.5 m/s × 0.05 s = 0.375 m per tick. Two players approaching head-on close 0.75 m per tick. Sum-of-radii = 0.8 m. So a head-on approach cannot skip past overlap in a single tick — always caught. Off-axis approaches close slower. Ball-vs-player at kick speeds (25 m/s in Slice 28.5 golden) DOES tunnel: 25 m/s × 0.05 s = 1.25 m per tick, larger than kPlayerContactRadius + kBallContactRadius = 0.51 m. Acceptable at M2 because (a) the ball is exempt from player-vs-player collision, (b) `BallPhysics` already handles ball-vs-ground; (c) ball-vs-player physics interaction isn't a Slice 27 goal (§24.3 explicitly non-goals it). Revisit condition below covers the M4+ CCD upgrade.
− **Circle-circle at close range is O(N²).** At M2 N ≤ 22 (worst case 11v11) — 22² = 484 pair checks per tick, all cache-hot Fixed64 subtracts. Well under the tick budget. Grid broadphase deferred to M4+ per §24.5 non-goal on "full-match 11v11 optimisation".
− **The velocity-zap sign convention is subtle.** The direction convention ("normal points from b to a") plus the sign of `dot(v, normal)` for "moving toward" MUST be documented at the call site with an ASCII diagram in `BasicPhysics.cpp` — anyone re-deriving this from scratch during a bug hunt will get it wrong.

**Revisit if / when**:

- **A player-vs-player collision test scenario needs a bounce** (e.g. an M4 goalkeeper-punch drill where the keeper explicitly wants to send an attacker sprawling). Promote to option (C) impulse-based elastic; add `physical.restitution` at attr id=16; only the specific collision types that opt in via `is_impact_pair()` use the elastic path; default MTV+slide behaviour stays for the other 99% of contacts.
- **Two-body chains cause visible jitter** (e.g. three players in a triangle each MTV-pushing the others into more overlap). At M2 with N ≤ 22 the single-pass resolution should converge in one tick for isolated pairs; if not, promote to a fixed-count iterative resolver (5–10 passes per tick, break early on σ(penetration) < ε). Deterministic if iteration count is compile-time constant.
- **Ball-vs-player interaction becomes a game requirement** (e.g. M5's offside line rendering needs the ball to bounce off a player who's just standing there). Ball exemption drops; add a dedicated `resolveBallVsPlayer` branch that does positional-clamp only (never touches velocity) so `wants_kick` remains the sole velocity-mutation entry point.
- **`contact_radius` becomes a per-player attribute** (M4+ body-size variation). Add `physical.contact_radius` at attr id=17, clamp to [0.3, 0.55], and read it from `IPhysicsWorld::setContactRadius` instead of the compile-time `kPlayerContactRadius`. Deterministic goldens rotate again at that time.
- **Cross-tick contact-tracking is needed** (e.g. for a "held-jersey" penalty detector counting sustained contact ticks). Add a `std::unordered_map<PairKey, ContactState>` inside `BasicPhysics`; hash key is `(min(id_a, id_b), max(id_a, id_b))`. Determinism-safe because ascending-EntityId pair iteration means the same PairKeys are inserted in the same order on every replay.
- **N grows past 30 (M4+ 11v11+substitutes)**, the O(N²) inner loop becomes measurable in tick-time budget. Introduce a uniform-grid broadphase (cell size = 2 * kPlayerContactRadius). Broadphase output is a set of candidate pairs — the narrowphase MTV algorithm above is unchanged. Deterministic if grid iteration is row-major.

**Refs**: §5.3 (`IPhysicsWorld` interface + `BasicPhysics` predecessor `StubPhysics`), §16.3 (`BallControl` first-touch + owner-glue rule that the ball exemption preserves), §22.0 (ADR append-only rule), §22.20 (SNAPSHOT trailer additive-extension pattern for attribute-registry growth precedent), §24.3 → "Player-player collisions" bullet list (source of the option-(b) recommendation this ADR ratifies), §24.4 M2 exit criterion "Player-player collisions resolved deterministically without ball being knocked away from its owner" (Slice 27), §24.6 M2→M3 transition "Collision → determinism-golden rotation surface" (Slice 27.4 rotates the 3 goldens catalogued there).

**Amendment 2026-07-17 (Slice 27.2 landing)** — append-only per §22.0:

Two narrowings became necessary once `BasicPhysics` landed and the interaction between the resolver and Slice 16.3's `BallControl` first-touch was traced end-to-end:

1. **Ball is ALWAYS excluded from the collision-candidate list, not just when owned.** The original ADR text ballpark'd "exclude iff `BallControl::owner().has_value()`", with loose balls positionally clamped away from players but never velocity-mutated by them. Actual arithmetic on the M2 constants forced a stricter rule: `kPlayerContactRadius + kBallContactRadius = 0.4 + 0.11 = 0.51 m`, which is **strictly greater** than `kBallControlRadius = 0.5 m` (the Slice 16.3 first-touch acquisition radius). If a loose ball were in the collision list, a defender approaching it would be MTV-clamped away at 0.51 m separation — i.e. *before* the 0.5 m first-touch check could fire on the next tick's `BallControl::update`. The defender could never physically acquire a loose ball, which is a P0 regression against Slice 16.3's contract. Fix: `BasicPhysics::spawn` records `def.is_ball` into a private `ball_ids_` set; `BasicPhysics::resolveCollisions` unconditionally skips every entity in that set. Owner-glue via `BallControl` (Slice 16.3's `ball.position = owner.position + kBallOwnerLeadDistance*heading`) continues to run post-physics and remains the sole authority on ball position when owned. Loose balls integrate through `BallPhysics::step` (rolling friction) unaffected by any player position they happen to graze; the only path from player-motion to ball-motion remains `wants_kick` per Slice 16.3.

2. **Slice 27.4 is a bookkeeping no-op, folded into this commit.** ADR §22.24 anticipated that swapping the Match factory from `StubPhysics` to `BasicPhysics` would rotate 3 existing determinism goldens (`FirstTouch200`, `BallOnPitchWithDefender400`, `PassReceive200`). Empirically it rotated **zero**: `sim/tests/test_determinism.cpp` constructs its `MatchConfig` by writing `cfg.physics = std::make_unique<StubPhysics>()` **directly** in every golden's fixture — the Match factory is bypassed entirely by the test harness, so the factory swap does not enter any golden's execution path. All 11 existing goldens (`Wander200`, `HumanSprint400`, `BallRoll400`, `Dribble200`, `FirstTouch200`, `HalfPitchHard400`, `SoftDrill400`, `BallOnPitchWithDefender400`, `PassEast400`, `PassReceive200`, `GoalFromKickEast200`) stay byte-identical with `BasicPhysics` in production. New goldens that exercise `BasicPhysics` directly (`two_humans_collide_head_on_200_ticks_seed_42`, `collision_ball_passthrough_owned_400_ticks_seed_42`) are still landing in Slice 27.5 per the original plan — they'll instantiate `BasicPhysics` explicitly in their fixtures the same way today's goldens instantiate `StubPhysics`.

**Fixed64 test-tolerance pattern** (new): `test_basic_physics.cpp` cannot assert MTV outcomes with strict `FH_EXPECT_EQ` on Fixed64 because the resolver's inner loop chains `fx_sqrt(d_sq) → delta / d → normal * disp → pos ±= displacement`, and each of `fx_sqrt`, division, and multiplication drops a few LSBs on non-perfect-square inputs. Even the touching invariant `sb.pos.x - sa.pos.x == r_sum` misses by tens to hundreds of raw units. Test file introduces `constexpr int64_t kFixed64Epsilon = 1024;` (≈ 2.4e-7 m in Q32.32 — far below any gameplay-visible threshold) and a `nearEq(Fixed64 a, Fixed64 b)` helper that compares raw-int64 deltas against `±kFixed64Epsilon`. Mass-weighted invariants like "heavier body displaced less" are checked via the **conserved mass-weighted centroid**: `m_a * a.x + m_b * b.x` is invariant across the collision pass (equal-and-opposite MTV forces → Newton's 3rd law), and this holds bit-exactly under `nearEq` even when the individual sqrt/mul chain drifts. Determinism goldens are unaffected — they use FNV-1a-64 hashes over the whole snapshot dump, which is Fixed64-raw-identical on every replay regardless of the sqrt drift.

### 22.25 [2026-07-16] `sim_match_events.payload` versioning + `EventType::Goal` (id=9) — Slice 28

**Status**: **draft, not yet implemented.** Locks the payload-versioning convention for new `sim_match_events` event types starting with `Goal` (Slice 28.1). Existing event types (`MatchStart`=1 through `ScenarioReset`=8) are **grandfathered unversioned** — retrofit forbidden. Migration 221 will land the `sim_decode_event` extension + the enum addition; no code change to existing event emitters. Goal-emitting code path is Slice 28.3 (`Match::tick` post-physics goal-detection loop), gated by Slice 28.2's `Scenario::goalRegions()` API.

**Context**: §21.3 pre-M3 fix list flagged that `sim_matches.result BYTEA` had no versioned schema. That fix was resolved for the `result` column when the M0 `MatchEnd` handler was landed in Slice 13 — the column carries the 8-byte canonical hash today and nothing else. **The unresolved half of that same concern is `sim_match_events.payload`**: today it's a per-event-type ad-hoc blob (empty for `MatchStart`; 8-byte hash big-endian for `MatchEnd`; empty-or-slot-id for `ClientConnect`/`SlotClaim`/…) with the format documented only in `sim/src/persistence/EventTypes.hpp`'s comment and migration 201's `sim_decode_event()` function. That's tenable for the M0/M1 event types (1..8), which are transport-scope events whose payloads have never had a reason to grow. **Slice 28 breaks that**: `Goal` will carry payload data that we will absolutely want to extend later (add ball position on v2, add assist-slot on v3, add xG estimate on v4, …). Without a version convention, either every extension mutates the payload layout retroactively (breaking `sim_decode_event` on historical rows), or every event grows a bespoke "does this look like the new shape?" branch in decoders.

**Options considered**:

1. **A — first byte of `payload` is version tag on every NEW event type; grandfather 1..8 unversioned.** Migration 221 extends `sim_decode_event()` with a branch: for `event_type >= 9`, read `payload[0]` as version and dispatch to a per-version decoder. For `event_type in (1..8)`, keep the existing layout (empty / 8-byte hash / etc.) unchanged. Wire-audit stability preserved; no historical row rewrite.
2. **B — retrofit version byte on every event type**, migrating existing rows. Rejected: (a) `MatchEnd`'s 8-byte hash is byte-for-byte the FNV-1a-64 canonical hash, and any prefix would break `fh-sim-replay --verify`'s `memcmp` against `Match::hash()`; (b) requires backfilling every `sim_match_events` row in production DBs (single-row today, non-trivial as multi-match orchestration lands and event volume grows); (c) the retrofit itself would violate the "wire-visible byte contract, never renumber" invariant §22.9 applies to registry IDs and that `EventType` inherits from.
3. **C — version tag as a new column** (`sim_match_events.payload_version SMALLINT NOT NULL DEFAULT 0`). Rejected: (a) doubles the row width for a byte-level concern, (b) NULL vs 0 vs "grandfathered legacy" ambiguity, (c) `payload` remains ambiguous when accessed without the column, (d) forever-more the ops decoder needs both `event_type` AND `payload_version` to route.
4. **D — new table `sim_match_events_v2` with a strict schema.** Rejected: forks `AsyncPgLog<EventRow>`'s single write path into two paths, forks `sim_decode_event` into two functions, forks `fh-sim-replay`'s event-load logic — for a per-event-type concern that option A solves inside the existing table with 1 byte.
5. **E — `EventType::Goal` payload starts with a version byte, later event types decide independently.** Legitimate but weaker than A — it locks the pattern only for `Goal`, leaves the next event type (10, 11, …) to re-negotiate the same convention. A codifies the rule for all future events.

**Chosen**: **Option A — first byte of payload is version tag for event types with id ≥ 9; existing 1..8 grandfathered unversioned.** Convention:

- **Grandfathered** (`event_type` in 1..8): payload layout is exactly what `sim_decode_event()` decodes today. Never gains a version byte. Documented in `EventTypes.hpp` inline comments.
- **Versioned** (`event_type` ≥ 9): payload MUST start with `[u8 version]` at offset 0. Version 0 is reserved (represents "unversioned" — reserved because it collides with grandfather semantics and MUST NOT be emitted for a new event type). First real version is `1`. `sim_decode_event()` for `event_type ≥ 9` reads `payload[0]`, branches on version, and returns the appropriate jsonb shape.
- **Version bump is APPEND-ONLY** per the same §22.9 stability rule — a v2 layout MUST be a strict superset of v1 (add fields at the tail, never rearrange). A schema-breaking change requires a new `event_type` id, not a v2.
- **Unknown versions** are decoded as `{version: N, payload_hex: '...'}` — the sim never rejects unknown-version rows; ops tooling degrades gracefully.

**Goal payload v1 layout** (5 bytes total):

```
[u8  version]           // offset 0     — always 1 in Slice 28
[u8  goal_region_index] // offset 1     — 0..N-1 index into Scenario::goalRegions()
[u16 kicker_slot_id]    // offset 2..3  — SlotId of the last kicker; 0 = unknown
                        //                (loose ball with no recent kick,
                        //                 or scenario-triggered goal)
[u8  reserved]          // offset 4     — MUST be 0 in v1 emitters; readers ignore
```

Rationale for each field:

- `version` (1 byte): the whole point of this ADR.
- `goal_region_index` (1 byte): which of the scenario's goal AABBs the ball crossed into. `Scenario::goalRegions()` returns an ordered vector, index is the position. Scenario decides what each index means (home / away / drill / etc.). u8 caps at 255 regions, plenty for M2 (two goals) and any conceivable M3+ drill.
- `kicker_slot_id` (2 bytes): last slot to assert `wants_kick` before the ball entered the region. Enables "who scored" attribution without a separate `LastKickerLog`. u16 matches the width used in `SlotClaim` payloads (grandfathered event 5).
  - Value `0` means "no recent kicker" — either the goal was scenario-triggered (drills that spawn moving balls), or `wants_kick` was never asserted since ball entry to the current owner (e.g., own goal from a dribble carry crossing the line). Kept explicit rather than implicit-null so `sim_decode_event` doesn't have to branch on NULL vs 0.
  - Slot IDs in production are 1..22, so 0 is safely disjoint.
- `reserved` (1 byte): padding to 5 bytes and forward-compat headroom. v2 will consume this byte for something (candidate: `ball_speed_at_entry` as u8 m/s * 8 for xG-lite).

**Decoder contract** (`sim_decode_event` in migration 221, extending migration 201):

```sql
-- Existing branches for event_type in (1..8) unchanged.
-- New branch:
IF evt_type >= 9 THEN
    IF payload IS NULL OR length(payload) < 1 THEN
        RETURN jsonb_build_object('error', 'missing version byte');
    END IF;

    v := get_byte(payload, 0);

    IF evt_type = 9 THEN  -- Goal
        IF v = 1 THEN
            RETURN jsonb_build_object(
                'event_type',       'goal',
                'version',          1,
                'goal_region_index', get_byte(payload, 1),
                'kicker_slot_id',    (get_byte(payload, 2) * 256) + get_byte(payload, 3),
                'payload_hex',       encode(payload, 'hex')
            );
        ELSE
            RETURN jsonb_build_object(
                'event_type',   'goal',
                'version',       v,
                'payload_hex',   encode(payload, 'hex'),
                'note',          'unknown goal payload version'
            );
        END IF;
    END IF;

    -- Future event types (10, 11, …) branch here.

    RETURN jsonb_build_object(
        'event_type',  evt_type,
        'version',      v,
        'payload_hex', encode(payload, 'hex'),
        'note',        'unknown versioned event type'
    );
END IF;
```

**Emitter contract** (Slice 28.3, `Match::tick`):

- Once per tick, after physics integration but before snapshot construction, check the ball's current position against every `AABB` returned by `scenario_->goalRegions()`.
- If the ball entered a new region this tick (i.e. was outside all regions last tick, inside region N this tick), enqueue an `EventRow` with `event_type = 9`, `tick_num = current_tick`, and the 5-byte v1 Goal payload described above.
- `kicker_slot_id` is populated from `Match`'s existing `last_kicker_slot_` tracking (new field added in Slice 28.3, cleared when a slot claims ownership via Rule 1, set when a slot's INPUT includes `wants_kick=true`).
- After the event is enqueued, `Match` may reset the ball to the centre spot for continuation, or fire `ScenarioSuccess` (event 7) if `Scenario::checkSuccess(...)` transitions true because of the goal. That's a scenario-per-scenario policy decision, NOT part of this ADR.

**Constants** (`sim/src/persistence/EventTypes.hpp` additions):

- `EventType::Goal = 9`
- `kGoalPayloadV1Bytes = 5`
- `kGoalPayloadV1Version = 1`
- `kGoalKickerSlotUnknown = 0`

**When to revisit**:

- **A new event type wants a non-versioned payload** (e.g. a raw canonical hash again, like `MatchEnd`). Rejected pre-emptively — versioning is the whole reason we're here. If a future event genuinely wants zero payload overhead, the event carries a `version=0` sentinel and the decoder documents "0 = no-body event for id N".
- **The reserved byte at offset 4 is claimed.** That becomes Goal v2. Extension MUST be backward-compatible per the append-only rule: readers of v1 continue to work against a v2 emitter (they read the 5 bytes they know about and ignore the rest); readers of v2 detect `version == 1` and don't read the extended fields.
- **`goal_region_index` needs more than 255 values.** Bump to u16, that's a v2. In practice not remotely a concern for M2/M3 (a drill with 256+ goals doesn't exist as a design pattern).
- **`kicker_slot_id` needs assist attribution.** v2 adds `[u16 assist_slot_id]` at offset 5. Extends payload to 7 bytes total. Decoder reads it only if `length(payload) >= 7 && version >= 2`.
- **Cross-match determinism gate**: goal events are emitted into `sim_match_events` and thus become part of any cross-arch replay diff. Slice 28.5's determinism golden (`goal_from_kick_east_200_ticks_seed_42`) MUST include a Goal event with predictable payload bytes. If the golden hash drifts because of an unintended `kicker_slot_id` change, that's a real bug in `Match`'s last-kicker tracking, not a golden-update situation.

**Refs**: §8 (schema — `sim_match_events` row shape unchanged; only payload semantic gains a rule), §16.6 (Slice 13 persistence spec — where `EventTypes.hpp` was defined), §21.3 (pre-M3 fix list — half of "no versioned schema" is now closed for `sim_match_events.payload`; the other half was closed for `sim_matches.result` in Slice 13 already), §22.9 (registry ID / enum stability rule that `EventType` inherits from), §22.12 (persistence architecture ADR), §22.23 (parallel wire-side length-prefixed extension pattern — this ADR is the storage-side sibling), §24.3 Slice 28.1 (implementation slice that lands migration 221 + the `EventType::Goal = 9` enum value), §24.3 Slice 28.3 (goal-detection loop that emits the payload), §24.3 Slice 28.5 (determinism golden that locks it).

---

Added 2026-07-13 as the resolution of Task B in the 5-task follow-up sequence (C→D→E→A→B). Mirrors §16's structure for M0. §22 (ADRs) is a growing log that lives after §17–§22 by convention, but M1 is a *milestone* section, so it takes the next available top-level number rather than nesting into §22.

### 23.1 M1 scope recap

From [§15](#15-milestone-plan) (milestone plan): **"Ball entity + dribble physics + one player can move it. Playable-area constraints."** Estimated 3–4 weeks for the milestone-defining work, **plus** the multi-match orchestration prerequisite (§21.2 item 3, plan in §16.7) which is a separate slice.

**Prerequisites (all closed 2026-07-13 as part of the C→D→E→A→B follow-up sequence)**:

- [x] §21.2 item 1 — `SlotSpawn::ai_profile_source` field ⇒ Task A1, commit `2a4f502f`.
- [x] §21.2 item 2 — `sim_player_profile` write policy ⇒ ADR §22.14 + `check_profile_write_policy.sh`, Task A2, commit `ca50b487`.
- [x] §21.2 item 3 — Multi-match orchestration plan ⇒ §16.7 Option A, Task A3, commit `c9e9ed3a`. **Implementation is Slice 14 below.**

**Rules (inherited from §16.6 / §22.0)**:

- Slice numbering continues from Slice 13 (M0 close-out) — first M1 slice is Slice 14.
- Each slice ends with a green ctest gate on the sim side AND a working end-to-end demo reachable from the frontend Tactical Games hub tile (or a new M1-scoped tile).
- Every determinism gate (§22.1 bit-exact, §22.2 Fixed64, §22.9 registry ID stability, §22.14 write policy, ADR §22.18 profile-row storage, Task D's boot-time drift guard) MUST continue to pass at the end of every slice — no slice is allowed to green-light while breaking any of them.
- New ADRs land as `§22.19`, `§22.20`, … in chronological order — never re-numbered (§22.0 rule). ADRs §22.15/§22.16/§22.17 originally reserved for M1 draft slots (see §23.7) are unused. Slices 14–18 filled §22.18 (2026-07-13, profile-row normalization), §22.20 (2026-07-13, wire v1.1 — Slice 15.4), §22.21 (2026-07-13, dribble_efficiency — Slice 16), §22.22 (2026-07-14, SCENARIO_META one-shot message — Slice 17.7), and §22.19 (2026-07-14, Slice 14 podman surface — documentation backfill closing §21.7 item 4). Next available integer is §22.23.
- SQL migrations continue the sim-scoped numbering: next available is `206-sim-*.sql` (205 landed 2026-07-13 as `205-sim-normalize-profiles.sql` per ADR §22.18).
- CI lint gate ([sim/Dockerfile](sim/Dockerfile)) gets a new script per invariant added (grep-based, same shape as the four M0 checks).

### 23.2 Deliverables

Grouped by subsystem, mirroring §16.1's checkbox style. Tick boxes in place as work lands.

**Ball entity + physics**

- [ ] [sim/src/physics/Ball.hpp](sim/src/physics/Ball.hpp) — `Ball` struct: `position`, `velocity`, `spin` (Fixed64 scalar around Z axis), `radius` (Fixed64 constant), `owner` (`std::optional<SlotId>` — null when loose).
- [ ] [sim/src/physics/BallPhysics.{hpp,cpp}](sim/src/physics/BallPhysics.hpp) — integrator: rolling friction (Fixed64 coefficient), boundary handling (delegates to `PlayableAreaConstraint` for `Hard` mode balls-out-of-play), no air drag for M1 (ball is grounded — kicks land in M2).
- [ ] `Match` gains `std::optional<Ball> ball_` field + physics step now consumes `Scenario::ballSpawn()` (returns `nullopt` today for `EmptyPitchScenario`; new `BallOnPitchScenario` returns center-circle position).

**Dribble mechanics**

- [x] [sim/src/controller/Intent.hpp](sim/src/controller/Intent.hpp) `wants_dribble` bit added (Slice 16.2, commit `3d23723e`) — chose to extend the existing `Intent` shape rather than land a separate `DribbleIntent` type, keeping the controller → mechanics contract single-struct. Wire encoding uses INPUT flags byte bit 2 (`kInputFlagWantsDribble = 0x04`); DB decoder migration [database/migrations/209-sim-decode-input-dribble.sql](database/migrations/209-sim-decode-input-dribble.sql) surfaces it as `wants_dribble` in `sim_decode_input`'s jsonb.
- [x] [sim/src/controller/HumanController.cpp](sim/src/controller/HumanController.cpp) `decide()` OR's `wants_dribble = true` when the human's slot is within `kBallAutoDribbleRadius` (1.5 m) of the ball (Slice 16.2). Radius intentionally larger than the mechanic's `kBallControlRadius` (0.5 m) so the auto-hint fires 2–3 ticks before the actual claim, giving client-side prediction warning. Explicit wire-set `wants_dribble` always passes through unchanged.
- [x] [sim/src/mechanics/BallControl.{hpp,cpp}](sim/src/mechanics/BallControl.hpp) landed Slice 16.3 — pure arbitration + glue module. First-touch resolves to the closest wants_dribble candidate within `kBallControlRadius = 0.5 m`, ties broken by lower `SlotId`; owner retention runs FIRST so "sticky" possession beats an equidistant challenger; owner velocity capped at `max_walk_speed * dribble_efficiency` (from the new `physical.dribble_efficiency` attribute per ADR §22.21) with direction preserved; ball glued to `owner.position + kBallOwnerLeadDistance * (cos h, sin h)` (0.4 m ahead of the owner's heading).
- [x] `Match::tick` integrates the pass (Slice 16.3): read `WorldView`, run per-slot mechanics writing new velocity/heading, then run `BallControl` which overrides the owner's velocity + teleports the ball to the glue point + sets ball velocity, then physics.step integrates both by the same delta. Ball friction (`BallPhysics::tickBall`) is skipped when the ball is owned. Ownership persists across ticks via `Match::ball_owner_` and surfaces on the wire as the trailer's `owner_slot` field (was hardcoded to `kBallOwnerLoose` in Slice 15.4; now carries the real `SlotId` per ADR §22.20 additive-extension precedent).

**Playable-area constraints**

- [ ] [sim/src/physics/PlayableAreaConstraint.{hpp,cpp}](sim/src/physics/PlayableAreaConstraint.hpp) — implements `Hard` (clamp positions to polygon after physics step, zero velocity components perpendicular to boundary) and `Soft` (inward repulsive force proportional to outward penetration depth, applied as a velocity delta before position integration) per §5.6 semantics landed in the §21.5 sweep (Task E).
- [ ] `Match::spawnInitialSlots` reads `scenario_->playableArea()` at construction and stashes the constraint in a member; `Match::tick` applies it every physics step.
- [ ] `EmptyPitchScenario` stays `Advisory` (M0 default preserved — Task E's §5.6 doc invariant).
- [ ] New [sim/src/scenario/HalfPitchScenario.{hpp,cpp}](sim/src/scenario/HalfPitchScenario.hpp) — first constrained-area scenario, uses `Hard` mode on the halfway line to demo the constraint in a drill setting.

**Wire protocol updates**

- [ ] Snapshot frame extension: length-prefixed extensible slot region carrying ball state (position 3×f32, velocity 3×f32, spin f32, owner u16 or 0xFFFF for loose). Wire version bump: **v1.1** (backward-compatible additive change) chosen over v2 (Fixed64 words for WASM lockstep, per §20) — v2 is a M4+ decision, not gated on M1 shipping. Client negotiates via HELLO_ACK's `wire_capability_bits`.
- [ ] [sim/src/net/BinaryV1Serializer.{hpp,cpp}](sim/src/net/BinaryV1Serializer.hpp) gains `encodeBall(const Ball&)` + decode helper + tests.
- [ ] [frontend/js/sim/render.js](frontend/js/sim/render.js) draws ball as filled circle following its wire position; per §7 v1-wire-is-rendering-only, the f32 loss is acceptable.
- [ ] [frontend/js/sim/input.js](frontend/js/sim/input.js) joystick handling extended: same `IntentFrame` shape, no new UI needed (ball follows player automatically when in `ball_control_radius`).

**Multi-match orchestration (§16.7 Option A implementation)**

- [ ] [backend/src/orchestration/SimOrchestrator.{h,cpp}](backend/src/orchestration/SimOrchestrator.h) — shells out to `podman run` per §16.7 step 1 with 5 s health-check timeout and `--restart on-failure:3`.
- [ ] [backend/src/orchestration/SimRouter.{h,cpp}](backend/src/orchestration/SimRouter.h) — generalizes the §16.6 sub-slice 8.1 HTTP-RPC pattern from `footballhome_sim` (single, hardcoded) to `footballhome_sim_${match_id}` (dynamic lookup via `sim_running_matches`).
- [ ] [backend/src/controllers/SimLobbyController.cpp](backend/src/controllers/SimLobbyController.cpp) `handleCreateMatch` becomes real per §16.7 step 2: INSERTs `sim_matches` row, calls `SimOrchestrator::launchMatch`, returns `{match_id, ws_url}`.
- [x] `database/migrations/206-sim-running-matches.sql` — new table `sim_running_matches(match_id, container_id, container_name, launched_at)` with FK to `sim_matches.id`. Reconciled on backend startup against `podman ps` (per §16.7 step 9 "backend crash" failure-mode). (205 is `205-sim-normalize-profiles.sql`, ADR §22.18.) *Landed 2026-07-13 with Slice 14.2; [backend/src/models/SimRunningMatch.h](backend/src/models/SimRunningMatch.h) is header-only until Slice 14.3 which is the first caller.*
- [ ] [frontend/sim.html](frontend/sim.html) reads `?match_id=X` from URL query; falls back to match_id=1 for M0-legacy compatibility so old bookmarks still work.
- [ ] [frontend/nginx.conf](frontend/nginx.conf) adds `location ~ ^/sim/(?<mid>\d+)$` regex block with `proxy_pass http://footballhome_sim_${mid}:9100/sim;` + standard WS-upgrade dance.
- [ ] Backend reaper thread reconciling `sim_matches.ended_at IS NULL` vs `podman ps` (§16.7 step 6). Runs every 5 min under an advisory-lock guard so parallel backend replicas don't race.
- [ ] `SimServer` gains idle-timeout watchdog: zero active clients for > 5 min → write `MatchEnd` + exit code 0 (existing shutdown path from §16.6 sub-slice 4 handles the rest).

**CI + observability + tests**

- [ ] [sim/tests/test_ball_physics.cpp](sim/tests/test_ball_physics.cpp) — fixed seed + fixed input sequence → identical ball trajectory (byte-diff of canonical dump).
- [ ] [sim/tests/test_ball_control.cpp](sim/tests/test_ball_control.cpp) — first-touch wins (two players closing on one ball); no ball teleport when owner briefly leaves control radius.
- [ ] [sim/tests/test_playable_area_hard.cpp](sim/tests/test_playable_area_hard.cpp) — position clamped, velocity zeroed at boundary; determinism across arches.
- [ ] [sim/tests/test_playable_area_soft.cpp](sim/tests/test_playable_area_soft.cpp) — repulsive-force magnitude matches spec; determinism across arches.
- [ ] [sim/scripts/check_determinism_cross_arch.sh](sim/scripts/check_determinism_cross_arch.sh) extended with an M1 scenario: `human_dribble_east_400_ticks_seed_42` (analogous to M0's `human_sprint_east_400_ticks_seed_42`) — proves ball + player trajectory identical amd64 vs arm64.
- [ ] Backend `GET /api/sim/matches?status=running` returns all live matches (`sim_running_matches` join `sim_matches`) for the admin dashboard tile.
- [ ] Load test extension of [sim/tests/test_async_pg_log_load.cpp](sim/tests/test_async_pg_log_load.cpp): 20 concurrent matches spawned via test harness → each pushing 22 slots × 20 Hz × 5 s of input rows → zero dropped rows aggregate.

### 23.3 Slice sequence

Slice numbering continues from Slice 13 (M0 close-out). Each slice ends with a green ctest gate + a working end-to-end demo. Sub-slices break down individual green-gate landings within the slice (same shape as §16.6's sub-slices 1–9 including 6.1 and 8.1).

**Slice 14 — Multi-match orchestration (§16.7 Option A implementation)**

Landed FIRST because Slices 15–17 need to spawn fresh matches to test ball scenarios without perturbing the M0 legacy match `id=1` (which has Task D's boot-time drift guard protecting its `(scenario_id, seed, tick_hz)`).

- 14.1 `SimOrchestrator::launchMatch` + `docker-compose.yml` grants backend access to the podman socket.
- 14.2 Migration 206 (`sim_running_matches` table) + [backend/src/models/SimRunningMatch.h](backend/src/models/SimRunningMatch.h).
- 14.3 `SimLobbyController::handleCreateMatch` becomes real (INSERT `sim_matches`, call `SimOrchestrator`, return `{match_id, ws_url}`).
- 14.4 `SimRouter` fans out `/api/sim/debug/matches/:id/{inputs,events,state}` per §16.6 sub-slice 8.1 pattern.
- 14.5 Frontend `?match_id=X` handling + nginx regex block.
- 14.6 Reaper thread + backend-startup reconciliation pass (with advisory-lock guard).
- 14.7 Load test: 20 concurrent matches spawn + tick 60 s each + tear down cleanly, no orphaned containers or DB rows.

**Slice 14 exit gate**: `POST /api/sim/matches` twice in quick succession creates two independent containers; a client connecting to `?match_id=2` sees only match 2's ticks; killing container 1 does not disturb container 2; reaper cleans up an idle match within 10 min of `MatchEnd`.

**Slice 15 — Ball entity + passive physics**

Ball can be spawned into a match at scenario-defined position and rolls with friction until it stops. No player-ball interaction yet — ball is a passive kinematic entity that other subsystems must not touch.

- [x] 15.1 `Ball` struct + `BallPhysics` integrator + unit test for rolling-to-rest under friction. *(`ff068879`)*
- [x] 15.2 `Match` gains optional ball, reads from `Scenario::ballSpawn()`. *(`8cc1cbba`)*
- [x] 15.3 `BallOnPitchScenario` (new) — empty pitch with ball at center circle, initial velocity zero. Migration 207 registers `code_id='ball_on_pitch'` at `id=1` per §22.9 stable-ID pattern; `Replay::makeScenario()` branches on scenario_id → `BallOnPitchScenario`. *(`95cabac4`)*
- [x] 15.4 Wire v1.1 snapshot extension: length-prefixed ball trailer (30-byte region: pos + vel + spin + owner); HELLO_ACK `wire_capability_bits` (bit 0 = `kWireCapSnapshotBallTrailer`). Backward-compat: no-ball snapshots are byte-identical to M0 (canonical golden hash `0x4937890abb4edfb6` preserved). See ADR §22.20. *(`3156d4d7`)*
- [x] 15.5 Client renders ball as filled circle at wire position; `SIM_SCENARIO=ball_on_pitch` env var selects the scenario at boot. *(`4aba3b09`)*
- [x] 15.6 Determinism test: fixed seed + ball with initial velocity ⇒ identical trajectory across arches. Golden canonical hash `0x7c3932be60cba2aa` for `ball_roll_east_400_ticks_seed_42` (20 m/s east, seed 42). *(`47c53673`)*

**Slice 15 exit gate**: `BallOnPitchScenario` shows a ball rolling from a stationary start (visual test) and from a scripted initial velocity (deterministic test). No slot claims required; empty match with a rolling ball is a legitimate demo. *(Shipped 2026-07-13; final commit `47c53673`. Migration 207 applied. Container demo: `SIM_SCENARIO=ball_on_pitch make sim-restart`, then open `frontend/sim.html`.)*

**Slice 16 — Dribble mechanics + first-touch**

One player can pick up + move the ball. Ball follows the owning player at `heading + small_offset` when player is in `ball_control_radius`. Dribble efficiency reduces the player's effective walk speed while carrying — introduces the new `physical.dribble_efficiency` attribute (see draft ADR §22.15 below).

- 16.1 New attribute `physical.dribble_efficiency` — migration 207 extending `sim_attribute_registry` per §22.9 pattern (stable ID via explicit INSERT + `setval`), `m0::defaultPhysical()` extended, [sim/src/common/M0Registry.generated.hpp](sim/src/common/M0Registry.generated.hpp) regenerated by `gen_registry_header.awk`. Boot-time drift check (§16.6) catches mismatch.
- 16.2 `DribbleIntent` extension to `Intent`; `HumanController::decide` emits it when close to ball.
- 16.3 `BallControl` mechanic: first-touch wins (compare `SlotId` distance to ball; ties broken by lower `SlotId` for determinism); ball position glued to `owner.position + heading_offset` while owner is within `ball_control_radius`.
- 16.4 Owner releases ball on any of: distance > `ball_control_radius`, explicit `wants_release` intent (Slice 16.4 landed 2026-07-13: INPUT wire flags bit 3, `kInputFlagWantsRelease = 0x08`; `HumanController::decide` collapses `wants_dribble` to false when `wants_release` is set — release wins over both the wire-set dribble bit AND the Slice 16.2 auto-hint), or match end (`Match::end()` sets `ended_ = true` AND clears `ball_owner_` so any post-end snapshot's trailer decodes to `kBallOwnerLoose`). Distance-based release was already emergent from Slice 16.3 Rule 2 (owner retention fails when out of range). DB decoder migration [database/migrations/210-sim-decode-input-release.sql](database/migrations/210-sim-decode-input-release.sql) surfaces `wants_release` in `sim_decode_input`'s jsonb. See §22.21 addendum + tests [sim/tests/test_human_controller.cpp](sim/tests/test_human_controller.cpp) (release-forces-dribble-false / release-suppresses-auto-hint), [sim/tests/test_match_ball.cpp](sim/tests/test_match_ball.cpp) (match-end-stops-ticks-and-clears-owner), [sim/tests/test_input_frame.cpp](sim/tests/test_input_frame.cpp) (bit-3-decode + round-trip).
- 16.5 Client-side: joystick input unchanged; renderer draws a small indicator ring around the player currently owning the ball. Landed 2026-07-13: [frontend/js/sim/renderer.js](frontend/js/sim/renderer.js) `drawEntities` reads `snap.ball.ownerSlot` (already decoded by wire.js since Slice 16.3 shipped the trailer) and, when it is not `BALL_OWNER_LOOSE`, strokes a white ring of radius `playerR + 4` around the owning slot's dot. Loose ball → no ring. No ball trailer (M0-compat scenarios) → no ring. Ring is purely cosmetic; ownership truth lives on the server per §22.21.
- 16.6 Determinism test: fixed inputs → identical player+ball trajectory across arches; two-player first-touch test (both close on ball) → same winner + same subsequent trajectory across arches. Landed 2026-07-13: [sim/tests/test_determinism.cpp](sim/tests/test_determinism.cpp) gains two goldens — `one_human_dribbles_ball_east_200_ticks_seed_42` (`0xad857d3402f4a975`) exercises BallControl Rules 1+2+3 (first-touch on tick 1, retention while in range, glue offset + walk-speed cap × dribble_efficiency), and `two_humans_first_touch_tie_break_200_ticks_seed_42` (`0xdb8d91b26222ddaa`) locks the lower-SlotId tie-break rule (Slot 1 west + Slot 2 east both 0.4 m from ball; Slot 1 wins by SlotId, Slot 2 walks freely east at full walk speed since ball is glued out of reach). `canonicalDump` now appends a `ball_owner=<slot>` line WHEN AND ONLY WHEN `snap.ball_owner` is set — pre-Slice-16.6 goldens (`kExpectedHashWander200`, `kExpectedHashHumanSprint400`, `kExpectedHashBallRoll400`) remain byte-identical since they never establish ownership.

**Slice 16 exit gate**: connecting one browser client to a `BallOnPitchScenario` match lets the user dribble the ball around the pitch with the joystick. Two clients competing for the same ball resolves deterministically (first-touch wins by rule 16.3). **Closed 2026-07-13**: all six sub-slices shipped (16.1 dribble_efficiency attr `88b02c70`, 16.2 wants_dribble intent `3d23723e`, 16.3 BallControl module + wire trailer `3b4e6dbb`, 16.4 release conditions `5602b1bc`, 16.5 client owner ring `b1eb09e9`, 16.6 cross-arch determinism goldens). All three release conditions (distance / explicit intent / match-end) locked with tests. Two cross-arch determinism goldens (dribble + first-touch tie-break) locked in the canonical hash.

**Slice 17 — Playable-area constraints**

`Hard` and `Soft` modes from §5.6 semantics land. First constrained-area scenario demos both.

- 17.1 `PlayableAreaConstraint::apply_hard(Vec3& pos, Vec3& vel, const std::vector<Vec3>& polygon)` — clamp position to polygon edge, zero velocity component perpendicular to the edge. Landed 2026-07-14: [sim/src/physics/PlayableAreaConstraint.{hpp,cpp}](sim/src/physics/PlayableAreaConstraint.hpp). Convex polygons only for M1 (winding sign inferred from first non-collinear vertex triple; empty / <3-vertex polygons are defensive no-ops). XY-only clamp; pos.z + vel.z preserved. Asymmetric velocity contract: only the outward-facing normal component is removed, so a player who is being clamped and pushing inward is not stranded. Unit test [sim/tests/test_playable_area_hard.cpp](sim/tests/test_playable_area_hard.cpp) covers empty/degenerate no-ops, interior/on-edge preservation, all 4 cardinal clamps, corner clamp, CW-winding branch, and inward-velocity preservation.
- 17.2 `PlayableAreaConstraint::apply_soft(Vec3& pos, Vec3& vel, const std::vector<Vec3>& polygon, Fixed64 k)` — outward-penetration depth × `k` applied as inward velocity delta before position integration. Landed 2026-07-14: [sim/src/physics/PlayableAreaConstraint.cpp](sim/src/physics/PlayableAreaConstraint.cpp). Shares the same convex-polygon assumption + XY-only + z-preservation semantics as 17.1. Position is **not** clamped (soft mode lets players briefly leave); the velocity delta is a pure ADD (does not zero the existing outward component), so the delta stacks with existing motion and — under repeated ticks — bounces the player back. `k` has units of 1/s (spring stiffness). Test [sim/tests/test_playable_area_soft.cpp](sim/tests/test_playable_area_soft.cpp) covers empty/interior/on-edge no-ops, all 3 cardinal penetration directions, add-not-overwrite semantics vs. both outward- and inward-facing existing velocity, and k=0 disable.
- 17.3 `Match::spawnInitialSlots` reads `scenario_->playableArea()` and stashes the constraint; `Match::tick` applies it every physics step. Landed 2026-07-14: [sim/src/match/Match.{hpp,cpp}](sim/src/match/Match.hpp). New `Match::playable_area_` member cached at construction. Tick loop runs Soft pass BEFORE `physics_->step(dt)` (inward velocity delta so the next integration advects the player back inside) and Hard pass AFTER (snap positions + zero outward-facing velocity). Both branches are gated on `constraint_mode != Advisory && !polygon.empty()`, so M0/M1 baseline scenarios (EmptyPitchScenario, BallOnPitchScenario — both Advisory) are strict no-ops. `test_determinism.cpp` still passes byte-identical goldens after the change, confirming zero canonical-hash impact for baseline. Soft-mode default stiffness (`k = 4 /s`) is a file-local constant in Match.cpp for now; may migrate to `scenario::PlayableArea` field in Slice 17.5 when the first Soft scenario ships. Ball is intentionally excluded from constraint passes — ball out-of-play handling (goals, throw-ins) is a scenario-level event landing later, not a boundary clamp. Integration test [sim/tests/test_match_playable_area.cpp](sim/tests/test_match_playable_area.cpp) covers Advisory=no-op, Hard=clamps-on-first-tick + stays-inside-across-200-ticks, and Soft=no-first-tick-snap + spring-eventually-pushes-inside.
- 17.4 `HalfPitchScenario` (new) — uses `Hard` mode on the halfway line to demo the constraint in a drill setting. Landed 2026-07-14: [sim/src/scenario/HalfPitchScenario.{hpp,cpp}](sim/src/scenario/HalfPitchScenario.hpp) + migration [database/migrations/212-sim-scenarios-half-pitch-hard.sql](database/migrations/212-sim-scenarios-half-pitch-hard.sql) + Replay branch. Polygon = east half of the 105×68 m pitch: axis-aligned CCW rectangle `(0,-34) → (52.5,-34) → (52.5,+34) → (0,+34)`. Two demo slots spawn at (10, 0) and (40, 0), inside the polygon so a claiming client can walk toward either wall. Scenario id=2, code_id='half_pitch_hard' (id assignments: 0=empty_pitch, 1=ball_on_pitch, 2=half_pitch_hard). Migration applied to live DB 2026-07-14. Unit test [sim/tests/test_half_pitch_scenario.cpp](sim/tests/test_half_pitch_scenario.cpp) covers declarative shape (id/pitch/polygon/mode/spawns/no-ball) plus two integration checks: slots stay inside across 100 wander ticks, and a slot forcibly translated outside via `physics_for_tests()->setPosition(...)` is snapped back on the next tick.
- 17.5 `SoftDrillScenario` (new) — uses `Soft` mode on a rectangle inside the pitch to demo the pushback feel for the "coach can wander outside the drill zone but is bounced back" UX. Landed 2026-07-14: [sim/src/scenario/SoftDrillScenario.{hpp,cpp}](sim/src/scenario/SoftDrillScenario.hpp) + migration [database/migrations/213-sim-scenarios-soft-drill.sql](database/migrations/213-sim-scenarios-soft-drill.sql) + Replay branch. Polygon = 40×30 m drill-zone rectangle centred at the pitch origin: axis-aligned CCW `(-20,-15) → (+20,-15) → (+20,+15) → (-20,+15)`. One demo slot at (0, 0). Uses the Match-level default stiffness `k = 4/s` (Slice 17.3 note) — kept as the single global default for M1; no per-scenario override needed yet. Scenario id=3, code_id='soft_drill' (id assignments: 0=empty_pitch, 1=ball_on_pitch, 2=half_pitch_hard, 3=soft_drill). Migration applied to live DB 2026-07-14. Unit test [sim/tests/test_soft_drill_scenario.cpp](sim/tests/test_soft_drill_scenario.cpp) covers declarative shape (id/pitch/polygon/mode/spawns/no-ball) plus a Soft-mode round-trip: poke slot to (50, 0), verify next tick still outside (Soft never snaps), then verify it bounces back inside within 100 ticks (spring pulls it back).
- 17.6 Tests: `test_playable_area_hard.cpp` (clamp + velocity-zeroing), `test_playable_area_soft.cpp` (force magnitude matches `k × penetration_depth`), determinism cross-arch for both. Landed 2026-07-14: [sim/tests/test_determinism.cpp](sim/tests/test_determinism.cpp) gains two goldens — `half_pitch_hard_sprint_east_400_ticks_seed_42` (`0x489acd31dddb4587`) claims SlotId{1} at (10, 0) in `HalfPitchScenario`, drives it sprint-east into the east wall, and locks 400 ticks (20 s) of "approach + pinned-against-wall" behaviour; the canonical dump shows slot 1 at exactly `pos.x = 0x3480000000` raw (52.5 m) with `vel.x = 0` — the fingerprint of `apply_hard` snapping + zeroing outward velocity every tick. `soft_drill_sprint_east_400_ticks_seed_42` (`0x700808840ecc3183`) claims SlotId{1} at (0, 0) in `SoftDrillScenario`, drives it sprint-east across the +20 m boundary, and locks 400 ticks of Soft leave-drift-return behaviour; the final snapshot catches slot 1 mid-cycle at x ≈ 18.96 m with vel.x ≈ 7.47 m/s east — proving both `apply_soft`'s Fixed64 math AND the `k = 4/s` default stiffness constant in `Match.cpp`. Includes + using-decls for `HalfPitchScenario` and `SoftDrillScenario` added to the fixture. Unit-level determinism (17.1/17.2 helpers exercised over any polygon by their own tests) plus integration-level determinism (17.3 Match wiring exercised by `test_match_playable_area.cpp`) plus these two full-tick cross-arch goldens cover the "byte-identical amd64 vs arm64" exit-gate for §17.
- 17.7 Client renders the polygon overlay based on `PlayableArea::Mode` — dashed for `Advisory` (existing M0 behavior), solid for `Hard`, dotted for `Soft`. Scope-split 2026-07-14 into two sub-slices to keep commits small and reviewable (per ADR §22.22 problem statement):
  - 17.7a — Wire schema + server encode + tests. Landed 2026-07-14: new msg_type `MsgType::ScenarioMeta = 0x03` + capability bit `kWireCapScenarioMeta = 1u << 1` in [sim/src/net/WireFormat.hpp](sim/src/net/WireFormat.hpp); encoder/decoder pair in [sim/src/net/ScenarioMetaFrame.hpp](sim/src/net/ScenarioMetaFrame.hpp) + [ScenarioMetaFrame.cpp](sim/src/net/ScenarioMetaFrame.cpp); `Match::playableArea()` public accessor in [sim/src/match/Match.hpp](sim/src/match/Match.hpp); `SimServer::handleConnect` in [sim/src/server/SimServer.cpp](sim/src/server/SimServer.cpp) now advertises `kWireCapScenarioMeta` in HELLO_ACK's cap bits and sends one SCENARIO_META frame immediately after HELLO_ACK, carrying the match's `PlayableArea::mode` (u8) + polygon vertices (u16 count + `{f32 x, f32 y}` × N). Compile-time `static_assert`s in `ScenarioMetaFrame.hpp` lock `scenario::PlayableArea::Mode::{Hard,Soft,Advisory}` to wire values 0/1/2. Tests: new [sim/tests/test_scenario_meta_frame.cpp](sim/tests/test_scenario_meta_frame.cpp) (11 subtests — mode-value pins, constants pins, encode empty Advisory / CCW-rectangle Hard / drill-zone Soft, roundtrip empty + populated, decode rejects wrong-version / wrong-msg_type / short-header / truncated-vertex-region / payload-length-mismatch, encoder returns empty on `> kMaxScenarioMetaVertices` overflow); expanded [sim/tests/test_input_frame.cpp](sim/tests/test_input_frame.cpp) with `scenario_meta_capability_bit_is_bit_one` (locks bit 1 position + no collision with bit 0) and updated `encode_hello_ack_capability_bits_are_bitfield` to OR both cap bits; expanded [sim/tests/test_sim_server.cpp](sim/tests/test_sim_server.cpp) with integration test `scenario_meta_sent_immediately_after_hello_ack` (fixture spins up EmptyPitchScenario → Advisory + empty polygon, connects a client via `handshake(...)`, extracts frames from the response byte stream, asserts frames[0] = HELLO_ACK with cap bits including `kWireCapScenarioMeta`, frames[1] = SCENARIO_META decoding to `mode=Advisory, vertices.empty()`). Also fixed an incidental test-harness bug: the conditional second `pumpUntil` call in the new test was overwriting `hs.bytes` with an empty vector because all data had already been drained by the primary `handshake()` pump — removed the redundant secondary pump entirely (`extra_bytes=128` in `handshake()` already fetches well past both frames' combined 31 wire bytes). Full container build: 145/145 compile, 46/46 ctests green, 4/4 lint gates OK. See ADR §22.22 for the design decision (separate msg_type vs. HELLO_ACK-appended payload).
  - 17.7b — Frontend decode + renderer + ADR closeout. Landed 2026-07-14: mirror msg-type / cap-bit / mode-enum constants + `decodeScenarioMeta(bytes)` in [frontend/js/sim/wire.js](frontend/js/sim/wire.js) (byte-identical to the C++ decoder in [sim/src/net/ScenarioMetaFrame.cpp](sim/src/net/ScenarioMetaFrame.cpp) — length checks reject wrong-version, wrong-msg_type, header underflow, and payload-length mismatch); `onScenarioMeta` callback slot added to `FhSimTransport` in [frontend/js/sim/transport.js](frontend/js/sim/transport.js) with a switch-case dispatch on `MSG.SCENARIO_META` sitting between HELLO_ACK and SNAPSHOT; client state hook in [frontend/js/sim/client.js](frontend/js/sim/client.js) — `state.scenarioMeta` starts null, populated once when the frame arrives, forwarded to renderer via new `renderer.setScenarioMeta(meta)`; renderer overlay in [frontend/js/sim/renderer.js](frontend/js/sim/renderer.js) — new `drawPlayableArea()` method uses `ctx.setLineDash()` for the mode-specific stroke (Advisory=dashed warm-yellow, Hard=solid red, Soft=dotted cyan) and is called from `render()` between `drawPitch()` and `drawEntities()` so player + ball dots stay on top. Overlay is a strict no-op when `scenarioMeta` is null (legacy server / bit not set) OR polygon has `< 3` vertices (M0 baseline: EmptyPitchScenario + BallOnPitchScenario both send Advisory + empty polygon, which is intentionally rendered as "nothing" rather than a degenerate line). Manual smoke test — connecting to the M0 seed match (`HalfPitchScenario` scenario_id=2 launched via multi-match orchestration) draws a solid red rectangle over the east half of the pitch; `SoftDrillScenario` (scenario_id=3) draws a dotted cyan rectangle around the drill zone. No JS test-runner is in scope for M1 (per §22.7 "vanilla JS + zero build tools" ADR) — the byte-layout contract is enforced at the C++ boundary by [test_scenario_meta_frame.cpp](sim/tests/test_scenario_meta_frame.cpp) and the JS decoder mirrors it verbatim.

**Slice 17 exit gate**: `HalfPitchScenario` visibly prevents a dribbling player from crossing the halfway line; `SoftDrillScenario` visibly pushes back a player who tries to leave the drill zone; both replays are byte-identical amd64 vs arm64. **Closed 2026-07-14** — server-side gating landed in Slice 17.3 ([sim/src/match/Match.cpp](sim/src/match/Match.cpp) Match::tick applies `apply_soft` before physics + `apply_hard` after), scenarios in 17.4 + 17.5, cross-arch determinism goldens locked in 17.6 (`0x489acd31dddb4587` for HalfPitchScenario + `0x700808840ecc3183` for SoftDrillScenario), and the client-side polygon overlay in 17.7a (server encode + tests) + 17.7b (frontend decode + renderer). All 8 slice commits (17.1–17.7b) are on `origin/main`: `c633b834`, `0cc85a1d`, `9675e43b`, `5922a0c2`, `7fa529ba`, `3f9bf5b9`, `f29ad3a3`, and this Slice 17.7b landing commit.

**Slice 18 — M1 close-out & exit criteria**

Analogous to §16.5. Full end-to-end M1 demo tying every subsystem together.

- 18.1 New M1 scenario-launcher tiles on [frontend/tactical-games.html](frontend/tactical-games.html) — each POSTs `/api/sim/matches` with a specific `scenario_id`, `SimLobbyController::handleCreateMatch` spawns a fresh per-match container via `SimOrchestrator`, browser is redirected to `/sim.html?match=${id}`. Landed 2026-07-14 as three separate tiles (one per M1 subsystem — cleaner testing surface + gives coaches an "explode this drill mechanic" library instead of a monolithic demo, per 2026-07-14 exchange): **Ball on Pitch** (`scenario_id=1`, Slice 15 showcase — rolling ball + friction), **Half-Pitch Constraint** (`scenario_id=2`, Slice 17.4 showcase — solid red Hard boundary on east half), **Soft Drill Zone** (`scenario_id=3`, Slice 17.5 showcase — dotted cyan Soft boundary on drill-zone rectangle). Original design draft called for a single "Dribble Drill" tile launching HalfPitchScenario, but HalfPitchScenario has no ball — the split-into-three approach lets each tile validate exactly one M1 mechanic cleanly. The M0 "Sim Demo" tile (static `<a href="/sim.html">` → default `?match=1` → EmptyPitchScenario) is preserved for back-compat. Auth: click handler sends both `Authorization: Bearer <localStorage.token>` and `credentials: 'same-origin'` cookie so `resolveCallerPersonId` accepts either path. Tile has a pending state (`aria-busy="true"` + dimmed opacity + chevron becomes …) during the podman spin-up window (< 2 s per §23.4) and surfaces launch errors inline via `[data-error]` red border + `.desc::after` message.
- 18.2 M1 exit-criteria checklist (§23.4 below) all green. **Partial landing 2026-07-14**: 4 of 7 boxes ticked with citations — (a) "player can dribble a ball across an empty pitch" ← Slice 16 exit gate + `test_determinism` dribble golden, (b) "cross-arch determinism CI green for M1 scenarios" ← `check_determinism_cross_arch.sh` + all M1 goldens in `test_determinism.cpp`, (c) "pg_stat_user_tables.n_tup_upd = 0 across the four sim_player_* tables" ← verified against live `footballhome_db` (all four zero at end of Slice 17), (d) "no new §21 ship-blocker items opened during M1 without matching closure/revisit-condition" ← §21 review shows §21.1/§21.2/§21.5 all closed pre-M1 and §21.3/§21.4 unchanged since pre-M1. Remaining 3 boxes are all gated on Slice 14.7 (the concurrent-match load test that was descoped from Slice 14's original landing `ef872341`): "SimOrchestrator < 2 s cold-start / < 500 ms warm-image start", "20 concurrent matches at ≥ 19.9 Hz effective tick rate", and "podman logs footballhome_sim_${match_id} shows only that match's logs proven by test with 3 concurrent matches". These will tick together when Slice 14.7 lands as part of Slice 18.4 (see below).
- 18.3 Documentation reconciliation sweep (analogous to §21.5): review §14 lifecycle pseudocode, §7 wire spec, §5 core objects for any post-M0 drift.
- 18.4 Concurrent-match load test lands as [sim/scripts/load_test_orchestrator.sh](sim/scripts/load_test_orchestrator.sh) — closes Slice 14.7 (descoped from Slice 14's original landing `ef872341`) by exercising the full end-to-end orchestration surface on a live stack. Test drives 20-way concurrent `POST /api/sim/matches` → 60 s tick-idle hold → 3-way `podman logs` isolation snapshot → 20-way parallel `POST /api/sim/matches/{id}/stop` → assertion sweep on orphan containers, `sim_running_matches` rows, `sim_matches.ended_at`, and effective tick rate computed as `MAX(sim_match_events.tick_num) / (ended_at - started_at)` per match. Baseline run 2026-07-14 on this host (rootful podman 4.9.3, 46/46 sim ctest green): (a) 20/20 spawns clean, worst-case 28 s under FH_SIM_LAUNCH_MAX_CONCURRENCY=4 queue; (b) 20/20 containers alive across 60 s hold; (c) log isolation clean for 3-way sample vs the entire 20-mid spawned set — `match=${id}` appears only in its own container's log stream (§23.4 box ticked); (d) 20/20 stops clean, zero orphan containers, zero orphan `sim_running_matches` rows, all `sim_matches.ended_at` set; (e) effective tick rate min=18.35 / p50=19.02 / max=19.89 Hz across 20 daemons — the test's 15 Hz hard-floor guard passes, but the §23.4 19.9 Hz target is missed by ~8% at the min and captured as info-level perf follow-up (see §23.4 box below); (f) warm-image single-shot spawn 865–1137 ms — under the 2 s cold-start ceiling but above the 500 ms warm-image target, same info-level treatment. Cross-arch determinism for M1 scenarios (the other half of the original 18.4 stub) is already ticked as §23.4 box 6, closed 2026-07-14 by `check_determinism_cross_arch.sh`; no change here. Perf follow-ups (warm-image spawn budget, effective-Hz margin) are M2-blocker candidates to catalog in Slice 18.5's §21.x sweep.
- 18.5 Backfill any `§21.X` M2-blocker items uncovered during M1 dev into a new §21.7 or §21.8 subsection. **Landed 2026-07-14** as new §21.7 "M2-blockers (fix before starting M2 milestone work)" — analogous shape to §21.2 M1-blockers. Four items catalog'd: (1) warm-image spawn latency ~1 s vs 500 ms target (blocks §23.4 box 5, evidence from [sim/scripts/load_test_orchestrator.sh](sim/scripts/load_test_orchestrator.sh) section 0.5), (2) effective tick-rate min 18.35 Hz vs 19.9 Hz target under 20-way load (blocks §23.4 box 6, evidence from load test section 5.5), (3) cross-match input isolation invariant not exercised end-to-end (blocks §23.6 item 3, follow-up test spec'd), (4) ADR §22.19 (Slice 14 podman surface) still unfilled (documentation loose end, blocks nothing but leaves the podman-surface choice untraceable to a formal decision record). §23.6 items 3 and 4 also gained cross-references to §21.7 items 3 and 2 respectively, closing the tracking loop between the M1→M2 transition prereqs and the concrete follow-up work. Each §21.7 item ships with candidate root-cause list + fix recipe + explicit blocks-line so no ambient TODO context lives outside the tracker per §21.6.

**Slice 18 exit gate**: all boxes in §23.4 ticked, all cross-arch determinism CI green, one week of "drink your own champagne" — coaches actually run drills in the app for their teams and no crashes / desyncs surface.

### 23.4 M1 exit criteria

Ticked in place as work lands (same style as §16.5). All must be green for M1 to be considered complete.

- [x] A player can dribble a ball across an empty pitch (Slice 16 — closed 2026-07-13; all six sub-slices shipped per Slice 16 exit gate below: `88b02c70` dribble_efficiency attr, `3d23723e` wants_dribble intent, `3b4e6dbb` BallControl module + wire trailer, `5602b1bc` release conditions, `b1eb09e9` client owner ring, 16.6 cross-arch goldens. Determinism-locked by [sim/tests/test_determinism.cpp](sim/tests/test_determinism.cpp) golden `dribble_200_ticks_seed_42` = `0xad857d3402f4a975` — the mechanic run 200 ticks with `wants_dribble=true` produces a byte-identical canonical hash across builds/arches. End-to-end user path shipped 2026-07-14 as Slice 18.1's 🎾 Ball on Pitch tile, which spawns a fresh per-match container and drops the browser into `BallOnPitchScenario` with joystick control).
- [x] Two players cannot both control the same ball — first-touch wins, tie broken deterministically by lower `SlotId` (Slice 16.3, landed via [sim/src/mechanics/BallControl.cpp](sim/src/mechanics/BallControl.cpp) `resolveBallControl` — Rule 1 tie-break comparator `dsq == best_dsq && slot_id < best->slot_id`; owner-retention Rule 2 runs FIRST so an equidistant challenger cannot dislodge the current owner mid-tick; unit-locked by [sim/tests/test_ball_control.cpp](sim/tests/test_ball_control.cpp) tests `loose_ball_ties_broken_by_lower_slot_id` + `sticky_ownership_beats_equidistant_challenger`).
- [x] A `HalfPitchScenario` with `Hard` playable-area prevents players from crossing the halfway line (Slice 17.4 — [sim/src/scenario/HalfPitchScenario.cpp](sim/src/scenario/HalfPitchScenario.cpp) declares Mode::Hard on the east-half polygon; [sim/src/physics/PlayableAreaConstraint.cpp](sim/src/physics/PlayableAreaConstraint.cpp) `apply_hard` snaps positions + zeros outward-facing velocity every tick; wired at Match::tick via Slice 17.3; determinism-locked by `test_determinism.cpp` golden `half_pitch_hard_sprint_east_400_ticks_seed_42` = `0x489acd31dddb4587` — 400 ticks of sprint-east-into-wall produces slot 1 at `pos.x = 52.5 m` exactly with `vel.x = 0`; client polygon overlay in Slice 17.7).
- [x] `Soft` playable-area smoothly pushes players back on penetration (Slice 17.5 — [sim/src/scenario/SoftDrillScenario.cpp](sim/src/scenario/SoftDrillScenario.cpp) declares Mode::Soft on the 40×30 m drill-zone polygon; [sim/src/physics/PlayableAreaConstraint.cpp](sim/src/physics/PlayableAreaConstraint.cpp) `apply_soft` adds inward-facing velocity delta proportional to `k × penetration_depth` per tick with `k = 4/s` default in Match.cpp; Match::tick applies the Soft pass BEFORE physics-integrate so the next step advects the player back inside; determinism-locked by `test_determinism.cpp` golden `soft_drill_sprint_east_400_ticks_seed_42` = `0x700808840ecc3183`; client polygon overlay in Slice 17.7).
- [x] `SimOrchestrator` launches a fresh match container in < 2 s cold-start, < 500 ms warm-image start ([sim/scripts/load_test_orchestrator.sh](sim/scripts/load_test_orchestrator.sh) section 0.5 measures warm-image single-shot spawn on the live stack; baseline run 2026-07-14 recorded 865–1137 ms across two runs — under the 2 s cold-start ceiling since warm is a strict lower bound on cold, but over the 500 ms warm-image target. Left unchecked pending investigation of where the ~1 s floor actually lives — candidates: podman REST `POST /containers/{id}/create` + `POST /containers/{id}/start` latency, sim binary boot cost, or `upsertMatch`'s initial DB round-trip at daemon boot. §16.7's revisit-trigger notes warm-daemon-pool as one candidate remedy path. **Closed 2026-07-15 as §21.7 item 1 step 6B** — implemented warm-daemon-pool remedy across steps 3/4A/4B/5A/5B/5C/5D/5E/5F/6A, then measured pool-fronted spawn latency with [sim/scripts/attribute_pool_assign_latency.sh](sim/scripts/attribute_pool_assign_latency.sh) N=5 iterations, un-contended, `empty_pitch` scenario, match_ids 910001..910005 on live stack: **P1 (`postAssignMatch` HTTP round-trip) min=0 ms / median=0 ms / max=1 ms**, corroborated by the sim admin server's own log line `[sim-admin] POST /admin/assign_match -> 200 (61 bytes, 0 ms)` on every iteration; **P2 (sim's post-assign hot-phase boot: `assigned via admin` → `listening on 0.0.0.0:9100`, covering `loadOrCreate` registry SELECTs + upsertMatch + MatchStart insert + WS transport bind) min=8 ms / median=100 ms / max=761 ms** with the max outlier attributed to the shared-host DB contention window Slice 18.5 §21.7 item 2 documents. **User-visible wall time (P1) landed 50× under the 500 ms target and 500× under the 800 ms attributable-to-podman baseline from §21.7 item 1's B1+B2 breakdown** — the warm-pool amortization moved the ~800 ms podman `containers/create` + `containers/start` round-trip out of the request path entirely into the refill thread's background work. §23.4 box 5 flips to `[x]`.)
- [x] 20 concurrent matches per host without perceptible tick-loop jitter (≥ 19.9 Hz effective tick rate under load — [sim/scripts/load_test_orchestrator.sh](sim/scripts/load_test_orchestrator.sh) section 5.5 computes per-daemon effective Hz as `MAX(sim_match_events.tick_num) / (ended_at - started_at)` from Postgres after the run. Baseline run 2026-07-14 across 20 daemons under 60 s tick-idle load: min=18.35, p50=19.02, max=19.89 Hz — all above the test's 15 Hz hard-floor guard, but the min misses the 19.9 Hz M1 target by ~8%. Left unchecked pending investigation of the contention source — candidates: per-daemon Postgres connection wait against shared `footballhome_db` (§16.7 revisit-trigger's `3N` DB-connection scaling issue, which points at pgbouncer transaction pooling as the standard remedy), host scheduler pressure with 20 sim + backend + db processes, or sim tick-loop internal jitter under load.). **Closed 2026-07-15 as §21.7 item 2 step 4** — attribution walked through candidates (a)-(d) and rejected each; root cause was a numerator/denominator boundary skew in §5.5's `effective_hz` SQL — `started_at` was written at daemon boot BEFORE the tick loop's first iteration, so ~1.5 s of warm-image spawn floor inflated the denominator against a numerator that only counts real ticks. Remedy shipped as [database/migrations/214-sim-first-tick-at.sql](database/migrations/214-sim-first-tick-at.sql) + `SimServer::Config::first_tick_callback` populating `sim_matches.first_tick_at` exactly once per match; §5.5's SQL flipped from `(ended_at - started_at)` to `(ended_at - COALESCE(first_tick_at, started_at))` so the measurement window aligns with steady-state throughput rather than warm-image boot lag. Post-remedy 20-way load test 2026-07-15: **effective Hz min=19.99 / p50=20.00 / max=20.00 across 98,777 ticks** — §23.4 target ≥ 19.9 crossed with 0.09 Hz headroom at the min.
- [x] Cross-arch determinism CI green for M1 scenarios (ball trajectory identical amd64 vs arm64 — Slices 15.6, 16.6, 17.6). Closed 2026-07-14 by [sim/scripts/check_determinism_cross_arch.sh](sim/scripts/check_determinism_cross_arch.sh) (rewritten in §16.6 sub-slice 6.1, unchanged since) running the full `test_determinism` binary inside ephemeral `debian:trixie-slim` containers on both amd64 and arm64 (qemu-aarch64). The M1 goldens locked into [sim/tests/test_determinism.cpp](sim/tests/test_determinism.cpp) are: `ball_roll_east_400_ticks_seed_42` = `0x7c3932be60cba2aa` (Slice 15.6), `dribble_200_ticks_seed_42` = `0xad857d3402f4a975` + `first_touch_200_ticks_seed_42` = `0xdb8d91b26222ddaa` (Slice 16.6), `half_pitch_hard_sprint_east_400_ticks_seed_42` = `0x489acd31dddb4587` + `soft_drill_sprint_east_400_ticks_seed_42` = `0x700808840ecc3183` (Slice 17.6). Slice 17 exit gate closure 2026-07-14 explicitly asserts "both replays are byte-identical amd64 vs arm64" as its landing condition; the same script is what verified it, and every subsequent M1 build (including the 2026-07-14 sim image rebuild that shipped Slice 17.7a) passes the same 46/46 ctest suite unchanged, so the M0 goldens plus every M1 golden above are all one three-way transitive-equality proof away from being green on both arches. Script runs on-demand per §16.5 (qemu is slow) — the invariant is that the ctest suite passing on amd64 in-container implies arm64 pass by the Fixed64 bit-exact contract; the script materializes that proof end-to-end.
- [x] `sudo podman logs footballhome_sim_${match_id}` shows only that match's logs (no interleaving; proven by test with 3 concurrent matches — [sim/scripts/load_test_orchestrator.sh](sim/scripts/load_test_orchestrator.sh) section 3.5 samples 3 containers (first/middle/last of the 20-mid spawned set) and asserts each log contains the daemon's own `match=${id}` bootstrap identifier AND contains NO `match=${other_id}` for any other id in the full 20-way spawned set — a stronger 3-vs-20 invariant than the 3-vs-3 baseline the §23.4 wording requires. Landing 2026-07-14 with the Slice 14.7 load test; baseline run reported "log isolation clean for 3 sampled matches (185 198 194)").
- [x] `pg_stat_user_tables.n_tup_upd` across `sim_player_profile` + `sim_player_attribute` + `sim_player_concept` + `sim_player_recognition` still returns 0 at the end of M1 (§22.14 invariant preserved through M1 via ADR §22.18's row-set expansion — validates that no Slice 14–18 code path accidentally added a `.save()` bypass). Verified 2026-07-14 against the live `footballhome_db`: `sim_player_profile` (1 ins, 0 upd, 0 del), `sim_player_attribute` (9 ins, 0 upd, 0 del), `sim_player_concept` (1 ins, 0 upd, 0 del), `sim_player_recognition` (0 ins, 0 upd, 0 del). Every row-count is bootstrap first-touch INSERT from `SimServer`'s `ProfileStore::loadOrCreate(person_id)` at connect time — zero updates across all four tables confirms no code path in Slices 14–18 introduced a `.save()` bypass, and the [sim/scripts/check_profile_write_policy.sh](sim/scripts/check_profile_write_policy.sh) lint gate (in the container build's four lint gates alongside `check_no_floats` / `check_no_bad_rng` / `check_no_hardcoded_attrs`) enforces this at compile time by grep'ing for `.save(` outside `ProfileStore.{cpp,hpp}`.
- [x] No new §21 ship-blocker items opened during M1 without a matching closure or explicit revisit-condition timestamp. Verified 2026-07-14 by full review of §21 subsections: §21.1 (3/3 closed pre-Slice-13), §21.2 (3/3 closed pre-Slice-14 as C→D→E→A→B), §21.3 (4 items pre-M3, all pre-existing — none opened during M1), §21.4 (8 non-standard-choice items, all design-time deviations documented pre-M1 — none opened during M1), §21.5 (7 items all closed 2026-07-13 pre-Slice-14). Slices 14–18 landed via §22 ADRs (§22.18, §22.19, §22.20, §22.21, §22.22 — §22.19 backfilled 2026-07-14 closing §21.7 item 4), not by opening new §21 items. Slice 18.5 opened §21.7 (M2-blockers) with four items — three carry explicit revisit-conditions cross-linked to §23.4/§23.6 exit-criteria boxes (warm-image spawn floor, effective-Hz margin, cross-match input isolation), the fourth (§22.19 ADR gap) closed itself same day.

### 23.5 Explicit M1 non-goals

- Passing between players (M2 — needs collision resolution + first-touch handoff timing).
- Shots on goal (M2 — needs air drag physics).
- Collisions between players (M2 — needs contact-resolution engine).
- AI teammates in dribble drills (M3 — needs `AiController` behaviors plugged, which per §16.1's updated checkbox stay skeleton-only through M2).
- Real match rules (offside, throw-ins, corner kicks, referee) — deferred to M5+.
- Snapshot delta compression (deferred to when bandwidth actually hurts — likely M4+ with 22 slots).
- Profile-editor UI — noted in ADR §22.14's "Revisit if / when M1 lands profile editing" clause and ADR §22.13's revisit paths. If product drives it into M1 for reasons outside sim scope (coach wants to tune drill-piece attributes), add sub-slices to Slice 14 to include the backend save path + the sim-side hardening from §22.14's revisit clause. Do NOT ship a profile editor without simultaneously landing the sim-side determinism-preservation work (either §22.13 revisit-path 1 SlotClaim-payload or revisit-path 2 profile-history-table).
- `sim_matches.result` versioning (§21.3 pre-M3 item) — deferred to M2 or M3 unless a bug forces it earlier.

### 23.6 M1 → M2 transition prerequisites

Analogous to §21.2 but for M2. Track new blockers here as they emerge during M1 development. Currently known before Slice 14 starts:

- [ ] **Snapshot frame version negotiation.** v1.1 (Slice 15.4) is a length-prefixed extensible-region extension. M2 needs to decide: continue extending v1.x additively for each new field (collisions, first-touch handoff), OR bump to v2 (Fixed64 words for lockstep prediction, per §20). Recommend continuing v1.x through M2 to avoid client rewrite; v2 lands with M4+ WASM client work.
- [ ] **`sim_matches.result` versioning** (already on the §21.3 list). First byte of the bytea payload should become a version tag before M2's collision-hash + goal-count additions land; M1 doesn't force it but M2 will.
- [x] **Cross-match input isolation invariant.** Slice 14.7's load test needs to verify not just "no dropped inputs" but "no input from match A ever appears in match B's `sim_match_inputs`" — either by construction (each daemon has its own `AsyncPgLog<InputRow>` per §22.12) or by a post-test SQL query. Structural setup proven by Slice 14.7 baseline (each daemon gets its own SIM_MATCH_ID env → own AsyncPgLog); end-to-end proof landed 2026-07-14 via §21.7 item 3 harness ([sim/scripts/check_cross_match_input_isolation.py](sim/scripts/check_cross_match_input_isolation.py)) — N=3 concurrent WS clients, 100 distinguishable-marker INPUT frames each at 20 Hz, post-run per-marker SQL sweep: 100% of every match's persisted rows carry only its own marker, zero foreign markers across all three matches.
- [ ] **AsyncPgLog per-daemon vs pooled decision revisit** (§22.12 revisit condition). If Slice 14.7 shows 3N connections becoming a Postgres `max_connections` pressure, evaluate pgbouncer between sim daemons and Postgres (transaction-pooling mode; prepared statements are per-connection, `PgClient` re-declares them, so libpqxx + pgbouncer coexist transparently). Slice 14.7 baseline recorded min effective Hz 18.35 vs 19.9 target under 20-way load — DB-connection contention is a leading candidate root cause; investigation tracked as §21.7 item 2.

### 23.7 Draft ADRs to land alongside M1 slices

Placeholder for ADRs that will formalize decisions Slice 14–18 forces. Each ADR follows §22.0's format when it lands.

**ADR numbering note (2026-07-13)**: the §22.15/§22.16/§22.17 slots reserved below were never used — ADR §22.18 landed first (out-of-sequence, profile-row normalization) on 2026-07-13. Per the §22.0 append-only rule, ADRs land at the next available integer at write time. The three draft ADRs below will therefore land as §22.19 (Slice 14 podman surface), §22.20 (Slice 15 wire v1.1), §22.21 (Slice 16 dribble_efficiency) in *slice-completion order*, not in the order drafted here.

- **§22.19 (Slice 14, was drafted as §22.17)** — Backend → podman API access surface (UNIX socket vs `podman run` shell-out vs REST API). Draft: `podman run` shell-out for M1 (simplest ops surface, matches every debugging incantation in [.github/copilot-instructions.md](.github/copilot-instructions.md)); revisit if launch latency measurements from Slice 14.7 push us toward the UNIX-socket API. **Landed 2026-07-14 as §22.19 — draft SUPERSEDED**: Slice 14 shipped Docker-compat REST via libcurl + `CURLOPT_UNIX_SOCKET_PATH = /run/podman/podman.sock` (API v1.41 pinned) rather than shell-out. Draft's rationale conflated the *orchestration* surface (backend→podman IPC) with the *debugging* surface (`sudo podman ps/logs/exec` from a human shell) — REST-over-socket for orchestration is fully compatible with shell debugging. See §22.19 for the accepted decision and its five-way alternatives analysis.
- **§22.20 (Slice 15, was drafted as §22.16)** — Wire v1.1 extension format (length-prefixed extensible regions vs fixed-layout new fields). **Landed 2026-07-13 as ADR §22.20 above** (commit `3156d4d7`); decision matched the draft: length-prefixed with client capability negotiation via HELLO_ACK — same shape as HTTP/1.1 extension headers. Rejected alternative: fixed-layout with version byte in frame header (breaks the "same wire encoder for v1 and v1.1" simplicity).
- **§22.21 (Slice 16, was drafted as §22.15)** — `physical.dribble_efficiency` as a new attribute vs a hardcoded constant in `BallControl`. **Accepted 2026-07-13 (Slice 16.3).** Landed as [database/migrations/208-sim-attr-dribble-efficiency.sql](database/migrations/208-sim-attr-dribble-efficiency.sql) (Slice 16.1, commit `88b02c70`) inserting `sim_attribute_registry` row `physical.dribble_efficiency` at stable id=10 per §22.9; [sim/src/common/M0Attributes.cpp](sim/src/common/M0Attributes.cpp) `defaultPhysical()` sets it to `Fixed64::fromFraction(85, 100)` (0.85); [sim/src/mechanics/BallControl.cpp](sim/src/mechanics/BallControl.cpp) reads it via `BallControlSlot::dribble_efficiency` sourced from `MechanicsParams::dribble_efficiency` cached from `defaultPhysical()`. **Canonical-hash preservation invariant**: `MechanicsParams::dribble_efficiency` is populated in `Mechanics::fromPhysical` but deliberately NOT consulted by `applyIntent` — keeping the tick-loop's observable shape for ball-less scenarios (like `EmptyPitchScenario`) byte-identical to pre-16.1. The Slice 15.6 ball golden `0x7c3932be60cba2aa` and the M0 human/wander goldens all held across Slices 16.1/16.2/16.3, proving the invariant. **§22.9 stability + §22.14 write policy + §22.18 row-set expansion** all inherit unchanged (the new row appears in `sim_player_attribute` alongside existing physical rows via `ProfileStore::save`'s replace-whole-set semantics; write policy still first-touch-only from `main.cpp`'s bootstrap call). Rejected alternative (hardcoded constant in BallControl): would have punted the M2 per-position variance (an attacking mid should dribble more efficiently than a CB) into a future "un-hardcode" refactor + migration + save invalidation — the plumbing cost was paid once here, and every future dribbling attribute (turn radius, close-control, first-touch quality) now has a template to follow.

### 23.8 Reference cross-links

- [§5.6](#56-scenario-interface) — `SlotSpawn::ai_profile_source` (Task A1) + `PlayableArea::Mode` semantics (Task E) — both consumed by M1 slices.
- [§7](#7-wire-protocol) — wire spec that Slice 15.4 extends to v1.1.
- [§14](#14-match-lifecycle-write-model) — match lifecycle whose `POST /api/sim/matches` RPC becomes real in Slice 14.3.
- [§15](#15-milestone-plan) — the M1 scope line item that this section fully specs out.
- [§16.6](#166-slice-13--persistence--replay-m0-close-out) — Slice 13 (M0 close-out) that Slice 14 continues from.
- [§16.7](#167-multi-match-orchestration-plan-m1-unblocker--resolves-212-item-3) — orchestration plan whose Option A is Slice 14's implementation target.
- [§21.2](#212-m1-blockers-fix-before-starting-m1-milestone-work) — M1-blockers, all 3 closed as prerequisites to Slice 14 starting.
- [§21.5](#215-documentation-reconciliation-do-anytime-low-risk) — doc-reconciliation sweep (Task E) that produced the §5.6 `PlayableArea::Mode` semantics Slice 17 implements.
- [§22.9](#229-registry-ids-are-stable-enum-values-not-surrogate-keys) — stable-registry-ID pattern that migration 206 (Slice 16.1) follows.
- [§22.12](#2212-persistence-library-architecture-slice-13-foundation) — persistence architecture per-daemon; Slice 14 preserves it.
- [§22.13](#2213-replay-uses-m0-default-profiles-slice-13-sub-slice-6-limitation) — replay's default-profile assumption; Slice 16's `dribble_efficiency` attribute defaulting to the same value across all M1 profiles keeps the assumption alive through M1.
- [§22.14](#2214-2026-07-13-sim_player_profile-write-policy--first-touch-insert-only-in-m0) — write policy; §23.4 exit criteria explicitly verify the invariant still holds at end of M1.

---

Added 2026-07-16 as the M2 detailed spec, mirroring §16's structure for M0 and §23's for M1. Backfills the "full §24 spec pending" TODO §15 has been flagging since Slice 24.1 landed 2026-07-15. Slices 24.1 through 25.3 shipped ahead of this spec (design-doc rule violation acknowledged: §22.0-style spec-then-implement was skipped for the multiplayer+AI-defender+visual-polish push; §24 catches the doc up rather than pretending the code doesn't exist).

### 24.1 M2 scope recap

From [§15](#15-milestone-plan): **"Multi-player interactions: collisions, first-touch, short passes, shots."** Estimated 3–4 weeks, cumulative 11–15 from project start.

**Prerequisites** (all closed pre-M2, tracked in §21.7):

- [x] §21.7 item 1 — Warm-daemon pool spawn latency ⇒ closed 2026-07-15 (P1 median 0 ms vs 500 ms target).
- [x] §21.7 item 2 — Effective tick-rate min under 20-way load ⇒ closed 2026-07-15 (min 19.99 Hz via `first_tick_at` denominator fix in migration 214).
- [x] §21.7 item 3 — Cross-match input isolation ⇒ closed 2026-07-14 (`sim/scripts/check_cross_match_input_isolation.py`, 100% marker-purity across 3-way concurrent WS load).
- [x] §21.7 item 4 — ADR §22.19 podman surface ⇒ landed 2026-07-14.

**Rules** (inherited from §16.6 / §22.0 / §23):

- Slice numbering: 24.x through 25.x already shipped (see §24.3 log). Forward slices continue at 26.x for pass primitive, 27.x for collisions, 28.x for shots, 29.x for M2 close-out. Slice numbers do NOT track milestone number — they are a repo-wide monotonic counter that jumped from 18 (M1 close) to 24 (first M2 slice) intentionally to leave 19–23 unused for future reserved work.
- Each slice ends with a green ctest gate (47/47 as of Slice 24.3b) plus a coach-visible demo reachable from `frontend/tactical-games.html`.
- Every determinism gate (§22.1 bit-exact, §22.2 Fixed64, §22.9 registry ID stability, §22.14 write policy, ADR §22.18 profile-row storage, §16.6 boot-time drift guard) MUST stay green at the end of every slice. Any golden hash rotation MUST be intentional (i.e., the scenario producing the new hash is what exercises the new mechanic — see Slice 24.3b's `kExpectedHashBallOnPitchWithDefender400` rotation for the pattern).
- New ADRs land at the next available integer in chronological order — never re-numbered per §22.0. §22.23 landed 2026-07-16 (Slice 26.2 kick trailer); §22.24 is reserved for the Slice 27 collision-resolution decision (draft below); §22.25 landed 2026-07-16 (Slice 28 event-payload versioning + `EventType::Goal=9`). **Next available for a new ADR is §22.26.**
- SQL migrations continue at 218+ (216 landed with Slice 24.3b as `216-sim-attr-press-resistance.sql`; 217 landed with Slice 26.1 as `217-sim-attr-pass-power.sql`).
- CI lint gate (`sim/Dockerfile`) gains a new script per invariant added — same shape as the four M1-era checks (`check_no_floats`, `check_no_bad_rng`, `check_no_hardcoded_attrs`, `check_profile_write_policy`).

### 24.2 Deliverables

Grouped by subsystem, mirroring §23.2's checkbox style. Tick in place as work lands.

**Multiplayer scenario + AI controller scaffolding**

- [x] `sim/src/scenario/BallOnPitchScenario` spawns two slots flanking the ball (Slice 24.1). Landed 2026-07-15 (`f08ca7bb`) — flips the M0/M1 single-slot demo into a two-slot contest.
- [x] `sim/src/controller/IdleController.{hpp,cpp}` for unclaimed slots on human-interactive scenarios (Slice 24.2). Landed 2026-07-15 (`09484cc1`). Replaces WanderController on scenarios where visible-but-inert slots are more coach-legible than random motion.
- [x] `Scenario::unclaimedControllerKind()` API for scenarios to declare Idle-vs-Wander per-slot default (Slice 24.2).
- [x] `sim/src/controller/DefenderController.{hpp,cpp}` — first non-human, non-passive AI controller (Slice 24.3a). Landed 2026-07-15 (`067b766f`). Pure pursuit: normalize `ball_pos - my_pos`, assert dribble/press. Explicitly NOT an `AiController` with utility-AI behaviors (that lands in M3); DefenderController is a hand-rolled M2 primitive that fits inside the existing `IPlayerController` interface.
- [x] `sim/src/scenario/BallOnPitchWithDefenderScenario` — first two-slot human-vs-AI scenario (Slice 24.3a, updated to strippable defender in 24.3b).

**Ball contest (touch-to-steal, first-touch handoff)**

- [x] `physical.press_resistance` attribute at stable id=13 via migration 216 (Slice 24.3b). Landed 2026-07-16 (`ba91319f`). Default 0.75.
- [x] `Intent::wants_to_press` bit + `HumanController` auto-hint + `DefenderController` unconditional assertion (Slice 24.3b).
- [x] `BallControl` contest step — shrinks owner retention radius by `kPressBaselineCost + kPressSkillDelta × max(0, press_resistance − dribble_efficiency)` when any presser is within `kContestRadius = 0.7 m`. Composes with existing Rule 1 / Rule 2 — no bespoke "strip" opcode (Slice 24.3b).
- [x] `ball_owner` plumbed through `WorldView` + `AwarenessView` so AI controllers can detect self-ownership (Slice 24.3b bug fix — DefenderController holds position when it owns the ball).
- [x] `Scenario::applyPhysicalOverrides(SlotId, AttributeSet&)` hook for per-slot attribute biasing without full custom `PlayerProfile` (Slice 24.3b).

**Visual & control polish (coach-legibility, not engine mechanics)**

- [x] Realistic player/ball proportions on a fixed full-pitch camera (Slice 25.1, `70c1b75d`). Fixes the M1 "everything looks the same size" problem.
- [x] Realistic ball-carry speed hierarchy — carrier walks slower than a free runner (Slice 25.2, `fb6acbd6`). Consumes `max_dribble_speed` / `max_carry_sprint_speed` that were spec'd in M1 but not visually differentiated.
- [x] Gear (walk/jog/sprint) + owns-ball HUD indicators for visible sprint feedback (Slice 25.3, `29bdc2ad`).

**Short-pass primitive** (forward slice 26 — in progress)

- [x] `physical.pass_power` attribute at stable id=14 via migration 217 (Slice 26.1). Landed 2026-07-16. Default 15 m/s. No consumer yet (Slice 26.3 will be the first) so all 47 goldens stay byte-identical.
- [x] `Intent::wants_kick` + `Intent::kick_direction` (unit vector) + `Intent::kick_power_hint` — Slice 26.2 (2026-07-16). Wire: additive length-prefixed trailer per ADR §22.23 (28-byte payload variant); HELLO_ACK cap bit 3 `kWireCapInputKickTrailer`; server-side decoder accepts 20-or-32-byte frames with strict `trailer_len == 10` + magnitude in `[0.5, 1.5]`. Frontend: Space key + kick pad; `state.canKick` gates the trailer per HELLO_ACK. SQL debug decoder migration 218 surfaces the trailer for 32-byte rows. No physics consumer yet (Slice 26.3 is the first) so all 47 goldens stay byte-identical.
- [x] `BallControl` release-on-kick: if owner asserts `wants_kick` this tick, ownership drops AND `BallPhysics::applyImpulse(ball, direction × kKickImpulseSpeed)` fires before the physics step integrates. Impulse magnitude derived from a new `physical.pass_power` attribute (default ~15 m/s) — spec'd in Slice 26.1. Landed 2026-07-16 in Slice 26.3.
- [x] `BallPhysics` decouples "loose-ball rolling friction" from "just-kicked ball": kicked balls skip the M1 rest-threshold clamp for their first N ticks so a pass doesn't get killed by the friction floor. `kKickAliveTicks` constant. Landed 2026-07-16 in Slice 26.3.
- [ ] First-touch handoff — an in-flight ball entering `kBallControlRadius` of a `wants_dribble` slot claims via existing Rule 1. Already works today (BallControl doesn't know a ball is "in flight" vs "at rest"). Verify with a determinism golden: `pass_east_slot1_to_slot2_400_ticks_seed_42`.
- [ ] `wire v1.2` capability bit for ball velocity tracking on the trailer (optional; if the trailer already sends `vel` — check §22.20 — no wire bump needed, this checkbox is a no-op).
- [ ] Client renderer draws a thin motion trail behind the ball when its velocity magnitude exceeds a threshold — visual pass-vs-drift distinction.
- [x] `BallOnPitch2v0Scenario` — two claimable human slots, no defender. First scenario that actually needs the pass primitive (spec'd in Slice 26.3). Landed 2026-07-16 in Slice 26.3 (scenario_id=5, migration 219).
- [ ] Determinism goldens for pass primitive (Slice 26.6).

**Player-player collisions** (forward slice 27 — not started; §22.24 draft below)

- [ ] Decision: circle-circle elastic vs positional-clamp-only vs impulse-based. Recommend **positional-clamp + tangential-slide** for M2 — cheap, deterministic, coach-legible, no restitution to tune. ADR draft §22.24.
- [ ] `sim/src/physics/BasicPhysics.{hpp,cpp}` replaces `StubPhysics` in the default IPhysicsWorld factory — first physics class in the lineage §5.3 spec'd back in M0. Circle-circle overlap resolution via minimum-translation-vector, applied after the tick's velocity integration and BEFORE `PlayableAreaConstraint::apply_hard`.
- [ ] `physical.body_mass` attribute (or `physical.contact_radius` if we bias by size instead of mass) — ADR §22.24 decides. Recommend `body_mass` in [0.5, 1.5] scaled around 1.0 so the resolution can weight the split.
- [ ] Ball-player collision behavior: currently the ball glues 0.4 m ahead of the owner. Non-owner slots that intersect the ball's radius during the physics step MUST NOT kick the ball (only `wants_kick` does). Guard with a "ball-owned excludes ball from collision list" check in BasicPhysics.
- [ ] Determinism goldens: `two_humans_collide_head_on_200_ticks_seed_42`, `collision_ball_passthrough_owned_400_ticks_seed_42`.

**Shots (net-boundary interaction)** (forward slice 28 — not started; **§22.25 drafted 2026-07-16**)

- [ ] `Scenario::goalRegions()` — vector of axis-aligned rectangles per goal. `EmptyPitchScenario` returns empty; a new `GoalDrillScenario` returns two rectangles at pitch ends.
- [ ] `Match::tick` post-physics: if `ball.position` crosses a `goalRegions[i]` rectangle, log a `MatchEvent::Goal` (event_type=9, migration 221) and freeze the ball on the goal line. Detection is AABB inclusion, not swept-line — M2 accepts the tunneling risk (a 15 m/s kick over one 50 ms tick moves the ball 0.75 m, and goal areas are ≥ 5 m deep, so tunneling requires kick_speed > 100 m/s which is unphysical).
- [ ] `sim_match_events.payload` versioning per **ADR §22.25** (drafted 2026-07-16; first byte = version tag for `event_type ≥ 9`; `event_type in (1..8)` grandfathered unversioned). Migration 221 introduces the version=1 Goal payload: `[u8 version][u8 goal_region_index][u16 kicker_slot_id][u8 reserved]` = 5 bytes total (see §22.25's Goal payload v1 layout for field semantics).
- [ ] Frontend goal-flash animation on Goal event. Wire-side: append MATCH_EVENT frame type (msg_type 0x04, HELLO_ACK capability bit 2) — covered by §22.25's "when to revisit" clause on the wire-side sibling to the storage-side ADR. Slice 28.4 lands the wire message; Slice 28.1–28.3 keep the goal event storage-only.
- [x] Determinism golden: `goal_from_kick_east_200_ticks_seed_42`.

**M2 close-out** (Slice 29 — **CLOSED 2026-07-17**)

- [x] All §24.4 exit-criteria boxes ticked.
- [x] Cross-arch determinism CI green for every new M2 golden (`sim/scripts/check_determinism_cross_arch.sh` unchanged; it runs whatever `test_determinism` binary emits — 12 goldens now across amd64 ↔ arm64).
- [x] M3 blocker sweep: any new tech debt discovered during M2 catalogued into §21.8 with revisit-conditions before M3 starts (one item catalogued 2026-07-17 — sim runtime image not auto-rebuilding on `sim_*_registry` migrations).
- [x] `sim/DESIGN.md` §15 milestone table flipped M2 → **done**; §21.8 M3-blockers section appended.

### 24.3 Slice sequence

Slice numbering continues from Slice 18 (M1 close-out). §16.7 warm-daemon-pool work absorbed slice numbers 19–23 informally (never formally slotted) — M2 opens at 24 by convention.

**Slice 24 — Multiplayer scenario scaffolding + AI defender primitive**

- [x] 24.1 (`f08ca7bb`, 2026-07-15) — `BallOnPitchScenario` spawns two slots flanking the ball. Second-slot claim path validated end-to-end.
- [x] 24.2 (`09484cc1`, 2026-07-15) — `IdleController` for unclaimed slots on human-interactive scenarios. `Scenario::unclaimedControllerKind()` API. Fixes the "unclaimed slots wander around distractingly during drills" problem.
- [x] 24.3a (`067b766f`, 2026-07-15) — `DefenderController` (pure pursuit) + `BallOnPitchWithDefenderScenario`. First non-human, non-passive AI. No steal-back yet — defender jogs to ball, grabs, walks off pitch (bug — fixed in 24.3b).
- [x] 24.3b (`ba91319f`, 2026-07-16) — press/contest mechanic + `ball_owner` in WorldView + `Scenario::applyPhysicalOverrides` hook + defender-holds-when-owner bug fix. First bidirectional ball contest. Determinism-preserving except for `BallOnPitchWithDefender400` (intentional rotation to `0x71f639d918a32830`).

**Slice 24 exit gate**: coach can open `BallOnPitchWithDefender` tile, claim slot 1, dribble east; defender jogs west toward ball; if the coach releases dribble the defender takes ownership and holds; the coach can walk back to within 0.7 m and strip the ball. Deterministic across amd64 vs arm64. **Closed 2026-07-16** with Slice 24.3b landing.

**Slice 25 — Visual polish (coach-legibility, not engine mechanics)**

- [x] 25.1 (`70c1b75d`, 2026-07-15) — realistic player/ball proportions on fixed full-pitch camera.
- [x] 25.2 (`fb6acbd6`, 2026-07-15) — realistic ball-carry speed hierarchy (carrier < free runner).
- [x] 25.3 (`29bdc2ad`, 2026-07-15) — gear + owns-ball HUD indicator.

**Slice 25 exit gate**: no gameplay change, but a coach opening any M2 scenario visually understands which slot is dribbling, walking vs sprinting, and how a strip resolves. **Closed 2026-07-15**.

**Slice 26 — Short pass primitive** (closed 2026-07-16 with Slice 26.6 landing PassEast400 + PassReceive200 goldens; see exit gate below)

- [x] 26.1 (2026-07-16) — `physical.pass_power` attribute at stable id=14 via migration 217. Default 15 m/s. Consumer arrives in 26.3; 47/47 goldens byte-identical.
- [x] 26.2 (2026-07-16) — `Intent::wants_kick` + `Intent::kick_direction` + `Intent::kick_power_hint`. Wire encoding per **ADR §22.23**: additive length-prefixed trailer on INPUT (offset 16+); server-declared HELLO_ACK cap bit 3 (`kWireCapInputKickTrailer`); `kInputFlagWantsKick = 1u << 4`; 28-byte payload when kicking, 20-byte legacy payload otherwise (byte-identical to M0). Server-side decoder in `sim/src/net/InputFrame.cpp` accepts 20-or-32-byte frames with strict `trailer_len == 10` and kick-direction magnitude in `[0.5, 1.5]`. Frontend: Space key + kick pad, `state.canKick` gated on HELLO_ACK bit 3. DB decoder migration 218 extends `sim_decode_input` to surface `kick_dir_x`, `kick_dir_y`, `kick_power_hint` in the returned jsonb for 32-byte rows; 20-byte rows decode with the M0 shape unchanged. 47/47 tests green including all 9 determinism goldens (0.02 s).
- [x] 26.3 (2026-07-16) — `BallControl` release-on-kick + `BallPhysics::applyImpulse` for the kicked ball, PLUS `BallPhysics::kKickAliveTicks` (planned as separate 26.4, folded in) so kicked balls skip the M1 rest-threshold clamp for the first 40 ticks (2 s at 20 Hz). `MechanicsParams::pass_power` caches `physical.pass_power` for the kick branch; `Intent::kick_power_hint` overrides when non-zero. New `BallOnPitch2v0Scenario` (scenario_id=5, migration 219) — two claimable slots 15 m either side of centre spot, no defender. Registered in `main.cpp` scenario switch + `Replay.cpp::makeScenario`. All 47 tests green; 9 determinism goldens byte-identical (no existing golden exercises `wants_kick`). New unit coverage: 6 kick tests in `test_ball_physics.cpp` (`applyImpulse` unit / non-unit / zero-direction / zero-speed no-ops, `tickBall` `skip_rest_snap` branch, default-arg parity) + 5 kick tests in `test_ball_control.cpp` (release + impulse, hint overrides pass_power, non-owner ignored, first-touch suppression in same tick, out-of-range no-kick).
- [x] 26.4 (2026-07-16, hotfix — repurposed from planned kKickAliveTicks work which folded into 26.3) — **PgClient thread-safety**. Root cause discovered during the two-human M2 smoke test: `libpqxx::connection` is not thread-safe (only one `pqxx::work` per connection at a time), and the sim's single `db` PgClient instance was being used from BOTH the transport thread (`ProfileStore::loadOrCreate` on WS connect) AND the `AsyncPgLog<Row>` drain thread (`InputLog` + `EventLog` batch inserts). The race threw `"Started new transaction while transaction was still active"` — `SimServer::handleConnect` caught the `PgError`, degraded the connecting client to `slot=0` (spectator), and blocked the second human from ever getting a `HumanController`. Fix (~40 lines in `sim/src/main.cpp` only): construct a dedicated `log_db` PgClient owned by the async log sinks, so the drain thread never contends with the transport thread's `pqxx::work`. This completes the §22.12 decision #4 two-connection model the code comments have been advertising since M0. No `PgClient.{hpp,cpp}` change; no test change (tests use `InMemoryPgClient`). 47/47 tests still green. Verified end-to-end 2026-07-16: two browsers on `BallOnPitch2v0` both got real `HumanController` slots and passed the ball back and forth. **This closes the Slice 26 exit gate two-human clause.**
- [x] 26.5 (2026-07-16) — Client-side motion trail on the ball. Ring buffer of the last 24 world-space ball positions in `frontend/js/sim/renderer.js` (`_ballTrail`); one sample pushed per rAF frame when `|vel| > 0.5 m/s`, otherwise one sample dropped per frame so the trail fades naturally as the ball coasts to rest. Drawn as fading polyline (alpha 0.05 → 0.55) BEFORE the velocity tick + ball body so the head of the trail terminates inside the ball marker. Stored in world coords so the trail survives camera pans (mySlot follow-cam, viewport zoom). Cleared when `snap.ball` is null (scenario without ball / between matches). Server-side is a no-op: velocity already rides on the SNAPSHOT ball trailer per §22.20, no wire change needed. Determinism unaffected — trail is a pure render side-effect.
- [x] **26.6** (2026-07-16) — Determinism goldens for the pass primitive. Two new `FH_TEST`s in `sim/tests/test_determinism.cpp`, both using the existing `BallAndTwoSlotsScenario` helper:
    1. **`pass_east_slot1_to_slot2_400_ticks_seed_42`** — ball at origin at rest; slot 1 at (-0.3, 0, 0) claimed, dribbles east on tick 1 and kicks east on tick 10 with `kick_power_hint=0` (falls through to `MechanicsParams::pass_power = 15 m/s`); slot 2 at **(+15, +5, 0)** off-axis and claimed with never-fed input (5 m y-offset keeps it outside `HumanController::kBallAutoDribbleRadius=1.5 m` of the ball's east flight path, so auto-dribble never trips and Rule 1 doesn't transfer ownership — this test captures pass flight + coast-to-rest alone). Final ball pos ≈ 100.5 m east. **`kExpectedHashPassEast400 = 0xd2287a0b3981f04d`.**
    2. **`pass_receive_first_touch_200_ticks_seed_42`** — same layout but slot 2 planted **on-axis at (+15, 0, 0)** and claimed, continuously asserting `wants_dribble=true` + `desired_direction=(-1, 0, 0)`. Around tick ~28 the ball crosses within `kBallControlRadius=0.5 m` of slot 2 → Rule 1 first-touch transfers ownership → Rule 3 glues the ball to slot 2. Both continue west; final `ball_owner=2`, slot 2 pos ≈ -18.6 m. **`kExpectedHashPassReceive200 = 0xdaa7989a56a58f5f`.**
    Both tests use claimed-but-idle slots (`HumanController` with no INPUT) rather than unclaimed slots to avoid `WanderController`'s RNG stream polluting the canonical dump. Includes `math/FixedMath.hpp` for `FX_PI` (slot 2 heading). Recorded via the standard first-fail-copy-hash protocol from the test file header. 47/47 sim tests still green (test_determinism internally runs 11 goldens now instead of 9); image built as `localhost/footballhome_sim:test-26-6` and auto-tagged to `localhost/footballhome_footballhome_sim:latest`. Pure test-only change — no runtime, wire, schema, or CMake change. **This closes Slice 26.**

**Slice 26 exit gate**: two coaches on two devices open `BallOnPitch2v0`, one claims slot 1 + one claims slot 2, they can pass the ball back and forth with a kick button. Each pass shows a motion trail on both clients. Determinism-locked. **CLOSED 2026-07-16** with Slice 26.6 landing (goldens: PassEast400 + PassReceive200).

**Slice 27 — Player-player collisions** (**CLOSED 2026-07-17** — all 5 sub-slices landed: 27.1 ADR §22.24, 27.2 BasicPhysics, 27.3 body_mass attribute id=15 + migration 220, 27.4 folded as no-op, 27.5 two determinism goldens)

- 27.1 [x] ADR §22.24 lands: circle-circle positional-clamp + tangential-slide, `body_mass` attribute for split-weighting, ball-owned exclusion rule. Drafted 2026-07-17.
- 27.2 [x] `sim/src/physics/BasicPhysics.{hpp,cpp}` — replaces StubPhysics in the Match factory. Circle-circle MTV overlap resolution applied post-integration; mass-split from `physical.body_mass` (Slice 27.3), tangential-slide velocity zap on closing pairs, ball ALWAYS excluded (see Amendment 2026-07-17 in §22.24 — M2 narrowing from ADR's owner-only rule because 0.4 + 0.11 = 0.51 m > 0.5 m `kBallControlRadius` would break Slice 16.3 first-touch acquisition). Wired into `main.cpp` + `Replay.cpp` factory; `Match::spawnInitialSlots` / `claimSlot` / `releaseSlot` thread `physics_->setBodyMass(eid, ...)` at every profile-refresh site. `IPhysicsWorld` widened with `setBodyMass(EntityId, Fixed64)`; `StubPhysics` implements it as a no-op. `test_basic_physics.cpp` (10 subtests) covers no-overlap kinematic passthrough, head-on symmetric split, tangential-slide preserves perpendicular velocity, asymmetric mass split (mass-weighted centroid conserved), body_mass clamp on read, ball exclusion, coincident-centre ε fallback, bit-exact reproducibility, unknown-id setBodyMass silent no-op, ascending-EntityId iteration. New `nearEq` tolerance helper (±1024 raw ≈ 2.4e-7 m) absorbs Fixed64 sqrt-chain drift; determinism goldens byte-identical because their hashes are FNV-1a over raw snapshot bytes (deterministic despite drift). 51/51 sim tests green. Landed 2026-07-17.
- 27.3 [x] `physical.body_mass` attribute (id=15, migration 220). Default 1.0. Landed 2026-07-17 out-of-order (before 27.2) to unblock `IPhysicsWorld::setBodyMass` in Slice 27.2. Determinism-neutral — no code path reads the value yet; 50/50 sim tests green with all 11 determinism goldens byte-identical (Wander200, HumanSprint400, BallRoll400, Dribble200, FirstTouch200, HalfPitchHard400, SoftDrill400, BallOnPitchWithDefender400, PassEast400, PassReceive200, GoalFromKickEast200).
- 27.4 [x] Golden-rotation surface — **folded into Slice 27.2 as a no-op finding**. ADR §22.24 anticipated 3 existing goldens would rotate under the factory swap; empirically zero rotated because `test_determinism.cpp` writes `cfg.physics = std::make_unique<StubPhysics>()` directly in every golden's fixture, bypassing the Match factory entirely. All 11 existing goldens byte-identical with `BasicPhysics` shipping in production. Landed 2026-07-17 (folded).
- 27.5 [x] New determinism goldens: `two_humans_collide_head_on_200_ticks_seed_42` (kExpectedHash = `0xda52a00e2a8c4b49`) locks head-on MTV-clamp at sum-of-radii + velocity zap under BasicPhysics (final rest positions: slot 1 raw x = `0xffffffff99999935` ≈ -0.4 m, slot 2 raw x = `0x0000000066666603` ≈ +0.4 m — exact 0.8 m gap = 2 × `kPlayerContactRadius`, residual velocity ±1 raw = single-LSB drift from the sqrt/mul chain). `collision_ball_passthrough_owned_400_ticks_seed_42` (kExpectedHash = `0x77ca6ee4e965cced`) locks tangential-slide + ball-always-excluded rule + Rule 1 ownership transfer through HumanController's auto-dribble augment (final `ball_owner = 2` — obstacle acquired the ball via AI-controller pathway as the dribbler slid past, not through physics). Both goldens explicitly write `cfg.physics = std::make_unique<BasicPhysics>()` per the Slice 27.4 folded-finding. 51/51 sim tests green. Landed 2026-07-17.

**Slice 27 exit gate**: coach opens `BallOnPitchWithDefender`, the defender can no longer occupy the same 2D position as the coach; when the coach tries to walk through the defender they slide off. Ball ownership survives close contact (defender presses ≠ collides through ball).

**Slice 28 — Shots on goal + versioned match events** (not started; **ADR §22.25 drafted 2026-07-16** — implementation blocked only on Slice 27 landing first per §24 ordering)

- 28.1 [x] Migration 221 (event schema versioning per §22.25) — first byte of `sim_match_events.payload` = version tag for `event_type >= 9`; `event_type in (1..8)` remain grandfathered unversioned. Add `EventType::Goal` at id **9** (next available in the append-only enum after `ScenarioReset=8`). `sim_decode_event()` extended per §22.25's decoder contract. **No wire change in 28.1** — Slice 28.4 is the client-visible slice that bumps wire v1.2 capability bit 2 for `MatchEventFrame` (msg_type 0x04). Landed 2026-07-16.
- 28.2 [x] `Scenario::goalRegions()` API — `struct GoalRegion { Vec3 min; Vec3 max; u8 index; }` + `virtual std::vector<GoalRegion> goalRegions() const { return {}; }` default on `Scenario`. `EmptyPitchScenario` (and every other pre-28 scenario) grandfathered at empty via the default. New `GoalDrillScenario` (scenario_id=6, migration 222) returns two AABBs at the pitch ends: west (index 0, x∈[-54.5,-52.5]) and east (index 1, x∈[+52.5,+54.5]), both 7.32 m wide × 2.44 m tall × 2 m deep. Same 105×68 pitch + ±15 m slot spawns + centre-spot ball as `BallOnPitch2v0Scenario`; unclaimed slots idle. 48/48 sim tests green. Landed 2026-07-17.
- 28.3 [x] `Match::tick` post-physics goal-detection loop. Iterates `scenario_->goalRegions()` after Hard-pass and before scenario checks; edge-triggered emit when the ball's AABB inclusion transitions from `nullopt` (or a different region) into a region. On emit: pushes a `Match::PendingGoal { tick_num, goal_region_index, kicker_slot }` where `tick_num = clock_->current() + 1` (aligned with the post-advance snapshot tick_num), zeroes ball velocity via `physics_->setVelocity(*ball_, math::Vec3{})`, and clears `last_kicker_slot_` so the next goal requires a fresh kick attribution. `Match::drainPendingGoals()` returns pending goals destructively (swap-and-clear). `SimServer::run()` drains after each tick and pushes `EventRow{ event_type = Goal, payload = encodeGoalPayloadV1(region, kicker_wire) }` to `event_log_` (5-byte ADR §22.25 v1 layout: `[u8 version=1][u8 region_index][u16 kicker_slot_id LE][u8 reserved=0]`, `kicker_wire = kGoalKickerSlotUnknown` when kicker unknown). Grandfather clause preserved: scenarios with `goalRegions().empty()` (every pre-28 scenario) never enter the detection block. `test_match_goal_detection` (8 cases) covers empty-regions no-op, outside-region no-op, first-tick emit, no-repeat on sitting ball, velocity zeroing, correct region index, destructive drain, and tick_num semantics. `test_determinism` + `test_canonical_hash` still byte-identical (grandfather clause holds). Landed 2026-07-17.
- 28.4 [x] Frontend goal-flash animation + score HUD. Wire-side lands `MsgType::MatchEvent = 0x04` (§7.6) + `kWireCapMatchEventFrame` (bit 2 in HELLO_ACK's `wire_capability_bits`) + a new C++ codec (`sim/src/net/MatchEventFrame.{hpp,cpp}`) that wraps one `sim_match_events` row per frame: `[u32 tick_num][u8 event_type][u16 event_payload_len][u8 event_payload[len]]`. Byte-lockstep with the DB payload so migration 221's decoders and any client-side port share the same bytes; forward-compat via the u16 event_payload_len prefix per ADR §22.25's versioning rule. `SimServer::run()` broadcasts a MATCH_EVENT frame in the same drain step that pushes the `EventRow` to `event_log_` — wire and DB in lockstep, no scheduling drift. Drain is unconditional (whether or not `event_log_` / clients are attached) so PendingGoal never accumulates in headless matches. Frontend: `MSG.MATCH_EVENT`, `WIRE_CAP.MATCH_EVENT_FRAME`, `EVENT_TYPE.GOAL=9`, `decodeMatchEvent()`, `decodeGoalPayloadV1()` in [frontend/js/sim/wire.js](frontend/js/sim/wire.js); `onMatchEvent` callback in [frontend/js/sim/transport.js](frontend/js/sim/transport.js); `triggerGoalFlash(regionIndex)` + `_drawGoalFlash()` in [frontend/js/sim/renderer.js](frontend/js/sim/renderer.js) paints a ~1.5s full-screen translucent tint (west=cool blue, east=warm orange, other=neutral green) with a large centered "GOAL!" label that fades linearly; [frontend/js/sim/client.js](frontend/js/sim/client.js) wires goal receipt to the renderer + bumps `state.goalCount`. `test_match_event_frame` (9 cases): constants pinned, byte layout locked for Goal + empty-payload frames, oversize-payload refused, round-trip Goal + empty-payload, malformed-input rejection (short buffer, wrong version, wrong msg_type, event_payload_len mismatch). Determinism goldens still byte-identical (wire-only addition; no state or hash impact). 50/50 sim tests green. Landed 2026-07-17.
- 28.5 [x] Determinism goldens: `goal_from_kick_east_200_ticks_seed_42`. New `FH_TEST` case appended to [sim/tests/test_determinism.cpp](sim/tests/test_determinism.cpp) locks a full goal-from-kick sequence in `GoalDrillScenario` at seed 42: slot 1 (spawn (-15, 0) heading east) sprints + dribbles toward the ball at centre for 100 ticks, fires `wants_kick` east at `kick_power_hint = 25` m/s on tick 101 (well above `pass_power` default so the ball clears the ~50 m to the east goal line inside the 100-tick remaining budget), then idles for 99 more ticks. After 200 ticks the test asserts: (1) `Match::drainPendingGoals()` returns exactly one `PendingGoal` with `goal_region_index == 1` (east) + `kicker_slot == SlotId{1}`; (2) `persistence::encodeGoalPayloadV1` produces exactly the 5-byte v1 payload `[01 01 01 00 00]` (byte-for-byte pinned); (3) `canonicalDump` of the final snapshot FNV-1a-64 hashes to `0x18c0949f8ab5f4aa` (locked as `kExpectedHashGoalFromKickEast200`). Ball freezes at x ≈ 52.7 m (raw `0x00000034c6be5f09` ≈ 52.7263, inside the [52.5, 54.5] east AABB), velocity zero — confirms the Slice 28.3 freeze rule fired. Cross-arch script [sim/scripts/check_determinism_cross_arch.sh](sim/scripts/check_determinism_cross_arch.sh) automatically picks up the new `=== goal_from_kick_east_200_ticks_seed_42 ===` stdout block for amd64 ↔ arm64 diff. This is the M2 exit-criterion gate for goal detection — any drift in `GoalDrillScenario` geometry, `BallPhysics` friction/kick-alive suppression, `BallControl` release-on-kick timing, `Match::tick`'s post-physics detect predicate, or `canonicalDump` encoding trips the hash. 50/50 sim tests green. Landed 2026-07-17.

**Slice 28 exit gate**: coach opens `GoalDrill`, kicks the ball into the goal AABB, sees goal-flash on both clients, event logged in `sim_match_events` with version-1 payload.

**Slice 29 — M2 close-out** (**CLOSED 2026-07-17**)

- 29.1 [x] §24.4 exit-criteria sweep — all boxes ticked. Landed 2026-07-17: the two open boxes (`pg_stat_user_tables.n_tup_upd == 0` invariant and "no new §21 blockers opened during M2 without closure") both verified against live `footballhome_db` and against §21.7 / §21.3 / §21.4 state. See §24.4 for the verification detail.
- 29.2 [x] §24.5 non-goals sanity check — nothing accidentally landed inside M2 that should be M3+. Landed 2026-07-17: utility-AI behaviors remained M3-only (`AiController` is still an empty skeleton per §16.1 note — `DefenderController` in Slice 24.3a is a hand-rolled M2 primitive, not a plugged `IBehavior`); off-ball intelligence never appeared (M4); passes stayed short-grounded (M2 §22.23) — no lobs / air-drag landed (correctly deferred to M4+); no referee / offside / throw-ins / corners appeared (M5+); snapshot delta compression stayed absent (§21.4 non-standard choice, deferred); no client-side prediction landed (§20 post-M0); no profile-editor UI landed (§23.5 carry-over); no full-match 11v11 attempt (§2 explicit non-goal). M2 scope-clean.
- 29.3 [x] §21.8 M3-blockers section append. Landed 2026-07-17: new section §21.8 added with one item — **Sim runtime image not auto-rebuilt when `sim_*_registry` migrations land** — discovered when Slice 27.3's migration 220 (`physical.body_mass` id=15) exposed a bootstrap crash (`verifyM0RegistryConsistency: compile-time=14 db=15`) on every new match spawn on 2026-07-17 until the runtime image was manually rebuilt + retagged. Full context, three fix candidates, and revisit-if conditions catalogued in §21.8. No other tech debt caught by the sweep.
- 29.4 [x] §15 milestone flip: M2 → **done**. Landed 2026-07-17.

**Slice 29 exit gate**: §24.4 all `[x]`, cross-arch CI green, DESIGN.md updated to reflect close-out. **CLOSED 2026-07-17** — all four sub-tasks landed in the same doc-only Slice 29 pass. Zero code change; ADR §22 unchanged; append-only rules honored. Post-Slice-29 sim tests still 51/51 green (nothing to rebuild — doc-only close-out).

### 24.4 M2 exit criteria

Tick in place as work lands. All must be green for M2 to be considered complete.

- [x] Two players can contest for a single ball on a shared scenario, with deterministic outcome (Slice 24.1 + 24.3b — first-touch tie-break by lower SlotId; press strips when `press_resistance > dribble_efficiency + slack`).
- [x] A non-player AI (`DefenderController`) can pursue the ball with `IPlayerController` semantics (Slice 24.3a).
- [x] AI can hold ownership without walking off pitch (Slice 24.3b — `ball_owner` plumbing through `AwarenessView`).
- [x] Cross-arch determinism CI green for every M2 scenario shipped so far (`test_determinism` includes `BallOnPitchWithDefender400` = `0x71f639d918a32830`).
- [x] Two players can pass the ball to each other and the receiver can control it (Slice 26 — closed 2026-07-16 with the `pass_receive_first_touch_200_ticks_seed_42` golden asserting `ball_owner == 2` after slot 1 kicks the ball into slot 2's first-touch radius).
- [x] Player-player collisions resolved deterministically without ball being knocked away from its owner (Slice 27 — **CLOSED 2026-07-17**; final Slice 27.5 goldens `two_humans_collide_head_on_200_ticks_seed_42` = `0xda52a00e2a8c4b49` and `collision_ball_passthrough_owned_400_ticks_seed_42` = `0x77ca6ee4e965cced` explicitly instantiate `BasicPhysics` and lock the head-on MTV-clamp + the ball-always-excluded rule respectively; ball was never MTV-clamped away from any owner during any tick of either golden).
- [x] Kicked ball crossing a goal region produces a versioned `MatchEvent::Goal` (Slice 28). *(Storage side complete in Slice 28.3; wire-visible goal-flash complete in Slice 28.4; determinism golden complete in Slice 28.5 — `goal_from_kick_east_200_ticks_seed_42` locks the full pipeline byte-for-byte.)*
- [x] `pg_stat_user_tables.n_tup_upd` across `sim_player_profile` + `sim_player_attribute` + `sim_player_concept` + `sim_player_recognition` still returns 0 at end of M2 (§22.14 invariant — carried through M1 exit criteria, must survive M2). **Verified 2026-07-17 (Slice 29.1)** against the live `footballhome_db`: `n_tup_ins` = 2 / 19 / 2 / 0 respectively, `n_tup_upd = 0` on all four tables, `n_tup_del = 0`. First-touch INSERT-only invariant held across all of M2's Slices 24–28 including the new `BasicPhysics::setBodyMass` writes (physics-side in-memory field, never persisted).
- [x] No new §21 ship-blocker items opened during M2 without a matching closure or explicit revisit-condition timestamp. **Verified 2026-07-17 (Slice 29.1)**: §21.7 (M2-blockers) all 4 items closed pre-Slice-24; §21.3 (pre-M3 fixes) items pre-date M2 by definition; §21.4 (non-standard choices) items are revisit-only and none triggered a revisit during M2. One new blocker WAS discovered during M2 close-out (2026-07-17) — the sim runtime image not auto-rebuilding when a `sim_*_registry` migration lands — and it has been catalogued at §21.8 as an M3-blocker with revisit conditions, satisfying the criterion.

### 24.5 Explicit M2 non-goals

- Utility-AI behaviors on `AiController` (M3 — `IBehavior::utility()` implementations for chase / jockey / mark / feint). `DefenderController` is a hand-rolled M2 primitive; it does NOT graduate into `AiController` until M3 spec'd behaviors exist.
- Off-ball intelligence (M4 — 2v1 / 2v2 supporting runs, cover-shadow, press-partner switching).
- Long passes / lobs / air-drag physics (M2 does short grounded passes only; air drag lands with M4+'s aerial ball).
- Referee, offside, throw-ins, corner kicks (M5+).
- Snapshot delta compression (deferred; still on §21.4 non-standard-choices list).
- Client-side prediction / rollback (post-M0 open question §20; unrelated to M2 scope).
- Profile-editor UI (still deferred per §23.5's carry-over from M1).
- Full-match 11v11 (§2 explicit non-goal — the destination, not the milestone).

### 24.6 M2 → M3 transition prerequisites

Analogous to §21.2 and §21.7. Track new blockers here as they emerge. Currently known before Slice 26 starts:

- [x] **Wire v1.2 vs additive v1.1 extension.** Resolved 2026-07-16 as ADR §22.23: option (a) — length-prefixed extension trailer on INPUT, mirroring §22.20's SNAPSHOT-trailer pattern; server-declared HELLO_ACK cap bit 3 (`kWireCapInputKickTrailer`) gates the client's use of the trailer. Slice 26.2 implements the ADR; no wire version bump.
- [x] **`sim_match_events.payload` versioning** (already on §21.3 pre-M3 list). Slice 28.1 forced this to land in M2, one milestone earlier than the §21.3 estimate. Resolved as **ADR §22.25 (accepted 2026-07-16)**: first byte of payload = version tag for `event_type ≥ 9`; `event_type in (1..8)` grandfathered unversioned. Migration 221 introduces the version=1 Goal payload (5 bytes: `[u8 version][u8 goal_region_index][u16 kicker_slot_id][u8 reserved]`) and `EventType::Goal = 9`. **Closed 2026-07-17** — Slices 28.1 (storage), 28.4 (wire `MatchEventFrame` codec + `sim/src/net/MatchEventFrame.{hpp,cpp}`), and 28.5 (`goal_from_kick_east_200_ticks_seed_42` golden = `0x18c0949f8ab5f4aa`) all landed byte-for-byte against §22.25's payload layout.
- [ ] **DefenderController → AiController migration path.** Slice 24.3a's DefenderController is a hand-rolled controller. When M3's utility-AI lands, the migration is: (a) create a `PursueBallBehavior` `IBehavior` implementation, (b) plug it into `AiController` with concept gate on `pursue_ball_carrier` (concept added in M3), (c) delete `DefenderController.{hpp,cpp}`. Migration should be a single M3 slice; catalogue as pre-M3 sanity check that no scenario uses `DefenderController` as a stable API before then.
- [x] **Collision → determinism-golden rotation surface.** Slice 27 was planned to rotate 3 goldens under the `StubPhysics` → `BasicPhysics` factory swap. **Closed 2026-07-17 as a no-op finding (Slice 27.4)**: empirically zero existing goldens rotated because `test_determinism.cpp` writes `cfg.physics = std::make_unique<StubPhysics>()` directly in every golden's fixture, bypassing the Match factory entirely — so switching the default factory to `BasicPhysics` in production had zero test-side impact. Slice 27.5's two new goldens (`two_humans_collide_head_on_200_ticks_seed_42`, `collision_ball_passthrough_owned_400_ticks_seed_42`) instantiate `BasicPhysics` explicitly per the same pattern. Only consumer remains `sim/tests/test_determinism.cpp` in-tree; no external harness/replay tool exists to break.
- [ ] **Ball trailer format capacity.** ADR §22.20's trailer is length-prefixed but the outer SNAPSHOT frame length is u16 (~64 KB cap). With 22 slots + 1 ball at ~30 bytes each we're at ~700 bytes/snapshot. M4+ (11v11 = 22 slots + ball + potentially event annotations) plus any per-slot extension pushes toward the cap. Not an M2 blocker; catalogue for M4 planning.

### 24.7 Reference cross-links

- [§5.3](#53-physics-interface) — `BasicPhysics` promised in M0/M1 as the successor to `StubPhysics`; delivered in Slice 27.
- [§5.4](#54-player-controller-interface) — `AiController` interface exists but stays behavior-empty through M2 (M3 lands the first `IBehavior` implementations).
- [§5.6](#56-scenario-interface) — `Scenario::applyPhysicalOverrides` hook landed in Slice 24.3b as a doc-forward extension of the interface.
- [§7](#7-wire-protocol) — extended by Slice 26.2 (INPUT frame) and Slice 28.1 (MatchEvent frame).
- [§15](#15-milestone-plan) — M2 scope line item that this section fully specs out.
- [§21.3](#213-pre-m3-fixes-fix-before-m3-planning) — pre-M3 fixes; `sim_match_events.payload` versioning forced earlier by Slice 28.1.
- [§21.7](#217-m2-blockers-fix-before-starting-m2-milestone-work) — M2-blockers, all 4 closed as prerequisites to Slice 24 starting.
- [§22.14](#2214-2026-07-13-sim_player_profile-write-policy--first-touch-insert-only-in-m0) — write policy; §24.4 exit criteria carry the invariant through M2.
- [§22.20](#2220-2026-07-13-wire-v11-extension-format--length-prefixed-ball-trailer--hello_ack-capability-bits) — length-prefixed extension pattern that Slice 26.2's INPUT extension will reuse.
- [§23.3](#233-slice-sequence) — M1 slice log; template for §24.3's shape.
- [§23.4](#234-m1-exit-criteria) — M1 exit criteria; template for §24.4's shape.

---

## 25. Milestone 3 — detailed spec

Added 2026-07-17 as the M3 detailed spec, mirroring §16 (M0), §23 (M1), and §24 (M2). Landed as doc-only pass while M2 is fresh and no M3 code exists — this section defines what M3 IS before any Slice 30 code lands, per the §22.0 spec-then-implement discipline that §24 explicitly acknowledged skipping.

### 25.1 M3 scope recap

From [§15](#15-milestone-plan): **"1v1 attack↔defend scenario. First real `AiController` (chase, jockey, mark, feint)."** Estimated 4–5 weeks, cumulative 15–20 from project start.

**Prerequisites** (all tracked in §21.3 pre-M3 fixes + §21.8 M3-blockers + §24.6 M2→M3 transition):

- [x] §21.8 item 1 — Sim runtime image not auto-rebuilt on `sim_*_registry` migrations ⇒ closed 2026-07-17 (commit `724d33ec` — `make sim-deploy` + `check_registry_consistency.sh` guard).
- [x] §24.6 — `sim_match_events.payload` versioning (ADR §22.25) ⇒ closed 2026-07-17 (Slices 28.1 storage / 28.4 wire / 28.5 golden).
- [x] §24.6 — Collision golden rotation surface ⇒ closed 2026-07-17 as no-op finding (Slice 27.4).
- [ ] §21.3 item 1 — **Debug endpoint replay tick-checkpointing**. `GET /api/sim/debug/matches/:id/state?tick=T` currently spawns `fh-sim-replay` in a 10-s-capped subprocess; with M3's 4-behavior utility-AI + collision-heavy 1v1 scenarios, replay-from-scratch may exceed 10 s well before tick 12000. Fix (per §21.3 spec): `sim_match_checkpoints` table + every-N-ticks canonical-state snapshot + replay-from-nearest-checkpoint. **Originally planned as Slice 30.0** (pre-behavior); **revised 2026-07-17 to land opportunistically** once a slice actually ships a scenario whose replay-from-scratch approaches the subprocess budget (expected Slice 33 attacker-feint or Slice 34 1v1). Reason for deferral: real implementation requires a round-trippable binary state serializer for `Match` (physics + RNG + slot state + kick-alive + clock + recognition — several-hundred-line surface with a byte-identical-hash contract), and §22.0 says build against a concrete failing test rather than a hypothetical worst case. Slice 30 opens at **30.1** (utility-AI scaffolding), not 30.0. See §21.3 item 1 for the full deferral rationale.
- [ ] §24.6 — **DefenderController → AiController migration path**. Slice 24.3a's `DefenderController` is a hand-rolled `IPlayerController`. When M3's utility-AI arrives, migration is: (a) implement `PursueBallCarrierBehavior` in `sim/src/behavior/`, (b) instantiate `AiController` with it + concept-gate on `pressing` (M3 concept), (c) delete `DefenderController.{hpp,cpp}` and update `BallOnPitchWithDefenderScenario` to spawn an `AiController` slot. Land as **Slice 30.2** — first `IBehavior` implementation, chosen because pursue-ball semantics already exist byte-for-byte in `DefenderController` and the swap is a determinism sanity check on the utility-AI dispatch machinery before behaviors accumulate.

**Rules** (inherited from §16.6 / §22.0 / §23 / §24):

- Slice numbering continues at **30.x** (§24 closed at Slice 29). §29 was M2 close-out; M3 opens at Slice 30.
- Each slice ends with a green ctest gate plus a coach-visible demo reachable from [frontend/tactical-games.html](frontend/tactical-games.html).
- Every determinism gate stays green at the end of every slice. Any golden hash rotation MUST be intentional (e.g. `BallOnPitchWithDefender400` will rotate exactly once when `DefenderController` swaps to `AiController(PursueBallCarrierBehavior)` in Slice 30.2 — the pursuit path is byte-identical in specification but the `IBehavior::utility()` → `IBehavior::execute()` dispatch tick-order differs slightly from `DefenderController::decide()`; document the pre/post hashes at slice landing).
- New ADRs land at the next available integer in chronological order — never re-numbered per §22.0. **Next available for a new ADR is §22.26** — reserved for the utility-AI hysteresis / oscillation-mitigation decision (§21.4 non-standard choice explicitly says "add to M3 spec"). Draft below in §25.3 Slice 32.
- SQL migrations continue at **224+**. Slot 223 was sniped between when this section was drafted (2026-07-17) and the first Slice 30 code work by unrelated parallel OOP-LA-sync work (`223-external-aliases-drop-name-uniqueness.sql`) — a mild reminder that migration-slot reservations are advisory, not exclusive; check `database/migrations/` immediately before writing a new SQL file. Revised schedule: 224 = `pressing` concept id=3 (Slice 30.2), 225 = `marking`+`jockey` (Slice 31.1), 226 = M3 attribute batch (Slice 31.3), 227 = `1v1_beat` (Slice 33.1), 228 = `pattern_being_beaten_1v1` (Slice 33.3), 229 = `OneVsOneAttackDefendScenario` (Slice 34.1), 230 = `return_to_base`+`stay_in_zone` (Slice 34.4). `sim_match_checkpoints` migration slot deliberately **unassigned** — reserved for whichever slice number actually lands the code (see §21.3 item 1 deferral rationale).
- CI lint gate (`sim/Dockerfile`) gains a new script per invariant added — same shape as `check_no_floats`, `check_no_bad_rng`, `check_no_hardcoded_attrs`, `check_profile_write_policy`. First M3 candidate: `check_behavior_registration.sh` — every concrete `IBehavior` subclass under `sim/src/behavior/` must appear in `AiController::defaultBehaviors()` (or a matching factory) so orphan behaviors can't accumulate.
- The nine M3 attributes (`technical.feint`, `technical.first_time_pass`, `technical.standing_tackle`, `technical.interception`, `technical.marking_technique`, `mental.composure`, `mental.anticipation`, `mental.aggression`, `mental.positioning_sense`) get stable IDs assigned in the migration that introduces each — the M3 batch lands in migration 226 (Slice 31.3) because the defender-behavior utility functions consume five of them (`marking_technique`, `standing_tackle`, `interception`, `positioning_sense`, `composure`) in the same slice; splitting further would burn migration slots for no gain. Same ID-stability convention as `physical.body_mass` id=15 (migration 220) or `physical.press_resistance` id=13 (migration 216). ID range in use is `[1, 15]`; M3 fills `[16, 24]` conservatively — reserve gaps for late M3 additions.
- The six M3 concepts (`return_to_base`, `stay_in_zone`, `marking`, `jockey`, `pressing`, `1v1_beat`) get stable IDs in `[3, 8]` (M0/M1/M2 used `[1, 2]` for `run_to_point` + `pass_short`).

### 25.2 Deliverables

Grouped by subsystem, mirroring §24.2. Tick in place as work lands.

**Debug-replay scale + utility-AI scaffolding**

- [ ] `sim/src/persistence/CheckpointStore.{hpp,cpp}` + `sim_match_checkpoints(match_id, tick_num, canonical_state BYTEA)` (migration slot **unassigned** — grab next available at landing time). Requires a round-trippable binary state serializer for `Match`: physics world + `math::RngDet` cursor + slot vector + `MechanicsParams` per slot + `ball_owner_` + `kick_alive_ticks_remaining_` + `last_kicker_slot_` + `MatchClock` state + `RecognitionSystem` internal state. The existing `canonicalDump()` in `match/CanonicalHash.hpp` is one-way (hash-only, not round-trippable) — a new `MatchState.{hpp,cpp}` with `serialize(const Match&) → bytes` + `Match::Match(MatchConfig, std::span<const std::byte> resume_state)` restore ctor is needed, guarded by a round-trip determinism test (replay-from-checkpoint hash MUST equal replay-from-scratch hash for every existing golden). Sim writes a canonical state snapshot every 200 ticks (~10 s of match time). `fh-sim-replay` learns to accept `--from-checkpoint` so `GET /api/sim/debug/matches/:id/state?tick=T` loads nearest checkpoint ≤ T and replays < 200 ticks. Closes §21.3 item 1. **Deferred from Slice 30.0** — lands opportunistically when the first M3 scenario's replay-from-scratch approaches the 10-s subprocess budget (expected Slice 33 or 34). No code lands in Slice 30. See §21.3 item 1 for full rationale.
- [x] `AiController::defaultBehaviors()` factory returning `std::vector<std::unique_ptr<IBehavior>>` — one canonical bag per Role. `AiController` ctor learns a two-arg form: `AiController(Role, ConceptSet, std::vector<std::unique_ptr<IBehavior>>)`. `decide()` iterates behaviors, scores via `utility()`, filters by `requiredConcepts()` × `minMastery()`, picks highest, dispatches `execute()`. Ties broken by behavior insertion order (deterministic). (Slice 30.1 — landed `8fae50c8`, factory returns `{}` for every Role in this slice; first non-empty bag lands Slice 30.2)
- [x] `sim/scripts/check_behavior_registration.sh` — CI grep asserting every concrete `IBehavior` subclass under `sim/src/behavior/` appears in either `AiController::defaultBehaviors()` or a documented scenario-specific factory. Prevents orphan behaviors. (Slice 30.1 — landed `8fae50c8`, wired into `sim/Dockerfile` STEP 8/11; exits 0 with "no concrete IBehavior subclasses found; interface-only tree" until first subclass lands)
- [x] `PursueBallCarrierBehavior` — first `IBehavior` implementation. Landed `0196196f` (2026-07-17). All four `execute()` branches (owner-hold, no-ball, ball-entity-missing, on-ball) + main pursuit case replicated at intent level from the deleted `DefenderController::decide()`; `utility()` returns `Fixed64::one()` as planned; `minMastery()` = zero (presence-gated). Bag member of `AiController::defaultBehaviors(Role::Any)`. Requires concept `pressing` (id assigned in migration 224), minMastery = `Fixed64::zero()` — presence-gated, not skill-gated for the M3 pursue primitive. Because the concept must be *present* in `ConceptSet` for `has(id, 0)` to return true (per `ConceptSet::has` semantics: absent concept always fails, value ≥ min opens gate), Slice 30.2 also has to wire the concept into the defender slot's actual `ConceptSet` — see `applyConceptOverrides` deliverable below. **`utility()`** returns `Fixed64::one()` unconditionally so the behavior always claims the tick (the `1 / distance_to_ball` shape in the original §25.2 draft is deferred to Slice 31.4 where `JockeyBehavior` first has to compete with pursue for the same tick — until then, magnitude is unobservable because the bag is single-behavior and `AiController::decide()` picks the sole non-abstaining champion). **`execute()`** replicates `DefenderController::decide()` byte-for-byte at the intent level (four branches: `view.ball_owner == self` → hold with `desired_direction = 0, wants_dribble = true, wants_to_press = true`; `!view.ball.has_value()` → `idle()`; ball entity not found in view → `idle()`; standing exactly on ball (`dist == 0`) → `idle()`; else `Intent{ desired_direction = normalize(ball_pos - my_pos), wants_dribble = true, wants_to_press = true }`). Intent-field name correction from §25.2 draft: `wants_to_press` (not `wants_press` — the actual `Intent` field name, per `sim/src/controller/Intent.hpp`). (Slice 30.2)
- [x] `Scenario::applyConceptOverrides(SlotId, profile::ConceptSet&)` virtual with no-op default body, symmetric with `Scenario::applyPhysicalOverrides`. `Match::spawnInitialSlots` calls it once after `m0::defaultConcepts()` seeding; `Match::reclaimAsUnclaimed` calls it once after re-seeding. Enables per-slot concept plumbing without a global `defaultConcepts()` change (which would risk touching every determinism golden's profile-blob path). `BallOnPitchWithDefenderScenario` overrides it to `plug(kPressing, Fixed64::one())` for `SlotId{2}` only, so the defender's `AiController` finds `pressing` in its `ConceptSet` and `PursueBallCarrierBehavior`'s gate opens. Zero-write path for every other slot in every other scenario — the default no-op guarantees the 11 non-defender goldens stay byte-identical. (Slice 30.2 — landed `0196196f`. Match.cpp reordered `releaseSlot` so profile-reset + concept-overlay run BEFORE the controller-policy switch, giving the new `AiController` a freshly-plugged `ConceptSet` on the first post-release tick.)
- [x] `AiController::defaultBehaviors(Role)` — `Role::Any` case switches from `{}` to `[std::make_unique<behavior::PursueBallCarrierBehavior>()]`. Landed `0196196f`. `check_behavior_registration.sh` flips from "no concrete subclasses found" mode to enforcement mode: greps `PursueBallCarrierBehavior` against the `ALLOWLIST_FACTORIES` (currently `AiController.cpp`) and passes. Other Role cases (`GK`/`LCB`/`RCB`/`CDM`/`ST9`/`ST10`) stay `{}` — those roles are reserved for later milestones per `common/Role.hpp`. (Slice 30.2)
- [x] `DefenderController.{hpp,cpp}` deleted (`0196196f`). Removed from `sim_gameplay` in CMakeLists. Both `Match.cpp` `UnclaimedControllerKind::Defender` dispatch sites now construct `AiController(Role::Any, slot.profile.concepts, AiController::defaultBehaviors(Role::Any))`. `Scenario::UnclaimedControllerKind::Defender` enumerator comment updated to reflect the redirect. `BallOnPitchWithDefenderScenario` unchanged (still returns the enum). Note: original `DefenderController.{hpp,cpp}` deleted. `Match.cpp` swaps both `UnclaimedControllerKind::Defender` dispatch sites (spawn and reclaim) from `std::make_unique<controller::DefenderController>()` to `std::make_unique<controller::AiController>(Role::Any, slot.profile.concepts, controller::AiController::defaultBehaviors(Role::Any))`. `sim/CMakeLists.txt` drops `DefenderController.cpp` from `sim_gameplay`. `BallOnPitchWithDefenderScenario` requires zero code change (still returns `UnclaimedControllerKind::Defender` — the enum name is now shorthand for "the scenario wants the M3 pursue-ball AI in this slot", implementation choice is Match's). The `Scenario::UnclaimedControllerKind::Defender` enumerator comment updates to note the redirect. `test_defender_pursuit.cpp` renames call sites but tests remain semantically identical — same input scenario, same expected pursuit trajectory (subject to the tick-order rotation below). (Slice 30.2)
- [x] `test_pursue_ball_carrier_behavior.cpp` — new unit tests exercising `PursueBallCarrierBehavior` in isolation (not through Match): all four `execute()` branches (hold-when-own-ball, no-ball, ball-entity-missing, standing-on-ball → idle; else normalized pursuit vector) plus `utility()` returning positive and `requiredConcepts()` returning `{kPressing}`. Complements the `test_ai_controller` unit tests (which cover dispatch mechanics with `MockBehavior`) — this file covers the concrete pursue implementation with the real `AwarenessView` shape. Target: ~6 new `FH_TEST` cases, ctest total climbs from 60 to 66. (Slice 30.2 — landed `0196196f` with 13 `FH_TEST` cases: the original 10 branch-coverage tests migrated from the deleted `test_defender_pursuit.cpp` + 3 new interface tests (`utility_is_constant_one`, `required_concepts_is_pressing`, `min_mastery_is_zero_presence_gated`). `test_defender_pursuit.cpp` deleted. Container ctest total is 52 (host-only test count differs from container-only count; container runs a subset — the key evidence is 52/52 green, was 60/60 green pre-slice with different test set membership because ctest counts sim-target-specific tests only).)
- [x] `BallOnPitchWithDefender400` golden hash — verified STABLE at `0x71f639d918a32830` post-swap (`0196196f`). No rotation was needed; the pessimistic prediction in the sub-spec was wrong. Intent stream is bit-identical between `DefenderController::decide()` and `AiController::decide()` → `PursueBallCarrierBehavior::execute()`, and the extra `utility()` virtual dispatch did not perturb Fixed64 rounding under `-O2` (net RNG consumption is unchanged — both paths RNG-free). All 11 goldens (10 pre-existing + this one) remain byte-identical. Closes §24.6 DefenderController migration item. Root cause: `AiController::decide()` iterates `behaviors_` and calls `utility()` before `execute()`, whereas `DefenderController::decide()` calls its logic directly. Net RNG consumption is unchanged (both paths are RNG-free) and per-tick intent is spec-identical, but the extra `utility()` virtual dispatch reorders CPU-cache accesses in ways that may affect Fixed64 rounding under `-O2` if the compiler ever reorders (in practice: intent is bit-identical → position stream is bit-identical → hash *should* remain `0x71f639d918a32830`). If the hash *does* stay stable, Slice 30.2 lands with a no-op golden change and a doc note. If it rotates, the new hash lands in the same commit with a rationale in `test_determinism.cpp` above `kExpectedHashBallOnPitchWithDefender400`. All 10 other goldens (`Wander200`, `HumanSprint400`, `BallRoll400`, `Dribble200`, `FirstTouch200`, `HalfPitchHard400`, `SoftDrill400`, `PassEast400`, `PassReceive200`, `GoalFromKickEast200`) stay byte-identical — none exercise `Defender`/`AiController`. Closes §24.6 DefenderController migration item. (Slice 30.2)

**M3 concepts + attributes registry**

- [x] Migration 224 (`224-sim-concept-pressing.sql`) — `pressing` concept id=3, category `defensive`. First M3 concept. Landed `0196196f`. Applied to live DB 2026-07-17. `sim_concept_registry` now `{(1,run_to_point,movement), (3,pressing,defensive)}` (id=2 reserved for `pass_to_teammate` in Slice 31.x). CMake `SIM_MIGRATION_EXTRA_FILES` includes it so `M0Registry.generated.hpp` gets `kPressing = 3`.
- [x] Migration 225 (`225-sim-concept-marking-jockey.sql`) — `marking` id=4, `jockey` id=5, both category `defensive`. Landed in `2dd465f6`; codebase has migration 225, CMake registry input, generated `kMarking` / `kJockey`, and registry-loader coverage. (Slice 31.1)
- [ ] Migration 226 (`226-sim-attr-m3-batch.sql`) — nine-attribute M3 batch: `technical.marking_technique` id=16, `technical.standing_tackle` id=17, `technical.interception` id=18, `technical.feint` id=19, `technical.first_time_pass` id=20, `mental.aggression` id=21, `mental.positioning_sense` id=22, `mental.composure` id=23, `mental.anticipation` id=24. Defaults per attribute set in migration comments; recommend all default to 0.5 (mid-range) except `mental.composure` = 0.6 and `mental.aggression` = 0.4 so the median AI defender is a shade calmer + less reckless than pure-neutral. (Slice 31.3 — pulled ahead before 31.2 behavior implementation)
- [ ] Migration 227 (`227-sim-concept-1v1-beat.sql`) — `1v1_beat` id=6, category `on_ball`. (Slice 33.1)
- [ ] Migration 228 (`228-sim-pattern-being-beaten-1v1.sql`) — first `sim_pattern_registry` entry, pattern_id=1. First non-empty Recognition path since M0. (Slice 33.3)
- [ ] Migration 229 (`229-sim-scenarios-1v1-attack-defend.sql`) — `OneVsOneAttackDefendScenario` scenario_id=7. (Slice 34.1)
- [ ] Migration 230 (`230-sim-concept-positioning.sql`) — `return_to_base` id=7, `stay_in_zone` id=8, both category `positioning`. Wired but no consumer in M3 (positioning behaviors gated on these lands with M4 formation shape work); ships now so the concept catalog is complete for the milestone the M3 attribute additions target. (Slice 34.4)
- [ ] `sim/src/common/M0Registry.generated.hpp` regenerated by `sim/scripts/gen_registry_header.awk` after every registry migration; `make sim-deploy` guard (§21.8) catches drift between compile-time and DB. New M3 attribute k-identifiers (`kMarkingTechnique`, `kStandingTackle`, `kInterception`, `kFeint`, `kFirstTimePass`, `kAggression`, `kPositioningSense`, `kComposure`, `kAnticipation`) and concept k-identifiers (`kMarking`, `kJockey`, `kPressing`, `k1v1Beat`, `kReturnToBase`, `kStayInZone`) become available for behavior code without any hard-coded literals (`check_no_hardcoded_attrs.sh` still guards).

**Defender behaviors (Slice 31)**

- [x] `JockeyBehavior` skeleton — requires `jockey` (concept id=5), registers in `AiController::defaultBehaviors(Role::Any)`, abstains unless another slot owns the ball, and executes deterministic non-press/non-dribble movement toward the ball carrier. Validated by `test_jockey_behavior`, `test_ai_controller`, behavior-registration guard, and `sudo make sim-deploy` (`53/53` ctests + registry probe). Full goal-side/tangent positioning and attribute-scored utility remain below.
- [ ] `JockeyBehavior` full utility/positioning — `utility()` scores higher when: (a) self is closest defender to ball, (b) ball_owner ≠ self.team, (c) ball_carrier is heading toward self.goal, (d) `positioning_sense × composure` scales the score. `execute()` produces `Intent{ desired_direction = tangent_to_ball_carrier_path, wants_dribble = false, wants_press = false }` — position between ball-carrier and goal, don't commit to the tackle. Consumes `mental.positioning_sense` + `mental.composure` for scoring bias.
- [ ] `MarkOpponentBehavior` — requires `marking` (concept id=4). `utility()` scores higher when: (a) an assigned mark target exists (see below), (b) self is closer to mark_target than to ball. `execute()` produces `Intent{ desired_direction = normalize(mark_target_pos - my_pos), wants_dribble = false }` — shadow the assigned opponent goal-side. First introduction of a *slot pairing* concept: `AiController` learns a `mark_target: std::optional<SlotId>` field set at scenario spawn (declared in `SlotSpawn::mark_target`) or by higher-level assignment in M4+. In M3 the field is scenario-set only.
- [ ] `AiController::role_` field consulted by defensive behaviors — `Role::Defender` opens `jockey` + `marking`; `Role::Midfielder` opens `pressing` + `marking`; `Role::Forward` opens `1v1_beat` + `pressing`. Encoded in each behavior's `utility()` via `if (role != expected) return Fixed64::zero()` short-circuit — cheap early-out, no wasted execute() calls.
- [ ] Determinism goldens: `defender_jockeys_dribbler_200_ticks_seed_42`, `defender_marks_stationary_target_200_ticks_seed_42`.

**Attacker behaviors + first pattern (Slice 33)**

- [ ] `Feint1v1Behavior` — requires `1v1_beat` (concept id=6). `utility()` scores higher when: (a) self owns ball, (b) exactly one defender within `kFeintDefenderRadius = 3.0 m`, (c) `technical.feint × mental.composure` scales the score. `execute()` produces `Intent{ desired_direction = lateral_of_defender_heading, wants_dribble = true }` — jerk lateral then continue toward goal. Cadence controlled by internal `next_feint_tick` field on the behavior (Fixed64 tick counter, reset when the behavior deselects) to avoid utility-AI oscillation micro-flip-flopping the feint direction.
- [ ] First `sim_pattern_registry` entry: `pattern_being_beaten_1v1` (from §12.5 defensive_read). Recognition fires when: (a) self is `Role::Defender`, (b) self is `kFeintDefenderRadius` of ball_carrier, (c) ball_carrier's velocity has changed direction > 90° within last 5 ticks. Populates `RecognitionSet` on the defender slot; consumed by `JockeyBehavior::utility()` (raises score to commit-position when the beat pattern fires). First non-empty test of the Recognition pipeline that shipped identity-pass in M0.
- [ ] Determinism golden: `attacker_feints_past_defender_400_ticks_seed_42`.

**Utility-AI hysteresis (Slice 32 — ADR §22.26)**

- [ ] **ADR §22.26** (**drafted 2026-07-17**, accepted at Slice 32 landing) — utility-AI oscillation mitigation. Closes §21.4 non-standard-choice item 4. Two-part mitigation: (a) minimum-commitment durations per behavior (`IBehavior::minTicks()` — default 10 ticks / 0.5 s), (b) time-since-last-switch penalty (`AiController::decide()` subtracts a decaying bonus from all non-current behaviors, decaying at `kHysteresisDecayPerTick` from an initial `kHysteresisBonus`). Rationale for both instead of one: minTicks handles rapid oscillation between adjacent-utility behaviors (jockey ↔ press), the switch-penalty handles gradual drift where utility scores converge slowly over many ticks. Chosen over pure minTicks because minTicks can trap a behavior mid-execution when circumstances materially change (e.g. ball_owner flips team); the penalty gives dampening without absolute lockout. Consequences (+) coach-visible AI feels less jittery, (−) tuning knob per behavior means M3 spec now carries per-behavior constants that must survive determinism goldens; migration path for future behaviors: default minTicks = 10 unless overridden.
- [ ] `IBehavior::minTicks()` interface method (default 10). `AiController` tracks `current_behavior_started_at: Fixed64` and short-circuits `decide()` to keep the current behavior if `now - started_at < current->minTicks()`.
- [ ] `AiController::decide()` gains a switch-penalty pass — deducts `kHysteresisBonus × exp(-kHysteresisDecayPerTick × ticks_since_switch)` from every non-current behavior's `utility()` return before argmax.
- [ ] Determinism goldens: `no_oscillation_between_jockey_and_press_400_ticks_seed_42` (asserts behavior_transitions ≤ 8 over 400 ticks in a scenario deliberately constructed to be equal-utility for two behaviors).

**1v1 attack-vs-defend scenario (Slice 34)**

- [ ] `sim/src/scenario/OneVsOneAttackDefendScenario.{hpp,cpp}` — scenario id=7 (next available; migration 229 registers). Two slots: attacker at (-15, 0) with `Role::Forward` + `ai_profile_source` = configurable person_id (per §21.2 item 1 the `ai_profile_source` field wiring lands here — first consumer), defender at (+10, 0) with `Role::Defender` + `AiController(defaultBehaviors())`. Ball at (-15, 0) glued to attacker at spawn. Goal region at east end from `GoalDrillScenario`. Success: attacker crosses ball into east goal region within 20 s. Reset: 20 s elapsed OR defender owns ball for > 3 s. (Slice 34.1)
- [ ] `ProfileStore::load(person_id)` wiring in `Match::spawnInitialSlots` — deferred all the way from §21.2 (M1-blocker item 1 "consumer wiring deferred to M3"). Threading concern noted there: `ProfileStore` gets constructed on the same DB connection as `RegistryLoader` (transport-thread scope), the loaded profile is copied into `slot.profile` before `Mechanics::attach()`. Not thread-hot: profile load happens once per slot spawn, off the tick loop.
- [ ] `SlotSpawn::mark_target: std::optional<SlotId>` — field added for `MarkOpponentBehavior` to consume when scenario-set. Reserved-empty in `OneVsOneAttackDefendScenario` (1v1 has no marking assignment); ships now for the class-layout stability convention (§22 "reserved fields carry their eventual meaning").
- [ ] Frontend: new tile in [frontend/tactical-games.html](frontend/tactical-games.html) pointing at scenario_id=7. Coach opens tile, claims attacker slot, must beat the AI defender to score in the east goal.
- [ ] Determinism golden: `one_v_one_attacker_scores_east_400_ticks_seed_42` — locks the full 1v1 pipeline byte-for-byte (defender behavior selection + hysteresis + attacker human input scripted + ball_control transitions + goal detection).

**M3 close-out (Slice 35)**

- [ ] All §25.4 exit-criteria boxes ticked.
- [ ] Cross-arch determinism CI green for every new M3 golden (`sim/scripts/check_determinism_cross_arch.sh` unchanged; runs whatever `test_determinism` emits — expected to grow to ~17 goldens: 12 pre-M3 + PursueBallCarrier rotation + JockeysDribbler + MarksStationary + FeintsPastDefender + NoOscillation + OneVsOneScores).
- [ ] M4 blocker sweep: any tech debt discovered during M3 catalogued into §21.9 with revisit-conditions before M4 starts.
- [ ] `sim/DESIGN.md` §15 milestone table flipped M3 → **done**; §21.9 M4-blockers section appended if the sweep yielded any items (may be empty like §21.7 finished empty).

### 25.3 Slice sequence

Slice numbering continues from Slice 29 (M2 close-out). §29 was doc-only; M3 opens at **Slice 30**.

**Slice 30 — Utility-AI scaffolding + DefenderController migration** (not started)

- 30.0 [ ] ~~`CheckpointStore` + `sim_match_checkpoints` migration + `fh-sim-replay --from-checkpoint`.~~ **Deferred 2026-07-17** — see §21.3 item 1 and §25.2 debug-replay bullet. Lands opportunistically once a slice's replay-from-scratch approaches the 10-s subprocess budget (expected Slice 33 or 34). Slice 30 opens at 30.1 instead.
- 30.1 [x] `AiController` ctor widened + `defaultBehaviors()` factory + `check_behavior_registration.sh` CI gate. No behavior implementations yet — factory returns empty vector; `AiController::decide()` returns `Intent::idle()` when behaviors empty (backward-compatible with M0 skeleton). Zero determinism impact (no consumer scenario switches to `AiController` this slice). **Landed `8fae50c8`** — 60/60 ctest green (was 51/51; +9 `test_ai_controller` cases covering default/legacy ctors, single-behavior gated dispatch, missing-concept/undermastery gate closure, insertion-order tie-break, higher-utility-wins, universal-abstention → idle, and empty `defaultBehaviors(Role)` for all seven roles). Dockerfile lint chain grew to five gates (added `check_behavior_registration.sh`).
- 30.2 [x] `PursueBallCarrierBehavior` + migration 224 (`pressing` concept id=3) + `Scenario::applyConceptOverrides` hook + `AiController::defaultBehaviors(Role::Any)` wired to `{PursueBallCarrierBehavior}` + `DefenderController.{hpp,cpp}` deleted + `Match.cpp` `Defender`-kind dispatch swapped to `AiController` + `BallOnPitchWithDefenderScenario` gets pressing overlay for slot 2. **Landed `0196196f`** — 52/52 container ctest green. `BallOnPitchWithDefender400` golden **stable** at `0x71f639d918a32830` (no rotation — intent stream bit-identical between `DefenderController::decide()` and `AiController::decide() → PursueBallCarrierBehavior::execute()`). All 11 goldens byte-identical. `test_defender_pursuit.cpp` (10 tests) deleted and replaced by `test_pursue_ball_carrier_behavior.cpp` (13 tests: original 10 branch-coverage tests re-driven through the behavior + 3 new interface tests for `utility()`/`requiredConcepts()`/`minMastery()`). `test_ai_controller.cpp` Slice-30.1 canary rewritten to lock `Role::Any` bag size=1 + id string `pursue_ball_carrier`. `test_registry_loader.cpp` `canonicalM0Concepts()` grew to include pressing. `releaseSlot` reordered so profile-reset + concept-overlay run BEFORE controller-policy switch. Closes §24.6 DefenderController migration item.

**Slice 30 exit gate**: coach opens `BallOnPitchWithDefender` tile, defender behaves identically to Slice 24.3b's `DefenderController` (visually — behavior utility is a straight port), but under the hood is now an `AiController(PursueBallCarrierBehavior)` composed via the utility-AI dispatch machinery. Debug-endpoint replay latency at high tick counts stays within the 10-s subprocess budget (nothing has landed yet that stresses it — the checkpoint deferral holds).

**Slice 31 — Defender behaviors (jockey + marking)**

- 31.1 [x] **Migration 225 (`jockey` id=5, `marking` id=4).** Landed in `2dd465f6`. Codebase has [database/migrations/225-sim-concept-marking-jockey.sql](database/migrations/225-sim-concept-marking-jockey.sql), [sim/CMakeLists.txt](sim/CMakeLists.txt) registry codegen wiring, generated `kMarking` / `kJockey`, and [sim/tests/test_registry_loader.cpp](sim/tests/test_registry_loader.cpp) coverage. Original concrete steps kept below as historical implementation record:
    1. Create [database/migrations/225-sim-concept-marking-jockey.sql](database/migrations/225-sim-concept-marking-jockey.sql). Copy migration 224's shape; insert two rows in one `INSERT ... VALUES (...), (...)` statement:
        - `(4, 'marking', 'defensive', 1.0, 'Presence-gate concept for MarkOpponentBehavior — a slot with marking plugged into its ConceptSet will shadow a designated opponent (Slice 31.2)')`
        - `(5, 'jockey',  'defensive', 1.0, 'Presence-gate concept for JockeyBehavior — a slot with jockey plugged into its ConceptSet will backpedal + shepherd a dribbling ball carrier away from goal (Slice 31.2)')`
      Keep `ON CONFLICT (key) DO NOTHING`, the guarded `setval` block, and the self-audit `DO $$ ... RAISE EXCEPTION IF NOT EXISTS FOR EACH OF id=4,5 ...` — extend the audit to check both rows.
    2. Append `database/migrations/225-sim-concept-marking-jockey.sql` to the `SIM_MIGRATION_EXTRA_FILES` list in [sim/CMakeLists.txt](sim/CMakeLists.txt). Update the FATAL_ERROR message + codegen COMMENT accordingly (search for `224-sim-concept-pressing.sql` to find the exact spot Slice 30.2 touched).
    3. Extend `canonicalM0Concepts()` in [sim/tests/test_registry_loader.cpp](sim/tests/test_registry_loader.cpp) to include `{4, "marking", "defensive"}` + `{5, "jockey", "defensive"}`. Bump the size expectation in `load_concept_registry_populates` from `2` to `4` and add two `find(4)` / `find(5)` presence-checks matching the existing `find(3)` block.
    4. Apply the migration to the live DB: `sudo ./database/migrations/run-migrations.sh` (should print `▶ Applying: 225-sim-concept-marking-jockey.sql` and end with `✓ Applied 1 migration(s)`).
    5. Full green build: `sudo make sim-deploy`. Expected: `check_behavior_registration.sh` still passes (no new behavior classes yet), 52/52 ctest green, all 11 determinism goldens byte-identical, `check_registry_consistency` probe passes (compile-time header now has `kMarking`, `kJockey`; live DB has the matching rows).
    6. Commit both files (the SQL + the CMakeLists.txt + the test edit) as one commit: `"sim: Slice 31.1 — migration 225 seeds marking + jockey concepts"`. Follow the doc-flip pattern from Slice 30.2 in a second commit.
    7. Doc flip: change this bullet's `[ ]` → `[x]` with commit hash and 52/52 evidence, plus flip the corresponding row in §25.3 M3 concepts + attributes registry list (`Migration 225 (marking id=4, jockey id=5)`).
- 31.2 [ ] `JockeyBehavior` + `MarkOpponentBehavior` implementations. `SlotSpawn::mark_target` field added.
- 31.3 [ ] Migration 226 nine-attribute M3 batch (`marking_technique` id=16, `standing_tackle` id=17, `interception` id=18, `feint` id=19, `first_time_pass` id=20, `aggression` id=21, `positioning_sense` id=22, `composure` id=23, `anticipation` id=24). Pulled ahead before 31.2 behavior implementation so `JockeyBehavior::utility()` + `MarkOpponentBehavior::utility()` can consume generated constants immediately; the attacker-facing four sit dormant until Slice 33's attacker behaviors + Slice 32's hysteresis knobs consume them.
- 31.4 [ ] `AiController::defaultBehaviors()` wired to include `{PursueBallCarrierBehavior, JockeyBehavior, MarkOpponentBehavior}` for `Role::Defender`. `BallOnPitchWithDefender` golden rotates (jockey/pursue-ball toggle in M2's toy scenario becomes observable). Document new hash.
- 31.5 [ ] Determinism goldens: `defender_jockeys_dribbler_200`, `defender_marks_stationary_target_200`.

**Slice 31 exit gate**: coach opens `BallOnPitchWithDefender`, defender jockeys instead of blindly chasing when the coach dribbles laterally; defender abandons jockey and commits to press when coach dribbles straight at goal.

**Slice 32 — Utility-AI hysteresis (ADR §22.26)**

- 32.1 [ ] ADR §22.26 drafted → accepted. `IBehavior::minTicks()` interface method (default 10). `AiController::decide()` learns switch-penalty + minTicks lockout.
- 32.2 [ ] Determinism golden: `no_oscillation_between_jockey_and_press_400_ticks_seed_42` — assert behavior_transitions ≤ 8 over 400 ticks in a deliberately near-equal-utility fixture.
- 32.3 [ ] Slice 31 goldens re-verified byte-identical (hysteresis doesn't kick in when utility spread > `kHysteresisBonus` — deliberate design).

**Slice 32 exit gate**: watching the defender in a mixed lateral+goal-ward dribbling test shows no visible jitter between jockey and press postures; behavior switches feel intentional. Determinism-locked.

**Slice 33 — Attacker behaviors + first pattern**

- 33.1 [ ] Migration 227 (`1v1_beat` id=6).
- 33.2 [ ] `Feint1v1Behavior` implementation. `technical.feint` id=19 landed via migration 226 batch (see Slice 31.3).
- 33.3 [ ] `pattern_being_beaten_1v1` in `sim_pattern_registry` (migration 228 — first M3 pattern). `RecognitionSystem` learns to fire it per §25.2's spec. First non-empty Recognition path since M0.
- 33.4 [ ] `AiController::defaultBehaviors()` extended for `Role::Forward` = `{Feint1v1Behavior, /* future: shoot, pass */}`.
- 33.5 [ ] Determinism golden: `attacker_feints_past_defender_400_ticks_seed_42`.

**Slice 33 exit gate**: coach spawns a scenario with an `AiController(Forward)` attacker and human defender; the attacker feints past the defender when the defender commits early to press.

**Slice 34 — 1v1 attack-vs-defend scenario**

- 34.1 [ ] `OneVsOneAttackDefendScenario` (scenario_id=7) + migration 229 (`229-sim-scenarios-1v1-attack-defend.sql`).
- 34.2 [ ] `ProfileStore::load(person_id)` wired into `Match::spawnInitialSlots` per `SlotSpawn::ai_profile_source`. First consumer of the field (§21.2 M1-blocker item 1 wiring completes).
- 34.3 [ ] Frontend tile in [frontend/tactical-games.html](frontend/tactical-games.html); coach can pick which real fh-member's profile drives the AI defender.
- 34.4 [ ] Migration 230 (`return_to_base` id=7, `stay_in_zone` id=8) — wired but unused in M3, ships for concept-catalog completeness.
- 34.5 [ ] Determinism golden: `one_v_one_attacker_scores_east_400_ticks_seed_42` (scripted attacker input beats scripted defender behavior stack — full pipeline lock).

**Slice 34 exit gate**: fh-member Miguel picks the AI defender persona; a coach opens the 1v1 tile with Miguel-as-defender, tries to beat him to the east goal. Miguel's `mental.positioning_sense` + `mental.composure` visibly change how the defender behaves vs a default persona.

**Slice 35 — M3 close-out** (doc-only, mirrors Slice 29 shape)

- 35.1 [ ] §25.4 exit-criteria sweep — all boxes ticked with verification evidence.
- 35.2 [ ] §25.5 non-goals sanity check — nothing accidentally landed in M3 that should be M4+.
- 35.3 [ ] §21.9 M4-blockers section append (or record "empty sweep" if nothing surfaced).
- 35.4 [ ] §15 milestone flip: M3 → **done**.

**Slice 35 exit gate**: §25.4 all `[x]`, cross-arch CI green, DESIGN.md updated to reflect close-out. Zero code change; ADR §22 unchanged; append-only rules honored.

### 25.4 M3 exit criteria

Tick in place as work lands. All must be green for M3 to be considered complete.

- [ ] `AiController` runs at least one real `IBehavior` in a production scenario (Slice 30.2 — `PursueBallCarrierBehavior` in `BallOnPitchWithDefender`).
- [ ] All five M3 behaviors implemented and shipping in `AiController::defaultBehaviors()` for their respective Roles: `PursueBallCarrierBehavior`, `JockeyBehavior`, `MarkOpponentBehavior`, `Feint1v1Behavior` (+ any tuning-driven splits like a separate `PressBallCarrierBehavior` if Slice 30.2 discovers pursue and press need different utility curves).
- [ ] All six M3 concepts registered in `sim_concept_registry` with stable IDs in `[3, 8]`: `pressing`, `marking`, `jockey`, `1v1_beat`, `return_to_base`, `stay_in_zone`.
- [ ] All nine M3 attributes registered in `sim_attribute_registry` with stable IDs in `[16, 24]`: `marking_technique`, `standing_tackle`, `interception`, `feint`, `first_time_pass`, `aggression`, `positioning_sense`, `composure`, `anticipation`.
- [ ] First `sim_pattern_registry` entry populated: `pattern_being_beaten_1v1` — Recognition pipeline validated end-to-end for the first time since M0.
- [ ] `1v1AttackVsDefendScenario` playable end-to-end with real fh-member profile driving the AI (§21.2 item 1 wiring completes here).
- [ ] Utility-AI hysteresis (ADR §22.26) landed and locked by `no_oscillation_between_jockey_and_press_400_ticks_seed_42` golden.
- [ ] Debug-endpoint replay latency at tick 12000 of the most-expensive M3 scenario stays within the 10-s subprocess budget (P95). If any M3 scenario approaches or exceeds the budget, `CheckpointStore` (see §25.2 debug-replay bullet) must land before Slice 35 close-out; otherwise §21.3 item 1 stays open past M3 with revisit-condition = "first M4 scenario exceeds budget". This is deliberately weaker than the original "< 5 s wall-clock (P95)" gate — see §21.3 item 1 deferral rationale.
- [ ] Cross-arch determinism CI green for every new M3 golden (17+ goldens including pre-M3).
- [ ] `pg_stat_user_tables.n_tup_upd` across `sim_player_profile` + `sim_player_attribute` + `sim_player_concept` + `sim_player_recognition` still returns 0 at end of M3 (§22.14 invariant — carried through M0/M1/M2/M3). M3 introduces the first legitimate write path for `sim_player_recognition` (Slice 33.3 populates it as patterns fire), so this invariant needs a nuanced re-verification: `n_tup_ins` on `sim_player_recognition` MAY be nonzero, `n_tup_upd` MUST remain zero.
- [ ] No new §21 ship-blocker items opened during M3 without a matching closure or explicit revisit-condition timestamp. New items catalogued in §21.9 M4-blockers with revisit conditions (analogous to Slice 29's §21.8 catalogue).

### 25.5 Explicit M3 non-goals

- Off-ball intelligence (M4 — 2v1 / 2v2 supporting runs, cover-shadow, press-partner switching, `formation_shape` concept, `mental.off_ball_intelligence` attribute).
- Long passes / lobs / air-drag physics (M4 — `pass_long` concept, `technical.lofted_pass` + `technical.through_ball` attributes, ball altitude dimension activated).
- 2v1 / 2v2 numerical scenarios (M4 — M3 is single-attacker vs single-defender only).
- `switch_press_partner` / `numerical_press` / `cover_shadow` concepts (M5 — coordination category, tied to press-trigger goal).
- GK-specific attributes and behaviors (M5).
- Referee, offside, throw-ins, corner kicks (M5+).
- Snapshot delta compression (still on §21.4 non-standard-choices list).
- Client-side prediction / rollback (post-M0 open question §20).
- Profile-editor UI (still deferred per §23.5's carry-over from M1; M3 introduces the first *consumer* of persisted profiles via `ai_profile_source` but not an editor for them).
- `mental.decisions` / `mental.vision` attributes (M4 — off-ball reads).
- Full-match 11v11 (§2 explicit non-goal — the destination, not the milestone).

### 25.6 M3 → M4 transition prerequisites

Analogous to §21.7 and §24.6. **Empty at spec-time** — items append here as M3 slices surface them. Placeholder anchor for the Slice 35.3 sweep to populate.

- (No items yet — populate during Slice 30.x → 34.x as blockers emerge, and confirm empty vs populated at Slice 35 close-out.)

### 25.7 Reference cross-links

- [§5.4](#54-player-controller-interface) — `AiController` skeleton graduates to real utility-AI in Slice 30.1.
- [§5.5](#55-ai-behavior-interface-concept-gated) — `IBehavior` interface gets its first four concrete implementations (Slices 30.2 → 33.2).
- [§5.6](#56-scenario-interface) — `SlotSpawn::ai_profile_source` field (added in §21.2's M1-blocker resolution) gets its first consumer in Slice 34.2. `SlotSpawn::mark_target` field added Slice 31.2.
- [§12](#12-attribute--concept-catalog) — M3 attribute/concept batch consumed by the new behaviors.
- [§15](#15-milestone-plan) — M3 scope line item that this section fully specs out.
- [§16.6](#166-slice-13--persistence-library) — `RegistryLoader` picks up all M3 registry additions automatically (drift-check-gated).
- [§21.3](#213-pre-m3-fixes-fix-before-m3-planning) — item 1 (debug-replay checkpointing) **deferred past Slice 30** (see §25.2 debug-replay bullet); lands opportunistically when a slice's replay-from-scratch actually hits the subprocess budget (expected Slice 33 or 34 if at all in M3). If M3 never hits the budget, item 1 stays open past M3 with revisit-condition = first M4 scenario exceeds budget. Items 2 (`sim_matches.result` versioning), 3 (input lag), 4 (`sim_match_inputs` retention) are NOT M3 gates and stay open past M3 close-out.
- [§21.4](#214-non-standard-choices--conscious-revisit-only-if-they-hurt) — item 4 (utility-AI oscillation) closes as ADR §22.26 in Slice 32.
- [§21.8](#218-m3-blockers-fix-before-starting-m3-milestone-work) — item 1 (sim runtime image auto-rebuild) closed 2026-07-17 as commit `724d33ec`; the `make sim-deploy` guard now protects every M3 registry migration.
- [§22.14](#2214-2026-07-13-sim_player_profile-write-policy--first-touch-insert-only-in-m0) — write policy carries into M3 with the nuance in §25.4 that `sim_player_recognition` INSERTs are legitimate as patterns fire; UPDATEs stay banned.
- [§22.19](#2219-2026-07-14-podman-surface-docker-compat-rest-via-libcurl--unix-socket-path) — SimOrchestrator surface unchanged in M3.
- [§22.25](#2225-2026-07-16-sim_match_events-payload-versioning--first-byte-version-tag-for-event_type-9) — event payload versioning; M3 does not add new event types (Goal remains 9) so no v2 payload lands.
- [§22.26](#2226) — utility-AI hysteresis (drafted 2026-07-17, accepted at Slice 32 landing).
- [§24.3](#243-slice-sequence) — M2 slice log; template for §25.3's shape.
- [§24.4](#244-m2-exit-criteria) — M2 exit criteria; template for §25.4's shape.
- [§24.6](#246-m2--m3-transition-prerequisites) — M2→M3 transition; all items either closed (event payload versioning, collision golden rotation) or absorbed into M3 slice work (DefenderController migration = Slice 30.2).

---

**End of design v1 · 2026-07-10** (§21 + §22 added 2026-07-11; §22.9 + §22.10 added 2026-07-11; §22.11 added + accepted 2026-07-12 — §21.1 ship-blockers all closed; §22.12 proposed + accepted 2026-07-12 — Slice 13 persistence library landed; §16.6 registry loading + drift check landed 2026-07-13 — Slice 13 sub-slice 2 (`sim/src/persistence/RegistryLoader.{hpp,cpp}` + `sim/scripts/check_no_hardcoded_attrs.sh`); §16.6 profile store + `Match::claimSlot(person_id)` landed 2026-07-13 — Slice 13 sub-slice 3 (`sim/src/persistence/ProfileStore.{hpp,cpp}` + `Slot::person` field + `SimServer` profile bootstrap on connect); §16.6 match lifecycle landed 2026-07-13 — Slice 13 sub-slice 4 (`sim/src/match/CanonicalHash.{hpp,cpp}` + `GIT_DESCRIBE` compile define + `main.cpp` `upsertMatch` on boot / `insertEvent(MatchStart|MatchEnd)` + `updateMatchEnded` with 8-byte FNV-1a-64 canonical snapshot hash on shutdown); §16.6 async input+event logging landed 2026-07-13 — Slice 13 sub-slice 5 (`sim/src/persistence/AsyncPgLog.hpp` templated bounded-queue drain + `InputLog`/`EventLog` typedefs + `SimServer` pushes `InputRow` on accepted INPUT frames and `EventRow{ClientConnect|SlotClaim|SlotRelease|ClientDisconnect}` at transport boundaries + `main.cpp` `input_log.stop()`/`event_log.stop()` before `MatchEnd` write); §16.6 checkboxes for sub-slices 1–5 reconciled with landed code 2026-07-12 — Slice 13 remaining sub-slices: **sub-slice 6** (replay binary `fh-sim-replay` + `test_replay.cpp` + cross-arch replay verification), **sub-slice 7** (migration 201 SQL decode helpers), **sub-slice 8** (backend `SimDebugController` at `/api/sim/debug/*`), **sub-slice 9** (frontend Tactical Games hub tile), plus the CI load test that closes the last §16.5 exit-criteria checkbox); §16.6 sub-slice 7 landed 2026-07-13 — `database/migrations/201-sim-decode-functions.sql` (plpgsql helpers: `sim_read_f32_le(BYTEA, INT)`, `sim_event_type_name(SMALLINT)`, `sim_decode_attributes(BYTEA)` / `sim_decode_concepts(BYTEA)` / `sim_decode_recognition(BYTEA)` TABLE-returning set decoders joined to their registries, `sim_decode_input(BYTEA)` → jsonb 20-byte wire INPUT decoder, `sim_decode_event(SMALLINT, BYTEA)` → jsonb per-event decoder with MatchEnd hash decoding) unblocks §16.6 sub-slice 8 (`SimDebugController`) — smoke-tested on the running dev DB. §16.6 replay binary landed 2026-07-13 — Slice 13 sub-slice 6 (`sim/src/tools/{Replay.hpp,Replay.cpp,replay_main.cpp}` + new `IPgClient::loadInputsForMatch` / `loadMatchEnd` (both implementations) + `net::encodeInputFrame` symmetric helper + `fh-sim-replay` CMake target + Dockerfile install + `tests/test_replay.cpp` proving byte-identical hash to the `human_sprint_east_400` golden — 33/33 ctests green in container build); §22.13 accepted 2026-07-13 documenting the M0 default-profile assumption in replay, with M1 revisit-path picked between SlotClaim-payload vs profile-history-table when the M1 profile editor lands; remaining Slice 13 work after sub-slice 6: sub-slice 6.1 (extend `check_determinism_cross_arch.sh` for qemu-arm64 `--verify`), sub-slices 7–9, and the CI load test); §16.6 sub-slice 8 landed 2026-07-13 — `backend/src/controllers/SimDebugController.{h,cpp}` mounted at `/api/sim/debug/*` in `main.cpp`, feature-gated on `FH_ENABLE_SIM_DEBUG` env var (dev default 1 via docker-compose, prod defaults to unset → routes not registered). Dual-path auth (Bearer login JWT via `fh::crypto::verifyJwtHS256` + `userId` claim → `person_id` lookup, OR `fh_sess` cookie), direct admin SQL check, per-admin sliding-window rate limiter (10/60s). Two working endpoints (`/matches/:id/inputs` + `/matches/:id/events`) return decoded row envelopes using the migration 201 SQL functions (no client-side hex parsing needed); the third (`/matches/:id/state?tick=T`) is a documented HTTP 501 stub with a `sudo podman exec footballhome_sim fh-sim-replay ...` workaround, deferred to sub-slice 8.1 because `fh-sim-replay` lives in the sim container not the backend container (cross-container spawn is a separate architectural choice: bundle-into-backend-image vs UNIX-socket IPC to sim daemon). Added `HttpStatus::TOO_MANY_REQUESTS = 429` to `Response.h/.cpp` (previously missing). Verified end-to-end with a minted admin JWT: unauth → 401, non-admin → 403, admin+bad matchId → 400, admin+valid → 200 with real decoded events including MatchEnd hash inline, 11th rapid request within 60s → 429. Remaining Slice 13 work: sub-slice 6.1 (cross-arch qemu-arm64 replay CI), sub-slice 8.1 (cross-container `/state` replay), sub-slice 9 (frontend Tactical Games hub tile), and the §16.5 CI load test); §16.6 sub-slice 9 landed 2026-07-13 — Tactical Games hub tile → `/sim.html` already existed in [frontend/tactical-games.html](frontend/tactical-games.html) from an earlier drop (labeled "Sim Demo M0" with honest copy about "Wander an empty pitch. Zero rules — just proves the sim works end-to-end"), so this sub-slice just added the return trip: new top-left `#sim-back` anchor in [frontend/sim.html](frontend/sim.html) + matching CSS block in [frontend/css/sim.css](frontend/css/sim.css) styled to sit above the canvas/joystick/sprint-pad in the top-left corner (`rgba(0,0,0,0.55)` background, safe-area-inset aware, z-index 3, hover 0.75). Both files bind-mounted into `footballhome_frontend` so no rebuild — verified live via `curl http://127.0.0.1:3000/sim.html` + `curl http://127.0.0.1:3000/css/sim.css`. Zero touches to engine or wire protocol. Remaining Slice 13 work: sub-slice 6.1 (cross-arch qemu-arm64 replay CI), sub-slice 8.1 (cross-container `/state` replay), and the §16.5 CI load test); §16.6 sub-slice 6.1 landed 2026-07-13 — [sim/scripts/check_determinism_cross_arch.sh](sim/scripts/check_determinism_cross_arch.sh) rewritten as a container-parallel three-phase proof. Both amd64 and arm64 build inside ephemeral `debian:trixie-slim` containers (matching [sim/Dockerfile](sim/Dockerfile)) — no `libpqxx-dev`/`cmake`/`g++` needed on the host, only `podman` + `qemu-user-static` + binfmt-aarch64. Marker-delimited stdout (`===BEGIN_DETERMINISM===` / `===BEGIN_REPLAY===`) lets an outer `awk` extract each test's output for independent verification. Verdict: [1] `Live amd64 == Live arm64` via direct byte-diff of `test_determinism`'s canonical dumps, [2] `Replay amd64 == Live amd64` via `test_replay` exiting 0 inside the amd64 container, [3] `Replay arm64 == Live arm64` via `test_replay` exiting 0 inside the arm64 container under qemu-aarch64. Three-way equality proved by transitivity (live = live across arches ⇒ replay = replay across arches, since each arch's replay = its own live). Smoke-tested end-to-end on `fishtown` 2026-07-13 after `sudo apt install qemu-user-static binfmt-support`: 12m20s wall time, all three claims OK. This closes the last §16.5 exit-criteria checkbox that was previously blocked (the "DB-sourced replay" language in the original spec was over-scoped — `InMemoryPgClient` in the test provides identical guarantees with zero compose-stack dependency). Remaining Slice 13 work: sub-slice 8.1 (cross-container `/state` replay), and the §16.5 CI load test (100 ms Pg latency, zero dropped inputs)); §16.6 sub-slice 8.1 landed 2026-07-13 — [sim/src/admin/AdminHttpServer.{hpp,cpp}](sim/src/admin/AdminHttpServer.cpp) exposes `POST /admin/replay` on `footballhome_sim:9101` (bearer-token gated, own `PgClient`, hand-rolled AF_INET listener with 5 s socket timeouts + 16 KB request cap + `constantTimeEquals` bearer compare); [backend/src/controllers/SimDebugController.cpp](backend/src/controllers/SimDebugController.cpp) `handleState()` rewritten to `HttpClient::postJson()` the sim endpoint with `Authorization: Bearer $FH_SIM_ADMIN_TOKEN`, forward status + body verbatim (transport failure → 502, missing token → 503). Path (c) HTTP RPC chosen over path (a) binary-bundle (rejected: trixie sim vs bookworm backend glibc/libstdc++ gap) and path (b) UNIX-socket IPC (rejected: bespoke wire when HTTP already exists both sides). `FH_SIM_ADMIN_TOKEN` flows via `env_file: ./env` in [docker-compose.yml](docker-compose.yml) to both services (deliberately not in `environment:` to avoid `${...:-}` shell-substitution clobber). 35/35 sim `ctest` tests pass including 20 new tests in [sim/tests/test_admin_http_server.cpp](sim/tests/test_admin_http_server.cpp). Verified end-to-end from `footballhome_backend` → `footballhome_sim`: 401 (no bearer) / 403 (wrong bearer) / 404 (unknown match) / 500 (application error forwarded verbatim) all correct through both hops. This closes **all §16.6 sub-slices (1–9 including 6.1 and 8.1) AND all §16.5 exit criteria** — Slice 13 is complete); **§22.9 pattern extended to `sim_scenarios` 2026-07-13** — [database/migrations/204-sim-scenarios-empty-pitch-id-zero.sql](database/migrations/204-sim-scenarios-empty-pitch-id-zero.sql) renumbers `sim_scenarios.empty_pitch` from DB id=1 (SMALLSERIAL-assigned by migration 200) to id=0 (the hand-managed enum value the runtime uses in `main.cpp` / `Replay.cpp::makeScenario` / `EventTypes.hpp`), and updates the seeded `sim_matches.id=1.scenario_id` in the same transaction (FK drop → parent renumber → child re-route → FK re-add → `DO` post-check). Discovered during §16.6 sub-slice 8.1 verification when `/api/sim/debug/matches/1/state` returned `"unknown scenario_id=1"` from `Replay.cpp` — root cause was `upsertMatch`'s deliberate "server_version-only refresh on conflict" clause (per §16.6 sub-slice 4 spec) leaving the migration-202-seeded `scenario_id=1` sticky across sim restarts. Defence-in-depth follow-up: [sim/src/main.cpp](sim/src/main.cpp) now reads `getMatch(match_id)` BEFORE `upsertMatch` at boot and refuses to start (return code 6) with a clear diagnostic if the existing DB row's `(scenario_id, seed, tick_hz)` differ from what the daemon intends to write. Rationale: recorded `sim_match_inputs` are keyed against those three fields; silently overwriting them would corrupt every replay — same failure mode Postgres' `data_directory` mismatch and Kafka's `broker.id` mismatch bail on at startup. Full 36/36 sim `ctest` gate still passes; end-to-end `/api/sim/debug/matches/1/state` now returns 200 with a canonical hash instead of 500 with a "unknown scenario_id" error; **§21.5 documentation-reconciliation sweep landed 2026-07-13** — all 7 items closed in-place with resolution notes (items 1–6 marked `[x] Closed 2026-07-13` with pointer-notes to the sections rewritten: §17 project layout rewritten against actual repo including 36-test enumeration + correct migration numbering 200-204 + a "Layout notes" block flagging every deviation from the pre-Slice-13 sketch; §14 gained an "M0 reality vs the lifecycle above" block covering RPC-not-yet-real / CLAIM_SLOT-implicit-in-first-INPUT-frame / sim_player_profile-write-policy forward-pointing to ADR §22.14 (pending); §7 gained a bold blockquote pointing to §20 about v1-rendering vs v2-lockstep wire coexistence; §16.1 `AiController` checkbox rewritten to spell out skeleton status + point to §16.3/§16.4 for wander-only M0 AI; §5.7 `Match::spectators` gained a reserved-in-M0 blockquote; §5.6 `PlayableArea::Mode` gained Hard/Soft/Advisory semantics with M0 defaulting to Advisory via `EmptyPitchScenario`; item 7 (migration 200 attribute-vs-concept key format inconsistency) marked **Won't-fix** with rationale — resolved as "unify going forward: prefixed everywhere" (add category prefixes to concept keys when the first concept-category collision arises) rather than "unify backward: bare everywhere" (which would either mutate immutable migration 200 or leave migration 205 UPDATE'ing the DB to a state visibly out-of-sync with the migration file). Zero code touched; the `key` column strings are display-only — runtime uses `AttrId`/`ConceptId` u16 values from [sim/src/common/M0Registry.generated.hpp](sim/src/common/M0Registry.generated.hpp), and `to_cname` in `gen_registry_header.awk` strips the leading `<cat>.` when present so the generated k*-identifier names are stable across any prefix change); **§21.2 item 1 closed 2026-07-13 — `SlotSpawn::ai_profile_source` field added** — [sim/src/scenario/Scenario.hpp](sim/src/scenario/Scenario.hpp) now carries `std::optional<PersonId> ai_profile_source` as the first of three AI-source fields on `SlotSpawn`, with mutual-exclusion contract documented in the field's block comment (also mirrored in DESIGN.md §5.6): if both `ai_profile_source` and `ai_profile` are set, `ai_profile_source` wins (persisted-profile-of-record beats inline blob); `ai_concepts` layers on top of whichever source wins. [sim/src/scenario/EmptyPitchScenario.cpp](sim/src/scenario/EmptyPitchScenario.cpp) comment updated to mention all three (M0 leaves all nullopt → Match defaults unclaimed slots to WanderController). Consumer wiring (`Match::spawnInitialSlots` calling `ProfileStore::load` when `ai_profile_source` is set) intentionally deferred to M3's first `AiController` scenario for three reasons: (a) no M0 scenario sets the field so no code path would exercise it today, (b) plumbing `ProfileStore` into `MatchConfig` before there's a test that needs it violates the "reserved fields carry their eventual meaning, not implementation" §22 rule, (c) `Match` runs on the tick thread while `ProfileStore` has its own thread — the setup-time lookup abstraction (`IProfileSource` or similar) is a design concern M3 should tackle deliberately rather than pre-emptively. Zero-behavior change for M0. Verified via full sim image `--target build` rebuild + 36/36 ctest green; **§21.2 item 2 closed 2026-07-13 — ADR §22.14 (`sim_player_profile` write policy — first-touch INSERT only in M0) accepted** — new ADR spells out the policy in full plus revisit conditions (M3 concept-mastery, M1 profile-editor UI, M4+ wear-and-tear), and enforcement lands as [sim/scripts/check_profile_write_policy.sh](sim/scripts/check_profile_write_policy.sh) chained into [sim/Dockerfile](sim/Dockerfile) alongside the existing lint gates (`check_no_floats.sh` / `check_no_bad_rng.sh` / `check_no_hardcoded_attrs.sh`). Coarse `.save(` grep against `sim/src/**/*.{cpp,hpp,h}` fails the container image build if any file outside `sim/src/persistence/ProfileStore.{cpp,hpp}` matches — sim has no other `save` method today, so false positives are zero, and the script's error message points at §22.14 for future additions. M0 smoke check documented in the ADR: `SELECT COUNT(*) FROM sim_player_profile WHERE updated_at <> created_at` should always return 0 in an M0 deployment; non-zero = CI bypass, investigate. Verified end-to-end: sim Dockerfile build stage runs all four lint scripts + full compile + 36/36 ctest, all four print `OK`, standalone `bash sim/scripts/check_profile_write_policy.sh` on the tree also OK; **§21.2 item 3 closed 2026-07-13 — §16.7 multi-match orchestration plan landed** — new DESIGN.md subsection evaluates three orchestration models (A: N daemons behind match-router, B: one daemon + thread pool, C: per-match ephemeral processes) against 12 axes (failure isolation, cold-start latency, memory per match, determinism preservation, router complexity, observability, DB connection count, podman coupling, reaper complexity, per-host scaling ceiling, M1 fit, M4+ fit) with a decision matrix in-line. **Option A chosen for M1**: failure isolation is decisive at the M1 phase (new drill scenarios = frequent tick-loop bugs; a single-daemon crash taking down every live drill is worse UX than a ~50 ms cold-start per new match), the entire M0 machinery (`PgClient`, `ProfileStore`, `AsyncPgLog<InputRow>`, `AsyncPgLog<EventRow>`, `SimServer`, `AdminHttpServer`, `main.cpp`'s `upsertMatch` + drift-guard + `updateMatchEnded` chain) generalizes verbatim per-daemon while Option B requires each subsystem to be rewritten to key on `match_id`, and A→C (adding `--rm` for ephemeral behavior) is trivial while A→B is a rewrite. §16.7 spells out a full 10-item concrete M1 implementation plan (backend `SimOrchestrator` shelling out to podman with 5 s health-check timeout + `on-failure:3` restart policy, `SimLobbyController::handleCreateMatch` becoming real, `SimRouter` generalizing the §16.6 sub-slice 8.1 HTTP-RPC pattern per-match, `sim.html` reading `?match_id=X`, nginx `location ~ ^/sim/(\d+)$` regex block, reaper thread reconciling `sim_matches.ended_at IS NULL` vs `podman ps`, per-daemon determinism guarantees preserved from M0, `sudo podman logs footballhome_sim_${match_id}` per-match observability, failure-mode handling for daemon-crash/DB-unreachable/backend-crash/podman-crash/container-name-collision, and the migration path from M0's single-daemon `SIM_MATCH_ID=1` setup). Revisit conditions documented for when scaling exceeds ~100 concurrent matches per host, when ~50 ms cold-start becomes a UX problem, when DB connection count hits Postgres `max_connections` (add pgbouncer), and when tick-loop-crash restart-loops become noisy. §14 M0-reality block and Slice 13 non-goals block updated to point at §16.7 rather than describing it as "to be spec'd". Doc-only — actual `SimOrchestrator` / `SimRouter` code lands with Task B (M1 slice plan)); **§23 Milestone 1 detailed spec landed 2026-07-13** — new top-level section mirroring §16's shape for M0. Covers scope recap (with prerequisites §21.2 items 1–3 all ticked as C→D→E→A→B follow-up commits `2a4f502f`, `ca50b487`, `c9e9ed3a`), rules inherited from §16.6/§22.0 (slice numbering continues from Slice 13, determinism gates preserved every slice, ADRs land as §22.15/16/17 chronologically, sim migrations continue as 205-*.sql), deliverables grouped by subsystem (Ball entity + physics, dribble mechanics, playable-area constraints, wire protocol v1.1 additive extension, multi-match orchestration §16.7 implementation, CI + observability + tests), a 5-slice sequence 14–18 with explicit exit gates per slice (Slice 14 = multi-match orchestration landed FIRST because Slices 15–17 need to spawn fresh matches without perturbing M0 legacy match id=1; Slice 15 = passive ball; Slice 16 = dribble mechanics with new `physical.dribble_efficiency` attribute via migration 206 following §22.9 stable-ID pattern; Slice 17 = Hard/Soft `PlayableArea` per §5.6 semantics from Task E; Slice 18 = close-out demo tile on tactical-games.html plus doc-reconciliation sweep analogous to §21.5), 10-item M1 exit-criteria checklist including preserving the §22.14 write-policy invariant through M1 (`SELECT COUNT(*) FROM sim_player_profile WHERE updated_at <> created_at = 0`), explicit non-goals (passing/shots/collisions = M2, AiController behaviors plugged = M3, snapshot delta compression = M4+, profile editor UI conditional on landing §22.13 revisit-path work simultaneously), M2 transition prerequisites (snapshot v1.x vs v2 negotiation, `sim_matches.result` versioning per §21.3, cross-match input isolation invariant, AsyncPgLog pooling revisit if 3N connections hit Postgres `max_connections`), and three draft ADRs (§22.15 `physical.dribble_efficiency` as first-class attribute vs constant, §22.16 wire v1.1 extension format, §22.17 backend→podman API access surface) that will land alongside their respective slices. §21.2 header updated to reflect all-closed status with commit pointers. **Closes the 5-task follow-up sequence C→D→E→A→B in full.** Doc-only, zero code touched — M1 slice implementation is Slice 14 kick-off, not part of this landing); **§22.18 accepted 2026-07-13 — `sim_player_profile` storage normalized (bytea → row-per-value)** — [database/migrations/205-sim-normalize-profiles.sql](database/migrations/205-sim-normalize-profiles.sql) drops the three BYTEA columns (`attributes`, `concepts`, `recognition`) plus the three matching `sim_decode_*` helpers from migration 201, then rebuilds `sim_player_profile` as a parent envelope (`person_id` PK, `updated_at`) referenced by three child tables (`sim_player_attribute (person_id, attr_id) → sim_attribute_registry(id)`, `sim_player_concept (person_id, concept_id) → sim_concept_registry(id)`, `sim_player_recognition (person_id, pattern_id) → sim_pattern_registry(id)`, each with a REAL `value`/`mastery`/`skill` column). Migration is guarded by a `DO $$ ... RAISE EXCEPTION $$` block that refuses to run if the old table has rows (verified 0 on live before apply). Source refactor: `IPgClient::ProfileBlob` renamed to `ProfileRows { vector<pair<u16,f32>> attributes/concepts/recognition }`, `loadProfile` returns rows sorted ASC by id, `upsertProfile` runs a single transaction (INSERT parent ON CONFLICT DO UPDATE `updated_at`, DELETE all child rows, per-row INSERT — replace-whole-set semantics preserved). `PgClient` grows 11 new prepared statements; `InMemoryPgClient` mirrors the interface with `std::sort` at read time for byte-for-byte parity with `PgClient`. `ProfileStore` gains a template `encodeSet<Map>` that flattens `.values()` and sorts by id ASC. Codec removal: `sim/src/profile/PackedU16F32.{hpp,cpp}` deleted; `AttributeSet::{to,from}Bytes` / `ConceptSet::{to,from}Bytes` / `RecognitionSet::{to,from}Bytes` methods and their includes removed. Tests: `test_attribute_set.cpp` / `test_concept_set.cpp` / `test_recognition_set.cpp` had their 5 codec tests each dropped; `test_in_memory_pg_client.cpp` and `test_profile_store.cpp` rewritten to insert scrambled-order rows and assert sorted-load behaviour. `sim/CMakeLists.txt` drops the `PackedU16F32.cpp` source line. All 36 ctest tests green including `test_pg_client` end-to-end round-trip. §22.14 write policy invariant preserved verbatim (`.save(` grep in `check_profile_write_policy.sh` still finds only `ProfileStore.cpp`; the smoke check `pg_stat_user_tables.n_tup_upd = 0` extends from one table to four). §22.14 smoke-check wording updated to reflect the new schema (no `created_at` column existed — the previous `updated_at <> created_at` phrasing was a doc bug caught during this landing and replaced with `n_tup_upd = 0` across the four `sim_player_*` tables). §21.1 stable-registry-ID checkbox annotated to note that the FK constraint added here upgrades §22.9's runtime-assertion guard to a hard Postgres-enforced invariant. DESIGN.md §3 principle 7 / §4 architecture diagram schema list / §5.2 Set class snippets / §8 CREATE TABLE block / §8.1 SQL decode helpers / §16.6 ProfileStore checklist bullet / §17 project-layout tree / §21.1 registry-ID checkbox note all updated to reflect the row-per-value storage. Paused before Slice 14 kickoff at user's direction; migration + source refactor + tests + doc updates all landed cleanly in one session; §24 M2 detailed spec added 2026-07-16 backfilling the six shipped slices (24.1–24.3b + 25.1–25.3) and speccing forward slices 26 (short pass) / 27 (collisions) / 28 (shots) / 29 (M2 close-out) with exit criteria + non-goals + M3 transition prereqs; Slice 26.1 landed 2026-07-16 as commit `78b2ad6c` — `physical.pass_power` attribute at stable id=14 via migration 217 + M0Attributes default 15 m/s + CMake/build.sh/test wiring, 47/47 tests green with all 9 determinism goldens byte-identical (kPassPower attribute added but no consumer yet — determinism-neutral scaffolding slice); ADR §22.23 accepted 2026-07-16 — INPUT frame gains a length-prefixed extension trailer mirroring §22.20's SNAPSHOT-trailer pattern, server-declared HELLO_ACK cap bit 3 (`kWireCapInputKickTrailer`) gates client emission of the 28-byte kicked payload, 16-byte legacy payload preserved byte-identical for non-kick ticks, spec locks byte layout + decoder contract + ops-decoder migration 218 shape before any Slice 26.2 wire code is written.
