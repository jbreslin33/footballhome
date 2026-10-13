-- 579: U12 referee fee is $35, not $30.
--
-- Owner 2026-10-13: "ref fees are 25 for u8 and u10 and 35 for u12" (and,
-- asked which number stands: "use what i said originally about ref fees").
-- U8/U10 already sit at $25; only the U12 referee policy moves.  The U12
-- COACHING policy ($30) is coach pay, not a ref fee, and stays.

BEGIN;

UPDATE ref_fee_policies
   SET per_game_usd = 35.00
 WHERE kind = 'referee' AND age_band = 'U12' AND per_game_usd = 30.00;

COMMIT;
