-- 1818 (2026-11-24) — PPR Indoor 2027: the U12 team's name on the forms.
-- Owner: "Team name for u12: Lighthouse Boys Club u12".
UPDATE league_entry_teams et SET team_name = 'Lighthouse Boys Club U12'
  FROM league_entries e
 WHERE e.id = et.entry_id AND e.season_label = '2027 Indoor' AND et.age_group = 'U12';
