-- Leagues
-- Leagues belong to organizations
-- 
-- This file contains manually-managed leagues.
-- DO NOT modify IDs - they are referenced throughout the database.

INSERT INTO leagues (id, organization_id, name, slug, is_active) VALUES
(1, 1, 'American Premier Soccer League', 'american-premier-soccer-league', true),
(2, 2, 'CASA Select', 'casa-select', true),
(3, 2, 'CASA Traditional', 'casa-traditional', true),
(4, 3, 'Cosmopolitan Soccer League', 'cosmopolitan-soccer-league', true);

-- Update sequence
SELECT setval('leagues_id_seq', (SELECT MAX(id) FROM leagues));
