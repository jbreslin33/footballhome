-- 1560 (2026-11-19) — Bayo and Lucca Santos back to ✅ Regular on APSL.
-- Mig 1559 moved five to 🪑 Reserves on APSL; the owner meant three:
-- "masi, benzig, delgado".  Aboubacar Bayo II and Lucca Santos return to
-- ✅ Regular on APSL (chased for APSL games again).
UPDATE team_persons SET squad_status_id = NULL
 WHERE team_id = 35 AND removed_at IS NULL
   AND person_id IN (3488,    -- Aboubacar Bayo II
                     22698);  -- Lucca Santos
