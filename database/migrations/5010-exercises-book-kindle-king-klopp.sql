-- 5010 🏋️ Exercises from the book "kindle-king-klopp" into the exercise catalog (mig 2191).
-- Every practice the book sets out, in OUR OWN WORDS, with app page numbers
-- (the diagram is the book page).  Written by scripts/exercises/sync.py load.
-- Re-runnable: clears this book's exercises first.
BEGIN;
DELETE FROM exercises WHERE book_id = (SELECT id FROM coaching_books WHERE slug = 'kindle-king-klopp');
INSERT INTO schema_migrations (filename) VALUES ('5010-exercises-book-kindle-king-klopp.sql') ON CONFLICT DO NOTHING;
COMMIT;
