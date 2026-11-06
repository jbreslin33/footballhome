-- Coach schedule (owner 11/6): every youth coach sees every youth practice
-- except Ali, who stays Fridays only.  Joseph Vazquez had no days (call in
-- by invite) since mig 955 — give him all seven, like Luke, Anthony,
-- Sheldon and Victor.  James has no schedule row, so he already sees every
-- practice of every team he coaches (APSL, Liga 1, Reserves, youth, Women).
INSERT INTO coach_schedule_days (coach_schedule_id, isodow)
SELECT s.id, d
  FROM coach_schedules s
  JOIN coaches c ON c.id = s.coach_id
  JOIN persons p ON p.id = c.person_id
  JOIN club_sections cs ON cs.id = s.club_section_id AND cs.code = 'B'
 CROSS JOIN generate_series(1, 7) AS d
 WHERE (p.first_name, p.last_name) = ('Joseph', 'Vazquez')
ON CONFLICT DO NOTHING;
