-- 1269 (2026-11-11) — Drives of 5 minutes or less count as the same place
-- for schedule clashes (was 3, mig 526).
--
-- Owner 2026-11-11: "why do you have clash for saturday the sites are
-- super close lol".  Sat 11/14: youth practice at the Lighthouse Community
-- Center (Somerset St) ends 12:00; the men's practice at the Sport Complex
-- (Erie Ave) wants coaches at 12:00 (30 min lead).  The two are a 4.2 min
-- drive — over the 3 min "same place" line, so it became 4.2 × 1.25 + 10
-- min parking = 16 min and a clash.  5 min covers our two sites (and 18
-- other short hops); #my and the call-in plan line read it.

UPDATE schedule_conflict_policies SET same_place_minutes = 5 WHERE same_place_minutes < 5;
