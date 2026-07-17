# Guide to DESIGN.md: Designer Onboarding

Welcome to the footballhome simulator design document! This guide will help you navigate the comprehensive DESIGN.md file and understand how to find what you need.

## Quick Overview

**DESIGN.md** is the single source of truth for the footballhome simulator project — a multiplayer tactical football training system. It documents:
- Architecture and design decisions
- Technical specifications
- Database schema
- Project roadmap (Milestones 0-3)
- Implementation progress
- Decision rationale (ADRs)

**Key fact:** This is **one cohesive document**, not scattered docs. Everything connects.

---

## Document Structure at a Glance

### Part 1: Foundation (Sections 1-4)
Start here to understand **what** the simulator is and **why** it's designed this way.

| Section | Purpose | Read if... |
|---------|---------|-----------|
| **§1 Vision** | Purpose of the simulator | You're new to the project |
| **§2 Non-goals** | What we explicitly don't do | You're tempted to add something |
| **§3 Guiding principles** | 10 core design rules | You're making architectural decisions |
| **§4 Architecture overview** | System diagram + data flow | You need the 30-second mental model |

### Part 2: Technical Deep-Dive (Sections 5-11)
The implementation layer. Read if you're building features, not just using the simulator.

| Section | What it covers | Relevance |
|---------|---------------|-----------|
| **§5 Class hierarchy** | C++ server object model | Backend engineers, architects |
| §5.1 Math & primitives | Q32.32 fixed-point math | Determinism-critical code |
| §5.2 Attributes & concepts | Open player skill catalog | Coaches, AI trainers |
| §5.3 Physics interface | Collision and movement | Physics features |
| §5.4 Player controller interface | Human/AI input layer | Multiplayer design |
| §5.5 AI behavior interface | Concept-gated AI | AI/behavior engineers |
| §5.6 Scenario interface | Training scenarios | Scenario designers |
| §5.7 Match orchestrator | Game loop | Core loop engineers |
| §5.8 Network transport | Binary wire protocol | Networking, client work |
| §5.9 Server runtime | Process startup | DevOps, deployment |
| **§6 Client architecture** | Vanilla JS renderer | Frontend engineers |
| **§7 Wire protocol** | Binary message format | Wire-level debugging |
| **§8 Database schema** | SQL tables & relationships | Data engineers, SQL queries |
| **§9 Coordinate system & math** | Pitch layout + vectors | Physics, rendering |
| **§10 Determinism rules** | Byte-identical simulation | Testing, replays |
| **§11 Player model** | Cognition stages (Recognition→Decision→Execution) | Behavior design |

### Part 3: Reference Catalogs (Section 12)
**Reserved catalogs** (not code yet) that define the skill taxonomy.

| Catalog | Describes |
|---------|-----------|
| §12.1 Physical | Player body attributes (speed, strength, etc.) |
| §12.2 Technical | Ball skill attributes (passing, shooting, etc.) |
| §12.3 Mental | Decision-making attributes (positioning, awareness, etc.) |
| §12.4 Concepts | Tactical knowledge units (pressing, marking, etc.) |
| §12.5 Patterns | Recognition targets (for M4+, empty in M0) |

**For designers:** These catalogs are the DNA of the training system. Decisions here cascade into coaching content.

### Part 4: Project Roadmap (Sections 13-25)
Where the project has been, where it's going, and what's in progress.

| Section | Content |
|---------|---------|
| **§13 Auth model** | Login + member-only access |
| **§14 Match lifecycle** | Stages: join → play → end → persist |
| **§15 Milestone plan** | Roadmap overview (M0 → M1 → M2 → M3) |
| **§16 Milestone 0** | Current/recent target — detailed spec + slices |
| **§23 Milestone 1** | Next phase — specs + slice breakdown |
| **§24 Milestone 2** | Physics, AI behaviors, collisions |
| **§25 Milestone 3** | Advanced AI, utility system |

### Part 5: Operations & Context (Sections 17-22)
Rules, gotchas, and the reasoning behind choices.

