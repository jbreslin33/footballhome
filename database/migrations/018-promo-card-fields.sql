-- Add card design fields to promotional_posts so each post stores its own
-- heading, subheading, body lines, and footer (previously hardcoded in JS).
ALTER TABLE promotional_posts ADD COLUMN IF NOT EXISTS heading VARCHAR(200);
ALTER TABLE promotional_posts ADD COLUMN IF NOT EXISTS subheading VARCHAR(200);
ALTER TABLE promotional_posts ADD COLUMN IF NOT EXISTS body_lines TEXT;
ALTER TABLE promotional_posts ADD COLUMN IF NOT EXISTS footer VARCHAR(200);
