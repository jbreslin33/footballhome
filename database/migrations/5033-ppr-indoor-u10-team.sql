-- 5033 (2027 Indoor entry, 2026-11-27): PPR Indoor 2027 gets a U10 team set up like the U12.
-- Owner: "i need a u10 ppr entry same as u12 to email".
-- U10 Travel Winter (team 965). Coach Luke Breslin (3463) and assistant Anthony Acevedo (22397),
-- both coaches of 965. Same home court and court times as the U12, returning, max 12.
-- Its own team form and roster items. The club form and check now cover 2 teams.
BEGIN;
INSERT INTO league_entry_teams (entry_id, team_id, age_group, gender, team_name, is_returning,
                                coach_person_id, assistant_person_id, home_court, court_availability,
                                prev_age_group, max_roster, sort_order)
SELECT u12.entry_id, t.id, 'U10', u12.gender, 'Lighthouse Boys Club U10', u12.is_returning,
       u12.coach_person_id, u12.assistant_person_id, u12.home_court, u12.court_availability,
       'U10', u12.max_roster, u12.sort_order + 1
  FROM league_entry_teams u12
  JOIN league_entries e ON e.id = u12.entry_id AND e.season_label = '2027 Indoor'
  JOIN teams t ON t.name = 'U10 Travel Winter' AND t.is_active
 WHERE u12.age_group = 'U12'
   AND NOT EXISTS (SELECT 1 FROM league_entry_teams x WHERE x.entry_id = u12.entry_id AND x.age_group = 'U10');

INSERT INTO league_entry_items (entry_id, entry_team_id, kind, label, how, template_file_id, sort_order)
SELECT i.entry_id, u10.id, i.kind, replace(i.label, 'U12', 'U10'), i.how, i.template_file_id, i.sort_order + 2
  FROM league_entry_items i
  JOIN league_entry_teams u12 ON u12.id = i.entry_team_id AND u12.age_group = 'U12'
  JOIN league_entry_teams u10 ON u10.entry_id = u12.entry_id AND u10.age_group = 'U10'
 WHERE NOT EXISTS (SELECT 1 FROM league_entry_items x WHERE x.entry_team_id = u10.id);
-- keep the check last
UPDATE league_entry_items i SET sort_order = 10
  FROM league_entries e WHERE e.id = i.entry_id AND e.season_label = '2027 Indoor' AND i.kind = 'payment';

INSERT INTO schema_migrations (filename) VALUES ('5033-ppr-indoor-u10-team.sql') ON CONFLICT DO NOTHING;
COMMIT;
