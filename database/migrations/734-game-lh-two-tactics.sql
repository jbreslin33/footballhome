-- 734 (2026-10-26) — game: Lighthouse's two tactics on the full-back /
-- winger, picked live in the HUD (game/DESIGN.md §8.63, G4.65).
--
-- James 10/26: "so there are diff concepts here for the 2 to 7 and 3 to 11.
-- the standard one and the one for this session is 3 rules. #1 priority
-- interception, #2 no turn, #3 contain. there is another tactic where our
-- winger does a cover shadow from their winger to fb. after they stay in
-- middle to protect midfield during cb to fb ball transmission they go to
-- the closest point of future line of pass from fb to winger. then traverse
-- up to fb while looking behind and see if winger moves and thus adjusting
-- cover shadow. in this concept the standard thing for our fb there is to
-- not play tight since ball to the ground is cover shadowed so they play
-- off for long ball. can we have in the hud a way to pick the tactic? of
-- course in general on both tactics they still always have a direct
-- opponent to mark its just how they mark."
--
-- Tactic A = the Lighthouse APSL model itself (defend-your-man asked 90).
-- Tactic B = a child model, "Lighthouse APSL — shadow the line": inherits
-- everything, adds shadow-the-line and play-off-long-ball. Pick either in
-- the game's admin bar (the game-model dropdown, Home / Away) — no new
-- wire. Defaults where James hadn't said (CONCEPTS.md NEXT): the line is
-- always full-back → their winger wherever he goes; the 3 rules apply to
-- every man-marker, our full-back included when the ball goes down the line.

INSERT INTO game_concepts (id, name, title, family, moment, kind, taught_from, status, cue_answer, lacking, principle_id) VALUES
 (168, 'defend-your-man', 'Defend your man: intercept, no turn, contain', 'individual', 'out_of_possession', 'style', 'amateur', 'wired',
  'Three rules in order. 1: the pass to your man — get to it first if you can. 2: if not, arrive tight and goal-side as it arrives, and while he has it with his back to goal stay tight — don''t dive in, don''t let him turn. 3: he''s turned — contain him.',
  'Dives in on a man with his back to goal, or arrives late and lets him turn.',
  (SELECT id FROM game_principles WHERE code = 'op-mark')),
 (169, 'shadow-the-line', 'Shadow the line to their winger', 'individual', 'out_of_possession', 'style', 'amateur', 'wired',
  'Protect the middle while their centre-back plays to the full-back; then get to the nearest point of the full-back''s pass line to their winger and work up it to the full-back, looking behind — when their winger moves, move the shadow.',
  'Runs straight at the full-back: the ball down the line to their winger is open.',
  (SELECT id FROM game_principles WHERE code = 'op-press-team')),
 (170, 'play-off-long-ball', 'Play off for the long ball', 'individual', 'out_of_possession', 'style', 'amateur', 'wired',
  'Our winger has the ground ball to your man shadowed: don''t play tight — stand off him, goal-side, and win the ball over the top.',
  'Tight on a man the ground ball can''t reach: the ball over the top goes in behind him.',
  (SELECT id FROM game_principles WHERE code = 'op-mark'))
ON CONFLICT (id) DO NOTHING;

INSERT INTO game_concept_links (concept_id, other_id, kind) VALUES
 (168, 160, 'requires'), (168, 162, 'refines'), (168, 157, 'refines'),
 (169, 165, 'requires'), (169, 27, 'refines'),
 (170, 169, 'requires'), (170, 160, 'requires')
ON CONFLICT DO NOTHING;

INSERT INTO game_concept_sources (concept_id, source_id, citation)
SELECT c, id, cite FROM game_sources, (VALUES
  (168, 'fh', 'James 10/26: "3 rules. #1 priority interception, #2 no turn, #3 contain" — Lighthouse''s standard on the full-back / winger'),
  (168, 'coaching-standard', 'the defender''s order: intercept, else stop him turning, else delay/contain'),
  (169, 'fh', 'James 10/26: the winger goes to the nearest point of the future full-back→winger pass line and traverses up to the full-back, adjusting the cover shadow as their winger moves. Lighthouse''s own'),
  (170, 'fh', 'James 10/26: with the ground ball cover-shadowed our full-back plays off his winger for the long ball. Lighthouse''s own')
) AS v(c, code, cite)
WHERE game_sources.code = v.code
ON CONFLICT DO NOTHING;

-- Tactic A: the Lighthouse APSL model (both tactics inherit it).
INSERT INTO game_model_concepts (model_id, concept_id, demand, citation)
SELECT m.id, c.id, 90, 'Lighthouse''s standard: intercept, no turn, contain (James 10/26).'
  FROM game_models m, game_concepts c
 WHERE m.name = 'Lighthouse APSL' AND c.name = 'defend-your-man'
ON CONFLICT (model_id, concept_id) DO UPDATE SET demand = EXCLUDED.demand, citation = EXCLUDED.citation;

-- Tactic B: a child of Lighthouse APSL.
INSERT INTO game_models (name, kind, parent_id, formation_code, note, sort_order)
SELECT 'Lighthouse APSL — shadow the line', 'team', p.id, p.formation_code,
       'Lighthouse APSL, second tactic: the winger shadows the full-back→winger line, our full-back plays off for the long ball (James 10/26).',
       p.sort_order + 1
  FROM game_models p WHERE p.name = 'Lighthouse APSL'
ON CONFLICT (name) DO NOTHING;
INSERT INTO game_model_concepts (model_id, concept_id, demand, citation)
SELECT m.id, c.id, 90, v.citation FROM (VALUES
 ('shadow-the-line', 'The winger shadows the full-back→winger line (James 10/26).'),
 ('play-off-long-ball', 'Our full-back plays off for the long ball (James 10/26).')
) AS v(name, citation)
JOIN game_concepts c ON c.name = v.name
JOIN game_models m ON m.name = 'Lighthouse APSL — shadow the line'
ON CONFLICT (model_id, concept_id) DO UPDATE SET demand = EXCLUDED.demand, citation = EXCLUDED.citation;

INSERT INTO game_model_params (owner, code, param, value, unit, note)
SELECT v.* FROM (VALUES
 ('concept', 'defend-your-man', 'no_turn_gap_m', 0.7::numeric, 'm', 'Rule 2: this far goal-side of his man while he has it with his back to our goal.'),
 ('concept', 'defend-your-man', 'no_turn_within_m', 3, 'm', 'Rule 2 holds when the defender is within this of his man (further, he closes as normal).'),
 ('concept', 'shadow-the-line', 'from_fb_m', 3, 'm', 'Up the line he stops this far from the full-back.'),
 ('concept', 'shadow-the-line', 'on_line_m', 1.5, 'm', 'Within this of the pass line he is on it, and works up to the full-back.'),
 ('concept', 'shadow-the-line', 'handover_m', 3, 'm', 'Closer than this to a full-back on the ball, the normal press takes over.'),
 ('concept', 'play-off-long-ball', 'off_m', 7, 'm', 'Our full-back stands this far goal-side of their winger while the ground ball is shadowed.')
) AS v(owner, code, param, value, unit, note)
WHERE NOT EXISTS (SELECT 1 FROM game_model_params g WHERE g.owner = v.owner AND g.code = v.code AND g.param = v.param);
