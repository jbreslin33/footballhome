# All messages in the DB — status and what's left

Owner rule (2026-09-17): **"we need all messages in db no hard code not even
for nudges."** No player/parent/lead-facing wording, link, fallback word or
mailbox address lives in C++ or JS. Code names a template and hands over
facts; the DB holds the sentences.

An inventory that day found 46 hardcoded sites in 18 files. Passes 1 and 2
are done and live, and so is most of pass 3 (3a, below). **What is left:
the three season one-offs in leads.js, `lib/program-info.js`, and pass 4** —
this file is the hand-off.

## How it works (use this for everything that follows)

| Piece | Where | What it does |
|---|---|---|
| `message_templates` | table (mig 098, +364–368) | One row per (kind, tier): `subject`, `body`. `client_side = true` rows may be loaded by the browser. |
| `MessageCopy` (C++) | `backend/src/models/MessageCopy.{h,cpp}` | Renders a (kind, tier) with tokens; appends the SMS link hint; builds `sms:` / `mailto:` / Gmail hrefs from `clubs.outreach_email`. |
| `MessageCopy` (JS) | `frontend/js/lib/message-copy.js` | Same syntax in the browser. `await MessageCopy.load(this.auth)` in the screen's load, then `MessageCopy.render(kind, tier, tokens)` → `{subject, body}` or `null`. **`null` ⇒ draw no button.** |
| Copy endpoint | `GET /api/messages/templates/copy` | Any signed-in user. Returns the `client_side` rows (form links already resolved) + `outreach_email`. |
| `club_forms` | table (mig 365) | External links. Copy says `{form:<code>}`; `fh_fill_form_links(text, club_id)` resolves it server-side. |
| `fh_event_kind_labels` | table (mig 364) | Player-facing name per event kind ("match" → "Game"). Never the gcal title. |
| `WelcomeMessage` | `backend/src/models/WelcomeMessage.{h,cpp}` | The welcome: skeleton + blocks chosen from the player's real schedule. |

Template syntax (identical in C++ and JS):

- `{token}` — the value; if empty, the word from the `kind='fallback'` row
  whose `tier` is the token name (`first` → "there"); nothing if no such row.
- `[[ … ]]` — optional section, kept only when every `{token}` inside has a
  value. Fallback words never apply inside one. Example:
  `Hi[[ {first}]],` and `[[ (up from {from_team})]]`.
- `{form:<code>}` — a `club_forms` link.

Conventions: new copy goes in a **numbered migration** guarded by
`WHERE NOT EXISTS (… kind = … AND tier = …)`; wording changes are an
`UPDATE` in a new migration, never a code edit. `tier` is the voice or
variant (`adult` | `parent` | `firm_dated` …).

## Done

**Pass 1 — backend-written (mig 364–366):** welcome, `#rsvps` reminder,
🔗 LINK (`magic_link*`), 🎟 call-up invites (`event_invite*`), push payloads
(`push`; chat names = `chats.push_label`), password-reset mail, SMS link
hint, fallback words, `clubs.outreach_email`.

