-- 1445 (2026-11-17) — 📇 Event Center: a group CONTACT on every section of
-- the players pill (owner "why when on #event/…/players can i not message
-- all players going, not going etc. where is contact button. all screens
-- should have contact button!"). 💬 / ✉ open the same group composer as
-- #teams' column titles. Words only.
BEGIN;
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Event Center', v.label, 'event_center', v.tier, NULL, v.body, 1200, true, true, false
  FROM (VALUES
    ('Group contact: everyone heading',                  'group_all',        '👥 Everyone'),
    ('Group contact: email button tip ({n})',            'group_email_tip',  'Email {n} (BCC)'),
    ('Group contact: text button tip ({n})',             'group_text_tip',   'Text {n}'),
    ('Group contact: who can''t be reached ({phone} {email})', 'group_missing', '{phone} no mobile · {email} no email'),
    ('Group contact: composer title ({group} {event})',  'group_scope',      '{group} — {event}'),
    ('Group contact: email subject ({event})',           'group_subject',    '{event}')
  ) AS v(label, tier, body)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates t WHERE t.kind = 'event_center' AND t.tier = v.tier);
COMMIT;
