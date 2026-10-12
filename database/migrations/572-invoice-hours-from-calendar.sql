-- 572 (2026-10-12) — #invoices: the calendar IS the hours, for everyone.
-- Owner: "i think we need to simplify this. its dup info. so take out the
-- days where we edit the day and lets just use gcal for hours for
-- everyone. then for that gcal event the hours would be the time of the
-- event but within that we can edit if they were late but that should be
-- hidden and have to hit an edit button the default if we check it off is
-- to give the hours. we need to brek them down by day and week. for luke
-- and anthony only show youth stuff. i need all in there."
--
-- The editable day-by-day grid is gone.  The sheet's hours section is the
-- period's calendar, broken down by week and day: tick an event and it
-- bills its hours (a game the league's coaching hours, mig 500; a practice
-- the event length); ✏️ opens the hidden from/till editor for late or
-- stayed-on; untick and it comes off.  Luke and Anthony see only youth
-- events because the list is the teams each person coaches (they coach no
-- mens team); James coaches mens + travel, so everything of his is there.
UPDATE invoice_issuers SET days_source = 'events' WHERE is_active;

UPDATE message_templates SET body = 'Hours from the calendar'
 WHERE kind = 'invoices' AND tier = 'games_title';
UPDATE message_templates SET body = 'Tick what you worked — a ticked event bills its hours: games the league''s coaching hours, practices the event length. Tap ✏️ to adjust the times if someone was late or stayed on.'
 WHERE kind = 'invoices' AND tier = 'games_hint';

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Invoices', l, 'invoices', t, NULL, b, o, true, true, false
  FROM (VALUES
    ('week_label', 'Invoices — week header in the hours breakdown', 'Week {n} · {from} – {till}', 772),
    ('day_add',    'Invoices — add hours without an event (button)', '➕ Hours without an event', 773)
  ) AS v(t, l, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'invoices' AND m.tier = v.t);
