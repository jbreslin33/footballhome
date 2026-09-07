-- 341 — Add Ando Andre as a coach of all youth teams.
--
-- Why (2026-09-07, owner: "add him also as a coach of all youth teams",
-- asked right after confirming he is a player on Liga 1).
--
-- Person 22494, andoandre17@gmail.com, LeagueApps signup 2026-07-23,
-- currently an active player on Lighthouse Boys Club Liga 1 (team 120).
-- Reuse that row — never mint a second Ando Andre, or his LA membership,
-- RSVPs and Liga 1 roster spot would sit on one person id and his coach
-- rights on another (see 314 for the same reasoning).
--
-- "All youth teams" today = every active boys team; the club has no girls
-- teams. Same reach as the rest of the youth staff after 312/313/314,
-- coach_role_id NULL. Nothing here touches his playing side.

BEGIN;

INSERT INTO coaches (person_id)
SELECT 22494
 WHERE NOT EXISTS (SELECT 1 FROM coaches WHERE person_id = 22494)
ON CONFLICT (person_id) DO NOTHING;

INSERT INTO team_coaches (team_id, coach_id)
SELECT t.id, c.id
  FROM teams t
  CROSS JOIN coaches c
 WHERE c.person_id = 22494
   AND t.gender_category IN ('boys', 'girls')
   AND t.is_active
   AND NOT EXISTS (SELECT 1 FROM team_coaches tc
                    WHERE tc.team_id = t.id AND tc.coach_id = c.id AND tc.ended_at IS NULL);

-- Guard: on every active youth team, and still a player on Liga 1.
DO $$
DECLARE n INT; total INT; plays INT;
BEGIN
    SELECT count(*) INTO total FROM teams WHERE gender_category IN ('boys', 'girls') AND is_active;
    SELECT count(*) INTO n
      FROM team_coaches tc
      JOIN coaches c ON c.id = tc.coach_id AND c.person_id = 22494
      JOIN teams t ON t.id = tc.team_id AND t.gender_category IN ('boys', 'girls') AND t.is_active
     WHERE tc.ended_at IS NULL;
    IF n <> total OR total = 0 THEN
        RAISE EXCEPTION 'Ando Andre coaches %/% active youth teams', n, total;
    END IF;

    SELECT count(*) INTO plays FROM team_persons tp
     WHERE tp.person_id = 22494 AND tp.team_id = 120 AND tp.removed_at IS NULL;
    IF plays = 0 THEN
        RAISE EXCEPTION 'Ando Andre lost his Liga 1 playing row — aborting';
    END IF;
END $$;

COMMIT;
