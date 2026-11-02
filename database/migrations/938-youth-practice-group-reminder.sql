-- Group RSVP reminder for ONE youth practice (owner 11/2): says the day,
-- sneakers not spikes, and why coaches need the answer.  Games and the
-- whole-week message keep their own tiers.  {day} = squad_notice day_today /
-- day_tomorrow, empty further out.
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
VALUES ('System', 'RSVP reminder — group, youth practice', 'rsvp_reminder', 'group_parent_practice', NULL,
        E'Hi all, practice[[ {day}]]: {event}. Wear sneakers, no spikes. Please set your availability on footballhome.org so coaches can plan the session.[[ Who''s in: {roll_call}]] - {sender}',
        14, true, false, false);
