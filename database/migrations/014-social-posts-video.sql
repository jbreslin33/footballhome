-- Add video support to social_posts for Instagram Reels
ALTER TABLE social_posts ADD COLUMN IF NOT EXISTS video_path TEXT;
ALTER TABLE social_posts ADD COLUMN IF NOT EXISTS video_url TEXT;
ALTER TABLE social_posts ADD COLUMN IF NOT EXISTS media_type VARCHAR(10) NOT NULL DEFAULT 'image';

COMMENT ON COLUMN social_posts.video_path IS 'Local path to converted MP4 video';
COMMENT ON COLUMN social_posts.video_url IS 'Public URL for the MP4 video';
COMMENT ON COLUMN social_posts.media_type IS 'image or video - determines Instagram publish method';
