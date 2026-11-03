-- 1001 (2026-11-03) — 💤 Inactive gets its own section on every screen.
-- Owner: "this needs to show inactive on all screens! we are still gonna
-- bill them monthly but no fines and we are not gonna remind them of
-- rsvps. so then need to show in sep section on all screens including
-- event center so i don't bother with them!"
--
-- Code: the event feed carries `inactive` (CalendarController, kept out
-- of `rsvps` so no count or reminder sees them) → Event Center's 💤 fold
-- and week-tile count; Game Center's roster carries squadStatus → its 💤
-- fold, out of No Response / Not Going; /api/payments/standing carries
-- `inactive` → the 💤 INACTIVE pill on every player card's line (#payments,
-- Event/Game Center, #teams chip).  These are the words.
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
VALUES
  ('Event Center', 'Section — inactive players (fold)',     'event_center',    'sec_inactive',  NULL, '💤 Inactive', 1211, true, true, false),
  ('Event Center', 'Week tile — inactive players ({n})',    'event_center',    'tile_inactive', NULL, '💤 {n} inactive', 1225, true, true, false),
  ('Player cards', 'Inactive pill',                         'person_standing', 'inactive',      NULL, '💤 INACTIVE', 0, true, true, false),
  ('Player cards', 'Inactive pill tip',                     'person_standing', 'inactive_tip',  NULL, 'Inactive — still billed monthly, no fines, no RSVP reminders', 0, true, true, false);
