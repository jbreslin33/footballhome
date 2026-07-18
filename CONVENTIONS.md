# Football Home Conventions

This is the canonical convention document for Football Home. It contains the
project-wide rules that apply across backend, frontend, database, simulation,
setup, and AI-assisted work. If another document contains lasting project-wide
rules, migrate those rules here and leave that other document as orientation or
tool-specific bootstrap only.

## Repository Contract

- Workspace root is `/srv/footballhome`.
- Production and local container workflows use rootful Podman on Linux. Use
  `sudo podman ...` and `sudo make ...` for container and database operations.
- `docker` is not installed on this host; the engine is `podman`.
- Before running commands or editing files, check the local context in this
  order: `pwd`, `make help`, `sudo podman ps`, then read the relevant files.
- Do not run destructive targets such as `make rebuild`, `make safe-rebuild`,
  volume removal, or container volume resets without explicit approval. Run
  `make backup` first when destructive work is approved.
- Do not commit secrets. Plaintext `env`, VPN configs, APSL credentials, backups,
  generated logs, and scratch files must stay ignored.

## Documentation System

Use the smallest document that owns the decision:

- `CONVENTIONS.md`: cross-cutting rules, source-of-truth boundaries, coding
  style, setup expectations, terminal discipline, and AI workflow guidance.
- `.github/copilot-instructions.md`: tool bootstrap only. It may point agents to
  this document and include minimal pre-read safety rules, but it must not become
  a second convention source.
- `README.md`: product orientation, quickstart, and common commands.
- `<subsystem>/README.md`: local entrypoint map for a subsystem.
- `<subsystem>/DESIGN.md`: active roadmap, technical design, and current plan
  for one subsystem, for example `sim/DESIGN.md`.
- `docs/<topic>-design.md`: cross-cutting designs that do not fit one subsystem.
- `docs/adr/YYYY-MM-DD-short-title.md`: short immutable architecture decision
  records for durable decisions that affect multiple areas or are likely to be
  revisited.

Avoid one giant root design document. It makes ownership unclear and makes AI
context worse by forcing unrelated history into every task.

When a subsystem has a predictable AI context set, put a short "Start here"
section in its README listing the first files to load.

## General Principles

- Write clear, maintainable code
- Follow existing patterns in the codebase
- Use meaningful variable and function names
- Add comments for complex logic
- Keep functions focused and single-purpose
- **Use Object-Oriented Programming (OOP) principles in all code**
  - Encapsulation: Keep data and methods together in classes
  - Inheritance: Use class hierarchies where appropriate
  - Polymorphism: Leverage virtual functions and interfaces
  - Abstraction: Hide implementation details behind clean interfaces
- **Use state machines for screens and when appropriate elsewhere**
  - Manage complex state transitions explicitly
  - Track context and history
  - Make application flow predictable and testable
- **Prefer custom solutions over bloated third-party tools**
  - Build lightweight, purpose-specific implementations when feasible
  - Use third-party libraries when they provide clear value without excessive overhead
  - Evaluate dependencies carefully: consider maintenance burden, size, and complexity
  - Acceptable third-party use cases:
    - Well-established, focused libraries (e.g., `nlohmann/json` for JSON parsing)
    - Complex domains where custom implementation would be error-prone (e.g., cryptography)
    - Standard protocols and formats
  - Avoid heavy frameworks that dictate architecture or add unnecessary abstractions

## Terminal Commands

- Show full, unfiltered command output. Do not hide diagnostics with display
  filters or redirects.
- Do not use `head`, `tail`, `grep`, `awk`, `sed`, `cut`, `less`, `more`, pager
  commands, `--quiet`, `-q`, `2>/dev/null`, or output redirection when the output
  is being shown for diagnosis or validation.
- Existence checks inside scripts are fine, for example `grep -q` before acting.
- If output will be enormous, ask which slice is useful before running the
  command instead of silently truncating it.

## File Organization

- Root is for first-class entrypoints and metadata: `Makefile`, `build.sh`,
  `setup.sh`, `docker-compose.yml`, `package.json`, `README.md`,
  `CONVENTIONS.md`, and encrypted secrets such as `env.age`.
- Operational scripts belong under `scripts/` or the subsystem they operate on.
  Use focused subdirectories such as `scripts/setup/`, `scripts/debug/`,
  `scripts/ads/`, or `sim/scripts/` when a category grows.
- Scraper output belongs under `database/scraped-html/<league>/`, never root.
- Generated SQL for league data belongs under
  `database/scripts/leagues/<continent>/<country>/<league>/sql/`.
- Scratch files, temporary psql output, local probes, logs, media experiments,
  and test throwaways do not belong in root and must not be committed.

## Language Choices

