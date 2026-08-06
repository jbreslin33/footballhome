# Normalize groups, membership, and RSVP eligibility

Date: 2026-07-30 (design settled 2026-07-31)
Status: Accepted — design settled in discussion; migration not yet started

## Context

Investigating why Sheldon (and other boys rostered before 2026-07-19) showed
a blocked RSVP button on `#my` exposed the root cause: RSVP-ability is a
*stored copy* of roster membership (`player_rsvp_eligibility`, synced by
trigger `fn_grant_default_rsvp_eligibility`), and stored copies drift.
Migration 232 added the boys trigger clause but not the one-time backfill
107 did for mens, so pre-2026-07-19 boys have no eligibility rows. Any
"synced by trigger + backfill" design is one missed migration away from
this bug; the fix is to stop storing the copy.

### Evidence the current model is already hand-maintained duplication

Comparing `player_rsvp_eligibility` against derivable roster membership
(`v_team_members`) on 2026-07-31:

| team | stored | not derivable | …of which active on *another* team |
|---|---|---|---|
| 35 APSL | 79 | 63 | 60 |
| 120 Liga 1 | 76 | 48 | 47 |
| 121 Liga 2 | 75 | 47 | 46 |
| 908/909 Practice/Pickup | 155 | 3 | 0 |

~153 of ~390 rows are people hand-granted RSVP rights on a team they are
not rostered on — i.e. the "Liga 1 players are eligible for APSL" league
rule, encoded one unexplained checkbox at a time. ~5 rows are lapsed
members whose eligibility was never cleaned up (they can still RSVP —
live bug, same root cause: nothing reconciles the copy).

## Decision — the group model

**One entity: a group is a named set of people.** The existing `teams`
table remains that entity (keep the name `teams`). Everything else derives
from membership.

1. **Outward connection is optional.** `teams.division_id` (currently
   NOT NULL) and `club_id` become nullable. Competitive teams (APSL, Liga
   1/2, Adult, U8, U12) connect to a division/club; internal groups
   (reserves, trialists, training-only) connect to nothing. No separate
   `practice_groups` table — a parallel table would duplicate every
   mechanism (membership, event join, chat hook) for no semantic
   difference.

2. **One membership table: `team_persons`** replaces both `rosters`
   (player_id-keyed, used broadly) and `roster_assignments`
   (leagueapps_user_id-keyed, roster board + dues + trigger). Identity
   bridge confirmed: `players.person_id` (unique) and
   `external_person_aliases` (person ↔ LA user id) connect the two
   schemes. LA ids are resolved on demand at sync time, never stored on
   membership rows.

3. **RSVP eligibility = membership in a group tagged on the event.**
   `my_rsvp_eligible` for person P on event E becomes:
   `EXISTS (team_persons row for P on any team in fh_event_teams for E)`
   (plus existing coach/admin clauses). Nothing stored, nothing to sync,
   nothing to drift. **`player_rsvp_eligibility` is dropped entirely**,
   along with `fn_grant_default_rsvp_eligibility`.

4. **The pool/union machinery dies.** Pool teams (908/909; phantom
   918–923), `teams.is_pool`, `teams.roster_source`,
   `team_roster_sources`, and the union half of `v_team_members` encoded
   "practice is for everyone across these teams" as hidden schema. Under
   the group model the *event* says who it's for: the 7 recurring gcal
   practice series change their description from `Team: Practice` to
   `Team: APSL, Liga 1, Liga 2, Adult` (one-time ops edit), producing one
   `fh_event` with multiple `fh_event_teams` rows and one shared RSVP
   list, sliceable by team via membership. Draft migration 249 (pool-team
   backfill) is obsolete — delete it.

