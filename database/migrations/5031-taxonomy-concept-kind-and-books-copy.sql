-- 5031 (2026-11-27): #football-taxonomy Concepts tab — the concept's kind (behaviour / style / call,
-- migs 5026/5029) as a filter and on the sheet, and the coaching-book patterns tagged with it (migs 5028/5030).
BEGIN;
INSERT INTO message_templates (category, label, kind, tier, body, sort_order, client_side, is_public) VALUES
 ('Football', 'Taxonomy of Football — kind filter: all',            'taxonomy', 'kind_all',       'Every kind', 665, true, false),
 ('Football', 'Taxonomy of Football — kind: behaviour',             'taxonomy', 'kind_behaviour', '🧠 Behaviours', 666, true, false),
 ('Football', 'Taxonomy of Football — kind: style',                 'taxonomy', 'kind_style',     '🎨 Style dials', 667, true, false),
 ('Football', 'Taxonomy of Football — kind: call',                  'taxonomy', 'kind_call',      '📣 Calls', 668, true, false),
 ('Football', 'Taxonomy of Football — field: kind',                 'taxonomy', 'f_kind',         'Kind', 669, true, false),
 ('Football', 'Taxonomy of Football — book patterns on a card ({n} main, {a} also)', 'taxonomy', 'books_n', '📚 in the books: {n} (+{a} also)', 670, true, false),
 ('Football', 'Taxonomy of Football — sheet section: book patterns ({n})', 'taxonomy', 's_books', '📚 In the books ({n})', 671, true, false),
 ('Football', 'Taxonomy of Football — no book patterns',            'taxonomy', 'none_books',     'No book pattern is tagged with this yet.', 672, true, false),
 ('Football', 'Taxonomy of Football — book pattern where this is not the main concept', 'taxonomy', 'book_also', 'also', 673, true, false),
 ('Football', 'Taxonomy of Football — book pattern that only loosely fits', 'taxonomy', 'book_loose', 'loose fit', 674, true, false),
 ('Football', 'Taxonomy of Football — book pattern pages ({from}, {to})', 'taxonomy', 'book_pages', 'p. {from}–{to}', 675, true, false);
COMMIT;
