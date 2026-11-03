-- 963-cup-game-jobs.sql
--
-- Owner 11/3: "cups are like apsl games" — USASA Cup games (league =
-- 'USASA Cup') get the APSL game-day set from mig 625: sub cards,
-- warm-ups, goalie warm-up, tents (toggleable), water, bench discipline.

INSERT INTO job_definitions (event_kind, league_label, slug, title, description, needed_count, toggleable, sort_order)
SELECT 'match', 'USASA Cup', d.slug, d.title, d.description, d.needed_count, d.toggleable, d.sort_order
  FROM job_definitions d
 WHERE d.event_kind = 'match' AND d.league_label = 'APSL' AND d.is_active
   AND NOT EXISTS (SELECT 1 FROM job_definitions x
                    WHERE x.event_kind = 'match' AND x.league_label = 'USASA Cup' AND x.slug = d.slug);
