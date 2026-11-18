-- 1458 (2026-11-18) — ⚡ Calendar speed for regular users (owner "lets fix
-- regular users first. make sure they are fast ... without not getting
-- correct data").  Measured on /api/calendar/upcoming (players, parents,
-- coaches; prod data, 11/18):
--
-- 1. JIT off for this database.  The calendar query's cost estimate
--    crosses jit_above_cost (100000) on a month, so Postgres compiled
--    ~1,100 expressions to machine code on EVERY request: 843 ms of a
--    1,271 ms player month was LLVM compile time, the real work ~400 ms.
--    Our tables are small (tens of thousands of rows) — JIT never pays
--    for itself here.  Takes effect on new connections (restart backend).
--
-- 2. fh_dues_blocks_eligibility: same answer, ~6.5× faster.  It is
--    called for every player on every event's who's-going list (via
--    fh_dues_eligible) — 400–700 calls per week view.  Calling
--    fh_dues_policy_blocks() from inside it cost ~0.7 ms a call; the same
--    pick done inline costs ~0.1 ms.  The LATERAL below MUST stay the
--    same pick as fh_dues_policy_blocks (section row beats club-wide row,
--    newest effective_from on or before p_on wins, none = no block).
--    Checked: 0 mismatches for all 2,173 rostered people on 2026-09-01,
--    10-01 (65 blocked), 10-10 and 11-18.
BEGIN;

DO $$ BEGIN
  EXECUTE format('ALTER DATABASE %I SET jit = off', current_database());
END $$;

CREATE OR REPLACE FUNCTION fh_dues_blocks_eligibility(p_person_id integer, p_club_id integer DEFAULT 134, p_on date DEFAULT CURRENT_DATE)
 RETURNS boolean
 LANGUAGE sql
 STABLE
AS $function$
  SELECT EXISTS (
    SELECT 1
      FROM team_persons tp
      JOIN teams t ON t.id = tp.team_id
     CROSS JOIN LATERAL (
           -- = fh_dues_policy_blocks(p_club_id, t.club_section_id, p_on)
           SELECT dp.blocks_eligibility
             FROM dues_policies dp
            WHERE dp.club_id = p_club_id
              AND (dp.club_section_id IS NULL OR dp.club_section_id = t.club_section_id)
              AND dp.effective_from <= p_on
            ORDER BY (dp.club_section_id IS NOT NULL) DESC, dp.effective_from DESC
            LIMIT 1) pol
     WHERE tp.person_id = p_person_id
       AND tp.removed_at IS NULL
       AND t.club_id = p_club_id
       AND t.club_section_id IS NOT NULL
       AND pol.blocks_eligibility)
$function$;

COMMIT;
