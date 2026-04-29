-- ============================================================================
-- Chat Configuration: chats, integrations, and club mappings
-- Loaded during container init. Idempotent (ON CONFLICT safe).
-- ============================================================================

-- ============================================================================
-- 1. Chats (GroupMe groups linked to teams)
-- ============================================================================

-- APSL Lighthouse (team chat)
INSERT INTO chats (id, team_id, name, chat_type_id, is_active)
SELECT 1, t.id, 'APSL Lighthouse', 1, true
FROM teams t WHERE t.name = 'Lighthouse 1893 SC' AND t.source_system_id = 1
ON CONFLICT (id) DO UPDATE SET
    team_id = EXCLUDED.team_id,
    name = EXCLUDED.name,
    chat_type_id = EXCLUDED.chat_type_id;

-- Training Lighthouse (training chat, no team)
INSERT INTO chats (id, name, chat_type_id, is_active)
VALUES (4, 'Training Lighthouse', 5, true)
ON CONFLICT (id) DO UPDATE SET
    name = EXCLUDED.name,
    chat_type_id = EXCLUDED.chat_type_id;

-- Philadelphia Pickup (pickup chat, no team)
INSERT INTO chats (id, name, chat_type_id, is_active)
VALUES (5, 'Philadelphia Pickup', 3, true)
ON CONFLICT (id) DO UPDATE SET
    name = EXCLUDED.name,
    chat_type_id = EXCLUDED.chat_type_id;

-- Lighthouse Boys Club Liga 1 & 2 (team chat)
INSERT INTO chats (id, team_id, name, chat_type_id, is_active)
SELECT 6, t.id, 'Lighthouse Boys Club Liga 1 & 2', 1, true
FROM teams t WHERE t.name = 'Lighthouse Boys Club' AND t.source_system_id = 2
ON CONFLICT (id) DO UPDATE SET
    team_id = EXCLUDED.team_id,
    name = EXCLUDED.name,
    chat_type_id = EXCLUDED.chat_type_id;

-- Lighthouse Boys Club U23 (team chat)
INSERT INTO chats (id, team_id, name, chat_type_id, is_active)
SELECT 7, t.id, 'Lighthouse Boys Club U23', 1, true
FROM teams t WHERE t.name = 'Lighthouse Boys Club U23' AND t.source_system_id = 2
ON CONFLICT (id) DO UPDATE SET
    team_id = EXCLUDED.team_id,
    name = EXCLUDED.name,
    chat_type_id = EXCLUDED.chat_type_id;

-- ============================================================================
-- 2. Chat Integrations (GroupMe API links)
-- ============================================================================

INSERT INTO chat_integrations (id, chat_id, provider_id, external_id, external_name, is_primary, sync_messages, sync_members, sync_events)
SELECT 1, 1, 1, '109785985', 'APSL Lighthouse',                 true, false, false, true WHERE EXISTS (SELECT 1 FROM chats WHERE id=1)
ON CONFLICT (id) DO UPDATE SET chat_id=EXCLUDED.chat_id, provider_id=EXCLUDED.provider_id, external_id=EXCLUDED.external_id, external_name=EXCLUDED.external_name;

INSERT INTO chat_integrations (id, chat_id, provider_id, external_id, external_name, is_primary, sync_messages, sync_members, sync_events)
SELECT 4, 4, 1, '108640377', 'Training Lighthouse',             true, false, false, true WHERE EXISTS (SELECT 1 FROM chats WHERE id=4)
ON CONFLICT (id) DO UPDATE SET chat_id=EXCLUDED.chat_id, provider_id=EXCLUDED.provider_id, external_id=EXCLUDED.external_id, external_name=EXCLUDED.external_name;

INSERT INTO chat_integrations (id, chat_id, provider_id, external_id, external_name, is_primary, sync_messages, sync_members, sync_events)
SELECT 5, 5, 1, '65284700',  'Philadelphia Pickup',             true, false, false, true WHERE EXISTS (SELECT 1 FROM chats WHERE id=5)
ON CONFLICT (id) DO UPDATE SET chat_id=EXCLUDED.chat_id, provider_id=EXCLUDED.provider_id, external_id=EXCLUDED.external_id, external_name=EXCLUDED.external_name;

