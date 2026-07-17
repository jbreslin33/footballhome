# Football Home ↔ Google Calendar — design doc

**Status:** IN PROGRESS. Slices 0–6b landed on `main`; Slice 6a + 7 next.
**Last updated:** 2026-07-17.
**Owner:** jbreslin / Football Home.

---

## 0. RESUME HERE (2026-07-17 EOD)

Where we are and exactly what to do tomorrow. Read this before touching
anything else — it will save you from re-deriving what's already known.

### 0.1 What landed today (Slice 6b)

Roster-gated RSVPs via a description DSL. Ops now writes
`Team:` / `Club:` tags into the gcal event description; the classifier
resolves them to a `teams[]` set via `gcal_team_aliases` and attaches
them to `fh_events` through the new `fh_event_teams` junction. Backend
enforces "must be on at least one attached team's roster" on POST; GET
returns `teams[]`, `my_rsvp_eligible`, `hangout_link`. Frontend renders
team chips + a 5-branch RSVP block (signed-out / no-roster /
not-eligible / open / countdown).

- Migration `121-gcal-team-aliases-and-junction.sql` — applied.
- Classifier `scripts/gcal-classify.js` — DSL Pass A + legacy Pass B
  are disjoint via `Team:` exclusion; 1451 events reclassified.
- Backend `CalendarController.cpp` — deployed.
- Frontend `frontend/js/screens/calendar.js` — deployed.
- Full spec in §6.1.5. Wire-level behaviour in §10.2.
- `fh_events.team_id` DROPPED. Junction is 3NF source of truth.

### 0.2 Tomorrow's smallest useful batch (W1 + W2 + W3)

Do these first — they're independent, all small, and W2 in particular
unblocks the whole "user retrofits gcal → RSVPs auto-open in 5 min"
loop that Slice 6b assumes but is not currently happening.

**W1 — Doc sync (already done in this commit).** §13 has a Slice 6b
row; this §0 exists; timestamp bumped. Nothing to do tomorrow.

**W2 — Install the gcal-sync systemd timer.** The units live in
`/srv/footballhome/systemd/gcal-sync.{service,timer}` but are NOT
installed on the host — `systemctl list-timers | grep gcal` returns
nothing. That's why today's classifier run picked up
`insert=1245 update=207` on the ops calendar: sync hadn't run in
weeks. Fix:

```bash
sudo ln -sf /srv/footballhome/systemd/gcal-sync.service /etc/systemd/system/gcal-sync.service
sudo ln -sf /srv/footballhome/systemd/gcal-sync.timer   /etc/systemd/system/gcal-sync.timer
sudo systemctl daemon-reload
sudo systemctl enable --now gcal-sync.timer
systemctl list-timers gcal-sync.timer --no-pager
```

Verify next run within 5 min; `journalctl -u gcal-sync.service -n 100
--no-pager` should show sync+classify output. `scripts/setup/setup-gcal.sh`
should idempotently do all of this — worth checking whether the script
exists and just wasn't run, vs needs writing.

**W3 — Seed aliases for Women / Boys / Girls.** `gcal_team_aliases`
today has 8 rows, all `club_alias='mens'`. Any DSL like
`Club: Women`, `Club: Boys`, `Club: Girls` will resolve to zero teams
today and land in `classifyDsl`'s `missingClub` bucket. Add a
migration `122-gcal-aliases-women-boys-girls.sql` that mirrors the
`mens` seed. Need real team_ids first — look them up:

```sql
SELECT id, name, gender_category
  FROM teams
 WHERE gender_category IN ('womens','boys','girls')
   AND (is_pool = true OR name IN ('Pickup','Practice','Adult'))
 ORDER BY gender_category, id;
```

Mirror the mens 8-row shape per category:
`(club_alias, team_alias) = (<cat>, apsl | liga 1 | liga1 | liga 2 |
liga2 | adult | practice | pickup)` with matching team_ids. Skip any
tuple that has no real team on the DB side — better silent-unresolved
in the classifier report than a fake FK.

### 0.3 Then Slice 6a (biggest — see §13)

Schema `fh_recurring_rsvps` already exists (migration 119). Rebuild
plan in §13 6a row plus below. Do NOT do the "backfill for regulars"
step — cross-doc directive: users opt in themselves via the profile
toggle. If the toggle isn't compelling enough that regulars discover
it, that's a UX problem to fix, not a data-migration problem to
work around.

Order for tomorrow, once W1–W3 land:
1. `GET /api/calendar/my-standing` + `POST /api/calendar/my-standing`
   in `CalendarController`. Upserts one row per
   `(person_id, kind, category)` with `active` boolean.
2. `scripts/gcal-rsvp-apply-standing.js` — pure worker, no HTTP. Join
   `fh_events` (rsvps_open_at ≤ now AND standing_applied_at IS NULL)
   → `fh_event_teams` → `player_rsvp_eligibility` → `fh_recurring_rsvps`
   (active AND matching kind + (category OR NULL)). Upsert
   `fh_event_rsvps` with `created_via='standing'`, then stamp
   `fh_events.standing_applied_at = now()`. Idempotent — safe to
   re-run.
3. `systemd/gcal-rsvp-apply-standing.{service,timer}` — 5 min cadence,
   independent of gcal-sync (they touch different tables and different
   locks; running in parallel is fine).
4. Frontend: profile-screen toggle grid `(kind × category)`. Bind to
   `/api/calendar/my-standing`. Show a per-card "Auto-registered via
   your standing pref" pill on calendar cards where
   `my_rsvp_created_via = 'standing'` (backend must add that column
   to `GET /api/calendar/upcoming` first).

### 0.4 Then Slice 7 (data migration — legacy pickup RSVPs)

Discovered state (see §13 Slice 7 row for detail): "pickup" today
lives on `matches` rows with `match_type_id=7`, with RSVPs in
`player_rsvp_history` (360 rows) and standing prefs in
`player_recurring_rsvps` (129 rows, keyed on day_of_week+match_type).
There is NO dedicated "pickup" table to drop.

One-shot copy scripts (see 6a §13 row) — do NOT drop the legacy
tables, they still hold real-match RSVPs. Just stop dual-writing to
them for pickup once the frontend repoint is deployed.

