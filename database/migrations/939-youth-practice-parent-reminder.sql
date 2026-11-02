-- One-to-one RSVP reminder led by a youth practice (owner 11/2: "still seeing
-- old one" — the parent texts, after mig 938 changed only the group message).
-- Same words as the group: the day, sneakers not spikes, why coaches ask.
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
VALUES
  ('System', 'RSVP reminder — parent, youth practice', 'rsvp_reminder', 'parent_practice', NULL,
   E'Hi {first}, {child} has practice[[ {day}]]: {event}. Wear sneakers, no spikes. Please set availability on footballhome.org so coaches can plan the session: {link}[[ {deadline}]] - {sender}',
   14, true, false, false),
  ('System', 'RSVP reminder — parent of several, youth practice', 'rsvp_reminder', 'multi_practice', NULL,
   E'Hi {first}, practice[[ {day}]] for {children}: {event}. Wear sneakers, no spikes. Please set availability on footballhome.org so coaches can plan the session: {link}[[ {deadline}]] - {sender}',
   14, true, false, false);
