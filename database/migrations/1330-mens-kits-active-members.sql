-- 1330 (2026-11-13): Men's kits count active members.
-- Owner: "use active members" — $35 × men on an active LeagueApps league
-- program (not pickup-only payers); the count follows registrations.
UPDATE budget_lines SET note = '$35 per active member — men on an active league program, not pickup-only (owner 2026-11-13)' WHERE id = 13;
INSERT INTO schema_migrations (filename) VALUES ('1330-mens-kits-active-members.sql') ON CONFLICT DO NOTHING;
