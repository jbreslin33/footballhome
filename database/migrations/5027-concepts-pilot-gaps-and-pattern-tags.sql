-- 5027 (2026-11-27): concepts revisit, step 2 — what the 300-pattern tagging pilot (Daniel, Bielsa
-- Thirteen Steps, Zonal Marking) said was missing, and where book patterns' tags live.
--   * 9 new concepts, each seen in 2+ pilot patterns (queued: teaching first, engine later)
--   * style concepts point at the style dimension they are one end of (game_style_dimensions, -2..2,
--     the same scale as game_style_dimension_links); NULL value = the concept IS the whole dial
--   * coaching_book_pattern_concepts: a pattern's main concept + the others it involves
--   * coaching_book_pattern_styles: a pattern that shows a team's style choice
--   * coaching_book_patterns.concept_fit: tagged / none (no concept covers it) / not_behaviour
--     (formation or history only); NULL = not yet tagged. Replaces the never-filled concept_id.
BEGIN;

INSERT INTO game_concepts (id, name, title, family, moment, status, kind, principle_id, definition, cue_answer, lacking)
SELECT v.id, v.name, v.title, v.family, v.moment, 'queued', 'skill', p.id, v.def, v.cue, v.lacking
  FROM (VALUES
  (191, 'screen-back-four', 'Screen the back four', 'individual', 'out_of_possession', 'op-compact',
   'Without the ball the holding midfielder (or two) sits in the space just in front of the back line, shuts the passes into it and picks up anyone who drops in there.',
   'Their 10 or a dropping forward wants the ball between our lines: be there first, goal-side, and deny the pass.',
   'Their 10 receives between our lines unopposed and turns at the back four.'),
  (192, 'cross-delivery', 'Pick the cross', 'individual', 'in_possession', 'ip-create',
   'From wide, choose the delivery that fits: early and hard into the gap between their line and the keeper before they set, whipped or lifted over the near defenders to the far post, or the cut-back once on the byline.',
   'Wide with the ball and runners going: early behind the line if they are still running back, far post if the near side is crowded, cut-back from the byline.',
   'Every cross floated to the near defender''s head.'),
  (193, 'wingback-drop-five', 'Wing-back: drop to make five', 'individual', 'out_of_possession', 'op-compact',
   'Without the ball, and the moment we lose it, the wing-back sprints back into line beside the back three so the line becomes five and the space outside each wide centre-back is closed.',
   'We lose it or settle into our block: get back level with the back three, beside the outside centre-back.',
   'A back three stretched across the width, with the space beside it open on the counter.'),
  (194, 'channel-run', 'Run the channel', 'individual', 'in_possession', 'ip-progress',
   'The striker runs in behind through the gap between their centre-back and full-back, pulling a centre-back wide and out of the middle.',
   'A teammate can play forward: go through the gap between their centre-back and full-back, staying onside.',
   'Every run straight at the centre-backs, who stay where they are strongest.'),
  (195, 'ball-playing-cb', 'Centre-back: first playmaker', 'individual', 'in_possession', 'ip-build-up',
   'The free centre-back, left time by their press, looks forward first and plays the pass that starts the attack rather than handing it to the full-back or keeper.',
   'Free centre-back with time: lift your head and find the forward pass through their first line.',
   'The free centre-back always plays it sideways, and the attack starts where they want it.'),
  (196, 'drift-to-overload', 'Drift across to the ball side', 'individual', 'in_possession', 'ip-progress',
   'The free midfielder leaves his zone and drifts across, behind their midfield, to the side the ball is on, so we have an extra man there.',
   'Ball on one side and nobody marking you: drift across behind their midfield to add a man near the ball.',
   'The spare man stays in his zone on the far side while the ball side is outnumbered.'),
  (197, 'both-fullbacks-go', 'Both full-backs go, the holders stay', 'team', 'in_possession', 'ip-shape',
   'Both full-backs push on together for width, while the two holding midfielders and the centre-backs stay back as cover.',
   'We are settled in their half: both full-backs high and wide; the two holders sit in front of the centre-backs.',
   'Both full-backs go and nobody covers, or neither goes and the attack has no width.'),
  (198, 'diagonal-to-flank', 'Run out to the empty flank', 'individual', 'to_attack', 'ta-spread',
   'On a counter with our wide man still deep, a central midfielder or forward runs diagonally out to fill the flank.',
   'We win it and the wing is empty: run diagonally out to it so the carrier has a wide outlet.',
   'The counter runs straight down the middle into their recovering men.'),
  (199, 'strike-pair-jobs', 'Strike pair: split the jobs', 'group', 'in_possession', 'ip-create',
   'Two strikers never do the same thing: one runs the channel or comes short, the other attacks the box, so the passer always has two different outlets.',
   'Your partner goes short or wide: you go long or attack the box.',
   'Both strikers make the same run, and one defender marks both.')
  ) v(id, name, title, family, moment, pcode, def, cue, lacking)
  JOIN game_principles p ON p.code = v.pcode;

