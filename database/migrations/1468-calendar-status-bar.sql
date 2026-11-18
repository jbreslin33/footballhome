-- 1468 (2026-11-18) — 📅 Calendar status bar: everything outstanding, one line,
-- green / yellow / red.  Owner 11/18 (viewing as a player): "this is where
-- all the outstanding items should go. including unread messages, warning
-- they have unset rsvp, dues, fines etc. then if all set on all it should
-- show in green and say up to date? then in yellow if something minor and
-- red if major?" → "this would keep cal area cleaner" → "keep the extra
-- view as for me lol and show the one i mentioned below it".
--
-- The orange 🎭 view-as bar stays the admin's own (the way out).  Under it,
-- for everyone, ONE bar: colour = the worst item, a headline, a chip per
-- item; tap → the details (unanswered strip, dues / volunteer notice, chat,
-- fines), folded by default.
--
-- status_items: which item is major (red) or minor (yellow), and the
-- window for "answer soon".  Change a severity by migration.
BEGIN;

CREATE TABLE IF NOT EXISTS status_items (
    code          text PRIMARY KEY,
    severity      text NOT NULL CHECK (severity IN ('major', 'minor')),
    window_hours  integer CHECK (window_hours IS NULL OR window_hours > 0),
    sort_order    integer NOT NULL DEFAULT 0,
    is_active     boolean NOT NULL DEFAULT true
);
COMMENT ON TABLE status_items IS
  'mig 1468: the Calendar status bar''s items — major = red, minor = yellow; window_hours = how close an unanswered event turns major. Words: message_templates event_center chip_<code>.';

INSERT INTO status_items (code, severity, window_hours, sort_order) VALUES
    ('dues_blocked', 'major', NULL, 1),   -- ineligible for games & practice (dues)
    ('suspended',    'major', NULL, 2),   -- suspended for an event this week
    ('rsvp_soon',    'major', 48,   3),   -- unanswered, starts within 48 h
    ('rsvp_open',    'minor', NULL, 4),   -- unanswered, later this week
    ('dues_owed',    'minor', NULL, 5),   -- owes dues (warning / alternate / volunteer back balance)
    ('fines_owed',   'minor', NULL, 6),
    ('chat_unread',  'minor', NULL, 7)
ON CONFLICT (code) DO NOTHING;

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Event Center', v.label, 'event_center', v.tier, NULL, v.body, v.sort_order, true, true, false
  FROM (VALUES
    ('Status bar — all set',                 'status_ok',         '✓ You''re all set — nothing needs you',  1360),
    ('Status bar — one minor thing',         'status_minor_one',  '⚠️ 1 thing to look at',                 1361),
    ('Status bar — minor things',            'status_minor_many', '⚠️ {n} things to look at',              1362),
    ('Status bar — one major thing',         'status_major_one',  '⛔ 1 needs you now',                     1363),
    ('Status bar — major things',            'status_major_many', '⛔ {n} need you now',                    1364),
    ('Status bar — open the details',        'status_open',       'Details ▾',                             1365),
    ('Status bar — fold the details',        'status_close',      'Hide ▴',                                1366),
    ('Status chip — blocked for dues',       'chip_dues_blocked', 'Ineligible — {amount} dues',            1367),
    ('Status chip — suspended',              'chip_suspended',    'Suspended',                             1368),
    ('Status chip — answer soon',            'chip_rsvp_soon',    '{n} to answer in the next {hours}h',    1369),
    ('Status chip — answer this week',       'chip_rsvp_open',    '{n} to answer',                         1370),
    ('Status chip — dues owed',              'chip_dues_owed',    '{amount} dues',                         1371),
    ('Status chip — fines owed',             'chip_fines_owed',   '{amount} fines',                        1372),
    ('Status chip — unread chat',            'chip_chat_unread',  '{n} new messages',                      1373)
  ) AS v(label, tier, body, sort_order)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'event_center' AND m.tier = v.tier);

COMMIT;