### 0.5 Then Slice 8 (unclassified queue)

Classifier currently reports 14 unresolved "Soccer …" summaries
(mostly youth practice + a couple of intra-squad games). Decision
(2026-07-17): SKIP the admin UI. Add
`scripts/gcal-unclassified-report.js` that mails jbreslin@ weekly with
the list. Ops resolves each by adding DSL tags in gcal — that's the
source of truth per §6.1.5, not an FH admin form. If the volume grows
past ~50/week we'll revisit.

### 0.6 Traps re-learned today (don't step on tomorrow)

- **`teams.name`, not `teams.display_name`.** The `SELECT` in
  `CalendarController::handleGetUpcoming`'s `teams_json` subquery
  was written as `t.display_name` and 500'd until fixed. When you
  wire the Slice 6a profile toggle, if you `SELECT` from teams,
  use `name`.
- **Rootful podman means `sudo` on everything.** `podman ps` without
  sudo returns empty. `make shell-db` without sudo fails. Set your
  shell aliases and stop losing 30s per command trying to
  understand why the container "doesn't exist".
- **The 148-migration runner is slow (~30-45s to reach a new file).**
  This is not broken; it's per-file existence-checking through slow
  podman exec. Wait it out. `ps auxf | grep run-migrations` confirms
  it's alive.
- **The gcal `singleEvents: true` expansion.** Every recurring
  instance is its own row in `gcal_events`. When ops edits the
  Saturday pickup DSL description, they MUST use "This and following
  events" (not "This event only") or only one instance updates.
  This is a training issue, not a code issue.
- **Container names conflict on rebuild.** `podman-compose up -d`
  after a build can't recreate a container whose name is already
  in use; workaround is `podman rm -f footballhome_backend
  footballhome_frontend footballhome_leagueapps_sync` then
  `podman-compose up -d`. There's probably a `--force-recreate`
  equivalent worth digging up so `make build` does this cleanly.

### 0.7 Off-limits drift on disk (2026-07-17 EOD)

None. `git status` clean after today's Slice 6b commit + this §0
resume-note commit.

---

## 1. Why this exists

Coaches and ops staff already live in Google Calendar. Football Home (FH)
wants to be the place coaches see their next practice, know who's coming,
manage the lineup, chat with the team, and (later) run the match. Rebuilding
scheduling inside FH creates two sources of truth — a guaranteed way for the
website and reality to drift.

So gcal stays authoritative for *when* and *where*, and FH adds everything
gcal cannot: rosters, RSVPs, attendance, lineups, chat, match reports,
stats. Every FH-side asset hangs off a stable gcal event ID.

Analogous to how LeagueApps is authoritative for membership (see
[`/memories/repo/membership-source-of-truth.md`](../.github/copilot-instructions.md)
for the strict rule) — but with one important difference: unlike LA, gcal
events do NOT need to be re-fetched on every FH request. They churn over
minutes, not seconds. See §4.

### 1.1 The hard rule

> **No event may exist in FH that does not first exist — and continue to
> exist — in the Soccer calendar or the Ops calendar.**

Corollaries:

- FH never calls `events.insert`. Anywhere. Any "create event in FH" UI
  is forbidden. Coaches create the event in Google Calendar first; FH
  picks it up on the next poll (≤5 min).
- If a gcal event is deleted/cancelled, FH tombstones its mirror row.
  Anything hanging off it (RSVPs, attendance, chat) is *preserved for
  audit* but hidden from users. This is the safe default because
  Google might briefly return `status=cancelled` for a rescheduled
  instance before the new instance appears — we don't want to lose
  RSVPs to a race.
- If a gcal event *reappears* (a coach clicks Undo, or the poller
  saw a false-positive cancellation), FH clears the tombstone and
  the RSVPs come back with it.
- No "orphan" FH data. An `fh_events` row without a live
  `gcal_events` parent is a bug and should surface on the admin
  health page.

---

## 2. Two calendars, two roles

| Calendar | Google ID | SA access | Role |
|----------|-----------|-----------|------|
| Soccer | `soccer@lighthouse1893.org` | *Make changes to events* (writer) | Everything internal to soccer — practices, film sessions, staff meetings. Includes facility-using events too. |
| Ops    | `sports@lighthouse1893.org` | *See all event details* (reader) | Every event at a Lighthouse facility, across the org. Booked by many departments; soccer is one of many voices. |

**Facility-using soccer events appear on BOTH calendars.** Ops is the
authoritative facility-booking log; Soccer duplicates it so coaches see
their own schedule without the noise of rodeos, barn rentals, etc.

FH must **never write to Ops**. This is enforced two ways:

1. The service account only has *See all event details* on Ops (write
   attempts return 403 at the API layer).
2. Backend code MUST NOT call `events.insert/patch/delete` with
   `GCAL_OPS_CALENDAR_ID`. This should be a lint rule / grep-check in CI
   once we have code.

---

## 3. What FH does not do

- FH does not become a scheduler. Coaches create events in Google
  Calendar. Full stop. (See §1.1.)
- FH does not push soccer events into Ops. Whoever created the event
  in Soccer is responsible for also adding it to Ops if it uses a
  facility (this matches current staff workflow).
- FH does not resolve conflicts between calendars. If Soccer and Ops
  disagree about a "same" event, FH shows both entries as-is; humans
  reconcile in gcal.
- FH does not delete RSVPs on its own initiative. Deletion of the
  underlying gcal event tombstones the FH mirror; RSVPs go with it
  (hidden, not deleted) so an accidental gcal delete + undelete
  preserves them.

---

## 4. Data flow: cached-mirror, not read-through

Unlike the LA membership rule (fetch-every-request), gcal is mirrored
into Postgres by a background poller and read from Postgres by every
request.

**Justification.** Membership changes affect legality and eligibility;
one-second staleness is unacceptable (someone dropped from LA must not
appear on the roster). Calendar events describe intent about a future
moment; five-minute staleness is invisible to users, saves ~1s per page
render, and keeps FH usable when Google is degraded.

