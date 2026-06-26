# TODO

Running list of known issues and follow-ups. Newest items at the top.

## Bugs

- **`GET /api/divisions` returns 500** — `handleGetDivisions` runs a malformed
  query: `FROM clubs sd JOIN clubs c ON sd.club_id = c.id`. `sd` was clearly
  meant to be a `subdivisions` table (or join logic was changed and this query
  was never updated). Surfaced 2026-06-26 during DB normalization work but is
  pre-existing — not caused by migrations 067–069.
  - File: `backend/src/controllers/DivisionController.cpp` (search for
    `handleGetDivisions`)
  - Backend log: `column sd.club_id does not exist`

## Data hardening (deferred from 2026-06-26 audit)

These were on the audit list but skipped because the data isn't ready:

- **`persons.birth_date NOT NULL`** — 2250 rows currently NULL. Need a backfill
  plan (LA import? user prompts? leave as-is?) before tightening.
- **`persons.last_name NOT NULL`** — 4 rows NULL. Likely fixable; investigate
  those records, then add the constraint.
- **`mens_team_columns.internal_role` → FK lookup** — column does not exist on
  this table. The audit was wrong; re-audit where mens-team "role" actually
  lives (probably `mens_team_columns.mutex_group` or a different table) before
  deciding whether to normalize.

## Refactor follow-ups (Phase 1 leftovers)

- **`SocialController` media-upload curl encoders** — `httpGet`/`httpPost` now
  use `core/HttpClient`, but lines 892, 948, 999, 1415, 1807 still call
  `curl_easy_init` directly for multipart media uploads. `HttpClient` doesn't
  expose progress callbacks or multipart, so these were left alone. If
  `HttpClient` grows those features, migrate these too.
- **`SocialWriteCallback` static** — still used by the media-upload encoders
  above. Remove when those encoders are migrated.

## Notes

- Migrations are forward-only. To roll back 067/068/069 you must write 070+
  that re-adds the dropped columns. Don't edit applied migration files.
- `00-schema.sql` is the canonical fresh-install schema and is kept in sync
  with applied migrations — update both whenever schema changes.
