-- 808 (2026-10-29) — two APSL Reserves TeamPass spellings that are our players.
--
-- Same fix as mig 768 for the CASA sheet, on the Reserves TeamPass list
-- (official_roster_sources 6):
--   "Leonardo Santa Castano" = Leo Santa (3511) — full name + second surname
--   "Lusayo Msakatika"       = Lusayo Mwakatika (22298) — TeamPass typo

INSERT INTO official_roster_aliases (source_id, name_key, person_id, note)
SELECT 6, fh_name_key(v.n), v.p, v.note
  FROM (VALUES ('Leonardo Santa Castano', 3511, 'TeamPass has his full name Leonardo Santa Castano'),
               ('Lusayo Msakatika', 22298, 'TeamPass spells it Msakatika, we have Mwakatika')) AS v(n, p, note)
ON CONFLICT (source_id, name_key) DO NOTHING;
