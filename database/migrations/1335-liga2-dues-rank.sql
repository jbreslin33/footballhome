-- 1335 (2026-11-13): Liga 2 carries dues like Liga 1, so its 35 roster spots
-- count toward full house on the Year plan (next year, and this spring when
-- the option is on).  Ranked under Liga 1 (10) and APSL (20).
UPDATE teams SET dues_rank = 5 WHERE name = 'Lighthouse Mens Club Liga 2' AND dues_rank IS NULL;
INSERT INTO schema_migrations (filename) VALUES ('1335-liga2-dues-rank.sql') ON CONFLICT DO NOTHING;
