-- Migration 044: Add Brazil/Puerto Rico GroupMe chat integrations for calendar + RSVP sync

-- Chats linked to teams
INSERT INTO chats (id, team_id, name, chat_type_id, is_active)
SELECT 8, t.id, 'Brazil Trialists', 1, true
FROM teams t
WHERE t.name = 'Brazil' AND t.source_system_id = 5
ON CONFLICT (id) DO UPDATE SET
  team_id = EXCLUDED.team_id,
  name = EXCLUDED.name,
  chat_type_id = EXCLUDED.chat_type_id,
  is_active = true;

INSERT INTO chats (id, team_id, name, chat_type_id, is_active)
SELECT 9, t.id, 'Puerto Rico Trialists', 1, true
FROM teams t
WHERE t.name = 'Puerto Rico' AND t.source_system_id = 5
ON CONFLICT (id) DO UPDATE SET
  team_id = EXCLUDED.team_id,
  name = EXCLUDED.name,
  chat_type_id = EXCLUDED.chat_type_id,
  is_active = true;

-- GroupMe integrations
INSERT INTO chat_integrations
  (id, chat_id, provider_id, external_id, external_name, is_primary, sync_messages, sync_members, sync_events)
VALUES
  (8, 8, 1, '114866775', 'Brazil Trialists', true, false, false, true)
ON CONFLICT (id) DO UPDATE SET
  chat_id = EXCLUDED.chat_id,
  provider_id = EXCLUDED.provider_id,
  external_id = EXCLUDED.external_id,
  external_name = EXCLUDED.external_name,
  sync_events = true;

INSERT INTO chat_integrations
  (id, chat_id, provider_id, external_id, external_name, is_primary, sync_messages, sync_members, sync_events)
VALUES
  (9, 9, 1, '114866725', 'Puerto Rico Trialists', true, false, false, true)
ON CONFLICT (id) DO UPDATE SET
  chat_id = EXCLUDED.chat_id,
  provider_id = EXCLUDED.provider_id,
  external_id = EXCLUDED.external_id,
  external_name = EXCLUDED.external_name,
  sync_events = true;

-- Link chats to Lighthouse club for club-level visibility
INSERT INTO chat_clubs (chat_id, club_id)
SELECT 8, c.id FROM clubs c WHERE c.name = 'Lighthouse 1893 SC'
ON CONFLICT (chat_id, club_id) DO NOTHING;

INSERT INTO chat_clubs (chat_id, club_id)
SELECT 9, c.id FROM clubs c WHERE c.name = 'Lighthouse 1893 SC'
ON CONFLICT (chat_id, club_id) DO NOTHING;

-- Keep sequences ahead of explicit IDs
SELECT setval('chats_id_seq', GREATEST((SELECT COALESCE(MAX(id), 1) FROM chats), 1));
SELECT setval('chat_integrations_id_seq', GREATEST((SELECT COALESCE(MAX(id), 1) FROM chat_integrations), 1));
