-- 1885 (2026-11-24) — 🗻 3D pyramid: the UPSL's side next to the MLS column, the USL column after it.
-- Owner: "so weird that i see blank side where i assume upsl shold be" — on the APSL's (FIFA)
-- calendar the USL column (spring to fall) is empty, and it stood between MLS and the UPSL.  Now
-- the FIFA calendar's sides come together: 0 APSL · 1 MLS · 2 UPSL, then 3 USL · 4 NPSL · 5 League for Clubs.
UPDATE pro_leagues SET pyramid_side = 3 WHERE name IN ('USL Championship', 'USL League One', 'USL League Two');
UPDATE pro_leagues SET pyramid_side = 2 WHERE name = 'United Premier Soccer League';