5. **Multi-team membership is legal — no one-home-team mutex.** League
   rules allow a player on multiple teams simultaneously (common case:
   moved up Liga 1 → APSL, replacement not found yet). The old board's
   `uniq_roster_assignments_mens_selection_one_of` forbade this, which
   is exactly what forced the ~153 hand-maintained cross-team
   eligibility grants. Those grants import as what they really are:
   membership on the granted team with `on_roster=false` (the board's
   existing "in the squad pool, not on the official roster" semantic).
   Prod-clone backfill confirms 77 persons on multiple official teams.
   The board UI must display multi-membership visually (Phase 2).
   Trialists (on no roster at all) can still get on-demand groups
   (e.g. `apsl_trialists` tagged on friendlies only) — but **do not
   pre-mint the group grid**; create each group the day it has members
   (data + a gcal alias, zero code). Same membership-identity test
   still rules out per-team practice groups (`apsl_practice` ≡ `apsl`,
   a copy by construction).

6. **`teams.kind`** distinguishes `official` (mirrors a real league
   roster; division/club required) from `internal` (hand-curated;
   division/club forbidden) from `admin_bucket` (roster-board
   bookkeeping like 915 "Dues Owed (Boys)"). Enforced by CHECK.

7. **`roster_columns` folds into `teams`** (label, short_label, color,
   sort_order, mutex_group, max_roster, archived_at). `domain` columns
   (on `roster_assignments` and `roster_columns`) die — category derives
   from `teams.gender_category`.

8. **Suspensions/revokes** ("on the roster but barred") are the one case
   that is not membership. Handled by a small exceptions table (sketch
   below) — NOT by deleting the membership row, which would corrupt
   roster history. This is the sole survivor of the old eligibility
   concept, and it stores only exceptions, so it cannot drift.

9. **Chat (parked, but shaped by this).** Only 2 chats exist; the model
   extends naturally — a chat hooks to a team (persistent channel) or an
   event (thread), membership derives from `team_persons`. Not built in
   this pass. The dead prototype event system **`chat_events` +
   `event_rsvps` + `chat_event_rsvps`** (3/0/7 rows, superseded by
   `fh_events`/`fh_event_rsvps`) is dropped, with care for FK dependents
   (`tactical_boards`, `training_attendance`, `magic_link_tokens`).

10. **`working_rosters` is confirmed dead** (zero references in backend
    or frontend; unimplemented legacy-038 concept) — dropped.

### DDL sketch

```sql
ALTER TABLE teams
  ALTER COLUMN division_id DROP NOT NULL,
  ADD COLUMN kind TEXT NOT NULL DEFAULT 'official'
    CHECK (kind IN ('official', 'internal', 'admin_bucket')),
  ADD CONSTRAINT teams_kind_outward CHECK (
    (kind = 'official' AND division_id IS NOT NULL)
    OR (kind <> 'official' AND division_id IS NULL)
  ),
  -- roster_columns fields fold in:
  ADD COLUMN label TEXT, ADD COLUMN short_label TEXT,
  ADD COLUMN color TEXT, ADD COLUMN board_sort_order INTEGER,
  ADD COLUMN mutex_group TEXT, ADD COLUMN max_roster INTEGER,
  ADD COLUMN board_archived_at TIMESTAMPTZ;
-- is_pool, roster_source dropped at the end of the migration.

CREATE TABLE team_persons (
    id                   SERIAL PRIMARY KEY,
    team_id              INTEGER NOT NULL REFERENCES teams(id) ON DELETE CASCADE,
    person_id            INTEGER NOT NULL REFERENCES persons(id) ON DELETE CASCADE,
    joined_at            TIMESTAMPTZ NOT NULL DEFAULT now(),
    removed_at           TIMESTAMPTZ,
    removed_reason       TEXT,
    removed_details      JSONB,
    on_roster            BOOLEAN NOT NULL DEFAULT false,
    jersey_number        VARCHAR(10),
    coach_sort_order     INTEGER,
    assigned_by_user_id  INTEGER REFERENCES users(id),
    CHECK (removed_at IS NULL OR removed_at > joined_at)
);
CREATE UNIQUE INDEX team_persons_active_unique
    ON team_persons (team_id, person_id) WHERE removed_at IS NULL;
-- NO one-home-team mutex: multi-team players are legal (decision 5).
-- replaces rosters + roster_assignments; roster_positions repoints here.

CREATE TABLE rsvp_suspensions (          -- exceptions only
    person_id   INTEGER NOT NULL REFERENCES persons(id) ON DELETE CASCADE,
    team_id     INTEGER REFERENCES teams(id) ON DELETE CASCADE,  -- NULL = all
    starts_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
    ends_at     TIMESTAMPTZ,
    reason      TEXT,
    created_by_user_id INTEGER REFERENCES users(id),
    PRIMARY KEY (person_id, team_id, starts_at)
);
```

