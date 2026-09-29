-- 496 (2026-09-29) — mock lineups for everyone on the roster.  Owner, minutes
-- after mig 495: "actually just allow any player to make a mock lineup lol
-- on their game center page for any game they are eligible for by being on
-- roster."  So the grant table goes: draft access = a team_persons row on
-- one of the game's teams (or coach / club admin).  Drafts themselves stay
-- as mig 495 built them.
DROP TABLE IF EXISTS lineup_drafters;
CREATE OR REPLACE FUNCTION pg_temp.ld(p_tier text, p_label text, p_body text, p_sort int)
RETURNS void LANGUAGE sql AS $$
  INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
  SELECT 'Game Center', p_label, 'lineup_drafts', p_tier, NULL, p_body, p_sort, true, true
   WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = 'lineup_drafts' AND tier = p_tier);
$$;
SELECT pg_temp.ld('pill_my_draft', 'Lineup drafts — my draft pill', 'My draft', 13);
UPDATE message_templates SET body = 'Your mock lineup. Only you can change it; everyone on the roster can see it.' WHERE kind = 'lineup_drafts' AND tier = 'draft_hint';
UPDATE message_templates SET body = 'The official lineup — what the coaches set. Anyone on the roster can keep a mock lineup of their own next to it.' WHERE kind = 'lineup_drafts' AND tier = 'official_hint';
