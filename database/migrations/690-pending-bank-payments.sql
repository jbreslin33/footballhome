-- 690 (2026-10-24) — A bank (ACH) payment counts as paid the moment
-- LeagueApps records it, not days later when it clears.
--
-- Owner: "allen ssaying he paid dues. is this true?" → "Transaction
-- #83543432 · SUCCESS · $65.25" → "how are hyou not seeing that?" →
-- "this needs fixx for everone right?" → "so game center and tuition page
-- pick it up etc?".
--
-- LeagueApps applies a card charge to the registration's amountPaid at
-- once, but a Bank payment only once it settles (Jesueth Arce Jimenez's
-- 10/20 $35 was still unapplied on 10/24).  Our ledger sync
-- (person_payments, transactions-2) already has the payment within
-- minutes; the balance only read the registration.  So:
--
--   * person_la_memberships.la_paid_changed_at — when LeagueApps last
--     moved amountPaid (trigger on the sync's UPDATE).
--   * fh_membership_pending_bank_usd(m) — Bank payments on that
--     registration in the last 14 days, after amountPaid last moved:
--     paid in LeagueApps, not applied yet.  Once LeagueApps applies it,
--     amountPaid moves, la_paid_changed_at passes the payment, and it
--     stops counting — never double.
--   * fh_dues_balance_usd and fh_membership_months_overdue subtract it
--     (capped, never below zero).  Everything reading the balance follows:
--     Game Center 💰 / the alternate rule, #my, the dues note, RSVP
--     eligibility; #payments and #rsvps read the months-behind function.

ALTER TABLE person_la_memberships ADD COLUMN IF NOT EXISTS la_paid_changed_at TIMESTAMPTZ;
COMMENT ON COLUMN person_la_memberships.la_paid_changed_at IS
    'mig 690: when the LA sync last saw amountPaid change — Bank payments in the ledger after it are pending (paid, not applied yet).';

CREATE OR REPLACE FUNCTION person_la_memberships_paid_changed() RETURNS trigger AS $fn$
BEGIN
    IF NEW.la_amount_paid_cents IS DISTINCT FROM OLD.la_amount_paid_cents THEN
        NEW.la_paid_changed_at := now();
    END IF;
    RETURN NEW;
END $fn$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS person_la_memberships_paid_changed ON person_la_memberships;
CREATE TRIGGER person_la_memberships_paid_changed
    BEFORE UPDATE OF la_amount_paid_cents ON person_la_memberships
    FOR EACH ROW EXECUTE FUNCTION person_la_memberships_paid_changed();

CREATE OR REPLACE FUNCTION fh_membership_pending_bank_usd(p_membership_id bigint) RETURNS numeric
LANGUAGE sql STABLE AS $$
    SELECT COALESCE(SUM(pp.amount), 0)
      FROM person_la_memberships m
      JOIN person_payments pp ON pp.la_registration_id = m.la_registration_id
     WHERE m.id = p_membership_id
       AND pp.txn_type = 'Bank'
       AND pp.paid_at > now() - interval '14 days'
       AND pp.paid_at > COALESCE(m.la_paid_changed_at, '-infinity'::timestamptz)
$$;
COMMENT ON FUNCTION fh_membership_pending_bank_usd(bigint) IS
    'mig 690: Bank (ACH) payments LeagueApps recorded but has not applied to the registration yet (last 14 days, after amountPaid last moved).';

CREATE OR REPLACE FUNCTION fh_dues_balance_usd(p_person_id integer) RETURNS numeric
LANGUAGE sql STABLE AS $$
  SELECT COALESCE(SUM(GREATEST(0, (m.la_amount_owed_cents - m.la_amount_paid_cents) / 100.0
                                   - fh_membership_pending_bank_usd(m.id))), 0)
    FROM person_la_memberships m
    JOIN leagueapps_programs lp ON lp.program_id = m.la_program_id
   WHERE m.person_id = p_person_id AND m.ended_at IS NULL
     AND lp.variant IN ('active', 'inactive')
$$;

-- LeagueApps' months-behind bucket (sync, mig 270), less any pending bank
-- payment — #payments and #rsvps read this instead of the raw column.
CREATE OR REPLACE FUNCTION fh_membership_months_overdue(p_membership_id bigint) RETURNS integer
LANGUAGE sql STABLE AS $$
    SELECT CASE WHEN fh_membership_pending_bank_usd(m.id) > 0
                THEN floor(GREATEST(0, (m.la_amount_owed_cents - m.la_amount_paid_cents) / 100.0
                                       - fh_membership_pending_bank_usd(m.id))
                           / NULLIF(fh_monthly_dues_usd(134, NULL), 0))::int
                ELSE m.months_overdue END
      FROM person_la_memberships m WHERE m.id = p_membership_id
$$;
