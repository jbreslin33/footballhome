-- 1890 (2026-11-25): each machine carries its concept's exact catalogue title.
--
-- Owner 11/25, reading the player's state table: "why does it say pressing distance and not stay in
-- pressing distance. details!" The machine column is the concept, word for word from game_concepts;
-- the State column says which state of it he is in. Marking scheme is a group of concepts, so its
-- STATES carry the concept titles (your direct opponent / zonal marking / the free man at the back).
UPDATE game_engine_terms t SET title = c.title,
       note = coalesce(t.note, '') || ' · title = game_concepts ' || c.name || ' (mig 1890)'
  FROM (VALUES ('cover_shadow', 'cover-shadow'), ('pressing_distance', 'pressing-distance'), ('recover', 'recover'),
               ('press', 'close-down'), ('loose_ball', 'nearest-decides'), ('double_team', 'double-team'), ('cover', 'cover')) AS v(code, concept)
  JOIN game_concepts c ON c.name = v.concept
 WHERE t.kind = 'machine' AND t.code = v.code;
UPDATE game_engine_terms t SET title = c.title
  FROM (VALUES ('marking_scheme.watching', 'direct-opponent'), ('marking_scheme.zonal', 'zonal-marking'), ('marking_scheme.free', 'libero')) AS v(code, concept)
  JOIN game_concepts c ON c.name = v.concept
 WHERE t.kind = 'machine_state' AND t.code = v.code;
UPDATE game_engine_terms t SET title = v.title
  FROM (VALUES ('pressing_distance.on', 'On'), ('pressing_distance.stepping', 'Stepping into reach'),
               ('cover_shadow.hiding', 'Hiding a man behind him'), ('cover_shadow.on_the_lane', 'Pressing along the lane'),
               ('recover.getting_back', 'On'), ('press.closing', 'On'), ('loose_ball.going', 'Going for the loose ball'),
               ('double_team.second', 'Second man on the ball'), ('cover.behind', 'On')) AS v(code, title)
 WHERE t.kind = 'machine_state' AND t.code = v.code;
