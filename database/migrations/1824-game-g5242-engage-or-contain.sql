-- G5.242 (game/DESIGN.md §8.348): engage-or-contain (game_concepts 157) as the presser's step-in — a capability picked
-- off the shelf, off without these rows, its use set by data (DFL, game/scripts/benchmarks_tracking_fbline.py THE ENGAGE
-- CUE; 7 matches, 5 Hz):
--   "your cover has arrived" — with an opponent inside 1.5 m the ball is taken off a man's feet 0.44 / 0.46 / 0.53 times
--   a second (0-5 / 5-14 / 14 m+ off a touchline) and 0.58 / 0.65 / 0.74 with a second opponent within 5 m: x1.38.
--   "he is pinned on the touchline" — within 5 m of it his nearest opponent is inside 3 m 42% of his time on the ball
--   (32% further in); ours 26%. The presser's stand-off there x0.7.
-- Seeds 1000-4000 x 8: tackles 17.9 -> 20.7 a team-match (20.3), fouls 11.7 -> 13.5 (12.5), a defender inside 3 m of a
-- man within 5 m of the touchline 26 -> 32% of his time (42), card 10 / 9 / 14 -> 14 / 7 / 12.
INSERT INTO game_model_params (owner, code, param, value, unit, note) VALUES
 ('physics', 'press', 'engage_cover', 1.38, 'x', 'G5.242 §8.348 engage-or-contain: the presser''s tackle clock with a mate within engage_cover_m of the ball (his cover has arrived) — DFL 0.58-0.74 v 0.44-0.53 a second'),
 ('physics', 'press', 'engage_cover_m', 5, 'm', 'G5.242 §8.348: how near the ball a second defender counts as cover'),
 ('physics', 'press', 'pinned_scale', 0.7, 'x', 'G5.242 §8.348 engage-or-contain: the presser''s stand-off when the carrier is within pinned_m of a touchline — DFL nearest opponent inside 3 m 42% of the time there v 32% further in'),
 ('physics', 'press', 'pinned_m', 5, 'm', 'G5.242 §8.348: how near the touchline the carrier counts as pinned')
ON CONFLICT (owner, code, param) DO UPDATE SET value = EXCLUDED.value, unit = EXCLUDED.unit, note = EXCLUDED.note;

-- The two behaviours, in the engine's index (docs/taxonomy-one-system.md). The game's scratch DB has no index table.
DO $$
BEGIN
  IF to_regclass('public.game_engine_behaviours') IS NOT NULL THEN
    INSERT INTO game_engine_behaviours (code, file, line, symbol, class_name, tag, who, what, status, concept_id, other_concepts, suggested, confidence, is_read) VALUES
     ('press_engage_cover_arrived', 'game/src/ai/DefendingBlock.cpp', 118, 'PressBall', 'PressBall', 'G5.242 §8.348', 'individual',
      'In tackle reach and goal-side of the carrier with a mate within 5 m of the ball (his cover has arrived), the presser steps in sooner: his tackle clock x1.38 (rows physics.press.engage_cover / engage_cover_m; DFL).',
      'concept', 157, 'double-team, delay', NULL, 'medium', false),
     ('press_step_in_pinned_touchline', 'game/src/ai/DefendingBlock.cpp', 103, 'PressBall', 'PressBall', 'G5.242 §8.348', 'individual',
      'The carrier within 5 m of a touchline (pinned): the presser stands 0.7 of his rolled stand-off off him (rows physics.press.pinned_scale / pinned_m; DFL).',
      'concept', 157, 'double-team, jockey-angle, touchline-trap', NULL, 'medium', false)
    ON CONFLICT (code) DO UPDATE SET file = EXCLUDED.file, line = EXCLUDED.line, symbol = EXCLUDED.symbol, class_name = EXCLUDED.class_name, tag = EXCLUDED.tag,
      who = EXCLUDED.who, what = EXCLUDED.what, status = EXCLUDED.status, concept_id = EXCLUDED.concept_id, other_concepts = EXCLUDED.other_concepts, confidence = EXCLUDED.confidence;
  END IF;
END $$;
