-- 962-women-game-jobs.sql
--
-- Owner 11/3: "make women like liga 1" — the women's games (league =
-- 'Tri County') get the same game-day set as Liga 1 (mig 960): lead the
-- non-ball warm-up, lead the ball warm-up, roster to the refs, pay the
-- refs (reimbursed).

INSERT INTO job_definitions (event_kind, league_label, slug, title, description, needed_count, toggleable, sort_order)
SELECT 'match', 'Tri County', d.slug, d.title, d.description, d.needed_count, d.toggleable, d.sort_order
  FROM job_definitions d
 WHERE d.event_kind = 'match' AND d.league_label = 'CASA'
   AND NOT EXISTS (SELECT 1 FROM job_definitions x
                    WHERE x.event_kind = 'match' AND x.league_label = 'Tri County' AND x.slug = d.slug);
