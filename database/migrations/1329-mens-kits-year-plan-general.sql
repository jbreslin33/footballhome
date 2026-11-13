-- 1329 (2026-11-13): Men's kits $35 each; section-wide costs on the Year plan.
-- Owner: "so kits $35 each" — Kits — Mens = $35 × every men's member (the
-- active LeagueApps count), no longer assumed.  The Year plan gets a
-- "general" group per section from its own budget_lines (amount × members,
-- or × the weeks in the period, or fixed).
BEGIN;
UPDATE budget_lines SET is_assumed = false, note = '$35 per member (owner 2026-11-13)' WHERE id = 13;
INSERT INTO message_templates (category, label, kind, tier, body, is_active, sort_order, client_side, is_public) VALUES
  ('Finances', 'Finances — Year plan section-wide group', 'finances', 'plan_general',     '{section} — general', true, 77, true, false),
  ('Finances', 'Finances — Year plan per member unit',    'finances', 'plan_unit_member', 'per member today',    true, 78, true, false),
  ('Finances', 'Finances — Year plan per week unit',      'finances', 'plan_unit_week',   'per week',            true, 79, true, false);
INSERT INTO schema_migrations (filename) VALUES ('1329-mens-kits-year-plan-general.sql') ON CONFLICT DO NOTHING;
COMMIT;
