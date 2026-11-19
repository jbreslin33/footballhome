-- 1525 (2026-11-19) — ⛔ Not On Roster on APSL too; paperwork isn't a roster.
--
-- Owner: "we would assume a guy is eligile if they are [On Roster] via some
-- roster mechanishmt [if] not then we should flag as not on roster?" →
-- "so mars should be flagged" "for apsl".
--
-- 1. APSL (35) and APSL Reserves (938) get team_eligibility_sources: the
--    APSL Active + APSL Reserve official rosters ("no diff between a
--    reserve and a main").
-- 2. The add lanes (Needs Add / ITC / Transfer / Docs / No Room / Awaiting
--    Approval) no longer count as eligible: a man is On Roster through an
--    official roster or he is flagged.  Kept: a roster status that counts
--    as on roster (On Roster, Possible / Pending Drop — still on it) and
--    Suspended.  No Liga 1 row sits in an add lane today.
-- Today: Mars Milligan (APSL, Needs Docs); Dawens Erolias and Josue David
-- on APSL Reserves (On Roster for CASA, not APSL).

BEGIN;

INSERT INTO team_eligibility_sources (team_id, source_id)
SELECT t.id, s.id
  FROM teams t CROSS JOIN official_roster_sources s
 WHERE t.id IN (35, 938) AND s.is_active AND s.league_label LIKE 'APSL%'
ON CONFLICT DO NOTHING;

CREATE OR REPLACE FUNCTION fh_team_persons_eligibility() RETURNS trigger
LANGUAGE plpgsql AS $$
DECLARE ne integer; ok boolean;
BEGIN
    IF NEW.removed_at IS NOT NULL
       OR NOT EXISTS (SELECT 1 FROM team_eligibility_sources WHERE team_id = NEW.team_id) THEN
        RETURN NEW;
    END IF;
    SELECT id INTO ne FROM squad_statuses WHERE code = 'not_eligible';
    -- 🏋 / 💤 are the coach's call: leave them be.
    IF NEW.squad_status_id IS NOT NULL AND NEW.squad_status_id <> ne THEN
        RETURN NEW;
    END IF;
    -- mig 1525: On Roster through an official roster, or a status that
    -- says he is on one; paperwork in progress (add lanes) is not.
    ok := COALESCE((SELECT counts_as_on_roster OR code = 'suspended'
                      FROM roster_statuses WHERE id = NEW.roster_status_id), false)
       OR EXISTS (SELECT 1 FROM official_roster_names n
                    JOIN team_eligibility_sources e ON e.source_id = n.source_id AND e.team_id = NEW.team_id
                   WHERE n.person_id = NEW.person_id);
    NEW.squad_status_id := CASE WHEN ok THEN NULL ELSE ne END;
    NEW.invite_only     := NEW.squad_status_id IS NOT NULL;
    RETURN NEW;
END $$;

UPDATE team_persons tp SET roster_status_id = tp.roster_status_id
 WHERE tp.removed_at IS NULL
   AND EXISTS (SELECT 1 FROM team_eligibility_sources e WHERE e.team_id = tp.team_id);

COMMIT;
