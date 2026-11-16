-- 1416 (2026-11-16): the winter youth "teams" are practice groups — which
-- group a kid is in decides which practices he sees (owner: "this is
-- really practice grouping" + "really there is not limit on those 'Teams'
-- just the travel ones … that will be obvious from official roster").
--   max_roster NULL  → no "3/12 · 9 left" cap line on their columns.
--   league_roster false → off the Roster pill (no league list to show) and
--   no "✓ 0 on roster · 5v5 · -5 subs" tally; they live on the Team pill.
--   Fall U8/U10/U12 (912/913/914) keep both — real league lists and caps.
--   Plus the copy for the column fold (owner: "would prefer if active is
--   at top and the other stuff is expandable but rolled up by default").

BEGIN;

UPDATE teams SET max_roster = NULL, league_roster = false
 WHERE id IN (940, 941, 942, 945, 946, 947, 949, 952, 953, 954, 955, 956);

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Roster sheet', 'Team boards: the rolled-up section under each column''s main list ({n} players)',
       'roster_sheet', 'board_more_fold', NULL, '▸ More · {n}', 1048, true, true, false
 WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = 'roster_sheet' AND tier = 'board_more_fold');

COMMIT;
