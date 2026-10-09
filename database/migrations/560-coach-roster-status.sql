-- 560 (2026-10-09) — coaches on a team carry a roster status and a role.
-- Owner: "we should also add coaches to the teams on fh. that are 'on
-- roster' 'not on roster' etc" — the league's roster sheet (GotSport /
-- EPYSA) lists three coaches for a youth team while nine people coach on
-- Football Home; which three is a roster question, the same one the
-- players answer with roster_statuses.  team_coaches.roster_status_id is
-- that answer (NULL = not on roster); coach_roles (head / assistant) says
-- how the sheet labels them.  The youth sheet today: Luke head, James and
-- Anthony assistants, on roster for U8, U10 and U12 (the U10 sheet on
-- file 2026-10-09).
ALTER TABLE team_coaches ADD COLUMN IF NOT EXISTS roster_status_id INTEGER REFERENCES roster_statuses(id);
COMMENT ON COLUMN team_coaches.roster_status_id IS 'mig 560: the coach''s standing on the league roster for this team (roster_statuses); NULL = not on roster.';
WITH who AS (
  SELECT p.id AS person_id, v.role, v.o
    FROM (VALUES ('Luke', 'Breslin', 'head', 1), ('James', 'Breslin', 'assistant', 2), ('Anthony', 'Acevedo', 'assistant', 3)) AS v(fn, ln, role, o)
    JOIN persons p ON p.first_name = v.fn AND p.last_name = v.ln
   WHERE EXISTS (SELECT 1 FROM coaches c WHERE c.person_id = p.id))
UPDATE team_coaches tc
   SET coach_role_id = (SELECT id FROM coach_roles WHERE name = who.role),
       roster_status_id = (SELECT id FROM roster_statuses WHERE code = 'on_roster')
  FROM coaches c, who, teams t
 WHERE c.id = tc.coach_id AND c.person_id = who.person_id AND t.id = tc.team_id
   AND tc.ended_at IS NULL AND t.is_travel AND t.gender_category = 'boys' AND t.is_active AND t.board_sort_order IS NOT NULL;
