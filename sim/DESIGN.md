# footballhome sim — design doc

**Status:** draft v1 · 2026-07-10
**Owner:** footballhome
**Scope:** authoritative multi-player tactical football simulator, server-side C++, browser client, binary wire, member-only auth.

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
7. **Attributes are strings-keyed and grow on demand.** Adding an attribute is a registry entry + code that reads it. Zero DB migration.
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
                             │  • sim_player_profile (bytea)    │
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

Attributes are stored as `float` in the DB (for human readability + registry stability), but converted to `Fixed64` on load and kept as `Fixed64` in-process. The sim loop only ever sees `Fixed64` values.

```cpp
class AttributeRegistry;      // singleton, loaded from sim_attribute_registry
class ConceptRegistry;        // singleton, loaded from sim_concept_registry

class AttributeSet {
    // packed { u16 id → Fixed64 value }
    std::unordered_map<AttrId, Fixed64> values;
public:
    Fixed64 get(AttrId, Fixed64 default_value) const;
    Fixed64 get(const std::string& key, Fixed64 default_value) const;   // registry lookup
    void    set(AttrId, Fixed64);
    bool    has(AttrId) const;
    std::vector<uint8_t> toBytes() const;                    // packed (u16 id, i64 raw)*
    static AttributeSet fromBytes(std::span<const uint8_t>);
    static AttributeSet fromFloatMap(const std::unordered_map<AttrId, float>&);  // load-time only
};

class ConceptSet {
    std::unordered_map<ConceptId, Fixed64> mastery;   // 0.0–1.0 in Fixed64
public:
    Fixed64 level(ConceptId) const;
    Fixed64 level(const std::string& key) const;
    bool    has(ConceptId, Fixed64 min_mastery = Fixed64::fromInt(0)) const;
    void    plug(ConceptId, Fixed64 mastery);
    void    unplug(ConceptId);
    std::vector<uint8_t> toBytes() const;
    static ConceptSet fromBytes(std::span<const uint8_t>);
};

class PatternRegistry;             // singleton, loaded from sim_pattern_registry
using PatternId = uint16_t;

class RecognitionSet {
    // Per-pattern probability the player correctly labels a pattern per scan.
    // Empty in M0 (no patterns registered until M4). Kept as a first-class field
    // from day 1 so bytea layout, wire format, and behavior interfaces are stable.
    std::unordered_map<PatternId, Fixed64> patterns;
public:
    Fixed64 skill(PatternId) const;                   // 0.0–1.0 in Fixed64
    Fixed64 skill(const std::string& key) const;      // registry lookup
    void    set(PatternId, Fixed64);
    bool    has(PatternId) const;
    std::vector<uint8_t> toBytes() const;
    static RecognitionSet fromBytes(std::span<const uint8_t>);
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
    // if this slot is AI, which concepts are plugged?
    std::optional<ConceptSet> ai_concepts;
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

### 5.7 Match orchestrator

```cpp
struct Slot {
    SlotId slot_id;
    std::unique_ptr<IPlayerController> controller;
    EntityId entity;
    PlayerProfile profile;
    std::optional<ClientId> owner;   // set if human, empty if AI
    Role role;
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
| 0x02 | HELLO_ACK | server → client | u64 match_id, u16 your_slot_or_0, u32 tick_hz |
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
[Entity entities[num_entities]]     // 30 bytes each
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

**Milestone 0 snapshot size (payload)**: 10 (header) + 12 slots × 30 = **370 bytes**. Add the 4-byte frame header (§7) = **374 bytes on the wire**. At 20 Hz ≈ 7.30 KB/s per client.

### 7.3 INPUT payload

```
[u32 client_tick]
[f32 desired_dir_x]     // normalized; zero if no movement
[f32 desired_dir_y]
[u8  flags]             // bit 0 = wants_sprint, bit 1 = wants_walk
[u8  reserved[3]]
```

**16 bytes per input.** Sent at ~30 Hz or on change.

### 7.4 WebSocket handshake

- Path: `/sim` (proxied through nginx to `footballhome_sim:9100`)
- Subprotocol header: `Sec-WebSocket-Protocol: fh-sim.v1.bearer.<JWT>`
- Server validates JWT (shared secret with `footballhome_backend`), attaches `JwtClaims` to `ClientId`.

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

-- Player profiles (binary-packed attributes + concepts + recognition)
CREATE TABLE sim_player_profile (
    person_id    BIGINT PRIMARY KEY REFERENCES persons(id),
    attributes   BYTEA NOT NULL,                                   -- packed (u16 attr_id, f32 val)*
    concepts     BYTEA NOT NULL,                                   -- packed (u16 concept_id, f32 mastery)*
    recognition  BYTEA NOT NULL DEFAULT '\x0000'::bytea,           -- packed (u16 pattern_id, f32 skill)* — empty until M4
    updated_at   TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

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

```sql
CREATE OR REPLACE FUNCTION sim_decode_attributes(payload BYTEA)
RETURNS TABLE(key TEXT, value REAL) AS $$
DECLARE
    n INT;
    i INT;
    attr_id INT;
    val REAL;
BEGIN
    n := (get_byte(payload, 0) | (get_byte(payload, 1) << 8));
    FOR i IN 0..(n-1) LOOP
        attr_id := (get_byte(payload, 2 + i*6) | (get_byte(payload, 3 + i*6) << 8));
        val := ...;   -- decode f32 from bytes 4..7 of the record
        RETURN QUERY
          SELECT r.key, val FROM sim_attribute_registry r WHERE r.id = attr_id;
    END LOOP;
END;
$$ LANGUAGE plpgsql IMMUTABLE;
```

Similar `sim_decode_concepts()`. Ops can `SELECT * FROM sim_decode_attributes(p.attributes) WHERE ...` for ad-hoc inspection.

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
   Sim server accepts, sends HELLO_ACK { match_id, your_slot_or_0, tick_hz }.

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

## 15. Milestone plan

> **This document is the source of truth for both design AND progress.** Each
> milestone below has a Status column; §16.1 breaks Milestone 0 into checkable
> deliverables. Tick the boxes in place as work lands. Do not create parallel
> progress files.

| Milestone | Adds | Est. weeks | Cumulative | Status |
|---|---|---:|---:|---|
| **M0** | `Fixed64` + `FixedMath` + trig LUTs + cross-platform determinism CI. Move a player dot on empty pitch. Full infra (auth, wire, physics stub, WanderController, Canvas2DRenderer, replay logging). | 5–7 | 5–7 | in progress (see §16.1) |
| **M1** | Ball entity + dribble physics + one player can move it. Playable-area constraints. | 3–4 | 8–11 | not started |
| **M2** | Multi-player interactions: collisions, first-touch, short passes, shots. | 3–4 | 11–15 | not started |
| **M3** | 1v1 attack↔defend scenario. First real `AiController` (chase, jockey, mark, feint). | 4–5 | 15–20 | not started |
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
- [x] `sim/src/controller/{IPlayerController.hpp, HumanController.{hpp,cpp}, WanderController.{hpp,cpp}, AiController.{hpp,cpp}}` (`AiController` is skeleton only until M3).
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
- [ ] `database/migrations/201-sim-decode-functions.sql` — `sim_decode_attributes()` / `sim_decode_concepts()` plpgsql helpers (§8.1). Deferred; ops nice-to-have, not needed by the sim binary.

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
- [ ] `sim/src/persistence/IPgClient.hpp` — pure-virtual interface. Read methods (`loadRegistry`, `loadProfile`, `getMatch`) + write methods (`insertMatch`, `updateMatchEnded`, `insertInput`, `insertEvent`, `upsertProfile`). Interface-first so tests can inject an in-memory fake and gameplay code never depends on libpqxx directly.
- [ ] `sim/src/persistence/PgClient.{hpp,cpp}` — concrete impl using `libpqxx` (matches backend's Pg stack). Prepared statements for all hot paths. Single connection is fine for M0; connection pool later. Env: `SIM_DB_HOST`, `SIM_DB_PORT`, `SIM_DB_NAME`, `SIM_DB_USER`, `SIM_DB_PASSWORD`. Startup fails loud if unreachable — no fallback.
- [ ] `sim/src/persistence/InMemoryPgClient.{hpp,cpp}` — test double implementing the same interface with `std::unordered_map` backing. Used by unit tests + `test_determinism` extensions.
- [ ] `sim/src/persistence/EventTypes.hpp` — stable enum values for `sim_match_events.event_type`. Append-only. Initial values: `1=match_start, 2=match_end, 3=client_connect, 4=client_disconnect, 5=slot_claim, 6=slot_release, 7=scenario_success, 8=scenario_reset`. Documented in place.
- [ ] `sim/Dockerfile` build stage adds `libpqxx-dev`; runtime stage adds `libpqxx-6.4` (or version matching debian:trixie).
- [ ] `sim/CMakeLists.txt` adds `pkg_check_modules(PQXX REQUIRED libpqxx)` and a new `sim_persistence` library target linked by `sim_server`.

**Registry loading at startup**
- [ ] `AttributeRegistry::loadFromDb(IPgClient&)`, `ConceptRegistry::loadFromDb(IPgClient&)`, `PatternRegistry::loadFromDb(IPgClient&)` — replaces any in-memory seeding path. `SimServer::run()` calls these before any `Match` is constructed.
- [ ] Startup asserts that IDs of every key in `sim/src/common/M0Attributes.hpp` match the DB rows loaded from migration `200-sim-registries.sql`. Any drift fails startup with a clear error naming the mismatched key. Prevents silent renumbering ever corrupting bytea profiles.
- [ ] Remove all hard-coded default-attribute paths from `SimServer` / `Match` / `Slot`. Every attribute value used in gameplay now comes from `PlayerProfile` loaded from DB. Registry defaults (`sim_attribute_registry.weight`) are used ONLY as fallback for materializing a first-time profile in `ProfileStore::loadOrCreate`.
- [ ] CI grep extended (`sim/scripts/check_no_hardcoded_attrs.sh`): no `Fixed64::fromFloat` call may appear outside `sim/src/persistence/` and `sim/src/registry/` — enforces "attributes always come from DB."

**Player profile read/write**
- [ ] `sim/src/persistence/ProfileStore.{hpp,cpp}` — thin wrapper over `IPgClient` that reads/writes `sim_player_profile` bytea via the existing `AttributeSet::toBytes/fromBytes`, `ConceptSet::toBytes/fromBytes`, `RecognitionSet::toBytes/fromBytes` codecs.
- [ ] `ProfileStore::loadOrCreate(person_id)`: if row exists → decode + return; else materialize a default `PlayerProfile` from registry defaults, persist, return. First-touch is idempotent.
- [ ] `Match::claimSlot(SlotId, ClientId, person_id)` calls `ProfileStore::loadOrCreate` and stores the resulting profile in the slot. Existing overload without `person_id` deprecated; tests migrated.
- [ ] Test: `test_profile_store.cpp` — round-trips a profile through DB (`InMemoryPgClient`), verifies byte-exact recovery, verifies default materialization for unknown `person_id`.

**Match lifecycle in DB**
- [ ] `SimServer` on startup: `pg.upsertMatch(SIM_MATCH_ID, scenario_id, seed, tick_hz, server_version)` — idempotent `INSERT ... ON CONFLICT (id) DO UPDATE` so a restart of a running match preserves its `sim_match_inputs`/`sim_match_events` history but refreshes `server_version`. Migration 202's seeded id=1 row remains the single M0 match.
- [ ] `server_version` value derived at build time from git describe (`GIT_DESCRIBE` compiler define, already used in `main.cpp` for HELLO_ACK) — no runtime string manipulation.
- [ ] On SIGTERM / SIGINT: sim writes `event_type=match_end` with the canonical snapshot hash (see replay section) into `sim_match_events`, then `UPDATE sim_matches SET ended_at = NOW(), result = <canonical hash bytea> WHERE id = ?`. Lobby's `WHERE ended_at IS NULL` predicate then correctly hides the match.
- [ ] Frontend lobby (`SimLobbyController::handleListMatches`) unchanged; verified with a manual shutdown.

**Match input logging (deterministic replay source)**
- [ ] `sim/src/persistence/InputLog.{hpp,cpp}` — bounded MPSC queue (256 slots) drained by a dedicated background thread that calls `pg.insertInputBatch(...)`. Gameplay thread never blocks on Postgres; when queue is full it logs a warning + increments a dropped-input counter (visible via debug endpoint). Dropped inputs are a violation of the exit criteria — CI load test asserts zero drops under simulated 100 ms Pg latency for a 10-min match.
- [ ] `Match::applyInput(ClientId, Intent, TickNum)` records the input to `InputLog` after acceptance. Wire-format `InputFrame` bytes reused as `sim_match_inputs.payload` — one codec, one source of truth for what a "recorded input" looks like.
- [ ] Batch flush cadence: every tick boundary (background thread wakes on condvar, drains all queued entries in one transaction). Latency to durability ≤50 ms typical, never blocks gameplay.
- [ ] Event log: same shape as input log — bounded MPSC + background drain — for `client_connect`, `client_disconnect`, `slot_claim`, `slot_release`, `scenario_success`, `scenario_reset` (M0 emits the first four; scenario events wired in for M1).
- [ ] Tests: `test_input_log.cpp` verifies queue semantics, drop counter, ordering (inputs for the same `(match, tick, slot)` collapse to the last submitted per §14 semantics — first-write-wins with idempotent replacement is out-of-scope; simple last-write-wins is fine for M0).

**Replay binary**
- [ ] `sim/src/tools/replay.cpp` — new CMake target `fh-sim-replay`. Links `sim_match`, `sim_data`, `sim_gameplay`, `sim_persistence`.
- [ ] CLI: `fh-sim-replay --match-id N [--up-to-tick T] [--emit-hex] [--emit-hash]`. Reads `sim_matches` for scenario + seed; constructs `Match`; reads `sim_match_inputs` ordered by `(tick_num, slot_id)`; for each tick loop, applies queued inputs then calls `match.tick()`; emits canonical hex (all Fixed64 raw values of all entity states) and/or FNV-1a-64 hash of same.
- [ ] On match_end: sim daemon emits the canonical snapshot hash into `sim_match_events` (event_type=2, payload=8-byte hash big-endian). Replay verifies by computing its own hash and asserting equality; exit code 1 on divergence.
- [ ] `sim/Dockerfile` copies `fh-sim-replay` into the runtime image at `/usr/local/bin/`. Also present in build stage for `ctest`.
- [ ] `sim/tests/test_replay.cpp` (new integration test) — scripts a 400-tick match via `InMemoryPgClient`, then runs `Match` construction + replay in-process, asserts final snapshot byte-identical to the live match.
- [ ] `sim/scripts/check_determinism_cross_arch.sh` extended: after native amd64 run, replay the same match from the recorded input log; assert same hash. Then run same replay under arm64 via qemu; assert same hash again. Three-way byte equality (live amd64 = replay amd64 = replay arm64).

**Migration 201 — SQL decode helpers**
- [ ] `database/migrations/201-sim-decode-functions.sql` — the deferred function pack from §8.1. Adds `sim_decode_attributes(BYTEA)`, `sim_decode_concepts(BYTEA)`, `sim_decode_recognition(BYTEA)`, `sim_decode_input(BYTEA)`, `sim_decode_event(BYTEA)`. All `CREATE OR REPLACE FUNCTION ... IMMUTABLE`. Idempotent; safe to re-apply. Used by the debug endpoint below and by ops for ad-hoc queries.

**Backend debug endpoint**
- [ ] `backend/src/controllers/SimDebugController.{h,cpp}` mounted at `/api/sim/debug` in `main.cpp`. Admin-only (`SessionService::requireAdmin`). Not exposed unless `FH_ENABLE_SIM_DEBUG=1` in env, so prod stays clean.
- [ ] `GET /api/sim/debug/matches/:id/inputs?from_tick=N&to_tick=M` — returns JSON array using `sim_decode_input()`. Bounded to 1000 rows per page.
- [ ] `GET /api/sim/debug/matches/:id/events` — returns JSON array using `sim_decode_event()`. Bounded to 1000 rows per page.
- [ ] `GET /api/sim/debug/matches/:id/state?tick=T` — spawns `fh-sim-replay --match-id :id --up-to-tick T --emit-hex --emit-json-snapshot` in a sandboxed subprocess (10-second timeout, unprivileged uid, no network); returns the JSON snapshot. This is the only path where the sim emits JSON — allowed by §19 because it's a debug endpoint, not gameplay.
- [ ] Rate limit: 10 req/min per admin. Prevents accidental heavy replay load.

**Frontend hookup (Tactical Games hub → sim)**
- [ ] `frontend/js/screens/tactical-games.js` (or wherever the hub lives — locate first) — add a tile "Live pitch (M0 dot demo)" that opens `/sim.html`. Copy stays honest about what it is — this is not yet a training exercise.
- [ ] `frontend/sim.html` link back to the hub added in top-left HUD so a user isn't stranded.
- [ ] No engine or wire-protocol changes.

**§16.5 exit criteria additions**
- [ ] Sim daemon refuses to start if `sim_attribute_registry` or `sim_concept_registry` is empty. No hard-coded fallback attribute values exist in `sim/src/{physics,controller,behavior,scenario,match}/` (CI grep enforces).
- [ ] Every match played end-to-end has: (a) a `sim_matches` row with `ended_at` set, (b) `sim_match_inputs` rows for every accepted input, (c) `sim_match_events` rows for `match_start`, all `client_connect`/`disconnect`/`slot_claim`/`slot_release`, and `match_end` with canonical snapshot hash, (d) `sim_matches.result` populated with the same hash.
- [ ] `fh-sim-replay --match-id N` produces byte-identical snapshot hash to the recorded `match_end` hash for every `N`.
- [ ] Cross-arch determinism CI green with DB-sourced replay: live amd64 = replay amd64 = replay arm64 (via qemu).
- [ ] First-time slot join for a new `person_id` materializes a default `sim_player_profile` row from registry defaults; subsequent joins read the existing row byte-for-byte.
- [ ] Admin `GET /api/sim/debug/matches/:id/state?tick=T` returns the deterministic snapshot at tick T for any recorded match.
- [ ] Input write queue never blocks the tick loop under simulated 100 ms Postgres latency for a 10-minute match (load test enforces zero dropped inputs).

**Slice 13 explicit non-goals**
- Multi-match orchestration (`SimServer::createMatch` beyond the seeded id=1) — deferred; single-daemon single-match convention stays for M0.
- Profile-editing UI for coaches — deferred to M1+ when there's actual attribute values worth editing.
- Names on pieces from real fh members — plumbing lands here (`sim_player_profile` keyed by `person_id`), UI defers to M1+.
- Replay scrubbing UI — deferred; API only.
- Match visibility beyond `public` — `sim_matches.visibility` column exists but stays hard-coded to 0. Wire-up when clubs/private matches matter.
- Snapshot compression (delta encoding, keyframes) — deferred; M0 stores full canonical hex only at match_end for verification, not per-tick.

## 17. Project layout (scaffolding in progress; per-file status tracked in §16.1)

```
footballhome/
├─ sim/
│   ├─ DESIGN.md                 (this file)
│   ├─ WIRE.md                   (binary format reference)
│   ├─ CMakeLists.txt
│   ├─ Dockerfile
│   ├─ src/
│   │   ├─ main.cpp
│   │   ├─ math/
│   │   │   ├─ Fixed64.{hpp,cpp}
│   │   │   ├─ FixedMath.{hpp,cpp}       (fx_sqrt, fx_sin, fx_cos, fx_atan2)
│   │   │   ├─ TrigLUT.{hpp,cpp}         (sin/cos/atan2 lookup tables)
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
│   │   │   └─ PlayerProfile.{hpp,cpp}
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
│   │   │   └─ AiController.{hpp,cpp}     (skeleton, empty until M3)
│   │   ├─ behavior/
│   │   │   └─ IBehavior.hpp
│   │   ├─ scenario/
│   │   │   ├─ Scenario.hpp
│   │   │   └─ EmptyPitchScenario.{hpp,cpp}
│   │   ├─ match/
│   │   │   ├─ Slot.hpp
│   │   │   ├─ MatchClock.{hpp,cpp}
│   │   │   ├─ Match.{hpp,cpp}
│   │   │   └─ Snapshot.hpp
│   │   ├─ net/
│   │   │   ├─ INetworkTransport.hpp
│   │   │   ├─ WebSocketTransport.{hpp,cpp}
│   │   │   ├─ ISnapshotSerializer.hpp
│   │   │   └─ BinaryV1Serializer.{hpp,cpp}
│   │   ├─ auth/
│   │   │   └─ JwtVerifier.{hpp,cpp}
│   │   ├─ persistence/
│   │   │   └─ PgClient.{hpp,cpp}
│   │   └─ server/
│   │       └─ SimServer.{hpp,cpp}
│   └─ tests/
│       ├─ test_fixed64.cpp
│       ├─ test_fixed_math.cpp
│       ├─ test_binary_serializer.cpp
│       ├─ test_recognition_passthrough.cpp
│       ├─ test_wander_controller.cpp
│       ├─ test_determinism.cpp
│       ├─ test_determinism_cross_platform.cpp    (runs under qemu-aarch64)
│       └─ test_stamina.cpp
├─ database/migrations/
│   ├─ 200-sim-registries.sql
│   ├─ 201-sim-matches.sql
│   ├─ 202-sim-inputs-events.sql
│   ├─ 203-sim-player-profile.sql
│   └─ 204-sim-decode-functions.sql
├─ backend/  (existing — adds /api/sim/* routes)
│   └─ src/controllers/SimLobbyController.{hpp,cpp}
└─ frontend/
    ├─ sim.html
    └─ js/sim/
        ├─ wire.js
        ├─ transport.js
        ├─ renderer.js
        ├─ input.js
        ├─ interpolator.js
        ├─ client.js
        └─ lobby.js
```

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

- [x] **Registry IDs must be stable across environments** — closed 2026-07-11; see §22.9. `sim_attribute_registry.id SMALLSERIAL` today lets Postgres assign IDs in insertion order — a dev DB reset can produce different IDs than prod, and every `sim_player_profile.attributes` bytea encodes those IDs directly. §16.6 tries to catch drift with a startup assertion, but that's a runtime guard on a schema-level bug. **Fix**: migration 200 (and all future registry migrations) must `INSERT INTO sim_attribute_registry (id, key, ...) VALUES (1, 'physical.max_walk_speed', ...), (2, ...)` explicitly, then `SELECT setval('sim_attribute_registry_id_seq', (SELECT MAX(id) FROM sim_attribute_registry))`. Treat registry IDs as first-class stable identifiers (like enum values), not artificial primary keys. Same for `sim_concept_registry` and `sim_pattern_registry`.
- [x] **PRNG portability claim in §10 rule 3 is subtly wrong** — closed 2026-07-11; see §22.10. `std::mt19937_64` raw output is spec-defined across implementations, but `std::uniform_int_distribution`, `uniform_real_distribution`, `bernoulli_distribution` etc. are **NOT** portable between libstdc++ / libc++ / MSVC. A well-known determinism gotcha. Also, both `std::mt19937_64` and `sim/src/math/RngDet.hpp` are referenced — unclear which is authoritative. **Fix**: either (a) forbid all `std::*_distribution` in gameplay via a CI grep and require in-house implementations (uniform int by rejection sampling on raw output; uniform real via `raw / max`), or (b) update §10 to name `RngDet` as the only sanctioned RNG and spec its distribution semantics. Add distribution-lockdown CI grep once decided.
- [x] **Catalog exists in two places (DB and code)** — closed 2026-07-12; see §22.11. `sim_attribute_registry` / `sim_concept_registry` (DB, seeded by migration 200) and the compile-time `constexpr AttrId k...` constants are now single-sourced: `build.sh` pre-generates `sim/src/common/M0Registry.generated.hpp` from migration 200 via `sim/scripts/gen_registry_header.awk`, and `M0Attributes.{hpp,cpp}` contains only non-catalog baseline VALUES (`defaultPhysical()`, `defaultConcepts()`). Container build FATAL_ERRORs loudly if the pre-generated header is missing (verified). Boot-time §16.6 drift check retained as belt-AND-suspenders.

### 21.2 M1-blockers (fix before starting M1 milestone work)

- [ ] **AI slots have no way to load a real teammate's profile.** Product goal: "our player names on AI pieces" (fh-member Miguel's profile drives an AI midfielder). Today `SlotSpawn` (§5.6) has `optional<ConceptSet> ai_concepts` and `optional<PlayerProfile> ai_profile` inline — no "load profile from `sim_player_profile` by `person_id`" path. **Fix**: add `optional<PersonId> ai_profile_source` to `SlotSpawn`. If set, the runtime calls `ProfileStore::load(person_id)` at match setup and injects the profile into the AI slot. Small change, unlocks a big product feature.
- [ ] **`sim_player_profile` write policy is unspecified.** `updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()` exists but nothing says when the sim writes. Naive per-tick writes would be catastrophic. **Fix**: spec (probably in §14 match lifecycle) that profile writes happen at match end + on explicit concept-mastery events (M3+); never per-tick.
- [ ] **Single-daemon single-match convention has no multi-match exit ramp spec'd.** `SIM_MATCH_ID=1` env-baked. §16.6 punts multi-match as an explicit non-goal, but M1 with real drills will need N concurrent matches. Design has no section on how multi-match orchestration works: threading model, process model, match-to-daemon routing, backend `POST /api/sim/matches` becoming a real create. **Fix**: add a new §16.x "Multi-match orchestration plan" before M1 starts. Options to evaluate: (a) N daemons behind a match-router keyed on `match_id`, (b) one daemon with a thread pool serving K matches, (c) per-match ephemeral process spawned on demand. Each has different failure and observability characteristics.

### 21.3 Pre-M3 fixes (fix before M3 planning)

- [ ] **Debug endpoint replay won't scale for long matches.** §16.6's `GET /api/sim/debug/matches/:id/state?tick=T` spawns `fh-sim-replay` in a subprocess with a 10s timeout. For M3+ physics with 22 slots at tick 11999 of a 10-min match, replay-from-scratch exceeds 10s. Subprocess-per-request also serializes debug users. **Fix**: add tick-checkpointing. Every N ticks (e.g. 200 = 10s of match time) the sim writes a full canonical state snapshot to a new `sim_match_checkpoints` table. Replay to tick T loads nearest checkpoint ≤T and replays <200 ticks. Standard technique in deterministic replay tools (`rr`, Chronoscope, speedrunning quantum leap). Not needed for M0, blocking for M3.
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

- [ ] **§17 project layout is stale.** Lists migrations `201-sim-matches.sql, 202-sim-inputs-events.sql, 203-sim-player-profile.sql, 204-sim-decode-functions.sql`, but reality is: migration 200 is one file with all 8 tables, migration 202 is sim-lobby, migration 201 will be the decode functions per §16.6. Test list under §17 also doesn't match what's actually in `sim/tests/`. Full pass needed.
- [ ] **§14 references a "sim server RPC" that doesn't exist.** "Backend inserts row into sim_matches, calls sim server RPC to create instance." Reality (§16.1): `POST /api/sim/matches` is a no-op returning the single seeded row. Reconcile once multi-match orchestration is spec'd (§21.2).
- [ ] **§7 pre-commits to `f32` positions on the wire; §20 wants WASM client-side prediction.** Lockstep prediction needs `Fixed64` on the wire. §20 acknowledges v2-wire is required; §7 doesn't cross-reference this. Add a cross-reference in §7 saying "v1 wire targets rendering only; a v2 wire spec (§20) is required for client-side prediction / WASM lockstep."
- [ ] **§16.1 has `AiController` checked off as an M0 deliverable, but §16.3/§16.4 say AI is wander-only in M0.** True (`AiController` is code-present, behavior-empty), just easy to misread. Add a parenthetical: "(skeleton class; no behaviors plugged until M3)."
- [ ] **§5.7's `Match` includes `spectators` field; §16.4 says "no spectator role distinction in M0."** Field is reserved but present. Add coverage note: "reserved field, no tests until spectator role lands (M3+); do not access from gameplay code."
- [ ] **§5.6's `PlayableArea::Mode` enum has three values (`Hard` / `Soft` / `Advisory`) with no semantics defined.** M0 doesn't use any. Add definitions to §5.6 or defer them to M1 when the first constrained-area scenario lands.
- [ ] **Migration 200 registry key formats are inconsistent.** Attributes use category-prefixed keys (`physical.max_walk_speed`, `physical.max_jog_speed`, ...) while concepts use bare keys (`run_to_point` with `category = 'movement'` set separately in the row). The awk generator in §22.11 handles both by stripping the category prefix only when present, but the underlying inconsistency is worth unifying. Recommendation: pick one convention (bare keys, since the row already carries a `category` column) and land a migration to rewrite the attribute keys. Zero-behavior-change on the sim side because the generated `k*` identifier names stay the same.

### 21.6 Process for this section

- When a checkbox in §21 is addressed, tick it and add a one-line resolution note in place (e.g. "Fixed in Slice 14 by explicit-ID inserts; see migration 213-registry-stable-ids.sql, and §22.9 for the decision record").
- When a checkbox is decided as **won't-fix** with rationale, tick it and record the rationale in place, or point at the §22 ADR that documents it.
- Do **not** open parallel issue trackers or docs for these items — §21 is the tracker, §22 is the decision record.
- New flaws or new non-standard choices discovered later append to the appropriate subsection with a new checkbox.

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

**Refs**: §7.4, §5.8, §21.4 (bespoke WS entry).

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

**End of design v1 · 2026-07-10** (§21 + §22 added 2026-07-11; §22.9 + §22.10 added 2026-07-11; §22.11 added + accepted 2026-07-12 — §21.1 ship-blockers all closed; §22.12 proposed + accepted 2026-07-12 — Slice 13 persistence library landed; §16.6 registry loading + drift check landed 2026-07-13 — Slice 13 sub-slice 2 (`sim/src/persistence/RegistryLoader.{hpp,cpp}` + `sim/scripts/check_no_hardcoded_attrs.sh`); §16.6 profile store + `Match::claimSlot(person_id)` landed 2026-07-13 — Slice 13 sub-slice 3 (`sim/src/persistence/ProfileStore.{hpp,cpp}` + `Slot::person` field + `SimServer` profile bootstrap on connect); §16.6 match lifecycle landed 2026-07-13 — Slice 13 sub-slice 4 (`sim/src/match/CanonicalHash.{hpp,cpp}` + `GIT_DESCRIBE` compile define + `main.cpp` `upsertMatch` on boot / `insertEvent(MatchStart|MatchEnd)` + `updateMatchEnded` with 8-byte FNV-1a-64 canonical snapshot hash on shutdown); §16.6 async input+event logging landed 2026-07-13 — Slice 13 sub-slice 5 (`sim/src/persistence/AsyncPgLog.hpp` templated bounded-queue drain + `InputLog`/`EventLog` typedefs + `SimServer` pushes `InputRow` on accepted INPUT frames and `EventRow{ClientConnect|SlotClaim|SlotRelease|ClientDisconnect}` at transport boundaries + `main.cpp` `input_log.stop()`/`event_log.stop()` before `MatchEnd` write))
