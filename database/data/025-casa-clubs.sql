-- Clubs
INSERT INTO clubs (id, display_name, slug, source_system_id, is_active)
VALUES
  (1, 'Ad', 'ad', 2, true),
  (2, 'Oaklyn', 'oaklyn', 2, true),
  (3, 'Philadelphia Sierra Stars', 'philadelphia-sierra-stars', 2, true),
  (4, 'Persepolis', 'persepolis', 2, true),
  (5, 'Phoenix Scm', 'phoenix-scm', 2, true),
  (6, 'Philly Blackstars', 'philly-blackstars', 2, true),
  (7, 'Illyrians', 'illyrians', 2, true),
  (8, 'Lighthouse Boys', 'lighthouse-boys', 2, true),
  (9, 'Futbol Armada', 'futbol-armada', 2, true)
ON CONFLICT (id) DO UPDATE SET
  display_name = EXCLUDED.display_name,
  slug = EXCLUDED.slug,
  source_system_id = EXCLUDED.source_system_id,
  is_active = EXCLUDED.is_active;
