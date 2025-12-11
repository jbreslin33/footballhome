-- ========================================
-- CASA CLUBS
-- ========================================
-- Generated: 2025-12-11T13:48:43.929Z
-- Source: CASA Website
-- ========================================

INSERT INTO clubs (id, name, display_name, slug, is_active)
VALUES ('555c3845-32c1-4d0f-8408-a73af2d063f1', 'Lighthouse Boys Club', 'Lighthouse Boys Club', 'lighthouse-boys-club', true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO clubs (id, name, display_name, slug, is_active)
VALUES ('98645582-efe3-434f-8351-23e3a35453c8', 'Lighthouse Old Timers', 'Lighthouse Old Timers', 'lighthouse-old-timers', true)
ON CONFLICT (id) DO NOTHING;
