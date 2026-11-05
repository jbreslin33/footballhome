-- 1075: mig 1074's "Inactive on every team" waiver rule counted the PICK
-- pickup pool (a team with no club section), so Yancarlo Corredor (22221),
-- Inactive on Liga 1 and Cup, lost his 10/1 start-fresh waiver.  Only
-- section teams count; his waiver re-opens.

BEGIN;

CREATE OR REPLACE FUNCTION fh_fine_waivers_sync(p_person integer)
RETURNS void LANGUAGE plpgsql AS $$
DECLARE inactive boolean;
BEGIN
    -- Inactive on every section team he is on (and on at least one);
    -- pickup pools (no section) do not count.
    SELECT EXISTS (SELECT 1 FROM team_persons tp JOIN teams t ON t.id = tp.team_id
                    WHERE tp.person_id = p_person AND tp.removed_at IS NULL AND t.club_section_id IS NOT NULL)
       AND NOT EXISTS (SELECT 1 FROM team_persons tp
                         JOIN teams t ON t.id = tp.team_id AND t.club_section_id IS NOT NULL
                         LEFT JOIN squad_statuses ss ON ss.id = tp.squad_status_id
                        WHERE tp.person_id = p_person AND tp.removed_at IS NULL
                          AND ss.code IS DISTINCT FROM 'inactive')
      INTO inactive;
    IF inactive THEN
        INSERT INTO fine_waivers (person_id, waived_from, reason)
        SELECT p_person, fh_fine_unbilled_since(now()), 'inactive'
         WHERE NOT EXISTS (SELECT 1 FROM fine_waivers w
                            WHERE w.person_id = p_person AND w.waived_until IS NULL AND w.reversed_at IS NULL);
    ELSE
        UPDATE fine_waivers SET waived_until = GREATEST(now(), waived_from + interval '1 second')
         WHERE person_id = p_person AND waived_until IS NULL AND reversed_at IS NULL AND reason = 'inactive';
    END IF;
END $$;

-- Re-open what 1074 closed by mistake (closed today, still inactive everywhere that counts).
UPDATE fine_waivers w SET waived_until = NULL
 WHERE w.reason = 'inactive' AND w.reversed_at IS NULL
   AND w.waived_until >= '2026-11-05 14:00+00' AND w.waived_until < '2026-11-05 15:00+00'
   AND EXISTS (SELECT 1 FROM team_persons tp JOIN teams t ON t.id = tp.team_id AND t.club_section_id IS NOT NULL
                WHERE tp.person_id = w.person_id AND tp.removed_at IS NULL)
   AND NOT EXISTS (SELECT 1 FROM team_persons tp
                     JOIN teams t ON t.id = tp.team_id AND t.club_section_id IS NOT NULL
                     LEFT JOIN squad_statuses ss ON ss.id = tp.squad_status_id
                    WHERE tp.person_id = w.person_id AND tp.removed_at IS NULL
                      AND ss.code IS DISTINCT FROM 'inactive');

COMMIT;
