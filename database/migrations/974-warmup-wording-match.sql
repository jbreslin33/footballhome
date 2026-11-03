-- 974-warmup-wording-match.sql
--
-- Owner 11/3: "make the warm-up wording match" — the APSL and USASA Cup
-- sets said "Conduct the … warm-up"; Liga 1 / women (migs 960, 962) say
-- "Lead the … warm-up".  All sets now say "Lead".

UPDATE job_definitions SET description = 'Lead the non-ball warm-up.'
 WHERE event_kind = 'match' AND slug = 'warmup' AND description = 'Conduct the non-ball warm-up.';

UPDATE job_definitions SET description = 'Lead the ball warm-up.'
 WHERE event_kind = 'match' AND slug = 'ball-warmup' AND description = 'Conduct the ball warm-up.';
