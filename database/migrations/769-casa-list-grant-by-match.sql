-- 769 (2026-10-27) — the 🌐 pull grants On Roster by the MATCHED person,
-- not by an exact name string.
--
-- Owner: "teams are showing 32 liga 1 roster but its 35 now".  The CASA
-- list had 35; the "✓ N on roster" header had 32.  The grant in
-- MensRosterController::handleOfficialRosterRefresh compared raw names,
-- so a list row matched through an alias (mig 645) or a per-team name
-- (team_person_names) never upgraded the player:
--   "Aboubacar Bayo" = Aboubacar Bayo II (3488)       — matched 'team'
--   "Ali Alshami"    = Ali Salah Alshami (3509)       — matched 'alias'
-- and one spelling had no match at all:
--   "Somi Safavi"    = Som Safavi (10878), on Liga 1   — alias below
-- The backend now grants on official_roster_names.person_id (set by
-- fh_official_roster_names_match); this migration applies the same grant
-- once so the board is right before the next pull.

INSERT INTO official_roster_aliases (source_id, name_key, person_id, note)
VALUES (2, fh_name_key('Somi Safavi'), 10878, 'CASA sheet spells it Somi, we have Som')
ON CONFLICT (source_id, name_key) DO NOTHING;

-- re-run the match trigger over the stored list
UPDATE official_roster_names SET full_name = full_name WHERE source_id = 2;

UPDATE team_persons tp
   SET roster_status_id = (SELECT id FROM roster_statuses WHERE code = 'on_roster')
  FROM official_roster_sources s
 WHERE s.id = 2 AND tp.team_id = s.team_id AND tp.removed_at IS NULL
   AND (tp.roster_status_id IS NULL OR tp.roster_status_id IN
         (SELECT id FROM roster_statuses WHERE code IN
           ('not_on_roster','awaiting_approval','needs_itc','submitted_itc',
            'needs_transfer','awaiting_transfer','awaiting_roster_spot',
            'needs_docs','has_docs')))
   AND tp.person_id IN (SELECT n.person_id FROM official_roster_names n
                         WHERE n.source_id = s.id AND n.person_id IS NOT NULL);
