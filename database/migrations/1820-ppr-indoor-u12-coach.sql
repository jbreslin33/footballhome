-- 1820 (2026-11-24) — PPR Indoor 2027: the U12 team's coach on the forms.
-- Owner: "coach for u12 is luke breslin" (person 3463, a coach of team 964).
UPDATE league_entry_teams et SET coach_person_id = 3463
  FROM league_entries e
 WHERE e.id = et.entry_id AND e.season_label = '2027 Indoor' AND et.age_group = 'U12'
   AND EXISTS (SELECT 1 FROM team_coaches tc JOIN coaches c ON c.id = tc.coach_id
                WHERE tc.team_id = et.team_id AND tc.ended_at IS NULL AND c.person_id = 3463);
