-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Team Logos - CASA (from SportsEngine API)
-- Source: https://se-api.sportsengine.com/v3/microsites/events
-- Reproducibility: Logos are extracted from match data, not manually curated
-- Total logos applied: 13
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

UPDATE teams SET logo_url = 'https://se-team-service-production.s3.amazonaws.com/uploads/team/logo/11f089c6-38b5-2b86-a6ce-e61f3017bc57/large_square_84.png'
WHERE name = 'Philly BlackStars' AND source_system_id = 2;
UPDATE teams SET logo_url = 'https://se-team-service-production.s3.amazonaws.com/uploads/team/logo/11f089c6-38cd-1f48-b177-0ebac976a684/large_square_Illyrians.png'
WHERE name = 'Illyrians FC' AND source_system_id = 2;
UPDATE teams SET logo_url = 'https://se-team-service-production.s3.amazonaws.com/uploads/team/logo/11f089c6-38b9-b188-b2ff-ee90516ff737/large_square_Lighthouse.png'
WHERE name = 'Lighthouse Boys Club' AND source_system_id = 2;
UPDATE teams SET logo_url = 'https://se-team-service-production.s3.amazonaws.com/uploads/team/logo/11f089c6-38c1-d7e6-a6ce-e61f3017bc57/large_square_Oaklyn_United.png'
WHERE name = 'Oaklyn United FC II' AND source_system_id = 2;
UPDATE teams SET logo_url = 'https://se-team-service-production.s3.amazonaws.com/uploads/team/logo/11f089c6-38c5-ac0e-b177-0ebac976a684/large_square_85.png'
WHERE name = 'Phoenix SCM' AND source_system_id = 2;
UPDATE teams SET logo_url = 'https://se-team-service-production.s3.amazonaws.com/uploads/team/logo/11f089c6-38bb-1ffa-b177-0ebac976a684/large_square_Ade_United.png'
WHERE name = 'Adé United FC' AND source_system_id = 2;
UPDATE teams SET logo_url = 'https://se-team-service-production.s3.amazonaws.com/uploads/team/logo/11f089c6-38d6-b986-a6ce-e61f3017bc57/large_square_82.png'
WHERE name = 'Philadelphia Sierra Stars' AND source_system_id = 2;
UPDATE teams SET logo_url = 'https://se-team-service-production.s3.amazonaws.com/uploads/team/logo/11f0d9f4-b886-12d4-b185-9add99b5cd93/large_square_large_uncropped_Persepolis_United.png'
WHERE name = 'Persepolis FC' AND source_system_id = 2;
UPDATE teams SET logo_url = 'https://se-team-service-production.s3.amazonaws.com/uploads/team/logo/11f089c7-d6ce-f59e-a770-e61f3017bc57/large_square_85.png'
WHERE name = 'Phoenix SCR' AND source_system_id = 2;
UPDATE teams SET logo_url = 'https://se-team-service-production.s3.amazonaws.com/uploads/team/logo/11f089c7-d6be-f6b2-a2a6-cabfdee30661/large_square_PSC_II__1_.png'
WHERE name = 'Philadelphia SC Select' AND source_system_id = 2;
UPDATE teams SET logo_url = 'https://se-team-service-production.s3.amazonaws.com/uploads/team/logo/11f089c7-d68f-e4bc-a2a3-cabfdee30661/large_square_Lighthouse.png'
WHERE name = 'Lighthouse Boys Club U23' AND source_system_id = 2;
UPDATE teams SET logo_url = 'https://se-team-service-production.s3.amazonaws.com/uploads/team/logo/11f089c7-d6b5-a12a-a76f-e61f3017bc57/large_square_Gemini_Generated_Image_h4esunh4esunh4es.png'
WHERE name = 'Persepolis FC II' AND source_system_id = 2;
UPDATE teams SET logo_url = 'https://se-team-service-production.s3.amazonaws.com/uploads/team/logo/11f10c16-b122-1f5c-adba-aa423833d9df/large_square_Sewell_Old_Boys.png'
WHERE name = 'Sewell''s Old Boys ' AND source_system_id = 2;
