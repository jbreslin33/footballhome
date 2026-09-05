-- 322 — Players per side for each board team (teams.field_size).
--
-- Owner 2026-09-05, Teams board: under each column's "✓ N on roster"
-- tally, show the game format and how many of those On-Roster players
-- are subs — "7v7 · 3 subs". The format is per team, not per age
-- label, and "right now" for the adults (11v11) implies it can change,
-- so it lives on the team row rather than being inferred from the
-- label in JavaScript. NULL = unknown, and the board simply omits the
-- format/subs line for that column.
--
-- Values: U8/U10 7v7, U12 9v9, mens/womens 11v11 (owner). U6 4v4 and
-- U16/U19 11v11 follow US Soccer's small-sided standards — not stated
-- by the owner, adjust here if the club plays them differently.

BEGIN;

ALTER TABLE teams ADD COLUMN IF NOT EXISTS field_size smallint
    CHECK (field_size IS NULL OR field_size BETWEEN 3 AND 11);

COMMENT ON COLUMN teams.field_size IS
    'Players per side for this team''s game format (7 = 7v7). NULL = unknown.';

UPDATE teams SET field_size = 4  WHERE is_active AND board_sort_order IS NOT NULL AND name ~* '^U6\M';
UPDATE teams SET field_size = 7  WHERE is_active AND board_sort_order IS NOT NULL AND name ~* '^U(8|10)\M';
UPDATE teams SET field_size = 9  WHERE is_active AND board_sort_order IS NOT NULL AND name ~* '^U12\M';
UPDATE teams SET field_size = 11 WHERE is_active AND board_sort_order IS NOT NULL
    AND (name ~* '^U(16|19)\M' OR gender_category IN ('mens', 'womens'));

COMMIT;
