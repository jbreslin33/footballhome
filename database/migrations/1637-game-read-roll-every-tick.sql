-- G5.203 (game/DESIGN.md §8.309): the race read steps a rolling ball every tick, as the World does. Reads::race looked
-- at a rolling ball every 3rd tick — at 12-20 m/s a 1.2-2 m stride, while World captures every tick: a man 0.3-0.6 m
-- off the line (inside his reaction only his 0.6 m body reaches) fell between two looks. On our own-third ground
-- passes lost to a man the read had "never reaching", clean (no deflection on the way) and inside 1.5 s: 25 → 12
-- (4 seeds x 8 matches).
--   roll_stride 1 — every tick (no row = 3)
INSERT INTO game_model_params (owner, code, param, value, unit, note) VALUES
 ('physics', 'receive', 'roll_stride', 1, 'ticks', 'G5.203 §8.309: Reads::race checks a rolling ball every this many ticks (no row = 3; World captures every tick)')
ON CONFLICT (owner, code, param) DO UPDATE SET value = EXCLUDED.value, unit = EXCLUDED.unit, note = EXCLUDED.note;