**Keying decision:** `team_persons.person_id` (not `player_id`).
`fh_event_rsvps` is already person-keyed, `players` is 1:1 with `persons`
(`players.person_id` unique), and RSVP checks start from the session
person. Player-specific attributes stay reachable via the trivial join.
If implementation surfaces a strong reason to key on `player_id`, revisit
— but the name and the RSVP path both favor `person_id`.

## Migration sequence

Prod constraint: brief downtime acceptable; `#my` RSVP is the only
latency/uptime-sensitive screen. Forward-only migrations, phased so each
phase leaves the app working.

**Phase 0 — prep (no schema changes)**
- Delete draft `249-boys-home-team-rsvp-eligibility-backfill.sql`
  (obsolete under this design).
- Ops coordination: add `gcal_team_aliases` for `apsl`, `liga 1`,
  `liga 2`, `adult`, `u8`, `u12`; then edit the 7 recurring practice
  series descriptions to tag real teams. (Boys/girls/women events don't
  exist in the pipeline yet — zero classified rows — so mens is the only
  live cutover.)
- Verify identity bridge coverage: every active `roster_assignments.
  leagueapps_user_id` must resolve via `external_person_aliases` →
  `persons`. **Ran 2026-07-31: 329/330 active rows resolve.** Stragglers:
  LA `57723203` (active, admin-bucket 913, unlinked person — fix via LA
  sync or a 246-style manual link) and 3 removed-history rows for lapsed
  LA `57648955` (consciously skip). `rosters` → `players.person_id` is
  100% clean.
- ~~Reserves-on-matches tagging decision~~ **resolved by decision 5**:
  cross-team grants import as direct membership (multi-team is legal),
  so those players keep exactly their current event visibility — no
  ops tagging action required at cutover.

**Phase 1 — additive schema + backfill (app still on old tables)**
- `teams` alterations above; create `team_persons`, `rsvp_suspensions`.
- Backfill `team_persons` from `roster_assignments` (via alias bridge;
  carries on_roster/removed_*/coach_sort_order) and from `rosters` (via
  `players.person_id`; carries jersey_number), deduping where both
  describe the same membership. **The backfill must be idempotent and
  re-runnable** — it runs once here for verification, and again inside
  the Phase 2 cutover window to pick up placements made in between
  (closes the drift window; brief downtime acceptable).
- Keep an old→new mapping (`rosters.id` → `team_persons.id`) during
  backfill so the `roster_positions` repoint in Phase 2 is a mechanical
  UPDATE, and port `trg_notify_rosters` (`fn_notify_lineup_change`) from
  `rosters` to `team_persons` so lineup-change notifications survive.
- Cross-team `player_rsvp_eligibility` grants import as direct
  membership with `on_roster=false` (decision 5) — for persons with at
  least one active membership elsewhere; fully-lapsed grant holders
  are deliberately dropped.
- Fold `roster_columns` data into `teams`.
- Verification queries (run before Phase 2): old-vs-new eligibility diff
  per team must be explainable row-by-row (expected diffs: the ~5 stale
  lapsed-member rows, which this migration intentionally does not carry).

**Phase 2 — backend cutover (one deploy)**
- `CalendarController` eligibility → `team_persons` join (person-keyed,
  drops the alias hop).
