-- 1577 (2026-11-19) — 🔎 #apsl Forecast: focus any team in the pyramid, no
-- home side in the words.
--
-- Owner 2026-11-19: "what about team focus. non lh focus." — a search box
-- lists every APSL team and every feeder team; picking one opens its
-- conference (an APSL side: its own page; a feeder side: its row marked in
-- the feeder tables).  The page opens on the first conference, not ours.
BEGIN;
UPDATE message_templates SET body = ' Its winner plays the conference''s group-playoff winner for the last spot ({pct} to come up).'
 WHERE kind = 'apsl_pyramid' AND tier = 'fc_ol_rules_meet';
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'APSL pyramid', l, 'apsl_pyramid', t, NULL, b, o, true, true, true
  FROM (VALUES
    ('fc_focus',        'Forecast — focus search placeholder',            '🔎 Focus any team — APSL or feeder', 427),
    ('fc_focus_feeder', 'Forecast — focused feeder team line ({team} {feeder})', '🔎 {team} — {feeder}: see the feeders below', 428)
  ) AS v(t, l, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'apsl_pyramid' AND m.tier = v.t);
COMMIT;
