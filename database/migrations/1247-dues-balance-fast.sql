-- 1247 (2026-11-11) — fh_dues_balance_usd fast again.
--
-- After mig 1240 (pickup counts toward club dues) the public roll-call card
-- (/rc, RsvpBoard: fh_dues_eligible per player per event) ran 45 s+ queries
-- and #fines answered 504.  Cause: fh_membership_pending_bank_usd joins
-- person_payments on la_registration_id, which had NO index — every
-- membership row seq-scanned all payments, and mig 1240 added ~119 pickup
-- memberships to every balance.  Fix: index the join key, and only look for
-- a pending bank payment when the membership owes something.  Same result.

CREATE INDEX IF NOT EXISTS idx_person_payments_registration_paid
    ON person_payments (la_registration_id, paid_at DESC);

CREATE OR REPLACE FUNCTION public.fh_dues_balance_usd(p_person_id integer)
 RETURNS numeric
 LANGUAGE sql
 STABLE
AS $function$
  SELECT COALESCE(SUM(CASE WHEN m.la_amount_owed_cents > m.la_amount_paid_cents
                           THEN GREATEST(0, (m.la_amount_owed_cents - m.la_amount_paid_cents) / 100.0
                                            - fh_membership_pending_bank_usd(m.id))
                           ELSE 0 END), 0)
    FROM person_la_memberships m
    JOIN leagueapps_programs lp ON lp.program_id = m.la_program_id
   WHERE m.person_id = p_person_id AND m.ended_at IS NULL
     AND lp.variant IN ('active', 'inactive', 'pickup')   -- pickup = club member for dues (mig 1240)
     AND fh_dues_free_reason(p_person_id) IS NULL         -- volunteers (704) owe nothing
$function$;
