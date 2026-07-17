# Football Home ↔ Google Calendar — design doc

**Status:** IN PROGRESS. Slices 0–7 landed on `main`; MyScreen unified
week view (§10.4) landed 2026-07-17 EOD. Slice 8 (unclassified queue)
is the only open scheduled item.
**Last updated:** 2026-07-17 EOD.
**Owner:** jbreslin / Football Home.

---

## 0. RESUME HERE (2026-07-17 EOD)

Where we are and exactly what to do tomorrow. Read this before touching
anything else — it will save you from re-deriving what's already known.

### 0.1 What landed today (Slices 6a, 7, MyScreen unified)

- **Slice 6a — standing/recurring RSVPs.** `GET/POST
  /api/calendar/my-standing` in `CalendarController`. Worker
  `scripts/gcal-rsvp-apply-standing.js` running on the shared 5-min
  cadence with the sync worker. Frontend surfaces are the two
  outline "Recurring Going / Not Going" buttons per event card on
  MyScreen (below) — no separate profile grid.
- **Slice 7 — legacy pickup rip.** `mens-events-reminders.js`
  repointed at `fh_events` + `fh_event_rsvps`. Legacy tables
  (`matches` / `player_rsvp_history` / `player_recurring_rsvps`)
  retained for real-match data; pickup no longer dual-writes.
  Committed 2026-07-17.
- **MyScreen unified week view.** `frontend/js/screens/my.js`
  rewritten as the primary player landing screen. Single-page
  layout: compressed chat on top (newest message only + expand
  toggle), one-week RSVP list below. Trims client-side to the
  current week per §6.5.5 (Sunday 20:00 ET rollover). Four buttons
  per card (per-event Going/Not Going, recurring Going/Not Going);
  per-event override always wins. See §10.4.
- **View-as impersonation on `/api/calendar/*`.** `auth.js` +
  `CalendarController::applyImpersonation`. See §10.5.

### 0.2 Only open scheduled item — Slice 8

Unclassified queue. Fallback classifier reports N "Soccer …"
summaries per run that don't match any legacy regex AND have no
`Team:` DSL tag. **Decision 2026-07-17 stands: SKIP the admin UI.**
Add `scripts/gcal-unclassified-report.js` that emails jbreslin@
weekly with the list. Ops resolves each by adding DSL tags in gcal
(source of truth per §6.1.5), not by clicking through an FH admin
form. Revisit if volume grows past ~50/week.

#### 0.2.1 Slice 8 implementation sketch

- Script runs weekly (same host-level cadence as the sync worker,
  but a separate systemd timer is fine).
- It scans `gcal_events` rows that:
  - are not tombstoned/deleted,
  - have a summary matching the soccer-prefix rule from §6.0,
  - do not already have a matching `fh_events` row, and
  - do not contain a `Team:` DSL tag in the description.
- Output is an email body with one bullet per event:
  - summary,
  - calendar (Soccer vs Ops),
  - start time,
  - link to the Google event when available,
  - a short note such as "no Team tag / no regex match".
- No admin UI, no FH-side mutation path, and no auto-classification.
  The report is an ops handoff, not an FH workflow.
- If the weekly volume stays under ~50 rows, the current report-only
  approach remains the right tradeoff. If it grows beyond that, we can
  revisit a lightweight admin queue after the operational pain is real.

### 0.3 Deferred / opportunistic

- **W3 follow-up (option C).** Create virtual Practice + Pickup
  pool teams for Women / Boys / Girls (mirror Mens teams 908/909),
  wire `player_rsvp_eligibility` from the corresponding LA program
  IDs (`5064686` Women Pickup, `5064618` Boys Pickup, `5064662`
  Girls Pickup per copilot-instructions membership-flow section),
  then add the alias rows. Do this when ops starts tagging non-Mens
  practice/pickup events. Also seed Girls once a
  `gender_category='girls'` team exists.
- **`club-events.js` migration.** The last screen still reading
  from the legacy chat-driven RSVP path. Not urgent — the chat
  event system it uses is orthogonal to gcal.

### 0.4 Traps re-learned recently (don't step on tomorrow)

