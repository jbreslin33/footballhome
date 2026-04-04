-- Migration 012: Holiday posts table for non-match Instagram posts
-- These are standalone posts (Easter, Mother's Day, etc.) not tied to a match

CREATE TABLE IF NOT EXISTS holiday_posts (
    id SERIAL PRIMARY KEY,
    holiday_name VARCHAR(100) NOT NULL,
    holiday_date DATE NOT NULL,
    caption TEXT,
    image_path TEXT,
    image_url TEXT,
    status VARCHAR(20) NOT NULL DEFAULT 'draft',
    scheduled_at TIMESTAMPTZ,
    posted_at TIMESTAMPTZ,
    external_media_id VARCHAR(100),
    error_message TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(holiday_name, holiday_date)
);

CREATE INDEX IF NOT EXISTS idx_holiday_posts_status ON holiday_posts(status);
CREATE INDEX IF NOT EXISTS idx_holiday_posts_date ON holiday_posts(holiday_date);
