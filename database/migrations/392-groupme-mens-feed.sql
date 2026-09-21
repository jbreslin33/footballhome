-- 392-groupme-mens-feed.sql
--
-- Read-only GroupMe feed on #my.  The Men's club GroupMe group is
-- registered as an integration of the 'mens' chat, so the same
-- membership rule that gates the chat (and its chat_links, mig 391)
-- gates the feed.  sync_messages = true is the switch the backend reads;
-- external_name is the heading the screen shows.  The access token is
-- NOT here — it lives in env as GROUPME_ACCESS_TOKEN.
INSERT INTO chat_providers (name, description)
VALUES ('groupme', 'GroupMe group chat (read-only message feed)')
ON CONFLICT (name) DO UPDATE SET is_active = true;

INSERT INTO chat_integrations (chat_id, provider_id, external_id, external_name, is_primary, sync_messages)
SELECT c.id, p.id, '117642517', 'Men''s GroupMe', true, true
  FROM chats c, chat_providers p
 WHERE c.slug = 'mens' AND p.name = 'groupme'
ON CONFLICT (provider_id, external_id) DO NOTHING;
