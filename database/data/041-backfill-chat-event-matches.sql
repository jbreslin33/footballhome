-- ============================================================================
-- Backfill matches for chat_events in Training & Pickup chats
-- Plus a trigger so future chat_events in chats with a team_id automatically
-- get a matching matches row (match_type=3 'practice', home_team_id=team).
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. Backfill: every existing chat_event in chats 4/5 with no match_id
-- ----------------------------------------------------------------------------
WITH inserted AS (
    INSERT INTO matches (
        match_type_id, home_team_id, away_team_id,
        match_date, match_time, title, description,
        source_system_id, external_id
    )
    SELECT
        3,                                              -- practice
        c.team_id,
        NULL,
        COALESCE(ce.event_date, (ce.start_at AT TIME ZONE 'America/New_York')::date, CURRENT_DATE),
        COALESCE(ce.event_time, (ce.start_at AT TIME ZONE 'America/New_York')::time),
        ce.title,
        ce.description,
        5,                                              -- internal
        'chat_event:' || ce.id::text
    FROM chat_events ce
    JOIN chats c ON c.id = ce.chat_id
    WHERE ce.chat_id IN (4, 5)
      AND ce.match_id IS NULL
      AND c.team_id IS NOT NULL
      AND NOT EXISTS (
          SELECT 1 FROM matches m2
          WHERE m2.source_system_id = 5
            AND m2.external_id = 'chat_event:' || ce.id::text
      )
    RETURNING id, external_id
)
UPDATE chat_events ce
SET match_id = ins.id
FROM inserted ins
WHERE ins.external_id = 'chat_event:' || ce.id::text
  AND ce.match_id IS NULL;

-- ----------------------------------------------------------------------------
-- 2. Trigger: auto-create a match for new chat_events in chats with team_id
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION chat_event_create_match()
RETURNS TRIGGER AS $$
DECLARE
    v_team_id INTEGER;
    v_new_match_id INTEGER;
BEGIN
    -- Only act if event has no linked match yet
    IF NEW.match_id IS NOT NULL THEN
        RETURN NEW;
    END IF;

    SELECT team_id INTO v_team_id FROM chats WHERE id = NEW.chat_id;

    -- Only auto-create for chats backed by a team (training, pickup, etc.)
    IF v_team_id IS NULL THEN
        RETURN NEW;
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

    NEW.match_id := v_new_match_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_chat_event_create_match ON chat_events;
CREATE TRIGGER trg_chat_event_create_match
    BEFORE INSERT ON chat_events
    FOR EACH ROW EXECUTE FUNCTION chat_event_create_match();

COMMENT ON FUNCTION chat_event_create_match() IS
    'Auto-creates a matches row (match_type=practice) for every chat_event in a chat with team_id set. Lets training/pickup chats use the same schedule + lineup pipeline as regular team matches.';
