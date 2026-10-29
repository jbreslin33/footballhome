-- 858 (2026-10-29) — game: the Lighthouse 9 leaves their centre-backs alone
-- unless one drives (G4.97, game/DESIGN.md §8.95).
--
-- James 10/29: "lh 9 is supposed to sit and cover shadow mid fielders of
-- ukies. he is not activated to go after 4 and 5 of ukies unless they drive
-- forward or the ball is played to the ukie fb then he closes the door on
-- the closest cb to ball." Measured: with their centre-back on the ball the 9
-- counter-pressed him 28% of the time, and a CB driving at us had no answer.

BEGIN;

INSERT INTO game_model_params (owner, code, param, value, unit, note)
SELECT v.* FROM (VALUES
  ('concept', 'pack-the-middle', 'cb_drive_mps', 2::numeric, 'm/s',
   'G4.97: their centre-back carrying toward our goal at least this fast is DRIVING — the 9''s trigger to press him (James 10/29). [FH]'),
  ('concept', 'pack-the-middle', 'cb_press_gap_m', 2, 'm',
   'G4.97: the 9 presses a driving centre-back this far off him, on the line to his nearest central man (the cover shadow).')
) AS v(owner, code, param, value, unit, note)
WHERE NOT EXISTS (SELECT 1 FROM game_model_params g WHERE g.owner = v.owner AND g.code = v.code AND g.param = v.param);

COMMIT;
