# TODO

Running list of known issues and follow-ups. Newest items at the top.

## Google Workspace signup (blocks real password-reset email delivery)

Code for the password-reset flow is fully deployed as of 2026-07-05:
`POST /api/auth/forgot-password`, `POST /api/auth/reset-password`,
`fh::mail::send()` SMTP helper (libcurl), `/reset-password.html`
landing page, two-button login redesign, per-IP + per-user rate
limits, `password_reset_tokens` table (migration 091).  End-to-end
tested via log-scraping — the token INSERT + reset + login round-trip
works.  Only blocker left is a real SMTP sender.

Decision: Google Workspace Business Starter ($6/mo) on
`footballhome.org`, so automated mail sends from
`notifications@footballhome.org` instead of a personal Gmail address.
See `/memories/session/google-workspace-setup.md` for the extended
notes.  Fallback if Workspace is delayed: personal Gmail +
16-char App Password — same env-var shape, zero code change.

Checklist (user to complete in main chat):

- [ ] Sign up at https://workspace.google.com/business/signup — Business
  Starter, domain `footballhome.org`, primary user `jbreslin`.  Use
  `jbreslin33@gmail.com` only when the form asks for a "current email"
  (receipts + recovery); the new account is separate from personal Gmail.
- [ ] Verify domain: paste the `TXT` record Google gives you into the DNS
  registrar for `footballhome.org`.  Wait 5–30 min.
- [ ] Add the 5 MX records Google gives you at the same registrar.
- [ ] Turn on 2FA on the new `jbreslin@footballhome.org` account
  (myaccount.google.com/security).
- [ ] Add the 6 free aliases via admin.google.com → Users → jbreslin →
  Add alternate email addresses:
    `admin@`, `notifications@`, `noreply@`, `support@`, `coach@`,
    `signups@`.
- [ ] Generate an App Password at myaccount.google.com/apppasswords
  (label "footballhome-app-smtp") and copy the 16-character password.