INSERT INTO game_concept_links (concept_id, other_id, kind)
SELECT a.id, b.id, v.k FROM (VALUES
  ('channel-run',        'runs',                 'refines'),
  ('drift-to-overload',  'overload-to-isolate',  'refines'),
  ('diagonal-to-flank',  'regain-spread',        'refines'),
  ('ball-playing-cb',    'play-out-back',        'refines'),
  ('both-fullbacks-go',  'rest-defense',         'requires'),
  ('cut-back',           'cross-delivery',       'kind-of'),
  ('wingback-drop-five', 'recover',              'refines'),
  ('screen-back-four',   'compact-block',        'refines'),
  ('strike-pair-jobs',   'channel-run',          'requires')) v(a, b, k)
JOIN game_concepts a ON a.name = v.a JOIN game_concepts b ON b.name = v.b
ON CONFLICT DO NOTHING;

-- Style concepts → their dimension.
ALTER TABLE game_concepts
  ADD COLUMN style_dimension_id integer REFERENCES game_style_dimensions(id),
  ADD COLUMN style_value smallint CHECK (style_value BETWEEN -2 AND 2),
  ADD CONSTRAINT game_concepts_style_dim_check CHECK (style_dimension_id IS NULL OR kind = 'style');

UPDATE game_concepts c SET style_dimension_id = d.id, style_value = v.val
  FROM (VALUES
  ('man-mark',       'orientation',   2),
  ('zonal-marking',  'orientation',  -2),
  ('short-simple',   'possession',    2),
  ('direct-ball',    'possession',   -2),
  ('verticality',    'tempo',         2),
  ('pass-ladder',    'tempo',         1),
  ('counter-attack', 'after-win',     2),
  ('block-height',   'block-height', NULL)) v(name, dcode, val)
  JOIN game_style_dimensions d ON d.code = v.dcode
 WHERE c.name = v.name;

-- Book pattern tags.
-- game_taxonomy_chain (mig 1932) counted patterns through the old column: rebuilt below on the link table.
DROP VIEW game_taxonomy_chain;
ALTER TABLE coaching_book_patterns DROP COLUMN concept_id;
ALTER TABLE coaching_book_patterns ADD COLUMN concept_fit text
  CHECK (concept_fit IN ('tagged', 'none', 'not_behaviour'));

CREATE TABLE coaching_book_pattern_concepts (
  pattern_id integer  NOT NULL REFERENCES coaching_book_patterns(id) ON DELETE CASCADE,
  concept_id smallint NOT NULL REFERENCES game_concepts(id),
  is_main    boolean  NOT NULL DEFAULT false,
  fit        text     NOT NULL DEFAULT 'good' CHECK (fit IN ('good', 'loose')),
  PRIMARY KEY (pattern_id, concept_id));
CREATE UNIQUE INDEX coaching_book_pattern_concepts_one_main ON coaching_book_pattern_concepts (pattern_id) WHERE is_main;
CREATE INDEX coaching_book_pattern_concepts_concept ON coaching_book_pattern_concepts (concept_id);

CREATE TABLE coaching_book_pattern_styles (
  pattern_id   integer  NOT NULL REFERENCES coaching_book_patterns(id) ON DELETE CASCADE,
  dimension_id integer  NOT NULL REFERENCES game_style_dimensions(id),
  value        smallint NOT NULL CHECK (value BETWEEN -2 AND 2),
  PRIMARY KEY (pattern_id, dimension_id));

CREATE VIEW game_taxonomy_chain AS
SELECT p.id, p.code, p.title, p.level, p.side,
  (SELECT count(DISTINCT t.source_id) FROM game_common_principle_links l
     JOIN game_source_principles t ON t.id = l.term_id WHERE l.principle_id = p.id) AS sources,
  (SELECT count(*) FROM game_principles g WHERE g.play_principle_id = p.id) AS model_principles,
  (SELECT count(*) FROM game_concepts c JOIN game_principles g ON g.id = c.principle_id
    WHERE g.play_principle_id = p.id) AS concepts,
  (SELECT count(*) FROM game_engine_behaviours b JOIN game_concepts c ON c.id = b.concept_id
     JOIN game_principles g ON g.id = c.principle_id WHERE g.play_principle_id = p.id) AS engine_behaviours,
  (SELECT count(*) FROM game_engine_behaviours b JOIN game_concepts c ON c.id = b.concept_id
     JOIN game_principles g ON g.id = c.principle_id WHERE g.play_principle_id = p.id AND b.in_sim) AS in_sim,
  (SELECT count(*) FROM coaching_book_pattern_concepts bc JOIN game_concepts c ON c.id = bc.concept_id
     JOIN game_principles g ON g.id = c.principle_id
    WHERE bc.is_main AND g.play_principle_id = p.id) AS book_patterns
FROM game_play_principles p;

COMMIT;
