-- James 11/20: "move asif naviz to liga 1 ... i mean team not official roster"
-- Asif Nifaz (person 22796, b. 2010-11-04) joins the Liga 1 TEAM (120) as a
-- plain team row (on_roster stays false = not on the league list). He keeps
-- his U16 (956) row too: two team_persons rows = on both.
INSERT INTO team_persons (team_id, person_id)
SELECT 120, 22796
WHERE NOT EXISTS (SELECT 1 FROM team_persons
                  WHERE team_id = 120 AND person_id = 22796 AND removed_at IS NULL);
