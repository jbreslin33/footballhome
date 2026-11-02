-- Event Center Who's Coming (owner 11/2): coaches in their own section, with
-- the same reminders as players.  Coaches stay out of every player count.
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
VALUES
  ('Event Center', 'Who''s Coming: Coaches section', 'event_center', 'sec_coaches', NULL, '🧑‍🏫 Coaches', 1198, true, true, false),
  ('Event Center', 'Who''s Coming: remind coaches ({n})', 'event_center', 'remind_group_coaches', NULL, '📣 Remind all {n} coaches who haven''t answered', 1198, true, true, false);
