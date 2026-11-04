-- 1034: youth not on an official roster → the Practice Squad of their age
-- team, or younger; older than U12 → U12 (owner 2026-11-04: "move all
-- youth players not on an official roster to the practice squad of their
-- age or younger. any older players put in u12 like u13 etc").
--
-- Today (64 youth kids, 26 not on a fall list): 20 already sit on their
-- age team's 🏋 Practice Squad (U8 / U10 / U12).  The six 13-year-olds on
-- U19 (932, no games, no list) move to U12 (914), where the youth rule
-- (mig 1031/1033) makes them Practice Squad.  Their winter U15 rows stay.
-- Not moved: Sheldon Rhoden (22433, 18, an APSL man) stays on U19;
-- Yasmeen Turner (U8 Needs Docs, full since mig 1033) and Yousef Mouneeb
-- (U10 On Roster by status) are not Practice Squad by the owner's own
-- rules.
--
-- Going forward fh_youth_place (mig 902) picks only teams that play games
-- (games_need_roster): the youngest one at or above the kid's age, else
-- the oldest one that season — a U13+ kid lands on U12 in the fall, U18
-- in the winter.

BEGIN;

INSERT INTO team_persons (team_id, person_id)
SELECT 914, x.id FROM (VALUES (22664), (22603), (22465), (22690), (22520), (22672)) AS x(id)
 WHERE EXISTS (SELECT 1 FROM persons p WHERE p.id = x.id)
   AND NOT EXISTS (SELECT 1 FROM team_persons tp WHERE tp.team_id = 914 AND tp.person_id = x.id AND tp.removed_at IS NULL);

UPDATE team_persons SET removed_at = now(), removed_reason = 'board_move',
       removed_details = jsonb_build_object('to_team_id', 914, 'mig', 1034)
 WHERE team_id = 932 AND removed_at IS NULL
   AND person_id IN (22664, 22603, 22465, 22690, 22520, 22672);

CREATE OR REPLACE FUNCTION fh_youth_place(p_person_id integer) RETURNS void
LANGUAGE sql AS $$
    INSERT INTO team_persons (team_id, person_id)
    SELECT DISTINCT t.id, p.id
      FROM persons p
      CROSS JOIN (VALUES ('fall'), ('winter')) AS season(term)
      CROSS JOIN LATERAL (
        SELECT t.id FROM teams t JOIN team_terms tt ON tt.team_id = t.id AND tt.term = season.term
         WHERE t.is_active AND t.games_need_roster
           AND t.gender_category IN ('boys', 'girls') AND t.name ~ '^U[0-9]+$'
         -- youngest team at or above his age first; none → the oldest (mig 1034)
         ORDER BY (fh_team_age(t.id) >= fh_youth_single_age(p.birth_date,
                     extract(year FROM now() AT TIME ZONE 'America/New_York')::int
                     + CASE WHEN extract(month FROM now() AT TIME ZONE 'America/New_York') >= 6 THEN 1 ELSE 0 END)) DESC,
                  CASE WHEN fh_team_age(t.id) >= fh_youth_single_age(p.birth_date,
                     extract(year FROM now() AT TIME ZONE 'America/New_York')::int
                     + CASE WHEN extract(month FROM now() AT TIME ZONE 'America/New_York') >= 6 THEN 1 ELSE 0 END)
                       THEN fh_team_age(t.id) ELSE -fh_team_age(t.id) END,
                  t.id
         LIMIT 1) t
     WHERE p.id = p_person_id AND p.birth_date IS NOT NULL
       AND NOT EXISTS (SELECT 1 FROM team_persons x
                         JOIN teams xt ON xt.id = x.team_id
                         JOIN team_terms xtt ON xtt.team_id = xt.id AND xtt.term = season.term
                        WHERE x.person_id = p.id AND x.removed_at IS NULL AND xt.is_active
                          AND xt.gender_category IN ('boys', 'girls'));
$$;

COMMIT;
