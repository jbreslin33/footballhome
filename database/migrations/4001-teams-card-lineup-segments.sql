-- 4001 #teams Graphic team cards split by lineup role: ⭐ Starters / 🪑 Bench /
-- 🔄 Reserve (then "No role yet"), the lit sort pill ordering each segment.
-- Owner 11/27 "segment them as the first sort. then within that sort by
-- age". Wording only here. (Numbered in a gap below the max on purpose —
-- parallel sessions take max+1.)
BEGIN;
INSERT INTO message_templates (category, label, kind, tier, body, sort_order, client_side, is_public)
SELECT 'Roster sheet', v.label, 'roster_sheet', v.tier, v.body, v.so, true, false
FROM (VALUES
  ('#teams team card: segment header — starters', 'tc_seg_starter', '⭐ Starters', 910),
  ('#teams team card: segment header — bench',    'tc_seg_bench',   '🪑 Bench', 911),
  ('#teams team card: segment header — reserve (on roster, may not always get in)', 'tc_seg_reserve', '🔄 Reserve', 912),
  ('#teams team card: segment header — no lineup role set', 'tc_seg_none', 'No role yet', 913)
) AS v(label, tier, body, so)
WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'roster_sheet' AND m.tier = v.tier);
INSERT INTO schema_migrations (filename) VALUES ('4001-teams-card-lineup-segments.sql') ON CONFLICT DO NOTHING;
COMMIT;
