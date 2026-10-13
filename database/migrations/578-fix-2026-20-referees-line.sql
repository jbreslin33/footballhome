-- 578: 2026.20's Referees line back to what its payments say.
--
-- The league-feed re-key bug (fixed in ce6de6b3) let the picker offer the
-- APSL 9/30 and Liga 1 10/4 games a second time after they were already
-- ticked, so the line's description named each game twice and its amount
-- ($521.75 for "4" games) drifted from the two payments actually recorded
-- ($310 + $130 = $440).  Rebuild the line from its own ref_fee_payments —
-- owner 2026-10-13: "your listing apsl and liga 1 2x for same games."

BEGIN;

UPDATE invoice_lines l
   SET quantity    = p.n,
       amount      = p.total,
       description = 'Referees — ' || p.games
  FROM (SELECT COUNT(*) AS n, SUM(rp.amount_usd) AS total,
               string_agg(pol.label || ' ' || to_char(rp.game_on, 'FMMM/FMDD') || ' ' || rp.opponent,
                          ', ' ORDER BY rp.game_on, rp.id) AS games
          FROM ref_fee_payments rp
          JOIN ref_fee_policies pol ON pol.id = rp.policy_id
         WHERE rp.invoice_line_id = 60) p
 WHERE l.id = 60 AND l.category = 'referees' AND p.n > 0 AND l.amount <> p.total;

COMMIT;