| Section | Topic |
|---------|-------|
| **§17 Project layout** | File tree + per-file implementation status |
| **§18 Debug & observability** | Logging, profiling, replay inspection |
| **§19 Anti-patterns** | Things we explicitly don't do (and why) |
| **§20 Open questions** | Revisit-later items (safe to ignore for now) |
| **§21 Known flaws** | Conscious technical debt + blockers |
| **§22 Decision log (ADRs)** | **The reasoning behind every big choice** |

---

## How to Navigate by Role

### I'm a **Product/Design Lead**
1. **§1 Vision** — Why does this exist?
2. **§3 Guiding principles** — What are the constraints?
3. **§15 Milestone plan** — What's the roadmap?
4. **§16.1 Deliverables** (M0) — What ships next?
5. **§12 Catalogs** — What skills do we teach?
6. **§11 Player model** — How do players learn?

### I'm a **Frontend Engineer**
1. **§4 Architecture overview** — How does the client fit?
2. **§6 Client architecture** — Where does my code live?
3. **§7 Wire protocol** — Binary message format
4. **§6.2 Renderer interface** — How to render a snapshot
5. **§6.3 Input interface** — How to capture player input
6. **§10 Determinism rules** — Why can't I use floating-point?

### I'm a **Backend/C++ Engineer**
1. **§4 Architecture overview** — System picture
2. **§5 Class hierarchy** — The server object model
3. **§22 Decision log** — Why did we choose this way?
4. **§17 Project layout** — Where's the code?
5. **§10 Determinism rules** — Math rules for the sim loop
6. Specific §5.X for your subsystem (physics, AI, networking, etc.)

### I'm a **Scenario/Content Designer**
1. **§11 Player model** — How do players learn?
2. **§5.6 Scenario interface** — How scenarios work
3. **§12 Catalogs** — What attributes/concepts to use
4. **§6.4 Layout & UX requirements** — Screen constraints
5. **§21 Known flaws** → M0 non-goals — What can't I do yet?

### I'm a **QA/Testing Engineer**
1. **§10 Determinism rules** — Why replays must be identical
2. **§14 Match lifecycle** — What states can a match be in?
3. **§22.1 Determinism is a top-level property** — Testing strategy
4. **§18 Debug & observability** — How to inspect a match
5. **§16.5 M0 exit criteria** — What "done" looks like

### I'm a **DevOps/Infrastructure**
1. **§5.9 Server runtime** — Process startup + lifecycle
2. **§8 Database schema** — Tables + relationships
3. **§22.19 Backend → podman IPC** — Service communication
4. **§13 Auth model** — Member-only login flow

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

## Next Steps

### Your First Day
1. Read **§1 (Vision)** and **§3 (Guiding principles)** — 15 min.
2. Read **§4 (Architecture overview)** — 10 min.
3. Read the role-specific guide above for your job title — 20 min.
4. Skim **§22 (Decision log)** to get a sense of how decisions are documented — 30 min.

### Your First Week
- Deep-dive into the §5.X subsystems relevant to your work.
- Read **§22** ADRs to understand the reasoning (not just the rules).
- Check **§17 (Project layout)** to find code files.
- Run a simulator match locally and inspect a replay using the tools in **§18**.

### Your First Month
- Contribute a small fix or clarification to DESIGN.md (show you understand the format).
- Propose an ADR for a decision you made.
- Mentor someone else using this guide.

---

## FAQ

**Q: Is DESIGN.md always up-to-date?**
A: Yes. §22.8 declares it "one document, one source of truth." If you see a discrepancy with code, the document is authoritative — the code is the bug.

**Q: Can I ignore parts of DESIGN.md?**
A: Not the ones in your critical path. But yes, open questions (§20), some of §21 (known flaws), and advanced M3 milestones can wait.

**Q: How long is DESIGN.md?**
A: ~3500 lines. Not all at once. Use this guide to navigate by role + task.

**Q: What if I disagree with a design decision?**
A: Read the ADR (§22) first. If you still disagree, propose an amendment in the ADR (see §22.0). Don't fork it in your head.

**Q: Who maintains this?**
A: The whole team. Everyone owns keeping it accurate. If you find a discrepancy, fix it (or flag it in §21 as a known flaw).

---

**Last updated:** 2026-07-17  
**For questions:** Check §20 (Open questions) or §21 (Known flaws), or add an ADR in §22.
