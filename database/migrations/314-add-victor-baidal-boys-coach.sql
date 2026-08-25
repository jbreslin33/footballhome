-- 314 — Add Victor Baidal as a boys coach.
--
-- Why (2026-08-25, owner: "Add victor Baidel as boys coach of all teams.
-- he is a player on men too").
--
-- Spelled Baidal in the database, not Baidel: person 22301,
-- vebaidal@gmail.com, currently an active player on Lighthouse Mens Club
-- APSL. That is the row the owner means — "he is a player on men too" is
-- the identifying detail, and it matches exactly one person.
--
-- Reusing that row rather than inserting a new one is the whole point of
-- this migration. Creating a second Victor Baidal would split his
-- identity across two person ids: his LA membership, RSVPs, payments and
-- APSL roster spot would stay on 22301 while the coach rights sat on a
-- stranger, and the two would never reconcile. Coaching and playing are
-- different tables against the SAME person — coaches.person_id and
-- team_persons.person_id — so one person can hold both without conflict.
--
-- Nothing here touches his playing side: his APSL team_persons row and
-- his mens LA membership are untouched, so he keeps appearing on the mens
-- board as a player exactly as before.
--
-- Same reach as the rest of the boys staff after migrations 312/313: every
-- active boys team, coach_role_id NULL (the head-coach designations sit
-- only on the three travel squads).

BEGIN;

INSERT INTO coaches (person_id)
SELECT 22301
 WHERE NOT EXISTS (SELECT 1 FROM coaches WHERE person_id = 22301)
ON CONFLICT (person_id) DO NOTHING;

INSERT INTO team_coaches (team_id, coach_id)
SELECT t.id, c.id
  FROM teams t
  CROSS JOIN coaches c
 WHERE c.person_id = 22301
   AND t.gender_category = 'boys'
   AND t.is_active
   AND NOT EXISTS (SELECT 1 FROM team_coaches tc
                    WHERE tc.team_id = t.id AND tc.coach_id = c.id AND tc.ended_at IS NULL);

-- Guard: on every active boys team, and still a player on mens.
DO $$
DECLARE n INT; total INT; plays INT;
BEGIN
    SELECT count(*) INTO total FROM teams WHERE gender_category = 'boys' AND is_active;
    SELECT count(*) INTO n
      FROM team_coaches tc
      JOIN coaches c ON c.id = tc.coach_id AND c.person_id = 22301
      JOIN teams t ON t.id = tc.team_id AND t.gender_category = 'boys' AND t.is_active
     WHERE tc.ended_at IS NULL;
    IF n <> total THEN
        RAISE EXCEPTION 'Victor Baidal coaches %/% active boys teams', n, total;
    END IF;

    SELECT count(*) INTO plays FROM team_persons tp
      JOIN teams t ON t.id = tp.team_id AND t.gender_category = 'mens'
     WHERE tp.person_id = 22301 AND tp.removed_at IS NULL;
    IF plays = 0 THEN
        RAISE EXCEPTION 'Victor Baidal lost his mens playing row — aborting';
    END IF;
END $$;

COMMIT;
