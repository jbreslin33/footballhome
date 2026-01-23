-- Organizations
-- Top-level entities that own leagues
-- 
-- This file contains manually-managed organizations.
-- DO NOT modify IDs - they are referenced throughout the database.

INSERT INTO organizations (id, name, slug, is_active) VALUES
(1, 'American Premier Soccer League', 'american-premier-soccer-league', true),
(2, 'CASA Soccer Leagues', 'casa-soccer-leagues', true),
(3, 'Cosmopolitan Soccer League', 'cosmopolitan-soccer-league', true),
(39, 'Lighthouse 1893 SC', 'lighthouse-1893-sc', true);

-- Update sequence
SELECT setval('organizations_id_seq', (SELECT MAX(id) FROM organizations));
