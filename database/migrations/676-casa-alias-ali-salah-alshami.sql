-- 676 (2026-10-24) — CASA's Liga 1 sheet lists Ali Salah Alshami as
-- "Ali Alshami".  Owner: "heads up ali salah is in casa roster ali
-- Alshami" → "we should use consistent name".
--
-- Football Home keeps his full name, Ali Salah Alshami (person 3509),
-- which is also how the APSL TeamPass list spells him — renaming him to
-- the sheet's short form would break that match instead.  The alias maps
-- the CASA spelling onto him (mig 645's human fix for a spelling the
-- exact match misses); its trigger rematches the pulled list at once.

INSERT INTO official_roster_aliases (source_id, name_key, person_id, note)
SELECT s.id, fh_name_key('Ali Alshami'), p.id, 'CASA sheet drops his middle name Salah'
  FROM official_roster_sources s, persons p
 WHERE s.team_id = 120 AND s.system = 'google_sheet'
   AND p.first_name = 'Ali Salah' AND p.last_name = 'Alshami'
ON CONFLICT (source_id, name_key) DO NOTHING;
