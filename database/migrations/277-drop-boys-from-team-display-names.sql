-- ═══════════════════════════════════════════════════════════════════════
-- 277-drop-boys-from-team-display-names.sql
-- ═══════════════════════════════════════════════════════════════════════
--
-- Drops the gendered "Boys" suffix (and the 👦 emoji) from the
-- youth team display names/labels so girls joining these same
-- age-group teams don't see a name/label that reads "Boys". Matches
-- how mens teams already display (APSL/Liga 1 carry no "Men's"
-- prefix) — gender_category already tags the team internally, the
-- display name doesn't need to repeat it. gcal_team_aliases (the
-- ops-facing Team:/Club: DSL) is untouched — this is FH display only.

BEGIN;

UPDATE teams SET name = 'U6',  label = '⚽ U6'  WHERE id = 931;
UPDATE teams SET name = 'U8',  label = '⚽ U8'  WHERE id = 912;
UPDATE teams SET name = 'U10', label = '⚽ U10' WHERE id = 913;
UPDATE teams SET name = 'U12', label = '⚽ U12' WHERE id = 914;
UPDATE teams SET name = 'U19', label = '⚽ U19' WHERE id = 932;

COMMIT;
