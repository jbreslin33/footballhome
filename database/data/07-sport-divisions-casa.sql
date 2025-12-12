-- ========================================
-- CASA SPORT DIVISIONS
-- ========================================
-- Generated: 2025-12-12T17:51:01.197Z
-- Source: CASA Website
-- ========================================

INSERT INTO sport_divisions (id, club_id, sport_id, name, display_name, slug, is_active)
VALUES ('7edd10c4-c7d4-447a-8446-595226c325b8', '555c3845-32c1-4d0f-8408-a73af2d063f1', '550e8400-e29b-41d4-a716-446655440101', 'Lighthouse Boys Club', 'Lighthouse Boys Club', 'lighthouse-boys-club', true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO sport_divisions (id, club_id, sport_id, name, display_name, slug, is_active)
VALUES ('0915072e-e2c9-46fe-81f0-8da72c286a4b', '98645582-efe3-434f-8351-23e3a35453c8', '550e8400-e29b-41d4-a716-446655440101', 'Lighthouse Old Timers', 'Lighthouse Old Timers', 'lighthouse-old-timers', true)
ON CONFLICT (id) DO NOTHING;
