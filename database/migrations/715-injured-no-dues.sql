-- 715 (2026-10-26) — Long-term injured players are not billed.  Owner: "for
-- tution we also need an injured section right? ... move mars milligan
-- there" / "so we don't bill them" → "only long term injury. but move them
-- both to long term injured" (Mars Milligan and Ryan Terrero, both set
-- Short-term on #teams).
--
-- No new list: the injury is the #teams health setting (person_injuries,
-- mig 510); health_statuses.waives_dues says which kinds stop billing
-- (Long-term injury only).  While such an injury covers now:
--   * fh_dues_balance_usd → $0 (no bill, no notice, never ALTERNATE);
--   * #finances Summary counts them under Injured, Projections leave them
--     out; #payments shows a 🩹 INJURED group (PaymentsOverview /
--     PersonPayments).
-- Set Healthy on #teams and LA's balance applies again.  Fines already
-- skip injured days (mig 510).  A volunteer (mig 704) stays a volunteer.

ALTER TABLE health_statuses ADD COLUMN IF NOT EXISTS waives_dues boolean NOT NULL DEFAULT false;
COMMENT ON COLUMN health_statuses.waives_dues IS 'mig 715: an injury of this kind covering now means no dues (Tuition 🩹 Injured).';
UPDATE health_statuses SET waives_dues = true WHERE code = 'long_term_injury' AND NOT waives_dues;

CREATE OR REPLACE FUNCTION fh_dues_free_reason(p_person int) RETURNS text
LANGUAGE sql STABLE AS $$
    SELECT CASE WHEN fh_is_volunteer(p_person)              THEN 'volunteer'
                WHEN EXISTS (SELECT 1 FROM person_injuries i
                               JOIN health_statuses h ON h.id = i.health_status_id AND h.waives_dues
                              WHERE i.person_id = p_person AND i.starts_at <= now()
                                AND (i.ends_at IS NULL OR i.ends_at > now())) THEN 'injured' END
$$;
COMMENT ON FUNCTION fh_dues_free_reason(int) IS
    'mig 715: why a person owes no dues right now — volunteer (mig 704), injured (a waives_dues injury covering now), else NULL.';

-- Same body as mig 704 with the reason function.
CREATE OR REPLACE FUNCTION fh_dues_balance_usd(p_person_id integer) RETURNS numeric
LANGUAGE sql STABLE AS $$
  SELECT COALESCE(SUM(GREATEST(0, (m.la_amount_owed_cents - m.la_amount_paid_cents) / 100.0
                                   - fh_membership_pending_bank_usd(m.id))), 0)
    FROM person_la_memberships m
    JOIN leagueapps_programs lp ON lp.program_id = m.la_program_id
   WHERE m.person_id = p_person_id AND m.ended_at IS NULL
     AND lp.variant IN ('active', 'inactive')
     AND fh_dues_free_reason(p_person_id) IS NULL   -- volunteers (704) and the injured (715) owe nothing
$$;

-- Mars Milligan and Ryan Terrero: their open Short-term injuries become Long-term.
UPDATE person_injuries i SET health_status_id = (SELECT id FROM health_statuses WHERE code = 'long_term_injury')
  FROM persons p
 WHERE p.id = i.person_id AND i.ends_at IS NULL
   AND i.health_status_id = (SELECT id FROM health_statuses WHERE code = 'short_term_injury')
   AND ((p.id = 22445 AND p.first_name = 'Mars' AND p.last_name = 'Milligan')
     OR (p.id = 22349 AND p.first_name = 'Ryan' AND p.last_name = 'Terrero'));

-- Wording (kind payments_overview, mig 489/704).
UPDATE message_templates SET body = 'Members|Free|Volunteers|Injured|Paid up|Behind|Blocked|Owed', updated_at = now()
 WHERE kind = 'payments_overview' AND tier = 'summary_columns' AND body = 'Members|Free|Volunteers|Paid up|Behind|Blocked|Owed';
UPDATE message_templates SET body = 'Monthly dues × members, then × 12. Free memberships, volunteers and injured players project $0. Owed balances are not included.', updated_at = now()
 WHERE kind = 'payments_overview' AND tier = 'projections_note' AND body = 'Monthly dues × members, then × 12. Free memberships and volunteers project $0. Owed balances are not included.';
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
SELECT 'Payments', v.label, 'payments_overview', v.tier, NULL, v.body, v.sort, true, true
  FROM (VALUES
    ('injured_label', 'Payments — injured status label', '🩹 Injured', 12),
    ('injured_note',  'Payments — injured card note',    'Long-term injury (set on Teams): not billed while it lasts. Set Healthy and dues apply again.', 13)
  ) AS v(tier, label, body, sort)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates t WHERE t.kind = 'payments_overview' AND t.tier = v.tier);
