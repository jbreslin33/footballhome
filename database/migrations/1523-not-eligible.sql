-- 1523 (2026-11-19) — ⛔ Not eligible: on the team, On Roster nowhere that counts.
--
-- Owner: "for teams for liga 1 i think 1st class citizens are players that
-- are on lgia 1 official roster or apsl (call downs). if your not eligible
-- at this momnemt to play liga 1 i thik you need to be secitoned off" →
-- (Caleb Rojas) "back door eligible to liga 1 via call down from apsl" →
-- not-eligible men stop seeing Liga 1 games, keep practices → "yes build it".
--
--   team_eligibility_sources   which official rosters make a man eligible
--                              for a team's games: Liga 1 = CASA (its own)
--                              + APSL Active + APSL Reserve (call-downs)
--   squad_statuses not_eligible  per team, invite_only (no games), still
--                              owes practices; set ONLY by the trigger
--   fh_team_persons_eligibility  BEFORE INSERT/UPDATE on team_persons: on a
--                              team with eligibility sources, a row with no
--                              status or ⛔ becomes ⛔ unless he is On Roster
--                              on one of them, or his roster status counts
--                              as on roster / is an add lane / suspended
--                              (same lanes as games_need_roster, mig 1031).
--                              🏋 Practice Squad and 💤 Inactive are the
--                              coach's and never touched.
--   fn_official_names_reread_games  every official-roster sync re-reads these
--                              teams' rows too, so ⛔ clears the moment the
--                              sync shows him On Roster.
-- Today: Jeune, Patino, Kante, Nicolas, Castillo, Wafa, Corredor → ⛔.
-- Caleb Rojas and Armando Pena stay (On Roster for APSL).

BEGIN;

INSERT INTO squad_statuses (code, display_name, owes_practice_rsvps, sort_order, is_active, per_team)
SELECT 'not_eligible', 'Not eligible', true, 3, true, true
 WHERE NOT EXISTS (SELECT 1 FROM squad_statuses WHERE code = 'not_eligible');

CREATE TABLE IF NOT EXISTS team_eligibility_sources (
  team_id    integer NOT NULL REFERENCES teams(id) ON DELETE CASCADE,
  source_id  integer NOT NULL REFERENCES official_roster_sources(id) ON DELETE CASCADE,
  PRIMARY KEY (team_id, source_id)
);
COMMENT ON TABLE team_eligibility_sources IS
  'mig 1523: On Roster on any of these official rosters = eligible for this team''s games. A team with rows here auto-sets ⛔ Not eligible (squad status) on everyone else. Liga 1: CASA + APSL Active + APSL Reserve (call-down).';

INSERT INTO team_eligibility_sources (team_id, source_id)
SELECT 120, s.id FROM official_roster_sources s
 WHERE s.is_active AND (s.team_id = 120 OR s.league_label LIKE 'APSL%')
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
    ok := COALESCE((SELECT counts_as_on_roster OR board_section IN ('proposed', 'pending_add', 'no_room')
                           OR code = 'suspended'
                      FROM roster_statuses WHERE id = NEW.roster_status_id), false)
       OR EXISTS (SELECT 1 FROM official_roster_names n
                    JOIN team_eligibility_sources e ON e.source_id = n.source_id AND e.team_id = NEW.team_id
                   WHERE n.person_id = NEW.person_id);
    NEW.squad_status_id := CASE WHEN ok THEN NULL ELSE ne END;
    NEW.invite_only     := NEW.squad_status_id IS NOT NULL;
    RETURN NEW;
END $$;
COMMENT ON FUNCTION fh_team_persons_eligibility() IS
  'mig 1523: ⛔ Not eligible on a team with team_eligibility_sources unless On Roster on one of them (or an on-roster / add-lane / suspended roster status). Never touches Practice Squad or Inactive.';

DROP TRIGGER IF EXISTS team_persons_eligibility ON team_persons;
CREATE TRIGGER team_persons_eligibility
  BEFORE INSERT OR UPDATE ON team_persons
  FOR EACH ROW EXECUTE FUNCTION fh_team_persons_eligibility();

CREATE OR REPLACE FUNCTION public.fn_official_names_reread_games()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
    UPDATE team_persons tp SET roster_status_id = tp.roster_status_id
      FROM teams t
     WHERE t.id = tp.team_id AND tp.removed_at IS NULL
       AND (t.games_need_roster
            OR EXISTS (SELECT 1 FROM team_eligibility_sources e WHERE e.team_id = t.id));   -- mig 1523
    RETURN NULL;
END $function$;

-- Apply now.
UPDATE team_persons tp SET roster_status_id = tp.roster_status_id
 WHERE tp.removed_at IS NULL
   AND EXISTS (SELECT 1 FROM team_eligibility_sources e WHERE e.team_id = tp.team_id);

-- Words.
INSERT INTO message_templates (category, label, kind, tier, body, sort_order, client_side)
SELECT v.cat, v.label, v.kind, v.tier, v.body, v.ord, true
  FROM (VALUES
    ('Roster sheet', 'roster_sheet', 'board_not_eligible_h', '#teams Team view: not eligible group heading', '⛔ NOT ELIGIBLE', 905),
    ('Roster sheet', 'roster_sheet', 'team_status_not_eligible', '#teams Team pill: not eligible (set by the official-roster sync)', '⛔ Not eligible (auto)', 906),
    ('Roster sheet', 'roster_sheet', 'tc_not_eligible', '#teams team card: not eligible row', '⛔ Not eligible', 907),
    ('Roster sheet', 'roster_sheet', 'tc_not_eligible_tip', '#teams team card: not eligible hover',
     'Not On Roster for this team or as a call-down — doesn''t see its games, still practises. Clears itself when the sync shows them On Roster.', 908),
    ('Event Center', 'event_center', 'sec_not_eligible', 'Game card: not eligible fold', '⛔ Not eligible', 907),
    ('Person standing', 'person_standing', 'roster_not_eligible', 'Roster line: not eligible on a team ({team})', '{team} Not eligible', 54)
  ) AS v(cat, kind, tier, label, body, ord)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = v.kind AND m.tier = v.tier);

COMMIT;
