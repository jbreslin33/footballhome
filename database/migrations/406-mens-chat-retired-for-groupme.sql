-- 406 — Retire the in-app Men's chat; GroupMe carries it.
--
-- Owner 2026-09-22: "lets get rid of the chat for men. since we are using
-- groupme for chat".
--
-- The chat ROW stays: the Men's GroupMe join link (chat_links, mig 391)
-- and the read-only GroupMe feed (chat_integrations, mig 392) hang off it,
-- and membership (who sees those) is resolved through it.  What goes is
-- the messaging: chats.messaging_enabled = false makes
-- GET /api/my/chat/messages return no history and the flag, POST refuse,
-- and #my draw only the section links.  History (43 messages) is kept.
-- Flip the flag back by migration to bring the in-app chat back.

ALTER TABLE chats ADD COLUMN IF NOT EXISTS messaging_enabled boolean NOT NULL DEFAULT true;
COMMENT ON COLUMN chats.messaging_enabled IS
  'false = no in-app messaging (links/integrations still shown); the section chats elsewhere (GroupMe etc.).';

UPDATE chats SET messaging_enabled = false WHERE slug = 'mens';