- **Backend**: C++ is the preferred language for all backend development
- **Simulation**: C++ (required for deterministic fixed-point math)
- **Frontend**: JavaScript (ES6+)

## C++ Backend (`backend/`)

### Naming Conventions
- **Classes**: PascalCase (e.g., `HttpClient`, `Database`)
- **Functions/Methods**: camelCase (e.g., `getInstance`, `isConnected`)
- **Variables**: snake_case for local variables, camelCase for member variables with trailing underscore (e.g., `status_`)
- **Constants**: UPPER_SNAKE_CASE
- **Namespaces**: lowercase (e.g., `fh::sim`, `fh::sim::math`)

### Code Style
- Use `const` and `constexpr` where appropriate
- Prefer `nullptr` over `NULL`
- Use smart pointers (`std::unique_ptr`, `std::shared_ptr`) for ownership
- Mark single-argument constructors as `explicit` to prevent implicit conversions
- Use `noexcept` for functions that don't throw exceptions
- Delete copy constructors/assignment operators when appropriate (e.g., singletons)

### Object-Oriented Design
- Organize code into classes with clear responsibilities
- Use access specifiers (`public`, `private`, `protected`) to enforce encapsulation
- Prefer composition over inheritance when appropriate
- Use virtual functions for polymorphic behavior
- Apply SOLID principles:
  - **S**ingle Responsibility: Each class should have one reason to change
  - **O**pen/Closed: Open for extension, closed for modification
  - **L**iskov Substitution: Derived classes should be substitutable for base classes
  - **I**nterface Segregation: Many specific interfaces are better than one general-purpose interface
  - **D**ependency Inversion: Depend on abstractions, not concretions

### Headers
- Use include guards or `#pragma once`
- Forward declare when possible to reduce compilation dependencies
- Include order: system headers, third-party headers, project headers

### Error Handling
- Use exceptions for exceptional conditions
- Return error codes or status objects for expected failures
- Document error conditions in function comments

### Controllers and Routing

- Controllers live in `backend/src/controllers/` and inherit from `Controller`.
- Register controllers in `HttpServer::setupRoutes()` in `backend/src/main.cpp`.
- Return JSON with `Response::json(string)`.
- Implement each feature with dedicated classes at the appropriate boundary:
  controller, service, model, repository, or parser.

### LeagueApps Membership Source Of Truth

LeagueApps is the only authority for who is a member. The database is a cache of
LeagueApps, never the source of truth.

Every endpoint that renders anything derived from LeagueApps membership state
must do this on every request:

1. Call `LaProgramSync::run(programId)` for every LeagueApps program the response
   depends on.
2. Let `LaProgramSync` upsert persons, aliases, memberships, and close open
   memberships that LeagueApps no longer returns.
3. Query Postgres after the sync.
4. Render from the database result, not from the in-memory LeagueApps response.

A LeagueApps registration counts as membership only when `registrationStatus` is
`SPOT_RESERVED`, `SPOT_PENDING`, or `WAITING_LIST`. All other statuses are not
memberships.

For LeagueApps-dependent routes, register through `Controller::laGet`,
`laPost`, `laPut`, or `laDel`, not bare router methods. Use static program lists
when the route is scoped to one category, and dynamic resolvers such as
`Controller::allLaProgramIds()` when the handler depends on request parameters or
cross-category data. Handlers should use `Response handleName(const Request&,
const LaSyncMap&)`.

Do not:

- Shape response cards directly from `LeagueAppsService::fetchProgramRegistrations`.
- Filter active members based on pickup membership, or the reverse.
- Cache LeagueApps snapshots on controller/model singletons.
- Implement client-side-only tab switching for LeagueApps-derived lists.
- Read `person_la_memberships` without a preceding sync in the same response
  path.
- Trust `is_pool`, `is_pickup`, `is_member`, or other DB booleans as the
  membership authority.

Run `make check-la-sync` before deploying backend changes that touch membership
paths. `make deploy` runs the same check.

## Simulation (`sim/`)

- Treat `sim/README.md` as the local entrypoint map.
- Treat `sim/DESIGN.md` as the active simulator design and roadmap.
- Keep gameplay deterministic: same seed plus same inputs must produce
  byte-identical state across machines.
- Use C++20 and the existing interface-heavy design. Do not introduce a game
  framework.

### Fixed-Point Math
- Use `math::Fixed64` for deterministic calculations
- Q32.32 format (32 bits integer, 32 bits fractional)
- Avoid floating-point arithmetic in simulation core

### Entity Management
- Entities identified by `EntityId`
- Use `SlotId` for player slot assignments
- Keep state in `EntityState` struct

### Enums
- Use `enum class` for type safety
- Specify underlying type (e.g., `std::uint8_t`) for wire protocol compatibility

