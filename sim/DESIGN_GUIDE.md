# Guide to DESIGN.md

This is my own cheat sheet for getting back up to speed on the footballhome
simulator project — what's in `DESIGN.md`, how it's organized, and where to
look depending on what I'm about to do. It's written for one developer (me),
not a team, so there's no role-based navigation — just the document's
contents and a sane path through them.

## What DESIGN.md is

`DESIGN.md` is the single source of truth for the sim project — a
multiplayer tactical football training system that's a companion to the
main fh RSVP/roster app. It's **one cohesive ~3500-line document**, not
scattered docs, covering vision, architecture, full technical spec,
database schema, the milestone roadmap, live implementation status, and
every architecture decision (with reasoning) made along the way.

If the doc and the code ever disagree, **the doc is right and the code is
the bug** — see §22.8.

---

## Where the project stands right now

Before diving into sections, check the **status banner at the very top of
DESIGN.md** (above §1) — it's a running log of the most recent slices
landed, updated every time something ships. As of the last update:

- **M0 (foundation), M1 (ball/dribble), M2 (multiplayer physics/collisions/shots)** — all **done**.
- **M3 (utility-AI behaviors, concepts)** — in progress. `AiController` utility-AI
  dispatch is scaffolded (Slice 30.1) and the first real behavior,
  `PursueBallCarrierBehavior`, has landed (Slice 30.2), replacing the old
  `DefenderController`.
- **Next up:** Slice 31.1 — seed `marking` + `jockey` concepts via migration.
- **M4/M5** — not started (2v1+ progressions, then the original goal:
  `PressTrigger4v2`).

The **§15 Milestone plan** table gives the compact roadmap view (weeks,
cumulative estimate, status per milestone). Read the banner first, the
table second — the banner is the most current word on exactly what landed
last.

---

## Document Map

### Sections 1-4 — Foundation: what & why

| Section | Contents |
|---------|----------|
| **§1 Vision** | Why this exists — teach tactical concepts by playing them, same engine scales toward full 11v11 |
| **§2 Non-goals** | Explicitly out of scope for now (3D rendering, matchmaking, user-generated scenarios, etc.) |
| **§3 Guiding principles** | 10 rules that every design/code decision must satisfy |
| **§4 Architecture overview** | System diagram: browser client ↔ `footballhome_sim` (C++) ↔ `footballhome_backend` ↔ Postgres |

### Sections 5-11 — Technical spec (the implementation layer)

| Section | Contents |
|---------|----------|
| **§5 Class hierarchy** | The full C++ server object model |
| §5.1 | Q32.32 fixed-point math (`Fixed64`) — the math primitives |
| §5.2 | Attributes & concepts — the player skill/knowledge model |
| §5.3 | `IPhysicsWorld` — collision & movement interface |
| §5.4 | `IPlayerController` — human/AI input layer |
| §5.5 | `IBehavior` — concept-gated AI behavior interface |
| §5.6 | `Scenario` interface — training scenario definitions |
| §5.7 | `Match` — the game loop orchestrator |
| §5.8 | Network transport — binary wire layer |
| §5.9 | Server runtime — process startup/lifecycle |
| **§6 Client architecture** | Vanilla JS renderer, ~200 lines, zero game logic |
| **§7 Wire protocol** | Binary message format (SNAPSHOT, INPUT, HELLO_ACK, etc.) |
| **§8 Database schema** | SQL tables & relationships for sim data |
| **§9 Coordinate system & math** | Pitch layout + vector conventions |
| **§10 Determinism rules** | Why and how the sim is byte-identical across machines |
| **§11 Player model** | Recognition → Decision → Execution cognitive stages |

### Section 12 — Reference catalogs (documentation, not yet code)

| Catalog | Describes |
|---------|-----------|
| §12.1 Physical | Body attributes (speed, strength, etc.) |
| §12.2 Technical | Ball-skill attributes (passing, shooting, etc.) |
| §12.3 Mental | Decision-making attributes (positioning, awareness, etc.) |
| §12.4 Concepts | Tactical knowledge units (pressing, marking, etc.) |
| §12.5 Patterns | Recognition targets — reserved for M4+, empty today |

### Sections 13-16, 22-25 — Roadmap & progress

| Section | Contents |
|---------|----------|
| **§13 Auth model** | Login + member-only access, JWT flow |
| **§14 Match lifecycle** | join → play → end → persist |
| **§15 Milestone plan** | Roadmap table (M0-M5), status per milestone |
| **§16 Milestone 0** | Detailed spec + deliverable checklist (§16.1), attributes (§16.2), concepts (§16.3), non-goals (§16.4), exit criteria (§16.5) |
| **§22 Decision log (ADRs)** | Every architecture decision made, with context/decision/consequences — **the reasoning behind everything** |
| **§23 Milestone 1 spec** (nested under the ADR numbering — scope §23.1, deliverables §23.2, slices §23.3, exit criteria §23.4) |
| **§24 Milestone 2 spec** (same shape: §24.1-24.7 — physics, collisions, shots) |
| **§25 Milestone 3 spec** (same shape: §25.1-25.7 — utility AI, first real behaviors) |

