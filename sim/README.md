# Simulator Entry Point

This directory contains the deterministic C++ tactical simulator.

## Start Here

For simulator work, load these first:

- `sim/DESIGN.md` for the active roadmap, architecture, and current slice status.
- `docs/aider/sim.md` for the canonical AI context map. Add only the smallest
  pack for the concept, slice, or subsystem you are touching.
- `sim/CMakeLists.txt` for build targets, registry codegen, and test wiring.
- `sim/src/common/M0Registry.generated.hpp` only when touching registry-backed
  attributes or concepts.
- The directly touched `sim/src/**` implementation files.
- The matching `sim/tests/**` test or golden file.

## Design Document Policy

- `sim/DESIGN.md` is the local active design and roadmap for simulator work.
- Stable project-wide rules belong in root `CONVENTIONS.md`, not here.
- Durable cross-system architecture decisions belong in `docs/adr/`.
- Local simulator decisions may stay in `sim/DESIGN.md` while they are useful for
  roadmap context; move them to an ADR only when they affect other subsystems or
  need a stable historical record.

## Non-Negotiables

- Gameplay math is fixed point. Do not introduce floats into the sim loop.
- Same seed plus same inputs must produce byte-identical results.
- Gameplay wire format is binary. JSON is only for human-facing debug surfaces.
- New registry attributes/concepts require migrations, generated header updates,
  and registry consistency validation.

## Validation

Use the narrowest relevant check while iterating. For deployable simulator slices,
run:

```bash
sudo make sim-deploy
```

This rebuilds the sim image, runs the containerized test suite, and verifies
registry consistency against the live database.