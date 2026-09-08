-- 347 — Add Jamie Arevalo as a coach of Tri County Women.
--
-- Why (2026-09-07, owner: "can we make Jamie Arevelo coach of womens team").
--
-- Person 22193, arevalojamie@yahoo.com, LeagueApps user 58290114, already
-- on the Tri County Women (team 901) team_persons roster.  Reuse that row —
-- 346 just merged her Google-login orphan into it so her sign-in, roster
-- spot and coach rights all sit on one person id (see 314/341 for the same
-- reasoning).
--
-- coach_role_id NULL, same as Anthony Acevedo and Marcelo Osorio-Soto on
-- this team.  Nothing here touches her roster row.

BEGIN;

INSERT INTO coaches (person_id)
SELECT 22193
 WHERE NOT EXISTS (SELECT 1 FROM coaches WHERE person_id = 22193);

INSERT INTO team_coaches (team_id, coach_id)
SELECT 901, c.id
  FROM coaches c
 WHERE c.person_id = 22193
   AND NOT EXISTS (SELECT 1 FROM team_coaches tc
                    WHERE tc.team_id = 901 AND tc.coach_id = c.id AND tc.ended_at IS NULL);

-- Guard: exactly one open coaching row on 901, and team 901 is still the
-- women's team.
DO $$
DECLARE n INT; tname TEXT;
BEGIN
    SELECT name INTO tname FROM teams WHERE id = 901;
    IF tname IS DISTINCT FROM 'Tri County Women' THEN
        RAISE EXCEPTION 'team 901 is "%", not Tri County Women — aborting', tname;
    END IF;
    SELECT count(*) INTO n
      FROM team_coaches tc
      JOIN coaches c ON c.id = tc.coach_id AND c.person_id = 22193
     WHERE tc.team_id = 901 AND tc.ended_at IS NULL;
    IF n <> 1 THEN
        RAISE EXCEPTION 'Jamie Arevalo has % open coach rows on Tri County Women', n;
    END IF;
END $$;

COMMIT;
