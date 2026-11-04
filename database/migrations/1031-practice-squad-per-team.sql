-- 1031: Practice Squad = no spot on this team (owner 2026-11-04: "youth
-- where there is no spot for player but we want them in an age group.
-- and same with liga1 apsl if no spot … practice squad is the way to go").
--
-- 1. Per team, not per section.  Mig 1009 made Practice Squad / Inactive
--    one category per man per section; "no spot" is about ONE team (39
--    youth kids hold a full spot on one team and no spot on another in the
--    same section).  squad_statuses.per_team marks it: a per-team status
--    lives on that team_persons row only (squad_status_id + invite_only);
--    person_section_squad_statuses keeps the section-wide ones (Inactive).
--    Clearing a section status now only resets rows that carried it.
-- 2. Youth: not on the team's league list = 🏋 Practice Squad (practices,
--    no games) instead of ↔ Call-in.  fh_team_persons_games_need_roster
--    sets it; on the list clears it.  The 82 youth Call-in rows move.
--    A game call-up is still an invite, as before.
-- 3. No Room leaves the Roster pill dropdown (nobody carries it): no spot
--    is set on the Team pill; the Roster pill shows Practice Squad men in
--    its NEEDS ADD › No Room step as a mirror.
-- ↔ Call-in stays for a man on the league roster asked game by game.

BEGIN;

ALTER TABLE squad_statuses ADD COLUMN IF NOT EXISTS per_team boolean NOT NULL DEFAULT false;
COMMENT ON COLUMN squad_statuses.per_team IS
  'mig 1031: true = set per team on team_persons.squad_status_id (Practice Squad = no spot on that team); false = one per man per section via person_section_squad_statuses (Inactive).';
UPDATE squad_statuses SET per_team = true WHERE code = 'practice_squad';

COMMENT ON TABLE person_section_squad_statuses IS
  'mig 1009/1031: a man''s section-wide category (squad_statuses.per_team = false, i.e. Inactive), once per club section; team_persons.squad_status_id mirrors it on all his teams in that section (trigger fh_section_squad_apply). Per-team categories (Practice Squad) live on the team row only.';
COMMENT ON COLUMN team_persons.squad_status_id IS
  'Team pill category on this team: a per-team status (Practice Squad, mig 1031) written here, or the mirror of person_section_squad_statuses (Inactive, mig 1009).';

-- No section rows for a per-team status (none today).
DELETE FROM person_section_squad_statuses s USING squad_statuses ss
 WHERE ss.id = s.squad_status_id AND ss.per_team;

CREATE OR REPLACE FUNCTION fh_section_squad_apply() RETURNS trigger
LANGUAGE plpgsql AS $$
BEGIN
    IF TG_OP = 'DELETE' THEN
        -- Only rows carrying THIS section status; a per-team Practice
        -- Squad on another team stays.
        UPDATE team_persons tp
           SET squad_status_id = NULL, invite_only = false, call_in = false
          FROM teams t
         WHERE t.id = tp.team_id AND t.club_section_id = OLD.club_section_id
           AND tp.person_id = OLD.person_id AND tp.removed_at IS NULL
           AND tp.squad_status_id = OLD.squad_status_id;
    ELSE
        UPDATE team_persons tp
           SET squad_status_id = NEW.squad_status_id, invite_only = true, call_in = false
          FROM teams t
         WHERE t.id = tp.team_id AND t.club_section_id = NEW.club_section_id
           AND tp.person_id = NEW.person_id AND tp.removed_at IS NULL
           AND tp.squad_status_id IS DISTINCT FROM NEW.squad_status_id;
    END IF;
    RETURN NULL;
END $$;

-- Youth (games_need_roster): the league list decides the spot.  On it =
-- full (a per-team Practice Squad ends); off it = Practice Squad.  A
-- section status (Inactive) is laid on top by team_persons_section_squad
-- on insert, and is never overwritten here.
CREATE OR REPLACE FUNCTION fh_team_persons_games_need_roster() RETURNS trigger
LANGUAGE plpgsql AS $$
DECLARE on_list boolean; ps integer; sec boolean;
BEGIN
    IF (SELECT games_need_roster FROM teams WHERE id = NEW.team_id) THEN
        on_list := COALESCE((SELECT counts_as_on_roster FROM roster_statuses WHERE id = NEW.roster_status_id), false)
                OR EXISTS (SELECT 1 FROM official_roster_names n
                             JOIN official_roster_sources s ON s.id = n.source_id
                            WHERE s.team_id = NEW.team_id AND s.is_active AND n.person_id = NEW.person_id);
        SELECT id INTO ps FROM squad_statuses WHERE code = 'practice_squad';
        sec := NEW.squad_status_id IS NOT NULL
               AND NOT COALESCE((SELECT per_team FROM squad_statuses WHERE id = NEW.squad_status_id), false);
        IF NOT sec THEN
            NEW.squad_status_id := CASE WHEN on_list THEN NULL ELSE ps END;
        END IF;
        NEW.invite_only := NEW.squad_status_id IS NOT NULL;
        NEW.call_in     := false;
    END IF;
    RETURN NEW;
END $$;

-- The 82 youth Call-in rows → Practice Squad (same rule, applied now).
UPDATE team_persons tp
   SET squad_status_id = (SELECT id FROM squad_statuses WHERE code = 'practice_squad'),
       invite_only = true, call_in = false
  FROM teams t
 WHERE t.id = tp.team_id AND t.games_need_roster AND tp.removed_at IS NULL
   AND tp.call_in AND tp.squad_status_id IS NULL;

-- No Room out of every league's dropdown.
DELETE FROM league_roster_statuses
 WHERE roster_status_id = (SELECT id FROM roster_statuses WHERE code = 'awaiting_roster_spot');

-- Copy: the dropdown's help line names the new meaning.
UPDATE message_templates SET body = 'His category — Plays, Practice Squad (no spot on this team: trains, no games), Paper spot (holds the place, plays only when invited), Call-in (on the league roster, asked game by game), Inactive (not practicing, still billed, no RSVP asks) or injured. Inactive and injured are one per man: they apply on every team in his section; Practice Squad is per team.'
 WHERE kind = 'roster_sheet' AND tier = 'team_status_title';

COMMIT;
