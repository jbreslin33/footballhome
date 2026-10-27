-- 755 (2026-10-27) — game: Lighthouse's shape on the Ukies' restart
-- (game/DESIGN.md §8.70, G4.72).
--
-- James 10/27: "lh 2 & 3 still too close to 7 & 11 on restart. lh 9
-- positioning makes no sense. he should be in middle of their 6 and 8 and
-- able to cover shadow them. like in a box between ukies 4,5,6,8. lh 7 and
-- 11 should be book ends to lh 8,10"
--
-- pack-the-middle (165) now places all three: the 9 in the middle of their
-- two centre-backs and two deepest central midfielders; the wingers level
-- with our 8 / 10 on their side, bookend_gap_m wider; on their restart the
-- full-backs fb_off_m goal-side and fb_inside_m inside their winger.

INSERT INTO game_model_params (owner, code, param, value, unit, note)
SELECT v.* FROM (VALUES
 ('concept', 'pack-the-middle', 'right_back_number', 2::numeric, '#', 'The full-back who stands off their winger on their restart.'),
 ('concept', 'pack-the-middle', 'left_back_number', 3, '#', 'The other full-back.'),
 ('concept', 'pack-the-middle', 'bookend_gap_m', 6, 'm', 'Each winger stands level with our 8 or 10 on his side, this much wider: a line of four.'),
 ('concept', 'pack-the-middle', 'fb_off_m', 10, 'm', 'On their restart the full-back stands this far goal-side of their winger.'),
 ('concept', 'pack-the-middle', 'fb_inside_m', 5, 'm', 'And this far inside him, toward the middle.')
) AS v(owner, code, param, value, unit, note)
WHERE NOT EXISTS (SELECT 1 FROM game_model_params g WHERE g.owner = v.owner AND g.code = v.code AND g.param = v.param);

UPDATE game_model_params
   SET note = 'Retired as the 9''s spot by G4.72 (he stands in the box between their centre-backs and deepest midfielders); used only when that box can''t be read.'
 WHERE owner = 'concept' AND code = 'pack-the-middle' AND param = 'nine_screen_gap_m';
