-- 565 (2026-10-11) — dates of birth for the three men's-board players with
-- none on file, read off the APSL official roster PDF (TeamPass, fetched
-- 2026-10-02, cached in match_official_rosters for match 9304).  LeagueApps
-- has no DOB for them, so the members-pool backfill could never fill these.
-- Owner: "find amir dob from apsl official roster".
-- Guarded on birth_date IS NULL so a later LA value is never clobbered,
-- and on the name so a re-numbered person is never mis-dated.
UPDATE persons SET birth_date = '2005-06-01', updated_at = now()
 WHERE id = 1275 AND last_name = 'Khan' AND birth_date IS NULL;
UPDATE persons SET birth_date = '1991-09-14', updated_at = now()
 WHERE id = 22536 AND last_name = 'Juarez de Leon' AND birth_date IS NULL;
UPDATE persons SET birth_date = '1995-06-15', updated_at = now()
 WHERE id = 14497 AND last_name = 'Montecer' AND birth_date IS NULL;
