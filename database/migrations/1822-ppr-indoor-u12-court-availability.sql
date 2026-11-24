-- 1822 (2026-11-24) — PPR Indoor 2027: when the U12 team's home court is free.
-- Owner: "COurt available 9am to 12pm and 4pm to 9pm sat, sun 9am to 9pm".
UPDATE league_entry_teams et SET court_availability = 'Saturdays 9 AM – 12 PM and 4 PM – 9 PM; Sundays 9 AM – 9 PM'
  FROM league_entries e
 WHERE e.id = et.entry_id AND e.season_label = '2027 Indoor' AND et.age_group = 'U12';
