-- =====================================================
-- TACTICAL BOARDS SCHEMA - FULLY NORMALIZED
-- =====================================================
-- This schema supports tactical board creation for matches, practices,
-- and club-wide instruction. Fully normalized for analytics and flexibility.

-- =====================================================
-- LOOKUP TABLES
-- =====================================================

-- Lookup: Board Types
CREATE TABLE IF NOT EXISTS tactical_board_types (
    id SERIAL PRIMARY KEY,
    code VARCHAR(50) UNIQUE NOT NULL,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    display_order INTEGER DEFAULT 0
);

INSERT INTO tactical_board_types (code, name, description, display_order) VALUES
    ('match', 'Match Preparation', 'Board linked to specific upcoming match', 1),
    ('practice', 'Practice Session', 'Training session board for drills and instruction', 2),
    ('club_wide', 'Club-Wide', 'Club-level tactical instruction available to all teams', 3),
    ('template', 'Template', 'Reusable template for creating new boards', 4)
ON CONFLICT (code) DO NOTHING;

-- Lookup: Tactical Stances
CREATE TABLE IF NOT EXISTS tactical_stances (
    id SERIAL PRIMARY KEY,
    code VARCHAR(50) UNIQUE NOT NULL,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    display_order INTEGER DEFAULT 0
);

INSERT INTO tactical_stances (code, name, description, display_order) VALUES
    ('offensive', 'Offensive', 'Attacking tactical setup', 1),
    ('defensive', 'Defensive', 'Defensive tactical setup', 2),
    ('neutral', 'Neutral', 'Balanced tactical setup', 3),
    ('pressing', 'High Pressing', 'High press defensive approach', 4),
    ('counter', 'Counter Attack', 'Counter-attacking setup', 5),
    ('possession', 'Possession', 'Possession-based approach', 6)
ON CONFLICT (code) DO NOTHING;

-- Lookup: Field Thirds
CREATE TABLE IF NOT EXISTS tactical_field_thirds (
    id SERIAL PRIMARY KEY,
    code VARCHAR(50) UNIQUE NOT NULL,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    display_order INTEGER DEFAULT 0
);

INSERT INTO tactical_field_thirds (code, name, description, display_order) VALUES
    ('own', 'Own Third', 'Defensive third of the field', 1),
    ('middle', 'Middle Third', 'Middle third of the field', 2),
    ('final', 'Final Third', 'Attacking third of the field', 3)
ON CONFLICT (code) DO NOTHING;

-- Lookup: Player Position Roles
CREATE TABLE IF NOT EXISTS tactical_position_roles (
    id SERIAL PRIMARY KEY,
    code VARCHAR(10) UNIQUE NOT NULL,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    display_order INTEGER DEFAULT 0
);

INSERT INTO tactical_position_roles (code, name, description, display_order) VALUES
    ('GK', 'Goalkeeper', 'Goalkeeper position', 1),
    ('DEF', 'Defender', 'Defensive position', 2),
    ('MID', 'Midfielder', 'Midfield position', 3),
    ('ATT', 'Attacker', 'Attacking position', 4)
ON CONFLICT (code) DO NOTHING;

-- Lookup: Arrow Types
CREATE TABLE IF NOT EXISTS tactical_arrow_types (
    id SERIAL PRIMARY KEY,
    code VARCHAR(50) UNIQUE NOT NULL,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    color VARCHAR(20),
    display_order INTEGER DEFAULT 0
);

INSERT INTO tactical_arrow_types (code, name, description, color, display_order) VALUES
    ('movement', 'Player Movement', 'General player movement', '#000000', 1),
    ('pass', 'Pass', 'Passing direction', '#0066CC', 2),
    ('run', 'Run', 'Running with ball', '#FF6B35', 3),
    ('press', 'Press', 'Pressing movement', '#FF0000', 4),
    ('dribble', 'Dribble', 'Dribbling path', '#FFD700', 5),
    ('shot', 'Shot', 'Shot on goal', '#00FF00', 6),
    ('defensive', 'Defensive Action', 'Defensive movement/coverage', '#8B0000', 7)
ON CONFLICT (code) DO NOTHING;

