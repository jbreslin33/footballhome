-- 730 (2026-10-26) — game: Lighthouse packs the middle, then presses the
-- pass to the full-back (game/DESIGN.md §8.62, G4.64).
--
-- James 10/26, Lighthouse defending the Ukies' build-up: "in bielsa he would
-- look the then cover shadow the center backs 4 and 5. but our lh tactic is
-- for him to … play a false 9 so in defense he will drop and assist the man
-- markers in the lh midfield the 6 8 and 10. also our 7 and 11 will assist
-- the midfield as well by staying tight inside. this gives us a 6v3 in
-- midfield. this will cause the center backs to take easy route because we
-- also have libero for long balls. so they will pass to fb on either side.
-- this is when our ball side 7 or 11 go after their direct opponent while
-- cover shadowing middle. our weak side 7 or 11 tuck in further to give us
-- extra midfielder and our 9 'locks the door' by now going up to the
-- closest cb and not allow a return pass from fb to cb. he can play off a
-- little and shade toward weakside cb to discourage that long pass." /
-- "we essentially pack the middle then wait for the inevitable pass to full
-- then we press" / "the ball side 7/11 doesn't curve run he just cover
-- shadows their 6 8 10 … while stepping to direct op" / "if there is no
-- concept you found like this in literature then attribute to lh".
--
-- Literature: the narrow front three that shows the build-up wide and
-- springs on the full-back is Klopp's Liverpool press (the wingers' run
-- there is CURVED; Lighthouse steps straight, the cover shadow on the
-- midfield is the point); the pass wide as the trigger is Rangnick's. The
-- false 9 dropping in to make 6 v 3, the far winger as an extra midfielder
-- and the 9's "lock the door" (shaded to the far centre-back) are
-- Lighthouse's own [FH].
--
-- Style lessons taught from amateur, asked for by the Lighthouse APSL team
-- model only (the Ukies and Bielsa don't). Lighthouse's 9 no longer runs at
-- their building CB on a cover shadow (Bielsa's, mig 642): its demand is 0
-- for Lighthouse APSL.

INSERT INTO game_concepts (id, name, title, family, moment, kind, taught_from, status, cue_answer, lacking, principle_id) VALUES
 (165, 'pack-the-middle', 'Pack the middle', 'team', 'out_of_possession', 'style', 'amateur', 'wired',
  'They build in their half: the false 9 drops in front of their midfield, on the line from the ball, and both wingers tuck inside — with the 6, 8 and 10 on their men that is 6 v 3 in the middle. Leave their full-backs open; that pass is the one we want.',
  'The front three stand on their back line: their centre-backs play through the middle to a free midfielder.',
  (SELECT id FROM game_principles WHERE code = 'op-compact')),
 (166, 'press-the-full-back', 'Press the pass to the full-back', 'group', 'out_of_possession', 'style', 'amateur', 'wired',
  'The ball goes to their full-back: the ball-side winger steps straight at him, standing on the line to their nearest midfielder so the ball back inside goes through you. The far winger tucks in further.',
  'Nobody goes when the ball goes wide: the full-back has time to pick the pass back inside.',
  (SELECT id FROM game_principles WHERE code = 'op-press-team')),
 (167, 'lock-the-door', 'Lock the door', 'individual', 'out_of_possession', 'style', 'amateur', 'wired',
  'On the pass to their full-back, the 9 goes up to the nearest centre-back, a little off him on the line to the full-back — no return pass — and leans toward the far centre-back to put off the long switch.',
  'The 9 stays dropped: the full-back plays it back to the centre-back and they switch play.',
  (SELECT id FROM game_principles WHERE code = 'op-press-team'))
ON CONFLICT (id) DO NOTHING;

INSERT INTO game_concept_links (concept_id, other_id, kind) VALUES
 (165, 17, 'refines'), (165, 160, 'requires'),
 (166, 165, 'requires'), (166, 27, 'refines'), (166, 160, 'requires'),
 (167, 165, 'requires'), (167, 27, 'refines')
ON CONFLICT DO NOTHING;

INSERT INTO game_concept_sources (concept_id, source_id, citation)
SELECT c, id, cite FROM game_sources, (VALUES
  (165, 'fh', 'James 10/26: the false 9 drops and the 7 and 11 tuck in — 6 v 3 in midfield; the libero takes the long ball, so their CBs go wide'),
  (165, 'klopp', 'Liverpool''s narrow front three in the press: shut the middle, show the build-up wide'),
  (166, 'fh', 'James 10/26: the ball-side 7/11 steps straight to his direct opponent while cover-shadowing their 6/8/10 — no curved run'),
  (166, 'rangnick', 'the pass wide as the pressing trigger: the touchline is the extra defender'),
  (166, 'klopp', 'the winger springs on the full-back when the ball goes wide (Liverpool''s run is curved; Lighthouse''s is straight)'),
  (167, 'fh', 'James 10/26: the 9 "locks the door" — up to the closest CB, no return pass, shaded toward the weak-side CB against the long pass. Lighthouse''s own')
) AS v(c, code, cite)
WHERE game_sources.code = v.code
ON CONFLICT DO NOTHING;

INSERT INTO game_model_concepts (model_id, concept_id, demand, citation)
SELECT m.id, c.id, v.demand, v.citation FROM (VALUES
 ('pack-the-middle', 90, 'Lighthouse''s plan without the ball: pack the middle (James 10/26).'),
 ('press-the-full-back', 90, 'Lighthouse''s trigger: the pass to their full-back (James 10/26).'),
 ('lock-the-door', 90, 'Lighthouse''s 9 locks the door on the return pass (James 10/26).'),
 ('cover-shadow', 0, 'Lighthouse''s 9 drops as a false 9 instead of Bielsa''s cover-shadow press on the CB (James 10/26).')
) AS v(name, demand, citation)
JOIN game_concepts c ON c.name = v.name
JOIN game_models m ON m.name = 'Lighthouse APSL'
ON CONFLICT (model_id, concept_id) DO UPDATE SET demand = EXCLUDED.demand, citation = EXCLUDED.citation;

INSERT INTO game_model_params (owner, code, param, value, unit, note)
SELECT v.* FROM (VALUES
 ('concept', 'pack-the-middle', 'false_nine_number', 9::numeric, 'number', 'The position number that plays the false 9.'),
 ('concept', 'pack-the-middle', 'right_wing_number', 7, 'number', 'A winger who tucks in (and presses the full-back on his side).'),
 ('concept', 'pack-the-middle', 'left_wing_number', 11, 'number', 'The other winger.'),
 ('concept', 'pack-the-middle', 'midfield_number_a', 6, 'number', 'Our midfield man markers: the men they mark are the ones the 9 and wingers screen.'),
 ('concept', 'pack-the-middle', 'midfield_number_b', 8, 'number', 'Our midfield man markers (second).'),
 ('concept', 'pack-the-middle', 'midfield_number_c', 10, 'number', 'Our midfield man markers (third).'),
 ('concept', 'pack-the-middle', 'tuck_width_m', 14, 'm', 'The wingers screen their midfield no wider than this off the centre line.'),
 ('concept', 'pack-the-middle', 'weak_tuck_width_m', 7, 'm', 'On the trigger the far winger tucks in to this — an extra midfielder.'),
 ('concept', 'pack-the-middle', 'central_width_m', 18, 'm', 'Their men within this of the centre line are the middle; a man wider is a full-back on the ball.'),
 ('concept', 'pack-the-middle', 'screen_gap_m', 3, 'm', 'The false 9 and wingers stand this far off the man they screen, toward the ball.'),
 ('concept', 'pack-the-middle', 'from_halfway_m', 0, 'm', 'The plan holds while the ball is at least this far into their half.'),
 ('concept', 'pack-the-middle', 'handover_m', 4, 'm', 'Closer than this to the carrier, the normal press takes over.'),
 ('concept', 'press-the-full-back', 'step_gap_m', 1.5, 'm', 'The winger stands this far off the full-back, on the line to their midfield.'),
 ('concept', 'press-the-full-back', 'shadow_ahead_m', 2, 'm', 'Their midfielder he shadows is level with the full-back or ahead of him, give or take this.'),
 ('concept', 'press-the-full-back', 'handover_m', 3, 'm', 'Closer than this to a full-back on the ball, he presses / tackles as normal.'),
 ('concept', 'lock-the-door', 'lock_gap_m', 3, 'm', 'The 9 stands this far off the near centre-back, on the line to the full-back.'),
 ('concept', 'lock-the-door', 'shade_m', 2, 'm', 'And this far toward the far centre-back, against the long switch.')
) AS v(owner, code, param, value, unit, note)
WHERE NOT EXISTS (SELECT 1 FROM game_model_params g WHERE g.owner = v.owner AND g.code = v.code AND g.param = v.param);

-- The screen covers the wingers too (G4.64 tuning, same day).
UPDATE game_model_params SET note = 'The wingers screen their midfield no wider than this off the centre line.'
 WHERE owner = 'concept' AND code = 'pack-the-middle' AND param = 'tuck_width_m';
UPDATE game_model_params SET note = 'The false 9 and wingers stand this far off the man they screen, toward the ball.'
 WHERE owner = 'concept' AND code = 'pack-the-middle' AND param = 'screen_gap_m';
