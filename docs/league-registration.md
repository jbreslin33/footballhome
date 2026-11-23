# 📝 League Registration (`#league-registration`, mig 1746)

Owner 2026-11-23: "we need to prepare for indoor ppr season … the last 4
docs i uploaded to files are needed filled out. should have a league
registration page for fh? and have these also as check list items but you
pre fill them for me and get them ready to be sent".

A registration with a league is a checklist. The forms are the league's own
Word files (uploaded to 📁 Files), filled in the browser from the rows below
each time they are opened or sent — no filled copy is stored.

## Tables

- `league_entries` — one registration (PPR Indoor 2027): league, club, who
  signs (`director_person_id`), who it goes to (`send_to_name` /
  `send_to_email` — set on the page, not in a migration: third-party
  contact), the fees (`fee_returning_usd` a current team of that league,
  `fee_new_usd` a new one), `payable_to`, `sent_at`.
- `league_entry_teams` — each team entered = the team commitment form's
  answers: age group, male / female, team name, coach and assistant (must be
  coaches of the FH team; name, phone, email come from the person; the
  address boxes override the person's address), home court, court
  availability, four unavailable dates, last season's age group and record,
  `is_returning`, `max_roster`.
- `league_entry_items` (+ `league_entry_item_kinds`) — the checklist. A form
  row has `template_file_id` → `club_files`; `kind` picks how it is filled
  (`club_form`, `team_form`, `roster`); `payment` / `other` are ticks only.

The official roster is not stored: it is the team's live players
(`team_persons` of `league_entry_teams.team_id`), first `max_roster` by last
name, with date of birth and a parent's phone (`person_guardians`, primary
first; the player's own phone if there is no guardian).

## Code

- `backend/src/models/LeagueEntry.cpp`, `controllers/LeagueEntryController.cpp`
  — `/api/league-entries` (club admins): the board, `/team`, `/entry`,
  `/item`, `/send`.
- `frontend/js/screens/league-registration.js` (`LeagueRegistrationScreen`) —
  the page; `_filled(entry, item)` maps the rows onto each form.
- `frontend/js/lib/docx-fill.js` (`DocxFill`) — opens a .docx (a zip, read
  with `DecompressionStream`), writes values over `Label ____` blanks and
  into empty table cells of `word/document.xml`, and zips it again
  (stored, no library). An empty value leaves the blank line in place.

## Sending

✉️ builds every form, posts them to `/send`, and the server emails them from
the club's address to `send_to_email`, cc and Reply-To the admin who pressed
it (words: `message_templates` kind `league_entry`, tier `email`). Only Word
files are accepted (zip magic), 8 MB in all.

## Adding a league / season

Rows by migration: a `league_entries` row, its `league_entry_teams`, and one
`league_entry_items` row per thing to hand in. A new form layout needs its
own `kind` and a branch in `_filled`.

## Not done

- Player photos: the PPR roster wants a photo per player in the numbered
  boxes; FH has no player photos, so those go in by hand.
- Signatures: print and sign (or sign in Word).
