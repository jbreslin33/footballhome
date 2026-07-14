# Handoff: Normalize `sim_player_profile` (close §22.14)

> **Status:** ready for pickup. Do NOT start until the currently-active
> sim work is committed — this touches `sim/DESIGN.md`, `sim/src/persistence/*`,
> and `sim/tests/*`, which are hot-editing surfaces.

## Motivation

`sim/DESIGN.md` §22.14 already flags this: BYTEA storage for player
attributes / concepts / recognition is opaque to Postgres, unenforceable at
the FK layer (the whole §22.9 registry-id-stability project exists to work
around this), and forces the `sim_decode_*` helpers in migration 201 just
to make ops queries possible.

**Goal:** normalize the *storage* while keeping the *wire format* identical.
`AttributeSet::toBytes/fromBytes` are still needed for per-tick snapshot
frames sent to the browser — nothing about the sim runtime or the wire
protocol changes. Only the DB boundary in `PgClient` / `InMemoryPgClient`
changes.

## Preconditions (verified 2026-07-13)

- `sim_player_profile`: **0 rows** → no data migration.
- `sim_matches`: 1 row → no cascading impact.
- Registries have explicit ids (§22.9 landed) → FKs work cleanly.

Before starting, re-verify:

```bash
sudo podman exec -i footballhome_db psql -U footballhome_user -d footballhome \
  -c "SELECT COUNT(*) FROM sim_player_profile;"
```

If non-zero, this handoff needs revision — write a data migration first.

## Schema — new migration `database/migrations/204-sim-normalize-profiles.sql`

```sql
BEGIN;

DROP TABLE IF EXISTS sim_player_profile;

CREATE TABLE sim_player_profile (
    person_id  BIGINT PRIMARY KEY REFERENCES persons(id) ON DELETE CASCADE,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE sim_player_attribute (
    person_id BIGINT   NOT NULL REFERENCES sim_player_profile(person_id) ON DELETE CASCADE,
    attr_id   SMALLINT NOT NULL REFERENCES sim_attribute_registry(id),
    value     REAL     NOT NULL,
    PRIMARY KEY (person_id, attr_id)
);
CREATE INDEX ON sim_player_attribute (attr_id);

CREATE TABLE sim_player_concept (
    person_id  BIGINT   NOT NULL REFERENCES sim_player_profile(person_id) ON DELETE CASCADE,
    concept_id SMALLINT NOT NULL REFERENCES sim_concept_registry(id),
    mastery    REAL     NOT NULL,
    PRIMARY KEY (person_id, concept_id)
);
CREATE INDEX ON sim_player_concept (concept_id);

CREATE TABLE sim_player_recognition (
    person_id  BIGINT   NOT NULL REFERENCES sim_player_profile(person_id) ON DELETE CASCADE,
    pattern_id SMALLINT NOT NULL REFERENCES sim_pattern_registry(id),
    skill      REAL     NOT NULL,
    PRIMARY KEY (person_id, pattern_id)
);
CREATE INDEX ON sim_player_recognition (pattern_id);

COMMIT;
```

## Code changes (persistence boundary only)

Nothing above `ProfileStore` moves. `PlayerProfile` / `AttributeSet` /
`ConceptSet` / `RecognitionSet` in-memory classes stay untouched.

1. **`sim/src/persistence/IPgClient.hpp`** — replace
   ```cpp
   struct ProfileBlob {
       std::vector<std::byte> attributes;
       std::vector<std::byte> concepts;
       std::vector<std::byte> recognition;
   };
   ```
   with
   ```cpp
   struct ProfileRows {
       std::vector<std::pair<std::uint16_t, float>> attributes;   // (attr_id,    value)
       std::vector<std::pair<std::uint16_t, float>> concepts;     // (concept_id, mastery)
       std::vector<std::pair<std::uint16_t, float>> recognition;  // (pattern_id, skill)
   };
   ```
   Update `loadProfile` / `upsertProfile` signatures to take `ProfileRows`.

2. **`sim/src/persistence/PgClient.cpp`** — swap prepared statements:
   - `loadProfile(person_id)`:
     - Single-row `SELECT 1 FROM sim_player_profile WHERE person_id=$1` to
       detect existence (returns `nullopt` if absent — preserves current
       "no row → materialize default" semantics in `ProfileStore::loadOrCreate`).
     - `SELECT attr_id, value FROM sim_player_attribute WHERE person_id=$1
        ORDER BY attr_id ASC` (and same shape for concepts, recognition).
     - `ORDER BY` is load-bearing for determinism.
   - `upsertProfile(person_id, rows)` — single transaction:
     - `INSERT INTO sim_player_profile (person_id) VALUES ($1)
        ON CONFLICT (person_id) DO UPDATE SET updated_at = NOW()`.
     - For each of the three child tables:
       `INSERT ... ON CONFLICT (person_id, X_id) DO UPDATE SET
        value/mastery/skill = EXCLUDED.value/mastery/skill`.
     - Then `DELETE FROM sim_player_attribute WHERE person_id=$1 AND
        attr_id NOT IN (…)` to preserve the current blob semantics of
       "replace the whole set." Same for concepts, recognition.

