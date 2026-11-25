-- 1884 (2026-11-24) — The UPSL's calendar is the APSL's.  Owner: "so weird that i see blank side
-- where i assume upsl shold be. its a spring to fall league" · "its ame as apsl".  It was briefly
-- moved to spring_fall in this migration's first version; it stays on the APSL root's calendar
-- (pyramid_competitions.calendar for slug 'apsl'), so it is always on the same pyramid as the APSL.
-- UPSL Division 1 follows its upper league.
UPDATE pro_leagues l SET calendar = c.calendar
  FROM pyramid_competitions c
 WHERE l.name = 'United Premier Soccer League' AND c.slug = 'apsl' AND c.parent_id IS NULL
   AND l.calendar IS DISTINCT FROM c.calendar;
