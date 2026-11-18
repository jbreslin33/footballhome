-- 1473 (2026-11-18) — 🚦 Status band: boxes, each with its own popup.
-- Owner 11/18: "each item needs to be in a box and actionable. so on phone
-- boxes would be stacked and desktop across" → "what is point of details?
-- just let each box do its own expanding" → "each box needs to expand
-- itself and not the others. missing rsvp button needs either page them down
-- to first missing one or open pop up" → popup (the band is on every
-- screen; the Calendar is not).
--
-- No "Details" any more.  Each box's button opens its own popup (a sheet
-- from the bottom on a phone, a centred window on a desktop):
--   ⛔ Missing N RSVPs  [Answer ›]          → the unanswered events, ✓ / ✗ each
--   ⛔ Overdue dues $X  [Pay now ›] [🙋 Volunteer ›] → LA / the volunteer card
--   ⚖️ Fined so far $X  [See ›]             → the fines
--   💬 newest message   [N new › | Open ›]  → the chat (always a box)
UPDATE message_templates SET body = 'Answer ›', updated_at = now()
 WHERE kind = 'event_center' AND tier IN ('act_rsvp_soon', 'act_rsvp_open');
UPDATE message_templates SET body = 'See ›', updated_at = now()
 WHERE kind = 'event_center' AND tier = 'act_fines_owed';
UPDATE message_templates SET body = '{n} new ›', updated_at = now()
 WHERE kind = 'event_center' AND tier = 'act_chat_unread';

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Event Center', v.label, 'event_center', v.tier, NULL, v.body, v.sort_order, true, true, false
  FROM (VALUES
    ('Status band — fines box',                      'seg_fines_owed',     '⚖️ Fined so far {amount}',                             1393),
    ('Status band — chat box (newest message)',      'seg_chat_unread',    '💬 {text}',                                           1394),
    ('Status band — chat button, nothing new',       'act_chat_read',      'Open ›',                                              1395),
    ('Status band — volunteer button',               'act_volunteer',      '🙋 Volunteer ›',                                      1396),
    ('Status band — volunteer button, picked',       'act_volunteer_pick', '🙋 My volunteer slots ›',                             1397),
    ('Status popup — RSVPs title',                   'sheet_rsvp',         '⚠️ Set your availability',                            1398),
    ('Status popup — fines title',                   'sheet_fines',        '⚖️ Your fines',                                       1399),
    ('Status popup — chat title',                    'sheet_chat',         '💬 Chat',                                             1400),
    ('Status popup — volunteer title',               'sheet_volunteer',    '🙋 Volunteer',                                        1401),
    ('Status popup — RSVPs: how',                    'need_how_short',     'Tap ✓ going or ✗ not going — tap the event to open it', 1402)
  ) AS v(label, tier, body, sort_order)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'event_center' AND m.tier = v.tier);
