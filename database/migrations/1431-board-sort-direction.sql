-- #teams sort direction pills (James 11/17 "it needs to sort asc or desc" +
-- "still not seeing asc/desc toggle"): ↑ Asc / ↓ Desc beside the sort pills.
BEGIN;
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Roster sheet', l, 'roster_sheet', t, NULL, b, o, true, true, false
  FROM (VALUES
    ('board_sort_asc',  'Team boards sort direction pill — smallest first (A→Z, #1, lowest)', '↑ Asc',  1047),
    ('board_sort_desc', 'Team boards sort direction pill — biggest first (Z→A, best first)',  '↓ Desc', 1048)
  ) AS v(t, l, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'roster_sheet' AND m.tier = v.t);
COMMIT;
