-- 429 — James Breslin and Michael Lopez coach the Women's team.
--
-- Owner 2026-09-25: "i need to be a coach of womens team. so does
-- michael.lopez@lighthouse1893.org".
--
-- Why: #my shows only events the viewer is personally on (rostered
-- player, live coach row, or invite — CalendarController `is_mine`).
-- Migration 405 (09-22, "we just need me as mens coach") ended James's
-- Women's row, so Sunday's Women Away vs Philadelphia Falcons dropped
-- off his page.  Michael (person 22439, super admin since 428) has never
-- had a coaches row at all.
--
--   James Breslin (1)      → reopen on Lighthouse Womens Club 1895 (901).
--                             His three mens rows (35, 120, 938) stay.
--   Michael Lopez (22439)  → new coaches row, then Women's (901).
--
-- No coach_role_id, matching Jamie Arevalo's existing Women's row, so
-- the coaching list keeps its order.  Nothing here touches 405's other
-- changes (Anthony youth-only, Jamie womens-only).

BEGIN;

INSERT INTO coaches (person_id)
SELECT 22439
 WHERE NOT EXISTS (SELECT 1 FROM coaches WHERE person_id = 22439);

INSERT INTO team_coaches (team_id, coach_id)
SELECT 901, c.id
  FROM coaches c
 WHERE c.person_id IN (1, 22439)
   AND NOT EXISTS (SELECT 1 FROM team_coaches tc
                    WHERE tc.team_id = 901 AND tc.coach_id = c.id AND tc.ended_at IS NULL);

DO $$
DECLARE n INT; james_mens INT;
BEGIN
    SELECT count(*) INTO n
      FROM team_coaches tc JOIN coaches c ON c.id = tc.coach_id
     WHERE tc.team_id = 901 AND tc.ended_at IS NULL AND c.person_id IN (1, 22439);
    IF n <> 2 THEN
        RAISE EXCEPTION 'migration 429: %/2 of James + Michael coach the Women''s team', n;
    END IF;

    SELECT count(*) INTO james_mens
      FROM team_coaches tc JOIN coaches c ON c.id = tc.coach_id
     WHERE c.person_id = 1 AND tc.ended_at IS NULL AND tc.team_id IN (35, 120, 938);
    IF james_mens <> 3 THEN
        RAISE EXCEPTION 'migration 429: James lost a mens coach row (% of 3)', james_mens;
    END IF;
END $$;

COMMIT;
