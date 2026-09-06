-- 337 — One more roster_statuses code (owner directive 2026-09-06):
--
--   possible_drop -> "Possible Drop"
--
-- The player IS on the official league roster, but the club is thinking
-- about dropping him (to free a spot, dues, attendance, whatever). He
-- still counts as on roster in every sense until he's actually dropped:
-- show_in_official_roster = true so official-roster views and the
-- board's "✓ N on roster" tally keep him, show_in_rsvp = true so he
-- keeps RSVPing. The status is a flag for the coach, not a change in
-- standing — the counterpart to Awaiting Roster Spot (336) on the other
-- side of the roster line.
--
-- Workflow order: ... -> Awaiting Approval -> On Roster -> Possible Drop
-- -> Suspended. sort_order is display-only.
--
-- No backend change (validated by joining roster_statuses.code). The
-- frontend dropdown and on-roster tally (roster-screen-base.js
-- renderStatusSelect / renderOnRosterTally / refreshOnRosterTally) list
-- it explicitly.

BEGIN;

INSERT INTO roster_statuses
    (id, code, display_name, description, show_in_rsvp, show_in_official_roster, sort_order, is_active)
VALUES
    (10, 'possible_drop', 'Possible Drop', 'On the official roster, but the club may drop him — still counts as on roster', true, true, 9, true);

UPDATE roster_statuses SET sort_order = 10 WHERE code = 'suspended';

COMMIT;
