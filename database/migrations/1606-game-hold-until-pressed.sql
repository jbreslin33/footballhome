-- G5.190 (game/DESIGN.md §8.296): a free man in his own end keeps the ball until someone closes him. His time on the
-- ball was drawn at the receipt (StatsBomb receipt-to-pass curves) and he passed on that clock, pressed or not: our
-- own-third foot releases came with nobody within 6 m 56% of the time (StatsBomb 360: 29%), passes a minute in play
-- 9.6 (DFL 8.23), spells 13.5 (12.15), passes 559 a team-match (434). Real releases there come when a man arrives —
-- DFL has no second presser on a deep back line (2nd-nearest defender median 15.1 m), so it is the holder, not the press.
--   free_hold_m 6 — past his drawn hold, a pass waits while no opponent is within 6 m (own half, up to 3 s more;
--                   free_hold_own_m 52.5 / free_hold_max_s 3 are the code defaults)
-- 4 m tried: passes 7.85 a minute (8.23), carries 53 (34.6). Rows, not code defaults: goldens unchanged.
INSERT INTO game_model_params (owner, code, param, value, unit, note) VALUES
 ('physics', 'tempo', 'free_hold_m', 6, 'm', 'G5.190 §8.296: past his drawn hold, a free man in his own half keeps it until an opponent is within this (0 = off)')
ON CONFLICT (owner, code, param) DO UPDATE SET value = EXCLUDED.value, unit = EXCLUDED.unit, note = EXCLUDED.note;
