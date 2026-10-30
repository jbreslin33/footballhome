-- 868 (2026-10-30) — #teams Roster pill: a youth file roster flags, never locks.
--
-- TODO "Youth (file-based rosters): flag only, no auto-clear".  The locked
-- league PDFs (club_file sources, mig 592) now have their names in
-- official_roster_names (scripts/youth-roster-names.py — DB only, never
-- git), so the board shows the OFFICIAL list and the ✂ cut flag on youth
-- teams too.  Nothing clears those names but re-running the script on a
-- new upload: there is no 🌐 pull, so no drop lane ever auto-clears.
--
-- Mig 772's rule stays with the online lists: a name on a file list does
-- NOT block a manual remove or a status change, because youth rosters
-- keep full manual control (2026-10-21).  TeamController's has_list and
-- RosterScreenBase.leagueListLocks() follow the same line.

CREATE OR REPLACE FUNCTION fh_on_league_list(p_team_id INT, p_person_id INT)
RETURNS BOOLEAN LANGUAGE sql STABLE AS $$
    SELECT EXISTS (
        SELECT 1 FROM official_roster_sources s
          JOIN official_roster_names n ON n.source_id = s.id
         WHERE s.is_active AND s.system <> 'club_file'
           AND s.team_id = p_team_id AND n.person_id = p_person_id)
$$;
COMMENT ON FUNCTION fh_on_league_list(INT, INT) IS 'mig 868: is this person on the team''s own ONLINE league list (official_roster_names matched by the trigger)? Locks manual removal and status moves; a club_file list flags only.';
