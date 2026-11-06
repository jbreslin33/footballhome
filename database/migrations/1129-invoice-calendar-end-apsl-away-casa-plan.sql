-- Owner 2026-11-06, three answers on James's invoices:
--  1. "gcal informs fh and in turn fh informs the hours on invoice" — the draft
--     calendar check followed a moved START only, so a shortened practice kept
--     its old end (11/3 u16+ billed to 20:45, calendar 20:30).  Practice and
--     claimed rows now remember the calendar end they were built with
--     (cal_end_at); Invoice::realityCheck moves an untouched end with the
--     calendar, a hand-edited end stays.  Games bill policy hours — NULL here.
--  2. "apsl we don't pay refs for away games" — APSL bill_home_only; the
--     11/5 at Vidas $310 comes off 2026.22's Referees line.
--  3. 2026.23's two CASA registration plans become one: CASA Player
--     Registrations $339.26 (plan 16) + CASA Player Add fees $168.64 (plan 15)
--     = $507.90 in 2 payments, $253.95 on 2026.23 and $253.95 on 2026.24.
BEGIN;

-- 1 ─────────────────────────────────────────────────────────────────────────
ALTER TABLE invoice_work_shifts ADD COLUMN IF NOT EXISTS cal_end_at time;
COMMENT ON COLUMN invoice_work_shifts.cal_end_at IS
  'Calendar end this practice/claimed row was built with (mig 1129). end_at = cal_end_at means untouched: the row follows the calendar end. NULL for games and hand rows.';

-- Untouched rows on drafts: their end equals the calendar end today.
UPDATE invoice_work_shifts s
   SET cal_end_at = s.end_at
  FROM invoices i, gcal_events g
 WHERE i.id = s.invoice_id AND NOT i.is_final
   AND s.end_at IS NOT NULL
   AND g.id = COALESCE((SELECT e.gcal_event_id FROM fh_events e WHERE e.id = s.fh_event_id AND e.kind <> 'match'),
                       s.gcal_event_id)
   AND s.end_at = (g.ends_at AT TIME ZONE 'America/New_York')::time;

-- 2026.22 Tue 11/3 u16+: calendar ends 20:30 (was billed to 20:45).
UPDATE invoice_work_shifts
   SET end_at = '20:30', cal_end_at = '20:30'
 WHERE id = 240 AND invoice_id = 20 AND work_date = '2026-11-03' AND end_at = '20:45';

UPDATE invoice_lines l
   SET quantity = h.hours, amount = ROUND(h.hours * l.rate, 2)
  FROM (SELECT ROUND(SUM(COALESCE(hours, EXTRACT(EPOCH FROM (end_at - start_at)) / 3600.0))::numeric, 2) AS hours
          FROM invoice_work_shifts WHERE invoice_id = 20) h
 WHERE l.invoice_id = 20 AND l.category = 'labor' AND l.rate IS NOT NULL;

-- 2 ─────────────────────────────────────────────────────────────────────────
UPDATE ref_fee_policies SET bill_home_only = true WHERE kind = 'referee' AND label = 'APSL';

DELETE FROM ref_fee_payments WHERE id = 47 AND invoice_line_id = 92 AND league_fixture_id = 33287;

-- Expenses::syncRefLine, same SQL.
UPDATE invoice_lines l
   SET quantity = 1, rate = p.total, amount = p.total, description = 'Referees — ' || p.games
  FROM (SELECT SUM(g.n) AS n, SUM(g.total) AS total,
               string_agg(g.lbl || CASE WHEN g.n > 1 THEN ' ×' || g.n ELSE '' END, ', ' ORDER BY g.so, g.lbl) AS games
          FROM (SELECT regexp_replace(pol.label, '^Parks & Rec ', '') AS lbl,
                       COUNT(*) AS n, SUM(rp.amount_usd) AS total, MIN(pol.sort_order) AS so
                  FROM ref_fee_payments rp JOIN ref_fee_policies pol ON pol.id = rp.policy_id
                 WHERE rp.invoice_line_id = 92
                 GROUP BY 1) g) p
 WHERE l.id = 92 AND p.n > 0;

-- 3 ─────────────────────────────────────────────────────────────────────────
UPDATE invoice_installment_plans SET total_amount = 507.90
 WHERE id = 16 AND total_amount = 339.26 AND installment_count = 2;
UPDATE invoice_lines SET rate = 253.95, amount = 253.95
 WHERE id = 84 AND invoice_id = 24 AND plan_id = 16 AND installment_no = 1;
DELETE FROM invoice_lines WHERE id = 96 AND invoice_id = 24 AND plan_id = 15 AND installment_no = 1;
DELETE FROM invoice_installment_plans p WHERE p.id = 15 AND NOT EXISTS (SELECT 1 FROM invoice_lines l WHERE l.plan_id = 15);

UPDATE invoices SET updated_at = now() WHERE id IN (20, 24);
COMMIT;
