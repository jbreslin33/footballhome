-- 739: Event Center No Response reminders (owner 2026-10-26: "whenever a
-- player shows as no response we need easy buttons to remind for that
-- specific event and others. but that event should be highlite").
--
-- POST /api/rsvp-board/remind takes fh_event_id (+ only): the personal
-- reminder names that event ({focus}) and its link opens the roll call on
-- it — alone, or first and highlighted above the rest of the week.

-- {focus} in the personal reminders, right after "RSVP".
UPDATE message_templates
   SET body = regexp_replace(body, 'to RSVP\.', 'to RSVP[[ {focus}]].')
 WHERE kind = 'rsvp_reminder' AND tier IN ('adult', 'parent', 'multi')
   AND body NOT LIKE '%{focus}%' AND body LIKE '%to RSVP.%';

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT c, l, k, t, NULL, b, o, true, cs, pub
  FROM (VALUES
    -- reminder text ({event} = "Tue Oct 28, 6:30 PM — Practice")
    ('RSVP reminders', 'Reminder names one event ({event})',                  'rsvp_reminder', 'focus_only', 'for {event}', 1190, false, false),
    ('RSVP reminders', 'Reminder names one event first ({event} {more})',      'rsvp_reminder', 'focus_more', 'for {event} and {more} more', 1191, false, false),
    -- the roll call card the link opens
    ('Roll call',      'Tag on the event a reminder was about',                'rsvp_roll_call', 'focus_tag', '👉 This one', 1192, true, true),
    -- Event Center No Response rows
    ('Event Center',   'No Response row label — remind about this event only', 'event_center', 'remind_this', 'This one', 1193, true, false),
    ('Event Center',   'No Response row label — remind about everything open', 'event_center', 'remind_all',  'All open', 1194, true, false),
    ('Event Center',   'Tooltip — this event only ({name})',                   'event_center', 'remind_this_title', 'Remind {name} about this event only', 1195, true, false),
    ('Event Center',   'Tooltip — all open, this one first ({name})',          'event_center', 'remind_all_title',  'Remind {name} about everything still open this week, this event first', 1196, true, false),
    ('Event Center',   'Group bar over No Response ({n})',                     'event_center', 'remind_group', '📣 Remind all {n} who haven''t answered', 1197, true, false),
    ('Event Center',   'Sent note on a row ({time} {count})',                  'event_center', 'reminded', 'reminded {time}[[ ×{count}]]', 1198, true, false)
  ) AS v(c, l, k, t, b, o, cs, pub)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = v.k AND m.tier = v.t);
