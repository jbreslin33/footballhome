-- ========================================
-- AUDIT & CHANGE TRACKING SYSTEM
-- ========================================
-- This creates tables and triggers to automatically capture ALL changes
-- made via the frontend after database initialization.
--
-- Changes are logged with replay SQL so they can be re-applied on rebuild.
-- ========================================

-- ---------------------------------------------------------
-- AUDIT LOG TABLE
-- ---------------------------------------------------------
CREATE TABLE IF NOT EXISTS change_log (
    id SERIAL PRIMARY KEY,
    table_name TEXT NOT NULL,
    record_id UUID,
    operation TEXT NOT NULL,  -- INSERT, UPDATE, DELETE
    old_values JSONB,
    new_values JSONB,
    changed_by UUID,  -- user_id if available from session
    changed_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    replay_sql TEXT,  -- Generated SQL to replay this change
    source TEXT DEFAULT 'app'  -- 'app', 'api', 'manual', 'import'
);

CREATE INDEX IF NOT EXISTS idx_change_log_table ON change_log(table_name);
CREATE INDEX IF NOT EXISTS idx_change_log_changed_at ON change_log(changed_at);
CREATE INDEX IF NOT EXISTS idx_change_log_record_id ON change_log(record_id);

-- ---------------------------------------------------------
-- AUDIT TRIGGER FUNCTION
-- ---------------------------------------------------------
CREATE OR REPLACE FUNCTION log_change_with_replay()
RETURNS TRIGGER AS $$
DECLARE
    replay TEXT;
    old_json JSONB;
    new_json JSONB;
    col_name TEXT;
    col_value TEXT;
    set_clauses TEXT[];
    insert_cols TEXT[];
    insert_vals TEXT[];
BEGIN
    -- Convert OLD and NEW to JSONB
    IF TG_OP = 'DELETE' THEN
        old_json := to_jsonb(OLD);
        new_json := NULL;
    ELSIF TG_OP = 'INSERT' THEN
        old_json := NULL;
        new_json := to_jsonb(NEW);
    ELSE -- UPDATE
        old_json := to_jsonb(OLD);
        new_json := to_jsonb(NEW);
    END IF;

    -- Generate replay SQL
    IF TG_OP = 'INSERT' THEN
        -- Build INSERT statement
        FOR col_name IN 
            SELECT jsonb_object_keys(new_json)
        LOOP
            col_value := new_json->>col_name;
            IF col_value IS NOT NULL THEN
                insert_cols := array_append(insert_cols, col_name);
                -- Escape single quotes
                col_value := replace(col_value, '''', '''''');
                insert_vals := array_append(insert_vals, '''' || col_value || '''');
            ELSE
                insert_cols := array_append(insert_cols, col_name);
                insert_vals := array_append(insert_vals, 'NULL');
            END IF;
        END LOOP;
        
        replay := format('INSERT INTO %I (%s) VALUES (%s) ON CONFLICT DO NOTHING;',
            TG_TABLE_NAME,
            array_to_string(insert_cols, ', '),
            array_to_string(insert_vals, ', ')
        );

    ELSIF TG_OP = 'UPDATE' THEN
        -- Build UPDATE statement with only changed columns
        FOR col_name IN 
            SELECT jsonb_object_keys(new_json)
        LOOP
            IF old_json->col_name IS DISTINCT FROM new_json->col_name THEN
                col_value := new_json->>col_name;
                IF col_value IS NOT NULL THEN
                    col_value := replace(col_value, '''', '''''');
                    set_clauses := array_append(set_clauses, 
                        format('%I = ''%s''', col_name, col_value)
                    );
                ELSE
                    set_clauses := array_append(set_clauses, 
                        format('%I = NULL', col_name)
                    );
                END IF;
            END IF;
        END LOOP;

        IF array_length(set_clauses, 1) > 0 THEN
            -- Try to find primary key column
            IF new_json ? 'id' THEN
                replay := format('UPDATE %I SET %s WHERE id = ''%s'';',
                    TG_TABLE_NAME,
                    array_to_string(set_clauses, ', '),
                    new_json->>'id'
                );
            ELSE
                replay := format('-- UPDATE %I: Could not generate WHERE clause (no id column)',
                    TG_TABLE_NAME
                );
            END IF;
        END IF;

    ELSIF TG_OP = 'DELETE' THEN
        -- Build DELETE statement
        IF old_json ? 'id' THEN
            replay := format('DELETE FROM %I WHERE id = ''%s'';',
                TG_TABLE_NAME,
                old_json->>'id'
            );
        ELSE
            replay := format('-- DELETE FROM %I: Could not generate WHERE clause (no id column)',
                TG_TABLE_NAME
            );
        END IF;
    END IF;

    -- Insert audit record
    INSERT INTO change_log (
        table_name, 
        record_id, 
        operation, 
        old_values, 
        new_values, 
        replay_sql
    ) VALUES (
        TG_TABLE_NAME,
        CASE 
            WHEN TG_OP = 'DELETE' THEN (old_json->>'id')::UUID
            ELSE (new_json->>'id')::UUID
        END,
        TG_OP,
        old_json,
        new_json,
        replay
    );

    -- Return appropriate value
    IF TG_OP = 'DELETE' THEN
        RETURN OLD;
    ELSE
        RETURN NEW;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- ---------------------------------------------------------
