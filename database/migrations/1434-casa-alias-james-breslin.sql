-- 1434 (2026-11-17) — CASA's Liga 1 sheet added James Breslin on 11/12
-- with the date in the Last Name box: row 1 reads "James | 11/12/2026".
-- Owner: "shows me as not on roster" → "oh i am not in footballhome lol?"
-- He is (person 1, Liga 1 team 120); the pull runs on every load and was
-- fine — only the name could not match.  The alias maps that exact sheet
-- name onto him (as mig 676 does for Ali Salah Alshami); its trigger
-- rematches the pulled list at once.  If CASA fixes the row, "James
-- Breslin" matches on its own and this row just goes unused.
-- NB the sheet's DOB (1972-07-24) differs from persons.birth_date — owner
-- to confirm which is right; not changed here.

INSERT INTO official_roster_aliases (source_id, name_key, person_id, note)
SELECT s.id, fh_name_key('James 11/12/2026'), 1, 'CASA sheet put the date added (11/12/2026) in his Last Name box'
  FROM official_roster_sources s
 WHERE s.team_id = 120 AND s.system = 'google_sheet' AND s.is_active
ON CONFLICT (source_id, name_key) DO NOTHING;
