-- 1364 (2026-11-14) — Kits: new players only.
--
-- Owner: "we don't do new kits each season. once issued players pay if lost.
-- we chose simple scheme for that reason. no design just number on back and
-- logo on front. plain white, plain royal blue" → "New players only".
--
-- budget_lines.amount_per gains 'new_member': $ × fh_budget_new_players(section,
-- year) = members on an active league program (never pickup) whose first
-- registration in that category falls in the budget year, + the section's open
-- roster spots (dues-carrying teams' max_roster − active members) we plan to
-- fill.  A year still ahead counts like this one (same joins, assumed).
-- Everyone who joined before Aug 1, 2026 got their kit before year one.
--
-- 🧪 Playground (mig 1361) follows: settings.kits_base = that count at reset,
-- teams.seed_total = team_count × players at reset; kits = kit × (kits_base +
-- players added above the seed).
BEGIN;

ALTER TABLE budget_lines DROP CONSTRAINT IF EXISTS budget_lines_amount_per_check;
ALTER TABLE budget_lines ADD CONSTRAINT budget_lines_amount_per_check CHECK (amount_per IN ('fixed', 'member', 'new_member', 'week'));

CREATE OR REPLACE FUNCTION fh_budget_new_players(p_section int, p_year int) RETURNS int LANGUAGE sql STABLE AS $$
    WITH sec AS (
        SELECT id, CASE code WHEN 'M' THEN 'men' WHEN 'W' THEN 'women' WHEN 'B' THEN 'boys' WHEN 'G' THEN 'girls' END AS cat
          FROM club_sections WHERE id = p_section
    ), yr AS (
        SELECT y.club_id, y.starts_on, y.ends_on FROM budget_years y WHERE y.id = p_year
    ), base AS (   -- a year still ahead counts this year's joins
        SELECT CASE WHEN yr.starts_on > (now() AT TIME ZONE 'America/New_York')::date
                    THEN COALESCE((SELECT y2.starts_on FROM budget_years y2 WHERE y2.club_id = yr.club_id
                                     AND (now() AT TIME ZONE 'America/New_York')::date BETWEEN y2.starts_on AND y2.ends_on), yr.starts_on)
                    ELSE yr.starts_on END AS from_,
               CASE WHEN yr.starts_on > (now() AT TIME ZONE 'America/New_York')::date
                    THEN COALESCE((SELECT y2.ends_on FROM budget_years y2 WHERE y2.club_id = yr.club_id
                                     AND (now() AT TIME ZONE 'America/New_York')::date BETWEEN y2.starts_on AND y2.ends_on), yr.ends_on)
                    ELSE yr.ends_on END AS to_
          FROM yr
    ), act AS (
        SELECT DISTINCT m.person_id FROM person_la_memberships m
          JOIN leagueapps_programs lp ON lp.program_id = m.la_program_id, sec
         WHERE m.ended_at IS NULL AND lp.variant = 'active' AND lp.category = sec.cat
    ), joined AS (
        SELECT a.person_id FROM act a, sec, base
         WHERE (SELECT MIN(m.la_registered_at) FROM person_la_memberships m JOIN leagueapps_programs lp ON lp.program_id = m.la_program_id
                 WHERE m.person_id = a.person_id AND lp.category = sec.cat)::date BETWEEN base.from_ AND base.to_
    )
    SELECT ((SELECT COUNT(*) FROM joined)
          + GREATEST(0, (SELECT COALESCE(SUM(t.max_roster), 0) FROM teams t
                          WHERE t.club_section_id = p_section AND t.is_active AND t.dues_rank IS NOT NULL)
                        - (SELECT COUNT(*) FROM act)))::int
$$;
COMMENT ON FUNCTION fh_budget_new_players(int, int) IS
  'Kits to buy in a budget year (mig 1364): members who joined that year + open roster spots to fill; a year ahead counts like this one.';

UPDATE budget_lines
   SET amount_per = 'new_member', is_assumed = true,
       note = '$35 per NEW player — kits are issued once, a lost kit is the player''s (owner 2026-11-14): joined this year + open roster spots'
 WHERE label LIKE 'Kits — %' AND amount_per = 'member';

-- 🧪 Playground: kits for new players only
ALTER TABLE budget_playground_settings ADD COLUMN IF NOT EXISTS kits_base integer NOT NULL DEFAULT 0 CHECK (kits_base >= 0);
ALTER TABLE budget_playground_teams    ADD COLUMN IF NOT EXISTS seed_total integer NOT NULL DEFAULT 0 CHECK (seed_total >= 0);

-- run after fh_budget_playground_reset (BudgetPlayground::reset calls both)
CREATE OR REPLACE FUNCTION fh_budget_playground_kits(p_club int, p_year int) RETURNS void LANGUAGE sql AS $$
    UPDATE budget_playground_teams SET seed_total = team_count * players
     WHERE club_id = p_club AND budget_year_id = p_year;
    UPDATE budget_playground_settings st SET kits_base = COALESCE((
        SELECT SUM(fh_budget_new_players(s.id, p_year)) FROM club_sections s
         WHERE s.code = ANY (CASE st.group_code WHEN 'Y' THEN ARRAY['B', 'G'] WHEN 'C' THEN ARRAY[]::text[] ELSE ARRAY[st.group_code] END)), 0)
     WHERE st.club_id = p_club AND st.budget_year_id = p_year;
$$;
SELECT fh_budget_playground_kits(134, id) FROM budget_years WHERE club_id = 134;

COMMIT;