Note the numbering quirk: §23-25 (per-milestone detailed specs) live physically
*after* §22 (the ADR log) in the file, not before it. §15 is the roadmap
overview; §16/23/24/25 are where each milestone's actual spec, slice
sequence, and exit checklist live.

### Sections 17-21 — Operations & context

| Section | Contents |
|---------|----------|
| **§17 Project layout** | File tree with per-file implementation status |
| **§18 Debug & observability** | Logging, replay inspection |
| **§19 Anti-patterns** | Things explicitly avoided, and why |
| **§20 Open questions** | Revisit-later items — safe to ignore for now |
| **§21 Known flaws** | Conscious technical debt + active blockers |

---

## Key Concepts to Know

### The Recognition→Decision→Execution Model (§11)
Players learn through three cognitive stages:
1. **Recognition** — Can they see and label a tactical pattern?
2. **Decision** — Can they decide what to do in that pattern?
3. **Execution** — Can they execute the technique?

The simulator trains all three. The design treats them as separate layers from day one.

### Fixed-Point Determinism (§22.1, §22.2)
- **All gameplay math** uses Q32.32 fixed-point (`Fixed64`), not floats.
- **Why?** Floats are non-deterministic across CPUs/compilers. Fixed-point is bit-exact everywhere.
- **Implication:** Same seed + same inputs = identical simulation on any machine. This is *required* for replays.

### Attribute-Driven Design (§5.2, §22.18)
- **Attributes** are player skills (e.g., passing accuracy, sprint speed).
- **Concepts** are tactical knowledge (e.g., "pressing", "marking").
- **Both are registry-backed:** Add a new attribute/concept by adding a row to the SQL registry, not by changing code.

### Scenario as Code + Registry Entry (§5.6)
- Scenarios are not user data — they're code + registry entries.
- A scenario defines initial player positions, AI behaviors, training objectives.
- Scenarios are versioned alongside the simulator (not editable by users in M0/M1).

### Wire Protocol = Binary, Never JSON (§7, §22.5)
- **Gameplay data** flows as binary on the wire (deterministic, compact).
- **Debug endpoints** serve JSON (for humans).
- **Why?** Floats in JSON → non-deterministic on the client. Binary is serializable as Fixed64.

---

## How to Find Specific Information

### "How do I add a new attribute?"
- **§5.2** — AttributeSet data structure
- **§22.18** — Storage normalization (bytea → row-per-value)
- **§12.1, 12.2, 12.3** — Existing attribute catalogs
- **§17** → look for `sim_attribute_registry` creation

### "What is a Concept and how do I create one?"
- **§5.2** — ConceptSet data structure
- **§12.4** — Concept catalog (tactical knowledge)
- **§22.11** — Registry codegen from migration
- Look for `migration 2XX-sim-concept-*.sql` files

### "How does the physics engine work?"
- **§5.3** — IPhysicsWorld interface
- **§22.24** — Player-player collision ADR
- **§10** — Determinism rules (especially fixed-point)

### "How do I design a new training scenario?"
- **§5.6** — Scenario interface
- **§6.4** — Layout & UX constraints (screen size, etc.)
- **§11** — Player model (what players learn from scenarios)
- **§16.1** — M0 scenarios (use as templates)

### "What's the wire protocol format?"
- **§7** — Full binary format specification
- **§7.1** — Message types (SNAPSHOT, INPUT, etc.)
- **§7.2** — SNAPSHOT payload structure
- **§22.20, 22.23** — Recent extensions (ball, kicks)

### "How is match state persisted?"
- **§8** — Database schema
- **§22.18** — Attribute/concept storage
- **§22.25** — Match event payload versioning
- **§16.6** — Slice 13 (persistence & replay)

### "What's the current milestone status?"
- **§16.1** — M0 progress tracker (current)
- Status banner at top of DESIGN.md shows: which slices are CLOSED, in progress, or upcoming

---

## How to Contribute to This Document

### When to Update DESIGN.md
1. **You made an architectural decision** → Add an ADR in §22 (copy §22.N template)
2. **You hit a blocker or technical debt** → Add/update §21 (Known flaws)
3. **Project roadmap changed** → Update §15 or the relevant Milestone section
4. **You're adding a new attribute/concept** → Update §12 catalog

### Structure to Follow
- **ADRs (§22):** Always follow the format: title, context, decision, consequences, amendments.
- **Milestones:** Use the [YYYY-MM-DD] slice numbering scheme.
- **Catalogs:** Use consistent formatting (ID, name, description, examples).

### When NOT to Update
- Don't duplicate what's already in code comments.
- Don't document ephemeral things (current build status, PR links, etc.) — those belong in git commit messages or tickets.
- Don't update the project layout (§17) unless you move files — focus stays on architectural decisions.

---

## Red Flags & Gotchas

### ⚠️ Determinism is Non-Negotiable
- **Never add floats to the sim loop.** Floats are non-deterministic.
- **Never use `<random>` distributions.** Use `RngDet` (§22.10).
- **Every arithmetic operation must be fixed-point.**
- Violation = replays don't match.

