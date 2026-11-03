-- 996-person-standing-copy.sql
--
-- Owner 11/3: "need last rsvp on all cards so i know if a player is ghost
-- lol and dues standing".  Every player card (Event Center, Game Center)
-- carries one line from GET /api/payments/standing — 👻 ghost / 🙈 no-show
-- (the #payments rule), the last RSVP, the dues standing — and the one-line
-- #teams card a 👻 + last-RSVP-date chip (components/person-standing.js).
-- Club admins only.  These are its words.

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT v.* FROM (VALUES
  ('Player cards', 'Ghost pill',                               'person_standing', 'ghost',          NULL, '👻 GHOST', 1, true, true, false),
  ('Player cards', 'Ghost pill tip ({days})',                  'person_standing', 'ghost_tip',      NULL, 'No present/late mark and no yes RSVP in the last {days} days', 2, true, true, false),
  ('Player cards', 'No-show pill',                             'person_standing', 'no_show',        NULL, '🙈 NO-SHOW', 3, true, true, false),
  ('Player cards', 'No-show pill tip ({days})',                'person_standing', 'no_show_tip',    NULL, 'Says yes but only absent marks in the last {days} days', 4, true, true, false),
  ('Player cards', 'Last RSVP ({icon} {status} {what})',       'person_standing', 'last_rsvp',      NULL, '🗓 Last RSVP {icon} {what}', 5, true, true, false),
  ('Player cards', 'Last RSVP tip ({date})',                   'person_standing', 'last_rsvp_tip',  NULL, 'Answered {date}', 6, true, true, false),
  ('Player cards', 'Never answered',                           'person_standing', 'no_rsvp',        NULL, '🗓 No RSVP ever', 7, true, true, false),
  ('Player cards', 'Teams chip: last RSVP ({date})',           'person_standing', 'chip_last',      NULL, '🗓{date}', 8, true, true, false),
  ('Player cards', 'Teams chip: never answered',               'person_standing', 'chip_never',     NULL, '🗓—', 9, true, true, false),
  ('Player cards', 'Dues: paid up',                            'person_standing', 'dues_paid',      NULL, '💰 Paid up', 10, true, true, false),
  ('Player cards', 'Dues: owes ({amount} {months})',           'person_standing', 'dues_owes',      NULL, '💰 Owes {amount} · {months} mo', 11, true, true, false),
  ('Player cards', 'Dues: volunteer',                          'person_standing', 'dues_volunteer', NULL, '🙋 Volunteer', 12, true, true, false),
  ('Player cards', 'Dues: injured, no dues',                   'person_standing', 'dues_injured',   NULL, '🩹 No dues', 13, true, true, false),
  ('Player cards', 'Dues: no live registration',               'person_standing', 'dues_no_membership', NULL, '💰 No membership', 14, true, true, false),
  ('Player cards', 'Dues: no live registration tip',           'person_standing', 'dues_no_membership_tip', NULL, 'No live LeagueApps registration', 15, true, true, false)
) AS v(category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = v.kind AND m.tier = v.tier);
