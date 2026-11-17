-- 1425 (2026-11-16): 💵 Men's money — kits + LeagueApps fees split half on
-- APSL, half on Liga 1 (owner: "put it all on apsl and liga 1" + "but its only
-- 1x per player"): one kit per man, counted once, never per team. Words only.
BEGIN;
INSERT INTO message_templates (category, label, kind, tier, body, is_active, sort_order, client_side, is_public)
SELECT 'Finances', 'Finances — men''s money: a Men''s club wide line split onto a team ({label})', 'finances', 'pm_half_line', '{label} — half', true, 425, true, false
 WHERE NOT EXISTS (SELECT 1 FROM message_templates t WHERE t.kind = 'finances' AND t.tier = 'pm_half_line');
INSERT INTO schema_migrations (filename) VALUES ('1425-mens-kits-on-apsl-liga1.sql') ON CONFLICT DO NOTHING;
COMMIT;
