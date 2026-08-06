-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Migration 264: drop team 915 "Dues Owed (Boys)"
--
-- Resolves item 3 from the "Session update (2026-08-05)" queue in
-- docs/adr/2026-07-30-roster-membership-rsvp-normalization.md. This
-- ADR named 915 as the canonical `admin_bucket` example, but it has
-- zero `team_persons` rows ever, and real dues/payment status already
-- lives on `players.is_paid_up_to_date` / `persons.leagueapps_payment_
-- status`, independent of any team membership. Decision: delete.
--
-- Cascades (verified before writing this migration, both ON DELETE
-- CASCADE): 4 team_coaches rows (James Breslin, Mohamed Mahgoub,
-- Charles Darlensky, Rancy Wright — all from the same 2026-07-10
-- bulk-seed timestamp that attached these coaches to nearly every
-- team; not a real per-team assignment) and 1 team_eligible_genders
-- row. Every other table with a teams(id) FK has zero rows for 915.
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

BEGIN;

DELETE FROM teams WHERE id = 915;

COMMIT;
