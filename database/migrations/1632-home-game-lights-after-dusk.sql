-- 1632 (2026-11-20) — Home games get the lights + generator jobs past dusk too.
--
-- Owner 11/20: "home games right now are always daylight but do same check"
-- + "away games of course no light or gen jobs".
--
-- The three after-dark field jobs (mig 1631) for a match: home only
-- (venue 'home'), at the Sport Complex field (facility 1, no spot), any
-- league, only when the game ends after civil dusk.  Away games never get
-- them — the venue rule leaves them out.

INSERT INTO job_definitions (event_kind, slug, title, description, needed_count, facility_id, venue, after_dark, sort_order)
SELECT 'match', d.slug, d.title, d.description, d.needed_count, 1, 'home', true, 100 + d.sort_order
  FROM job_definitions d
 WHERE d.event_kind = 'practice' AND d.facility_id = 1 AND d.spot_id IS NULL AND d.after_dark
ON CONFLICT DO NOTHING;
