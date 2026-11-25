-- 1920 (2026-11-25): stay in pressing distance, done FULLY = in reach AND goal side; the test = no forward progress.
-- Owner 11/25: "we need to judge based on where the ball is right and where we are in relation to our goal? being able
-- to press but the player can dribble to our goal lol is bad as we are 'chasing'" · "so the concept has to include to
-- be correct fully we need to prevent forward progress right? or it will fail?"
-- Engine: PressReach::goal_side (nearer his own goal than his man is), REACH flag 4 — a read only, the sim unchanged.
-- Viewer: in reach on the wrong side is NOT in it (red, its own banner). Clip judge (fh-concept-clips): good needs goal
-- side at the kick; bad = they got forward and he was too far OR near but chasing.

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
SELECT 'Football', 'Concept viewer — ' || v.l, 'taxonomy', v.t, NULL, v.b, v.o, true, true
  FROM (VALUES
    ('focus: in reach, wrong side ({num}, {man}, {gap}, {reach})', 'focus_pd_wrongside',
     '✗ WRONG SIDE — #{num} can reach #{man} ({gap} m) but is not between him and goal: he would be chasing', 507),
    ('clips: outcome forward, wrong side ({gap}, {m})', 'clip_out_forward_wrongside',
     'Near his man ({gap} m) but on the wrong side — they went {m} m forward', 508),
    ('clips: outcome goal, wrong side', 'clip_out_goal_wrongside', 'Near his man but on the wrong side — they scored', 509)
  ) AS v(l, t, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'taxonomy' AND m.tier = v.t);

UPDATE message_templates SET body = '✓ IN PRESSING DISTANCE — #{num} on #{man}: {gap} m away, he can reach {reach} m, goal side'
 WHERE kind = 'taxonomy' AND tier = 'focus_pd_in';

INSERT INTO game_engine_behaviours (code, file, line, tag, who, what, status, concept_id, other_concepts, suggested, confidence, is_read, in_sim)
SELECT 'pd_goal_side', 'game/src/ai/concepts/PressingDistance.cpp', 48, 'pressing distance goal side 11/25', 'individual',
       'Goal side of his man: he is nearer his own goal (its centre) than his man is, so the man cannot run at goal past him. Pressing distance done fully = in reach AND goal side. A read (REACH flag 4, the viewer, the clip judge); the sim does not act on it.',
       'concept', 164, '', NULL, 'high', true, false
 WHERE NOT EXISTS (SELECT 1 FROM game_engine_behaviours WHERE code = 'pd_goal_side');
