-- 1763 (2026-11-23): short league names for the youth competition pills.
--
-- Owner 2026-11-23: "use icon to make youth pills smaller and smaller on
-- total for header. use fall, spring etc icon, use u8 label small. no need to
-- say indoor or outdoor its understood put ppr or icsl."
--
-- #competitions names a youth competition "🍂 U8 PPR": the season icon is the
-- team's own (teams.short_label, "🍂 U8 Travel"), the age its scope, and the
-- league by its short name from this row — "Full name=Short" pairs split by |.
-- A league not listed keeps its full name.

BEGIN;
INSERT INTO message_templates (category, label, kind, tier, body, sort_order, client_side)
SELECT 'Finances', 'Finances — competitions: league short names', 'finances', 'cp_league_short',
       'Philadelphia Parks & Recreation=PPR|Inter-County Soccer League=ICSL', 954, true
 WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = 'finances' AND tier = 'cp_league_short');
INSERT INTO schema_migrations (filename) VALUES ('1763-competition-league-short-names.sql') ON CONFLICT DO NOTHING;
COMMIT;
