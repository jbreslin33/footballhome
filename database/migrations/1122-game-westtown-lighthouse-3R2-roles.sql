-- 1122 — Game G5.36 (game/DESIGN.md §8.134): Westtown FC and Lighthouse as pro sides, and the
-- 3-5-2 (3-R2)'s slot roles.
--
-- James (via the club-app session, 11/6): "just make west town and lh same as pro team ability
-- wise for now … lh would be dup of a team ability wise at pro level too but wheres westtown runs
-- standard pro tactics. lh runs this game model". Both are copies of the SAME 2015/16 Premier
-- League side, West Ham United (a 4-3-3), so a difference between them is tactics, not talent:
-- Westtown FC plays West Ham's 4-3-3 on the engine's standard behaviour; Lighthouse plays our
-- 3-5-2 (3-R2) (formations.id 16). Players are copied row for row inside the DB (names never in
-- git). Lighthouse wears its royal blue (mig 851); Westtown keeps West Ham's claret for now.
--
-- The 3-R2 by James's numbering: the bowl 3·5 6 4·2 (left wing-back 3, back three 5 6 4, right
-- wing-back 2), midfield 10 9 8, the 7 in the hole right of centre, 11 the lone striker. The
-- wing-backs get their own role: the engine plays the ball-side one at a wide man's depth and
-- tucks the far-side one into a back four (Brain::wingBack).

BEGIN;

INSERT INTO game_roles (code, title) VALUES ('wing-back', 'Wing-back')
ON CONFLICT (code) DO NOTHING;
UPDATE game_roles SET title = 'Full-back' WHERE code = 'full-back';

DELETE FROM formation_slot_roles WHERE formation_code = '3-5-2 (3-R2)';
INSERT INTO formation_slot_roles (formation_code, slot, role, number) VALUES
  ('3-5-2 (3-R2)',  1, 'keeper',       1),
  ('3-5-2 (3-R2)',  2, 'centre-back',  5),   -- left of the three
  ('3-5-2 (3-R2)',  3, 'centre-back',  6),   -- the middle
  ('3-5-2 (3-R2)',  4, 'centre-back',  4),   -- right of the three
  ('3-5-2 (3-R2)',  5, 'wing-back',    3),   -- left
  ('3-5-2 (3-R2)',  6, 'eight',       10),   -- midfield, left
  ('3-5-2 (3-R2)',  7, 'single-pivot', 9),   -- midfield, middle
  ('3-5-2 (3-R2)',  8, 'eight',        8),   -- midfield, right
  ('3-5-2 (3-R2)',  9, 'wing-back',    2),   -- right
  ('3-5-2 (3-R2)', 10, 'ten',          7),   -- in the hole, right of centre
  ('3-5-2 (3-R2)', 11, 'nine',        11);   -- the lone striker

-- The two sides: West Ham United's row and squad, copied.
DELETE FROM game_demo_players WHERE team_id IN (SELECT id FROM game_demo_teams WHERE name IN ('Westtown FC', 'Lighthouse'));
DELETE FROM game_demo_teams WHERE name IN ('Westtown FC', 'Lighthouse');
WITH src AS (SELECT * FROM game_demo_teams WHERE name = 'West Ham United'),
     made AS (
       INSERT INTO game_demo_teams (name, level_band, game_model, formation_code, kit_shirt, kit_shorts, kit_socks, kit_trim, quality)
       SELECT v.name, src.level_band, src.game_model, v.formation,
              COALESCE(v.shirt, src.kit_shirt), COALESCE(v.shorts, src.kit_shorts),
              COALESCE(v.socks, src.kit_socks), COALESCE(v.trim, src.kit_trim), src.quality
         FROM src CROSS JOIN (VALUES
           ('Westtown FC', '4-3-3',        NULL,      NULL,      NULL,      NULL),
           ('Lighthouse',  '3-5-2 (3-R2)', '#4169e1', '#4169e1', '#4169e1', '#ffffff')
         ) v(name, formation, shirt, shorts, socks, trim)
       RETURNING id)
INSERT INTO game_demo_players (team_id, shirt, name, max_speed_cms, concept_mask, person_id, position, description,
                               lineup_slot, quality, potential, age, age_source, start_age, years_off, lineup_tier)
SELECT made.id, p.shirt, p.name, p.max_speed_cms, p.concept_mask, p.person_id, p.position, p.description,
       p.lineup_slot, p.quality, p.potential, p.age, p.age_source, p.start_age, p.years_off, p.lineup_tier
  FROM made
  JOIN game_demo_players p ON p.team_id = (SELECT id FROM game_demo_teams WHERE name = 'West Ham United');

COMMIT;