```
                     Google Calendar (source of truth)
             ┌───────────────┐        ┌───────────────┐
             │   Soccer      │        │  Ops          │
             │ read + write  │        │ read only     │
             └────────┬──────┘        └──────┬────────┘
                      │                      │
                      ▼                      ▼
             ┌──────────────────────────────────────────┐
             │           gcal-sync worker               │
             │  (cron / systemd timer, every 5 min)     │
             │                                          │
             │  1. events.list(syncToken=<last>)        │
             │     ↳ incremental delta, per calendar    │
             │  2. UPSERT into gcal_events              │
             │  3. Mark deleted events tombstoned       │
             │  4. Persist new syncToken                │
             └───────────────────┬──────────────────────┘
                                 │
                                 ▼
                        ┌────────────────┐
                        │   Postgres     │
                        │   gcal_events  │
                        │   gcal_sync    │
                        └────────┬───────┘
                                 │
                                 ▼
                        ┌────────────────┐
                        │  FH backend    │
                        │  (reads only)  │
                        └────────────────┘
```

**Poll cadence.** Every 5 min via a `systemd .timer`, or via pg_cron
inside Postgres calling `NOTIFY` — TBD, but 5 min is the target.

**Incremental sync.** Use Google Calendar's `syncToken` mechanism so we
don't re-download the world each poll. First run: full paginated
`events.list()` → save `nextSyncToken`. Every subsequent run:
`events.list({ syncToken })` returns only what changed since. Google
occasionally invalidates the token (410 GONE); on that we do a full
re-sync.

---

## 5. Proposed Postgres schema

New file: `database/data/060-gcal.sql` (once we're ready to land it),
following the existing bootstrap numbering conventions.

```sql
-- Each calendar we sync from.  Two rows for now.
CREATE TABLE gcal_calendars (
    id           SERIAL PRIMARY KEY,
    google_id    TEXT NOT NULL UNIQUE,          -- e.g. soccer@lighthouse1893.org
    role         TEXT NOT NULL CHECK (role IN ('soccer','ops')),
    can_write    BOOLEAN NOT NULL,              -- read/write vs read-only
    display_name TEXT NOT NULL,
    time_zone    TEXT NOT NULL,
    last_synced_at TIMESTAMPTZ,
    sync_token   TEXT,                          -- Google incremental cursor
    created_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- One row per Google event (per calendar).  Same event mirrored to both
-- calendars => two rows here, linked heuristically by matching
-- (summary, start, end) if needed.
CREATE TABLE gcal_events (
    id               BIGSERIAL PRIMARY KEY,
    calendar_id      INT  NOT NULL REFERENCES gcal_calendars(id),
    google_event_id  TEXT NOT NULL,
    recurring_event_id TEXT,                    -- parent of recurring instance
    summary          TEXT,
    description      TEXT,
    location         TEXT,
    starts_at        TIMESTAMPTZ NOT NULL,
    ends_at          TIMESTAMPTZ NOT NULL,
    all_day          BOOLEAN NOT NULL DEFAULT false,
    status           TEXT NOT NULL,             -- confirmed | tentative | cancelled
    html_link        TEXT,
    hash             TEXT NOT NULL,             -- content hash for change detection
    raw              JSONB NOT NULL,            -- full API payload for forward compat
    first_seen_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
    last_seen_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
    deleted_at       TIMESTAMPTZ,               -- tombstone when Google says cancelled
    UNIQUE (calendar_id, google_event_id)
);
CREATE INDEX gcal_events_starts_at_idx ON gcal_events (starts_at);
CREATE INDEX gcal_events_calendar_starts_idx ON gcal_events (calendar_id, starts_at);

-- FH-specific data hanging off a gcal event.  One-to-one with gcal_events.
-- Rosters / RSVPs / attendance / lineups reference this row, not gcal_events
-- directly, but the FK is NOT NULL — per §1.1, an fh_events row without
-- a live gcal_events parent is a bug.
CREATE TABLE fh_events (
    id             BIGSERIAL PRIMARY KEY,
    gcal_event_id  BIGINT NOT NULL REFERENCES gcal_events(id) ON DELETE RESTRICT,
    kind           TEXT NOT NULL CHECK (kind IN ('practice','pickup','match','meeting','camp','other')),
    -- Classification — derived from summary/description parse or manual override
    category       TEXT,                        -- 'mens' | 'womens' | 'boys' | 'girls' | 'staff' | NULL
    team_id        INT REFERENCES teams(id),
    is_home        BOOLEAN,
    facility_id    INT,                         -- future: facilities table
    -- RSVP window (see §6.5).  NULL means RSVPs open immediately once event
    -- is visible in FH (i.e. no restriction).  Set for pickup-style events.
    rsvps_open_at  TIMESTAMPTZ,
    -- Standing-RSVP applier bookkeeping (§6.5.3).  NULL until the
    -- applier runs; once set, applier skips this row.
    standing_applied_at  TIMESTAMPTZ,
    -- Freeform notes visible to coaches on FH but not exported to gcal
    fh_notes       TEXT,
    created_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at     TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- RSVPs are keyed to fh_events, so they survive gcal-event edits (the gcal
-- row keeps its google_event_id even if summary/location change; fh_events
-- keeps its id even when gcal_events tombstones and comes back).
CREATE TABLE fh_event_rsvps (
    id             BIGSERIAL PRIMARY KEY,
    fh_event_id    BIGINT NOT NULL REFERENCES fh_events(id) ON DELETE CASCADE,
    person_id      BIGINT NOT NULL REFERENCES persons(id) ON DELETE CASCADE,
    response       TEXT NOT NULL CHECK (response IN ('yes','no','maybe')),
    responded_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (fh_event_id, person_id)
);
```

*Open question:* if the same match appears in both Soccer and Ops, we
end up with two `gcal_events` rows. Do we present those to the user as
one thing or two? Options:

a) Show as one merged event when `(starts_at, ends_at, summary)` match
   across the two calendars in the same window. Never persist the
   merge — it's a view-layer concern.
b) Persist a `gcal_event_pairs` table with soccer + ops row IDs when we
   detect a match. Human can un-pair if wrong.
c) Ignore the duplication — show both. Simplest, probably fine.

Start with (c). Escalate if it's noisy in practice.

---

## 6. Classifying events into FH concepts

### 6.0 The "Soccer" prefix filter

**Staff convention (enforced, per user directive 2026-07-16):**

> **Every soccer event on either calendar has a summary that begins
> with the literal word `Soccer`.** Anything that does not is not
> FH's problem.

