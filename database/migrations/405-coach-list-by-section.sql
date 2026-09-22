-- 405 — Coaching list: one section per coach.
--
-- Owner 2026-09-22: "we just need me as mens coach. no one else right
-- now. then the others should only show as youth coaches. Jamie Arevalo
-- should only show as women coach."
--
--   James Breslin (1)       → mens only: APSL 35, APSL Reserves 938,
--                             Liga 1 120 (head).  His womens + youth rows end.
--   Anthony Acevedo (22397) → youth only: his mens + womens rows end.
--   Jamie Arevalo (22193)   → womens only (already; guarded below).
--   Everyone else already coaches youth teams only (403/404 removed the
--   two who did not).
--
-- Ended the way the Teams screen does it — ended_at stamped, rows kept —
-- so coach checks (tc.ended_at IS NULL) stop seeing them.  James is an
-- admin, so his access to the youth boards is unchanged.

BEGIN;

-- James: keep only the three mens teams.
UPDATE team_coaches tc SET ended_at = now()
  FROM coaches c
 WHERE c.id = tc.coach_id AND c.person_id = 1
   AND tc.ended_at IS NULL
   AND tc.team_id NOT IN (35, 120, 938);

-- Anthony: keep only youth teams.
UPDATE team_coaches tc SET ended_at = now()
  FROM coaches c, teams t
 WHERE c.id = tc.coach_id AND c.person_id = 22397
   AND t.id = tc.team_id
   AND tc.ended_at IS NULL
   AND t.gender_category NOT IN ('boys', 'girls');

DO $$
DECLARE james INT; james_mens INT; anthony_adult INT; jamie INT; jamie_w INT; other_mens INT;
BEGIN
    SELECT count(*), count(*) FILTER (WHERE tc.team_id IN (35, 120, 938))
      INTO james, james_mens
      FROM team_coaches tc JOIN coaches c ON c.id = tc.coach_id
     WHERE c.person_id = 1 AND tc.ended_at IS NULL;
    IF james <> 3 OR james_mens <> 3 THEN
        RAISE EXCEPTION 'James: % open rows, % on mens teams (want 3/3)', james, james_mens;
    END IF;

    SELECT count(*) INTO anthony_adult
      FROM team_coaches tc JOIN coaches c ON c.id = tc.coach_id JOIN teams t ON t.id = tc.team_id
     WHERE c.person_id = 22397 AND tc.ended_at IS NULL AND t.gender_category NOT IN ('boys', 'girls');
    IF anthony_adult <> 0 THEN
        RAISE EXCEPTION 'Anthony still on % adult team(s)', anthony_adult;
    END IF;

    SELECT count(*), count(*) FILTER (WHERE tc.team_id = 901) INTO jamie, jamie_w
      FROM team_coaches tc JOIN coaches c ON c.id = tc.coach_id
     WHERE c.person_id = 22193 AND tc.ended_at IS NULL;
    IF jamie <> 1 OR jamie_w <> 1 THEN
        RAISE EXCEPTION 'Jamie: % open rows, % on womens (want 1/1)', jamie, jamie_w;
    END IF;

    -- Nobody but James on a mens team.
    SELECT count(*) INTO other_mens
      FROM team_coaches tc JOIN coaches c ON c.id = tc.coach_id JOIN teams t ON t.id = tc.team_id
     WHERE tc.ended_at IS NULL AND t.gender_category = 'mens' AND c.person_id <> 1;
    IF other_mens <> 0 THEN
        RAISE EXCEPTION '% other coach row(s) still on mens teams', other_mens;
    END IF;
END $$;

COMMIT;
