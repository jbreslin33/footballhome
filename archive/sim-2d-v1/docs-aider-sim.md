# Aider Context: Sim

Use this file as the first file you pass to aider for simulator work.
It is also the canonical AI context map for Copilot agents. Keep concept and
slice file packs here, not in `sim/DESIGN.md`.

```text
Read this context map. Add the smallest pack for my task, then wait for my next instruction.
Task:
```

## How To Use This File

1. Add only this file first when the task is vague.
2. Pick exactly one pack below, unless the task explicitly crosses boundaries.
3. Add neighboring tests before neighboring implementation files.
4. Add `sim/DESIGN.md` only when changing roadmap/design status or when the pack
	says the design is part of the work surface.
5. Finish simulator behavior, scenario, registry, or persistence edits with
	`sudo make sim-deploy`. For context-map-only edits, `git diff --check` is
	enough.

Pack format is consistent:

```text
## Pack Name
Use when ...

/add file1 file2 file3
```

## Sim Routing And Rules

Use first when you are not sure which sim subsystem owns the change.

```text
/add CONVENTIONS.md .github/copilot-instructions.md sim/README.md docs/aider/sim.md sim/DESIGN.md sim/CMakeLists.txt Makefile build.sh
```

## Slice Coverage Index

Use this index to translate a `sim/DESIGN.md` slice into the smallest pack in
this file. The pack sections below own the file lists; this index prevents the
slice roadmap and file-map system from drifting apart.

| Slice | Work surface | Pack to add |
| --- | --- | --- |
| 30.0 | Deferred checkpoint store / replay checkpoints | `Match Loop / Tick Behavior` plus `Determinism Goldens` |
| 30.1 | `AiController` factory / utility dispatch scaffold | `AI Behaviors / Concepts` |
| 30.2 | `pressing` + `PursueBallCarrierBehavior` | `Concept: pressing` |
| 31.1 | `marking` / `jockey` concept migration | `Concepts: marking / jockey` plus `Concept Catalog / Generated Registry` |
| 31.2 | `JockeyBehavior` + `MarkOpponentBehavior` | `Concepts: marking / jockey` |
| 31.3 | M3 behavior attributes | `Concept Catalog / Generated Registry` |
| 31.4 | Role-specific defender behavior bags | `Concepts: marking / jockey` plus `AI Behaviors / Concepts` |
| 31.5 | Defender behavior determinism goldens | `Determinism Goldens` plus `Concepts: marking / jockey` |
| 32.1 | Utility-AI hysteresis / `IBehavior::minTicks()` | `AI Behaviors / Concepts` |
| 32.2 | No-oscillation determinism golden | `Determinism Goldens` plus `AI Behaviors / Concepts` |
| 32.3 | Re-verify Slice 31 goldens | `Determinism Goldens` |
| 33.1 | `1v1_beat` concept migration | `Concept: 1v1_beat` plus `Concept Catalog / Generated Registry` |
| 33.2 | `Feint1v1Behavior` | `Concept: 1v1_beat` |
| 33.3 | `pattern_being_beaten_1v1` | `Pattern: being_beaten_1v1` |
| 33.4 | Attacker role behavior-bag tuning | `Concept: 1v1_beat` plus `AI Behaviors / Concepts` |
| 33.5 | Attacker-feint determinism golden | `Determinism Goldens` plus `Concept: 1v1_beat` |
| 34.1 | `OneVsOneAttackDefendScenario` | `Scenario: OneVsOneAttackDefend` |
| 34.2 | `ai_profile_source` / `ProfileStore::load` wiring | `Profile Source Loading` |
| 34.3 | Frontend tile / scenario launch UI | `Sim Frontend / Wire Protocol` plus `Scenario: OneVsOneAttackDefend` |
| 34.4 | `return_to_base` / `stay_in_zone` concepts | `Concepts: return_to_base / stay_in_zone` plus `Concept Catalog / Generated Registry` |
| 34.5 | Full 1v1 scoring determinism golden | `Determinism Goldens` plus `Scenario: OneVsOneAttackDefend` |
| 35.1 | M3 exit-criteria sweep | `M3 Close-Out / Design Status` |
| 35.2 | M3 non-goals sanity check | `M3 Close-Out / Design Status` |
| 35.3 | M4 blocker sweep | `M3 Close-Out / Design Status` |
| 35.4 | M3 milestone flip | `M3 Close-Out / Design Status` |

