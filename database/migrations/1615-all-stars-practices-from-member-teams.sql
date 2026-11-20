-- 1615 (2026-11-20) — 🌟 All-Stars games show each kid's practice attendance
-- from his own team.
--
-- Owner: "the kids all star games need to work like others. i need to
-- remind them. it shold look like men. it can even show attendance even
-- though it doesn't have criteria. same with women" → "all youth should
-- show practice attendance right for games?"
--
-- The U8 / U10 / U12 All-Stars teams hold no practices — the kids practise
-- with their age teams — so the game card's mini calendar (the practice
-- window, StarterCriteria::statsSql) found nothing.  A team flagged
-- practices_from_member_teams gives each player his OWN teams' window.

BEGIN;

ALTER TABLE teams
  ADD COLUMN IF NOT EXISTS practices_from_member_teams boolean NOT NULL DEFAULT false;
COMMENT ON COLUMN teams.practices_from_member_teams IS
  'mig 1615: this team holds no practices of its own (All-Stars) — a game''s practice window per player = his other teams'' practices.';

UPDATE teams SET practices_from_member_teams = true WHERE name ~* '^U\d+ All-Stars$';

COMMIT;
