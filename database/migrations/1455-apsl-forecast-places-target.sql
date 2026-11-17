-- 1455 (2026-11-17) — 📈 #apsl Forecast: points each place finishes on, a
-- ⭐ target per team, and a re-read after every match day.
--
-- Owner 2026-11-17: "what is probable point total of 6th place in div b" →
-- "give me % spread" → "put that on site too" + "so that it constantly
-- updates on load as seasons progress" + (6th = safe) "that is our north
-- star".  Under each table: per place its likely points, the 80% range and
-- the spread (tap for every total and the chance of that many or more).  On
-- a team: ⭐ the last safe place's usual points and what it asks of the
-- games left.  A forecast load re-reads the league feed when a listed game
-- has finished since the last read (PyramidSync::refreshIfGameDue) — no
-- table change.  Words only.
BEGIN;
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'APSL pyramid', l, 'apsl_pyramid', t, NULL, b, o, true, true, true
  FROM (VALUES
    ('fc_places',        'Forecast — heading: points each place finishes on ({from} {to})', '⛳ Points each place finishes on — tap the bars for the full spread', 374),
    ('fc_places_likely', 'Forecast — places column: likely points (median)',                'Likely pts', 375),
    ('fc_places_range',  'Forecast — places column: 80% range',                             '80% range', 376),
    ('fc_places_spread', 'Forecast — places column: spread',                                'Spread', 377),
    ('fc_target',        'Forecast — ⭐ target ({place} {pts} {lo} {hi} {need} {left} {wins})', 'Target: finish {place} — it usually takes {pts} pts ({lo}–{hi}). Need {need} more from {left} games ≈ {wins} wins.', 378),
    ('fc_target_done',   'Forecast — ⭐ target already reached ({place} {pts})',             'Target: finish {place} — usually {pts} pts, already there.', 379),
    ('fc_target_out',    'Forecast — ⭐ target out of reach',                                '(more than the games left can give)', 380)
  ) AS v(t, l, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'apsl_pyramid' AND m.tier = v.t);
COMMIT;
