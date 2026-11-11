-- 1240 (2026-11-11) — Pickup counts toward club dues.
--
-- Owner 2026-11-11: "yes count pickup toward club dues" (about members LA
-- moved from club → pickup and back, "a lot were paying then moved").
-- LA moves a member by MOVING the same registration (same
-- la_registration_id) into the section's pickup program, and every payment
-- stays on that registration — so the payment-advance (next_due_at) math
-- already counted them.  What did not: the balance.  fh_dues_balance_usd
-- summed active + inactive memberships only, so a member sitting in pickup
-- read $0 owed on every card, notice and the #payments / #finances
-- summaries.  Pickup now counts like active.  (#payments also lists them in
-- their section with a Pickup chip — PaymentsController.)

CREATE OR REPLACE FUNCTION public.fh_dues_balance_usd(p_person_id integer)
 RETURNS numeric
 LANGUAGE sql
 STABLE
AS $function$
  SELECT COALESCE(SUM(GREATEST(0, (m.la_amount_owed_cents - m.la_amount_paid_cents) / 100.0
                                   - fh_membership_pending_bank_usd(m.id))), 0)
    FROM person_la_memberships m
    JOIN leagueapps_programs lp ON lp.program_id = m.la_program_id
   WHERE m.person_id = p_person_id AND m.ended_at IS NULL
     AND lp.variant IN ('active', 'inactive', 'pickup')   -- pickup = club member for dues (mig 1240)
     AND fh_dues_free_reason(p_person_id) IS NULL         -- volunteers (704) owe nothing
$function$;

-- The card chip on #payments for a member whose registration sits in pickup.
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
SELECT 'Player sheet', v.label, 'player_sheet', v.tier, NULL, v.body, v.sort, true, true
  FROM (VALUES
    ('pickup_chip',       'Tuition card — member in the LA pickup program',          '🔁 Pickup', 61),
    ('pickup_chip_title', 'Tuition card — pickup chip tooltip',                      'Registration is in the LA pickup program right now — counts toward club dues', 62)
  ) AS v(tier, label, body, sort)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates t WHERE t.kind = 'player_sheet' AND t.tier = v.tier);
