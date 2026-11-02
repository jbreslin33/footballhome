-- G5.4 (game/DESIGN.md §8.102): with the ball the team's middle follows it more
-- closely. 0.45 left 1.4 mates ahead of the ball 17.5-35 m from their goal and 0.45
-- inside that; StatsBomb 360 freeze frames (Euro 2020, 24 matches, visible men only,
-- so a minimum) show 3.3 and 1.3. 0.9 gave 2.6 and 1.5, and offsides 1.5 a team
-- (pro 2.0). [FH] fit to those, on Frencken et al. 2011 (centroids follow the ball).
UPDATE game_model_params SET value = 0.9,
       note = 'In possession the shape''s middle stands at this × the ball''s x + ours_offset_m. Fit to mates ahead of the ball (§8.102).'
 WHERE owner = 'physics' AND code = 'shape' AND param = 'ours_slope';
