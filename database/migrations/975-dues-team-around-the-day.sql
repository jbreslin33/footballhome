-- 975 (2026-11-03) — fh_dues_team(): a payment made just before a player was
-- put on a team, or a refund just after he left, still counts for that team.
-- Owner 2026-11-03: "we need to count those that played and were removed as
-- we collected money. so it goes to that months we collected right?"
--   1. on a ranked team that day                → highest of those
--   2. else the team he joined next after paying (sign-up before rostering)
--   3. else the team he left most recently before paying (refund after leaving)
CREATE OR REPLACE FUNCTION fh_dues_team(p_person int, p_category text, p_at timestamptz)
RETURNS int LANGUAGE sql STABLE AS $$
  WITH sec AS (
    SELECT id FROM club_sections WHERE code = CASE p_category WHEN 'men' THEN 'M' WHEN 'women' THEN 'W' WHEN 'boys' THEN 'B' WHEN 'girls' THEN 'G' END
  ), d AS (SELECT (p_at AT TIME ZONE 'America/New_York')::date AS day
  ), mine AS (
    SELECT t.id, t.dues_rank,
           (tp.joined_at AT TIME ZONE 'America/New_York')::date AS j,
           (tp.removed_at AT TIME ZONE 'America/New_York')::date AS r
      FROM team_persons tp JOIN teams t ON t.id = tp.team_id
     WHERE tp.person_id = p_person AND t.dues_rank IS NOT NULL AND t.club_section_id = (SELECT id FROM sec)
  )
  SELECT COALESCE(
    (SELECT id FROM mine, d WHERE (j IS NULL OR j <= d.day) AND (r IS NULL OR r > d.day) ORDER BY dues_rank DESC LIMIT 1),
    (SELECT id FROM mine, d WHERE j > d.day ORDER BY j, dues_rank DESC LIMIT 1),
    (SELECT id FROM mine, d WHERE r <= d.day ORDER BY r DESC, dues_rank DESC LIMIT 1))
$$;