Future M4+ slices should add one row here and one pack below when they first
become active. Do not pre-enumerate speculative files before the owning code
surface exists.

## Concept Catalog / Generated Registry

Use when adding, renumbering, or validating sim concepts or attributes.

```text
/add sim/README.md docs/aider/sim.md sim/CMakeLists.txt sim/src/common/M0Registry.generated.hpp sim/scripts/gen_registry_header.awk sim/scripts/check_registry_consistency.sh database/migrations/200-sim-registries.sql sim/tests/test_registry.cpp sim/tests/test_registry_loader.cpp
```

## Concept: pressing

Use for the `pressing` concept and behavior path that chases/presses the ball
carrier.

```text
/add sim/README.md docs/aider/sim.md database/migrations/224-sim-concept-pressing.sql sim/src/behavior/PursueBallCarrierBehavior.hpp sim/src/behavior/PursueBallCarrierBehavior.cpp sim/src/controller/AiController.cpp sim/src/controller/AiController.hpp sim/tests/test_pursue_ball_carrier_behavior.cpp sim/tests/test_ai_controller.cpp
```

## Concepts: marking / jockey

Use for `marking`, `jockey`, mark-target plumbing, or defender behavior bags.

```text
/add sim/README.md docs/aider/sim.md database/migrations/225-sim-concept-marking-jockey.sql sim/src/behavior/MarkOpponentBehavior.hpp sim/src/behavior/MarkOpponentBehavior.cpp sim/src/behavior/JockeyBehavior.hpp sim/src/behavior/JockeyBehavior.cpp sim/src/controller/AiController.cpp sim/src/controller/AiController.hpp sim/src/scenario/Scenario.hpp sim/tests/test_mark_opponent_behavior.cpp sim/tests/test_jockey_behavior.cpp sim/tests/test_ai_controller.cpp
```

## Concept: 1v1_beat

Use for attacker feints, ST9/ST10 attacker behavior bags, or `1v1_beat` concept
gating.

```text
/add sim/README.md docs/aider/sim.md database/migrations/229-sim-concept-1v1-beat.sql sim/src/behavior/Feint1v1Behavior.hpp sim/src/behavior/Feint1v1Behavior.cpp sim/src/controller/AiController.cpp sim/src/controller/AiController.hpp sim/tests/test_feint_1v1_behavior.cpp sim/tests/test_ai_controller.cpp
```

## Concepts: return_to_base / stay_in_zone

Use for Slice 34.4 positioning concept catalog work. These concepts are wired
for registry completeness before their M4 behavior consumers exist.

```text
/add sim/README.md docs/aider/sim.md sim/CMakeLists.txt sim/src/common/M0Registry.generated.hpp sim/scripts/gen_registry_header.awk database/migrations/200-sim-registries.sql sim/tests/test_registry_loader.cpp
```

## Pattern: being_beaten_1v1

Use for the first M3 recognition pattern, recognition history, or pattern
registry loading.

```text
/add sim/README.md docs/aider/sim.md database/migrations/230-sim-pattern-being-beaten-1v1.sql sim/src/awareness/RecognitionSystem.hpp sim/src/awareness/RecognitionSystem.cpp sim/src/awareness/AwarenessView.hpp sim/src/registry/PatternRegistry.hpp sim/src/registry/PatternRegistry.cpp sim/src/match/Match.cpp sim/src/match/Match.hpp sim/src/main.cpp sim/tests/test_recognition_passthrough.cpp sim/tests/test_registry_loader.cpp
```

## Match Loop / Tick Behavior

Use for tick order, match lifecycle, input application, event emission, and
determinism changes in the core match engine.

```text
/add sim/README.md sim/DESIGN.md sim/src/match/Match.cpp sim/src/match/Match.hpp sim/tests/test_match_tick.cpp sim/tests/test_determinism.cpp
```