- [ ] Add the following to `env` (or send the App Password back to this
  chat and I'll do it):
    ```
    SMTP_HOST=smtp.gmail.com
    SMTP_PORT=587
    SMTP_USER=jbreslin@footballhome.org
    SMTP_PASS=<16-char App Password>
    MAIL_FROM=notifications@footballhome.org
    MAIL_FROM_NAME=Football Home
    ```
- [ ] Restart backend: `podman-compose up -d backend`.
- [ ] Trigger a real forgot-password from the login page and confirm the
  reset email arrives at a non-Google mailbox (Yahoo/iCloud test).

## Instagram token auto-refresh cron (preventative)

Resolved 2026-06-30: regenerated `IGAAl…` long-lived token via
Instagram-business-login flow at
`https://developers.facebook.com/apps/1177405337805460/instagram-business/API-setup/`.
Re-issuing also changed the IG business user ID, so `INSTAGRAM_USER_ID`
in `env` was bumped from `26233831926285183` → `27772857462308985`
and `post-to-instagram.js` was patched to read it from env (was
hardcoded). Poster 16 posted as media `18123919870732720`.

To prevent another lockout, add a 50-day cron that calls
`GET https://graph.instagram.com/refresh_access_token?grant_type=ig_refresh_token&access_token=$INSTAGRAM_ACCESS_TOKEN`,
parses the new token from the response, rewrites the env line, and
re-encrypts env.age. 50 days keeps a 10-day safety margin inside
the 60-day expiry window. Only works while the existing token is
still valid, so cron must fire reliably.

## Leads funnel — email → registration conversion lift

Current state (2026-06-29): ~521 leads in last 6 weeks, ~67% emailed,
~2/35 boys converted, 0/32 girls (Girls LA program was set to "opens
soon" — being fixed manually).  Single-touch 5-7% conversion is low
end of normal for a Meta lead-form funnel; the two interventions
below should push it toward 15-20%.

- [ ] **Meta lead-form thank-you-screen CTA** (no code; Ads Manager).
  In each active Meta lead form (Ads Manager → Instant Forms → form →
  Completion step), add a "View website" button pointing at the LA
  program URL for that funnel.  Captures the lead AND lets high-intent
  submitters tap straight through to register without leaving the
  Facebook in-app browser.  Mirrors the per-funnel LA URLs in
  `frontend/js/screens/leads.js#funnelContext()`:
    - Boys Club forms (1704106777282059, 2471488896628970) → URL_BOYS
    - Girls Club forms (1571742281184926, 1008195014960429) → URL_GIRLS
    - Men's Club forms → URL_MEN
    - Women's Club forms → URL_WOMEN

- [ ] **Multi-touch email follow-up sequence** (code).
  Currently we send exactly one email per lead (day-0 informational +
  CTA) and nothing else.  Add day-3 conversational nudge + day-10
  social-proof nudge for leads that haven't converted.  Two-part build:
    1. Backend surface — schedule + queue model.  Likely a view that
       joins `leads` against `lead_contacts` to compute "leads who got
       email 1 N days ago and have NOT converted (no matching active
       LA registration by email)."  Surface on `/api/leads` so the
       leads screen can render a "Follow-up due" filter / tab.
    2. Frontend — two new template variants in `funnelContext()`:
       a. **Touch 2 (day 3, conversational).**  No LA link.  Goal: get
          a reply.  Tone: "Hi {first} — any questions about practice
          times or whether {program} is the right fit?  Happy to hop
          on a quick call."
       b. **Touch 3 (day 10, social proof + urgency).**  "We had {N}
          new players join this week — {next_practice} session is open
          if you want to drop in before committing." LA link returns.
    3. Optionally: detect-and-suppress for leads who replied to touch
       1 (currently no inbound mail integration; manual mark-as-done
       button on the lead card would be enough).

## Bugs

- ~~**`PersonMerge::childTables()` catalogue is stale**~~ — FIXED
  (2026-06-27). Removed dropped tables (`chat_non_players`,
  `chat_external_members`) and added three missing ones with FKs to
  `persons(id)`: `sessions`, `event_rsvps`, `magic_link_tokens` (all
  `NoPersonUnique` except `event_rsvps` which has UNIQUE(chat_event_id,
  person_id) → `UniquePersonPlusCols`). Verified by completing the Dylan
  merge end-to-end with a merge → unmerge → re-merge cycle
  (`person_merges` rows 11+12). Forward-compatible with legacy snapshots
  (missing keys yield 0-row results in unmerge).

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
  2026-06-25.

  **Update 2026-06-27**: Musa (22218→1359), Gian (22223→14454), and Karim
  (22245→1315) were merged earlier in the day via an unknown path (rows
  8/9/10 in `person_merges`). Dylan stub (22233) merged into Dylan
  Martinez (22311) once the catalogue bug above was fixed (rows 11
  reverted, 12 live). Decisive evidence: Dylan Martinez joined the exact
  same 3 teams (903 U23 Men, 908 Training Lighthouse, 909 Pickup
  Lighthouse) on the exact day (2026-06-25) the stub left them, and the
  stub had zero ancillary data. Rosters cascade-deleted with the stub's
  players row are not restorable from snapshot (rosters not in the
  merge catalogue) — acceptable here because all 3 had `left_at`
  predating the merge.
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

- ~~**`DivisionController` other handlers**~~ — DONE (2026-06-27).
  `handleGetClubDivisions`, `handleGetDivisionPlayers`, and
  `handleUpdateDivisionPlayer` were all broken: UUID regexes on integer
  IDs, references to a nonexistent `team_division_players` table, and a
  fallback that updated `users.id = playerId` (wrong table, wrong id).
  Rewrote against the actual schema (`teams.club_id`, `teams.division_id`,
  rosters for active/historical). `handleUpdateDivisionPlayer` now updates
  the `persons` row reached via `players.person_id`, accepts but ignores
  the unsupported `status`/`registrationNumber` fields, and refuses to
  edit a player that isn't on a team in the supplied division (verified
  with a cross-division write attempt). Live-tested all three endpoints
  against `/api/clubs/134/divisions`, `/api/divisions/73/players` (43
  active / 120 total), and `PUT /api/divisions/73/players/22205`.

  Follow-up: ~~the frontend modal collects `status` and
  `registrationNumber` that the backend silently discards.~~ DONE
  (2026-06-27). Dropped both fields from
  `frontend/js/screens/DivisionRosterScreen.js` (modal inputs, card
  display, and PUT body) plus the inactive/suspended/waitlist options
  from the status filter (filter now only offers Active / All, which
  is what `handleGetDivisionPlayers` actually supports). Revisit if/
  when a per-division-player metadata table is added.
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
