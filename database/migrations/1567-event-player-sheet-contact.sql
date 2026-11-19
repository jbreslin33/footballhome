-- 1567 (2026-11-19) — Tap a player on an event → the ONE player sheet, its
-- 📇 Contact knowing the event.  Owner: "for event page when you click a
-- player it should bring up a consistent interface … for practice and games
-- if i click a no response or reserves it sould allow me to contact to rsvp
-- … bringing up palyer profiel and have contact button and then one of the
-- options knows what event it spawned from. but there should be normal
-- contact popup".  The sheet opens on 📇 Contact when they owe an answer
-- (– No response / 👋 never answered → 📣 RSVP reminder first; 🪑 Reserve /
-- 💤 Inactive off the list → 🎟 invite first), on 📅 Activity (✅ attendance
-- for this event) while the roll is open, else 👤 Person.  🪑 Reserve cards'
-- CONTACT now carry the same RSVP way in.  Game move sheet: + ⋯ Player sheet.
INSERT INTO message_templates (category, label, kind, tier, body, sort_order, client_side)
SELECT v.category, v.label, 'event_center', v.tier, v.body, v.sort_order, true
  FROM (VALUES
    ('Event Center', 'Player sheet off an event: row to open the sheet', 'person_sheet', '⋯ Player sheet', 910),
    ('Event Center', 'Player sheet 📇 Contact: owes an answer', 'sheet_contact_remind', 'Hasn''t answered {event} — 📣 RSVP reminder is first in Contact.', 911),
    ('Event Center', 'Player sheet 📇 Contact: Reserve / Inactive, invite', 'sheet_contact_callup', 'Not on the list for {event} — 🎟 RSVP link (invite) is first in Contact.', 912),
    ('Event Center', 'Player sheet 📇 Contact: nothing owed', 'sheet_contact_event', 'From {event}.', 913)
  ) AS v(category, label, tier, body, sort_order)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'event_center' AND m.tier = v.tier);
-- 🪑 Reserves (mig 1530 Standby) are never reminded and can answer any time,
-- so their way in is the 📣 Ask Reserves words (ask_standby_body), to one man.
INSERT INTO message_templates (category, label, kind, tier, body, sort_order, client_side)
SELECT v.category, v.label, 'event_center', v.tier, v.body, v.sort_order, true
  FROM (VALUES
    ('Event Center', 'Player sheet 📇 Contact: Reserve, ask', 'sheet_contact_ask', '🪑 Reserve for {event} — 📣 Ask (can you make it?) is first in Contact.', 914),
    ('Event Center', 'Contact popup: ask one Reserve (message name)', 'ask_reserve_msg', '📣 Ask (Reserve) — can you make it?', 915)
  ) AS v(category, label, tier, body, sort_order)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'event_center' AND m.tier = v.tier);
