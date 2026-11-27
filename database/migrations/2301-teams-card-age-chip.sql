-- 2301 #teams Graphic team cards: age-group chip (U21, U28 …) on every player
-- box, bottom-right — the same FH age (season chart) the List cards already
-- show. Owner 11/27 "put their age label on all players on team screeen" ·
-- "so u21 u28 etc". Wording only here; the chip reads player.ageGroup.
BEGIN;
INSERT INTO message_templates (category, label, kind, tier, body, sort_order, client_side, is_public)
SELECT 'Roster sheet', '#teams team card: age-group chip hover', 'roster_sheet', 'tc_age_tip',
       'Age group this season', 909, true, false
 WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = 'roster_sheet' AND tier = 'tc_age_tip');
INSERT INTO schema_migrations (filename) VALUES ('2301-teams-card-age-chip.sql') ON CONFLICT DO NOTHING;
COMMIT;
