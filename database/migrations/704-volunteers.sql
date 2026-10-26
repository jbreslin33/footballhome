-- 704 (2026-10-26) — Volunteers: players who help the club instead of
-- paying dues.  Owner: "we need a category in tuition for non paying
-- players. Like Yancarlo who is part time and helps with things like
-- streaming ... this way they are not counted in potential income" →
-- "volunteer is good, don't fine them."
--
-- LeagueApps stays read-only (their LA status may say UNPAID); FH decides:
--   * fh_dues_balance_usd → $0 for a volunteer, so no bill, no payment
--     notice, never ALTERNATE (mig 613), never dues-ineligible;
--   * fh_fine_exempt → true, so no fines (mig 693 rule extended);
--   * #finances Summary counts them in their own Volunteers column and
--     the Projections leave them out (PaymentsOverview);
--   * #payments puts them in a 🙋 VOLUNTEER group with no due/notice tools.
-- Add or remove a volunteer by a numbered migration (one-off data rule).

CREATE TABLE IF NOT EXISTS club_volunteers (
    person_id  INT PRIMARY KEY REFERENCES persons(id) ON DELETE CASCADE,
    helps_with TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
COMMENT ON TABLE club_volunteers IS
    'mig 704: volunteers — play without dues (balance $0), never fined, left out of income projections.';

CREATE OR REPLACE FUNCTION fh_is_volunteer(p_person int) RETURNS boolean
LANGUAGE sql STABLE AS $$
    SELECT EXISTS (SELECT 1 FROM club_volunteers v WHERE v.person_id = p_person)
$$;
COMMENT ON FUNCTION fh_is_volunteer(int) IS 'mig 704: person is a club volunteer (no dues, no fines).';

-- Same body as mig 690 plus the volunteer clause.
CREATE OR REPLACE FUNCTION fh_dues_balance_usd(p_person_id integer) RETURNS numeric
LANGUAGE sql STABLE AS $$
  SELECT COALESCE(SUM(GREATEST(0, (m.la_amount_owed_cents - m.la_amount_paid_cents) / 100.0
                                   - fh_membership_pending_bank_usd(m.id))), 0)
    FROM person_la_memberships m
    JOIN leagueapps_programs lp ON lp.program_id = m.la_program_id
   WHERE m.person_id = p_person_id AND m.ended_at IS NULL
     AND lp.variant IN ('active', 'inactive')
     AND NOT fh_is_volunteer(p_person_id)   -- volunteers owe nothing (mig 704)
$$;

-- Same body as mig 693 plus volunteers.
CREATE OR REPLACE FUNCTION fh_fine_exempt(p_person int) RETURNS boolean
LANGUAGE sql STABLE AS $$
    SELECT EXISTS (SELECT 1 FROM fine_exempt_persons x WHERE x.person_id = p_person)
        OR EXISTS (SELECT 1 FROM coaches co JOIN team_coaches tc ON tc.coach_id = co.id AND tc.ended_at IS NULL
                    WHERE co.person_id = p_person)
        OR fh_is_volunteer(p_person)
$$;
COMMENT ON FUNCTION fh_fine_exempt(int) IS 'mig 693/704: coaches (live team_coaches), fine_exempt_persons and volunteers are never fined.';

-- Yancarlo Corredor — part time, runs the streaming.
INSERT INTO club_volunteers (person_id, helps_with)
SELECT 22221, 'Streaming'
 WHERE EXISTS (SELECT 1 FROM persons WHERE id = 22221 AND first_name = 'Yancarlo' AND last_name = 'Corredor')
ON CONFLICT (person_id) DO NOTHING;

-- Wording (kind payments_overview, mig 489).
UPDATE message_templates SET body = 'Members|Free|Volunteers|Paid up|Behind|Blocked|Owed', updated_at = now()
 WHERE kind = 'payments_overview' AND tier = 'summary_columns' AND body = 'Members|Free|Paid up|Behind|Blocked|Owed';
UPDATE message_templates SET body = 'Monthly dues × members, then × 12. Free memberships and volunteers project $0. Owed balances are not included.', updated_at = now()
 WHERE kind = 'payments_overview' AND tier = 'projections_note' AND body = 'Monthly dues × members, then × 12. Free memberships project $0. Owed balances are not included.';
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
SELECT 'Payments', v.label, 'payments_overview', v.tier, NULL, v.body, v.sort, true, true
  FROM (VALUES
    ('volunteer_label', 'Payments — volunteer status label',   '🙋 Volunteer', 10),
    ('volunteer_note',  'Payments — volunteer card note',      'Volunteer: helps the club instead of paying dues. No bills, no fines, not in projections.', 11)
  ) AS v(tier, label, body, sort)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates t WHERE t.kind = 'payments_overview' AND t.tier = v.tier);
