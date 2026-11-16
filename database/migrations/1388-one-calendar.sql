-- 1388 (2026-11-16) — ONE 📅 Calendar.  Owner: "#calendar is still confusing.
-- rsvp, calendar and event center should be one page. when you click an event
-- it should take you to the event with more details and lineups etc." +
-- "1. calendar".
--
-- The This Week group had three doors to two calendars: ☑️ RSVP (→ #my →
-- Event Center), 📋 Event Center (the same page) and 🗓️ Calendar (the old
-- Google-mirror screen, where a tap opened a post/flyer menu — or nothing for
-- a player).  Now one page, Event Center's, at #calendar, for everyone: Week ·
-- Month · Agenda, admins also get the release and field-clash strips, the
-- tag audit and unclassified Google events; a tap always opens the event
-- (post / flyer moved onto the event's 👀 bar).

-- The menu: one Calendar page holds every event screen; RSVP and Event
-- Center retire (kept as rows, off — MainMenu.open still routes their codes).
UPDATE menu_pages
   SET label = 'Calendar', icon = '📅', audience = 'everyone', sort_order = 1,
       screens = ARRAY['event-center', 'calendar', 'my', 'game-center', 'attendance', 'event', 'practice',
                       'game-lineup', 'game-day-roster', 'lineups', 'player-calendar']
 WHERE code = 'calendar';
UPDATE menu_pages SET is_active = false WHERE code IN ('player', 'game-center');

-- The page's words.
UPDATE message_templates SET body = '📅 Calendar', updated_at = now()
 WHERE kind = 'event_center' AND tier = 'title';
UPDATE message_templates SET body = 'Tap an event to open it — lineups, who''s coming, everything', updated_at = now()
 WHERE kind = 'event_center' AND tier = 'list_sub';

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Event Center', v.label, 'event_center', v.tier, NULL, v.body, v.sort_order, true, true, false
  FROM (VALUES
    ('Calendar — view chip: week',              'view_week',    'Week',   1330),
    ('Calendar — view chip: month',             'view_month',   'Month',  1331),
    ('Calendar — view chip: agenda (4 weeks)',  'view_agenda',  'Agenda', 1332),
    ('Calendar — jump back to this month',      'this_month',   'This month', 1333),
    ('Calendar — agenda with nothing on',       'agenda_empty', 'Nothing on in these four weeks', 1334),
    ('Calendar — admin: Google event not classified', 'unclassified', '⚠ Not in Football Home yet — tag it in Google Calendar', 1335),
    ('Event — admin: start an Instagram post',  'post_btn',     '📷 Instagram post', 1336),
    ('Event — admin: start a flyer',            'flyer_btn',    '🖨️ Flyer', 1337)
  ) AS v(label, tier, body, sort_order)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'event_center' AND m.tier = v.tier);
