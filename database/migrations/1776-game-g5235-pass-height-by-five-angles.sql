-- G5.235 (game/DESIGN.md §8.341): a pass's chance of going high is read by five angle bands off straight at their
-- goal (0-30 / 30-45 / 45-60 / 60-120 / 120+ deg), not G5.75's three cones (within 60 deg / lateral / back).
-- StatsBomb PL 15/16 (benchmarks_statsbomb_highpass.py --angle): from midfield a 20-30 m pass goes high 34% within
-- 30 deg, 22% at 30-45, 10% at 45-60, 4% at 60-120; the 60 deg cone gave all of the first three 25%. The table is the
-- code's default (physics.pass.high5_<origin>_<angle>_<band> rows override a cell); this row turns it on.
-- Seeds 1000-4000 x 8: the midfield's square high ball 17.2 tried / 8.5 lost -> 16.0 / 8.2 (9.5 / 3.0); forward high
-- 30 m+ unchanged; card 9/12/12 -> 11/9/13 (inside run noise).
INSERT INTO game_model_params (owner, code, param, value, unit, note) VALUES
 ('physics', 'pass', 'high5_on', 1, 'switch', 'G5.235 §8.341: the high share of a pass by five angle bands off straight at their goal (0 = G5.75''s three cones)')
ON CONFLICT (owner, code, param) DO UPDATE SET value = EXCLUDED.value, unit = EXCLUDED.unit, note = EXCLUDED.note;
