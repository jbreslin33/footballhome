-- 1496 (2026-11-18) — 🍺 Barn Night is on the schedule every week, from its
-- title alone.  Owner 11/18: "i will add a barn night in gcal unless you can
-- see the one they have in there already its this friday" → "and if you can
-- see it then always have it on schedule".
--
-- The barn night is a weekly recurring Google event ("Barn Night", Fri
-- 7 PM–midnight) with no description, so the tag classifier (it needs a
-- `Team:` line) never picked it up.  gcal_title_rules: an untagged event on
-- a calendar whose title matches gets this tag text as its description, then
-- classifies like any tagged event.  Only soccer@ (calendar 1): the same
-- series is also on sports@ (calendar 2) and must not become a second event.
-- A real `Team:` description always wins over a rule.  Add a rule = a row.
BEGIN;

CREATE TABLE IF NOT EXISTS gcal_title_rules (
    id              serial PRIMARY KEY,
    calendar_id     integer NOT NULL REFERENCES gcal_calendars(id),
    summary_pattern text    NOT NULL,          -- POSIX regex, case-insensitive (~*)
    dsl             text    NOT NULL,          -- tag text applied as the description (Club: / Team: / Kind: …)
    is_active       boolean NOT NULL DEFAULT true,
    note            text,
    created_at      timestamptz NOT NULL DEFAULT now(),
    UNIQUE (calendar_id, summary_pattern)
);
COMMENT ON TABLE gcal_title_rules IS
  'mig 1496: untagged Google events classified by title — summary ~* pattern on that calendar → dsl used as the description. A tagged description (Team:) always wins.';

INSERT INTO gcal_title_rules (calendar_id, summary_pattern, dsl, note)
SELECT gc.id, '^\s*barn\s*night\s*$', E'Club: Mens\nTeam: APSL, Liga 1\nKind: Barn Night',
       'Weekly Friday barn night (21+) — counts as a practice attended (owner 11/18)'
  FROM gcal_calendars gc WHERE gc.id = 1
ON CONFLICT (calendar_id, summary_pattern) DO NOTHING;

COMMIT;
