-- 869 (2026-10-30) — game: the Lighthouse 9 chills in the box (G4.99,
-- game/DESIGN.md §8.97).
--
-- James 10/30: "lh 9 is still going after cb of ukies. he is supposed to
-- chill and help cover shadow ukiies 6,8,10 or even double mark them checking
-- in. then as soon as ball is struck he goes to mark the ball side cb to stop
-- back pass." Measured from the keeper: 27% of his time with their centre-back
-- on the ball he was "pressing a drive" at the old 2 m/s bar — a man taking a
-- touch — and a lapse of the pack sent him at the centre-back, his direct
-- opponent.

BEGIN;

UPDATE game_model_params
   SET value = 4,
       note = 'G4.99: their centre-back carrying toward our goal at least this fast is DRIVING — the 9''s trigger to press him (James 10/29). 4 m/s, a run not a touch (was 2). [FH]'
 WHERE owner = 'concept' AND code = 'pack-the-middle' AND param = 'cb_drive_mps';

INSERT INTO game_model_params (owner, code, param, value, unit, note)
SELECT v.* FROM (VALUES
  ('concept', 'pack-the-middle', 'nine_check_in_mps', 2::numeric, 'm/s',
   'G4.99: a central man coming toward the ball at least this fast is CHECKING IN — the 9 can double him (James 10/30). [FH]'),
  ('concept', 'pack-the-middle', 'nine_double_gap_m', 2, 'm',
   'G4.99: the 9 doubles a man checking in this far off him, on the line from the ball.'),
  ('concept', 'pack-the-middle', 'nine_double_reach_m', 12, 'm',
   'G4.99: the 9 only doubles a man this close to his box — further and he stays on the shadow.')
) AS v(owner, code, param, value, unit, note)
WHERE NOT EXISTS (SELECT 1 FROM game_model_params g WHERE g.owner = v.owner AND g.code = v.code AND g.param = v.param);

COMMIT;
