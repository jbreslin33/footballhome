-- 724 (2026-10-26) — Email drafts to a contact (a league commissioner first).
-- Owner: "where can we put email commissioner of league? so like if i want
-- to email aaron about something like reschedule or time change i should be
-- able to without others being involved ... the 2 apsl home games i have to
-- give him times for ... we should be able to draft emails from here to
-- have a normal 'email' button and explanation and then delete them if we
-- want if they were one offs" → Send opens my Gmail; drafts are saved,
-- editable, deletable.
--
-- The commissioner is a club_contacts row on the league body (mig 558; APSL
-- loaded by psql, never in git — contacts rule), so Game Center's 📇 panel
-- already lists him on every APSL game.  A draft belongs to one contact and
-- optionally the game it was started from.  Send = Gmail compose filled in
-- + sent_at + a club_contact_messages row (tier 'draft'); Delete removes it.

CREATE TABLE IF NOT EXISTS contact_email_drafts (
    id                 BIGSERIAL PRIMARY KEY,
    contact_id         INT NOT NULL REFERENCES club_contacts(id) ON DELETE CASCADE,
    match_id           INT REFERENCES matches(id) ON DELETE SET NULL,
    subject            TEXT NOT NULL DEFAULT '',
    body               TEXT NOT NULL DEFAULT '',
    created_by_user_id INT REFERENCES users(id) ON DELETE SET NULL,
    created_at         TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at         TIMESTAMPTZ NOT NULL DEFAULT now(),
    sent_at            TIMESTAMPTZ
);
CREATE INDEX IF NOT EXISTS contact_email_drafts_contact_idx ON contact_email_drafts (contact_id, sent_at, updated_at DESC);
COMMENT ON TABLE contact_email_drafts IS
    'mig 724: one-to-one emails to a club/league contact, drafted in Game Center; sent via the owner''s Gmail (sent_at), deletable.';

-- Wording (client-side; tokens filled in Game Center).
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
SELECT 'Opponents', v.label, 'contact_draft', v.tier, v.subject, v.body, v.sort, true, true
  FROM (VALUES
    ('note',      'Contact drafts — explanation under the buttons', NULL,
     'Just you and {name}: write it here, it stays as a draft until you send or delete it. Send opens your Gmail with it filled in.', 1),
    ('new_game',  'Contact drafts — a new draft started from a game', '{league}: {matchup}, {date}',
     E'Hi {first},\n\n\n\nThanks,\n{sender}', 2),
    ('new_plain', 'Contact drafts — a new draft with no game', '',
     E'Hi {first},\n\n\n\nThanks,\n{sender}', 3)
  ) AS v(tier, label, subject, body, sort)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates t WHERE t.kind = 'contact_draft' AND t.tier = v.tier);
