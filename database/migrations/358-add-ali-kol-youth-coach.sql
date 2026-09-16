-- 358 — Add Ali Kol as a coach of all youth teams.
--
-- Why (2026-09-16, owner: "add ali kol as coach of all youth teams").
--
-- Person 22688, alikol872@gmail.com, +1 856 581 5854, LeagueApps user
-- 58475808 (registered 2026-09-08), currently a player on Lighthouse
-- Boys Club Liga 1 (team 120, not yet On Roster), with a users row
-- (193) that has never signed in. Reuse that row — never mint a second
-- Ali, or his LA membership and roster spot would sit on one person id
-- and his coach rights on another (see 314/341/350).
--
-- Not touched: person 550 "Muhammed Ali Kol", a scraped CASA record
-- (Oaklyn United, removed 2026-06-25) that may be the same human from a
-- past season. Merging is a separate decision; nothing here depends on it.
--
-- "All youth teams" = every active boys/girls team (U6–U19 Intramural,
-- U8/U10/U12 Travel), coach_role_id NULL like the rest of the youth
-- staff. Nothing here touches his playing side.

BEGIN;

INSERT INTO coaches (person_id)
SELECT 22688
 WHERE NOT EXISTS (SELECT 1 FROM coaches WHERE person_id = 22688)
ON CONFLICT (person_id) DO NOTHING;

INSERT INTO team_coaches (team_id, coach_id)
SELECT t.id, c.id
  FROM teams t
  CROSS JOIN coaches c
 WHERE c.person_id = 22688
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
      JOIN coaches c ON c.id = tc.coach_id AND c.person_id = 22688
      JOIN teams t ON t.id = tc.team_id AND t.gender_category IN ('boys', 'girls') AND t.is_active
     WHERE tc.ended_at IS NULL;
    IF n <> total OR total = 0 THEN
        RAISE EXCEPTION 'Ali Kol coaches %/% active youth teams', n, total;
    END IF;

    SELECT count(*) INTO plays FROM team_persons tp
     WHERE tp.person_id = 22688 AND tp.team_id = 120 AND tp.removed_at IS NULL;
    IF plays = 0 THEN
        RAISE EXCEPTION 'Ali Kol lost his Liga 1 playing row — aborting';
    END IF;
END $$;

COMMIT;
