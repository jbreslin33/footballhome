-- 310 — Delete the last three match_series rows.
--
-- Why (2026-08-25, owner: "delete those too", after migration 309 took
-- the Practice generators).
--
-- 1 "Tuesday Pickup", 3 "Thursday Pickup", 5 "Saturday Pickup" are the
-- surviving half of the recurring-generator set that migration 309
-- removed. Same retired pool model, same state: active=false, and unlike
-- their Practice siblings they never generated a single match. They point
-- at team 909, which is why 309 left them alone — that team stays and its
-- rows were not that migration's business.
--
-- They are dead either way. A pickup session is a calendar event with
-- teams tagged on it, exactly like a practice; nothing schedules from
-- match_series any more. After this the table is empty, which is the
-- honest state — the generator model is gone entirely rather than
-- half-removed.
--
-- Team 909 itself is untouched: it mirrors a live paid LA registration
-- (program 5070075, 44 members) and LaPool keeps it converged in both
-- directions as of migrations 304/305.

BEGIN;

-- Guard: nothing active, and nothing that ever produced a match.
DO $$
DECLARE n INT;
BEGIN
    SELECT count(*) INTO n FROM match_series ms
     WHERE ms.active
        OR EXISTS (SELECT 1 FROM matches m WHERE m.series_id = ms.id);
    IF n > 0 THEN
        RAISE EXCEPTION 'refusing: % series still active or carrying matches', n;
    END IF;
END $$;

DELETE FROM match_series;

COMMIT;
