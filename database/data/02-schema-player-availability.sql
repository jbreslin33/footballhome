-- =====================================================
-- Player Availability Tracking System
-- =====================================================
-- Tracks medical, academic, and other availability issues
-- Allows granular control: can practice but not play games, etc.
-- =====================================================

-- Player Medical Status
-- Tracks injuries, illnesses, and recovery status
CREATE TABLE player_medical_status (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    player_id UUID NOT NULL REFERENCES players(id) ON DELETE CASCADE,
    
    -- Status
    status VARCHAR(20) NOT NULL DEFAULT 'healthy',
    -- Options: 'healthy', 'injured', 'recovering', 'ill', 'concussion_protocol'
    
    -- Injury Details
    injury_type VARCHAR(100), -- 'ankle_sprain', 'hamstring', 'concussion', 'knee', 'shoulder', etc.
    severity VARCHAR(20), -- 'minor', 'moderate', 'severe'
    
    -- Availability Flags
    available_for_practices BOOLEAN NOT NULL DEFAULT true,
    available_for_games BOOLEAN NOT NULL DEFAULT true,
    
    -- Date Tracking
    injury_date DATE,
    expected_return_date DATE,
    actual_return_date DATE,
    
    -- Medical Clearance
    medical_clearance_required BOOLEAN DEFAULT false,
    medical_clearance_date DATE,
    medical_provider VARCHAR(200), -- Doctor name, clinic
    
    -- Scope
    affects_all_teams BOOLEAN DEFAULT true, -- If false, only affects specific team
    team_id UUID REFERENCES teams(id), -- NULL = affects all teams
    
    -- Notes
    notes TEXT,
    treatment_plan TEXT,
    
    -- Metadata
    created_by UUID NOT NULL REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    resolved_at TIMESTAMP, -- When status ended (player returned to full health)
    resolved_by UUID REFERENCES users(id),
    
    -- Constraints
    CONSTRAINT medical_status_values CHECK (status IN ('healthy', 'injured', 'recovering', 'ill', 'concussion_protocol')),
    CONSTRAINT severity_values CHECK (severity IN ('minor', 'moderate', 'severe') OR severity IS NULL),
    CONSTRAINT team_scope_valid CHECK (
        (affects_all_teams = true AND team_id IS NULL) OR 
        (affects_all_teams = false AND team_id IS NOT NULL)
    )
);

-- Player Academic Status
-- Tracks academic eligibility and restrictions
CREATE TABLE player_academic_status (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    player_id UUID NOT NULL REFERENCES players(id) ON DELETE CASCADE,
    
    -- Status
    status VARCHAR(20) NOT NULL DEFAULT 'eligible',
    -- Options: 'eligible', 'ineligible', 'probation', 'restricted'
    
    -- Academic Details
    gpa DECIMAL(3,2), -- e.g., 3.75
    required_gpa DECIMAL(3,2), -- Minimum required
    credits_enrolled INTEGER,
    required_credits INTEGER,
    
    -- Availability Flags
    available_for_practices BOOLEAN NOT NULL DEFAULT true,
    available_for_games BOOLEAN NOT NULL DEFAULT true,
    
    -- Date Tracking
    status_start_date DATE NOT NULL,
    status_end_date DATE, -- When eligibility is restored
    review_date DATE, -- Next academic review
    
    -- Scope
    affects_all_teams BOOLEAN DEFAULT true,
    team_id UUID REFERENCES teams(id),
    
    -- Academic Period
    academic_term VARCHAR(50), -- 'Fall 2025', 'Spring 2026', etc.
    school_name VARCHAR(200),
    
    -- Notes
    notes TEXT,
    improvement_plan TEXT,
    
    -- Metadata
    created_by UUID NOT NULL REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    resolved_at TIMESTAMP,
    resolved_by UUID REFERENCES users(id),
    
    -- Constraints
    CONSTRAINT academic_status_values CHECK (status IN ('eligible', 'ineligible', 'probation', 'restricted')),
    CONSTRAINT team_scope_valid CHECK (
        (affects_all_teams = true AND team_id IS NULL) OR 
        (affects_all_teams = false AND team_id IS NOT NULL)
    )
);

-- History table for medical status changes
CREATE TABLE player_medical_status_history (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    medical_status_id UUID NOT NULL REFERENCES player_medical_status(id) ON DELETE CASCADE,
    player_id UUID NOT NULL REFERENCES players(id) ON DELETE CASCADE,
    
    -- What changed
    field_changed VARCHAR(50) NOT NULL,
    old_value TEXT,
    new_value TEXT,
    
    -- Who and when
    changed_by UUID NOT NULL REFERENCES users(id),
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    reason TEXT
);

-- History table for academic status changes
CREATE TABLE player_academic_status_history (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    academic_status_id UUID NOT NULL REFERENCES player_academic_status(id) ON DELETE CASCADE,
    player_id UUID NOT NULL REFERENCES players(id) ON DELETE CASCADE,
    
    -- What changed
    field_changed VARCHAR(50) NOT NULL,
    old_value TEXT,
    new_value TEXT,
    
    -- Who and when
    changed_by UUID NOT NULL REFERENCES users(id),
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    reason TEXT
);

-- Indexes for performance
CREATE INDEX idx_medical_status_player ON player_medical_status(player_id);
CREATE INDEX idx_medical_status_active ON player_medical_status(player_id) WHERE resolved_at IS NULL;
CREATE INDEX idx_medical_status_team ON player_medical_status(team_id) WHERE team_id IS NOT NULL;

CREATE INDEX idx_academic_status_player ON player_academic_status(player_id);
CREATE INDEX idx_academic_status_active ON player_academic_status(player_id) WHERE resolved_at IS NULL;
CREATE INDEX idx_academic_status_team ON player_academic_status(team_id) WHERE team_id IS NOT NULL;

CREATE INDEX idx_medical_history_status ON player_medical_status_history(medical_status_id);
CREATE INDEX idx_academic_history_status ON player_academic_status_history(academic_status_id);

-- Comments for documentation
COMMENT ON TABLE player_medical_status IS 'Tracks player injuries, illnesses, and medical availability';
COMMENT ON TABLE player_academic_status IS 'Tracks player academic eligibility and restrictions';
COMMENT ON COLUMN player_medical_status.available_for_practices IS 'Can player participate in practice sessions';
COMMENT ON COLUMN player_medical_status.available_for_games IS 'Can player participate in competitive games';
COMMENT ON COLUMN player_medical_status.affects_all_teams IS 'If true, status applies to all teams player is on';
COMMENT ON COLUMN player_academic_status.status IS 'eligible=full participation, ineligible=no participation, probation=limited, restricted=coaches discretion';
