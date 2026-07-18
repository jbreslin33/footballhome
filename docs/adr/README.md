# Architecture Decision Records

Use this directory for durable architecture decisions that affect multiple
subsystems or are likely to be revisited.

## Filename

Use:

```text
YYYY-MM-DD-short-title.md
```

Example:

```text
2026-07-18-leagueapps-membership-source-of-truth.md
```

## Template

```markdown
# Title

Date: YYYY-MM-DD
Status: Proposed | Accepted | Superseded

## Context

What problem or constraint forced this decision?

## Decision

What are we doing?

## Consequences

What becomes easier, harder, or explicitly out of scope?

## Links

- Related code, design docs, migrations, or follow-up work.
```

Keep ADRs short and append-only. If a decision changes, add a new ADR and mark
the old one superseded.