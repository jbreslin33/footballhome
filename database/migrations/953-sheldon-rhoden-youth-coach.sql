-- Owner 11/2: Sheldon Rhoden coaches youth (U8, U10, U12, U19).
INSERT INTO coaches (person_id)
SELECT 22433
 WHERE NOT EXISTS (SELECT 1 FROM coaches WHERE person_id = 22433);

INSERT INTO team_coaches (team_id, coach_id)
SELECT t.id, c.id
  FROM coaches c
 CROSS JOIN (VALUES (912), (913), (914), (932)) AS t(id)
 WHERE c.person_id = 22433
   AND NOT EXISTS (SELECT 1 FROM team_coaches x
                    WHERE x.team_id = t.id AND x.coach_id = c.id AND x.ended_at IS NULL);
