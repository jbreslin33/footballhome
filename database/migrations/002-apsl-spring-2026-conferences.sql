-- Migration 002: Add APSL Spring 2026 conferences and divisions
--
-- APSL added 3 new conferences for the 2025/2026 season:
--   - Mid-Atlantic Conference Fall (split from Mid-Atlantic Conference)
--   - Mid-Atlantic Conference Spring (split from Mid-Atlantic Conference)
--   - Mitten Conference (new)
--
-- The scraper auto-upserts conferences, but divisions are manually managed.
-- This migration adds the matching divisions.

-- Conferences (may already exist from scraper — use ON CONFLICT)
INSERT INTO conferences (id, season_id, name, source_system_id, external_id) VALUES
(36, 1, 'Mid-Atlantic Conference Fall', 1, '17826'),
(37, 1, 'Mid-Atlantic Conference Spring', 1, '17050'),
(39, 1, 'Mitten Conference', 1, '22958')
ON CONFLICT (id) DO UPDATE SET
    name = EXCLUDED.name,
    external_id = EXCLUDED.external_id;

-- Divisions (one per conference — APSL business rule)
INSERT INTO divisions (id, season_id, conference_id, name, source_system_id) VALUES
(67, 1, 36, 'Mid-Atlantic Conference Fall', 1),
(68, 1, 37, 'Mid-Atlantic Conference Spring', 1),
(69, 1, 39, 'Mitten Conference', 1)
ON CONFLICT (id) DO NOTHING;

-- Update sequences to highest ID
SELECT setval('conferences_id_seq', (SELECT MAX(id) FROM conferences));
SELECT setval('divisions_id_seq', (SELECT MAX(id) FROM divisions));