**Pass 2 — browser-drafted cards (mig 367–368):** 💸 PAY dues (boys/girls,
men's, `#youth-roster`), `#payments` Reminder/Firm/Final, CONTACT openers,
men's INVITE, `#members` Onboarding, women's REGISTER, bulk composer
subject; `la_dashboard` + `womens_league_registration` forms.

**Removed rather than converted:** the `#my` Remind + "Text/Email N No
Response" buttons (reminders live on `#rsvps` now).

**Pass 3a — `#leads` / `#messages` chips (mig 369):** touch-1 intro,
Register, Welcome, Pickup, Close, More info (wrapper), Field, Practice /
Games / Schedule, Cost, Fall Format, the men's "set availability"
broadcast — table rows 1, 5–14 below. How it works:

- Kinds are `lead_<fact>` (programme name, fee, practice days, venue,
  schedule link… rendered first, handed on as a token of the same name) and
  `lead_<message>`.
- `tier` is looked up most-specific first: funnel label → base funnel
  (`U23 Men` for `U23 Men + PR`) → audience (`boys|girls|youth|men|women`) →
  `parent` (any youth funnel) → `all`. One row covers every funnel until a
  funnel needs its own wording; add that funnel's row by migration.
- `LeadsScreen.funnelContext()` builds `{tiers, tokens}`;
  `LeadsScreen.leadCopy(kind, tiers, tokens)` renders; a chip exists only
  when its row does. Lead tokens (`{first}`, `{coachFirst}`…) pass through
  and are filled per lead by `fillTemplate()` → `MessageCopy.fill()`, so the
  fallback words are the DB's.
- New `club_forms`: `mens_handbook`, `casa_grassroots_roster`,
  `casa_grassroots_schedule`, `u23_mens_schedule`, `maps_outdoor`,
  `maps_indoor`, `footballhome`.
- Tests seed the sandbox from `tests/fixtures/message-copy.json` — the copy
  endpoint's payload dumped from the DB. Re-dump it after a copy migration
  if a test asserts on the new wording.
- Wording changed on purpose (see the migration header): men's practice is
  now the real Tue–Fri + Sat calendar (no "pickups count as practice"),
  youth 3rd-grade-and-up includes Fridays, women no longer see "$1 locks
  your spot", the dead "next pickup" branch and the TODO schedule chip are
  gone.

**Pass 3b — programme description (mig 370):** `lib/program-info.js` holds
no wording. The description is `program_*` rows in a small markup
(`### Heading`, `- bullet`, `  - sub-bullet`, `**bold**`) that the file
turns into both HTML and plain text; `program_description` is the skeleton
whose `{program_*}` tokens are the rows of that kind. Tier lookup: `youth →
all`, `men → adult → all`, `women → all`, `adult → all`. Fees and venues are
the `lead_fee` / `lead_pricing` / `lead_venue` rows — one place for a price
or an address. Rows a signed-out visitor may read are flagged
`message_templates.is_public` and served by `GET /api/public/program-copy`
(the flyer-QR pages have no login). Tests seed from
`tests/fixtures/program-copy.json` (that endpoint's `data`, dumped from the
DB). Wording changed on purpose: the adult schedule is the real calendar
(Tue–Fri + Sat, all practice — no "pickup").

**Deleted rather than converted (stale):** `spring-renewal*`,
`practice-schedule*` ("Summer/Fall 2026"), `alumni-return-*` ("rest of
July", "Fri Aug 7") in `leads.js`; `scripts/setup-lead-forms.py` (May 2026
one-off).

**Pass 4 — Meta ad copy (mig 371):** `scripts/ads/create-ad.js` reads each
ad's caption (`meta_ad_caption`), lead-form intro card (`meta_context_card`:
subject = title, body = one bullet per line) and thank-you page
(`meta_thank_you`) by ad key over its DB connection (`PG*` env, same
defaults as `publish-promo.js`); tier `all` is the default form;
`meta_button` holds the two button labels; the Instagram URL is
`club_forms.instagram`. A missing caption row stops the build. Still in the
script: lead-form questions, targeting, image URLs, budgets — config, not
wording. Meta forms can't be edited in place: a changed row affects the
NEXT form created. `node scripts/ads/create-ad.js <key> --dry-run` prints
the caption and card titles it would use.

## Open questions for the owner

- Practice days are typed into `lead_practice` rows. `WelcomeMessage`
  derives them from the calendar; doing the same for leads needs a backend
  endpoint.
- ⚽ Pickup chip still offers men "the next pickup" though men's sessions
  are all practice now. Keep for women only?

- `frontend/js/screens/rosters.js` — the player-view "Welcome" card drafts an
  email **to** the club mailbox. Looks vestigial; delete?
- `POST /api/my/events/push-remind` has no caller since the `#my` cleanup.
  Add a 🔔 push channel to `#rsvps`, or delete the endpoint + the
  `push/rsvp_remind` row?
- `#members` Onboarding still signs off "--James Breslin Soccer Director at
  Lighthouse" (in the DB now). Switch to a `{sender}` token?
- `WebPushService.cpp` falls back to `mailto:soccer@lighthouse1893.org` for
  the VAPID subject when the env var is unset — config, left alone.

## How to verify a conversion

- `node --test tests/` (one known unrelated failure:
  `admin-club-game-model-readme`).
- The frontend is bind-mounted, so JS is live on save — stage risky edits and
  bump the `?v=` stamp in `frontend/index.html`.
- Backend: build the image, then check the **running container's image id**
  matches the new build (`make deploy` can leave the old one running).
- The copy endpoint works for any signed-in user, so
  `await MessageCopy.load(app.auth); MessageCopy.render(kind, tier, {...})`
  in the browser console on footballhome.org is a real end-to-end check.
- Sends themselves are drafts: a button opens Messages/Gmail pre-filled and
  nothing goes out until the admin hits send.
