-- ============================================================================
-- Migration 070: Drop unused chat providers
-- ============================================================================
-- Migration 066 removed GroupMe (provider_id = 1). The remaining seed rows
-- (discord, slack, teamsnap, whatsapp) were never integrated:
--
--   - chat_integrations  — 0 rows for any of these provider_ids
--   - external_identities — 0 rows for any of these provider_ids
--   - Backend C++ code does not reference chat_providers at all
--   - Frontend does not reference chat_providers
--   - scripts/ does not reference chat_providers
--
-- This migration deletes those seed rows. The chat_providers table itself,
-- along with the chat_integrations.provider_id and
-- external_identities.provider_id FK columns, is preserved for future use
-- (e.g. when a real chat integration is added).
-- ============================================================================

BEGIN;

-- Verify nothing depends on these rows before deleting (defence in depth;
-- if any rows appeared since this migration was written the FKs would
-- block the DELETE anyway, but make the failure mode explicit).
DO $$
DECLARE
    ci_count INT;
    ei_count INT;
BEGIN
    SELECT count(*) INTO ci_count
    FROM chat_integrations ci
    JOIN chat_providers cp ON cp.id = ci.provider_id
    WHERE cp.name IN ('discord', 'slack', 'teamsnap', 'whatsapp');

    SELECT count(*) INTO ei_count
    FROM external_identities ei
    JOIN chat_providers cp ON cp.id = ei.provider_id
    WHERE cp.name IN ('discord', 'slack', 'teamsnap', 'whatsapp');

    IF ci_count > 0 OR ei_count > 0 THEN
        RAISE EXCEPTION
            'Refusing to drop chat providers: % chat_integrations rows, % external_identities rows still reference them',
            ci_count, ei_count;
    END IF;
END $$;

DELETE FROM chat_providers
WHERE name IN ('discord', 'slack', 'teamsnap', 'whatsapp');

COMMIT;
