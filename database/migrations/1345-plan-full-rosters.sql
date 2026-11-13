-- 1345 (2026-11-13): type full rosters on the Year plan.
-- Owner: "allow for on budget page to put in full rosters." — one box per
-- dues-carrying team (POST /api/finances/plan-roster): per-player
-- registrations follow, extra players beyond the entry fee's included count
-- follow, kits on the team's own plan follow; a team with no per-player fee
-- (youth) keeps it as teams.max_roster.  Full house + per player recalc.
INSERT INTO message_templates (category, label, kind, tier, body, is_active, sort_order, client_side, is_public) VALUES
  ('Finances', 'Finances — Year plan full rosters heading', 'finances', 'plan_rosters_title', 'Full rosters', true, 99, true, false),
  ('Finances', 'Finances — Year plan full rosters note',    'finances', 'plan_rosters_note',  'Type a team''s full roster — its player fees and full house follow.', true, 100, true, false);
INSERT INTO schema_migrations (filename) VALUES ('1345-plan-full-rosters.sql') ON CONFLICT DO NOTHING;
