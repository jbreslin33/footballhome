-- ============================================================================
-- Fix: chat_event_create_match trigger was BEFORE INSERT, which caused
-- orphan matches rows on every ON CONFLICT upsert. Postgres fires BEFORE
-- INSERT triggers even when the row gets routed to the ON CONFLICT DO UPDATE
-- path, so each sidecar sync cycle was burning a chat_events sequence value
-- and leaving an orphan `matches` row keyed `chat_event:<wasted_id>`.
--
-- Switch to AFTER INSERT, which only fires for rows that actually got
-- inserted (per pg docs §39.1). This eliminates the orphan stream.
--
-- Also: the original trigger set NEW.match_id to back-link the chat_event,
-- which only worked because BEFORE INSERT can mutate NEW. With AFTER INSERT
-- we have to UPDATE the chat_events row separately.
-- ============================================================================

CREATE OR REPLACE FUNCTION chat_event_create_match()
RETURNS TRIGGER AS $$
DECLARE
    v_team_id INTEGER;
    v_new_match_id INTEGER;
BEGIN
    -- Skip if event already linked to a match
    IF NEW.match_id IS NOT NULL THEN
        RETURN NULL;
    END IF;

    SELECT team_id INTO v_team_id FROM chats WHERE id = NEW.chat_id;

    -- Only auto-create for chats backed by a team (training/pickup/team)
    IF v_team_id IS NULL THEN
        RETURN NULL;
    END IF;

    INSERT INTO matches (
        match_type_id, home_team_id, away_team_id,
        match_date, match_time, title, description,
        source_system_id, external_id
    ) VALUES (
        3,
        v_team_id,
        NULL,
        COALESCE(NEW.event_date, (NEW.start_at AT TIME ZONE 'America/New_York')::date, CURRENT_DATE),
        COALESCE(NEW.event_time, (NEW.start_at AT TIME ZONE 'America/New_York')::time),
        NEW.title,
        NEW.description,
        5,
        'chat_event:' || NEW.id::text
    )
    ON CONFLICT (source_system_id, external_id) DO UPDATE
        SET title = EXCLUDED.title,
            match_date = EXCLUDED.match_date,
            match_time = EXCLUDED.match_time
    RETURNING id INTO v_new_match_id;

    -- Back-link chat_event → match (we're AFTER INSERT now, so update directly)
    UPDATE chat_events SET match_id = v_new_match_id WHERE id = NEW.id;

    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_chat_event_create_match ON chat_events;
CREATE TRIGGER trg_chat_event_create_match
    AFTER INSERT ON chat_events
    FOR EACH ROW EXECUTE FUNCTION chat_event_create_match();

COMMENT ON FUNCTION chat_event_create_match() IS
    'Auto-creates a matches row (match_type=practice) for every chat_event in a chat with team_id set. AFTER INSERT so it only fires for rows actually persisted (not for rows that hit ON CONFLICT DO UPDATE).';

-- ============================================================================
-- Cleanup: delete orphan matches whose external_id is `chat_event:<id>` but
-- the referenced chat_events row no longer exists. These were created by the
-- old BEFORE INSERT trigger on conflict-resolved upserts.
-- Cascades will clean match_divisions, match_events, match_lineups, etc.
-- ============================================================================

DELETE FROM matches m
WHERE m.external_id LIKE 'chat_event:%'
  AND m.source_system_id = 5
  AND NOT EXISTS (
      SELECT 1 FROM chat_events ce
      WHERE ('chat_event:' || ce.id::text) = m.external_id
  );
