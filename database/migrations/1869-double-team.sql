-- Double-team built whole (game/DESIGN.md §8.361, G5.255) — game_concepts 12, "Trap on the touchline".
--
-- The gap it answers (DFL Bundesliga 22/23 v ours): in their wide last third the ball is taken
-- straight off the attacker's feet 11.4 a team-match v 5.5 (§8.347); within 5 m of a touchline a
-- man on the ball has an opponent inside 1.5 m AND a second within 5 m for 8 s a team-match v 2
-- (THE ENGAGE CUE, §8.348) — only our first presser ever went near him.
--
-- game/src/ai/concepts/DoubleTeam:
--   recognise   their carrier within 12 m of a touchline, our presser within 5 m of him; the
--               second man = our nearest other outfielder within 15 m. His spot: 1.5 m inside the
--               carrier, toward the middle, level with him.
--   choose      physics.press.double_team (0 … 1): the share of such spells we trap, one roll a
--               spell. NO ROW = 0: read only, the sim unchanged.
--   execute     DefendingBlock's DoubleTeamBall state: the second man closes the inside, faces
--               the ball, and in reach has his own tackle clock; the presser keeps his.
-- 188 behaviours tagged (4 new).

UPDATE game_concepts SET definition =
  'Two defenders shut in the man on the ball against the touchline. The first presses him from the front, goal-side; the second comes across and closes the inside — the way back into the pitch — so he is caught between the two of them and the line, and either can take the ball. Do it when the line is close and your presser is already on him. Not this: two men chasing the ball in the middle of the pitch, where he can turn away from both and the man they left is free.'
 WHERE id = 12 AND coalesce(definition, '') = '';

INSERT INTO game_engine_acts (code, concept_id, note)
SELECT 'double_team', 12,
       'DoubleTeamBall: the second man closing the carrier''s inside by the touchline while the presser is on him (ai/concepts/DoubleTeam). Only with physics.press.double_team above 0.'
 WHERE NOT EXISTS (SELECT 1 FROM game_engine_acts WHERE code = 'double_team');

INSERT INTO game_engine_behaviours (code, file, line, tag, who, what, status, concept_id, other_concepts, suggested, confidence, is_read, in_sim)
SELECT v.code, v.file, 1, 'double-team 11/24', v.who, v.what, 'concept', 12, v.other, NULL, 'high', v.is_read, v.in_sim
  FROM (VALUES
    ('dt_trap_on_touchline', 'game/src/ai/concepts/DoubleTeam.cpp', 'group', 'engage-or-contain', true, true,
     'Reads whether their man on the ball is trapped: within 12 m of a touchline with our presser within 5 m of him. If so, our nearest other outfielder within 15 m is the second man, and his spot is 1.5 m inside the carrier, toward the middle of the pitch.'),
    ('dt_roll_per_spell', 'game/src/ai/concepts/DoubleTeam.cpp', 'group', '', true, true,
     'Decides once per spell of the carrier whether this side traps him: a roll against the dial physics.press.double_team. With no row the dial is 0 and nobody is sent.'),
    ('dt_close_the_inside', 'game/src/ai/DefendingBlock.cpp', 'individual', 'close-down', false, false,
     'The second man runs to his spot inside the carrier, facing the ball, so the line and the presser shut him in.'),
    ('dt_tackle_in_reach', 'game/src/ai/DefendingBlock.cpp', 'individual', 'engage-or-contain', false, false,
     'In reach of the ball the second man may tackle, on the presser''s rate with cover — the man who cannot go outside is taken by whichever of the two he turns into.')
  ) AS v(code, file, who, other, is_read, in_sim, what)
ON CONFLICT (code) DO NOTHING;

INSERT INTO game_concept_dials (concept_id, param, on_milli, note)
VALUES (12, 'physics.press.double_team', 1000, 'every spell by a touchline with the presser on him: a second man closes the inside')
ON CONFLICT (concept_id, param) DO NOTHING;

-- The new state's name for the clip viewer's brain panel (STATES frame: engine name → term code).
INSERT INTO game_engine_terms (kind, parent, code, title, note, sort_order, engine_name, definition)
SELECT 'state', 'without', 'double_team', 'Trap the man on the ball with the presser',
       'The second man by a touchline: closes the carrier''s inside while the presser is on him (ai/concepts/DoubleTeam).', 10, 'double-team',
       'They have the ball by a touchline and a team-mate is already pressing the man on it. He is the second man: he comes across and stands on the carrier''s inside, between him and the middle of the pitch, so the line and the two of them shut him in. In reach he can take the ball too.'
 WHERE NOT EXISTS (SELECT 1 FROM game_engine_terms WHERE kind = 'state' AND code = 'double_team');
