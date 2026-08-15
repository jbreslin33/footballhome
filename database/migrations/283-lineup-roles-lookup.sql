-- 283 — Normalizes team_persons.lineup_role (279) from a CHECK-constrained
-- varchar into a proper lookup table + FK, matching the existing
-- rsvp_statuses / match_statuses pattern.
--
-- Still a per-(team_id, person_id) flag, not per-game (that's
-- match_lineups.is_starter) — a player can be starter-eligible for one
-- team and bench-eligible for another (e.g. Liga 1 vs APSL) because
-- team_persons already has one row per team per player.

BEGIN;

CREATE TABLE lineup_roles (
    id          integer PRIMARY KEY,
    name        varchar(20) NOT NULL UNIQUE,
    description text,
    sort_order  integer NOT NULL DEFAULT 0
);

INSERT INTO lineup_roles (id, name, description, sort_order) VALUES
    (1, 'starter', 'Coach-designated starter-eligible for this team', 1),
    (2, 'bench',   'Coach-designated bench-eligible for this team', 2);

ALTER TABLE team_persons
    ADD COLUMN lineup_role_id integer REFERENCES lineup_roles(id);

UPDATE team_persons
    SET lineup_role_id = (SELECT id FROM lineup_roles WHERE name = team_persons.lineup_role)
    WHERE lineup_role IS NOT NULL;

ALTER TABLE team_persons DROP COLUMN lineup_role;

COMMENT ON COLUMN team_persons.lineup_role_id IS
    'Coach-set "eligible for starting lineup" / "eligible for bench" designation for this team, manually edited from the game-lineup screen. NULL = no designation. FK to lineup_roles.';

COMMIT;
