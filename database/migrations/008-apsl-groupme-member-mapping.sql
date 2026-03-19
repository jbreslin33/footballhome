-- Migration 008: APSL GroupMe member mapping & non-player exclusions
-- Fixes person records, maps GroupMe nicknames → persons in chat_event_rsvps,
-- creates chat_non_players table for excluding admins/managers from lineup pool.

BEGIN;

-- ============================================================================
-- 1. Fix incomplete person records from migration 005
-- ============================================================================
UPDATE persons SET last_name = 'Maldonado'
  WHERE first_name = 'Gian' AND last_name = '' AND NOT EXISTS (
    SELECT 1 FROM persons WHERE first_name = 'Gian' AND last_name = 'Maldonado'
  );

UPDATE persons SET last_name = 'Donza'
  WHERE first_name = 'Musa' AND last_name = '' AND NOT EXISTS (
    SELECT 1 FROM persons WHERE first_name = 'Musa' AND last_name = 'Donza'
  );

-- ============================================================================
-- 2. Create persons not yet in DB
-- ============================================================================
INSERT INTO persons (first_name, last_name) VALUES
  ('Christopher', 'Braz')
ON CONFLICT (first_name, last_name) DO NOTHING;

INSERT INTO players (person_id, source_system_id)
SELECT pe.id, 4
FROM persons pe
WHERE pe.first_name = 'Christopher' AND pe.last_name = 'Braz'
  AND NOT EXISTS (SELECT 1 FROM players p WHERE p.person_id = pe.id);

-- ============================================================================
-- 3. Map GroupMe nicknames → person_id in existing chat_event_rsvps
-- ============================================================================
DO $$
DECLARE
  mapping RECORD;
BEGIN
  FOR mapping IN
    SELECT * FROM (VALUES
      ('The Prince Momo',   'Amadou',      'Kamagate'),
      ('Abdoulaye',         'Abdoulaye',   'Kamagate'),
      ('Amar',              'Amar',        'Abdelrazek'),
      ('Arsene',            'Arsene',      'Bado'),
      ('Bility',            'Mohamed',     'Bility'),
      ('Bility⚽️',          'Mohamed',     'Bility'),
      ('Christopher',       'Christopher', 'Braz'),
      ('Erwa',              'Erwa',        'Babiker'),
      ('Gian',              'Gian',        'Maldonado'),
      ('Jazz M.',           'Mohamed',     'Khalafalla'),
      ('Musa',              'Musa',        'Donza'),
      ('VictorB',           'Victor',      'Baidel'),
      ('Walter',            'Walter',      'Candido')
    ) AS t(nickname, fname, lname)
  LOOP
    UPDATE chat_event_rsvps cer
    SET person_id = pe.id
    FROM persons pe
    WHERE pe.first_name = mapping.fname
      AND pe.last_name = mapping.lname
      AND cer.external_username = mapping.nickname
      AND cer.person_id IS NULL
      AND NOT EXISTS (
        SELECT 1 FROM chat_event_rsvps dup
        WHERE dup.chat_event_id = cer.chat_event_id
          AND dup.person_id = pe.id
      );
  END LOOP;
END $$;

-- ============================================================================
-- 4. Create chat_non_players table & populate
-- ============================================================================
CREATE TABLE IF NOT EXISTS chat_non_players (
  id SERIAL PRIMARY KEY,
  person_id INTEGER REFERENCES persons(id) ON DELETE CASCADE,
  external_username VARCHAR(255),
  reason VARCHAR(50) NOT NULL DEFAULT 'admin',
  notes TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(person_id),
  UNIQUE(external_username)
);

COMMENT ON TABLE chat_non_players IS 'GroupMe chat members who should be excluded from the lineup player pool (admins, managers, non-players)';

INSERT INTO chat_non_players (external_username, reason, notes) VALUES
  ('James Breslin',             'admin',   'Club admin'),
  ('Anthony Acevedo',           'admin',   'Team manager'),
  ('Cristian Alberto Paredes',  'other',   'Non-player member'),
  ('Darlensky',                 'other',   'Non-player member'),
  ('Rancy Mohamed Mahgoub',     'other',   'Non-player member')
ON CONFLICT (external_username) DO NOTHING;

UPDATE chat_non_players cnp
SET person_id = pe.id
FROM persons pe
WHERE cnp.external_username = 'James Breslin'
  AND pe.first_name = 'James' AND pe.last_name = 'Breslin'
  AND cnp.person_id IS NULL;

-- ============================================================================
-- 5. Create chat_external_members table (persists GroupMe group membership)
-- ============================================================================
CREATE TABLE IF NOT EXISTS chat_external_members (
  chat_id INTEGER NOT NULL REFERENCES chats(id) ON DELETE CASCADE,
  provider_id INTEGER NOT NULL REFERENCES chat_providers(id),
  external_user_id VARCHAR(255) NOT NULL,
  external_username VARCHAR(255),
  person_id INTEGER REFERENCES persons(id) ON DELETE SET NULL,
  synced_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (chat_id, provider_id, external_user_id)
);

CREATE INDEX IF NOT EXISTS idx_chat_external_members_person ON chat_external_members(person_id) WHERE person_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_chat_external_members_chat ON chat_external_members(chat_id);

COMMIT;
