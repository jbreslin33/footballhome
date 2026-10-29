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
| `sportsengine` | CASA Select Philadelphia, Lancaster, North Jersey, Central Jersey — standings computed from each season's games (mig 823) | backend |
| `root_soccer` | MIPSL — rows stream in lazy Next.js chunks, browser only | `scripts/pyramid-chrome-sync.js` (hourly timer) |

No source yet: CASA MA (SportsEngine — find its season page's program id,
as for the other CASA regions), MMSL (no public tables found). Those show as
"tables not mirrored yet" boxes.

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

## Flow chart (mig 823)

Owner 2026-10-29: "i want the conference shown in a container with
relegation and playoff spots in red and green. then under it are the feeder
leagues connected by arrows like a flow chart."

- The unit is a **table**. `pyramid_links` (mig 827, was `pyramid_flows`):
  ONE row per link between an upper level (a conference, or a table) and a
  lower table, keyed by source + table name (names survive a new season,
  feed ids don't). A link carries both directions — `promotes` (up) and
  `relegates` (down). Delaware River has four links below it, so it
  relegates one-to-many; North Jersey Liga 1 links into Delaware River AND
  Metropolitan. No link above = nothing to promote into (every APSL
  conference today).
- `pyramid_zone_kinds` (mig 827): what a zone IS — label, colour, and
  `moves` up / down / NULL (APSL playoff spots go to the national playoffs,
  not another table). A kind a feed introduces is recorded with the feed's
  label + colour, moving nowhere until a row says otherwise.
- `pyramid_zone_moves` (view): where each zone's teams go — up-zones up the
  table's promoting links, down-zones down every relegating link. The page's
  row tooltip reads it ("Relegation → CASA Central Jersey · Liga 1, …").
- `pyramid_zone_rules` (mig 828): DEFAULT spots for every table (owner:
  "that should be default for all divisions conferences etc. but then those
  that differ we can edit over time") — down: 12th relegation, 11th
  relegation playoff (a spot past the table's end doesn't exist); up (any
  table with a promoting link): 1st auto promotion, 2nd–5th promotion
  playoff (mig 834, owner: "do same for all feeders all over" — mig 828's
  feeder-count split dropped). A row
  naming a table OVERRIDES that direction for it; kind NULL = none that way.
  `pyramid_zones_effective` = rule zones + the source's marks for what the
  rules don't decide (APSL's playoff places). Edited on the page: ✏️ on any
  table → Default / None / This table's own, per direction →
  `POST /api/pyramid/zone-rules` (club admins).
- Group splits come from the feed's `teams[].conference` — Delaware River
  A/B, Cosmo Division 2 A/B — and links name the group tables.
- `pyramid_division_zones` = coloured places per table, as the source states
  them. APSL's feed carries the league office's marks (`promotion_rules`,
  current season): playoff (green), relegation playoff (light red),
  relegation (red). A TeamPass conference played in groups (Delaware River
  A/B, `teams[].conference`) becomes one table per group, `ext_id`
  `817:Group A`. CASA/feeder zones: none yet (no source states them).
- Page (`frontend/js/screens/apsl-pyramid.js`): pills — All + one per
  conference, each toggles. ONE chart: the conferences side by side on the
  top row (order = `pyramid_competitions.sort_order`), each feeder level in
  the rows below under the conference it feeds; a shared table sits once
  with a link to each. Arrows = an SVG overlay measured from the laid-out
  boxes: head up = promotes, head down = relegates.

Rule directions (mig 835): `up`, `down`, and `stay` (places whose teams
don't move to another table — a playoff). `applies_to` picks the tables a
default is for: `all` (down: 11th relegation playoff, 12th relegation),
`feeder` (has a promoting link up: 1st auto promotion, 2nd–5th promotion
playoff) or `top` (nothing above — the APSL conferences: 1st–4th playoff).
`expires_on` (mig 836) ends a row after a date: Delaware River Group A / B
2026/27 only — 1st–2nd playoff, 7th relegation playoff, 8th relegation.
The ✏️ editor has all three sections; an edit keeps the rows' expiry.

Route (mig 833, another session): `#apsl` is the APSL hub; the pyramid is
`#apsl-pyramid` (hub tile "Pyramid & tables").

Colours (mig 832, owner): auto promotion green, any promotion playoff
yellow, relegation playoff orange, relegation red, everything else white —
`pyramid_zone_kinds.color`; a kind a feed introduces comes in white.

Header + picker tile carry the root league's crest (`organizations.logo_url`
via `competitions[].logo_url` and `GET /api/pyramid/roots`). View pills:
Flow chart (built) · USA map · Club pathway · Standings · Growth by season
(greyed until built — `views[].built` in the screen).

## Views draw from ONE model (mig 842)

Owner 2026-10-29: "make sure they all draw from same source these are just
views."  `js/lib/pyramid-model.js` (`PyramidModel`) is built once from
`GET /api/pyramid` and owns everything derived: the layout (conference
columns, feeder levels, which table sits where), the links/arrows, zones and
their colours, counts, titles, and where a zone's teams go (`moveTargets`).
Views only draw it:

- `js/components/pyramid-flow-view.js` — `PyramidFlowView`, the flow chart.
- `js/components/pyramid-present-view.js` — `PyramidPresentView`, Prezi-style:
  the SAME chart (`flow.chartHtml`) on a zoomable stage. Click a box → fly to
  it; click a coloured row → follow it to where those teams go; wheel/pinch
  zoom, drag pan; ◀ ▶ / Play tour = overview, then each conference and its
  feeder levels in the model's order; full screen; far out = zone bands only.
- `js/components/pyramid-map-view.js` — `PyramidMapView` (mig 844): a dark US
  map (Leaflet 1.9.4 vendored in `frontend/vendor/leaflet/`, SRI-checked,
  loaded only when the view opens; OpenStreetMap tiles darkened in CSS) with
  a dot per club at its home ground — blue = has an APSL team, teal =
  feeder-only; a club whose league publishes no address sits at its
  league's point, dimmed + dashed. A label per conference: tap it → fly
  there, and that conference's chart (the same `flow.chartHtml`) appears
  under the map. Nothing covers anything (owner: "use arrows to bubble as
  its covering each other up … auto adjust so its all visible"): after every
  zoom/pan `_relayout()` places each conference bubble in the first free
  slot on a ring of candidates around its spot (never over another bubble or
  the zoom buttons; an off-screen conference sits on the edge in its
  direction) with a leader line + ring back to the spot; dots sharing one
  point fan out in a ring. Mig 850 (owner: "map full screen and the data as
  hud … overlay over map … transparency … slider"): the map fills the page
  (⛶ = browser full screen of `.mp-stage`, HUD and overlay included); the
  totals, dot legend, hint and located count float as a HUD; a conference
  opens its chart as an overlay (`.mp-ov`) with a see-through slider
  (remembered, `apsl-pyramid-map-ov`), ✕ / Esc to close; the fly-to frames
  the clubs in the part of the map the overlay leaves uncovered; bubbles
  keep clear of the HUD and the overlay. Club names beside the dots from
  zoom 7 (always for the picked conference), each on a free side of its dot
  or hidden (picked conference first, then APSL, then feeders). The picked
  conference's territory (mig 852, owner: "its really based on metro size
  … pretend your making the conferences from scratch based off population
  and distance"): COUNTIES — a county belongs to the conference whose
  nearest APSL club (`pyramid_club_conference`: only the conferences' own
  clubs draw borders, so a feeder feeding two conferences never moves one)
  is within `pyramid_territory_policy.reach_km` (100, ~an hour's drive) of
  the county's centre; nearer wins, so neighbours meet along county lines;
  a county no club reaches is open ground. `pyramid_county_overrides` sets
  one by hand. `GET /api/pyramid/territory?conf=` returns the counties as
  GeoJSON (drawn tinted, only the OUTER border outlined — an edge two of its
  counties share is inside), the population inside, and Sunday drive times
  (OSRM table — free-flow, no traffic — among the conference's APSL clubs:
  the furthest pair + the average over every pair; cached per club set in
  `pyramid_conference_travel`). HUD chip top-left.

  County data (not in git): `scripts/pyramid-counties-load.py` reads the
  Census county shapes (plotly's geojson-counties-fips.json) + Census
  county population estimates (co-est2023-alldata.csv) and upserts
  `pyramid_counties` — re-run when a new estimate year lands.
- `js/components/pyramid-path-view.js` — `PyramidPathView` (mig 845): pick a
  club (search box over the model's clubs); each of its teams' routes up the
  promoting links (`PyramidModel.upRoutes` / `routeSteps`) drawn top-down with
  the flow chart's tables, the club's rows outlined; two ways up = two routes
  side by side; "N step(s) up to the APSL". The pick is remembered.
- `js/components/pyramid-tables-view.js` — `PyramidTablesView` (mig 846):
  every table in the flow chart's order with full columns (the shared
  `tableHtml`, `opts.full`), then each conference's leagues' unlinked tables
  ("other tables"), then the root's cups; a find box narrows to a team's
  tables and marks its rows.
- `js/components/pyramid-growth-view.js` — `PyramidGrowthView` (mig 847):
  APSL sides by season, stacked by conference (the dataviz skill's
  eight-slot categorical set, validated on the app's dark surface #111827,
  colour fixed by conference order; former conferences fold into one grey
  series), a numbers table, then other leagues' seasons (Cosmo).

### Seasons (mig 847)

TeamPass feeds serve any past season (`?season=<id>`, listed in
`standings.season_list`). `PyramidSync::storeSeasons` re-counts the current
season from the feed just read and fetches each past season ONCE on a
background thread → `fh_pyramid_season_load` → `pyramid_seasons` +
`pyramid_season_divisions` (teams + the feed's club ids, tied to a
competition by feed id or by name). A conference that no longer exists is an
inactive `pyramid_competitions` row (Northeast, 2022–24, split into Mayflower
+ Constitution). A conference's size per season = DISTINCT clubs (Fall +
Spring tables list the same sides); a league's teams = team entries.
APSL: 36 → 39 → 46 → 76 → 81 sides (2022/23 → 2026/27).

### Where clubs are (mig 844)

`pyramid_clubs.venue_name / venue_address` = the club's home ground as its
league's feed names it: TeamPass — the location of most games the team hosts
(game → field → location); SportsEngine — the address of its home games. The
first venue a club is given sticks. `PyramidSync::geocodePending()` geocodes
on a background thread after a refresh, one Nominatim call a second
(`CarpoolRouting::geocode`, made public): the full address, else its town +
zip (`geocode_note` 'nominatim (town)'); a miss is stamped and not re-asked
until the address changes. A league's point (`PyramidModel.compPoint`) = the
middle of its placed clubs, else its geocoded region. First run 10/29: 128
exact, 50 town, 2 misses (typos in the feed), 81 with no published address
(ADASL, LISFL, MIPSL leagues).

The screen (`apsl-pyramid.js`) holds the model, the conference + view pills
and the ✏️ editor; it never lays anything out itself.

