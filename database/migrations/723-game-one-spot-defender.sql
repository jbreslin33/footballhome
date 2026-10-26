-- 723 (2026-10-26) — game: the one-spot defender (game/DESIGN.md §8.60, G4.63).
--
-- James 10/26, Lighthouse defending the Ukies playing out from the keeper:
-- "we need the lh direct opponent to go after their direct opponent as the
-- ball is traveling to him. the others can be in area of direct opponent
-- but also provide cover shadows on other players … another concept is to
-- be within pressing distance of anothers direct opponent" / "these are
-- critical concepts" / "they need to be in taxonomy and lh/bielsa system
-- relies on them to be advanced" / "a player could be close enough to get
-- to direct opponent during pass traversal, while also cover shadowing
-- another opp from current ball carrier who is not their direct opp, while
-- also being dense enough to get to 1 or more others direct opponents to
-- help. this is the on the way to being the ultimate defender" / "we could
-- suck at it at first but the concepts need to be there and applied".
--
-- Advanced = STYLE lessons, taught from amateur (youth bands don't know
-- them), asked for by a game model: Bielsa asks 90-95, so Lighthouse APSL
-- (inherits Bielsa) plays them; the Ukies' U.S. Soccer model does not ask.

INSERT INTO game_concepts (id, name, title, family, moment, kind, taught_from, status, cue_answer, lacking, principle_id) VALUES
 (162, 'jump-the-pass', 'Jump the pass to your man', 'individual', 'out_of_possession', 'style', 'amateur', 'wired',
  'Their pass is travelling to your man: go as the ball goes, so you arrive goal-side as it does and he can''t turn. Too far? The teammate in pressing distance of him goes.',
  'The ball reaches his man and he turns and plays forward with his defender still on his way.', 8),
 (163, 'shadow-second-man', 'Cover-shadow a second man', 'individual', 'out_of_possession', 'style', 'amateur', 'wired',
  'Keep your man in pressing distance, and stand on the line from their ball to someone else''s man, so that pass goes through you.',
  'Every defender stands on his own man only: the carrier has a free pass to anyone who isn''t marked tight.', 10),
 (164, 'pressing-distance', 'Stay in pressing distance', 'individual', 'out_of_possession', 'style', 'amateur', 'wired',
  'Close enough to your man to reach him while a pass to him travels, and close enough to one or more other men to help on them too.',
  'Spread man by man: a pass to anyone is a free first touch, and a beaten defender has no one near to help.', 10)
ON CONFLICT (id) DO NOTHING;

INSERT INTO game_concept_links (concept_id, other_id, kind) VALUES
 (162, 160, 'requires'), (163, 160, 'requires'), (164, 160, 'requires'),
 (163, 27, 'refines'), (164, 158, 'refines'), (162, 164, 'requires')
ON CONFLICT DO NOTHING;

INSERT INTO game_concept_sources (concept_id, source_id, citation)
SELECT c, id, cite FROM game_sources, (VALUES
  (162, 'fh', 'James 10/26: the direct opponent goes after his man as the ball travels to him'),
  (162, 'bielsa-leeds', '[BL ch3] man-oriented press: each presser goes to his man on the pass'),
  (162, 'rangnick', 'the pass as the pressing trigger: press while the ball travels'),
  (163, 'fh', 'James 10/26: cover-shadow another opponent from the carrier, not your direct opponent, while in reach of your own'),
  (163, 'coaching-standard', 'cover shadow: block a passing lane with your body while pressing or marking'),
  (164, 'fh', 'James 10/26: in pressing distance of your man and dense enough to reach one or more others to help — the ultimate defender'),
  (164, 'klopp', 'gegenpressing compactness: short distances so the next man can always press')
) AS v(c, code, cite)
WHERE game_sources.code = v.code
ON CONFLICT DO NOTHING;

INSERT INTO game_model_concepts (model_id, concept_id, demand, citation)
SELECT m.id, c.id, v.demand, v.citation FROM (VALUES
 ('jump-the-pass', 95, '[BL ch3] man-orientation in the press: your man receives, you are on him (James 10/26).'),
 ('shadow-second-man', 90, '[BL ch3] pressers cut the next pass with their run (James 10/26: every marker, not just the 9).'),
 ('pressing-distance', 90, '[BL ch3] the press works because every man is near enough to jump the next pass (James 10/26).')
) AS v(name, demand, citation)
JOIN game_concepts c ON c.name = v.name
JOIN game_models m ON m.name = 'Bielsa'
ON CONFLICT (model_id, concept_id) DO UPDATE SET demand = EXCLUDED.demand, citation = EXCLUDED.citation;

INSERT INTO game_model_params (owner, code, param, value, unit, note)
SELECT v.* FROM (VALUES
 ('concept', 'jump-the-pass', 'arrive_gap_m', 1::numeric, 'm', 'He arrives this far goal-side of where the ball reaches his man.'),
 ('concept', 'jump-the-pass', 'jump_max_m', 30, 'm', 'His man further than this from where the ball lands: the teammate in pressing distance jumps instead.'),
 ('concept', 'shadow-second-man', 'lane_from_passer_m', 4, 'm', 'The lane starts this far from the carrier (closer is pressing him).'),
 ('concept', 'shadow-second-man', 'lane_from_man_m', 3, 'm', 'The lane stops this far short of the man (closer is marking him).'),
 ('concept', 'shadow-second-man', 'lane_width_m', 1, 'm', 'Within this of the line, the ground pass goes through you.'),
 ('concept', 'shadow-second-man', 'lane_weight', 2, 'score', 'What a cut lane is worth when picking the spot (a man in reach to help = 1).'),
 ('concept', 'pressing-distance', 'pass_speed_mps', 14, 'm/s', 'Pass speed assumed when judging how long the ball takes to reach a man.'),
 ('concept', 'pressing-distance', 'reaction_s', 0.3, 's', 'Time to read the pass before he runs.'),
 ('concept', 'pressing-distance', 'contact_m', 1.5, 'm', 'Arriving within this of the man counts as on him.'),
 ('concept', 'pressing-distance', 'help_weight', 1, 'score', 'What each other man in pressing distance is worth when picking the spot.'),
 ('concept', 'pressing-distance', 'move_cost_per_m', 0.1, 'score', 'Cost per metre moved off the marking spot (so he only moves for a real gain).')
) AS v(owner, code, param, value, unit, note)
WHERE NOT EXISTS (SELECT 1 FROM game_model_params g WHERE g.owner = v.owner AND g.code = v.code AND g.param = v.param);
