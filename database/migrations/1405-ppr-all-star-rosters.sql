-- 1405 (2026-11-16): ⭐ PPR All-Star squads (owner's picks, 3 per age).
-- Second team_persons row on the mig-1404 teams; each kid keeps his fall
-- team. Person ids checked: one match each, all on their fall team.
--   U8  (966): Iker Castillo 22372, Suhaylah Jones 22624, Angel Terrero 22357
--   U10 (967): Jaxel Almonte 22673, Jalil Sapp 22282, Jamauri Bradham 22415
--   U12 (968): Yigit Torres 22336, Muhammad Idris 22711, Joseph Bradham 22413

INSERT INTO team_persons (team_id, person_id, on_roster)
SELECT t.id, v.person_id, true
  FROM (VALUES ('U8 All-Stars', 22372), ('U8 All-Stars', 22624), ('U8 All-Stars', 22357),
               ('U10 All-Stars', 22673), ('U10 All-Stars', 22282), ('U10 All-Stars', 22415),
               ('U12 All-Stars', 22336), ('U12 All-Stars', 22711), ('U12 All-Stars', 22413)) AS v(team, person_id)
  JOIN teams t ON t.name = v.team AND t.is_active
 WHERE NOT EXISTS (SELECT 1 FROM team_persons x WHERE x.team_id = t.id AND x.person_id = v.person_id AND x.removed_at IS NULL);
