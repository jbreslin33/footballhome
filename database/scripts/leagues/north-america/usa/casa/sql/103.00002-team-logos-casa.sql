-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Team Logos - CASA (from SportsEngine API)
-- Source: https://se-api.sportsengine.com/v3/microsites/events
-- Reproducibility: Logos are extracted from match data, not manually curated
-- Total logos applied: 8
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

UPDATE teams SET logo_url = 'https://se-team-service-production.s3.amazonaws.com/uploads/team/logo/11f089c6-38b9-b188-b2ff-ee90516ff737/large_square_Lighthouse.png'
WHERE name = 'Lighthouse Boys Club';
UPDATE teams SET logo_url = 'https://se-team-service-production.s3.amazonaws.com/uploads/team/logo/11f089c6-38c1-d7e6-a6ce-e61f3017bc57/large_square_Oaklyn_United.png'
WHERE name = 'Oaklyn United FC II';
UPDATE teams SET logo_url = 'https://se-team-service-production.s3.amazonaws.com/uploads/team/logo/11f089c6-38cd-1f48-b177-0ebac976a684/large_square_Illyrians.png'
WHERE name = 'Illyrians FC';
UPDATE teams SET logo_url = 'https://se-team-service-production.s3.amazonaws.com/uploads/team/logo/11f089c6-38bb-1ffa-b177-0ebac976a684/large_square_Ade_United.png'
WHERE name = 'Adé United FC';
UPDATE teams SET logo_url = 'https://se-team-service-production.s3.amazonaws.com/uploads/team/logo/11f089c6-38d6-b986-a6ce-e61f3017bc57/large_square_82.png'
WHERE name = 'Philadelphia Sierra Stars';
UPDATE teams SET logo_url = 'https://se-team-service-production.s3.amazonaws.com/uploads/team/logo/11f0d9f4-b886-12d4-b185-9add99b5cd93/large_square_large_uncropped_Persepolis_United.png'
WHERE name = 'Persepolis FC';
UPDATE teams SET logo_url = 'https://se-team-service-production.s3.amazonaws.com/uploads/team/logo/11f089c6-38b5-2b86-a6ce-e61f3017bc57/large_square_84.png'
WHERE name = 'Philly BlackStars';
UPDATE teams SET logo_url = 'https://se-team-service-production.s3.amazonaws.com/uploads/team/logo/11f089c6-38c5-ac0e-b177-0ebac976a684/large_square_85.png'
WHERE name = 'Phoenix SCM';
