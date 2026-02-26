-- Persons (Core Identity) - Bootstrap Data
-- Only manually-created persons (admin/user accounts).
-- All scraped players are created by per-league SQL generators (make load).
--
-- ARCHITECTURE: Auto-gen IDs with UNIQUE(first_name, last_name).
-- Same name = same person across all sources (curation overrides via name change).

-- James Breslin (admin/user — person_id=1)
INSERT INTO persons (id, first_name, last_name, birth_date) VALUES
  (1, 'James', 'Breslin', '1985-06-15')
ON CONFLICT (id) DO NOTHING;

-- Reset sequence to account for manually-assigned IDs
SELECT setval('persons_id_seq', (SELECT COALESCE(MAX(id), 1) FROM persons));
