-- 1542 (2026-11-19) — APSL registration form: Tolu's spelling.
-- The form row says "Oluwtolulope Asekun-Masha"; FH has Tolu Asekun-Masha
-- (person 22598, the one on the APSL list; TeamPass spells him
-- "Oluwtolupe" — official_roster_aliases, mig 769 era).  Mig 1540's
-- matcher found no one, so: one alias row.
INSERT INTO league_form_aliases (sheet_id, name_key, person_id, note)
SELECT s.id, fh_name_key('Oluwtolulope Asekun-Masha'), 22598, 'Form spells his full first name Oluwtolulope; we have Tolu'
  FROM league_form_sheets s WHERE s.league_id = 1 AND s.season = '2026/27'
ON CONFLICT (sheet_id, name_key) DO NOTHING;
