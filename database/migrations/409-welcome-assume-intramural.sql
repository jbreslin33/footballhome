-- 409 — Welcome assumes the intramural team for a new youth player.
--
-- Owner 2026-09-23: "if a new player is not on a team assume intramural
-- and send them that schedule. because i will be adding them shortly
-- after."
--
-- WelcomeMessage now picks the club's intramural team for the child's
-- age band when the child is on no live team (the `guess` CTE), and the
-- welcome carries that team's coming events and usual week.  This block
-- sits above them and says which team was assumed; {team} is its name.
-- Adults never match (the guess needs a youth birth date and a
-- boys/girls intramural side), so they keep welcome_no_team.
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order)
SELECT 'System', 'Welcome block — assumed intramural team (parent)', 'welcome_assumed_team', 'parent', NULL,
       E'{child} isn''t on a team in the app just yet — I''ll add {child} shortly, and {child} will be placed on a travel or intramural team when appropriate. New players start with {team}, so here''s that schedule for now.',
       35
 WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = 'welcome_assumed_team' AND tier = 'parent');
