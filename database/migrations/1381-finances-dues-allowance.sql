-- 1381 (2026-11-14) — allowance for uncollectible dues (the standard way).
--
-- Owner 2026-11-14: "so some of the due money will never be collected so does
-- it assume that it will lol" → "so we would account for not collecting
-- right?" → "go ahead".
--
-- • dues_allowance_tiers: the share of a member's balance not expected to be
--   collected, by how many months of dues it is (aging method). Change the
--   percentages by migration.
-- • Statement of Financial Position: dues receivable, less the allowance.
-- • Statement of Activities: the allowance is an expense (uncollectible dues).
-- • Operating Budget / BvA: dues × the expected collection rate, = 1 −
--   allowance ÷ dues billed since Aug 1 (collected + still owed).

CREATE TABLE IF NOT EXISTS dues_allowance_tiers (
    id                 serial PRIMARY KEY,
    club_id            integer NOT NULL REFERENCES clubs(id),
    months_behind_from integer NOT NULL CHECK (months_behind_from >= 1),
    uncollectible_pct  numeric(5,2) NOT NULL CHECK (uncollectible_pct BETWEEN 0 AND 100),
    UNIQUE (club_id, months_behind_from)
);
COMMENT ON TABLE dues_allowance_tiers IS
  'Allowance for uncollectible dues (mig 1381): a balance of N months of dues (CEIL(owed / monthly rate)) is uncollectible_pct % doubtful, from the tier with the largest months_behind_from <= N.';

INSERT INTO dues_allowance_tiers (club_id, months_behind_from, uncollectible_pct) VALUES
    (134, 1, 10), (134, 2, 50), (134, 4, 100)
ON CONFLICT (club_id, months_behind_from) DO NOTHING;

CREATE OR REPLACE FUNCTION fh_dues_doubtful_usd(p_club int, p_owed numeric, p_rate numeric) RETURNS numeric
LANGUAGE sql STABLE AS $$
    SELECT CASE WHEN COALESCE(p_owed, 0) <= 0 OR COALESCE(p_rate, 0) <= 0 THEN 0
           ELSE ROUND(p_owed * COALESCE((SELECT t.uncollectible_pct FROM dues_allowance_tiers t
                                          WHERE t.club_id = p_club AND t.months_behind_from <= CEIL(p_owed / p_rate)
                                          ORDER BY t.months_behind_from DESC LIMIT 1), 0) / 100, 2) END
$$;

UPDATE message_templates t SET body = v.body
  FROM (VALUES
    ('plan_rev_dues_unit', 'paying members × dues a month × 12 months × share expected to be collected'),
    ('var_dues_net', 'Dues actual is what LeagueApps paid out after its fees (it keeps about {pct}); the budget counts dues in full, less the share not expected to be collected.'),
    ('soa_note', 'Revenue, expenses and the change in net assets since soccer''s books began on Aug 1, club-wide. Expenses are recorded when invoiced; dues when paid through LeagueApps, plus what members owe now, with the part not expected to be collected as an expense (uncollectible dues). A guaranteed grant or sponsorship is revenue in full when promised — every year of a multi-year promise — with donor restrictions when it names what it may pay for or is for a later year. Spending on a grant''s purposes in its own year releases that much from restriction.'),
    ('plan_note', 'The operating budget for the year (Aug 1 – Jul 31), in the standard nonprofit order: revenue, expenses, net surplus. Soccer is a Lighthouse program — Lighthouse receives all the money (LeagueApps dues, CASA rental, grants, sponsors) and pays soccer''s invoices; every line here is soccer''s share. Earned revenue = dues (paying members × dues × 12 × the share expected to be collected) and CASA rental (bookings on the calendar); contributed = grants (restricted to their purpose) and sponsors. Expenses are rate × quantity from each team''s fee plan plus section and club-wide lines; tap a category to see its lines. Options (Liga 2, Temple 7s) are not in the budget. * = assumed.')
  ) AS v(tier, body)
 WHERE t.kind = 'finances' AND t.tier = v.tier;

INSERT INTO message_templates (category, label, kind, tier, body, is_active, sort_order, client_side, is_public)
SELECT 'Finances', v.label, 'finances', v.tier, v.body, true, v.ord, true, false
  FROM (VALUES
    ('Finances — SFP: less allowance for uncollectible dues', 'sfp_dues_allowance', 'Less allowance for uncollectible dues', 238),
    ('Finances — SOA: uncollectible dues expense', 'soa_bad_debt', 'Uncollectible dues (allowance)', 260)
  ) AS v(label, tier, body, ord)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates t WHERE t.kind = 'finances' AND t.tier = v.tier);
