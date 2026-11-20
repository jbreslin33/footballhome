-- 1636 (2026-11-20) — #tuition: total paid, then the LeagueApps fees coming
-- off.  Owner: "why are we not showing total paid then the la fees coming
-- off?" / "not seeing la fees … on tuition page".
--
-- Each MONEY IN row of the stats (since the books start / this month / avg /
-- a past month) now ends  Total − LeagueApps fees = After fees.  The fee is
-- what LeagueApps kept of the approved money (amount − net_amount), served
-- per section + month by /api/payments/ledger — the same figure as the
-- LeagueApps fees line on #finances.

INSERT INTO message_templates (category, label, kind, tier, body, is_active, sort_order, client_side, is_public)
SELECT v.cat, v.label, v.kind, v.tier, v.body, true, v.ord, true, false
  FROM (VALUES
    ('Payments', 'Tuition — cell: what LeagueApps kept', 'payments_overview', 'split_la_fees', '➖ LeagueApps fees', 902),
    ('Payments', 'Tuition — cell: money in after LeagueApps fees', 'payments_overview', 'split_after_fees', '🏦 After fees', 903)
  ) AS v(cat, label, kind, tier, body, ord)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates t WHERE t.kind = v.kind AND t.tier = v.tier);
