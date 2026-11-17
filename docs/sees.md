# 👁 SEES — who is asked about a game

Owner 2026-11-17: "there is rosters, sees. and one game sees" — "sees can
over ride the default of seeing due to being on roster" — "if its one off
that is invite".

Three facts. Nothing is copied per game.

| Level | Table | Meaning |
|---|---|---|
| 1. Roster | `official_roster_names` + `official_roster_sources.games_team_id` (since `games_from`) | on the league list → that team's games by default |
| 2. Sees | `person_team_sees` (person, team, `sees` yes/no, `ended_at`) | the exception for **every** game of a team: **yes** = standing call-down (needs a league rule in `team_invite_caps`, trigger-checked), **no** = 🚫 restrained |
| 3. One-game sees | `event_person_sees` (game, person, `sees` yes/no) | **yes** = one-off invite (who, sms/email/copy), **no** = not this game |

Each level overrides the one above it: one-game sees beats sees, and sees
beats the roster. No row = the level above decides. Ending a sees row
sets `ended_at`, so its past games stay computed (the window is
`created_at ≤ kickoff < ended_at`).

Our own team row (`team_persons`) still gives a man his team's events
directly. The list rule skips anyone who already has a row on the games
team.

## Reading it

- `fh_event_invites` is a **view** of the result: the one-game yes rows,
  plus every game a sees-yes or a list gives him that has no one-game row.
  Every older reader (RSVP board, reminders, No Response, Game Center,
  carpool, messages, dashboard) reads it unchanged. `revoked_at` is always
  NULL.
- `fh_event_invited(event, person)` answers one pair directly (the
  calendar calls it per event).
- `fh_person_sees(ids)` builds the card's 👁 SEES pills: `standing_invite`
  = sees yes, `restrained` = sees no, `official_list` = from the roster.

## Writing it

- `POST /api/person-sees/set {person_id, team_id, sees: true|false|null}`
  (club admins): ＋ L1 ⬇ / ✕ / 🚫 / ↺ on the SEES pills. `/restrain` is the
  same call.
- Game Center ⭐ standing toggle → `person_team_sees` (POST …/auto-invite).
- Game Center invite / CALL IN → `event_person_sees` yes; revoking one
  → `event_person_sees` no. That beats a standing call-down or the list
  for that game only.

## Retired (mig 1450)

`team_auto_invites`, `game_restraints` and the copied `auto`/`roster`
invite rows (kept as `*_retired_1450` tables for rollback), plus the six
sync triggers/functions that kept the copies in step, and the ⭐
CALL-DOWNS group and chip on #teams.