3. **`sim/src/persistence/InMemoryPgClient.cpp`** — mirror the
   `ProfileRows` interface. Internal storage can remain a map; only the
   external signature changes.

4. **`sim/src/persistence/ProfileStore.cpp`** — the encode/decode step
   moves out of `AttributeSet::toBytes/fromBytes` (which stays untouched)
   and into a direct row-loop:
   - On load: iterate `ProfileRows.attributes` → `set(AttrId(id),
     Fixed64::fromFloat(value))`. Same for concepts / recognition.
   - On save: iterate `AttributeSet::values()` → push
     `{static_cast<uint16_t>(id), Fixed64::toFloat(value)}` into
     `ProfileRows.attributes`. Sort by id ascending so the DB write order
     is deterministic (optional but keeps `pg_dump` diffs stable).

5. **`sim/tests/test_profile_store.cpp`** — rewire assertions from bytea
   equality to row equality.

6. **`sim/tests/test_pg_client_stub.cpp`** (and any other `IPgClient`
   fake in the test tree) — update signatures.

## Migration 201 (`sim_decode_*` helpers) — comment-only patch

Keep the functions — they still correctly decode **wire snapshot bytes**
(the codec `AttributeSet::toBytes` produces for the browser). Update the
`COMMENT ON FUNCTION` strings to say
`"Decodes an AttributeSet wire-snapshot bytea into (attr_id, key, category, value) rows"`
instead of referring to `sim_player_profile.attributes`. Same for concepts
and recognition.

## What must NOT change

- `AttributeSet` / `ConceptSet` / `RecognitionSet` in-memory classes.
- `toBytes()` / `fromBytes()` — still the wire snapshot codec. Only DB
  storage normalizes.
- `Fixed64` boundary: `fromFloat` at DB load, `toFloat` at DB save. Same
  as today, just once per row instead of once per blob.
- Determinism story: rows loaded `ORDER BY attr_id ASC` reproduce
  byte-identical `AttributeSet` state on every replica. Add a comment on
  each `SELECT` making this contract explicit.
- BYTEA storage for `sim_match_inputs` / `sim_match_events` —
  correctly stored as blobs (immutable wire audit records).

## DESIGN.md updates (~50 lines across 6 sections)

- **§3 principle 7** — soften: *"Attributes are string-keyed and grow on
  demand. Adding an attribute is a registry insert + code that reads it
  — no `ALTER TABLE` on profile storage."* Drop the "zero DB migration"
  framing (misleading — we now embrace normalized rows precisely because
  ALTER TABLE isn't a real concern at this scale).
- **§4 architecture diagram** (line 74) — replace
  `sim_player_profile (bytea)` with the four table names.
- **§8 schema block** — replace the `sim_player_profile CREATE TABLE`
  with the 4-table version above.
- **§8.1 decode helpers preamble** — clarify they decode wire snapshot
  bytes, not profile storage.
- **§16.6 `ProfileStore` bullet** — reads/writes rows via `IPgClient`,
  not bytea.
- **§22.14 backlog** — mark **closed** with a reference to migration 204
  and this handoff doc.

## Verification path

```bash
# 1. Apply migration
sudo make migrate

# 2. Confirm schema
sudo podman exec -i footballhome_db psql -U footballhome_user -d footballhome \
    -c "\d sim_player_profile" \
    -c "\d sim_player_attribute" \
    -c "\d sim_player_concept" \
    -c "\d sim_player_recognition"

# 3. Build + test sim
cd sim && ./build.sh   # or whatever the sim's build entry point is
# run persistence + profile tests

# 4. Boot sim daemon, run one match, confirm rows populate
sudo podman exec -i footballhome_db psql -U footballhome_user -d footballhome \
    -c "SELECT p.first_name, r.key, a.value
        FROM sim_player_attribute a
          JOIN sim_attribute_registry r ON r.id = a.attr_id
          JOIN persons p ON p.id = a.person_id
        ORDER BY p.id, a.attr_id
        LIMIT 20;"

# 5. Determinism regression check: same seed + same inputs must produce
#    the same MatchEnd snapshot hash as before the refactor.
```

## Scope

1 new migration (~60 lines) + comment tweak in migration 201 + ~150 lines
across 4 sim source files + ~40 lines test updates + ~50 lines
`sim/DESIGN.md`. All contained in `sim/` + `database/migrations/`. Zero
data migration. Contained blast radius.
