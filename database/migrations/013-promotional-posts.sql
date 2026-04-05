-- Migration 013: Promotional posts table for non-match Instagram posts
-- These are standalone promotional posts (registration open, tryouts, etc.)

CREATE TABLE IF NOT EXISTS promotional_posts (
    id SERIAL PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    caption TEXT,
    image_path TEXT,
    image_url TEXT,
    status VARCHAR(20) NOT NULL DEFAULT 'draft',
    scheduled_at TIMESTAMPTZ,
    posted_at TIMESTAMPTZ,
    external_media_id VARCHAR(100),
    error_message TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_promotional_posts_status ON promotional_posts(status);
