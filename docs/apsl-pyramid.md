# #apsl — the APSL pyramid (mig 819)

Owner 2026-10-29: "i want to build an apsl pyramid. with multiple views with
its feeder leagues and standings live … we want to show how big the apsl and
feeder system is. show keep club/team totals too."

## Tree

`pyramid_competitions` — APSL (root, `slug = 'apsl'`) → its conferences
(tier 1) → the **Affiliates – Tier 2** leagues listed at
apslsoccer.com/APSL/Affilates/ (tier 2). `parent_id` = what a node feeds.
The affiliates page does not say which conference each feeds; the parent was
read off the affiliate's region (CASA PA/NJ → Delaware River, Cosmo + LISFL →
Metropolitan, CASA MA → Mayflower, MMSL → Mid-Atlantic, MIPSL → Mitten,
ADASL → Terminus). Constitution, Trinity and Mid-Atlantic's Old Dominion side
list no affiliate. States: `pyramid_competition_states`.

## Live tables

`pyramid_sources` — where each league publishes, and in what shape:

| system | league(s) | read by |
|---|---|---|
| `teampass_json` | APSL (3841, every conference), Cosmo (3840) | backend, scraper proxy |
| `teampass_tables` | ADASL `/adasl/Tables/` | backend, scraper proxy |
| `demosphere` | LISFL (data rides in the page as JSON; URL carries the season) | backend |
| `league_fixtures` | CASA PA — computed from the scored fixtures we already sync | backend (SQL) |
| `root_soccer` | MIPSL — rows stream in lazy Next.js chunks, browser only | `scripts/pyramid-chrome-sync.js` (hourly timer) |

No source yet: CASA NJ, CASA MA (SportsEngine — add their program as a
`league_fixture_sources` row, then a `league_fixtures` pyramid source), MMSL
(no public tables found). Those show as structure with a link.

APSL's one feed covers all conferences: `pyramid_feed_divisions` maps the
feed's division ids to conference nodes (Mid-Atlantic = Chesapeake + Old
Dominion). An unmapped division hangs under the root — the cups.

Both writers go through **`fh_pyramid_load(source_id, divisions jsonb)`**:
upsert, retire what the read no longer lists, link clubs, stamp the source.
A read with no teams raises, so a broken parse never wipes a table.

The backend re-reads sources older than `max_age_minutes` on every
`GET /api/pyramid` (same on-open pattern as CASA fixtures and #film);
`?refresh=1` re-reads all.

## Counting

- **Teams** = live team rows in counted tables.
- **Clubs** = distinct `pyramid_clubs`, matched across leagues by
  `fh_pyramid_name_key()` ("Peachtree FC II" in ADASL = "Peachtree FC" in
  Terminus), and to our `clubs` row (or a `club_aliases` alias) when the key
  matches. Approximate by nature: a club spelled differently in two leagues
  counts twice.
- Not counted: the root's own tables (APSL cups — those teams are already in
  their conferences), and any division named in the source's
  `uncounted_divisions` (MIPSL's "APSL" table = the Mitten clubs).
- **Leagues** = APSL + affiliates. **States** = distinct states in the tree.

These tables are deliberately separate from `teams` (rosters, boards,
RSVPs) — the old `standings` table stays the scraper-era APSL table.

## Views (frontend/js/screens/apsl-pyramid.js)

Org chart · Pyramid (band width ∝ teams) · Standings. Tapping a box opens
that league's tables. Copy: `message_templates` kind `apsl_pyramid`.

Phase 2: map view — APSL venues carry street addresses in the TeamPass feed
(`locations`), to geocode once and store.
