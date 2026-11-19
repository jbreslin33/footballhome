-- 1544 (2026-11-19) — the blank W-9 (#files 56) and Paychex direct deposit (57)
-- shared with Members so volunteers can download them from their onboarding
-- steps (owner 11/19 "i need the guys to be able to download them right?").
UPDATE club_files SET visibility = 'members', updated_at = now() WHERE id IN (56, 57);