- Roster board (`MensRosterController`, `BoysRosterController`,
  `MensRoster`, `MensTeamAssignments`, `LaPool`) → `team_persons`.
- LA sync + coach placement write `team_persons` directly (replaces
  trigger).
- `EligibilityController`, `PersonMergeController`, `TeamRoster`,
  `MyController` mens-chat gate (currently `domain='mens'`) → membership
  checks.
- `rsvp-eligibility` admin screen → manages internal-group membership +
  suspensions instead of per-team checkbox grid.
- Repoint `roster_positions.roster_id` → `team_persons.id`.

**Cutover verification & rollback**
- **Parity harness (the actual "no disruption" proof):**
  `database/verification/rsvp-parity.sql`. For every person × every
  event in the next 30 days, compute old `my_rsvp_eligible` (current
  CalendarController SQL) vs new (derived). The diff must be empty
  except stale lapsed-member grants deliberately not carried.
  **Ran 2026-07-31 against a prod clone with (reworked) migration 250
  applied: 2 diffs total, both person 22428 (Amrit Das, genuinely
  lapsed) — zero unexplained.** An earlier draft with a one-home-team
  mutex produced 167 additional diffs; importing cross-team grants as
  direct membership (decision 5) eliminated them entirely. Backfill on
  prod data: 2707 rows, 515 active, 493 squad-pool (`on_roster=false`),
  77 persons on multiple official teams. Verified idempotent (re-run
  adds zero rows). Re-run the harness on prod itself at cutover.
- **Cutover order:** freeze roster writes (minutes) → re-run backfill →
  deploy new backend → spot-check `#my` → unfreeze.
- **Rollback:** redeploy the old backend image — old tables are intact
  until Phase 3, and `fh_event_rsvps` is untouched by the whole
  migration, so RSVPs submitted during the new-code window survive a
  rollback. Roster placements made during that window would need
  replaying into the old tables (window is minutes; acceptable).

**Phase 3 — drops (after Phase 2 verified in prod)**
- Triggers: `fn_grant_default_rsvp_eligibility`,
  `trg_check_roster_membership` (re-express membership-requirement check
  app-side or against `team_persons`).
- Tables: `player_rsvp_eligibility`, `roster_assignments`, `rosters`,
  `roster_columns`, `team_roster_sources`, `working_rosters`.
- **Chat-events family DESCOPED from Phase 3** (2026-07-31): scoping
  showed `chat_events`/`chat_event_rsvps` are not two stray reads but
  ~20 sites across `EventController`'s match-day/GroupMe/lineup
  surfaces plus `EligibilityController`'s session windows.  Dropping
  them is its own modernization project (move those surfaces to
  `fh_events`/`fh_event_rsvps`), to be scoped separately — not a
  side-effect of this ADR.
- Columns: `teams.is_pool`, `teams.roster_source`.
- Views: redefine `v_team_members` on `team_persons` or drop.
- Rows: pool teams 908/909 (after nothing references them).

## Open items

- **918–923 mystery** (teams recorded as created by migration 232,
  absent from prod, sequence advanced, no code path deletes teams —
  almost certainly a manual DELETE): unexplained but now inconsequential
  — those pool teams are obsolete. Remaining action: none, beyond not
  numbering any future migration against those ids.
