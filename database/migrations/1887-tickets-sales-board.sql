-- 1887 (2026-11-24) — 🎟 #tickets: the Sales pill tracks every sale (owner:
-- "we need tickets screen to track sales and names and emails etc") and the
-- page moves to the Club menu (owner: "would be under club?").
--
-- Sales pill: totals (tickets sold, people, money) by ticket and by how paid,
-- a search over name / email / phone, filters, and every sale as a row (date,
-- name, phone, email, ticket, people, paid, used, link).  Export CSV.  Words
-- only here; the screen is frontend/js/screens/tickets.js.

BEGIN;

UPDATE menu_pages SET group_code = 'club', sort_order = 3 WHERE code = 'tickets';

UPDATE message_templates SET body = 'Sales' WHERE kind = 'tickets' AND tier = 'pill_list';

INSERT INTO message_templates (category, label, kind, tier, body, sort_order, client_side, is_public)
SELECT 'Tickets', v.label, 'tickets', v.tier, v.body, v.o, true, false
  FROM (VALUES
    ('Tickets — sales: tickets sold',  'sales_tickets', 'Tickets sold', 35),
    ('Tickets — sales: people',        'sales_people',  'People', 36),
    ('Tickets — sales: money',         'sales_money',   'Money', 37),
    ('Tickets — sales: by ticket',     'by_product',    'By ticket', 38),
    ('Tickets — sales: by how paid',   'by_source',     'By how paid', 39),
    ('Tickets — sales: search',        'search_ph',     'Search name, email or phone', 40),
    ('Tickets — sales: all tickets',   'all_products',  'All tickets', 41),
    ('Tickets — sales: all methods',   'all_sources',   'All ways paid', 42),
    ('Tickets — sales: export',        'export',        '⬇ Export CSV', 43),
    ('Tickets — sales: col date',      'col_date',      'Date', 44),
    ('Tickets — sales: col name',      'col_name',      'Name', 45),
    ('Tickets — sales: col phone',     'col_phone',     'Phone', 46),
    ('Tickets — sales: col email',     'col_email',     'Email', 47),
    ('Tickets — sales: col ticket',    'col_ticket',    'Ticket', 48),
    ('Tickets — sales: col how paid',  'col_source',    'Paid by', 49),
    ('Tickets — sales: col people',    'col_people',    'People', 50),
    ('Tickets — sales: col amount',    'col_amount',    '$', 51),
    ('Tickets — sales: col used',      'col_used',      'Used', 52),
    ('Tickets — sales: col link',      'col_link',      'Link', 53),
    ('Tickets — sales: none match',    'none_match',    'No sales match.', 54),
    ('Tickets — sales: shown',         'shown',         '{n} shown', 55)
  ) AS v(label, tier, body, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'tickets' AND m.tier = v.tier);

COMMIT;
