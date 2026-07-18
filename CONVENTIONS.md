# Coding Conventions

This document describes the coding conventions and best practices for the FootballHome project.

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

## Simulation (`sim/`)

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

## Frontend (`frontend/`)

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

## Documentation

- Document public APIs
- Explain non-obvious design decisions
- Keep this CONVENTIONS.md file updated as patterns evolve

### Documentation Hierarchy

- `CONVENTIONS.md` is the canonical home for cross-cutting project rules:
  architecture constraints, coding style, terminal discipline, source-of-truth
  boundaries, setup expectations, and AI workflow guidance.
- Do not create competing convention files. If another file contains lasting
  project-wide rules, migrate the rule here and leave only a pointer from the
  old location when a tool requires that file to exist.
- `.github/copilot-instructions.md` is an AI transport file, not a second source
  of truth. It should point agents toward this document and only duplicate the
  smallest bootstrap rules needed before an agent can read more context.
- `README.md` is for orientation and quickstart commands, not detailed coding
  rules or long-term design plans.
- Subsystem plans belong beside the subsystem. Use `DESIGN.md` inside the owned
  directory when a part of the codebase has an active roadmap or design record,
  for example `sim/DESIGN.md` for the simulator.
- Cross-cutting designs that do not belong to a single subsystem go in `docs/`
  with a specific name such as `calendar-design.md`.
- Lasting architectural decisions should be short, dated records under
  `docs/adr/` if they affect multiple systems or are likely to be revisited.
- Avoid one giant root design document. It makes AI context worse because every
  task pays for unrelated history, and it makes ownership unclear.

### Planning Documents

- Prefer `<subsystem>/DESIGN.md` for an active plan, roadmap, or technical spec
  tied to one directory.
- Prefer `docs/<topic>-design.md` for a design that spans multiple directories.
- Prefer `docs/adr/YYYY-MM-DD-short-title.md` for a decision that should not be
  rewritten as the implementation evolves.
- Keep plans close to code entrypoints and include a short "load these first"
  section when a subsystem has a predictable AI context set.
- Move completed implementation details out of active plans when they become
  stable conventions; keep only the decisions and current next steps.

## Terminal Commands

- **Show full output when running commands** - don't use `tail` or other output-limiting tools
- Display complete logs and results for debugging and verification
- Use verbose flags when available to see detailed operation progress

## Version Control

- Write clear commit messages
- Keep commits focused on single changes
- Reference issue numbers when applicable

---

**Note**: This is a living document. Update it as new conventions are established or existing ones evolve.
