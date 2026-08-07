# 2026-08-07 — LA "inactive" sub-program (2-months-behind workflow)

## Context

1st-Friday-of-month billing run: members who hit 2 months unpaid get
moved in LA from the category's active "members" sub-program into a
new **"inactive"** sub-program. LA confirms each of men/women/boys/girls
now has exactly 3 sub-programs: **members** (active), **inactive**,
**pickup** — inactive is a peer of pickup, not a variant of active.

Desired behavior (owner directive 2026-08-07):
- Inactive members are cut from **everything** — rosters, squads, pool
  eligibility, RSVP — same as if they'd fully left.
- Except the **payments screen**, which still needs to show them (in a
  distinct section) so ops can monitor for reactivation and restore
  them once they pay.
- Planned follow-on (not yet needed/built): if they still haven't paid
  after another month, move them from inactive → **pickup** as the
  final landing spot (per-category pickup sub-program already exists).

## What's implemented

**`leagueapps_programs`** (migration 266) gained an `inactive` variant
alongside `active`/`pickup`. Confirmed + registered so far:

| category | variant  | program_id | status |
|----------|----------|------------|--------|
| men      | inactive | 5093107    | live |
| women    | inactive | 5114228    | live |
| boys     | inactive | ?          | **blocked** |
| girls    | inactive | ?          | **blocked** |

**Payments screen** (`PaymentsController.h/.cpp`, `PersonPayments.h/.cpp`,
`frontend/js/screens/payments.js`):
- `/api/payments/<category>/members` now syncs + loads both the active
  and (when configured) inactive program for that category.
- Response tags each row `variant: "active" | "inactive"`; every row
  also carries the real LA club `programName` (used for email-subject
  text — see below).
- Frontend renders a **🚫 Inactive — Monitor for Reactivation** section
  above the Overdue/Never/Behind/Current groups; summary strip's
  "Members" count and the "All" status-chip count both exclude the
  inactive section so they read as active-roster totals.
- Per-category `*InactiveProgramId_` fields in `PaymentsController`
  default to the confirmed IDs (env-var overridable, matching the
  existing `LEAGUEAPPS_*_PROGRAM_ID` convention); boys/girls default to
  `0` = "not configured", which the routing/sync code already treats as
  a no-op (skips cleanly, no boys/girls Inactive section yet, nothing
  breaks).

**Roster/squad/pool cutoff** (`LaPool.cpp`, migrations 267-269):
- `LaPool.cpp` §3a's pool-eligibility filter now excludes anyone with
  an open `paused`- or `inactive`-variant membership (was `paused`-only
  before — `paused` itself is currently unused/dead but left for
  compat).
- `fn_sweep_invalid_rosters()` (migration 267) now sweeps `team_persons`
  the same way it already swept the older `roster_assignments` table —
  closes the gap where `MensRoster.cpp`'s 2026-08-02 "FH-only squad
  cards" backdoor (lets a coach keep someone on a real squad column
  despite an LA registration gap) kept inactive members visible.
- Migration 268 adds a **second, unconditional** sweep rule: anyone on
  an `inactive`-variant membership comes off *every* team, not just
  ones with a `team_membership_requirements` row. Needed because
  Trialists (924/925/926/927/928/929) and Liga 1 U23 (461) have no
  requirement rows configured (by design, for genuine walk-on
  trialists) — the requirements-gated sweep alone silently skipped
  those teams for otherwise-inactive members.
- Migration 269: dropped mens/boys **pickup** from
  `team_membership_requirements` for APSL/Liga 1/Liga 2/Adult League
  (teams 35/120/121/122) — pickup was never supposed to grant real-squad
  eligibility (migration 097's own stated intent: "Pickup pool team
  ONLY... cannot see Practice/Games"), but the requirements table
  incorrectly listed it. Caught via a real case (see below).
- `fn_sweep_invalid_rosters()` already runs on every mens/boys roster
  page load (`MensRosterController.cpp`, `BoysRosterController.cpp`),
  not just via the `person_la_memberships` trigger — so this is
  self-healing per request, not just per membership-change event.

**Email-subject fix** (`payments.js`): the Gmail-compose reminder
subjects said `"Football Home — payment reminder"` etc. — members don't
pay FH anything, they pay Lighthouse dues, so that read as unrecognized
and probably contributed to non-response. Now uses the real LA club
name (`m.programName`, e.g. *"Lighthouse Men's Club 1893 Soccer
Membership"*) instead.

## Verified live (2026-08-07)

- **Oumar Barry** (person 3487, moved to men-inactive): confirmed via
  live API — shows in payments Inactive section with correct
  `programName`; confirmed via DB — zero open `team_persons` /
  `roster_assignments` rows anywhere (was previously still showing on
  Liga 1 U23 (461) and, for others in the same cohort, APSL Trialists
  (925) until migration 268).
- **Kay Asante** (person 22430): different case — never moved to
  inactive, just dropped from active to Pickup same-day. Was still
  showing on Liga 1 (120) because Pickup satisfied that team's
  (incorrect) requirement row. Fixed by migration 269; confirmed swept
  (`removed_reason = 'no_valid_membership'`).

## Open items for tomorrow

1. **Boys/girls inactive program IDs are still unknown.** Owner gave
   three URLs total: men (5093107), women (5114228), and one more
   (5114231) ambiguously labeled "boys inactive girls inactive" — never
   disambiguated, and no fourth URL was ever given. LA's public API has
   no program-metadata-by-id endpoint (confirmed by probing via
   `/api/admin/la-probe` with a minted admin token — registrations-export
   returns 200+empty for *any* program id, doesn't validate existence or
   return a name), so this can't be resolved from the API — needs the
   owner to state directly: which category is 5114231, and what's the
   other id. Once known: one migration (copy migration 266's pattern) +
   bump the two `*InactiveProgramId_` defaults in
   `PaymentsController.cpp` (or set the env vars) — no other code
   changes needed, everything else (LaPool exclusion, payments routing,
   roster sweep) is already category-generic.
2. **`YouthRosterController` (girls' roster screen) never calls
   `fn_sweep_invalid_rosters()`** — unlike `MensRosterController` /
   `BoysRosterController`. Not yet confirmed whether this is a live gap
   (i.e. does the girls screen even use a `team_persons`-backdoor
   mechanism analogous to Mens' "FH-only squad cards" that would need
   sweeping) or a non-issue (if girls rendering is purely
   LA-registration-driven with nothing stale to sweep). Needs
   investigation before boys/girls inactive goes live, so a girls
   player moved to inactive doesn't hit the same silent-leftover bug
   Oumar/Kay did.
3. Pickup-as-final-landing-spot workflow (inactive → pickup after
   another month unpaid) is a manual LA-side action for now — the
   `pickup` variant/program already exists per category, no FH-side
   work identified as needed unless the owner wants an explicit
   reminder/tracking mechanism for that second transition.
