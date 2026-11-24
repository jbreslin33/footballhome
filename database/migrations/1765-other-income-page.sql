-- 1765 (2026-11-23): 💰 Other income — money in that is not member dues, its own page in the Money menu.
--
-- Owner 2026-11-23: "now that we have club wide do we add other sources of
-- income like grants and rentals?"  Groups is member dues only; this is the
-- rest of the money in: grants and sponsorships (income_awards) and field
-- rental bookings on the calendar.  It belongs to the club — the one pool —
-- not to a group.  Read-only; it shows what the reports already read.
-- Menu row + wording; no numbers change.

BEGIN;

UPDATE menu_pages SET sort_order = 8 WHERE code = 'invoices'     AND group_code = 'money';
UPDATE menu_pages SET sort_order = 7 WHERE code = 'club-wide'    AND group_code = 'money';
UPDATE menu_pages SET sort_order = 6 WHERE code = 'competitions' AND group_code = 'money';
INSERT INTO menu_pages (code, group_code, label, icon, audience, sort_order, screens)
VALUES ('other-income', 'money', 'Other income', '💰', 'admin', 5, '{other-income}')
ON CONFLICT (code) DO NOTHING;

INSERT INTO message_templates (category, label, kind, tier, body, sort_order, client_side)
SELECT 'Finances', 'Finances — other income: ' || v.what, 'finances', v.tier, v.body, v.n, true
  FROM (VALUES
    ('title',             'oi_title',       'Other income', 980),
    ('note',              'oi_note',        'Money in that is not member dues: grants, sponsors and field rentals. It belongs to the club as a whole. A grant can only pay for what it was given for.', 981),
    ('none',              'oi_none',        'No other income yet.', 982),
    ('column: source',    'oi_col_source',  'Source', 983),
    ('column: kind',      'oi_col_kind',    'Kind', 984),
    ('column: detail',    'oi_col_detail',  'Detail', 985),
    ('kind: grant',       'oi_grant',       'Grant', 986),
    ('kind: sponsorship', 'oi_sponsor',     'Sponsor', 987),
    ('kind: rental',      'oi_rental',      'Field rental', 988),
    ('rental line',       'oi_rental_line', 'Field rental bookings', 989),
    ('grant: received',   'oi_received',    'received {amount}', 990),
    ('grant: awarded',    'oi_awarded',     'awarded, not received yet', 991),
    ('grant: pays for',   'oi_pays_for',    'pays for: {purposes}', 992),
    ('rental: booked',    'oi_booked',      '{n} booked on the calendar', 993),
    ('rental: assumed',   'oi_assumed',     '{n} more assumed', 994)
  ) v(what, tier, body, n)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'finances' AND m.tier = v.tier);

INSERT INTO schema_migrations (filename) VALUES ('1765-other-income-page.sql') ON CONFLICT DO NOTHING;
COMMIT;
