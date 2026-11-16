-- 1396 (2026-11-16): fill the winter travel teams (mig 1392) by ADDING —
-- owner: "add don't move all u8, u9, u10 players to u10 winter travel. add
-- don't move all u11 and u12 players to u12 winter travel."
--   ❄️ U8 953 / U9 945 / U10 942 → ❄️ U10 Travel Winter
--   ❄️ U11 946 / U12 940         → ❄️ U12 Travel Winter
-- Every kid keeps his generic age row. New rows have no roster status, so
-- the games_need_roster trigger makes them 🏋 Practice Squad (Not on
-- Roster); 💤 Inactive follows the kid.

BEGIN;

INSERT INTO team_persons (team_id, person_id, squad_status_id)
SELECT DISTINCT ON (dst.id, tp.person_id) dst.id, tp.person_id,
       CASE WHEN ss.code = 'inactive' THEN tp.squad_status_id END
  FROM team_persons tp
  JOIN (VALUES (953, 'U10 Travel Winter'), (945, 'U10 Travel Winter'), (942, 'U10 Travel Winter'),
               (946, 'U12 Travel Winter'), (940, 'U12 Travel Winter')) m(src, dst_name) ON m.src = tp.team_id
  JOIN teams dst ON dst.name = m.dst_name AND dst.is_active
  LEFT JOIN squad_statuses ss ON ss.id = tp.squad_status_id
 WHERE tp.removed_at IS NULL
   AND NOT EXISTS (SELECT 1 FROM team_persons x WHERE x.team_id = dst.id AND x.person_id = tp.person_id AND x.removed_at IS NULL)
 ORDER BY dst.id, tp.person_id, (ss.code = 'inactive') DESC NULLS LAST;

COMMIT;
