-- 1234 (2026-11-11) — #apsl-pyramid: one ☰ button, everything else in it.
--
-- Owner 2026-11-11: "for apsl-pyramid we need to do like game and have one
-- 'button' to open interface so screen on load is not cluttered … make
-- organized sections in the interface."  The page opens on the chart / map
-- alone plus ☰.  ☰ opens one panel in sections: View (view pills),
-- Conferences (conference pills), Show on screen (which of the view's
-- floating panels — legend, map key, conference stats, presentation
-- controls — sit over the chart; all off by default, remembered on this
-- device), Actions (full screen, ⟳ refresh for admins, back).  The old top
-- HUD is gone.  is_public: the page is public (mig 870).
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'APSL pyramid', l, 'apsl_pyramid', t, NULL, b, o, true, true, true
  FROM (VALUES
    ('menu_button',  'APSL pyramid — ☰ button tooltip',              'Menu (M)', 190),
    ('menu_view',    'APSL pyramid — menu section: views',           'View', 191),
    ('menu_conf',    'APSL pyramid — menu section: conferences',     'Conferences', 192),
    ('menu_show',    'APSL pyramid — menu section: floating panels', 'Show on screen', 193),
    ('menu_show_none','APSL pyramid — menu: view has no panels',     'This view has no extra panels.', 194),
    ('menu_actions', 'APSL pyramid — menu section: actions',         'Actions', 195),
    ('menu_refresh', 'APSL pyramid — menu: refresh from APSL',       '⟳ Refresh from APSL', 196),
    ('menu_back',    'APSL pyramid — menu: back',                    '← Back', 197)
  ) AS v(t, l, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'apsl_pyramid' AND m.tier = v.t);
