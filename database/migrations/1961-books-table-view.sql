-- 1961 📚 #books table view: every book in one table — title, pages,
-- read (pattern count), patterns per game moment, analysis (method
-- write-up) — sortable, with All / Read / Not read pills; tap a book to
-- open it.  📋 Table / 📖 Book toggle, table first.  Wording only here; the
-- table is built from GET /api/coaching-books.
-- (James 11/27 "can we fix up the books page with a "table" view. title,
-- read, anaylysis etc?")
BEGIN;
INSERT INTO message_templates (category, label, kind, tier, body, sort_order, client_side, is_public)
SELECT 'Coaching books', v.label, 'books', v.tier, v.body, v.so, true, false
FROM (VALUES
  ('Books — view pill, table', 'view_table', '📋 Table', 20),
  ('Books — view pill, one book', 'view_book', '📖 Book', 21),
  ('Books — table column, book', 'col_book', 'Book', 22),
  ('Books — table column, pages', 'col_pages', 'Pages', 23),
  ('Books — table column, read', 'col_read', 'Read', 24),
  ('Books — table column, patterns per moment', 'col_moments', 'By moment', 25),
  ('Books — table column, analysis', 'col_analysis', 'Analysis', 26),
  ('Books — read cell, read', 'read_yes', '✅ {patterns} patterns', 27),
  ('Books — read cell, not read', 'read_no', '⏳ not yet', 28),
  ('Books — analysis cell, written', 'analysis_yes', '✅ written', 29),
  ('Books — analysis cell, none', 'analysis_no', '—', 30),
  ('Books — filter pill, all', 'filter_all', 'All {n}', 31),
  ('Books — filter pill, read', 'filter_read', 'Read {n}', 32),
  ('Books — filter pill, not read', 'filter_unread', 'Not read {n}', 33),
  ('Books — table totals line', 'totals', '{books} books · {read} read · {patterns} patterns · {pages} pages', 34),
  ('Books — moment abbreviations (in poss / out of poss / to defend / to attack / set piece)', 'moment_abbr', 'IP|OOP|→D|→A|SP', 35)
) AS v(label, tier, body, so)
WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'books' AND m.tier = v.tier);
INSERT INTO schema_migrations (filename) VALUES ('1961-books-table-view.sql') ON CONFLICT DO NOTHING;
COMMIT;
