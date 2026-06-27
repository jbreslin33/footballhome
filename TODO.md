# TODO

Running list of known issues and follow-ups. Newest items at the top.

## Bugs

(none currently tracked)

## Data hardening (deferred from 2026-06-26 audit)

These were on the audit list but skipped because the data isn't ready:

- **`persons.birth_date NOT NULL`** — 2250 NULL / 882 with DOB (~28% coverage).
  Source survey: only ~61 unique DOBs are available from scrape sources
  (33 APSL via `database/scraped-html/apsl/apsl-dobs-116079.json`, 30 CASA via
  `database/scraped-html/casa/roster-data.json`). Live DB coverage:
    - 2248 of 2250 NULL persons have player records (scraped from public
      league pages that don't expose DOB)
    - 2 have LeagueApps aliases (LA import won't help materially)
    - 1 has a user account; 0 are on active rosters

  **Plan: leave `birth_date` NULLable on `persons` permanently.** Existing
  backfill pipelines are sufficient for the leagues we *can* scrape:
    - CASA: `database/scripts/leagues/north-america/usa/casa/sql/105.00002-players-casa.sql`
      uses `INSERT … ON CONFLICT … birth_date = COALESCE(EXCLUDED.birth_date, persons.birth_date)`.
    - APSL: one-off `database/data/105b-dobs-apsl.sql` regenerated from
      authenticated TeamPass scrape.

  If we want NOT NULL guarantees, enforce them where DOB *matters*
  (e.g. youth roster eligibility checks) via partial indexes or CHECK
  constraints on the join tables, not on `persons`.
- **`persons.last_name`** — column is already `NOT NULL`. Audit was wrong about
  NULL; the 4 rows have `last_name = ''` (empty string), not NULL. Records:
  - id 22218 'Musa' — likely dup of 1359 'Musa Donza'
  - id 22223 'Gian' — likely dup of 14454 'Gian Maldonado'
  - id 22245 'Karim' — likely dup of 1315 'Karim Russell' (only other Karim)
  - id 22233 'Dylan' — ambiguous (12+ existing Dylans)

  All 4 were imported 2026-05-26 (probably scraper stubs), have no users/
  emails/phones/match-events/lineups, and all current rosters were ended
  2026-06-25. Three are merge candidates; Dylan needs human disambiguation.
  Not auto-merged because `PersonMerge` doesn't reparent `rosters` (player_id
  CASCADE-deletes historical roster entries when the orphan player is
  dropped). If those rosters don't matter, run `PersonMerge::merge(kept,
  dropped)` for the 3 confident cases via `PersonMergeController` and then
  delete person 22233 if Dylan can't be resolved. If we want a stronger
  constraint, add a `CHECK (length(btrim(last_name)) > 0)` after cleanup.
- **`mens_team_columns.internal_role` → FK lookup** — column does not exist on
  this table. The audit was wrong. Re-audit complete: the closest concept is
  `mens_team_columns.mutex_group` (free-form TEXT identifier used to enforce
  "at most one of these columns per player" — see migration 050). It currently
  has only one non-NULL value (`'grassroots-country'`, used by Brazil and
  Puerto Rico). Not worth normalizing into a lookup table while there's a
  single group in use; revisit if more mutex groups are added.

  (Note: legacy `players.internal_role` was added by migration 031 and dropped
  by migration 039; the EligibilityController still exposes an `internal_role`
  field in its JSON output, but it's derived from `coach_assessments.status`,
  not a column.)

## Refactor follow-ups (Phase 1 leftovers)

- ~~**`SocialController` media-upload curl encoders**~~ — DONE (2026-06-26).
  All 10 direct `curl_easy_init` sites removed. The 6 "media-upload encoders"
  turned out to be URL-encoders only (calling `curl_easy_escape` via a local
  `urlEncode(curl, str)` helper), not multipart uploads — these were replaced
  with `HttpClient::urlEncode()`. The 4 actual HTTP calls (`refreshGoogleToken`,
  `handleListDriveMedia`, `handleDownloadDriveFile`, `handleLogoProxy`) now use
  `HttpClient::get`/`postForm`. No multipart or progress callbacks were ever
  needed; the prior note was based on a misread of the code.
- ~~**`SocialWriteCallback` static**~~ — DONE. Removed alongside the encoders.
- `#include <curl/curl.h>` and the local `urlEncode(CURL*, ...)` member have
  been removed from `SocialController.{h,cpp}`.

## Notes

- Migrations are forward-only. To roll back 067/068/069 you must write 070+
  that re-adds the dropped columns. Don't edit applied migration files.
- `00-schema.sql` is the canonical fresh-install baseline. As of 2026-06-26
  it is generated from `pg_dump --no-owner --no-privileges` and contains
  full DDL + a data snapshot (including `schema_migrations` rows that mark
  001–069 applied). The original hand-written league/season/conference/
  division seed files now live in `database/data/legacy/`. To regenerate
  after applying new migrations, see the header comment at the top of
  `00-schema.sql`.
