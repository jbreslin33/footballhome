-- 1893 (2026-11-25) — 🗻 3D pyramid: the controls are a rail on the right — one button per league
-- (MLS, USL, APSL, NPSL, UPSL, LfC), and under the picked one its levels (APSL 4 5 6 7 8 9).
-- A press snaps the pyramid round to that league / level; a drag still spins it for the fun of
-- it, but there is no other side-to-side moving.  Everything that stood across the top (calendar
-- pills, show switches, 3D / 2D, the hint) is gone.
--
-- Owner: "we need on right not bottom. the controls. get all the controls should be names of
-- leagus to go to their pyramdid. Mls, usl, apsl, npsl, upsl, league for clubs(lfc). the pyrmaid
-- has no need to go side to side so movmennt should be restricted to up and down … for apsl its
-- 4,5,6,7,8,9. we can keep the mouse rotatons for coolmess factor but as soon as you hit a button
-- for league or leavel it snaps there … also get rid of everyting at top".
--
-- Levels are now numbered by DIVISION (Division I = 1 … the APSL and the other national leagues
-- = 4, each row of their feeders 5, 6 …), not by row from the top; the cups carry no number.
-- Button names by pyramid_side (pro_leagues / pyramid_competitions); shape_side_order is the
-- order down the rail.
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT m.category, v.label, 'apsl_pyramid', v.tier, NULL, v.body, m.sort_order + v.n, true, true, true
  FROM message_templates m
  JOIN (VALUES
    (1, '3D rail: button for side 0 (the APSL)', 'shape_side_0', 'APSL'),
    (2, '3D rail: button for side 1 (MLS column)', 'shape_side_1', 'MLS'),
    (3, '3D rail: button for side 2 (UPSL)', 'shape_side_2', 'UPSL'),
    (4, '3D rail: button for side 3 (USL column)', 'shape_side_3', 'USL'),
    (5, '3D rail: button for side 4 (NPSL)', 'shape_side_4', 'NPSL'),
    (6, '3D rail: button for side 5 (League for Clubs)', 'shape_side_5', 'LfC'),
    (7, '3D rail: sides top to bottom (pyramid_side numbers)', 'shape_side_order', '1 3 0 4 2 5'),
    (8, '3D rail: headline of a cup level (no division number)', 'shape_level_cup', 'Cup'),
    (9, '3D rail: heading over the picked league''s levels', 'shape_rail_levels', 'Levels'),
    (10, '3D rail: whole pyramid button', 'shape_rail_all', 'Whole pyramid')
  ) AS v(n, label, tier, body) ON true
 WHERE m.kind = 'apsl_pyramid' AND m.tier = 'shape_close'
   AND NOT EXISTS (SELECT 1 FROM message_templates x WHERE x.kind = 'apsl_pyramid' AND x.tier = v.tier);

UPDATE message_templates
   SET body = 'Pick a league on the right, then a level · drag up or down to move · scroll or pinch to zoom · tap a level for its tables'
 WHERE kind = 'apsl_pyramid' AND tier = 'shape_hint_solid';