- **`fh_events.category`**: same denormalization smell as `domain`
  (derivable from tagged teams' `gender_category`); only load-bearing
  for team-less events (staff meetings). Proposal: derive when teams are
  tagged, store only for team-less. Decide during Phase 2.
- **Coach side**: `team_coaches` stays as the coach membership table
  (eligibility clause already uses it). `coach_rsvp_eligibility` not yet
  traced — audit during Phase 2; likely shrinks the same way.
- **Not yet traced**: `player_eligibilities`, `eligibility_policies`
  (division-rules engine — separate concern), `coach_assessments`
  (possibly dead — verify before assuming).
- **Numbering collisions**: two `107-*.sql` and two `232-*.sql` pairs
  exist; harmless to the runner (filename-keyed) but worth avoiding
  going forward.
- **Dev DB divergence (unrelated, found while testing)**: migration
  `243-us-soccer-game-model-full-population.sql` fails on the dev
  stack's data (NULL `phase_id` in `club_game_model_principles`), so
  `make migrate` against `footballhome_db_jbreslin` stops at 243.
  Migration 250 was applied to dev directly, bypassing the runner.
  Needs a dev-data fix or a fresh prod restore of the dev DB.
- **Girls**: no home teams exist; when girls events start, they need
  either first official teams or a `girls_training` internal group —
  data-only either way.

## Links

- Bug: `#my` RSVP blocked for boys rostered before 2026-07-19 (Sheldon).
  Under this plan it is fixed by Phase 1's backfill + Phase 2's derived
  eligibility, not by patching `player_rsvp_eligibility`.
- Superseded draft: `database/migrations/249-…-backfill.sql` (delete in
  Phase 0).
- Unrelated in-flight work on this branch (`sim/slice-33-4-attacker-bag-lock`):
  `/columns` endpoint on Boys/Mens roster controllers,
  `PersonLinker::closeStaleMemberships` — different Sheldon issue, don't
  conflate.
- Standing principles: normalize the DB, OOP, pure JS frontend,
  C++-first backend.

## Session update (2026-08-05) — status + next steps

Picking this back up mid-session (via `#my`/attendance work, unrelated
entry point) surfaced that Phases 1–2 are further along than this doc's
"migration not yet started" status line suggests. Correcting the record
and queuing the next concrete steps, since we're pausing before
finishing (back after practice).

**Confirmed already applied**, migrations `250`–`255` (2026-07-31 —
2026-08-02): `teams.kind`/`roster_columns` fold-in, `team_persons`,
APSL/Liga 1/Boys Trialists+Reserves internal groups (924–929),
season-reset of `on_roster`. Verified live against `schema_migrations`.

**`teams.is_active`** (migration `262`, this session) — a small
*addition* on top of this ADR's design, not part of it. Gap it fills:
`kind`/`board_archived_at`/`board_sort_order` describe board
*presentation*, not "is this team operationally real right now" — a
team can lack a board_sort_order without being defunct. `is_active`
is that flag, read by `MensTeamColumns` (board columns) and
`AuthController::handleCoachTeams` (coach team-picker) — nowhere else,
so it can't affect RSVP/attendance/event-tagging. Applied and correctly
defaults `true`; only the 6 previously-`board_archived_at`-set Lighthouse
teams (903, 904, 905, 908, 909, 915) came out `false`.

**Correction to a mid-session assumption**: 924–929 (the Trialists/
Reserves `kind='internal'` teams) having `club_id = NULL` is *by design*
per decision 1 ("internal groups... connect to nothing"), not a gap —
no action needed there, and no `club_id` should be set on them.

**Queued 2026-08-05, resolved 2026-08-06:**
1. ✅ **Done** (migration 263). Renamed `912`/`913`/`914`, dropping the
   "(Admin)" suffix ("U8 Boys (Admin)" → "U8 Boys", etc). Cosmetic, no
   conflict with `kind='internal'` already carrying the real semantic.
2. ✅ **Already satisfied, no action needed.** Re-checked 2026-08-06:
   migration 262's backfill (previously-`board_archived_at`-set →
   `false`, column default `true` otherwise) already produced exactly
   the table below — no separate backfill was required.
3. ✅ **Resolved: delete.** `915` "Dues Owed (Boys)" had zero
   `team_persons` rows ever, and real dues/payment status already
   lives on `players.is_paid_up_to_date` /
   `persons.leagueapps_payment_status`, independent of team
   membership — keeping it as a dormant `admin_bucket` team would just
   be unused surface. **Not yet executed** — deferred to a follow-up
   pass (this session only ran migration 263, items 1/5/6).
