-- 648 (2026-10-23) — game: the blind-side run + an offside-aware pass
-- ladder (game/DESIGN.md §8.32, CONCEPTS.md G4.35 plan).
--
-- James: "build blind_side_run next". Concept bit 30 'blind-side-run',
-- class ai::BlindSideRun [Bielsa-Leeds f7/21/35/46/48/51/65/78/81/82]:
-- the two most advanced attackers wait onside on the far shoulder of their
-- defender and go in behind when the carrier is free to pass and the
-- defender can't see them; a run the pass didn't find comes back onside.
-- STYLE (default 0). NOT yet in the Bielsa preset: measured slightly worse
-- than the ladder alone (DESIGN §8.32) — numbers here so it can be tuned
-- and switched on by a later row.
--
-- The pass ladder (mig 646) now skips men in an offside position and
-- leads a moving receiver by the ball's flight time (two new params).

INSERT INTO game_model_params (owner, code, param, value, unit, note) VALUES
 ('concept', 'pass-ladder', 'lead_s',              0.3, 's',
  'Reaction part of the lead on a moving receiver: play him where he will be after this + the ball''s flight [Bielsa-Leeds ch4: rung 1 is a ball into space].'),
 ('concept', 'pass-ladder', 'lead_pass_speed_mps', 12,  'm/s',
  'Average ball speed for the flight part of the lead (distance / this).'),
 ('concept', 'blind-side-run', 'line_band_m',      18,  'm',
  'An attacker within this of their deepest outfield player is "up at their line" and may make the run.'),
 ('concept', 'blind-side-run', 'max_runners',      2,   'players',
  'Only the most advanced few make it — the 9 and a winger or 8 [Bielsa-Leeds ch14/13/7].'),
 ('concept', 'blind-side-run', 'marker_radius_m',  10,  'm',
  'His defender: the nearest line defender within this.'),
 ('concept', 'blind-side-run', 'shoulder_m',       1.5, 'm',
  'Wait on the defender''s far-from-ball shoulder, this far off him [Bielsa-Leeds ch14: on the shoulder, drifting to the blind side].'),
 ('concept', 'blind-side-run', 'onside_margin_m',  2,   'm',
  'Wait this far onside of their line, so the run has an onside window for the pass.'),
 ('concept', 'blind-side-run', 'carrier_free_m',   3.5, 'm',
  'The cue: nobody within this of our carrier — he has time to play (the book''s cue is the passer turning forward, f82).'),
 ('concept', 'blind-side-run', 'blind_cos',        0,   'cos',
  'Behind his eyes: the runner is at more than 90° from the defender''s facing (he is ball-watching, f81).'),
 ('concept', 'blind-side-run', 'run_depth_m',      10,  'm',
  'Run to this far behind their line …'),
 ('concept', 'blind-side-run', 'channel_pull',     0.6, 'ratio',
  '… pulled toward the channel between the defender and goal: a diagonal across his back [Bielsa-Leeds f7/21].'),
 ('concept', 'blind-side-run', 'end_margin_m',     6,   'm',
  'Never run deeper than this short of their goal line.')
ON CONFLICT (owner, code, param) DO UPDATE
   SET value = EXCLUDED.value, unit = EXCLUDED.unit, note = EXCLUDED.note;
