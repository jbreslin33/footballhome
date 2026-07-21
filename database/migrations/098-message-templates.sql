-- 098 — add message templates for DB-backed outreach copy
BEGIN;

CREATE TABLE IF NOT EXISTS message_templates (
    id BIGSERIAL PRIMARY KEY,
    category VARCHAR(100) NOT NULL,
    label VARCHAR(200) NOT NULL,
    kind VARCHAR(50) NOT NULL DEFAULT 'snippet',
    tier VARCHAR(50) NOT NULL DEFAULT 'info',
    subject TEXT,
    body TEXT NOT NULL,
    html_body TEXT,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    sort_order INT NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_message_templates_category_active
    ON message_templates (category, is_active, sort_order, id);

INSERT INTO message_templates (category, label, kind, tier, subject, body, html_body, sort_order)
VALUES (
    'Men''s Club',
    'Mens practice availability reminder',
    'initial',
    'broadcast',
    'Football Home — RSVP',
    'Hi {first},\n\nThis is a gentle reminder that setting availability for practice is a team rule. If you are not sure, set Not Going. Please set your availability on My: https://footballhome.org/#my whether you are going or not, and change it if going. Team Rule: https://footballhome.org/#player-team-rules\n\nhttps://footballhome.org/#my\n\nThis link signs you in automatically and expires in 48 hours.\n\n— Lighthouse Soccer',
    '<p>Hi {first},</p><p>This is a gentle reminder that setting availability for practice is a team rule. If you are not sure, set Not Going. Please set your availability on My: <a href="https://footballhome.org/#my">https://footballhome.org/#my</a> whether you are going or not, and change it if going. Team Rule: <a href="https://footballhome.org/#player-team-rules">https://footballhome.org/#player-team-rules</a></p><p><a href="https://footballhome.org/#my">https://footballhome.org/#my</a></p><p>This link signs you in automatically and expires in 48 hours.</p><p>— Lighthouse Soccer</p>',
    0
)
ON CONFLICT DO NOTHING;

COMMIT;
