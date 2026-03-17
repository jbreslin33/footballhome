-- Migration 007: Create RSVP history tables and current-status views
-- The backend expects {role}_rsvp_history tables and {role}_rsvps_current views
-- for player, coach, and parent roles.

-- 1. RSVP Change Sources lookup table
CREATE TABLE IF NOT EXISTS rsvp_change_sources (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT
);

INSERT INTO rsvp_change_sources (name, description) VALUES
    ('app', 'RSVP via the web application'),
    ('groupme', 'RSVP synced from GroupMe'),
    ('admin', 'RSVP set by an administrator')
ON CONFLICT (name) DO NOTHING;

-- 2. Player RSVP history (append-only log)
CREATE TABLE IF NOT EXISTS player_rsvp_history (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    event_id INTEGER NOT NULL REFERENCES matches(id) ON DELETE CASCADE,
    player_id INTEGER NOT NULL REFERENCES users(id),
    rsvp_status_id INTEGER NOT NULL REFERENCES rsvp_statuses(id),
    changed_by INTEGER REFERENCES users(id),
    change_source_id INTEGER REFERENCES rsvp_change_sources(id),
    notes TEXT,
    changed_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_player_rsvp_history_event ON player_rsvp_history(event_id);
CREATE INDEX IF NOT EXISTS idx_player_rsvp_history_player ON player_rsvp_history(player_id);

-- 3. Coach RSVP history (append-only log)
CREATE TABLE IF NOT EXISTS coach_rsvp_history (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    event_id INTEGER NOT NULL REFERENCES matches(id) ON DELETE CASCADE,
    coach_id INTEGER NOT NULL REFERENCES users(id),
    rsvp_status_id INTEGER NOT NULL REFERENCES rsvp_statuses(id),
    changed_by INTEGER REFERENCES users(id),
    change_source_id INTEGER REFERENCES rsvp_change_sources(id),
    notes TEXT,
    changed_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_coach_rsvp_history_event ON coach_rsvp_history(event_id);
CREATE INDEX IF NOT EXISTS idx_coach_rsvp_history_coach ON coach_rsvp_history(coach_id);

-- 4. Parent RSVP history (append-only log)
CREATE TABLE IF NOT EXISTS parent_rsvp_history (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    event_id INTEGER NOT NULL REFERENCES matches(id) ON DELETE CASCADE,
    parent_id INTEGER NOT NULL REFERENCES users(id),
    rsvp_status_id INTEGER NOT NULL REFERENCES rsvp_statuses(id),
    changed_by INTEGER REFERENCES users(id),
    change_source_id INTEGER REFERENCES rsvp_change_sources(id),
    notes TEXT,
    changed_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_parent_rsvp_history_event ON parent_rsvp_history(event_id);
CREATE INDEX IF NOT EXISTS idx_parent_rsvp_history_parent ON parent_rsvp_history(parent_id);

-- 5. Current-status views (latest RSVP per person per event)

CREATE OR REPLACE VIEW player_rsvps_current AS
SELECT DISTINCT ON (event_id, player_id)
    event_id, player_id, rsvp_status_id, notes, changed_at
FROM player_rsvp_history
ORDER BY event_id, player_id, changed_at DESC;

CREATE OR REPLACE VIEW coach_rsvps_current AS
SELECT DISTINCT ON (event_id, coach_id)
    event_id, coach_id, rsvp_status_id, notes, changed_at
FROM coach_rsvp_history
ORDER BY event_id, coach_id, changed_at DESC;

CREATE OR REPLACE VIEW parent_rsvps_current AS
SELECT DISTINCT ON (event_id, parent_id)
    event_id, parent_id, rsvp_status_id, notes, changed_at
FROM parent_rsvp_history
ORDER BY event_id, parent_id, changed_at DESC;