INSERT INTO chat_integrations (id, chat_id, provider_id, external_id, external_name, is_primary, sync_messages, sync_members, sync_events)
SELECT 6, 6, 1, '109786182', 'Lighthouse Boys Club Liga 1 & 2', true, false, false, true WHERE EXISTS (SELECT 1 FROM chats WHERE id=6)
ON CONFLICT (id) DO UPDATE SET chat_id=EXCLUDED.chat_id, provider_id=EXCLUDED.provider_id, external_id=EXCLUDED.external_id, external_name=EXCLUDED.external_name;

INSERT INTO chat_integrations (id, chat_id, provider_id, external_id, external_name, is_primary, sync_messages, sync_members, sync_events)
SELECT 7, 7, 1, '109786278', 'Lighthouse Boys Club U23',        true, false, false, true WHERE EXISTS (SELECT 1 FROM chats WHERE id=7)
ON CONFLICT (id) DO UPDATE SET chat_id=EXCLUDED.chat_id, provider_id=EXCLUDED.provider_id, external_id=EXCLUDED.external_id, external_name=EXCLUDED.external_name;

-- Advance sequences past explicit IDs so future autoincrement INSERTs don't collide
SELECT setval('chats_id_seq',              GREATEST((SELECT COALESCE(MAX(id), 1) FROM chats),              1));
SELECT setval('chat_integrations_id_seq',  GREATEST((SELECT COALESCE(MAX(id), 1) FROM chat_integrations),  1));

-- ============================================================================
-- 3. Chat-Club Mappings (which clubs share which chats)
-- ============================================================================

-- Training Lighthouse → Lighthouse 1893 SC (club)
INSERT INTO chat_clubs (chat_id, club_id)
SELECT 4, c.id FROM clubs c WHERE c.name = 'Lighthouse 1893 SC'
ON CONFLICT (chat_id, club_id) DO NOTHING;

-- Philadelphia Pickup → Lighthouse 1893 SC (club)
INSERT INTO chat_clubs (chat_id, club_id)
SELECT 5, c.id FROM clubs c WHERE c.name = 'Lighthouse 1893 SC'
ON CONFLICT (chat_id, club_id) DO NOTHING;

-- Training Lighthouse → Lansdowne Yonkers FC
INSERT INTO chat_clubs (chat_id, club_id)
SELECT 4, c.id FROM clubs c WHERE c.name = 'Lansdowne Yonkers FC'
ON CONFLICT (chat_id, club_id) DO NOTHING;

-- Philadelphia Pickup → Lansdowne Yonkers FC
INSERT INTO chat_clubs (chat_id, club_id)
SELECT 5, c.id FROM clubs c WHERE c.name = 'Lansdowne Yonkers FC'
ON CONFLICT (chat_id, club_id) DO NOTHING;

-- Training Lighthouse → Lighthouse (CASA club)
INSERT INTO chat_clubs (chat_id, club_id)
SELECT 4, c.id FROM clubs c WHERE c.name = 'Lighthouse'
ON CONFLICT (chat_id, club_id) DO NOTHING;

-- Philadelphia Pickup → Lighthouse (CASA club)
INSERT INTO chat_clubs (chat_id, club_id)
SELECT 5, c.id FROM clubs c WHERE c.name = 'Lighthouse'
ON CONFLICT (chat_id, club_id) DO NOTHING;

-- Training Lighthouse → Lighthouse Boys Club U23
INSERT INTO chat_clubs (chat_id, club_id)
SELECT 4, c.id FROM clubs c WHERE c.name = 'Lighthouse Boys Club U23'
ON CONFLICT (chat_id, club_id) DO NOTHING;

-- Philadelphia Pickup → Lighthouse Boys Club U23
INSERT INTO chat_clubs (chat_id, club_id)
SELECT 5, c.id FROM clubs c WHERE c.name = 'Lighthouse Boys Club U23'
ON CONFLICT (chat_id, club_id) DO NOTHING;
