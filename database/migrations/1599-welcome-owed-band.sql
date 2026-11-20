-- 1599 (2026-11-20) — 👋 New registrations in the 🚦 band until welcomed.
-- Owner: "now i need to have any new registration show as a todo like
-- missing rsvp etc at top of page. action items. for me admin. they would
-- show until i send welcome right?" + "the button for them should take me
-- right to contact for them right? and pre selegct welcome message to club?"
--
-- Who: GET /api/welcomes/due (WelcomeLog::dueList) — a current LA
-- membership registered on/after welcome_outreach_policies' cutoff and no
-- person_welcomes row reaching them (same rule as the roster cards'
-- fuchsia WELCOME).  Club/super admins only, never while viewing as.
-- The box: "👋 Welcome — N new: Asif Nifaz · …  Welcome ›".  Its popup
-- lists each one; tapping a name opens their 📇 Contact popup with
-- 👋 Welcome preselected.  Sending it records person_welcomes → the name
-- drops off the band.  To start fresh, INSERT a later cutoff row.

INSERT INTO status_items (code, severity, window_hours, sort_order, is_active)
SELECT 'welcome_owed', 'action', NULL, 8, true
 WHERE NOT EXISTS (SELECT 1 FROM status_items WHERE code = 'welcome_owed');

INSERT INTO message_templates (category, label, kind, tier, body, sort_order, client_side)
SELECT 'Event Center', v.label, 'event_center', v.tier, v.body, 1100 + v.n, true
  FROM (VALUES
    (1, 'Band: new registrations box ({n} owed, {list} = names)', 'seg_welcome_owed',  '👋 Welcome — {n} new: {list}'),
    (2, 'Band: new registrations box button',                     'act_welcome_owed',  'Welcome ›'),
    (3, 'New registrations popup title',                          'sheet_welcome',     '👋 New registrations — send a welcome'),
    (4, 'New registrations popup: line under the title',          'welcome_intro',     'Tap a name — their contact opens with the welcome ready. They leave this list once it is sent.'),
    (5, 'New registrations popup: registered on ({date})',        'welcome_reg_on',    'registered {date}'),
    (6, 'New registrations popup: via a parent ({parent})',       'welcome_via',       'to {parent}'),
    (7, 'New registrations popup: nobody left',                   'welcome_empty',     'Everyone new has been welcomed. ✓')
  ) AS v(n, label, tier, body)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'event_center' AND m.tier = v.tier);
