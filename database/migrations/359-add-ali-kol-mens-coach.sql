-- 359 — Add Ali Kol as a coach of all men's teams too.
--
-- Why (2026-09-16, owner: "ok add him to the mens coaches too", right
-- after 358 put him on every youth team).
--
-- Same person 22688 (see 358). "All men's teams" = every active
-- gender_category='mens' team of the Lighthouse club (club 134): APSL
-- (35), Boys Club Liga 1 (120), APSL Reserves (938). Pickup (909) is
-- inactive and excluded. He plays on Liga 1 himself; coaching a team
-- you play on is already how Tolu sits on APSL, and nothing here
-- touches his playing row.

BEGIN;

INSERT INTO team_coaches (team_id, coach_id)
SELECT t.id, c.id
  FROM teams t
  CROSS JOIN coaches c
 WHERE c.person_id = 22688
   AND t.gender_category = 'mens'
   AND t.club_id = 134
   AND t.is_active
   AND NOT EXISTS (SELECT 1 FROM team_coaches tc
                    WHERE tc.team_id = t.id AND tc.coach_id = c.id AND tc.ended_at IS NULL);

DO $$
DECLARE n INT; total INT; plays INT;
BEGIN
    SELECT count(*) INTO total FROM teams WHERE gender_category = 'mens' AND club_id = 134 AND is_active;
    SELECT count(*) INTO n
      FROM team_coaches tc
      JOIN coaches c ON c.id = tc.coach_id AND c.person_id = 22688
      JOIN teams t ON t.id = tc.team_id AND t.gender_category = 'mens' AND t.club_id = 134 AND t.is_active
     WHERE tc.ended_at IS NULL;
    IF n <> total OR total <> 3 THEN
        RAISE EXCEPTION 'Ali Kol coaches %/% active mens teams (expected 3)', n, total;
    END IF;

    SELECT count(*) INTO plays FROM team_persons tp
     WHERE tp.person_id = 22688 AND tp.team_id = 120 AND tp.removed_at IS NULL;
    IF plays = 0 THEN
        RAISE EXCEPTION 'Ali Kol lost his Liga 1 playing row — aborting';
    END IF;
END $$;

COMMIT;