This is the single most important classifier rule. Both calendars
carry non-soccer bookings that FH must ignore entirely — e.g. the
Ops cal has rows like `Markeeda McLean Barn Rental`, `Ramiro Rodeo`,
`The Village Business Hours` that we saw during Slice 0 exploration.
The sync worker still mirrors *every* event into `gcal_events` (the
mirror is a faithful copy of the calendar), but the classifier only
promotes rows that pass the prefix filter into `fh_events`.

Concretely:

```sql
-- Candidates for FH classification.
-- NB: Postgres regex (POSIX ARE, §9.7.3) does NOT support Perl
-- shortcuts \s or \b — must use \M / \y for word boundary,
-- [[:space:]] for whitespace.  Migration 120 was the fix-up.
SELECT id, summary, starts_at
FROM   gcal_events
WHERE  deleted_at IS NULL
  AND  summary ~* '^Soccer\M';
```

Everything else stays in `gcal_events` (for audit / debugging / the
admin health page) but never crosses into `fh_events`, never
surfaces on any user-facing screen, never accepts RSVPs.

### 6.1 Pattern match on the summary

For rows that pass §6.0's `^Soccer\b` filter, FH needs to know
"practice? match? pickup? which team?" to render the right UI.
Hard-coded rules table, known patterns as of 2026-07-16:

| gcal summary pattern                       | `kind`     | `category` |
|--------------------------------------------|------------|------------|
| `^Soccer\s+11th\s+grade\+.*`               | `pickup`   | `mens`     |
| `^Soccer\s+All\s+Staff\s+Meeting$`         | `meeting`  | `staff`    |
| *(grow this table as new patterns appear)* |            |            |

The §6.1 summary-regex path is the **fallback classifier**. It only
runs on events whose description does NOT contain a `Team:` tag
(§6.1.5 owns those). It sets `kind` + `category` only; it does NOT
attach any `fh_event_teams` rows, which means events classified by
this path cannot accept RSVPs (the eligibility gate in §6.5.2 fails
closed with "This event has no roster attached yet"). Retrofit the
gcal description with §6.1.5 DSL tags to enable RSVPs.

### 6.1.5 Description DSL (source of truth for team attachment)

**Locked 2026-07-16.** For every event that needs RSVPs, ops writes a
small DSL in the gcal event's description body. Example (Saturday
mens pickup):

```
Team: Pickup
Club: Mens
```

Or, for a co-ed pickup event:

```
Team: Pickup
Club: Mens, Womens
```

Players and coaches never see the gcal event directly — the
description is treated as pure code. This is a deliberate design
choice: it lets ops evolve the DSL forever without collateral damage
to a user-facing surface. If we ever need player-visible prose,
that's what `Notes:` is for.

**Tags** (case-insensitive, one tag per line, `Tag: value` form).
Values are trimmed and normalized through `gcal_norm_alias` (SQL
function, migration 121) before lookup — so `Mens`, `MENS`, `Men's`,
and `mens.` all collapse to the same key.

| Tag       | Required?     | Values / semantics                                                                 |
|-----------|---------------|------------------------------------------------------------------------------------|
| `Team:`   | ✅ for RSVP    | `Pickup` \| `Practice` \| `APSL` \| `Liga 1` \| `Liga 2` \| `Adult` \| … (extensible via `gcal_team_aliases`) |
| `Club:`   | ✅ with `Team:` | `Mens` \| `Womens` \| `Boys` \| `Girls` (list-friendly: `Mens, Womens`)             |
| `Type:`   | optional      | `practice` \| `pickup` \| `match` \| `meeting` \| `camp` \| `other` (alias: `Kind:`). Overrides the auto-inferred kind. |
| `Home:`   | optional      | `Yes` \| `No` \| `Neutral`. Sets `fh_events.is_home`. Only meaningful on matches.  |
| `Notes:`  | optional      | Free text. Stored verbatim in `fh_events.fh_notes`; rendered in the card body.     |

**Multi-club events.** `Team:` and `Club:` are both **list-friendly** —
either comma-separated on a single line (`Club: Mens, Womens`) or
repeated across lines. All `Team:` values cross-product with all
`Club:` values to produce (club, team) pairs; each pair looks up
`gcal_team_aliases` → `team_id` and adds one `fh_event_teams` row.
So a single co-ed pickup event with `Team: Pickup / Club: Mens, Womens`
resolves to **two** junction rows (909 Mens Pickup + 919 Womens
Pickup once the Womens seed lands) and any member of either roster
can RSVP.

**Kind derivation** when `Type:` isn't explicit:
1. If any resolved `team_alias` is `pickup`   → `kind = 'pickup'`
2. Else if any is `practice`                  → `kind = 'practice'`
3. Else                                        → `kind = 'match'`

**Category (single-value cache on `fh_events`)**:
* Exactly one distinct club → `category = <that club>`
* Multiple distinct clubs   → `category = NULL` (the junction is truth)

**Append-only rule (non-negotiable).** Once a `gcal_team_aliases` row
is inserted and any live gcal event references it, the `team_id`
column MUST NOT be repointed. Rename by adding a new alias row
alongside the old one; delete an old alias only after grepping every
gcal event description to confirm nothing uses it. This mirrors the
sim ADR §22.25 rule that stable IDs never move once published — the
gcal descriptions are effectively "code" that has been "deployed" to
whoever owns the calendar, and we can't atomically re-deploy them.

**Idempotence.** The classifier (`scripts/gcal-classify.js`) parses
every DSL-tagged event on every 5-min tick, upserts `fh_events`, and
DELETE-then-INSERTs the junction to match the current description
exactly. Removing a tag from the description on next tick removes
the corresponding junction row. RSVPs on `fh_event_rsvps` are keyed
to `fh_events.id` (which is stable) so they survive junction
rebuilds.

### 6.2 Manual override

Any `gcal_events` row that passed §6.0 but no §6.1 pattern matched
can be manually classified in the FH admin UI. The override lives in
`fh_events` and survives even if the gcal summary text is edited
later.

### 6.3 Future prefix convention

Staff can start suffixing titles like `Soccer [U14 Boys] Practice`
or `Soccer [Mens] Match vs FC Barcelona` and the regex layer will
pick them up without new code. Not required — the §6.1 table is the
workhorse.

