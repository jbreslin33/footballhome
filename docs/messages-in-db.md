# All messages in the DB — status and what's left

Owner rule (2026-09-17): **"we need all messages in db no hard code not even
for nudges."** No player/parent/lead-facing wording, link, fallback word or
mailbox address lives in C++ or JS. Code names a template and hands over
facts; the DB holds the sentences.

An inventory that day found 46 hardcoded sites in 18 files. Passes 1 and 2
are done and live. **Pass 3 and 4 are not started** — this file is the
hand-off.

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

## Pass 3 — `#leads` / `#messages` chips (NOT STARTED — the big one)

Everything below is in `frontend/js/screens/leads.js` unless noted.
`LeadsScreen.messageTemplate()` / `messageSnippets()` are **also consumed by
`#messages`** (`frontend/js/screens/messages.js` ~316–323), so each snippet
renders on two screens — convert the source, check both.

Line numbers are from 2026-09-17 and will drift; grep the quoted text.

| # | Function / snippet id | What it says | Notes |
|---|---|---|---|
| 1 | `messageTemplate()` | Touch-1 first contact: "Hi {first}, {coachFirst} here — Soccer Director at Lighthouse 1893. Are you looking to join our {program}…" + signature | sms + email; subject = clubTitle |
| 2 | `springRenewalBody()` → `spring-renewal*` | "the Summer/Fall 2026 season is a NEW registration…" | hardcoded practice days, **address 199 East Erie Avenue**, "$1 then $35/month" |
| 3 | `alumni-return-sms`, `alumni-return-followup` | "Hey {first} — James at Lighthouse 1893. Pre-season is on…" | hardcoded human name + pricing |
| 4 | `practiceScheduleBody()` → `practice-schedule*` | "Thanks for registering for the Summer/Fall 2026 season!…" | derive the schedule like `WelcomeMessage` does instead of typing it |
| 5 | `fh-set-availability` | "Hi guys, We track availability for games, practice and pickup…" + 4-step walkthrough + fining line | mentions pickup — men are all practice now |
| 6 | `register`, `register-boys`, `register-girls` | "Great. To register your {son/daughter}… register here: {link}" | link already DB-driven (`leagueapps_programs.registration_url`) |
| 7 | `welcome` (Youth + Adult) | "🎉 … officially a member of the club. Next steps…" | address + Google Maps URL |
| 8 | `pickup` | "Our next pickup: {title} — {when} @ {loc}…" | pulls next pickup from the calendar |
| 9 | `close` (`body` + `smsBody`) | "Great — {closerLine}… Once you're registered, I'll send you a link…" | |
| 10 | `more-info` (`body` + `smsBody`) | wraps the program description (#15) | |
| 11 | `field` | two venues + two Google Maps URLs | venues belong in a table (check `facilities`) |
| 12 | `practice`, `games`, `schedule` | "Practice: {schedule}", "Games are mostly on {day}…", a literal `(TODO — fill this in…)` body | |
| 13 | `cost`, `fall-format` | "{fee} today to lock {whose} spot…", "Fall 2026 season format…" | |
| 14 | constants ~1654–1762 | `MENS_HANDBOOK` (Google Doc), `CASA_ROSTER_URL`, CSL schedule Sheet, CASA schedule pages, `ROSTER_NOTES['U23 Men']`, `fillTemplate()` fallbacks `'there'` / `'Coach'` | URLs → `club_forms`; fallbacks already exist as `fallback` rows |
| 15 | `frontend/js/lib/program-info.js` (whole file) | self-described "single source of truth" for membership/teams/schedule/billing copy; feeds `more-info`, `la-program-description`, `#public-program-info`, `#flyers` | fees (`$35`, `$1 then $35/mo`) and `mailto:soccer@…` are literals |

Suggested approach:

1. Give lead snippets their own kinds (`lead_first_contact`, `lead_close`, …)
   with `tier` = programme/voice, all `client_side = true`. `#messages`
   already lists `message_templates` rows, so most chips become plain rows and
   `messageSnippets()` shrinks to "load + fill".
2. Lead tokens today: `{first}`, `{full}`, `{phone}`, `{coach}`,
   `{coachFirst}` via `fillTemplate()` (leads.js ~2793) and `_personalize()`
   (messages.js ~237). Replace both with `MessageCopy.render` — one filler.
3. Move every URL in #14 and the Maps links into `club_forms`; move venue
   names/addresses to the facilities table if it fits, else a small
   `club_venues` table. Fees belong with the LA programme rows, not in copy.
4. `program-info.js` is also used by public pages (no login). The copy
   endpoint needs a public variant (or a `public` flag on rows) before that
   file can go.
5. Season-specific broadcasts (#2, #4: "Summer/Fall 2026") are one-offs —
   ask the owner whether to convert or delete them.

## Pass 4 — Meta ad scripts (NOT STARTED)

- `scripts/ads/create-ad.js` — `thank_you_page` title/body for 10 lead forms
  ("Thanks — talk soon!", "A Lighthouse 1893 coach will reach out within
  24–48 hours…").
- `scripts/setup-lead-forms.py` — `context_card`, `thank_you_page`, four ad
  message bodies, `website_url`.

These run by hand against the Meta API, not in the app. Have them read rows
(kind `meta_thank_you`, `meta_ad`) over a DB connection or a small JSON
export. Meta forms can't be edited in place — archive and recreate (see the
lead-form notes in project memory).

## Open questions for the owner

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
