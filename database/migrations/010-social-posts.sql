-- ============================================================================
-- 010: Social Media Posts & Schedule Templates
-- ============================================================================
-- Adds tables for managing Instagram/social media posts per match,
-- with support for 4 post types and per-team scheduling templates.
-- ============================================================================

-- Post types: pre_match_announcement, game_day, lineup, post_game
CREATE TABLE IF NOT EXISTS social_post_types (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    display_name VARCHAR(100) NOT NULL,
    description TEXT,
    sort_order INT NOT NULL DEFAULT 0
);

INSERT INTO social_post_types (name, display_name, description, sort_order) VALUES
    ('pre_match_announcement', 'Pre-Match Announcement', 'Announce the upcoming match with opponent, date, time, venue', 1),
    ('game_day', 'Game Day Announcement', 'Game day hype post — includes game day roster/players', 2),
    ('lineup', 'Pre-Match Lineup', 'Reveal starters and subs before kickoff', 3),
    ('post_game', 'Post-Game Result', 'Final score, result, and match summary', 4)
ON CONFLICT (name) DO NOTHING;

-- Individual social posts linked to matches
CREATE TABLE IF NOT EXISTS social_posts (
    id SERIAL PRIMARY KEY,
    match_id INT NOT NULL REFERENCES matches(id) ON DELETE CASCADE,
    team_id INT NOT NULL REFERENCES teams(id) ON DELETE CASCADE,
    post_type_id INT NOT NULL REFERENCES social_post_types(id),
    platform VARCHAR(30) NOT NULL DEFAULT 'instagram',

    -- Content
    image_path TEXT,             -- local path to generated image
    image_url TEXT,              -- public URL for the image
    caption TEXT,                -- generated caption text

    -- Status
    status VARCHAR(20) NOT NULL DEFAULT 'draft',  -- draft, scheduled, posted, failed
    scheduled_at TIMESTAMPTZ,   -- when to auto-post (null = manual only)
    posted_at TIMESTAMPTZ,      -- when actually posted
    external_media_id VARCHAR(100), -- Instagram media ID after posting
    error_message TEXT,         -- if posting failed

    -- Metadata
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    UNIQUE(match_id, team_id, post_type_id, platform)
);

CREATE INDEX idx_social_posts_match ON social_posts(match_id);
CREATE INDEX idx_social_posts_team ON social_posts(team_id);
CREATE INDEX idx_social_posts_status ON social_posts(status);
CREATE INDEX idx_social_posts_scheduled ON social_posts(scheduled_at) WHERE status = 'scheduled';

COMMENT ON TABLE social_posts IS 'Social media posts for matches. Each match can have up to 4 post types per team per platform.';

-- Per-team schedule templates (the "permanent" schedule)
-- e.g., "For team X, pre_match_announcement always posts 4 days before at 10:00 AM"
CREATE TABLE IF NOT EXISTS social_schedule_templates (
    id SERIAL PRIMARY KEY,
    team_id INT NOT NULL REFERENCES teams(id) ON DELETE CASCADE,
    post_type_id INT NOT NULL REFERENCES social_post_types(id),
    platform VARCHAR(30) NOT NULL DEFAULT 'instagram',

    -- Schedule relative to match time
    days_before INT NOT NULL DEFAULT 0,     -- how many days before match day
    post_time TIME NOT NULL DEFAULT '10:00', -- time of day to post (in team's local time)
    enabled BOOLEAN NOT NULL DEFAULT true,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    UNIQUE(team_id, post_type_id, platform)
);

COMMENT ON TABLE social_schedule_templates IS 'Per-team default posting schedule. Defines when each post type auto-publishes relative to match day.';

-- Seed some sensible defaults for schedule templates
-- (These will be created per-team when a team first configures their schedule)
