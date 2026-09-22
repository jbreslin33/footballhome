-- 407 — Post to the section's GroupMe from the "Write a message" box on #my.
--
-- Owner 2026-09-22: "i want to be able to send in the 'Write a message' box
-- on fh to gm. remember no fh native chat in fh for men right now. also can
-- others send a message and we would use their fh name in the gm chat as
-- part of the message?"
--
-- The post goes out through the club's GroupMe access token, so GroupMe
-- shows it from the token's owner; the sender's Football Home name is
-- written into the text — the kind='groupme' tier='relay' row below is
-- that wording.  post_messages on chat_integrations is the switch (mens
-- on; womens/youth have no integration).  Every relay is logged in
-- chat_relay_log — audit trail and the 3-per-10-seconds rate limit.

ALTER TABLE chat_integrations ADD COLUMN IF NOT EXISTS post_messages boolean NOT NULL DEFAULT false;
COMMENT ON COLUMN chat_integrations.post_messages IS
  'true = members may post to this external group from #my (relayed through the club token, sender named in the text).';

UPDATE chat_integrations ci SET post_messages = true
  FROM chat_providers p
 WHERE p.id = ci.provider_id AND p.name = 'groupme' AND ci.external_id = '117642517';

CREATE TABLE IF NOT EXISTS chat_relay_log (
    id                   bigserial PRIMARY KEY,
    chat_integration_id  int  NOT NULL REFERENCES chat_integrations(id),
    person_id            int  NOT NULL REFERENCES persons(id),
    text                 text NOT NULL,                 -- what was posted, sender prefix included
    external_message_id  text,                          -- GroupMe message id, NULL if the post failed
    error                text,
    created_at           timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS chat_relay_log_person_recent_idx ON chat_relay_log (person_id, created_at DESC);

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, client_side)
SELECT 'System', 'GroupMe relay — how a member''s post reads in the group', 'groupme', 'relay', NULL,
       '{name}: {text}', 230, false
 WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = 'groupme' AND tier = 'relay');
