-- 4023 Men's board order: Puerto Rico before U23 (APSL, Liga 1, then PR left,
-- U23 right). Owner 11/27 "think we need pr then u23 left to right".
-- (Gap number.)
BEGIN;
UPDATE teams SET board_sort_order = 9  WHERE slug = 'lighthouse-mens-club-puerto-rico';
UPDATE teams SET board_sort_order = 10 WHERE id = 957;
INSERT INTO schema_migrations (filename) VALUES ('4023-pr-before-u23.sql') ON CONFLICT DO NOTHING;
COMMIT;
