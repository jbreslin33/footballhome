-- 080-person-charge-flags.sql
--
-- Charge-Flag queue: the operator's "run this player's card in LA" work
-- queue.  LA's public API is read-only for payments, so we cannot POST a
-- charge from FH.  Instead, when a member is behind we flag them here with
-- an amount + reason; a human then opens LA Manager and actually runs the
-- card, then marks the flag "ran".
--
-- Lifecycle:
--   pending  → the queue.  Shown in the "Needs Charge" list.
--   ran      → operator ran the card in LA.  Kept for audit; usually the
--              next LA sync will produce a matching person_payments row.
--   canceled → operator decided not to run (refunded elsewhere, waived,
--              player quit, etc.).
--
-- We key by (la_user_id, la_program_id) rather than person_id so the queue
-- keeps working even if the person↔alias link is missing for some reason,
-- and so it lines up 1:1 with the payments Members view (which is keyed
-- the same way).
--
-- amount_cents is stored as INTEGER cents to avoid FP drift; the UI shows
-- dollars.  reason is free text.
--
-- resolved_by/at/note only populated when status transitions away from
-- 'pending'.

BEGIN;

CREATE TABLE IF NOT EXISTS person_charge_flags (
    id             BIGSERIAL   PRIMARY KEY,
    la_user_id     BIGINT      NOT NULL,
    la_program_id  BIGINT      NOT NULL,
    amount_cents   INTEGER     NOT NULL CHECK (amount_cents > 0),
    reason         TEXT,
    status         TEXT        NOT NULL DEFAULT 'pending'
                   CHECK (status IN ('pending','ran','canceled')),
    created_by     INTEGER     NOT NULL REFERENCES users(id),
    created_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
    resolved_by    INTEGER     REFERENCES users(id),
    resolved_at    TIMESTAMPTZ,
    resolved_note  TEXT,
    updated_at     TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Fast lookup by program + status for the queue view.
CREATE INDEX IF NOT EXISTS person_charge_flags_program_status_idx
    ON person_charge_flags (la_program_id, status, created_at DESC);

-- Fast per-member lookup ("does this card already have a pending flag?").
CREATE INDEX IF NOT EXISTS person_charge_flags_user_program_idx
    ON person_charge_flags (la_user_id, la_program_id, status);

-- Only one PENDING flag per (user, program) at a time — prevents the
-- operator from double-flagging the same person while a previous flag is
-- still unresolved.  Once marked ran/canceled the constraint releases.
CREATE UNIQUE INDEX IF NOT EXISTS person_charge_flags_one_pending_per_member
    ON person_charge_flags (la_user_id, la_program_id)
    WHERE status = 'pending';

COMMIT;
