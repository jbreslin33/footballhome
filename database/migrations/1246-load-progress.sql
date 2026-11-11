-- 1246: one "still loading" line on every screen that fills in parts
-- (owner 2026-11-11: "#payments total looks low on load and goes up" →
-- "this should be a universal rule on all loading pages for all things").
-- LoadProgress (frontend/js/components/load-progress.js) draws a bar,
-- the percent and "N of M <parts> in", and screens dim their numbers
-- until the last part lands.  First user: #payments stats box.
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT v.c, v.l, v.k, v.t, NULL, v.b, v.o, true, true, false
  FROM (VALUES
    ('Loading', 'Progress line while a screen fills in parts ({pct} {done} {total} {what})', 'load_progress', 'line',
     '⏳ Loading {pct}% — {done} of {total} {what} in · totals still adding up', 1246),
    ('Payments', 'What the stats box loads in parts (LoadProgress noun)', 'payments_overview', 'load_parts', 'programs', 1247)
  ) AS v(c, l, k, t, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = v.k AND m.tier = v.t);
