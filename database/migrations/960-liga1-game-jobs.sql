-- 960-liga1-game-jobs.sql
--
-- Owner 11/3: Liga 1 games (the Wednesday game and the rest) get jobs:
-- lead the non-ball warm-up, lead the ball warm-up, print the roster and
-- give it to the refs, pay the refs (reimbursed).  Liga 1 events carry
-- league = 'CASA', so this is the CASA game-day set (league_label scopes
-- it; the APSL set from mig 625 is untouched).

INSERT INTO job_definitions (event_kind, league_label, slug, title, description, needed_count, toggleable, sort_order)
SELECT v.* FROM (VALUES
    ('match', 'CASA', 'warmup',      'Warm-up (no ball)', 'Lead the non-ball warm-up.', 1, false, 1),
    ('match', 'CASA', 'ball-warmup', 'Warm-up (ball)',    'Lead the ball warm-up.', 1, false, 2),
    ('match', 'CASA', 'roster',      'Roster to refs',    'Print the roster and give it to the referees before kickoff.', 1, false, 3),
    ('match', 'CASA', 'pay-refs',    'Pay refs',          'Pay the referees — you get reimbursed.', 1, false, 4)
) AS v(event_kind, league_label, slug, title, description, needed_count, toggleable, sort_order)
WHERE NOT EXISTS (SELECT 1 FROM job_definitions d
                   WHERE d.event_kind = v.event_kind AND COALESCE(d.league_label,'') = COALESCE(v.league_label,'') AND d.slug = v.slug);
