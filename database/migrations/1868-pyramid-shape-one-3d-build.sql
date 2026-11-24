-- 1868 (2026-11-24) — 🗻 Spin the pyramid: one 3D build left.  Owner, of the seven tried that day:
-- "last one is winnner as far as resourcess it runs fine and doesn't sllow iin browser and slow
-- sysetem" · "drop the other versions and commit".  The kept build (the solid with standings and
-- arrows) is now just the 3D pyramid; the dropped builds' words go, and the hint only they used.
UPDATE message_templates SET body = '🗻 3D pyramid', label = 'Spin view: the 3D pyramid'
 WHERE kind = 'apsl_pyramid' AND tier = 'shape_style_standings';
DELETE FROM message_templates
 WHERE kind = 'apsl_pyramid'
   AND tier IN ('shape_style_step', 'shape_style_slope', 'shape_style_raised', 'shape_style_settle',
                'shape_style_solid', 'shape_style_teams', 'shape_hint');
