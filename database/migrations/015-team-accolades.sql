-- Team accolades: achievements, titles, taglines displayed on social cards
CREATE TABLE IF NOT EXISTS team_accolades (
    id SERIAL PRIMARY KEY,
    team_id INTEGER NOT NULL REFERENCES teams(id),
    accolade TEXT NOT NULL,
    accolade_type VARCHAR(20) NOT NULL DEFAULT 'achievement',  -- 'achievement' or 'tagline'
    sort_order INTEGER NOT NULL DEFAULT 0,
    active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_team_accolades_team_id ON team_accolades(team_id);
