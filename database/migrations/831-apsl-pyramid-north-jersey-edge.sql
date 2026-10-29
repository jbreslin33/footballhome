-- 831 (2026-10-29) — #apsl: CASA North Jersey on the right edge of the
-- Delaware River feeder row.
--
-- Owner 2026-10-29: "move north jersey to edge so closer than central to
-- metro conference" — its Liga 1 links into Delaware River AND
-- Metropolitan (the next column to the right), so it sits last in the row.
UPDATE pyramid_competitions SET sort_order = 40
 WHERE kind = 'affiliate' AND name = 'CASA Select North Jersey';
