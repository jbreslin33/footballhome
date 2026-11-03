-- 995 (2026-11-03) — APSL 10/4 at Persepolis United was an away game: no
-- referee fee.  Owner 2026-11-03: "persepolis was away. ve home".  Its $310
-- tick comes off James's 2026.20 Referees line (draft), and the line is
-- rebuilt from the games still ticked on it (Expenses::syncRefLine's rule).
BEGIN;
DELETE FROM ref_fee_payments r
 USING invoice_lines l, invoices i
 WHERE r.id = 13 AND r.policy_id = 1 AND r.game_on = '2026-10-04' AND r.opponent = 'Persepolis United FC'
   AND l.id = r.invoice_line_id AND i.id = l.invoice_id AND NOT i.is_final;
UPDATE invoice_lines l
   SET quantity = 1, rate = p.total, amount = p.total, description = 'Referees — ' || p.games
  FROM (SELECT SUM(g.n) AS n, SUM(g.total) AS total,
               string_agg(g.lbl || CASE WHEN g.n > 1 THEN ' ×' || g.n ELSE '' END, ', ' ORDER BY g.so, g.lbl) AS games
          FROM (SELECT regexp_replace(pol.label, '^Parks & Rec ', '') AS lbl, COUNT(*) AS n, SUM(rp.amount_usd) AS total, MIN(pol.sort_order) AS so
                  FROM ref_fee_payments rp JOIN ref_fee_policies pol ON pol.id = rp.policy_id
                 WHERE rp.invoice_line_id = 60 GROUP BY 1) g) p
 WHERE l.id = 60 AND p.n > 0;
UPDATE invoices SET updated_at = now() WHERE id = (SELECT invoice_id FROM invoice_lines WHERE id = 60);
COMMIT;
