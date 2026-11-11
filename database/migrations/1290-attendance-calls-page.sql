-- 1290 (2026-11-11): #attendance-calls — every attendance call that went out.
-- Owner: "so where on fh can i see attendance calls that went out" → "build
-- a page to see all attendance calls".  One fold per practice (newest
-- first): rounds, who was rung / texted, Twilio's answer, who is still
-- unmarked.  Data: GET /api/attendance-calls/log (attendance_call_rounds +
-- attendance_call_log, mig 1277).  Menu: This Week, after RSVP Reminders.

BEGIN;

UPDATE menu_pages SET sort_order = sort_order + 1 WHERE group_code = 'week' AND sort_order >= 6;
INSERT INTO menu_pages (code, group_code, label, icon, audience, sort_order, screens)
VALUES ('attendance-calls', 'week', 'Attendance Calls', '📞', 'admin', 6, '{attendance-calls}')
ON CONFLICT (code) DO NOTHING;

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Attendance calls', l, 'attendance_calls_page', t, NULL, b, o, true, true, false
  FROM (VALUES
    ('title',        'Page title',                         '📞 Attendance Calls', 1),
    ('subtitle',     'Page subtitle',                      'Every call and text sent to coaches to take attendance — newest practice first', 2),
    ('days_pill',    'Window pill ({n} days)',             'Last {n} days', 3),
    ('section_all',  'Section pill: all',                  'All', 4),
    ('policy_live',  'Section status: live',               '{section}: 📞 live — Going coaches rung', 5),
    ('policy_test',  'Section status: test',               '{section}: 🧪 test — {who} only', 6),
    ('policy_off',   'Section status: off',                '{section}: off', 7),
    ('policy_nobody','Section status: test, nobody',       '{section}: 🧪 test — nobody is rung', 8),
    ('empty',        'Nothing in the window',              'No attendance calls in this window.', 9),
    ('rounds',       'Card chip: rounds ({n})',            '{n} rounds', 10),
    ('calls',        'Card chip: calls ({ok}/{tried})',    '📞 {ok}/{tried} calls', 11),
    ('texts',        'Card chip: texts ({n})',             '💬 {n} texts', 12),
    ('unmarked_now', 'Card chip: still unmarked ({n})',    '{n} still unmarked', 13),
    ('all_marked',   'Card chip: everyone marked',         '✅ all marked', 14),
    ('live',         'Round chip: live',                   'LIVE', 15),
    ('test',         'Round chip: test',                   '🧪 TEST', 16),
    ('round',        'Round heading ({round}, {at}, {n})', 'Round {round} · {at} · {n} unmarked', 17),
    ('call',         'Channel: call',                      '📞 call', 18),
    ('sms',          'Channel: text',                      '💬 text', 19),
    ('failed',       'Outcome: failed ({error})',          '✗ failed {error}', 20),
    ('open_event',   'Open the practice button',           'Open practice ›', 21)
  ) v(t, l, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'attendance_calls_page' AND m.tier = v.t);

INSERT INTO schema_migrations (filename) VALUES ('1290-attendance-calls-page.sql') ON CONFLICT DO NOTHING;

COMMIT;
