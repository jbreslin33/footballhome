-- 2401 #teams 🎂 Age group sort pill: youngest first (tap again → oldest
-- first), on every view including the Team pill's short list. Owner 11/27
-- "all for sort by age group". Wording only here.
BEGIN;
INSERT INTO message_templates (category, label, kind, tier, body, sort_order, client_side, is_public)
SELECT 'Roster sheet', 'Team boards sort pill — age group (youngest first)', 'roster_sheet', 'board_sort_age',
       '🎂 Age group', 1049, true, false
 WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = 'roster_sheet' AND tier = 'board_sort_age');
INSERT INTO schema_migrations (filename) VALUES ('2401-teams-sort-by-age-group.sql') ON CONFLICT DO NOTHING;
COMMIT;