-- Lookup: Line Styles
CREATE TABLE IF NOT EXISTS tactical_line_styles (
    id SERIAL PRIMARY KEY,
    code VARCHAR(50) UNIQUE NOT NULL,
    name VARCHAR(100) NOT NULL,
    display_order INTEGER DEFAULT 0
);

INSERT INTO tactical_line_styles (code, name, display_order) VALUES
    ('solid', 'Solid Line', 1),
    ('dashed', 'Dashed Line', 2),
    ('dotted', 'Dotted Line', 3)
ON CONFLICT (code) DO NOTHING;

-- =====================================================
-- MAIN TABLES
-- =====================================================

-- Main tactical board metadata
CREATE TABLE IF NOT EXISTS tactical_boards (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    created_by UUID REFERENCES users(id),
    
    -- Board type from lookup
    board_type_id INTEGER NOT NULL REFERENCES tactical_board_types(id),
    
    -- Tactical context from lookups
    stance_id INTEGER REFERENCES tactical_stances(id),
    field_third_id INTEGER REFERENCES tactical_field_thirds(id),
    formation_home VARCHAR(10),      -- '4-4-2', '4-3-3', etc.
    formation_opponent VARCHAR(10),
    
    -- Canvas metadata
    canvas_width INTEGER DEFAULT 1200,
    canvas_height INTEGER DEFAULT 800,
    
    -- Settings
    is_public BOOLEAN DEFAULT false,
    is_template BOOLEAN DEFAULT false,
    version INTEGER DEFAULT 1,
    
    -- Timestamps
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Entity Links: What is this board for?
-- Many-to-Many: One board can link to multiple entities, one entity can have multiple boards
CREATE TABLE IF NOT EXISTS tactical_board_entities (
    id SERIAL PRIMARY KEY,
    tactical_board_id UUID NOT NULL REFERENCES tactical_boards(id) ON DELETE CASCADE,
    
    -- One of these will be populated per row
    match_id UUID REFERENCES matches(id) ON DELETE CASCADE,
    practice_id UUID REFERENCES practices(id) ON DELETE CASCADE,
    team_id UUID REFERENCES teams(id) ON DELETE CASCADE,
    club_id UUID REFERENCES clubs(id) ON DELETE CASCADE,
    sport_division_id UUID REFERENCES sport_divisions(id) ON DELETE CASCADE,
    
    -- Timestamps
    created_at TIMESTAMP DEFAULT NOW(),
    
    -- Constraints: exactly one entity type per row
    CONSTRAINT exactly_one_entity CHECK (
        (CASE WHEN match_id IS NOT NULL THEN 1 ELSE 0 END +
         CASE WHEN practice_id IS NOT NULL THEN 1 ELSE 0 END +
         CASE WHEN team_id IS NOT NULL THEN 1 ELSE 0 END +
         CASE WHEN club_id IS NOT NULL THEN 1 ELSE 0 END +
         CASE WHEN sport_division_id IS NOT NULL THEN 1 ELSE 0 END) = 1
    )
);

-- Player positions on the board
CREATE TABLE IF NOT EXISTS tactical_board_players (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tactical_board_id UUID NOT NULL REFERENCES tactical_boards(id) ON DELETE CASCADE,
    
    team VARCHAR(20) NOT NULL,       -- 'home' or 'opponent'
    player_id UUID REFERENCES users(id),  -- Optional: link to actual player
    name VARCHAR(255),               -- Display name on board
    jersey_number INTEGER,
    
    -- Position on canvas
    position_x DECIMAL(10,2) NOT NULL,
    position_y DECIMAL(10,2) NOT NULL,
    
    -- Appearance
    color VARCHAR(20) DEFAULT '#0066CC',
    position_role_id INTEGER REFERENCES tactical_position_roles(id),
    
    -- Ordering
    display_order INTEGER DEFAULT 0,
    
    -- Timestamps
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    
    -- Constraints
    CONSTRAINT valid_team CHECK (team IN ('home', 'opponent')),
    CONSTRAINT valid_position_x CHECK (position_x >= 0),
    CONSTRAINT valid_position_y CHECK (position_y >= 0)
);

-- Arrows for movements, passes, etc.
CREATE TABLE IF NOT EXISTS tactical_board_arrows (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tactical_board_id UUID NOT NULL REFERENCES tactical_boards(id) ON DELETE CASCADE,
    
    -- Arrow positioning
    start_x DECIMAL(10,2) NOT NULL,
    start_y DECIMAL(10,2) NOT NULL,
    end_x DECIMAL(10,2) NOT NULL,
    end_y DECIMAL(10,2) NOT NULL,
    
    -- Arrow type and styling from lookups
    arrow_type_id INTEGER NOT NULL REFERENCES tactical_arrow_types(id),
    color VARCHAR(20),  -- Optional override of default arrow type color
    line_style_id INTEGER NOT NULL REFERENCES tactical_line_styles(id),
    label VARCHAR(100),  -- Optional text label
    
    -- Link to players for analytics
    from_player_id UUID REFERENCES tactical_board_players(id) ON DELETE SET NULL,
    to_player_id UUID REFERENCES tactical_board_players(id) ON DELETE SET NULL,
    
    -- Ordering
    display_order INTEGER DEFAULT 0,
    
    -- Timestamps
    created_at TIMESTAMP DEFAULT NOW()
);

-- Text annotations on the board
CREATE TABLE IF NOT EXISTS tactical_board_annotations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tactical_board_id UUID NOT NULL REFERENCES tactical_boards(id) ON DELETE CASCADE,
    
    -- Position
    position_x DECIMAL(10,2) NOT NULL,
    position_y DECIMAL(10,2) NOT NULL,
    
    -- Content
    text TEXT NOT NULL,
    
    -- Styling
    font_size INTEGER DEFAULT 14,
    color VARCHAR(20) DEFAULT '#FFFFFF',
    background_color VARCHAR(20) DEFAULT '#00000099',
    
    -- Ordering
    display_order INTEGER DEFAULT 0,
    
    -- Timestamps
    created_at TIMESTAMP DEFAULT NOW(),
    
    CONSTRAINT valid_font_size CHECK (font_size > 0 AND font_size <= 72)
);

