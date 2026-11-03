-- 964-apsl-roster-job.sql
--
-- Owner 11/3: "apsl needs print roster and bring to game".  Added to the
-- APSL set and to the USASA Cup set, which mirrors APSL (mig 963).

INSERT INTO job_definitions (event_kind, league_label, slug, title, description, needed_count, toggleable, sort_order)
SELECT 'match', v.league_label, 'roster', 'Print roster', 'Print the roster and bring it to the game.', 1, false, 8
  FROM (VALUES ('APSL'), ('USASA Cup')) AS v(league_label)
 WHERE NOT EXISTS (SELECT 1 FROM job_definitions x
                    WHERE x.event_kind = 'match' AND x.league_label = v.league_label AND x.slug = 'roster');
