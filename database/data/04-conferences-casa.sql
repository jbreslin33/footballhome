-- ========================================
-- CASA CONFERENCES
-- ========================================
-- Generated: 2025-12-13T19:43:19.616Z
-- Source: CASA Website
-- ========================================

INSERT INTO league_conferences (id, league_id, name, display_name, slug, is_active)
VALUES ('782605fe-f106-4307-8e6b-34bdb5c6df87', '00000000-0000-0000-0001-000000000002', 'CASA Conference', 'CASA Conference', 'casa-conference', true)
ON CONFLICT (id) DO NOTHING;