### ⚠️ Scenario IDs Are Stable
- Once a scenario gets an ID in `sim_scenarios`, it's locked forever (for replay compatibility).
- Don't reuse or rename scenario IDs.
- New scenarios get new IDs.

### ⚠️ Registry IDs Are Stable Enums
- Attributes, concepts, and patterns have stable enum IDs in the registry.
- Once assigned, the ID is immutable (replays depend on it).
- See §22.9 for the full rule.

### ⚠️ M0 Constraints
- §16.4 lists explicit non-goals for M0.
- Don't build features outside M0 scope — they block milestone closure.
- M0 features only: 2 players, 1 ball, basic scenarios, no AI yet.

### ⚠️ Client is "Dumb"
- Client is vanilla JS with ~200 lines of code.
- **All game logic is on the server.**
- Client only: renders snapshots, sends input, receives updates.
- Any server-side feature automatically works on all clients.

---

## Quick Reference: Key Files

Mentioned frequently in DESIGN.md:

| File | Purpose |
|------|---------|
| `sim/src/math/Fixed64.hpp` | Q32.32 fixed-point type |
| `sim/src/Match.hpp` | Game loop orchestrator |
| `sim/src/IPlayerController.hpp` | Human/AI input interface |
| `sim/src/IPhysicsWorld.hpp` | Collision + movement |
| `sim/src/IBehavior.hpp` | AI behavior interface |
| `sim/src/Scenario.hpp` | Training scenario interface |
| `sim/src/Wire.hpp` | Binary protocol codec |
| `database/migrations/` | SQL registry definitions |
| `sim/src/tools/Replay.cpp` | Determinism testing tool |

---

## Getting Back Up to Speed (Re-orientation Checklist)

This isn't a one-time onboarding — it's what I run through every time I sit
back down after time away from the sim project.

1. **Read the status banner** at the top of DESIGN.md (above §1). It's the
   most current word on what landed last and what's next.
2. **Skim §15 (Milestone plan)** for the big-picture roadmap position.
3. **Check the current milestone's spec section** (§16 for M0, §23 for M1,
   §24 for M2, §25 for M3) — specifically its exit-criteria subsection
   (e.g. §25.4) to see what's still open before the milestone closes.
4. **Check §21 (Known flaws)** for anything blocking active work.
5. If it's been a long gap, skim the tail end of **§22 (Decision log)** —
   the most recent ADRs explain *why* the last few slices were built the
   way they were.
6. Find the code for the slice in progress via **§17 (Project layout)**,
   then pick up where the status banner says work stopped.

## First Time Through (if I've genuinely forgotten the fundamentals)

1. **§1 Vision** + **§3 Guiding principles** — what this is and the
   non-negotiable rules (~15 min).
2. **§4 Architecture overview** — the three-process picture: browser ↔
   `footballhome_sim` ↔ `footballhome_backend` ↔ Postgres (~10 min).
3. **§10 Determinism rules** + **§22.1/§22.2** — the single idea that
   shapes every line of gameplay code: fixed-point math, no floats, bit-exact
   replays (~10 min).
4. **§11 Player model** — Recognition → Decision → Execution, the layering
   every controller must respect (~10 min).
5. Skim **§22 (Decision log)** front to back once, just to build a mental
   map of *why* things are the way they are — don't try to retain details,
   just know it's there to search later (~30 min).

## Running the Project Locally

- **§17 Project layout** — file tree with per-file implementation status;
  use it to find where a given piece of the spec actually lives in code.
- **§18 Debug & observability** — how to inspect a running match / replay.
- **§16.6 / §22.12-22.14** — persistence & replay library, useful when
  debugging why a replay doesn't match a golden hash.

---

## FAQ

**Q: Is DESIGN.md always up-to-date?**
A: Yes — that's the rule (§22.8), "one document, one source of truth." If code and doc disagree, the doc is right and the code is the bug. Keep it that way: update the doc in the same sitting as the code change.

**Q: Do I need to read all ~3500 lines every time?**
A: No. Use the status banner + §15 for "where am I", the Document Map above for "where do I find X", and only read the §5.X subsystem or §22 ADR that's directly relevant to what I'm about to touch.

**Q: I disagree with a past decision I made — what do I do?**
A: Read the ADR in §22 first — there's usually a reason that seemed good at the time. If it still seems wrong, add an amendment to that ADR (format in §22.0) rather than silently changing behavior; keep the paper trail.

**Q: When do I add a new ADR vs. just editing a section?**
A: New ADR (§22, copy the §22.N template) for any decision with real trade-offs or that future-me will wonder about. Just edit in place for the Milestone spec sections (§16/23/24/25 checklists), §12 catalogs, §17 layout, and §21 known flaws — those are living trackers, not decision records.

---

**Last updated:** 2026-07-17
**When stuck:** check §20 (Open questions) and §21 (Known flaws) first — the answer to "is this a known issue" is probably already written down.
