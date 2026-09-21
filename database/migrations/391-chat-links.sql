-- 391-chat-links.sql
--
-- Section links at the top of #my.  The page already resolves each
-- viewer to one club chat (mens / womens / youth — MyController's
-- chatSlugForPerson, driven by active LA membership), so a link that
-- belongs to a section hangs off that chat row: whoever is a member of
-- the chat sees its links, nobody else does.
--
-- First row: the Men's club GroupMe join link (owner 2026-09-20).
-- Add / reword / retire links by migration — the screen renders
-- whatever rows are active, in sort_order.
CREATE TABLE IF NOT EXISTS chat_links (
    id          SERIAL PRIMARY KEY,
    chat_id     INTEGER NOT NULL REFERENCES chats(id) ON DELETE CASCADE,
    label       TEXT    NOT NULL,
    url         TEXT    NOT NULL,
    sort_order  INTEGER NOT NULL DEFAULT 0,
    is_active   BOOLEAN NOT NULL DEFAULT true,
    created_at  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (chat_id, url)
);

INSERT INTO chat_links (chat_id, label, url, sort_order)
SELECT c.id, '💬 Join the Men''s GroupMe', 'https://groupme.com/join_group/117642517/w0eqm5La', 10
  FROM chats c
 WHERE c.slug = 'mens'
ON CONFLICT (chat_id, url) DO NOTHING;
