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
3. **Seeded PRNG per match** (`std::mt19937_64` — spec-defined, portable — seeded from `sim_matches.seed`). All random draws go through it. No stray `rand()`.
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

---

**End of design v1 · 2026-07-10**
