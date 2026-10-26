-- 706 (2026-10-26) — game: the Ukies building from the keeper, James's
-- second pass (game/DESIGN.md §8.58).
--
-- James 10/26: "cdms should be above penalty box by 10 yards. then 7,11
-- should be pinned to sideline high up. near center line. 10 should be
-- above the 6,8(cdms) 9 should be inside half circle".
--
-- Box 16.5 m + 10 yd (9.1 m) = 25.6 m for the CDMs. The 7 and 11 on the
-- touchlines (±33.5 of 34) at 49 m, near halfway. The 10 above the CDMs
-- (~8 yd: 33 m, centre — James gave no gap). The 9 in his own half of the
-- centre circle (radius 9.15 m: 43.4-52.5 m) at 48 m. Depth from the
-- team's own goal line, width + = left (7 = left winger, 11 = right).

INSERT INTO game_phase_positions (phase_code, formation_code, side, number, depth_m, width_m, note) VALUES
 ('keeper', '4-2-3-1', 'in', 6, 25.6, -8, 'CDMs 10 yd above the box (James 10/26)'),
 ('keeper', '4-2-3-1', 'in', 8, 25.6, 8, 'CDMs 10 yd above the box (James 10/26)'),
 ('keeper', '4-2-3-1', 'in', 7, 49, 33.5, 'pinned to the touchline, high, near halfway (James 10/26)'),
 ('keeper', '4-2-3-1', 'in', 11, 49, -33.5, 'pinned to the touchline, high, near halfway (James 10/26)'),
 ('keeper', '4-2-3-1', 'in', 10, 33, 0, 'above the CDMs (James 10/26; ~8 yd, gap not given)'),
 ('keeper', '4-2-3-1', 'in', 9, 48, 0, 'inside his half of the centre circle (James 10/26)')
ON CONFLICT (phase_code, formation_code, side, number) DO UPDATE
  SET depth_m = EXCLUDED.depth_m, width_m = EXCLUDED.width_m, note = EXCLUDED.note;
