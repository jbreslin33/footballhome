-- 580: men's game-coaching projects at James's $20/h, not the coaches' $15.
--
-- Owner 2026-10-13: "coaching is 15 an hour. my coaching is 20 an hour.
-- refs are diff."  Invoices already bill hours × the issuer's rate (James
-- $20, Luke/Jamie/Anthony $15); a coaching policy's per_game_usd only feeds
-- the #finances cost projection.  APSL and Liga 1 are James's games, but
-- their per_game_usd sat at hours × $15 — re-derive at $20/h (APSL 3 h →
-- $60, Liga 1 2.45 h → $49).  The youth and Tri County policies stay at
-- hours × $15, matching their coaches' rate.

BEGIN;

UPDATE ref_fee_policies
   SET per_game_usd = ROUND(hours_per_game * 20.00, 2)
 WHERE kind = 'coaching' AND label IN ('APSL', 'Liga 1')
   AND per_game_usd = ROUND(hours_per_game * 15.00, 2);

COMMIT;
