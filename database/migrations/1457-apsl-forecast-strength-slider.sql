-- 1457 (2026-11-17) — 📈 #apsl Forecast: 🎚 strength slider on a team's page
-- (owner "add a slider to set our strength on the page", after "we are
-- getting stronger"). Drag a team's strength (attack ÷ defence, 1.00 =
-- average; the other sides marked); letting go replays the season with it
-- (GET /api/pyramid/forecast?conference=&team=&rating=). Words only.
BEGIN;
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'APSL pyramid', l, 'apsl_pyramid', t, NULL, b, o, true, true, true
  FROM (VALUES
    ('fc_slider',        'Forecast — 🎚 slider title',                                     'What if they play stronger? Drag their strength', 381),
    ('fc_slider_value',  'Forecast — slider value ({rating} {team} {team_rating})',       'Strength {rating} — closest: {team} ({team_rating})', 382),
    ('fc_slider_busy',   'Forecast — slider: replaying',                                  'Replaying the season…', 383),
    ('fc_slider_on',     'Forecast — slider: what-if shown ({base})',                     'Showing the what-if — every number on this page uses the strength above (their results say {base}).', 384),
    ('fc_slider_off',    'Forecast — slider: from results',                               'From their results so far — drag and let go to replay the season at another strength.', 385),
    ('fc_slider_reset',  'Forecast — slider: reset',                                      '↺ Their real strength', 386)
  ) AS v(t, l, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'apsl_pyramid' AND m.tier = v.t);
COMMIT;
