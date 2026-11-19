-- 1561 (2026-11-19) — 🧪 onboarding TEST MODE ON (owner 11/19 "yes test it
-- fully all the steps for all onboard"): every onboarding email goes to the
-- owner only — both email stages and the NSOR "send to the state" — and the
-- owner (person 1) is on the path, paid track (all 8 steps), to walk it on
-- his phone.  Undone by the matching TEST MODE OFF migration.
UPDATE onboarding_stages SET email_to = 'jbreslin@footballhome.org' WHERE stage IN ('volunteer', 'paid');
UPDATE message_templates SET body = 'jbreslin@footballhome.org', updated_at = now() WHERE kind = 'onboarding' AND tier = 'nsor_to';
INSERT INTO person_onboarding (person_id, track, note) VALUES (1, 'paid', '🧪 test')
ON CONFLICT (person_id) DO UPDATE SET track = 'paid', note = '🧪 test';
