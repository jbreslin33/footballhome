-- 430 — Club staff: a role that puts every team's events on your own My page.
--
-- Owner 2026-09-25: "me, lopez, vazquez, acevedo need to have ability to
-- be super admins but also see drop in with rsvp to any event for any
-- team. what role would that be lol."
--
-- Two different things, kept apart on purpose:
--   * admin level (admins.admin_level_id) = what you may DO on the staff
--     screens.  Super passes every gate.
--   * club staff (this migration)          = whose events your OWN My page
--     shows.  #my deliberately ignores admin level (owner 2026-09-17: "my
--     page for coaches and admin should be for them and not an admin type
--     view"), and a coach row shows one team and puts your name on the
--     public coaching list.  Full-time staff need every team without
--     either side effect.
--
-- Shape mirrors coaches/team_coaches: a lookup of staff roles, a
-- membership table with started_at/ended_at (rows are ended, never
-- deleted), and one SQL predicate the calendar query calls the way it
-- already calls fh_event_invited().
--
--   staff  → James Breslin (1), Michael Lopez (22439),
--            Joseph Vazquez (22277), Anthony Acevedo (22397), club 134.
--
-- Also: Joseph (admin 2, club) → super; Anthony (user 26, no admins row)
-- → new super admins row + club_admins 134, same as Michael in 428.
-- Nobody's coach rows change.

BEGIN;

CREATE TABLE IF NOT EXISTS staff_roles (
    id          SERIAL PRIMARY KEY,
    name        VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    sort_order  INTEGER
);

INSERT INTO staff_roles (name, description, sort_order)
VALUES ('staff',
        'Full-time club staff: every team''s games and practices appear on their own My page, with Go / No on each',
        1)
ON CONFLICT (name) DO NOTHING;

CREATE TABLE IF NOT EXISTS club_staff (
    club_id       INTEGER   NOT NULL REFERENCES clubs(id),
    person_id     INTEGER   NOT NULL REFERENCES persons(id) ON DELETE CASCADE,
    staff_role_id INTEGER   NOT NULL REFERENCES staff_roles(id),
    started_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ended_at      TIMESTAMP,
    PRIMARY KEY (club_id, person_id, started_at),
    CHECK (ended_at IS NULL OR ended_at > started_at)
);
CREATE INDEX IF NOT EXISTS idx_club_staff_person ON club_staff (person_id);
CREATE UNIQUE INDEX IF NOT EXISTS idx_club_staff_unique_active
    ON club_staff (club_id, person_id) WHERE ended_at IS NULL;

-- True when p_person_id is live club staff of the club that owns any of
-- the event's tagged teams.  Called from CalendarController's is_mine
-- next to fh_event_invited().
CREATE OR REPLACE FUNCTION fh_event_staff(p_fh_event_id BIGINT, p_person_id INTEGER)
RETURNS BOOLEAN LANGUAGE sql STABLE AS $$
  SELECT EXISTS (
    SELECT 1
      FROM fh_event_teams fet
      JOIN teams t       ON t.id = fet.team_id
      JOIN club_staff cs ON cs.club_id = t.club_id
     WHERE fet.fh_event_id = p_fh_event_id
       AND cs.person_id = p_person_id
       AND cs.ended_at IS NULL
  )
$$;

INSERT INTO club_staff (club_id, person_id, staff_role_id)
SELECT 134, p.id, (SELECT id FROM staff_roles WHERE name = 'staff')
  FROM persons p
 WHERE p.id IN (1, 22439, 22277, 22397)
   AND NOT EXISTS (SELECT 1 FROM club_staff cs
                    WHERE cs.club_id = 134 AND cs.person_id = p.id AND cs.ended_at IS NULL);

-- Joseph Vazquez: club → super.
UPDATE admins
   SET admin_level_id = (SELECT id FROM admin_levels WHERE name = 'super'),
       notes = 'Super admin - Joseph Vazquez. Club admin 2026-06-09, super 2026-09-25.'
 WHERE user_id = (SELECT id FROM users WHERE person_id = 22277);

-- Anthony Acevedo: first admins row, super, on club 134.
INSERT INTO admins (user_id, admin_level_id, notes)
SELECT u.id, (SELECT id FROM admin_levels WHERE name = 'super'),
       'Super admin - Anthony Acevedo. Super 2026-09-25.'
  FROM users u
 WHERE u.person_id = 22397
   AND NOT EXISTS (SELECT 1 FROM admins a WHERE a.user_id = u.id);

INSERT INTO club_admins (club_id, admin_id, admin_role)
SELECT 134, a.id, 'Club Administrator'
  FROM admins a JOIN users u ON u.id = a.user_id
 WHERE u.person_id = 22397
   AND NOT EXISTS (SELECT 1 FROM club_admins ca
                    WHERE ca.club_id = 134 AND ca.admin_id = a.id AND ca.ended_at IS NULL);

DO $$
DECLARE staff INT; supers INT; sees INT;
BEGIN
    SELECT count(*) INTO staff FROM club_staff
     WHERE club_id = 134 AND ended_at IS NULL AND person_id IN (1, 22439, 22277, 22397);
    IF staff <> 4 THEN
        RAISE EXCEPTION 'migration 430: %/4 staff rows', staff;
    END IF;

    SELECT count(*) INTO supers
      FROM admins a JOIN users u ON u.id = a.user_id
      JOIN admin_levels al ON al.id = a.admin_level_id
     WHERE al.name = 'super' AND u.person_id IN (1, 22439, 22277, 22397);
    IF supers <> 4 THEN
        RAISE EXCEPTION 'migration 430: %/4 are super admins', supers;
    END IF;

    -- Anthony has no Women''s coach row; staff alone must show him the game.
    SELECT count(*) INTO sees FROM fh_events fe
     WHERE fe.id = 69003214 AND fh_event_staff(fe.id, 22397);
    IF sees <> 1 THEN
        RAISE EXCEPTION 'migration 430: fh_event_staff does not see the Women''s game for Anthony';
    END IF;
END $$;

COMMIT;
