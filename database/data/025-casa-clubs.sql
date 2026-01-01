-- Clubs
INSERT INTO clubs (id, display_name, slug, source_system_id, is_active)
VALUES
  (1, 'Persepolis', 'persepolis', 2, true),
  (2, 'Phoenix Scr', 'phoenix-scr', 2, true),
  (3, 'Philadelphia', 'philadelphia', 2, true),
  (4, 'Lighthouse Old Timers', 'lighthouse-old-timers', 2, true),
  (5, 'Futbol Armada', 'futbol-armada', 2, true),
  (6, 'Philly Black Stars', 'philly-black-stars', 2, true),
  (7, 'Oaklyn United Nor Easters', 'oaklyn-united-nor-easters', 2, true),
  (8, 'Illyrians', 'illyrians', 2, true),
  (9, 'Ade', 'ade', 2, true)
ON CONFLICT (id) DO UPDATE SET
  display_name = EXCLUDED.display_name,
  slug = EXCLUDED.slug,
  source_system_id = EXCLUDED.source_system_id,
  is_active = EXCLUDED.is_active;