## Physics / Mechanics

Use for ball/player physics, collisions, movement mechanics, fixed-point math,
and physics goldens.

```text
/add sim/README.md sim/DESIGN.md sim/src/physics/BasicPhysics.cpp sim/src/physics/BasicPhysics.hpp sim/src/mechanics/BallControl.cpp sim/src/mechanics/BallControl.hpp sim/src/math/Fixed64.hpp sim/tests/test_basic_physics.cpp sim/tests/test_mechanics.cpp sim/tests/test_determinism.cpp
```

## AI Behaviors / Concepts

Use when the task is about utility-AI dispatch itself rather than a single
concept pack above.

```text
/add sim/README.md docs/aider/sim.md sim/src/controller/AiController.cpp sim/src/controller/AiController.hpp sim/src/behavior/IBehavior.hpp sim/src/behavior/PursueBallCarrierBehavior.cpp sim/src/behavior/JockeyBehavior.cpp sim/src/behavior/MarkOpponentBehavior.cpp sim/src/behavior/Feint1v1Behavior.cpp sim/src/awareness/AwarenessView.hpp sim/tests/test_ai_controller.cpp
```

## Registry / Attributes / Migrations

Use when adding or changing sim attributes, concepts, scenarios, generated
registry headers, or registry consistency validation.

```text
/add sim/README.md sim/DESIGN.md sim/src/common/M0Registry.generated.hpp sim/scripts/gen_registry_header.awk sim/scripts/check_registry_consistency.sh build.sh database/migrations/200-sim-registries.sql sim/tests/test_registry.cpp sim/tests/test_registry_loader.cpp
```

## Scenario: OneVsOneAttackDefend

Use for scenario id 7, its runtime/replay factory mapping, goal regions, and
focused scenario tests.

```text
/add sim/README.md docs/aider/sim.md database/migrations/231-sim-scenarios-1v1-attack-defend.sql sim/src/scenario/OneVsOneAttackDefendScenario.hpp sim/src/scenario/OneVsOneAttackDefendScenario.cpp sim/src/scenario/Scenario.hpp sim/src/main.cpp sim/src/tools/Replay.cpp sim/tests/test_one_v_one_attack_defend_scenario.cpp sim/CMakeLists.txt sim/tests/CMakeLists.txt
```

## Profile Source Loading

Use for `SlotSpawn::ai_profile_source`, `ProfileStore::load(person_id)`, and
injecting persisted profiles into AI slots at match setup.

```text
/add sim/README.md docs/aider/sim.md sim/src/scenario/Scenario.hpp sim/src/match/Match.hpp sim/src/match/Match.cpp sim/src/persistence/ProfileStore.hpp sim/src/persistence/ProfileStore.cpp sim/tests/test_profile_store.cpp sim/tests/test_one_v_one_attack_defend_scenario.cpp
```

## Determinism Goldens

Use when adding or updating canonical hashes, scripted match fixtures, or
cross-behavior determinism locks.

```text
/add sim/README.md docs/aider/sim.md sim/tests/test_determinism.cpp sim/src/match/Match.cpp sim/src/match/CanonicalHash.cpp sim/src/mechanics/BallControl.cpp sim/src/physics/BasicPhysics.cpp
```

## M3 Close-Out / Design Status

Use for Slice 35 doc-only close-out, M3 exit-criteria checks, non-goal audits,
M4 blocker appendices, and milestone table flips.

```text
/add sim/README.md docs/aider/sim.md sim/DESIGN.md sim/scripts/check_determinism_cross_arch.sh sim/tests/test_determinism.cpp
```

## Sim Frontend / Wire Protocol

Use for browser sim rendering, binary snapshots/events, frontend protocol reads,
and `/sim` websocket behavior.

```text
/add sim/README.md sim/DESIGN.md frontend/sim.html frontend/js/sim/renderer.js frontend/js/sim/wire.js sim/src/net/BinaryV1Serializer.cpp sim/src/net/BinaryV1Serializer.hpp sim/tests/test_binary_v1_serializer.cpp sim/tests/test_match_event_frame.cpp
```