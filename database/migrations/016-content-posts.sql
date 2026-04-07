-- Content Posts: User-uploaded media (photo/video) for Instagram posts, reels, stories
CREATE TABLE IF NOT EXISTS content_posts (
    id SERIAL PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    caption TEXT,
    format VARCHAR(20) NOT NULL DEFAULT 'post',  -- 'post', 'reel', 'story'
    
    -- Original uploaded media
    original_path TEXT,
    original_url TEXT,
    
    -- Final media (with or without sponsor overlay)
    image_path TEXT,
    image_url TEXT,
    video_path TEXT,
    video_url TEXT,
    media_type VARCHAR(10) DEFAULT 'image',  -- 'image' or 'video'
    
    -- Sponsor overlay
    include_sponsor BOOLEAN NOT NULL DEFAULT true,
    
    -- Status tracking
    status VARCHAR(20) NOT NULL DEFAULT 'draft',
    scheduled_at TIMESTAMPTZ,
    posted_at TIMESTAMPTZ,
    external_media_id VARCHAR(100),
    error_message TEXT,
    
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_content_posts_status ON content_posts(status);