### 6.4 Fallback

If a row passed §6.0 but nothing in §6.1 matched and no §6.2
override exists, the event lands in the admin "Needs classification"
queue (see Slice 8). Users don't see it yet; no RSVPs can attach
until it's tagged.

---

## 6.5. RSVP window rule

Some event kinds (currently just `pickup`) have a **restricted RSVP
window**: the RSVP list is empty and read-only until a fixed moment,
then “opens” for the week. This mirrors current FH behavior for
Saturday pickup: nobody stakes an early claim on a capacity-limited
slot.

### 6.5.1 The rule (confirmed 2026-07-16)

> **RSVPs open every Sunday at 20:00 America/New_York for every
> event happening in the following 7 days.**

Equivalently, for any `fh_events` row with `kind='pickup'`:

```
rsvps_open_at = the most recent Sunday 20:00 America/New_York
                that is <= fh_events.starts_at
```

Worked examples (“this coming Sunday” = 2026-07-19 20:00 ET):

| Event                                    | `starts_at`             | `rsvps_open_at`             |
|------------------------------------------|-------------------------|-----------------------------|
| Sat 2026-07-18 11:00 pickup (this week)  | 2026-07-18T11:00-04:00  | 2026-07-12T20:00-04:00      |
| Sat 2026-07-25 11:00 pickup (next week)  | 2026-07-25T11:00-04:00  | 2026-07-19T20:00-04:00      |
| Sat 2026-08-01 11:00 pickup              | 2026-08-01T11:00-04:00  | 2026-07-26T20:00-04:00      |

### 6.5.2 Enforcement

The RSVP write endpoint (`POST /api/rsvp`) checks:

```sql
SELECT rsvps_open_at FROM fh_events WHERE id = $1;
```

and rejects with `409 Conflict — RSVP window not open yet` if
`now() < rsvps_open_at` **and** the request is not being made by
the standing-RSVP applier (§6.5.3). Read endpoints show the event
with a countdown timer + “opens Sun 8:00 PM” label instead of the
RSVP button.

### 6.5.3 Standing (recurring) RSVPs — the exception

Some users “always come”. They shouldn’t have to click YES every
Sunday at 8pm; the system should do it for them the instant the
window opens.

**Data model** — new table:

```sql
CREATE TABLE fh_recurring_rsvps (
    id            BIGSERIAL PRIMARY KEY,
    person_id     BIGINT NOT NULL REFERENCES persons(id) ON DELETE CASCADE,
    -- What kind of event this standing RSVP applies to.  Matches the
    -- (kind, category) tuple on fh_events set by the §6.1 classifier.
    kind          TEXT NOT NULL,      -- e.g. 'pickup'
    category      TEXT,               -- e.g. 'mens'  (NULL = any category)
    response      TEXT NOT NULL CHECK (response IN ('yes','no','maybe')),
    active        BOOLEAN NOT NULL DEFAULT true,
    created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (person_id, kind, category)
);
```

**Applier job (`scripts/gcal-rsvp-apply-standing.js`):**

A scheduled job runs every 5 min (same systemd `.timer` cadence as
the sync worker, but independent). For each `fh_events` row where
`now() >= rsvps_open_at` and no standing RSVPs have been applied
yet (tracked by a boolean `standing_applied_at TIMESTAMPTZ` column
on `fh_events` — add to schema in §5):

```sql
INSERT INTO fh_event_rsvps (fh_event_id, person_id, response, responded_at)
SELECT $1, r.person_id, r.response, now()
FROM   fh_recurring_rsvps r
WHERE  r.active = true
  AND  r.kind = $2                       -- fh_events.kind
  AND  (r.category IS NULL OR r.category = $3)   -- fh_events.category
ON CONFLICT (fh_event_id, person_id) DO NOTHING;   -- respect manual RSVPs

UPDATE fh_events SET standing_applied_at = now() WHERE id = $1;
```

**Semantics:**

- The applier runs *at or after* `rsvps_open_at`, never before.
  Effectively “Sunday 8pm ET plus ≤5 min”.
- `ON CONFLICT DO NOTHING` means a user who manually pre-registered
  their answer (in a prior week for the same event, or via an admin
  override) wins over the standing default.
- Users can flip a standing RSVP off any time via their profile
  screen — `active=false`. That takes effect for the next window
  open; previously-applied rows for future events are NOT
  auto-removed (the user can still cancel manually per event).
- Deleting the standing row entirely (via profile) is equivalent to
  `active=false` for scheduling purposes.

**UI implications (profile screen):**

New section “Auto-RSVP” on the user profile listing every
`(kind, category)` the user could opt into. For each row:

- Toggle: On (Yes) / Off (No, manual only) / Off (No, standing No).
- “Applies to every event where kind = pickup and category = mens.”
- Small note: “We register you at 8:00 PM each Sunday when RSVPs open.”

### 6.5.4 Extending to other kinds later

**Update 2026-07-16.** `kind='practice'` now uses the same Sunday
20:00 ET window as `kind='pickup'` — see `RSVPS_OPEN_AT_SQL` in
`scripts/gcal-classify.js`. Rationale: mens moved from 1 pickup/week
to 4 practices + 1 pickup/week; opening all five together lets
players commit to their week in one sitting. Match/meeting/camp
still get `rsvps_open_at = NULL` until we spec their windows.

Same column and same standing-RSVP mechanism — add a `kind` branch
to `RSVPS_OPEN_AT_SQL` (or a lookup table) if matches, etc.,
eventually need windowed RSVPs with a different open-cadence.

---

## 7. Sync worker sketch

Language: Node (already have `googleapis` installed). One-shot script,
not a daemon. Called by cron / systemd `.timer`.

Skeleton (would live at `scripts/gcal-sync.js`, following existing
scripts/ conventions):

