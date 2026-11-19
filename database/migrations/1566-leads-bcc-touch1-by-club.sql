-- 1566 (2026-11-19) — ✉️ BCC touch 1 per club on #leads.
-- Owner: "for leads there should be a bcc all who did not regiseer 1st touch
-- right?" → "actually it should be by "club" so one for men, youth women etc".
-- One button per club (Men's / Women's / Youth) above the board: Gmail opens
-- with every not-yet-registered lead of that club in BCC (not signed up, not
-- already a member, not dead, has an email; deduped) and the club's touch-1
-- email.  One email can't greet each first name, so {first} = the greeting row.
INSERT INTO message_templates (category, label, kind, tier, body, sort_order, client_side)
SELECT v.category, v.label, 'leads_bcc', v.tier, v.body, v.sort_order, true
  FROM (VALUES
    ('Leads', 'BCC touch 1: name in "Hi …," (one email to many)', 'greeting',   'there',                          10),
    ('Leads', 'BCC touch 1: button ({club}, {n} = emails)',       'button',     '✉️ BCC {club} touch 1 ({n})',    20),
    ('Leads', 'BCC touch 1: Men''s club name',                    'club_men',   'Men''s',                         30),
    ('Leads', 'BCC touch 1: Women''s club name',                  'club_women', 'Women''s',                       40),
    ('Leads', 'BCC touch 1: Youth club name',                     'club_youth', 'Youth',                          50),
    ('Leads', 'BCC touch 1: hint next to the buttons',            'hint',       'Everyone on the board not registered yet (not signed up, not a member, not dead). Each one logs an email touch.', 60)
  ) AS v(category, label, tier, body, sort_order)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'leads_bcc' AND m.tier = v.tier);