### Simulation Validation

- Run `sudo make sim-deploy` for simulator slices that affect runtime behavior,
  registries, determinism, or container packaging.
- Keep registry migrations and `sim/src/common/M0Registry.generated.hpp` in sync.
- Golden hashes should change only when behavior intentionally changes; update
  the relevant design note when rotating a golden.

## Frontend (`frontend/`)

- The frontend is a vanilla JavaScript SPA. Do not introduce React, Vue, Angular,
  or framework-specific patterns.
- Screens should extend the existing `Screen` class pattern in
  `frontend/js/screens/`.
- Navigation should use the existing navigation/state-machine abstractions, not
  direct `window.location` changes.
- Do not add browser caching. Login localStorage for token/user is the only
  allowed persistent browser state unless a future convention explicitly changes
  this.

### JavaScript
- Use ES6+ features (classes, arrow functions, const/let)
- Prefer `const` over `let` when variables won't be reassigned
- Use meaningful class and function names
- Keep DOM manipulation separate from business logic

### Object-Oriented Design
- Use ES6 classes for organizing code
- Encapsulate related data and behavior in classes
- Use constructor functions for initialization
- Leverage inheritance with `extends` when appropriate
- Keep methods focused and cohesive

### State Machines
- **Use state machines for screen navigation** (see `NavigationStateMachine`)
- Use state machines for complex workflows and UI flows
- Apply state machine pattern when:
  - Multiple states with defined transitions
  - State-dependent behavior
  - Need to track history or context across states
- Benefits:
  - Clear state transitions
  - Easier to reason about application flow
  - Simplified testing of state-dependent logic

### File Organization
- Group related functionality into modules
- Use clear directory structure

## Database

- PostgreSQL is the database. Schema and data changes are raw SQL.
- Bootstrap SQL lives in `database/data/` and is loaded alphabetically on fresh
  builds.
- Live-preserving schema changes require a migration in `database/migrations/`
  and a matching update to `database/data/00-schema.sql`.
- League website data is regenerated and loaded via the idempotent scraper,
  parser, curation, and UPSERT pipeline.

### Schema Design
- **Normalize database schemas** following normal forms (1NF, 2NF, 3NF)
- Eliminate redundant data
- Use foreign keys to maintain referential integrity
- Create junction tables for many-to-many relationships
- Avoid data duplication across tables

### Connection Management
- Use connection pooling via `Database` singleton
- Call `warmPool()` during initialization
- Handle connection failures gracefully

### League Data Pipeline

- Per-league configuration lives in
  `database/scripts/leagues/<continent>/<country>/<league>/config.json`.
- `make sync-<league>` is the normal idempotent path: scrape, parse, curate,
  and load.
- Cross-league curation reads SQL files on disk, not the database.
- SQL file numbering per league:
  - `100`: organizations
  - `101`: clubs
  - `102`: teams
  - `103`: division-team assignments
  - `104`: standings
  - `105`: players
  - `106`: matches
  - `107`: rosters
  - `108`: event players
  - `109`: match events
  - `900`: curation updates

## HTTP

### Response Handling
- Use `Response` class for HTTP responses
- Set appropriate status codes
- Include standard headers (Server, Connection)
- Use `HttpClient` for external requests

## Testing

- Write unit tests for new functionality
- Test edge cases and error conditions
- Keep tests isolated and repeatable

## Documentation Maintenance

- Document public APIs and non-obvious design decisions.
- Keep active plans current enough that the next implementation slice is obvious.
- Move stable, cross-cutting rules from design docs into this document.
- Do not duplicate long rules across README files, design docs, and AI
  instructions. Link to the canonical owner instead.

## AI Workflow

- Start from the smallest relevant context set. Prefer the local subsystem README
  or design doc over broad repo exploration.
- For simulator work, start with `sim/README.md`, then `sim/DESIGN.md`, then the
  directly touched source and test files.
- For LeagueApps membership work, start with this document's membership section,
  then `backend/src/core/Controller.*`, the target controller, and
  `scripts/enforce-la-sync.sh`.
- For frontend screen work, start with `frontend/js/app.js`, the target screen,
  and adjacent screen classes.
- For setup/deploy work, start with `setup.sh`, `scripts/setup/`, `build.sh`,
  `Makefile`, and `docker-compose.yml`.
- After substantive edits, run the narrowest executable validation that can
  falsify the change before expanding scope.

## Version Control

- Write clear commit messages
- Keep commits focused on single changes
- Reference issue numbers when applicable
- Do not stage or commit unrelated user changes.
- Prefer follow-up correction commits over history rewriting after a push.

---

**Note**: This is a living document. Update it as new conventions are established or existing ones evolve.
