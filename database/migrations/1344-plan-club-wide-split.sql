-- 1344 (2026-11-13): club-wide costs + grants split by PAYING members.
-- Owner: "yes go ahead with that split … wait just split by paying members. so
-- women don't bear it right?" — each section pill carries its share of the
-- club-wide lines (and, with the grants switch on, of the grants) by paying
-- members: active league-program members, not free / volunteer / injured,
-- never pickup.  Women's pay no dues, so they carry none.
INSERT INTO message_templates (category, label, kind, tier, body, is_active, sort_order, client_side, is_public) VALUES
  ('Finances', 'Finances — Year plan club-wide share heading', 'finances', 'plan_club_share',         'Share of club-wide — {pct} ({active} of {all} paying members)', true, 95, true, false),
  ('Finances', 'Finances — Year plan club-wide share line',    'finances', 'plan_club_share_line',    'Club-wide costs (balls, field, paint, gas …)', true, 96, true, false),
  ('Finances', 'Finances — Year plan grants share line',       'finances', 'plan_grants_share',       'Share of grants — {pct}', true, 97, true, false),
  ('Finances', 'Finances — Year plan total after grants',      'finances', 'plan_total_after_grants', 'After grants', true, 98, true, false);
INSERT INTO schema_migrations (filename) VALUES ('1344-plan-club-wide-split.sql') ON CONFLICT DO NOTHING;
