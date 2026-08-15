-- ═══════════════════════════════════════════════════════════════════════
-- 281-youth-team-membership-requirements.sql
-- ═══════════════════════════════════════════════════════════════════════
--
-- fn_sweep_invalid_rosters() (migration 267) only enforces LA-membership
-- validity on teams that have a row in team_membership_requirements —
-- APSL/Liga 1/Liga 2/Adult League already do (boys/active 5039252 only,
-- Pickup excluded). The 5 active youth teams (U6/U8/U10/U12/U19) never
-- got any requirement rows, so once someone's added to team_persons
-- there, nothing ever re-checks their membership — they stay on the
-- board (and in whatever billing view reads it) even after their real
-- membership ends or downgrades to Pickup.
--
-- Found via a real case (2026-08-14): Levi Rodriguez's Boys Club
-- Members registration (5039252) ended 2026-08-12, replaced same-day by
-- a Pickup registration (5064618) — a clean downgrade, correctly
-- recorded in person_la_memberships. But his team_persons row on U10
-- never got swept, so he kept showing on the team board and getting
-- billed as a full member.
--
-- Fix: same requirement shape as the mens board, but covering BOTH real
-- Members programs (boys 5039252, girls 5039357) since these are co-ed
-- teams — girls register under the girls program, not boys. Pickup
-- (5064618 boys / girls has no pickup program yet) is deliberately
-- excluded, same as APSL/Liga1/Liga2/Adult League.
-- ═══════════════════════════════════════════════════════════════════════

BEGIN;

INSERT INTO team_membership_requirements (team_id, la_program_id)
VALUES
    (931, 5039252), (931, 5039357),  -- U6
    (912, 5039252), (912, 5039357),  -- U8
    (913, 5039252), (913, 5039357),  -- U10
    (914, 5039252), (914, 5039357),  -- U12
    (932, 5039252), (932, 5039357)   -- U19
ON CONFLICT DO NOTHING;

-- One-time catch-up, same pattern as migration 267: apply the newly-
-- widened sweep immediately so the 8 already-stale youth players (Levi
-- Rodriguez et al.) drop off their team boards right now instead of
-- waiting for their next LA membership-change event.
SELECT fn_sweep_invalid_rosters();

COMMIT;
