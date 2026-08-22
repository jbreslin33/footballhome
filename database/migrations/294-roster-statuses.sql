-- 294 — Creates roster_statuses, the lookup table Team::getRosterStatuses()
-- and TeamController::handleUpdateRosterMember() have queried against
-- since before this migration existed (roster_status_id was already
-- regex-parsed out of PUT /api/teams/:teamId/roster/:playerId bodies) —
-- the table itself was never created, so those code paths have been dead
-- on arrival. This finishes that scaffold rather than reinventing it.
--
-- Tracks OFFICIAL LEAGUE roster submission status — distinct from:
--   • team_persons.on_roster   — plain board-membership boolean, unused
--     by any UI since the mens board's Reserve/On-Roster toggle was
--     removed 2026-07-04.
--   • team_persons.lineup_role_id — coach-set starter/bench/reserve
--     designation (migration 283/293), the "Roster Role" dropdown.
--
-- code/display_name pairs (2026-08-22 owner directive):
--   not_on_roster     -> "Not on Roster"
--   awaiting_approval  -> "Awaiting Approval" (shortened from
--                         "Awaiting League Approval")
--   on_roster          -> "On Roster"

BEGIN;

CREATE TABLE roster_statuses (
    id                      integer PRIMARY KEY,
    code                    varchar(30) NOT NULL UNIQUE,
    display_name            varchar(60) NOT NULL,
    description             text,
    show_in_rsvp            boolean NOT NULL DEFAULT true,
    show_in_official_roster boolean NOT NULL DEFAULT true,
    sort_order              integer NOT NULL DEFAULT 0,
    is_active               boolean NOT NULL DEFAULT true
);

INSERT INTO roster_statuses
    (id, code, display_name, description, show_in_rsvp, show_in_official_roster, sort_order, is_active)
VALUES
    (1, 'not_on_roster',     'Not on Roster',     'Not submitted to the league — internal club roster only', true,  false, 1, true),
    (2, 'awaiting_approval', 'Awaiting Approval',  'Submitted to the league, pending official roster approval', true,  false, 2, true),
    (3, 'on_roster',         'On Roster',          'Confirmed on the official league roster', true,  true,  3, true);

ALTER TABLE team_persons
    ADD COLUMN roster_status_id integer REFERENCES roster_statuses(id);

COMMENT ON COLUMN team_persons.roster_status_id IS
    'Official league roster submission status (Not on Roster / Awaiting Approval / On Roster). NULL = not yet set. Distinct from on_roster (board membership) and lineup_role_id (coach Roster Role designation). FK to roster_statuses.';

COMMIT;
