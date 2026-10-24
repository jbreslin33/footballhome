-- 686 (2026-10-24) — game: facing apart from movement (game/DESIGN.md
-- §8.49, G4.53).
--
-- Until now a player always faced the way he moved, so there was no
-- backpedal, no side-shuffle, no jockey stance, no keeper set position —
-- and no body for an opponent to read. The intent now carries a facing;
-- his body turns toward it at his own yaw rate, and moving off that line
-- costs speed (his gait). The lesson below is the knowledge that uses it.

INSERT INTO game_concepts (id, name, title, family, moment, kind, taught_from, status, cue_answer, lacking, principle_id) VALUES
 (154, 'face-the-play', 'See ball and man', 'individual', 'out_of_possession', 'core', 'u10', 'wired',
  'Off the ball and only moving a few metres: keep the ball in front of you — shuffle or backpedal, don''t turn your back on the play.',
  'He turns and runs to every new spot, back to the ball, and loses the picture (and his man) each time.', 10)
ON CONFLICT (id) DO NOTHING;

INSERT INTO game_concept_sources (concept_id, source_id, citation)
SELECT 154, id, '"see ball and man" / keep the play in front of you — defending fundamentals' FROM game_sources WHERE code = 'fa-england'
UNION ALL SELECT 154, id, 'body shape: open to see the ball, jockey side-on (defending 1v1 sessions)' FROM game_sources WHERE code = 'coaching-standard'
UNION ALL SELECT 154, id, 'G4.53: facing apart from movement; gaits measured in the engine' FROM game_sources WHERE code = 'fh'
ON CONFLICT DO NOTHING;

INSERT INTO game_model_params (owner, code, param, value, unit, note)
SELECT v.* FROM (VALUES
 ('concept', 'face-the-play', 'within_m', 10::numeric, 'm', 'He faces the ball while adjusting within this distance of where he''s going; further, he turns and runs.'),
 ('skill', 'agility', 'side_share_at0', 0.40, 'share', 'Side-shuffle top speed as a share of his forward top speed, at agility 0. [FH] estimate — lateral shuffle tests run well under half sprint speed; source to pin.'),
 ('skill', 'agility', 'side_share_at50', 0.50, 'share', 'At 50.'),
 ('skill', 'agility', 'side_share_at100', 0.60, 'share', 'At 100.'),
 ('skill', 'agility', 'back_share_at0', 0.55, 'share', 'Backpedal top speed as a share of forward, at 0. [FH] estimate — backward sprinting runs roughly a third slower than forward; source to pin.'),
 ('skill', 'agility', 'back_share_at50', 0.65, 'share', 'At 50.'),
 ('skill', 'agility', 'back_share_at100', 0.75, 'share', 'At 100.'),
 ('skill', 'agility', 'yaw_rads_at0', 7, 'rad/s', 'How fast his body turns to a new facing, at 0 (~400 °/s). [FH] estimate.'),
 ('skill', 'agility', 'yaw_rads_at50', 9, 'rad/s', 'At 50 (~520 °/s).'),
 ('skill', 'agility', 'yaw_rads_at100', 11, 'rad/s', 'At 100 (~630 °/s).')
) AS v(owner, code, param, value, unit, note)
WHERE NOT EXISTS (SELECT 1 FROM game_model_params g WHERE g.owner = v.owner AND g.code = v.code AND g.param = v.param);

UPDATE game_attributes
   SET scales = scales || '; side-shuffle 40/50/60% and backpedal 55/65/75% of forward top speed; body turn 7/9/11 rad/s'
 WHERE code = 'agility' AND scales NOT LIKE '%backpedal%';
