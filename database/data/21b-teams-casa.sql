-- CASA Teams

INSERT INTO teams (id, division_id, name, display_name, city, state, logo_url, source_system_id, external_id, page_node_id)
VALUES
  (1, 1, 'Adé United FC', 'Adé United FC', NULL, NULL, NULL, 2, '68b9e9d8c557f500fc9757a0', '68b9e9d8c557f500fc9757a0'),
  (2, 1, 'Oaklyn United FC II', 'Oaklyn United FC II', NULL, NULL, NULL, 2, '68b9e9d9fa1e910177ec564d', '68b9e9d9fa1e910177ec564d'),
  (3, 1, 'Philadelphia Sierra Stars', 'Philadelphia Sierra Stars', NULL, NULL, NULL, 2, '68b9e9d91ff01d00fc20f616', '68b9e9d91ff01d00fc20f616'),
  (4, 1, 'Persepolis FC', 'Persepolis FC', NULL, NULL, NULL, 2, '69406f99797af1d33f398d2e', '69406f99797af1d33f398d2e'),
  (5, 1, 'Phoenix SCM', 'Phoenix SCM', NULL, NULL, NULL, 2, '68b9e9d9b3eb08013b7559cd', '68b9e9d9b3eb08013b7559cd'),
  (6, 1, 'Philly BlackStars', 'Philly BlackStars', NULL, NULL, NULL, 2, '68b9e9d8b3eb0800fd755c9c', '68b9e9d8b3eb0800fd755c9c'),
  (7, 1, 'Illyrians FC', 'Illyrians FC', NULL, NULL, NULL, 2, '68b9e9d8fa1e9100fbec60d4', '68b9e9d8fa1e9100fbec60d4'),
  (8, 1, 'Lighthouse Boys Club', 'Lighthouse Boys Club', NULL, NULL, NULL, 2, '68b9e9d81f736301382e6ee1', '68b9e9d81f736301382e6ee1'),
  (9, 2, 'Persepolis United FC II', 'Persepolis United FC II', NULL, NULL, NULL, 2, '68b9ec8f562f54017935a21b', '68b9ec8f562f54017935a21b'),
  (10, 2, 'Phoenix SCR', 'Phoenix SCR', NULL, NULL, NULL, 2, '68b9ec8f562f5400fd35a5dc', '68b9ec8f562f5400fd35a5dc'),
  (11, 2, 'Philadelphia SC II', 'Philadelphia SC II', NULL, NULL, NULL, 2, '68b9ec8fb3eb08013b755a47', '68b9ec8fb3eb08013b755a47'),
  (12, 2, 'Lighthouse Old Timers Club', 'Lighthouse Old Timers Club', NULL, NULL, NULL, 2, '68b9ec8fb3eb0800fd755db8', '68b9ec8fb3eb0800fd755db8'),
  (13, 2, 'Club de Futbol Armada', 'Club de Futbol Armada', NULL, NULL, NULL, 2, '68b9ec8f1ff01d00fc20f6d3', '68b9ec8f1ff01d00fc20f6d3')
ON CONFLICT (id) DO UPDATE SET
  division_id = EXCLUDED.division_id,
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  city = EXCLUDED.city,
  state = EXCLUDED.state,
  logo_url = EXCLUDED.logo_url,
  source_system_id = EXCLUDED.source_system_id,
  external_id = EXCLUDED.external_id,
  page_node_id = EXCLUDED.page_node_id
;

