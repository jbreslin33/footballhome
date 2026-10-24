-- 672 (2026-10-23) — game: meet the pass — the receiving end (game/DESIGN.md
-- §8.44, G4.49).
--
-- G4.44 parked release timing because "the ball in behind rarely reaches
-- the runner". fh-game-match's pass tally (G4.48) showed why: while OUR
-- pass travelled, every brain read the free ball as THEIR ball — the
-- receiver stood still, the forwards turned back goal-side, and the man the
-- passer picked got 24% of passes (the ball in behind: 2%). The engine now
-- reads the flight (where and when each player can first take the ball,
-- in the air too); this concept is our side's half of that read, intercept
-- (20) is theirs. Core: every coached kid is told "come to the ball".

INSERT INTO game_concepts (id, name, title, family, moment, kind, taught_from, status, cue_answer, lacking, principle_id) VALUES
 (153, 'meet-the-pass', 'Meet the pass', 'individual', 'in_possession', 'core', 'u10', 'wired',
  'Our pass is travelling: the man who can get to it first goes to meet it where he can; the rest keep playing — it''s still our ball.',
  'The receiver waits where he stood, and the team turns back to defend its own pass.', 3)
ON CONFLICT (id) DO NOTHING;

INSERT INTO game_concept_sources (concept_id, source_id, citation)
SELECT 153, id, '[Buckland] Simple Soccer ReceiveBall state (re-expressed stateless)' FROM game_sources WHERE code = 'buckland'
UNION ALL SELECT 153, id, '"come to the ball" — the first receiving lesson' FROM game_sources WHERE code = 'coerver'
UNION ALL SELECT 153, id, 'the flight read: measured 24% to the picked man (G4.48 pass tally)' FROM game_sources WHERE code = 'fh'
ON CONFLICT DO NOTHING;

INSERT INTO game_model_params (owner, code, param, value, unit, note)
SELECT v.* FROM (VALUES
 ('concept', 'meet-the-pass', 'reaction_s', 0.2::numeric, 's', 'Everyone starts for a free ball this long after it moves (plus his perception delay).'),
 ('concept', 'meet-the-pass', 'horizon_ticks', 90, 'ticks', 'How far ahead the flight is read (3 s at 30 Hz).'),
 ('concept', 'meet-the-pass', 'keep_running_mps', 3, 'm/s', 'A man ahead of our ball in flight moving forward at least this fast keeps his run going.')
) AS v(owner, code, param, value, unit, note)
WHERE NOT EXISTS (SELECT 1 FROM game_model_params g WHERE g.owner = v.owner AND g.code = v.code AND g.param = v.param);
