-- 574 (2026-10-12) — #invoices: the calendar breakdown is flat line items.
-- Owner: "again invoice is confusing. it says yes but the check is not
-- checked. show if rsvp and show if marked present to inform if we check
-- it off. do not total until bottom total hours. just line items of each
-- practice or game … an edit button to edit the hours … like a pop up."
--
-- The old RSVP badge read "✓ yes" — the same glyph as the worked checkbox,
-- so a yes looked like a tick that wasn't ticked.  It now reads "RSVP yes";
-- a new badge shows the attendance mark (#attendance, fh_event_attendance)
-- beside it.  Week/day subtotals are gone — one Total hours line at the
-- bottom — and ✏️ opens the override in a popup.
UPDATE message_templates SET body = 'RSVP yes' WHERE kind = 'invoices' AND tier = 'games_rsvp_yes';
UPDATE message_templates SET body = 'RSVP no'  WHERE kind = 'invoices' AND tier = 'games_rsvp_no';

UPDATE message_templates SET body = 'One line per practice or game. The RSVP and attendance columns say what happened — then ✓ it was worked as coach (its hours bill) or ✗ it was not. Hours stay 0 until ✓. ✏️ opens a popup to override the hours — rare, for a late start or staying on.'
 WHERE kind = 'invoices' AND tier = 'games_hint';

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Invoices', l, 'invoices', t, NULL, b, o, true, true, false
  FROM (VALUES
    ('games_att_present', 'Invoices — attendance badge: present',   'present',    776),
    ('games_att_late',    'Invoices — attendance badge: late',      'late',       777),
    ('games_att_absent',  'Invoices — attendance badge: absent',    'absent',     778),
    ('games_att_excused', 'Invoices — attendance badge: excused',   'excused',    779),
    ('games_att_none',    'Invoices — attendance badge: not marked','not marked', 780),
    ('total_hours',       'Invoices — bottom total label',          'Total hours', 781),
    ('edit_shift_hint',   'Invoices — ✏️ popup hint', 'Override the event''s hours — a late start, or stayed on. Wipe every box to take the day off the sheet.', 782)
  ) AS v(t, l, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'invoices' AND m.tier = v.t);
