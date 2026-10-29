-- 854 (2026-10-29) — #apsl-pyramid map HUD: the median Sunday drive.
--
-- Owner 2026-10-29: "add median drive" — next to the furthest pair and the
-- all-play-all average (mig 852): the middle trip of every club pair, which
-- a few far-flung clubs can't drag the way they drag the average.  Cached
-- rows without it are re-computed on the next look.
ALTER TABLE pyramid_conference_travel ADD COLUMN IF NOT EXISTS median_minutes numeric;

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'APSL pyramid', 'APSL pyramid — map HUD: median drive', 'apsl_pyramid', 'map_median', NULL, 'Median drive: {time}', 153, true, true, false
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'apsl_pyramid' AND m.tier = 'map_median');
