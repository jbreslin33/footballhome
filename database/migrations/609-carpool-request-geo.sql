-- 609 (2026-10-19) — Carpool pickup geocode cache on the request row.
--
-- Companion to mig 608.  A ride request's pickup address is a SNAPSHOT
-- (may be "grandma's", not the rider's person_addresses row), so its
-- coordinates are cached on the request itself: geocoded once (Nominatim)
-- when the request is created, backfilled lazily by the options/nudge
-- endpoints when older rows lack it.  A geocode failure is noted and not
-- re-asked.

ALTER TABLE fh_carpool_requests ADD COLUMN IF NOT EXISTS pickup_lat numeric(10,7);
ALTER TABLE fh_carpool_requests ADD COLUMN IF NOT EXISTS pickup_lon numeric(10,7);
ALTER TABLE fh_carpool_requests ADD COLUMN IF NOT EXISTS pickup_geocoded_at timestamptz;
ALTER TABLE fh_carpool_requests ADD COLUMN IF NOT EXISTS pickup_geocode_note text;

-- The agreed plan's detour minutes, stored at accept so the card can say
-- "+N min" forever without recomputing (same number the driver saw).
ALTER TABLE fh_carpool_requests ADD COLUMN IF NOT EXISTS meet_extra_minutes integer;
