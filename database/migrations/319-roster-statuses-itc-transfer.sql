-- 319 — Four more roster_statuses codes (owner directive 2026-08-30), the
-- paperwork stages a player sits in BEFORE the league ever sees a roster
-- submission. Migration 294/295 modeled only the submission itself
-- (Not on Roster -> Awaiting Approval -> On Roster, plus Suspended);
-- in practice a signing is usually blocked upstream of that by a
-- clearance the club has to chase:
--
--   needs_itc         -> "Needs ITC"          player's last registration was
--                        with a foreign federation, so an International
--                        Transfer Certificate has to be requested before
--                        he can be rostered at all.
--   submitted_itc     -> "Submitted ITC"      ITC request is filed, waiting
--                        on the releasing federation.
--   needs_transfer    -> "Needs Transfer"     domestic — player is still
--                        registered to another US club; a transfer/release
--                        has to be requested.
--   awaiting_transfer -> "Awaiting Transfer"  transfer request is filed,
--                        waiting on the releasing club/league.
--
-- All four are pre-official-roster, same flags as not_on_roster /
-- awaiting_approval: NOT on the official roster yet
-- (show_in_official_roster = false), but still RSVP-eligible
-- (show_in_rsvp = true) so a player waiting on paperwork keeps showing up
-- for practice and pickup. See EventController's RSVP-eligibility query.
--
-- sort_order is renumbered so the whole list reads in workflow order:
-- Not on Roster -> ITC pair -> Transfer pair -> Awaiting Approval ->
-- On Roster -> Suspended. Nothing keys off sort_order except
-- Team::getRosterStatuses()'s ORDER BY, so renumbering is display-only.
--
-- No backend change: TeamController::handleSetRosterStatusForPerson
-- validates by joining roster_statuses.code WHERE is_active, so these
-- codes are live the moment the rows exist. The frontend dropdown
-- (roster-screen-base.js renderStatusSelect) lists them explicitly.

BEGIN;

INSERT INTO roster_statuses
    (id, code, display_name, description, show_in_rsvp, show_in_official_roster, sort_order, is_active)
VALUES
    (5, 'needs_itc',         'Needs ITC',         'Coming from a foreign federation — International Transfer Certificate not yet requested', true, false, 2, true),
    (6, 'submitted_itc',     'Submitted ITC',     'ITC requested, awaiting the releasing federation',                                          true, false, 3, true),
    (7, 'needs_transfer',    'Needs Transfer',    'Still registered to another US club — transfer/release not yet requested',                  true, false, 4, true),
    (8, 'awaiting_transfer', 'Awaiting Transfer', 'Transfer requested, awaiting the releasing club/league',                                    true, false, 5, true);

UPDATE roster_statuses SET sort_order = 6 WHERE code = 'awaiting_approval';
UPDATE roster_statuses SET sort_order = 7 WHERE code = 'on_roster';
UPDATE roster_statuses SET sort_order = 8 WHERE code = 'suspended';

COMMIT;