```js
require('dotenv').config({ path: __dirname + '/../env' });
const { google } = require('googleapis');
const { Client } = require('pg');
const creds = JSON.parse(process.env.GCAL_SA_JSON);

const CALENDARS = [
  { google_id: process.env.GCAL_SOCCER_CALENDAR_ID, role: 'soccer' },
  { google_id: process.env.GCAL_OPS_CALENDAR_ID,    role: 'ops'    },
];

async function syncOne(pg, cal) {
  const auth = new google.auth.GoogleAuth({
    credentials: creds,
    scopes: ['https://www.googleapis.com/auth/calendar.readonly'],
  });
  const gcal = google.calendar({ version: 'v3', auth });

  // Fetch last syncToken from DB.
  const { rows: [row] } = await pg.query(
    `SELECT id, sync_token FROM gcal_calendars WHERE google_id = $1`, [cal.google_id]);
  let syncToken = row?.sync_token || null;
  let pageToken;
  let full = !syncToken;

  do {
    let res;
    try {
      res = await gcal.events.list({
        calendarId: cal.google_id,
        singleEvents: true,     // expand recurring
        maxResults: 250,
        pageToken,
        ...(syncToken ? { syncToken } : { timeMin: horizon(-30), timeMax: horizon(+365) }),
      });
    } catch (e) {
      if (e.code === 410) { syncToken = null; full = true; continue; }
      throw e;
    }
    for (const e of res.data.items || []) {
      await upsertEvent(pg, row.id, e);
    }
    pageToken = res.data.nextPageToken;
    if (!pageToken && res.data.nextSyncToken) {
      await pg.query(
        `UPDATE gcal_calendars SET sync_token=$1, last_synced_at=now() WHERE id=$2`,
        [res.data.nextSyncToken, row.id]);
    }
  } while (pageToken);
}

// ... upsertEvent computes SHA256(canonicalize(event)), skips if unchanged,
//     tombstones on status='cancelled', updates last_seen_at otherwise.

(async () => {
  const pg = new Client();  // DATABASE_URL from env
  await pg.connect();
  for (const cal of CALENDARS) await syncOne(pg, cal);
  await pg.end();
})();
```

Runs to completion in seconds. Idempotent. Safe to invoke concurrently
(row-level updates), though we don't need to.

---

## 8. Scheduling the worker

Two candidates:

a) **systemd `.timer`** (owned by host, like the existing
   `scrape-vpn.compose.yml`). Pros: simple, host-managed, restart on
   failure, unit files fit the existing pattern.
b) **pg_cron** invoking a small wrapper — but pg_cron can't run
   arbitrary Node, so this would need a signal + external worker
   anyway. Skip.

Recommend (a). Land a `systemd/gcal-sync.service` + `.timer` pair, and
document the install steps under `setup.sh` (a new
`scripts/setup/setup-gcal.sh` step, mirroring the other numbered
setup steps).

---

## 9. Backend read patterns

Whatever endpoint eventually surfaces gcal events (a `/api/calendar`
route, a match-detail lookup, a practice list) reads from Postgres,
not from Google. Example:

```sql
SELECT ge.*, fe.kind, fe.team_id
FROM gcal_events ge
LEFT JOIN fh_events fe ON fe.gcal_event_id = ge.id
JOIN gcal_calendars gc ON gc.id = ge.calendar_id
WHERE ge.deleted_at IS NULL
  AND ge.starts_at >= now()
  AND ge.starts_at < now() + interval '14 days'
ORDER BY ge.starts_at ASC;
```

No API call in the request path. This is the whole point of the
mirror.

---

## 10. Frontend implications

**Current state (2026-07-16):** FH has no unified calendar page. Related
screens that exist today:

- `admin-schedule.js` / `admin-schedule-item.js` — admin schedule editing
- `club-events.js` — club events + RSVP override (chat-driven)
- `mens-events-reminders.js` — pickup RSVP nudges
- `my.js` — per-user "My Schedule"

None of these read from gcal. They're all going to migrate to reading
from the mirror once Slice 3 lands.

### 10.1 New Calendar screen

Add `frontend/js/screens/calendar.js` — a `CalendarScreen extends
Screen` following the existing OOP pattern (no framework, per
[.github/copilot-instructions.md](../.github/copilot-instructions.md)).

**Visual format — should it mirror Google Calendar?**

Yes, largely. Users already know that UI; matching it removes a
learning curve. Concretely:

- Default view: **week grid** (Sun–Sat columns, hour rows), same as
  gcal week view. Mobile falls back to a stacked list per day.
- Secondary view: **month grid** for the "what's this Saturday
  look like 4 weeks out" question.
- Tertiary view: **agenda list** (chronological, 14 days ahead) —
  this is what small screens and email digests use.
- Color-coding by `fh_events.kind` (pickup=blue, practice=green,
  match=red, meeting=grey). Same color on all three views.
- Non-classified `gcal_events` (§6.4) are hidden from the public
  view; admins get a toggle to show them.
- Clicking a cell → **Event detail screen**.

### 10.2 Event detail screen — the read-only / editable split

This is the important layering. **The two data sources are visually
distinct on the screen.**

**Read-only, sourced from gcal (`gcal_events` row):**

| Field           | Where it comes from |
|-----------------|--------------------|
| Title / summary | `gcal_events.summary` |
| Start / end     | `gcal_events.starts_at` / `ends_at` |
| Location        | `gcal_events.location` |
| Description     | `gcal_events.description` |
| Recurrence      | derived from `recurring_event_id` |
| "Open in Google Calendar" link | `gcal_events.html_link` |

These render as static text. There is no edit button. If a coach
wants to change the time or location, they change it in Google
Calendar and it flows into FH on the next sync (≤5 min). This is
§1.1 in the UI.

**Editable in FH, stored on `fh_events` + related tables:**

| FH feature      | Table |
|-----------------|-------|
| Kind classification (pickup/practice/match/…) | `fh_events.kind` |
| Category (mens/womens/boys/girls/staff) | `fh_events.category` |
| Team linkage    | `fh_events.team_id` |
| Home/away flag  | `fh_events.is_home` |
| Coach notes (FH-only, not synced to gcal) | `fh_events.fh_notes` |
| Availability / RSVPs | `fh_event_rsvps` |
| Attendance (post-event check-in) | `fh_event_attendance` *(future table)* |
| Roster / lineup | `fh_event_lineups` *(future table)* |
| Chat thread     | existing chat tables, FK'd to `fh_events.id` |

These render below the gcal block, in an "FH details" section, each
with its own edit affordance where the current user has permission.

