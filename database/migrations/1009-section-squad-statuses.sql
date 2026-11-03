-- 1009: one category per man per section (owner 2026-11-03: "we also need
-- to categorize guys … besides rsvp eligibility"; proposal "Men's #teams:
-- Team pill proposal", decision 2).
--
-- Practice Squad / Inactive used to live on each team_persons row, so a
-- man on APSL and Liga 1 could be Inactive on one and blank on the other.
-- person_section_squad_statuses is now the truth: one row per person per
-- club section.  team_persons.squad_status_id (+ the invite_only it needs,
-- which carries the no-game-grants rules) is kept in step by trigger for
-- every one of his teams in that section, so the existing readers
-- (RsvpBoard, Calendar, Payments, fines, Game Center) keep working
-- unchanged.  Write the person row, never team_persons.squad_status_id.

BEGIN;

CREATE TABLE IF NOT EXISTS person_section_squad_statuses (
    person_id        integer NOT NULL REFERENCES persons(id) ON DELETE CASCADE,
    club_section_id  integer NOT NULL REFERENCES club_sections(id),
    squad_status_id  integer NOT NULL REFERENCES squad_statuses(id),
    set_at           timestamptz NOT NULL DEFAULT now(),
    PRIMARY KEY (person_id, club_section_id)
);
COMMENT ON TABLE person_section_squad_statuses IS
  'mig 1009: a man''s Practice Squad / Inactive category, once per club section. team_persons.squad_status_id mirrors it on all his teams in that section (trigger fh_section_squad_apply).';
COMMENT ON COLUMN team_persons.squad_status_id IS
  'Mirror of person_section_squad_statuses (mig 1009) for this team''s section. Do not write directly.';

-- Backfill: today's team rows.  Mixed rows for one man in one section
-- (none on 11/3) resolve to the lowest sort_order (Practice Squad over
-- Inactive) — the less restrictive one.
INSERT INTO person_section_squad_statuses (person_id, club_section_id, squad_status_id)
SELECT DISTINCT ON (tp.person_id, t.club_section_id) tp.person_id, t.club_section_id, tp.squad_status_id
  FROM team_persons tp
  JOIN teams t ON t.id = tp.team_id
  JOIN squad_statuses ss ON ss.id = tp.squad_status_id
 WHERE tp.removed_at IS NULL AND tp.squad_status_id IS NOT NULL AND t.club_section_id IS NOT NULL
 ORDER BY tp.person_id, t.club_section_id, ss.sort_order
ON CONFLICT DO NOTHING;

-- Person row changed → every one of his live teams in that section.
-- Clearing a category returns the team row to a full spot (invite_only
-- false), as Inactive → back on a yes RSVP always did; a games_need_roster
-- team's own BEFORE trigger then re-derives invite_only / call_in.
CREATE OR REPLACE FUNCTION fh_section_squad_apply() RETURNS trigger
LANGUAGE plpgsql AS $$
DECLARE r record;
BEGIN
    r := COALESCE(NEW, OLD);
    IF TG_OP = 'DELETE' THEN
        UPDATE team_persons tp
           SET squad_status_id = NULL, invite_only = false, call_in = false
          FROM teams t
         WHERE t.id = tp.team_id AND t.club_section_id = OLD.club_section_id
           AND tp.person_id = OLD.person_id AND tp.removed_at IS NULL
           AND tp.squad_status_id IS NOT NULL;
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

DROP TRIGGER IF EXISTS person_section_squad_apply ON person_section_squad_statuses;
CREATE TRIGGER person_section_squad_apply
AFTER INSERT OR UPDATE OR DELETE ON person_section_squad_statuses
FOR EACH ROW EXECUTE FUNCTION fh_section_squad_apply();

-- New team row for a man who already has a category in that section →
-- it starts with that category.  Named to sort after
-- team_persons_games_need_roster, so it has the last word on invite_only.
CREATE OR REPLACE FUNCTION fh_team_persons_section_squad() RETURNS trigger
LANGUAGE plpgsql AS $$
DECLARE sid integer;
BEGIN
    SELECT s.squad_status_id INTO sid
      FROM person_section_squad_statuses s
      JOIN teams t ON t.club_section_id = s.club_section_id
     WHERE t.id = NEW.team_id AND s.person_id = NEW.person_id;
    IF sid IS NOT NULL THEN
        NEW.squad_status_id := sid;
        NEW.invite_only     := true;
        NEW.call_in         := false;
    END IF;
    RETURN NEW;
END $$;

DROP TRIGGER IF EXISTS team_persons_section_squad ON team_persons;
CREATE TRIGGER team_persons_section_squad
BEFORE INSERT ON team_persons
FOR EACH ROW EXECUTE FUNCTION fh_team_persons_section_squad();

-- A real yes RSVP brings an Inactive man back (mig 945 rule), now on the
-- person row; the apply trigger clears every team row.
CREATE OR REPLACE FUNCTION fh_inactive_back_on_yes() RETURNS trigger
LANGUAGE plpgsql AS $$
BEGIN
    IF NEW.response = 'yes' AND NEW.created_via <> 'standing' THEN
        DELETE FROM person_section_squad_statuses s
         WHERE s.person_id = NEW.person_id
           AND s.squad_status_id = (SELECT id FROM squad_statuses WHERE code = 'inactive');
        -- Rows from before mig 1009 that never had a person row.
        UPDATE team_persons tp
           SET squad_status_id = NULL, invite_only = false, call_in = false
         WHERE tp.person_id = NEW.person_id AND tp.removed_at IS NULL
           AND tp.squad_status_id = (SELECT id FROM squad_statuses WHERE code = 'inactive');
    END IF;
    RETURN NEW;
END $$;

-- Bring every team row in line with its person row (a man Inactive on
-- Liga 1 only is now Inactive on APSL too).
UPDATE team_persons tp
   SET squad_status_id = s.squad_status_id, invite_only = true, call_in = false
  FROM teams t, person_section_squad_statuses s
 WHERE t.id = tp.team_id AND s.club_section_id = t.club_section_id AND s.person_id = tp.person_id
   AND tp.removed_at IS NULL AND tp.squad_status_id IS DISTINCT FROM s.squad_status_id;

COMMIT;
