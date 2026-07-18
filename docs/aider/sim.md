# Aider Context: Sim

Use this file as the first file you pass to aider for simulator work.

```text
Read this context map. Add the smallest pack for my task, then wait for my next instruction.
Task:
```

## Sim Routing And Rules

Use first when you are not sure which sim subsystem owns the change.

```text
/add sim/README.md sim/DESIGN.md sim/CMakeLists.txt sim/Dockerfile Makefile build.sh
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

Use for utility AI, tactical behavior selection, concepts, roles, recognition,
and behavior registration checks.

```text
/add sim/README.md sim/DESIGN.md sim/src/controller/AiController.cpp sim/src/controller/AiController.hpp sim/src/behavior/IBehavior.hpp sim/src/behavior/PursueBallCarrierBehavior.cpp sim/src/behavior/JockeyBehavior.cpp sim/src/behavior/MarkOpponentBehavior.cpp sim/src/awareness/AwarenessView.hpp sim/tests/test_ai_controller.cpp sim/tests/test_jockey_behavior.cpp sim/tests/test_mark_opponent_behavior.cpp
```

## Registry / Attributes / Migrations

Use when adding or changing sim attributes, concepts, scenarios, generated
registry headers, or registry consistency validation.

```text
/add sim/README.md sim/DESIGN.md sim/src/common/M0Registry.generated.hpp sim/scripts/gen_registry_header.awk sim/scripts/check_registry_consistency.sh build.sh database/migrations/200-sim-registries.sql sim/tests/test_registry.cpp sim/tests/test_registry_loader.cpp
```

## Sim Frontend / Wire Protocol

Use for browser sim rendering, binary snapshots/events, frontend protocol reads,
and `/sim` websocket behavior.

```text
/add sim/README.md sim/DESIGN.md frontend/sim.html frontend/js/sim/renderer.js frontend/js/sim/wire.js sim/src/net/BinaryV1Serializer.cpp sim/src/net/BinaryV1Serializer.hpp sim/tests/test_binary_v1_serializer.cpp sim/tests/test_match_event_frame.cpp
```