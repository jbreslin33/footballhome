-- 390 — Each club section's founding year.
--
-- Owner 2026-09-19: "fix the footer to say 1895 on the women's posts" —
-- every Instagram graphic closed with a hardcoded "LIGHTHOUSE 1893".
-- The sections were founded separately (owner, same day: "men are formed
-- 1893, boys 1897, women 1895, girls 1895"), so the year is a fact about
-- the section and lives on its row; GET /api/matches/:id hands it to the
-- graphic as section_founded_year.
ALTER TABLE club_sections ADD COLUMN IF NOT EXISTS founded_year SMALLINT;

UPDATE club_sections cs
   SET founded_year = v.founded_year
  FROM (VALUES ('Mens', 1893), ('Womens', 1895), ('Boys', 1897), ('Girls', 1895)) AS v(name, founded_year)
 WHERE cs.name = v.name
   AND cs.founded_year IS DISTINCT FROM v.founded_year;