-- Animation sequences (for multi-phase tactical explanations)
CREATE TABLE IF NOT EXISTS tactical_board_animations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tactical_board_id UUID NOT NULL REFERENCES tactical_boards(id) ON DELETE CASCADE,
    
    -- Animation metadata
    sequence_order INTEGER NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    duration_ms INTEGER DEFAULT 2000,
    
    -- Timestamps
    created_at TIMESTAMP DEFAULT NOW(),
    
    CONSTRAINT valid_duration CHECK (duration_ms > 0),
    UNIQUE(tactical_board_id, sequence_order)
);

-- Animation frames store state changes for each animation phase
CREATE TABLE IF NOT EXISTS tactical_board_animation_frames (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    animation_id UUID NOT NULL REFERENCES tactical_board_animations(id) ON DELETE CASCADE,
    
    -- Player movements in this frame
    player_id UUID NOT NULL REFERENCES tactical_board_players(id) ON DELETE CASCADE,
    position_x DECIMAL(10,2) NOT NULL,
    position_y DECIMAL(10,2) NOT NULL,
    
    -- Timestamps
    created_at TIMESTAMP DEFAULT NOW()
);

-- Collaboration tracking (who can edit/view boards)
CREATE TABLE IF NOT EXISTS tactical_board_collaborators (
    tactical_board_id UUID NOT NULL REFERENCES tactical_boards(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    permission_level VARCHAR(20) NOT NULL DEFAULT 'view',
    added_at TIMESTAMP DEFAULT NOW(),
    
    PRIMARY KEY (tactical_board_id, user_id),
    CONSTRAINT valid_permission CHECK (permission_level IN ('view', 'edit', 'owner'))
);

-- Tags for categorizing boards
CREATE TABLE IF NOT EXISTS tactical_board_tags (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    color VARCHAR(20),
    created_at TIMESTAMP DEFAULT NOW()
);

-- Tag assignments (many-to-many)
CREATE TABLE IF NOT EXISTS tactical_board_tag_assignments (
    tactical_board_id UUID NOT NULL REFERENCES tactical_boards(id) ON DELETE CASCADE,
    tag_id UUID NOT NULL REFERENCES tactical_board_tags(id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT NOW(),
    PRIMARY KEY (tactical_board_id, tag_id)
);

-- =====================================================
-- INDEXES FOR PERFORMANCE
-- =====================================================

-- Tactical boards indexes
CREATE INDEX IF NOT EXISTS idx_tb_creator ON tactical_boards(created_by);
CREATE INDEX IF NOT EXISTS idx_tb_board_type ON tactical_boards(board_type_id);
CREATE INDEX IF NOT EXISTS idx_tb_stance ON tactical_boards(stance_id);
CREATE INDEX IF NOT EXISTS idx_tb_field_third ON tactical_boards(field_third_id);
CREATE INDEX IF NOT EXISTS idx_tb_public ON tactical_boards(is_public) WHERE is_public = true;
CREATE INDEX IF NOT EXISTS idx_tb_template ON tactical_boards(is_template) WHERE is_template = true;
CREATE INDEX IF NOT EXISTS idx_tb_formation ON tactical_boards(formation_home, formation_opponent);
CREATE INDEX IF NOT EXISTS idx_tb_created ON tactical_boards(created_at DESC);

-- Entity links indexes
CREATE INDEX IF NOT EXISTS idx_tbe_board ON tactical_board_entities(tactical_board_id);
CREATE INDEX IF NOT EXISTS idx_tbe_match ON tactical_board_entities(match_id) WHERE match_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_tbe_practice ON tactical_board_entities(practice_id) WHERE practice_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_tbe_team ON tactical_board_entities(team_id) WHERE team_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_tbe_club ON tactical_board_entities(club_id) WHERE club_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_tbe_division ON tactical_board_entities(sport_division_id) WHERE sport_division_id IS NOT NULL;

-- Player positions indexes
CREATE INDEX IF NOT EXISTS idx_tbp_board ON tactical_board_players(tactical_board_id);
CREATE INDEX IF NOT EXISTS idx_tbp_team ON tactical_board_players(team);
CREATE INDEX IF NOT EXISTS idx_tbp_player ON tactical_board_players(player_id) WHERE player_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_tbp_position ON tactical_board_players(position_x, position_y);
CREATE INDEX IF NOT EXISTS idx_tbp_role ON tactical_board_players(position_role_id);

-- Arrows indexes
CREATE INDEX IF NOT EXISTS idx_tba_board ON tactical_board_arrows(tactical_board_id);
CREATE INDEX IF NOT EXISTS idx_tba_type ON tactical_board_arrows(arrow_type_id);
CREATE INDEX IF NOT EXISTS idx_tba_line_style ON tactical_board_arrows(line_style_id);
CREATE INDEX IF NOT EXISTS idx_tba_from_player ON tactical_board_arrows(from_player_id) WHERE from_player_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_tba_to_player ON tactical_board_arrows(to_player_id) WHERE to_player_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_tba_players ON tactical_board_arrows(from_player_id, to_player_id) WHERE from_player_id IS NOT NULL AND to_player_id IS NOT NULL;

-- Annotations indexes
CREATE INDEX IF NOT EXISTS idx_tban_board ON tactical_board_annotations(tactical_board_id);

-- Animations indexes
CREATE INDEX IF NOT EXISTS idx_tbanim_board ON tactical_board_animations(tactical_board_id);
CREATE INDEX IF NOT EXISTS idx_tbanim_order ON tactical_board_animations(tactical_board_id, sequence_order);
CREATE INDEX IF NOT EXISTS idx_tbframe_animation ON tactical_board_animation_frames(animation_id);
CREATE INDEX IF NOT EXISTS idx_tbframe_player ON tactical_board_animation_frames(player_id);

-- Collaborators indexes
CREATE INDEX IF NOT EXISTS idx_tbc_user ON tactical_board_collaborators(user_id);

-- Tags indexes
CREATE INDEX IF NOT EXISTS idx_tbta_board ON tactical_board_tag_assignments(tactical_board_id);
CREATE INDEX IF NOT EXISTS idx_tbta_tag ON tactical_board_tag_assignments(tag_id);

-- =====================================================
-- TRIGGERS FOR UPDATED_AT
-- =====================================================

CREATE OR REPLACE FUNCTION update_tactical_board_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_tactical_boards_updated
    BEFORE UPDATE ON tactical_boards
    FOR EACH ROW
    EXECUTE FUNCTION update_tactical_board_timestamp();

CREATE TRIGGER trigger_tactical_board_players_updated
    BEFORE UPDATE ON tactical_board_players
    FOR EACH ROW
    EXECUTE FUNCTION update_tactical_board_timestamp();

-- =====================================================
-- SAMPLE TAGS
-- =====================================================

INSERT INTO tactical_board_tags (name, description, color) VALUES
    ('Corner Kick', 'Set piece - corner kicks', '#FF6B35'),
    ('Free Kick', 'Set piece - free kicks', '#4ECDC4'),
    ('Defensive Shape', 'Defensive organization and positioning', '#2E86AB'),
    ('Attacking Play', 'Offensive patterns and movements', '#A23B72'),
    ('Pressing', 'High press and counter-press situations', '#F18F01'),
    ('Build-up Play', 'Playing out from the back', '#C73E1D'),
    ('Counter Attack', 'Fast transition from defense to attack', '#6A994E'),
    ('Possession', 'Maintaining possession and control', '#BC4B51')
ON CONFLICT (name) DO NOTHING;

-- =====================================================
-- TABLE AND COLUMN COMMENTS
-- =====================================================

-- Lookup table comments
COMMENT ON TABLE tactical_board_types IS 'Lookup: Types of tactical boards (match, practice, club-wide, template)';
COMMENT ON TABLE tactical_stances IS 'Lookup: Tactical stances (offensive, defensive, pressing, counter, etc.)';
COMMENT ON TABLE tactical_field_thirds IS 'Lookup: Field positioning zones (own, middle, final third)';
COMMENT ON TABLE tactical_position_roles IS 'Lookup: Player position categories (GK, DEF, MID, ATT)';
COMMENT ON TABLE tactical_arrow_types IS 'Lookup: Arrow types with default colors (movement, pass, run, press, etc.)';
COMMENT ON TABLE tactical_line_styles IS 'Lookup: Line drawing styles (solid, dashed, dotted)';

-- Main table comments
COMMENT ON TABLE tactical_boards IS 'Main tactical board sessions with metadata and settings';
COMMENT ON TABLE tactical_board_entities IS 'Many-to-many: Links boards to entities (match, practice, team, club, division)';
COMMENT ON TABLE tactical_board_players IS 'Individual player pieces positioned on the tactical board';
COMMENT ON TABLE tactical_board_arrows IS 'Arrows indicating movements, passes, and tactical instructions';
COMMENT ON TABLE tactical_board_annotations IS 'Text annotations and labels on the tactical board';
COMMENT ON TABLE tactical_board_animations IS 'Animation sequences for multi-phase tactical explanations';
COMMENT ON TABLE tactical_board_animation_frames IS 'Individual frames defining player positions in animations';
COMMENT ON TABLE tactical_board_collaborators IS 'Users who can view or edit specific tactical boards';
COMMENT ON TABLE tactical_board_tags IS 'Categories for organizing tactical boards';
COMMENT ON TABLE tactical_board_tag_assignments IS 'Many-to-many: Links boards to tags';

-- Column comments
COMMENT ON COLUMN tactical_board_entities.match_id IS 'Links to specific match for match preparation';
COMMENT ON COLUMN tactical_board_entities.practice_id IS 'Links to specific practice for training drills';
COMMENT ON COLUMN tactical_board_entities.team_id IS 'Links to team for team-specific boards';
COMMENT ON COLUMN tactical_board_entities.club_id IS 'Links to club for club-wide instruction';
COMMENT ON COLUMN tactical_board_entities.sport_division_id IS 'Links to division for division-wide boards';
COMMENT ON COLUMN tactical_board_arrows.from_player_id IS 'Links arrow to starting player for analytics';
COMMENT ON COLUMN tactical_board_arrows.to_player_id IS 'Links arrow to ending player for analytics';