-- TABLES TO AUDIT (user-editable data)
-- ---------------------------------------------------------

-- Users table (name corrections)
DROP TRIGGER IF EXISTS audit_users ON users;
CREATE TRIGGER audit_users
    AFTER INSERT OR UPDATE OR DELETE ON users
    FOR EACH ROW
    EXECUTE FUNCTION log_change_with_replay();

-- Team Players (roster assignments)
DROP TRIGGER IF EXISTS audit_team_players ON team_players;
CREATE TRIGGER audit_team_players
    AFTER INSERT OR UPDATE OR DELETE ON team_players
    FOR EACH ROW
    EXECUTE FUNCTION log_change_with_replay();

-- Division Players (registration numbers)
DROP TRIGGER IF EXISTS audit_division_players ON division_players;
CREATE TRIGGER audit_division_players
    AFTER INSERT OR UPDATE OR DELETE ON division_players
    FOR EACH ROW
    EXECUTE FUNCTION log_change_with_replay();

-- Practices (manual entries)
DROP TRIGGER IF EXISTS audit_practices ON practices;
CREATE TRIGGER audit_practices
    AFTER INSERT OR UPDATE OR DELETE ON practices
    FOR EACH ROW
    EXECUTE FUNCTION log_change_with_replay();

-- Practice Attendances (RSVPs)
DROP TRIGGER IF EXISTS audit_practice_attendances ON practice_attendances;
CREATE TRIGGER audit_practice_attendances
    AFTER INSERT OR UPDATE OR DELETE ON practice_attendances
    FOR EACH ROW
    EXECUTE FUNCTION log_change_with_replay();

-- Team Coaches (assignments)
DROP TRIGGER IF EXISTS audit_team_coaches ON team_coaches;
CREATE TRIGGER audit_team_coaches
    AFTER INSERT OR UPDATE OR DELETE ON team_coaches
    FOR EACH ROW
    EXECUTE FUNCTION log_change_with_replay();

-- Events (manual events)
DROP TRIGGER IF EXISTS audit_events ON events;
CREATE TRIGGER audit_events
    AFTER INSERT OR UPDATE OR DELETE ON events
    FOR EACH ROW
    EXECUTE FUNCTION log_change_with_replay();

-- Matches (score updates)
DROP TRIGGER IF EXISTS audit_matches ON matches;
CREATE TRIGGER audit_matches
    AFTER INSERT OR UPDATE OR DELETE ON matches
    FOR EACH ROW
    EXECUTE FUNCTION log_change_with_replay();

-- User External Identities (GroupMe linking)
DROP TRIGGER IF EXISTS audit_user_external_identities ON user_external_identities;
CREATE TRIGGER audit_user_external_identities
    AFTER INSERT OR UPDATE OR DELETE ON user_external_identities
    FOR EACH ROW
    EXECUTE FUNCTION log_change_with_replay();

-- ---------------------------------------------------------
-- HELPER VIEWS
-- ---------------------------------------------------------

-- View recent changes
CREATE OR REPLACE VIEW recent_changes AS
SELECT 
    id,
    table_name,
    operation,
    changed_at,
    replay_sql,
    new_values->>'first_name' || ' ' || new_values->>'last_name' as user_name,
    new_values->>'jersey_number' as jersey,
    source
FROM change_log
ORDER BY changed_at DESC
LIMIT 100;

-- View changes by table
CREATE OR REPLACE VIEW changes_by_table AS
SELECT 
    table_name,
    operation,
    COUNT(*) as count,
    MAX(changed_at) as last_change
FROM change_log
GROUP BY table_name, operation
ORDER BY last_change DESC;

-- ---------------------------------------------------------
-- UTILITY FUNCTIONS
-- ---------------------------------------------------------

-- Function to export replay SQL for a date range
CREATE OR REPLACE FUNCTION export_changes_sql(
    since_date TIMESTAMPTZ DEFAULT NULL,
    until_date TIMESTAMPTZ DEFAULT NULL
)
RETURNS TABLE(sql_statement TEXT) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        '-- ' || table_name || ' (' || operation || ') at ' || changed_at::TEXT || E'\n' ||
        replay_sql
    FROM change_log
    WHERE 
        (since_date IS NULL OR changed_at >= since_date)
        AND (until_date IS NULL OR changed_at <= until_date)
        AND replay_sql IS NOT NULL
        AND replay_sql != ''
    ORDER BY changed_at;
END;
$$ LANGUAGE plpgsql;

-- Function to clear old audit logs (keep last N days)
CREATE OR REPLACE FUNCTION cleanup_old_audit_logs(keep_days INTEGER DEFAULT 90)
RETURNS INTEGER AS $$
DECLARE
    deleted_count INTEGER;
BEGIN
    DELETE FROM change_log
    WHERE changed_at < NOW() - (keep_days || ' days')::INTERVAL;
    
    GET DIAGNOSTICS deleted_count = ROW_COUNT;
    RETURN deleted_count;
END;
$$ LANGUAGE plpgsql;

-- ---------------------------------------------------------
-- INITIAL STATE MARKER
-- ---------------------------------------------------------

-- Insert a marker to know when the database was initialized
INSERT INTO change_log (table_name, operation, replay_sql, source)
VALUES ('_system', 'INIT', '-- Database initialized', 'system');

