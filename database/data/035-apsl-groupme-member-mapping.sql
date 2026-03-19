-- ============================================================================
-- APSL GroupMe Chat: Non-player Exclusions & New Persons
-- Loaded during container init (make build / make rebuild).
-- ============================================================================

-- ============================================================================
-- 1. Create persons not yet on any roster (GroupMe-only players)
-- ============================================================================
INSERT INTO persons (first_name, last_name) VALUES
  ('Christopher', 'Braz')
ON CONFLICT (first_name, last_name) DO NOTHING;

-- Create player record for Christopher Braz (source_system_id=4 = GroupMe)
INSERT INTO players (person_id, source_system_id)
SELECT pe.id, 4
FROM persons pe
WHERE pe.first_name = 'Christopher' AND pe.last_name = 'Braz'
  AND NOT EXISTS (SELECT 1 FROM players p WHERE p.person_id = pe.id);

-- ============================================================================
-- 2. Non-players: people in APSL GroupMe who are NOT lineup candidates
--    (admins, managers, family). The eligibility engine checks this table
--    to exclude them from the player pool.
-- ============================================================================
INSERT INTO chat_non_players (external_username, reason, notes) VALUES
  ('James Breslin',             'admin',   'Club admin'),
  ('Anthony Acevedo',           'admin',   'Team manager'),
  ('Cristian Alberto Paredes',  'other',   'Non-player member'),
  ('Darlensky',                 'other',   'Non-player member'),
  ('Rancy Mohamed Mahgoub',     'other',   'Non-player member')
ON CONFLICT (external_username) DO NOTHING;

-- Link James Breslin by person_id
UPDATE chat_non_players cnp
SET person_id = pe.id
FROM persons pe
WHERE cnp.external_username = 'James Breslin'
  AND pe.first_name = 'James' AND pe.last_name = 'Breslin'
  AND cnp.person_id IS NULL;
