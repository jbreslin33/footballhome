-- 081-person-la-memberships-registration-id.sql
--
-- Add `la_registration_id` to `person_la_memberships`.
--
-- Why: LA transactions carry `registrationId` (uniquely identifies the
-- registration = child + program tuple).  For adults the transaction's
-- `userId` matches the child's LA user id, so the payments-members
-- query joined `person_payments.la_user_id → external_person_aliases →
-- persons.id → person_la_memberships.person_id` correctly.
--
-- For YOUTH the transaction's `userId` is the PARENT (payer), not the
-- child.  That join therefore never matched the child's membership row
-- and Boys/Girls members all showed status='never' even when their
-- parent had paid.  Storing the child's `la_registration_id` on the
-- membership row lets us join payments to memberships on the correct
-- (child) axis regardless of who paid.
--
-- The next LA sync run (LaProgramSync::run for each program, and the
-- admin backfill) will populate this column via
-- PersonLinker::recordMembership(personId, programId, registrationId).
-- The value is nullable to keep the migration backwards-compatible
-- with in-flight rows until the sync writes them.

BEGIN;

ALTER TABLE person_la_memberships
    ADD COLUMN IF NOT EXISTS la_registration_id BIGINT;

CREATE INDEX IF NOT EXISTS person_la_memberships_registration_current_idx
    ON person_la_memberships (la_registration_id)
    WHERE ended_at IS NULL AND la_registration_id IS NOT NULL;

COMMIT;
