-- 503 (2026-09-30) — Reopen a post that was deleted on Instagram.
-- Owner: "we need to be able to regenerate post if we deleted it from
-- insta. like have a button if it says posted that we can put that we
-- deleted from insta so that it allows new post".
--
-- A published post cannot be edited on Instagram, only deleted there; the
-- card in #game-center then still said "✅ Posted" and offered nothing.
-- POST /api/social/posts/:id/reopen (SocialController::handleReopenPost)
-- turns the row back into a bare draft; these are the words on its button
-- (client_side rows, read through MessageCopy.block('social_post', tier)).
CREATE OR REPLACE FUNCTION pg_temp.add_client_tpl(p_kind text, p_tier text, p_label text, p_body text, p_sort int)
RETURNS void LANGUAGE sql AS $$
  INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
  SELECT 'System', p_label, p_kind, p_tier, NULL, p_body, p_sort, true, true
   WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = p_kind AND tier = p_tier);
$$;

SELECT pg_temp.add_client_tpl('social_post', 'reopen_hint',    'Instagram post — reopen hint',
  'Instagram can''t edit a post that has gone out. To change it, delete it in the Instagram app, then reopen it here and post a fresh one.', 1);
SELECT pg_temp.add_client_tpl('social_post', 'reopen_button',  'Instagram post — reopen button',
  '🗑 I deleted it from Instagram — make a new post', 2);
SELECT pg_temp.add_client_tpl('social_post', 'reopen_confirm', 'Instagram post — reopen, second tap',
  'Tap again: clears ✅ Posted and rebuilds this post', 3);
SELECT pg_temp.add_client_tpl('social_post', 'reopen_failed',  'Instagram post — reopen failed',
  'Could not reopen the post: {reason}', 4);
