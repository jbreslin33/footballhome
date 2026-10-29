-- 859 (2026-10-29) — #apsl-pyramid: every view full screen, all writing in
-- collapsible HUDs.
--
-- Owner 2026-10-29: "all screens should be full screen with all writing etc
-- in a hud … the huds should be collapsable."  The page fills the window;
-- the main HUD (title, totals, view + conference pills, ⟳, ⛶ full screen)
-- and each view's panels (legend, presentation toolbar, map key, conference
-- stats) collapse to their title with ▾ / ▸, remembered.
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'APSL pyramid', l, 'apsl_pyramid', t, NULL, b, o, true, true, false
  FROM (VALUES
    ('hud_legend', 'APSL pyramid — HUD title: legend',           'Legend', 180),
    ('hud_map',    'APSL pyramid — HUD title: map key',          'Map key', 181),
    ('hud_stats',  'APSL pyramid — HUD title: conference stats', 'Conference', 182)
  ) AS v(t, l, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'apsl_pyramid' AND m.tier = v.t);
-- Gone with the page header / the presentation's own full-screen button.
DELETE FROM message_templates WHERE kind = 'apsl_pyramid' AND tier IN ('subtitle', 'present_full');
