-- 489 (2026-09-29) — #payments Summary + Projections at the top of the page.
-- Owner: "show me projections on financial page. like for each group and
-- overall. based on current members ... current members who are current in
-- dues, then another with just current members ... how much we project to
-- take in per month and per year. for all and each boys, men etc" /
-- "should be in a projections section. and the current raw totals should
-- be in a summary right?" / "put all at top".
--
-- Numbers come from GET /api/payments/overview (PaymentsOverview model):
-- current members = open rows on each section's active LeagueApps
-- membership program; rate and line per section from dues_policies via
-- fh_monthly_dues_usd / fh_dues_line_usd; owed via fh_dues_balance_usd.
-- Only the wording lives here (kind 'payments_overview', client_side).
CREATE OR REPLACE FUNCTION pg_temp.po_tpl(p_tier text, p_label text, p_body text, p_sort int)
RETURNS void LANGUAGE sql AS $$
  INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
  SELECT 'Payments', p_label, 'payments_overview', p_tier, NULL, p_body, p_sort, true, true
   WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = 'payments_overview' AND tier = p_tier);
$$;
SELECT pg_temp.po_tpl('summary_title',     'Payments overview — summary heading',     '📊 Summary', 1);
SELECT pg_temp.po_tpl('summary_note',      'Payments overview — summary note',        'Current members on each section''s membership program, as of the last LeagueApps sync. Owed is what has not been paid; Blocked is at or over the {line} line and cannot RSVP.', 2);
SELECT pg_temp.po_tpl('summary_columns',   'Payments overview — summary columns',     'Members|Free|Paid up|Behind|Blocked|Owed', 3);
SELECT pg_temp.po_tpl('projections_title', 'Payments overview — projections heading', '📈 Projections', 4);
SELECT pg_temp.po_tpl('projections_note',  'Payments overview — projections note',    'Monthly dues × members, then × 12. Free memberships project $0. Owed balances are not included.', 5);
SELECT pg_temp.po_tpl('projections_columns','Payments overview — projections columns','Rate|Per month|Per year', 6);
SELECT pg_temp.po_tpl('row_all_members',   'Payments overview — projection: all current members',      'All current members', 7);
SELECT pg_temp.po_tpl('row_current_dues',  'Payments overview — projection: members current in dues', 'Members current in dues (owe $0)', 8);
SELECT pg_temp.po_tpl('all_label',         'Payments overview — the total row',       'All', 9);