### 10.3 Screen inventory to build

- **`calendar.js`** — the week/month/agenda view above.
- **`event-detail.js`** — the split screen from §10.2.
- **`admin-event-classification.js`** — admin queue for §6.4
  fallback (list of gcal rows that passed §6.0 but not §6.1, with
  dropdowns to pick kind/category/team).

### 10.4 Migration order for existing screens

Once Slice 3 exists, the current screens migrate one at a time to
read from `fh_events`:

- `mens-events-reminders.js` first (smallest surface, and Slice 7
  pickup migration lands its data anyway).
- `club-events.js` next.
- `my.js` last (biggest, aggregates across everything).

First deliverable for M1: sync worker + `/api/calendar/upcoming`
returning DB rows + a minimal agenda-list version of `calendar.js`.
Week/month grids can come after.

---

## 11. Failure modes and monitoring

| Failure | Symptom | Mitigation |
|---------|---------|-----------|
| Google credentials revoked | 401 on every poll | Alert loudly (email?); test script exit code non-zero; systemd unit `OnFailure=` hook |
| SA removed from Ops ACL | 403 on Ops list only | Same alert path; degrade to Soccer-only sync until reshared |
| `syncToken` expires | 410 GONE | Auto-retry as full sync (already in sketch) |
| Poller hasn't run | `now() - last_synced_at > 15m` | Backend `/health` endpoint surfaces staleness; frontend can show a "gcal sync stale" banner |
| Event mass-deleted in gcal | Many tombstones one poll | No mitigation — deletions ARE authoritative; just log the delta count |

---

## 12. Open questions / TBD

- Whose Google account owns the FH-created soccer events? Currently the
  SA (`footballhome-gcal@…`) — it appears as the "created by" author,
  which is fine but visible in gcal. Acceptable? If not, we need
  domain-wide-delegation to impersonate a human, which adds complexity.
- Timezone: everything currently `America/New_York`. Confirm no traveling
  matches yet (they'd be represented in gcal correctly regardless, but
  our regex might not handle it).
- Deduplication between Soccer and Ops rows — start with option (c)
  (show both), revisit if noisy.
- Recurring events: `singleEvents: true` expands them, but if a coach
  edits ONE instance of a weekly practice, we get a new event row with
  `recurring_event_id` linking to the parent. Handle carefully in
  classification.

---

## 13. Rollout plan

- [x] **Slice 0:** service account created, both calendars wired,
      env encrypted, smoke test proves reads.
- [x] **Slice 1:** schema migration for `gcal_calendars` + `gcal_events` +
      `fh_events` + `fh_event_rsvps` + `fh_recurring_rsvps`. Seed
      `gcal_calendars` with the two rows. (`database/migrations/119`
      + fix-up `120` for the soccer-prefix index regex.)
- [x] **Slice 2:** `scripts/gcal-sync.js` — full initial sync + incremental
      via `syncToken`. `systemd/gcal-sync.{service,timer}` fires it
      every 5 min. Installed by `scripts/setup/setup-gcal.sh`.
- [x] **Slice 3:** classification pass — `scripts/gcal-classify.js`
      iterates the §6.1 pattern table, upserts `fh_events` rows, and
      computes `rsvps_open_at` for `kind='pickup'` per §6.5. Runs as
      the second `ExecStart` in `gcal-sync.service` so every tick is
      sync → classify. Reports unclassified soccer summaries at the
      end (Slice 8's queue).
- [x] **Slice 4:** backend `GET /api/calendar/upcoming?days=<int>`
      endpoint — `backend/src/controllers/CalendarController.{h,cpp}`
      joins `fh_events` → `gcal_events` → `gcal_calendars`, filters
      out tombstoned + cancelled rows, caps `days` at 1..90, and
      emits `rsvps_open_now` per §6.5.2 so the frontend can render
      the countdown vs RSVP button without re-deriving the rule.
      Unauthenticated (schedule-only, no PII); RSVP writes gain
      auth in Slice 6.
- [x] **Slice 5:** `CalendarScreen` (`frontend/js/screens/calendar.js`)
      renders the §10.1 agenda list — bucketed by date (Today,
      Tomorrow, This week, Next week, Later), color-coded by
      `kind`, with the read-only §10.2 fields + Slice 4's
      `rsvps_open_now` flag turned into a green "RSVPs open" pill
      or an amber "Opens Sun Jul 19 8:00 PM" countdown label.
      Reached via a new `admin-calendar` tile added under the
      Schedule section of `admin-club.js` (§10.1). Week and month
      grid views are follow-ups.
- [x] **Slice 6:** RSVP write endpoint — `POST /api/calendar/rsvp`
      with the §6.5.2 window check, wired to `fh_event_rsvps`.
      Session-gated (see `MyController::requireSession` pattern,
      Bearer JWT preferred over `fh_sess` cookie). Body
      `{fh_event_id, response, note?}`; reject 409 when
      `now() < fh_events.rsvps_open_at`; 404 when the event is
      tombstoned/cancelled; write with `created_via = 'manual'`
      (overwrites any prior `standing`/`admin` row for that person).
      `GET /api/calendar/upcoming` is now session-aware and returns
      `my_rsvp: 'yes'|'no'|'maybe'|null` per event so the frontend
      can reflect current state without a second call. Frontend:
      YES/NO/MAYBE buttons on pickup cards in `CalendarScreen` when
      `rsvps_open_now = true` (buttons disabled with the amber
      countdown label when false; anonymous callers get a
      "sign in to respond" pill instead of dead buttons).

      **Path note:** the doc originally called this endpoint
      `POST /api/rsvp`, but that path is already owned by
      `EventRsvpController` (the chat-driven event RSVP flow,
      keyed to `chat_event_id`). Scoped under `/api/calendar/*`
      to mirror the read endpoint and keep the two RSVP systems
      non-overlapping.
- [x] **Slice 6b:** roster-gated RSVPs via description DSL (§6.1.5).
      1. Migration `121-gcal-team-aliases-and-junction.sql` —
         `gcal_norm_alias()` immutable SQL fn, `gcal_team_aliases`
         seeded with 8 Mens rows, `fh_event_teams` junction (3NF),
         `fh_events.team_id` DROPPED.
      2. Classifier `scripts/gcal-classify.js` — DSL Pass A parses
         `Team:` / `Club:` / `Type:` / `Home:` / `Notes:` from the
         gcal description, cross-products Club × Team, resolves via
         aliases, DELETE-then-INSERT junction rows, upserts
         `fh_events`. Legacy Pass B regex excludes `Team:`-tagged
         events so paths are disjoint. Reports `unresolved` +
         `missingClub` at the end.
      3. Backend `GET /api/calendar/upcoming` returns `teams[]`,
         `hangout_link`, `my_rsvp_eligible`; drops `team_id`.
         `POST /api/calendar/rsvp` gates on:
         (a) event has ≥1 attached team (`fh_event_teams`) — else
             403 "no roster attached yet";
         (b) caller is on ≥1 attached team's roster (via
             `player_rsvp_eligibility`) — else 403 "not on the
             roster for this event".
      4. Frontend `frontend/js/screens/calendar.js` — renders
         `teams[]` chip strip, notes block, Meet button, and a
         5-branch RSVP block: signed-out / no-roster / not-eligible
         / open (buttons) / countdown pill.
      5. Practice now uses the same Sun 20:00 ET RSVP window as
         pickup (§6.5.4) so ops can attach `Team: Practice` to
         Tue/Wed/Thu/Fri Mens events and users see 4 practices + 1
         pickup opening together each week.
      6. Verified end-to-end 2026-07-17: 1451 events reclassified,
         API returns new shape, POST enforces roster gate.
