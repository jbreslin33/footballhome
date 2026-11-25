-- 1905 (2026-11-25): the concept viewer's five boxes, and each man's OWN read of who has the ball.
-- Owner 11/25: "formation is one box-this could change depending on off or def right? 442 def, 433 off. if that
-- is case show both and one on in green and the otehr in red.. playing style is another box. who has ball is
-- another box, tracking possesion by our player that is a decision. at what point does a plaeyr decide we have
-- the ball? that should not be "team" based. then we starat prob with box for main tactical concepts, last box
-- actiosn right like kick, dribble etc?"
--
-- Engine: PlayerAgent::read — every man runs the team's possession reader himself, with his own reaction on top
-- (physics.phase.player_react_s, physics.phase.player_per_10m_s; no rows = 0 = he reads it the tick his team
-- does, so nothing in a match changes yet). His state and his machines go by his read. Frame POSS_READ (0x51).

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
SELECT 'Football', 'Concept viewer — ' || v.l, 'taxonomy', v.t, NULL, v.b, v.o, true, true
  FROM (VALUES
    ('box: possession', 'box_possession', 'Who has the ball', 470),
    ('box: tactical concepts', 'box_concepts', 'Tactical concepts', 471),
    ('shape out of possession ({code})', 'view_shape_out', 'Without the ball: {code}', 472),
    ('shape in possession ({code})', 'view_shape_in', 'With the ball: {code}', 473),
    ('shape out popup ({code}, {team})', 'view_shape_out_def', '{team} defend in a {code}. Green = the shape he is in now, by his own read of who has the ball; red = the other one.', 474),
    ('shape in popup ({code}, {team})', 'view_shape_in_def', '{team} attack in a {code}. Green = the shape he is in now, by his own read of who has the ball; red = the other one.', 475),
    ('same shape both ways ({code})', 'view_shape_same', 'The engine plays one shape both ways today, so both are {code}. A second shape (say 4-4-2 without the ball, 4-3-3 with it) is not built yet.', 476),
    ('possession popup', 'view_read_def', 'This is HIS read, not the team''s: he decides it himself, once the ball has been with the other side long enough for him to see it (0.3 s, plus his own reaction when that is set).', 477),
    ('ball turned, not read yet', 'view_turning', 'The ball has turned — he has not read it yet', 478),
    ('ball turned popup', 'view_turning_def', 'The ball has gone to the other side, but not long enough for him to believe it. Until he does, he keeps playing the phase he was in.', 479)
  ) AS v(l, t, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'taxonomy' AND m.tier = v.t);

UPDATE message_templates SET body = 'Playing style' WHERE kind = 'taxonomy' AND tier = 'box_style' AND body = 'Style';

-- The single "formation" row is now the two shape rows.
UPDATE message_templates SET is_active = false WHERE kind = 'taxonomy' AND tier IN ('view_formation', 'view_formation_def');

INSERT INTO game_engine_behaviours (code, file, line, tag, who, what, status, concept_id, other_concepts, suggested, confidence, is_read, in_sim)
SELECT 'read_possession_own', 'game/src/ai/Brain.cpp', 1, 'own possession read 11/25', 'individual',
       'Each man reads who has the ball himself: the team''s possession reader run for him alone, with his own reaction on top (physics.phase.player_react_s + player_per_10m_s; 0 = the tick his team reads it). His state and his concept machines go by his read.',
       'unnamed', NULL, '', NULL, 'high', true, true
 WHERE NOT EXISTS (SELECT 1 FROM game_engine_behaviours WHERE code = 'read_possession_own');
