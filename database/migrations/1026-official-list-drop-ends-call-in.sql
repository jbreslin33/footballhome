-- 1026: the league dropping a man ends his ↔ Call-in (owner 2026-11-04:
-- "we need it to recognize his removal and thus remove him from call
-- ins").  Up to now absence from a fresh league list never changed an FH
-- row (mig 777: only Dropping / Pending Drop auto-clear).  Now: a man the
-- previous pull of a team's list matched, whom the fresh pull no longer
-- has, comes off that team if his row there is a Call-in
-- (removed_reason 'league_list_drop').  Full spots, paper spots and
-- Inactive rows are untouched.  "Previous pull" = official_roster_seen,
-- the matched people as of the last pull, which every writer
-- (#teams 🌐 refresh, Game Center 🖨 pull, youth file script) now
-- reconciles by calling fh_official_roster_reconcile(source).
--
-- Plus the owner's cleanup of Liga 1's "⚠ Wants in" list (same message):
--   off Liga 1 — APSL main guys, "they do not belong in liga columns":
--     Luke Breslin 3463, Hedayatullah Sangin 3510, Amir Khan 1275,
--     Som Safavi 10878 (their APSL / Cup rows unchanged);
--   💤 Inactive — Jose Castillo 22487, Walter Juarez de Leon 22536,
--     David Naranjo 22496, Jonathan MedinaRodriguez 22246.  The category
--     is per club section (mig 1009), so it follows each to every Men's
--     team row (Walter's Reserves row too).
-- Cole Vennis stays as he is (soon on the official list).

BEGIN;

CREATE TABLE IF NOT EXISTS official_roster_seen (
    source_id  integer NOT NULL REFERENCES official_roster_sources(id) ON DELETE CASCADE,
    person_id  integer NOT NULL REFERENCES persons(id) ON DELETE CASCADE,
    seen_at    timestamptz NOT NULL DEFAULT now(),
    PRIMARY KEY (source_id, person_id)
);
COMMENT ON TABLE official_roster_seen IS
  'mig 1026: who the last pull of each league list matched. fh_official_roster_reconcile compares the fresh official_roster_names against it: dropped men lose a Call-in row on the list''s team.';

-- Seed with today's lists, so the first reconcile only acts on real drops.
INSERT INTO official_roster_seen (source_id, person_id)
SELECT DISTINCT source_id, person_id FROM official_roster_names WHERE person_id IS NOT NULL
ON CONFLICT DO NOTHING;

CREATE OR REPLACE FUNCTION fh_official_roster_reconcile(p_source integer) RETURNS integer
LANGUAGE plpgsql AS $$
DECLARE v_team integer; n integer := 0;
BEGIN
    SELECT team_id INTO v_team FROM official_roster_sources WHERE id = p_source;
    -- An empty list is a failed parse, never "the league dropped everyone".
    IF v_team IS NULL OR NOT EXISTS (SELECT 1 FROM official_roster_names WHERE source_id = p_source) THEN
        RETURN 0;
    END IF;

    UPDATE team_persons tp
       SET removed_at = now(), removed_reason = 'league_list_drop',
           removed_details = jsonb_build_object('source_id', p_source, 'mig', 1026)
      FROM official_roster_seen s
     WHERE s.source_id = p_source AND tp.person_id = s.person_id
       AND tp.team_id = v_team AND tp.removed_at IS NULL AND tp.call_in
       AND NOT EXISTS (SELECT 1 FROM official_roster_names n
                        WHERE n.source_id = p_source AND n.person_id = s.person_id);
    GET DIAGNOSTICS n = ROW_COUNT;

    DELETE FROM official_roster_seen s
     WHERE s.source_id = p_source
       AND NOT EXISTS (SELECT 1 FROM official_roster_names n
                        WHERE n.source_id = p_source AND n.person_id = s.person_id);
    INSERT INTO official_roster_seen (source_id, person_id)
    SELECT DISTINCT p_source, person_id FROM official_roster_names
     WHERE source_id = p_source AND person_id IS NOT NULL
    ON CONFLICT DO NOTHING;
    RETURN n;
END $$;
COMMENT ON FUNCTION fh_official_roster_reconcile(integer) IS
  'mig 1026: call after a fresh pull of a league list. A man the last pull matched and this one does not loses his Call-in row on the list''s team (league_list_drop). Returns rows ended.';

-- Liga 1 cleanup.
UPDATE team_persons SET removed_at = now(), removed_reason = 'admin_remove'
 WHERE team_id = 120 AND removed_at IS NULL AND person_id IN (3463, 3510, 1275, 10878);

INSERT INTO person_section_squad_statuses (person_id, club_section_id, squad_status_id)
SELECT p.id, 1, (SELECT id FROM squad_statuses WHERE code = 'inactive')
  FROM persons p WHERE p.id IN (22487, 22536, 22496, 22246)
ON CONFLICT (person_id, club_section_id) DO UPDATE SET squad_status_id = EXCLUDED.squad_status_id, set_at = now();

COMMIT;
