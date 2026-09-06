-- 336 — One more roster_statuses code (owner directive 2026-09-06):
--
--   awaiting_roster_spot -> "Awaiting Roster Spot"
--
-- The player is cleared and ready to submit, but the team's official
-- roster is full — he's waiting for a spot to open (a release, a
-- transfer out, a roster expansion) before the club can submit him.
-- Distinct from Awaiting Approval, where the submission is already in
-- and the league is sitting on it.
--
-- Pre-official-roster, same flags as the other waits: not on the official
-- roster (show_in_official_roster = false) but still RSVP-eligible
-- (show_in_rsvp = true) so he keeps showing up for practice and pickup.
--
-- Slots into the workflow order right before Awaiting Approval:
-- Not on Roster -> ITC pair -> Transfer pair -> Awaiting Roster Spot ->
-- Awaiting Approval -> On Roster -> Suspended. sort_order is display-only
-- (Team::getRosterStatuses()'s ORDER BY).
--
-- No backend change: handleSetRosterStatusForPerson validates by joining
-- roster_statuses.code WHERE is_active. The frontend dropdown
-- (roster-screen-base.js renderStatusSelect) lists it explicitly.

BEGIN;

INSERT INTO roster_statuses
    (id, code, display_name, description, show_in_rsvp, show_in_official_roster, sort_order, is_active)
VALUES
    (9, 'awaiting_roster_spot', 'Awaiting Roster Spot', 'Cleared to submit, but the official roster is full — waiting for a spot to open', true, false, 6, true);

UPDATE roster_statuses SET sort_order = 7 WHERE code = 'awaiting_approval';
UPDATE roster_statuses SET sort_order = 8 WHERE code = 'on_roster';
UPDATE roster_statuses SET sort_order = 9 WHERE code = 'suspended';

COMMIT;