- [ ] **Slice 6a:** standing/recurring RSVPs (§6.5.3). Schema
      `fh_recurring_rsvps` already exists from migration 119. Work
      remaining (see §0.3 for the concrete tomorrow-order):
      1. `GET`/`POST /api/calendar/my-standing` on `CalendarController`
         — upsert one `fh_recurring_rsvps` row per
         `(person_id, kind, category)` with `active` boolean.
         Session-gated identically to `POST /api/calendar/rsvp`.
      2. `scripts/gcal-rsvp-apply-standing.js` — worker joining
         `fh_events` (rsvps_open_at ≤ now AND
         standing_applied_at IS NULL) → `fh_event_teams` →
         `player_rsvp_eligibility` → `fh_recurring_rsvps`
         (active + kind match + category match OR NULL), upserts
         `fh_event_rsvps` with `created_via='standing'`, stamps
         `fh_events.standing_applied_at = now()`. Idempotent.
      3. `systemd/gcal-rsvp-apply-standing.{service,timer}` — 5 min
         cadence, independent of gcal-sync.
      4. Frontend: profile-screen toggle grid `(kind × category)`
         bound to `/api/calendar/my-standing`. Backend adds
         `my_rsvp_created_via` to `GET /api/calendar/upcoming` and
         frontend shows a "Auto-registered via your standing pref"
         chip on those cards.
      **Explicitly NOT DOING** the design-doc "backfill for regulars
      ≥90% YES over 8 weeks + one-time email opt-in" step. If the
      profile toggle isn't compelling enough that regulars discover
      it, that's a UX problem to fix, not a data-migration problem
      to work around. (Decision 2026-07-17.)
- [ ] **Slice 7 — Pickup migration.** The Saturday Mens Pickup has
      real historical RSVPs that need to be preserved when the
      pickup screen repoints at the new `fh_events` rows.
      **Discovered state (2026-07-17):** there is NO dedicated
      "pickup" table — legacy pickup lives on `matches` rows with
      `match_type_id=7`. Legacy per-event RSVPs are in
      `player_rsvp_history` (360 rows, immutable log; take LATEST
      per (player, event)). Legacy standing prefs are in
      `player_recurring_rsvps` (129 rows, keyed by
      `(person_id, day_of_week, match_type_id)`).
      Migration:
      1. Slice 6b's classifier already writes an `fh_events` row
         (kind=pickup, category=mens, team=909 Pickup) for every
         Sat instance — done.
      2. One-shot `scripts/migrate-legacy-pickup-rsvps.js`:
         for each `matches` row with `match_type_id=7`, find the
         `fh_events` row on the same date, and for each player take
         the LATEST `player_rsvp_history` row → upsert
         `fh_event_rsvps` with `created_via='manual'`,
         `responded_at=changed_at`. Report counts. Idempotent.
      3. One-shot migration for standing prefs:
         `player_recurring_rsvps WHERE day_of_week=6 AND match_type_id=7
          AND rsvp_status = 'yes'` → `fh_recurring_rsvps`
         `(kind='pickup', category='mens', response='yes', active=true)`.
         Report only — user reviews then greenlights the copy.
      4. Repoint `mens-events-reminders.js` (and any other pickup
         screen) at `fh_events` + `fh_event_rsvps`. Only pickup —
         real matches keep the legacy path.
      5. **Do NOT drop legacy tables.** `matches` + `player_rsvp_history`
         + `player_recurring_rsvps` still hold real-match data.
         Slice 7 just stops dual-writing pickup rows to them.
- [ ] **Slice 8 — Unclassified queue.** Fallback classifier reports N
      "Soccer …" summaries per run that don't match any legacy regex
      AND have no `Team:` DSL tag (14 at Slice 6b landing time,
      mostly youth practice + intra-squad games). **Decision
      2026-07-17: SKIP the admin UI.** Add
      `scripts/gcal-unclassified-report.js` that emails jbreslin@
      weekly with the list. Ops resolves each by adding DSL tags in
      gcal (source of truth per §6.1.5), not by clicking through an
      FH admin form. Revisit if volume grows past ~50/week.

**Post-Slice-6b infra tasks (do first — see §0.2):**
- [ ] **W2** — install `systemd/gcal-sync.{service,timer}` on the host.
      Currently not installed → 5-min auto-sync isn't running →
      classifier only picks up gcal changes when someone runs it by
      hand. Detected 2026-07-17 when a manual run picked up
      `insert=1245 update=207`.
- [ ] **W3** — seed `gcal_team_aliases` for Women / Boys / Girls
      (migration `122-`), mirroring the 8-row Mens seed shape from
      migration 121.

**Explicitly out of scope, per §1.1:** any "create event in FH" UI or
an FH → gcal writer. If we ever want that, it requires a design-doc
amendment first, not a code change first.
