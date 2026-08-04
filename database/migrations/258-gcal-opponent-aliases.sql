-- 258-gcal-opponent-aliases.sql (2026-08-03)
--
-- fh_events.opponent is free text typed into a gcal description's
-- Opponent: tag (see scripts/gcal-classify.js). The #my page wants to
-- show the opponent's crest next to a game card, but matching free text
-- against teams.name directly is unsafe: e.g. "Oaklyn United" as typed
-- is a substring/word-match against THREE different scraped team rows
-- (Oaklyn United FC, ...FC II, ...Nor'Easters II), so guessing would
-- risk showing the wrong club's logo.
--
-- Same shape of problem gcal_team_aliases (migration 121) already
-- solves for our OWN teams' Team:/Club: tags -- a small hand-maintained
-- alias -> team_id table, resolved automatically forever after one-time
-- seeding. This is the opponent-side equivalent: one column (no
-- club/team split needed, opponent is a single free-form string) mapping
-- exactly what ops types in the calendar to the correct teams row.
--
-- New opponents just need one INSERT here -- no code change -- to get a
-- crest automatically; CalendarController falls back to an exact
-- teams.name match, and then to the Lighthouse crest, so nothing ever
-- renders blank.

BEGIN;

CREATE TABLE IF NOT EXISTS gcal_opponent_aliases (
    alias    TEXT PRIMARY KEY,
    team_id  INTEGER NOT NULL REFERENCES teams(id),
    notes    TEXT
);

COMMENT ON TABLE gcal_opponent_aliases IS
  'Maps free-form Opponent: text (as typed in a gcal event description) to the real teams row, for crest lookup on #my. Case/whitespace-insensitive match happens at query time.';

INSERT INTO gcal_opponent_aliases (alias, team_id, notes) VALUES
    ('Persepolis I',    493, 'Persepolis FC (first team)'),
    ('Persepolis II',   504, 'Persepolis FC II'),
    ('Oaklyn United',   28,  'Oaklyn United FC — confirmed 2026-08-03, not FC II or Nor''Easters II')
ON CONFLICT (alias) DO NOTHING;

COMMIT;
