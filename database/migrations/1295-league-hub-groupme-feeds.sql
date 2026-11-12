-- 1295 — GroupMe feeds on the league hubs (#casa, #apsl).
--
-- Owner 2026-11-12: "on casa admin i need this groupme chat just like mens
-- so i can see it from there. 'CASA Select PA (PHL & LNS)'" / "I also need
-- on APSL admin this chat ('APSL/CASA Recruitment')" / "also on apsl admin
-- page i need chat from gm ('Delaware River Conference - APSL')".
--
-- Same model as the Men's feed (mig 392): a chats row per hub (in-app
-- messaging off — the chat lives on GroupMe) and one chat_integrations row
-- per GroupMe group, sync_messages = the switch, external_name = heading.
-- Read-only (post_messages false).  Club admins read them through
-- GET /api/opponents/groupme?chat=<slug>.  chat_links rows = the "open in
-- GroupMe" pill under each hub's feeds.

INSERT INTO chats (name, slug, messaging_enabled, description)
VALUES ('CASA commissioner GroupMe', 'casa-hub', false, 'GroupMe feeds on #casa (mig 1295)'),
       ('APSL GroupMe',              'apsl-hub', false, 'GroupMe feeds on #apsl (mig 1295)')
ON CONFLICT (slug) WHERE slug IS NOT NULL DO NOTHING;

INSERT INTO chat_integrations (chat_id, provider_id, external_id, external_name, is_primary, sync_messages)
SELECT c.id, p.id, g.external_id, g.external_name, g.is_primary, true
  FROM (VALUES ('casa-hub', '87243536',  'CASA Select PA (PHL & LNS)',       true),
               ('apsl-hub', '87873733',  'APSL/CASA Recruitment',            true),
               ('apsl-hub', '101897592', 'Delaware River Conference - APSL', false))
       AS g(slug, external_id, external_name, is_primary)
  JOIN chats c ON c.slug = g.slug
  JOIN chat_providers p ON p.name = 'groupme'
ON CONFLICT (provider_id, external_id) DO NOTHING;

INSERT INTO chat_links (chat_id, label, url, sort_order)
SELECT c.id, '💬 Open GroupMe', 'https://web.groupme.com/chats', 10
  FROM chats c WHERE c.slug IN ('casa-hub', 'apsl-hub')
ON CONFLICT (chat_id, url) DO NOTHING;
