-- 1183 (2026-11-07) — Instagram collaborators: a list, ticked by default.
-- Owner: "can we auto tag as colloborator edesamour ?" then "can this be
-- default to tag him on all posts? i would have to uncheck him. and we could
-- build a list of others later."
--
-- social_collaborators is the list.  default_on = ticked on every post's
-- panel (untick to leave them off that post); posts that publish with no
-- panel (scheduled ones) take the default_on names.  Instagram allows 3 per
-- post and none on stories.  The collaborator gets an invite in Instagram;
-- the post shows on their profile once they accept.  Grow the list by
-- migration.  SocialController::collaboratorsParam reads it.
DROP TABLE IF EXISTS social_post_type_collaborators;   -- this migration's first draft

CREATE TABLE IF NOT EXISTS social_collaborators (
  id          SERIAL PRIMARY KEY,
  platform    VARCHAR(50) NOT NULL DEFAULT 'instagram',
  username    VARCHAR(30) NOT NULL CHECK (username ~ '^[A-Za-z0-9._]{1,30}$'),
  default_on  BOOLEAN NOT NULL DEFAULT true,
  is_active   BOOLEAN NOT NULL DEFAULT true,
  sort_order  INT NOT NULL DEFAULT 0,
  UNIQUE (platform, username)
);

INSERT INTO social_collaborators (username, default_on, sort_order)
VALUES ('edesamour', true, 1)
ON CONFLICT (platform, username) DO NOTHING;

DELETE FROM message_templates WHERE kind = 'weekend_slides' AND tier = 'collaborators';

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
SELECT 'System', v.label, 'social_post', v.tier, NULL, v.body, v.sort, true, true
  FROM (VALUES
    ('collab_heading', 'Instagram post — collaborators heading', '🤝 Tag as collaborator', 10),
    ('collab_hint',    'Instagram post — collaborators hint',    'They get an invite in Instagram; the post shows on their profile too once they accept.', 11)
  ) AS v(tier, label, body, sort)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'social_post' AND m.tier = v.tier);
