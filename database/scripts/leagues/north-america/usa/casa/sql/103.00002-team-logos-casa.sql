-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Team Logos - CASA (from SportsEngine API)
-- Source: https://se-api.sportsengine.com/v3/microsites/events
-- Reproducibility: Logos are extracted from match data, not manually curated
-- Total logos applied: 5
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

UPDATE teams SET logo_url = 'https://se-team-service-production.s3.amazonaws.com/uploads/team/logo/11f089c7-d6ce-f59e-a770-e61f3017bc57/large_square_85.png'
WHERE name = 'Phoenix SCR';
UPDATE teams SET logo_url = 'https://se-team-service-production.s3.amazonaws.com/uploads/team/logo/11f089c7-d68f-e4bc-a2a3-cabfdee30661/large_square_Lighthouse.png'
WHERE name = 'Lighthouse Boys Club U23';
UPDATE teams SET logo_url = 'https://se-team-service-production.s3.amazonaws.com/uploads/team/logo/11f089c7-d6be-f6b2-a2a6-cabfdee30661/large_square_PSC_II__1_.png'
WHERE name = 'Philadelphia SC Select';
UPDATE teams SET logo_url = 'https://se-team-service-production.s3.amazonaws.com/uploads/team/logo/11f089c7-d6b5-a12a-a76f-e61f3017bc57/large_square_Gemini_Generated_Image_h4esunh4esunh4es.png'
WHERE name = 'Persepolis FC II';
UPDATE teams SET logo_url = 'https://se-team-service-production.s3.amazonaws.com/uploads/team/logo/11f10c16-b122-1f5c-adba-aa423833d9df/large_square_Sewell_Old_Boys.png'
WHERE name = 'Sewell''s Old Boys ';
