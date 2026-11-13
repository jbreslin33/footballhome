-- 1331 (2026-11-13): Year plan "shared by" — full house, active, current.
-- Owner: "dont ever use pickup etc. use 70 as the maxed out perfect scenario
-- then use active but also a cat for current dues payers."
--   Full house  roster spots of the section's dues-carrying teams (max_roster,
--               dues_rank set: APSL 35 + Liga 1 35 = 70)
--   Active      members on an active LeagueApps league program — never pickup
--   Current     active, not free, owing nothing
BEGIN;
UPDATE message_templates SET is_active = false WHERE kind = 'finances' AND tier = 'plan_per_player';
INSERT INTO message_templates (category, label, kind, tier, body, is_active, sort_order, client_side, is_public) VALUES
  ('Finances', 'Finances — Year plan split columns',   'finances', 'plan_split_columns', 'Shared by|Players|Each|Of a year of dues', true, 80, true, false),
  ('Finances', 'Finances — Year plan split full house', 'finances', 'plan_split_full',    'Full house (every roster spot filled)', true, 81, true, false),
  ('Finances', 'Finances — Year plan split active',     'finances', 'plan_split_active',  'Active members', true, 82, true, false),
  ('Finances', 'Finances — Year plan split current',    'finances', 'plan_split_current', 'Current in dues', true, 83, true, false);
INSERT INTO schema_migrations (filename) VALUES ('1331-plan-split-full-active-current.sql') ON CONFLICT DO NOTHING;
COMMIT;
