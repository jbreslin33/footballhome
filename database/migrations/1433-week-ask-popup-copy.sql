-- 1433 (2026-11-17) — 📅 "Set the rest of your week" popup words
-- (frontend/js/lib/week-ask.js).  Owner: "after they set that we should
-- have a popup that shows the rest of events that week (set and not set so
-- they don't forget about the ones they set) then they can set them all
-- right there or close box … this is for all teams".
-- Opens on every event page after you answer it (you or your kids), with
-- the week's other open events.  Row lines reuse me_status_* / kid_status_*.

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
SELECT 'Event Center', v.label, 'event_center', v.tier, NULL, v.body, v.sort, true, true
  FROM (VALUES
    ('week_ask_title',        'Week popup — title, events still unanswered ({n})', '📅 Thanks! {n} more this week', 920),
    ('week_ask_body',         'Week popup — line under the title',                 'Set the rest of your week while you''re here — the coaches plan off every answer.', 921),
    ('week_ask_all_set',      'Week popup — title once every event is answered',   '✅ All set for the week', 922),
    ('week_ask_all_set_body', 'Week popup — line once every event is answered',    'Every event this week has an answer. Change any of them here or on the calendar.', 923),
    ('week_ask_open',         'Week popup — heading over the unanswered events',   'Still to answer', 924),
    ('week_ask_done',         'Week popup — heading over the answered events',     'Already answered', 925),
    ('week_ask_going',        'Week popup — Going button',                         'Going', 926),
    ('week_ask_not_going',    'Week popup — Not Going button',                     'Not Going', 927),
    ('week_ask_close',        'Week popup — close button',                         'Done', 928)
  ) AS v(tier, label, body, sort)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates t WHERE t.kind = 'event_center' AND t.tier = v.tier);
