-- 1529 (2026-11-19) — Jamie Arevalo (22193, paid women's coach — invoices
-- the club) onto the 🎓 onboarding path, paid track (owner 11/19 "add jamie
-- to paid").  No steps ticked: she starts at 0 of 8.
INSERT INTO person_onboarding (person_id, track)
SELECT 22193, 'paid' WHERE EXISTS (SELECT 1 FROM persons WHERE id = 22193)
ON CONFLICT (person_id) DO UPDATE SET track = 'paid';