- **Impersonation URL rewrite is per-endpoint-prefix, not global.**
  If you add a new `/api/*` READ path that must render as the
  impersonated player, you MUST extend both `frontend/js/auth.js`
  (URL rewrite whitelist) AND the backend controller's read handler
  (add the `applyImpersonation` call after session resolution).
  Writes deliberately bypass — never wire `applyImpersonation` into
  a POST.
- **`teams.name`, not `teams.display_name`.** The `SELECT` in
  `CalendarController::handleGetUpcoming`'s `teams_json` subquery
  was written as `t.display_name` and 500'd until fixed.
- **Rootful podman means `sudo` on everything.** `podman ps` without
  sudo returns empty. `make shell-db` without sudo fails. Set your
  shell aliases and stop losing 30s per command trying to
  understand why the container "doesn't exist".
- **The 148-migration runner is slow (~30-45s to reach a new file).**
  This is not broken; it's per-file existence-checking through slow
  podman exec. Wait it out.
- **The gcal `singleEvents: true` expansion.** Every recurring
  instance is its own row in `gcal_events`. When ops edits the
  Saturday pickup DSL description, they MUST use "This and following
  events" (not "This event only") or only one instance updates.

### 0.5 Off-limits drift on disk

Working tree for the calendar workstream is clean at HEAD. The
separate billing-refactor workstream still has uncommitted drift
(deleted `BillingController.*`, `BillingExpectations.*`,
`BillingProjector.*`; untracked `117-next-due-at.sql`,
`118-drop-billing-expectations.sql`, `wire-snoop.js`,
`backend/.dockerignore`). Do NOT stage those \u2014 they belong to a
parallel agent.

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

### 6.5.5 Client-side display window (weekly rollover)

**Added 2026-07-17 EOD.** Separate from the server-side
`rsvps_open_at` gate (§6.5.1–§6.5.2), MyScreen enforces a
display-only "one week at a time" rule:

> **The player-facing week view shows events up to (and including)
> the upcoming Sunday. At Sunday 20:00 America/New_York the window
> slides to the following Sunday.**

Rationale: after Slice 6b, ops attaches DSL tags to next week's
gcal events days in advance, and the classifier immediately mints
`fh_events` rows with `rsvps_open_at = <next Sun 20:00>`. Backend
`/api/calendar/upcoming?days=14` faithfully returns those future
rows. Without a client-side trim, a player would see next week's
practices + pickup in an amber "opens Sun 8pm" state alongside
this week's — visually crowded and confusing. Trimming to the
current week keeps the screen focused on "what should I RSVP to
now".

The two cutovers are intentionally the same clock (Sun 20:00 ET):
next week's events appear in the display window at the exact
instant their `rsvps_open_at` also passes, so a player who refreshes
MyScreen at 20:00:05 Sun sees the new week's cards already showing
open RSVP buttons — no amber countdowns on the player-facing path.

Implementation:

- Backend request remains `days=14` so next week's rows are already
  in memory client-side — the rollover is instant on the next tick,
  no fetch required.
- Frontend `frontend/js/screens/my.js` — `_weekWindowEnd()` returns
  end-of-upcoming-Sunday (23:59:59.999 local) when `now < Sun 20:00`,
  else end-of-following-Sunday.  `_renderEvents()` filters the
  fetched list by `event.starts_at <= _weekWindowEnd()`.
- The full 14-day list is still available on the (admin-facing)
  `CalendarScreen` (§10.1) which does NOT apply this trim — admins
  need forward visibility.

**Do NOT push this rule into the backend.** It's a UX-layer choice
tied to which surface is rendering, not a data-authority rule.

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

