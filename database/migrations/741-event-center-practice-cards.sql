-- 741: Event Center step 2 — a practice's Who's Coming as Game Center's
-- RSVP cards (owner 2026-10-26: "i like the rsvp situaiton in game center
-- and want that for practice").  Section labels, the groups/teams chooser
-- over the Going cards, and the line saying where a card's 💬 reminder
-- goes (FH Texter when it can take it, else the texting app).
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Event Center', l, 'event_center', t, NULL, b, o, true, true, false
  FROM (VALUES
    ('sec_going',       'Section — Going',                                  '✓ Going', 1200),
    ('sec_invited',     'Section — invited and available',                  '🎟 Invited · Available', 1201),
    ('sec_ineligible',  'Section — said going, over the dues line',         '⛔ Said going · Ineligible (dues)', 1202),
    ('sec_noresp',      'Section — no response (fold)',                     '– No response', 1203),
    ('sec_notgoing',    'Section — not going (fold)',                       '✗ Not going', 1204),
    ('groups_in_play',  'Practice: label before the group colours',         'Groups', 1205),
    ('teams_in_play',   'Pickup: label before the team colours',            'Teams', 1206),
    ('text_via_relay',  'Where a card''s 💬 goes — FH Texter ({device} {today} {cap})', '💬 on a card texts from {device} ({today}/{cap} today)', 1207),
    ('text_via_app',    'Where a card''s 💬 goes — texting app',            '💬 on a card opens your texting app', 1208),
    ('relay_fell_back', 'FH Texter refused a text ({error})',               'FH Texter could not send ({error}) — opened in your texting app', 1209)
  ) AS v(t, l, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'event_center' AND m.tier = v.t);
