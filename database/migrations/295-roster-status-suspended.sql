-- 295 — Adds a fourth roster_statuses value, 'suspended' (migration 294),
-- for a player still on the official roster but disciplinarily/dues
-- suspended from play. Still listed on the official roster
-- (show_in_official_roster) but not RSVP-eligible while suspended
-- (show_in_rsvp = false).

BEGIN;

INSERT INTO roster_statuses
    (id, code, display_name, description, show_in_rsvp, show_in_official_roster, sort_order, is_active)
VALUES
    (4, 'suspended', 'Suspended', 'On the official roster but suspended from play', false, true, 4, true);

COMMIT;