4. `908`/`909` (Practice/Pickup) — still not deleted, per this ADR's
   own Phase 3 criterion ("after nothing references them"): `909`
   still has one live `fh_event_teams` row. Leave `is_active=false`
   until that last event gets retagged and Phase 3 removes the rows
   for real.
5. ✅ **Done** (migration 263). Dropped `roster_columns` (17 rows,
   folded into `teams` by migration 250) and `coach_rsvp_eligibility`
   (72 rows — dropped its sync trigger
   `trg_sync_coach_rsvp_eligibility` /
   `fn_sync_coach_rsvp_eligibility_from_team_coaches()` first). Both
   confirmed zero backend/frontend reads before dropping. This *is*
   the Phase 2 coach-side audit this doc calls for in Open Items.
6. ✅ **Done** (migration 263). Dropped the two dead `clubs` rows,
   confirmed zero references across every table with a `club_id` FK
   first: `id=20004` ("Lighthouse"), `id=20010` ("Lighthouse Boys Club
   U23").

**Still open:** item 3's actual `DELETE FROM teams WHERE id=915`, and
the `club_sections` migration below (not started).

**LH team active/inactive table (club_id=134), as decided:**

| id | name | → |
|---|---|---|
| 916, 917, 911, 912(→U8 Boys), 913(→U10 Boys), 914(→U12 Boys), 122, 35, 120, 121, 924, 925, 926, 927, 928, 929, 901 | (16 on-rosters teams + Tri County Women) | `is_active = true` |
| 903, 904, 905, 908, 909 | (off-season/pool, kept per item 4 above) | `is_active = false` |
| 915 | Dues Owed (Boys) | pending decision (item 3) — delete, or keep `is_active=false` |

### New scope this ADR didn't cover: club sections (Mens/Boys/Girls/Womens)

Separate from roster membership — this is about the **club/organization
hierarchy**, not team membership, so it's additive to this ADR rather
than part of it.

**Problem**: "Mens Club"/"Boys Club"/etc. (the program-level split under
Lighthouse) only exists today as the bare string `teams.gender_category`
— no real entity, nothing to hang section-specific config on, no
composed display name ("Lighthouse Mens Club") without hardcoding it
somewhere.

**Decision**: `clubs.organization_id` already supports one organization
holding multiple clubs (`clubs`' own doc comment gives "Boys Club" as
the literal example) — never actually used that way (every org today
has exactly 1 club). Rather than reuse `clubs` rows for sections
(rejected — `clubs.sport_id` already means a club is scoped to one
sport; sections are a different, orthogonal axis), add a small generic
lookup table, since section names ("Mens"/"Boys"/etc.) have no
per-club attributes of their own — same shape as `match_types`/
`admin_levels`:

```sql
CREATE TABLE club_sections (
    id         SERIAL PRIMARY KEY,
    name       TEXT NOT NULL UNIQUE,   -- 'Mens','Womens','Boys','Girls'
                                        -- (match existing gender_category values)
    code       TEXT,
    sort_order INTEGER
);
-- seed: Mens/M/1, Womens/W/2, Boys/B/3, Girls/G/4

ALTER TABLE teams ADD COLUMN club_section_id INTEGER REFERENCES club_sections(id);
```

A team's full section applies only to `kind='official'` teams (internal/
admin_bucket teams stay unlinked from `club_id`/`club_section_id`, same
as they're unlinked from `division_id` today — consistent with decision
1's "connect to nothing"). No junction table — `(club_id,
club_section_id)` on the team row itself is the relationship. Display
label ("Lighthouse Mens Club") is composed at read time by joining
`organizations`/`clubs`/`club_sections`, never stored. `gender_category`
stays as-is for now (read by 8 backend + 6 frontend files) rather than
a big-bang replace — `club_section_id` becomes the real relationship in
parallel, individual screens migrate onto composed labels opportunistically.

**Not yet written**: the actual migration for `club_sections` +
`teams.club_section_id` + backfill from `gender_category` for the 16
Lighthouse official teams. Next session.
