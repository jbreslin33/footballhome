-- Add overlay_logos column to content_posts for multi-logo overlay support
-- Stores comma-separated logo keys: sponsor,epysa,apsl,casa
ALTER TABLE content_posts ADD COLUMN IF NOT EXISTS overlay_logos TEXT DEFAULT 'sponsor';
