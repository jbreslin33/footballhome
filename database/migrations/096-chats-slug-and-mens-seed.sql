-- 096-chats-slug-and-mens-seed.sql
--
-- Adds a stable `slug` column to `chats` so backend code can look up
-- well-known chats by name without hardcoding an integer id.  Also
-- seeds the men's team chat, which becomes the "Chat" tab on the
-- signed-in player's /#my screen.
--
-- Scope decision (2026-07-06): men's-only for v1.  Every member of the
-- men's program (any un-archived row in `mens_assignments`) plus club
-- admins can read + post.  No pins, no moderation, no image uploads.
-- Purpose is practical schedule-adjacent chatter — "is practice still
-- on, it's raining" — so GroupMe can be phased out for RSVPs while
-- the site becomes the shared surface.
ALTER TABLE chats ADD COLUMN IF NOT EXISTS slug VARCHAR(64);
CREATE UNIQUE INDEX IF NOT EXISTS chats_slug_key ON chats (slug) WHERE slug IS NOT NULL;

-- Seed the men's chat.  Idempotent: if a chat with slug='mens' already
-- exists this is a no-op.  `is_active=true`, `name` displayed in the
-- UI header, `description` shown as sub-text on the tab.
INSERT INTO chats (slug, name, description, is_active)
SELECT 'mens', 'Lighthouse 1893 Men''s', 'Practical stuff — cancellations, weather, running late, anything schedule-adjacent.', true
WHERE NOT EXISTS (SELECT 1 FROM chats WHERE slug = 'mens');