- [x] `mens-events-reminders.js` — migrated as part of Slice 7.
- [ ] `club-events.js` — not yet migrated.
- [x] `my.js` — migrated 2026-07-17 EOD.  Now the primary
      player-facing landing screen: chat compressed to the newest
      message on top (with an expand toggle for older messages) and
      a single "This Week" list of RSVP-eligible events below.
      Reads `/api/calendar/upcoming?days=14` +
      `/api/calendar/my-standing`, trims client-side per §6.5.5.
      Four buttons per card (per-event Going/Not Going, recurring
      Going/Not Going) — the per-event override always wins over
      the standing pref (§6.5.3's `ON CONFLICT DO NOTHING` rule).
      Also honors view-as impersonation (see §10.5).

First deliverable for M1: sync worker + `/api/calendar/upcoming`
returning DB rows + a minimal agenda-list version of `calendar.js`.
Week/month grids can come after.

### 10.5 View-as impersonation on `/api/calendar/*`

**Added 2026-07-17 EOD.** An admin using the "view as" picker
(see `frontend/js/role-selection.js`) needs MyScreen to render as
the impersonated player. The impersonation mechanism was originally
scoped to `/api/my/*` only (`MyController::applyImpersonation`);
MyScreen's move to `/api/calendar/*` broke it.

Fix:

- `frontend/js/auth.js` — the `?asPersonId=<id>` URL rewrite now
  covers `GET /api/calendar/upcoming` and `GET /api/calendar/my-standing`
  in addition to `/api/my/*`. Writes never get the override — an
  admin viewing as a player must never accidentally RSVP as them.
- `backend/src/controllers/CalendarController.cpp` — new
  `applyImpersonation()` helper (admin-only via `admins` join;
  target must exist; mirrors `MyController::applyImpersonation`).
  Called from `handleGetUpcoming` and `handleGetMyStanding` after
  the session resolves. `handlePostRsvp` and `handlePostMyStanding`
  deliberately do NOT call it.

This is a read-only affordance. Every LA-membership rule still
applies (see [.github/copilot-instructions.md](../.github/copilot-instructions.md)
membership section) — the impersonated view goes through the same
roster / eligibility filters the impersonated player themselves
would see.

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
- [x] **Slice 6a:** standing/recurring RSVPs (§6.5.3). Landed
      2026-07-17 EOD. Schema `fh_recurring_rsvps` from migration 119.
      Delivered:
      1. `GET`/`POST /api/calendar/my-standing` on `CalendarController`
         — upserts one `fh_recurring_rsvps` row per
         `(person_id, kind, category)` with `active` boolean.
         Session-gated identically to `POST /api/calendar/rsvp`.
      2. `scripts/gcal-rsvp-apply-standing.js` worker running on the
         5-min systemd timer (independent of gcal-sync).
      3. Frontend surface: two outline "Recurring Going / Not Going"
         buttons per event card on MyScreen (§10.4), NOT the separate
         profile grid originally spec'd. Cleaner — same context as
         the per-event override, one screen.
      **Explicitly NOT DONE** the design-doc "backfill for regulars
      ≥90% YES over 8 weeks + one-time email opt-in" step. Decision
      2026-07-17 stands.
- [x] **Slice 7 — Pickup migration.** Landed 2026-07-17. Legacy pickup
      RSVPs preserved; `mens-events-reminders.js` repointed at
      `fh_events` + `fh_event_rsvps`. `matches` +
      `player_rsvp_history` + `player_recurring_rsvps` retained for
      real-match data — pickup no longer dual-writes to them.
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
- [x] **W2** — install `systemd/gcal-sync.{service,timer}` on the host.
      DONE 2026-07-17 via `scripts/setup/setup-gcal.sh`. Timer runs
      every 5 min with `Persistent=true` so a machine that was off
      catches up on next boot.
- [x] **W3** — seed `gcal_team_aliases` for Boys + Womens.
      DONE 2026-07-17 via migration `122-gcal-aliases-boys-womens.sql`
      (7 rows: `boys → u8/u12/u16`, `womens/women → tri county`).
- [ ] **W3 follow-up (option C, deferred)** — create virtual Practice
      + Pickup pool teams for Women / Boys / Girls (mirror Mens
      teams 908/909), wire `player_rsvp_eligibility` from the
      corresponding LA program IDs (`5064686` Women Pickup, `5064618`
      Boys Pickup, `5064662` Girls Pickup per copilot-instructions
      membership-flow section), then add the alias rows. Do this
      when ops starts tagging non-Mens practice/pickup events. Also
      seed Girls once a `gender_category='girls'` team exists.

**Explicitly out of scope, per §1.1:** any "create event in FH" UI or
an FH → gcal writer. If we ever want that, it requires a design-doc
amendment first, not a code change first.
