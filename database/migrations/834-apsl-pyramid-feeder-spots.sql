-- 834 (2026-10-29) — #apsl: every feeder promotes the same way.
--
-- Owner 2026-10-29: "so delaware river feeders should show green as 1st
-- place in each one, then 2nd through 5th yellow, then 6 to 10 white then
-- 11th orange and 12th red … do same for all feeders all over."
--
-- The up defaults (mig 828) no longer depend on how many feeders share the
-- level above: every table with a promoting link → 1st auto promotion,
-- 2nd–5th promotion playoff.  The "2 or more feeders → 1st auto promotion
-- playoff" default is dropped (the kind stays, for a table's own rows).
-- Down is unchanged: 11th relegation playoff, 12th relegation.
DELETE FROM pyramid_zone_rules
 WHERE source_id IS NULL AND direction = 'up' AND kind = 'auto_promotion_playoff';
UPDATE pyramid_zone_rules SET min_feeders = NULL, max_feeders = NULL,
       note = CASE kind WHEN 'auto_promotion' THEN 'champion goes up'
                        WHEN 'promotion_playoff' THEN '2nd–5th play off' ELSE note END
 WHERE source_id IS NULL AND direction = 'up';
