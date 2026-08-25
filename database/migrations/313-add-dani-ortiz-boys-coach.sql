-- 313 — Add Dani Ortiz as a boys coach.
--
-- Why (2026-08-25, owner: "also add Dani Ortiz as boys coach like
-- Acevedo ortiz502cano@gmail.com").
--
-- Modelled on Anthony Acevedo (coach 40, person 22397), the reference the
-- owner named: a persons row with name and a primary email only — no
-- birth_date, no la_user_id, no LA membership — plus a coaches row and a
-- team_coaches row on every active boys team with coach_role_id NULL
-- (head-coach designations are only on the three travel squads).
--
-- A coach is not a member: nothing here touches person_la_memberships or
-- team_persons, so Dani will not appear on a roster board as a player.
--
-- Guarded on the email rather than the name — 'Dani Ortiz' is not
-- distinctive (six people named Ortiz already exist, none of them this
-- one) while the address is. Re-running is a no-op.

BEGIN;

WITH new_person AS (
    INSERT INTO persons (first_name, last_name)
    SELECT 'Dani', 'Ortiz'
     WHERE NOT EXISTS (
           SELECT 1 FROM person_emails
            WHERE lower(email) = 'ortiz502cano@gmail.com')
    RETURNING id
), person AS (
    SELECT id FROM new_person
    UNION ALL
    SELECT person_id FROM person_emails WHERE lower(email) = 'ortiz502cano@gmail.com'
    LIMIT 1
), email AS (
    -- email_type_id 1 / is_primary / is_verified copied from Acevedo's row.
    INSERT INTO person_emails (person_id, email, email_type_id, is_primary, is_verified)
    SELECT p.id, 'ortiz502cano@gmail.com', 1, true, true FROM person p
     WHERE NOT EXISTS (SELECT 1 FROM person_emails
                        WHERE lower(email) = 'ortiz502cano@gmail.com')
    RETURNING person_id
)
INSERT INTO coaches (person_id)
SELECT p.id FROM person p
 WHERE NOT EXISTS (SELECT 1 FROM coaches c WHERE c.person_id = p.id)
ON CONFLICT (person_id) DO NOTHING;

-- Every active boys team, same reach as the rest of the staff after
-- migration 312.
INSERT INTO team_coaches (team_id, coach_id)
SELECT t.id, c.id
  FROM teams t
  CROSS JOIN coaches c
  JOIN person_emails pe ON pe.person_id = c.person_id
                       AND lower(pe.email) = 'ortiz502cano@gmail.com'
 WHERE t.gender_category = 'boys'
   AND t.is_active
   AND NOT EXISTS (SELECT 1 FROM team_coaches tc
                    WHERE tc.team_id = t.id AND tc.coach_id = c.id AND tc.ended_at IS NULL);

-- Guard: Dani must end up on all nine, like everyone else.
DO $$
DECLARE n INT; total INT;
BEGIN
    SELECT count(*) INTO total FROM teams
     WHERE gender_category = 'boys' AND is_active;
    SELECT count(*) INTO n
      FROM team_coaches tc
      JOIN coaches c ON c.id = tc.coach_id
      JOIN person_emails pe ON pe.person_id = c.person_id
                           AND lower(pe.email) = 'ortiz502cano@gmail.com'
      JOIN teams t ON t.id = tc.team_id AND t.gender_category = 'boys' AND t.is_active
     WHERE tc.ended_at IS NULL;
    IF n <> total THEN
        RAISE EXCEPTION 'Dani Ortiz coaches %/% active boys teams', n, total;
    END IF;
END $$;

COMMIT;
