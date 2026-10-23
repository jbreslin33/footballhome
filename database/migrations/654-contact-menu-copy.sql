-- 654 (2026-10-23) — Game Center contact menu: one ✉ CONTACT button per
-- card and one 📣 Message bar, each asking WHAT and HOW, with every option
-- saying whether it works for this person and why not.
-- Owner: "its confusing in game center what does what as far as
-- communication" → "and what works / needs to be more clear" → "yes
-- build the redesign".  Replaces the per-card AUTO/MANUAL boxes (mig 649,
-- whose badge, reasons and status line carry over) and the separate squad
-- and No Response group bars.
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Game Center', v.l, 'contact_menu', v.t, NULL, v.b, v.o, true, true, false
  FROM (VALUES
    ('button',       'Card — open the contact menu',                      '✉ CONTACT', 950),
    ('title',        'Menu title ({name})',                               'Contact {name}', 951),
    ('what',         'Menu — WHAT heading',                               'What', 952),
    ('how',          'Menu — HOW heading',                                'How', 953),
    ('who',          'Group bar — WHO heading',                           'Who', 954),
    ('what_game',    'WHAT — personal game link',                         'Game link (their sign-in link to this game)', 955),
    ('what_remind',  'WHAT — RSVP reminder',                              'RSVP reminder (every unanswered event this week)', 956),
    ('what_reg',     'WHAT — registration form ({form})',                 'Registration form ({form})', 957),
    ('what_blank',   'WHAT — blank message',                              'Blank — my own words', 958),
    ('how_club',     'HOW — club number',                                 '📲 Club text (215) 769-9197', 959),
    ('how_phone',    'HOW — your phone',                                  '💬 Text from my phone', 960),
    ('how_email',    'HOW — your Gmail',                                  '✉ Email from my Gmail', 961),
    ('how_call',     'HOW — call',                                        '📞 Call', 962),
    ('works',        'Option works',                                      '✅ works', 963),
    ('why_club_what','Why club text is off for this WHAT',                'club text sends only the game link or the registration form', 964),
    ('send',         'Menu — send button',                                'Send', 965),
    ('call_go',      'Menu — call button',                                'Call', 966),
    ('cancel',       'Menu — close',                                      'Close', 967),
    ('bar_title',    'Group bar title',                                   '📣 Message a group', 968),
    ('who_squad',    'WHO — whole squad ({n})',                           'Squad — Starting, Bench, Alternates ({n})', 969),
    ('who_changed',  'WHO — added or moved since told ({n})',             'Added or moved since last told ({n})', 970),
    ('who_noresp',   'WHO — no response ({n})',                           'No response yet ({n})', 971),
    ('group_what_squad',  'Group — what the squad message is',            'Game reminder: game, where, arrival + a link to this lineup. No personal sign-in link.', 972),
    ('group_what_noresp', 'Group — what the no-response message is',      'RSVP reminder listing the week''s open events. No personal sign-in link.', 973),
    ('group_text',   'Group HOW — group text from your phone',            '💬 Group text from my phone (groups of 10)', 974),
    ('group_email',  'Group HOW — one email, BCC',                        '✉ One email from my Gmail (everyone BCC''d)', 975),
    ('group_none',   'Group bar — nobody to message',                     'Nobody in this group right now.', 976)
  ) AS v(t, l, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'contact_menu' AND m.tier = v.t);
