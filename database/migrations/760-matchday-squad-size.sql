-- 760 — Match-day squad size per team, extendable for one game.
--
-- Owner 2026-10-27: "if i try to put a player on bench and its full it
-- should ask if for that game only do i want to extend '20 man'. same
-- with all teams. whatever their limit is."
--
-- Before this the bench was hardcoded at 9 in game-center.js (ZONE_CAPS)
-- and EligibilityController::handleSaveMatchLineup, whatever the team.
-- Now:
--   teams.matchday_squad_size       the team's normal limit (starters +
--                                   bench). NULL = field_size + 9, which
--                                   is exactly the old behaviour (20 for
--                                   11v11, 18 for 9v9, 16 for 7v7).
--   match_lineup_metadata.squad_size  this game only, set when a coach
--                                   says yes to "extend" on a full bench.
--                                   NULL = the team's limit.
-- fh_match_squad_size(match) / fh_match_bench_cap(match) settle it from
-- the TAGGED teams (fh_event_teams, same as field_size), home team as the
-- fallback.  Change a team's limit with a later migration, e.g.
--   UPDATE teams SET matchday_squad_size = 18 WHERE id = 35;
--
-- The legacy match_lineup_metadata.roster_size column is untouched (the
-- page has always sent 0 there).

ALTER TABLE teams ADD COLUMN IF NOT EXISTS matchday_squad_size int
  CHECK (matchday_squad_size IS NULL OR matchday_squad_size BETWEEN 1 AND 60);
ALTER TABLE match_lineup_metadata ADD COLUMN IF NOT EXISTS squad_size int
  CHECK (squad_size IS NULL OR squad_size BETWEEN 1 AND 60);

COMMENT ON COLUMN teams.matchday_squad_size IS
  'Match-day squad limit (starters + bench). NULL = field_size + 9. mig 760';
COMMENT ON COLUMN match_lineup_metadata.squad_size IS
  'This game only: extended squad limit from Game Center. NULL = team limit. mig 760';

-- The team's normal limit + its field size for a match.
CREATE OR REPLACE FUNCTION fh_match_team_squad(p_match_id int,
                                               OUT squad_size int, OUT field_size int)
LANGUAGE sql STABLE AS $$
  WITH tagged AS (
    SELECT t.* FROM teams t
     WHERE t.id IN (SELECT fet.team_id FROM fh_events fe
                      JOIN fh_event_teams fet ON fet.fh_event_id = fe.id
                     WHERE fe.match_id = p_match_id)
  ), pool AS (
    SELECT * FROM tagged
    UNION ALL
    SELECT t.* FROM teams t JOIN matches m ON m.home_team_id = t.id
     WHERE m.id = p_match_id AND NOT EXISTS (SELECT 1 FROM tagged)
  )
  SELECT COALESCE(max(COALESCE(matchday_squad_size, COALESCE(field_size, 11) + 9)), 20)::int,
         COALESCE(max(field_size), 11)::int
    FROM pool;
$$;

-- Effective squad for the game: the per-game extension if bigger, else the team's.
CREATE OR REPLACE FUNCTION fh_match_squad_size(p_match_id int)
RETURNS int LANGUAGE sql STABLE AS $$
  SELECT GREATEST(ts.squad_size,
                  COALESCE((SELECT max(squad_size) FROM match_lineup_metadata
                             WHERE match_id = p_match_id), 0))
    FROM fh_match_team_squad(p_match_id) ts;
$$;

CREATE OR REPLACE FUNCTION fh_match_bench_cap(p_match_id int)
RETURNS int LANGUAGE sql STABLE AS $$
  SELECT GREATEST(fh_match_squad_size(p_match_id) - ts.field_size, 0)
    FROM fh_match_team_squad(p_match_id) ts;
$$;

-- Words for the extend offer (kind lineup_swap, migration 453).
-- {player} being benched, {cap} bench cap now, {squad} squad size now,
-- {next} squad size after extending, {team_squad} the team's usual limit.
CREATE OR REPLACE FUNCTION pg_temp.add_client_tpl(p_kind text, p_tier text, p_label text,
                                                  p_body text, p_sort int)
RETURNS void LANGUAGE sql AS $$
  INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
  SELECT 'System', p_label, p_kind, p_tier, NULL, p_body, p_sort, true, true
   WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = p_kind AND tier = p_tier);
$$;

SELECT pg_temp.add_client_tpl('lineup_swap', 'extend', 'Game Center — bench full: extend squad button',
  '➕ Extend to a {next}-man squad — this game only', 15);
SELECT pg_temp.add_client_tpl('lineup_swap', 'extend_note', 'Game Center — bench full: extend squad note',
  '{player} goes on the bench; other games stay {team_squad}-man', 16);
SELECT pg_temp.add_client_tpl('lineup_swap', 'to_bench_extend', 'Game Center — swap sheet: to Bench when full (extends)',
  'Bench full — extends to a {next}-man squad for this game', 17);
SELECT pg_temp.add_client_tpl('lineup_swap', 'extended_strip', 'Game Center — header note when this game is extended',
  'Extended to {squad}-man for this game (usually {team_squad})', 18);

-- Bench-full words now name the squad, not a fixed 9.
UPDATE message_templates SET body = 'Bench is full ({squad}-man squad, {cap} on the bench)'
 WHERE kind = 'lineup_swap' AND tier = 'bench_title' AND body = 'Bench is full ({cap} max)';
UPDATE message_templates SET body = 'Pick who {player} swaps with, or extend:'
 WHERE kind = 'lineup_swap' AND tier = 'bench_sub' AND body = 'Pick who {player} swaps with:';
