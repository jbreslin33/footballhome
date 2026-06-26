-- ============================================================================
-- Migration 066: Drop GroupMe
-- ============================================================================
-- Removes all GroupMe-specific tables, seed rows, and provider-1 data while
-- keeping the generic chat / chat_event / chat_event_rsvp / external_identity
-- infrastructure for future providers.
--
-- Tables dropped (GroupMe-only):
--   - chat_non_players          (allow-list of non-player GroupMe members)
--   - chat_external_members     (cached GroupMe group membership)
--   - groupme_groups            (legacy GroupMe group cache, if it exists)
--
-- Rows deleted (provider_id = 1 / 'groupme'):
--   - chat_event_rsvps         (cascade via chat_events)
--   - chat_events              (cascade via chats)
--   - chats                    (cascade via chat_integrations)
--   - chat_integrations
--   - external_identities
--   - chat_providers           (the 'groupme' row itself)
-- ============================================================================

BEGIN;

-- 1. Drop GroupMe-only tables outright
DROP TABLE IF EXISTS chat_non_players;
DROP TABLE IF EXISTS chat_external_members;
DROP TABLE IF EXISTS groupme_groups;

-- 2. Capture every chat that was a GroupMe chat (via chat_integrations.provider_id = 1)
CREATE TEMP TABLE IF NOT EXISTS _gm_chats AS
SELECT DISTINCT chat_id FROM chat_integrations WHERE provider_id = 1;

-- 3. Capture every chat_event hanging off those chats
CREATE TEMP TABLE IF NOT EXISTS _gm_events AS
SELECT id FROM chat_events WHERE chat_id IN (SELECT chat_id FROM _gm_chats);

-- 4. Delete RSVPs first, then events, then chats (defensive — FKs should cascade,
--    but ordering keeps the migration explicit and idempotent)
DELETE FROM chat_event_rsvps WHERE chat_event_id IN (SELECT id FROM _gm_events);
DELETE FROM chat_events      WHERE id            IN (SELECT id FROM _gm_events);
DELETE FROM chat_integrations WHERE provider_id  = 1;
DELETE FROM chats             WHERE id           IN (SELECT chat_id FROM _gm_chats);

-- 5. Drop GroupMe-linked external identities and aliases
DELETE FROM external_person_aliases  WHERE provider = 'groupme';
DELETE FROM external_identities      WHERE provider_id = 1;

-- 6. Finally remove the provider row
DELETE FROM chat_providers WHERE id = 1;

COMMIT;
