-- 1074: 💤 Inactive is per TEAM, and 📄 Paper spot folds into it (owner
-- 2026-11-05: "every thing is team based. so do they have sep purpose" →
-- "yes do it").
--
-- Paper spot (mig 619) and Inactive (mig 945; one per man per SECTION
-- since mig 1009) did the same thing — that team's games by invite only,
-- its practices seen but not asked, no fines — and differed only in
-- scope.  With everything per team they are one status: 💤 Inactive on
-- this team.  Practice Squad went per team the same way in mig 1031.
--
--  * squad_statuses.inactive.per_team = true; person_section_squad_statuses
--    and its two triggers go (team rows already carry every status).
--  * The three APSL paper spots (Armando Pena, Joey Benzing, David Masi)
--    become Inactive on APSL only — still active on Liga 1; David's ⭐
--    standing call-up still invites him to every APSL game and practice.
--  * A Yes brings him back on the event's own team(s) only (was: every
--    team in the section).  On a games-need-roster team the roster rule
--    then decides ACTIVE vs Practice Squad.
--  * Fines start fresh (mig 997 waiver) only when he is Inactive on EVERY
--    team he is on — parked on APSL while playing Liga 1 is no waiver.

BEGIN;

UPDATE squad_statuses SET per_team = true WHERE code = 'inactive';

DROP TRIGGER IF EXISTS person_section_squad_apply ON person_section_squad_statuses;
DROP TRIGGER IF EXISTS team_persons_section_squad ON team_persons;
DROP FUNCTION IF EXISTS fh_section_squad_apply();
DROP FUNCTION IF EXISTS fh_team_persons_section_squad();
DROP TABLE IF EXISTS person_section_squad_statuses;

CREATE OR REPLACE FUNCTION fh_fine_waivers_sync(p_person integer)
RETURNS void LANGUAGE plpgsql AS $$
DECLARE inactive boolean;
BEGIN
    -- Inactive on every team he is on (and on at least one).
    SELECT EXISTS (SELECT 1 FROM team_persons tp WHERE tp.person_id = p_person AND tp.removed_at IS NULL)
       AND NOT EXISTS (SELECT 1 FROM team_persons tp
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

-- A Yes (not a standing default) brings him back on the event's teams.
-- Touching roster_status_id lets the games-need-roster trigger re-decide
-- ACTIVE vs Practice Squad on youth teams.
CREATE OR REPLACE FUNCTION fh_inactive_back_on_yes()
RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
    IF NEW.response = 'yes' AND NEW.created_via <> 'standing' THEN
        UPDATE team_persons tp
           SET squad_status_id = NULL, invite_only = false, call_in = false,
               roster_status_id = tp.roster_status_id
          FROM fh_event_teams fet
         WHERE fet.fh_event_id = NEW.fh_event_id AND tp.team_id = fet.team_id
           AND tp.person_id = NEW.person_id AND tp.removed_at IS NULL
           AND tp.squad_status_id = (SELECT id FROM squad_statuses WHERE code = 'inactive');
    END IF;
    RETURN NEW;
END $$;

-- 📄 paper spots → 💤 Inactive on that team.
UPDATE team_persons
   SET squad_status_id = (SELECT id FROM squad_statuses WHERE code = 'inactive')
 WHERE removed_at IS NULL AND invite_only AND NOT call_in AND squad_status_id IS NULL;

-- Re-run the waiver rule for everyone it may now read differently.
SELECT count(*) AS resynced FROM (
  SELECT fh_fine_waivers_sync(x.person_id) FROM (
    SELECT DISTINCT tp.person_id FROM team_persons tp
      JOIN squad_statuses ss ON ss.id = tp.squad_status_id AND ss.code = 'inactive'
     WHERE tp.removed_at IS NULL
    UNION
    SELECT person_id FROM fine_waivers WHERE waived_until IS NULL AND reversed_at IS NULL AND reason = 'inactive'
  ) x) y;

-- "Inactive — all his teams": one tap parks him on every team he is on.
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Roster sheet', 'Team boards — Team dropdown: inactive on all his teams', 'roster_sheet', 'team_status_inactive_all',
       NULL, '💤 Inactive — all his teams', 965, true, true, false
 WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = 'roster_sheet' AND tier = 'team_status_inactive_all');

-- The dropdown's 📄 option goes; its words retire.
UPDATE message_templates SET is_active = false
 WHERE kind = 'roster_sheet' AND tier IN ('team_status_paper', 'board_not_functional_h');

COMMIT;
