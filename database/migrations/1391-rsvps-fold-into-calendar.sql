-- 1391 (2026-11-16) — RSVP Reminders folds into the 📅 Calendar.  Owner on
-- the one-page plan: "3. fold it".  #rsvps (RsvpBoardScreen) is now the
-- Calendar's 👥 By person half for admins; 📅 By event is the calendar.
-- Old #rsvps doors (menu, dashboard tiles, saved returns) land there.

UPDATE menu_pages SET is_active = false WHERE code = 'rsvps';
UPDATE menu_pages
   SET screens = array_append(screens, 'rsvps')
 WHERE code = 'calendar' AND NOT ('rsvps' = ANY (screens));

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Event Center', v.label, 'event_center', v.tier, NULL, v.body, v.sort_order, true, true, false
  FROM (VALUES
    ('Calendar — admin switch: the calendar',            'mode_event',  '📅 By event',  1338),
    ('Calendar — admin switch: RSVP reminders by person', 'mode_people', '👥 By person', 1339)
  ) AS v(label, tier, body, sort_order)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'event_center' AND m.tier = v.tier);
