-- 973 (2026-11-03) — whose dues count for which team on #finances.
-- Owner 2026-11-03: "if they are on team for apsl then they count for apsl" /
-- "if they are on both they count for higher team" / "reserves is not a real
-- team" / "its liga 1 guys who have been added for $5 to apsl reserves and
-- thus can play apsl".
--   teams.dues_rank   higher = higher team; NULL = never carries dues
--                     (APSL Reserves 938 is paper, the USASA Cup 939 a pool).
--   fh_dues_team()    a member's dues count once, for the highest-ranked team
--                     of their section they were on when they paid (else the
--                     one they are on now).  No team = the section itself.
BEGIN;
ALTER TABLE teams ADD COLUMN IF NOT EXISTS dues_rank INTEGER;
COMMENT ON COLUMN teams.dues_rank IS 'mig 973: a member''s dues count for their highest-ranked team; NULL = carries no dues.';
UPDATE teams SET dues_rank = v.r FROM (VALUES
    (35, 20),   -- APSL
    (120, 10),  -- Liga 1
    (901, 10),  -- Women
    (932, 40), (914, 30), (913, 20), (912, 10)   -- U19 > U12 > U10 > U8
) AS v(id, r) WHERE teams.id = v.id;

CREATE OR REPLACE FUNCTION fh_dues_team(p_person int, p_category text, p_at timestamptz)
RETURNS int LANGUAGE sql STABLE AS $$
  WITH sec AS (
    SELECT id FROM club_sections WHERE code = CASE p_category WHEN 'men' THEN 'M' WHEN 'women' THEN 'W' WHEN 'boys' THEN 'B' WHEN 'girls' THEN 'G' END
  ), mine AS (
    SELECT t.id, t.dues_rank,
           (tp.joined_at IS NULL OR tp.joined_at <= p_at) AND (tp.removed_at IS NULL OR tp.removed_at > p_at) AS then_on,
           tp.removed_at IS NULL AS now_on
      FROM team_persons tp JOIN teams t ON t.id = tp.team_id
     WHERE tp.person_id = p_person AND t.dues_rank IS NOT NULL AND t.club_section_id = (SELECT id FROM sec)
  )
  SELECT COALESCE(
    (SELECT id FROM mine WHERE then_on ORDER BY dues_rank DESC LIMIT 1),
    (SELECT id FROM mine WHERE now_on  ORDER BY dues_rank DESC LIMIT 1))
$$;
COMMENT ON FUNCTION fh_dues_team(int, text, timestamptz) IS 'mig 973: the team a member''s dues count for (highest dues_rank in the section).';
COMMIT;
