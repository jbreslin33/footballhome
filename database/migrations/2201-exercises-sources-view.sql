-- 2201 (2026-11-27): 🏋️ #exercises 📚 Sources view copy — every book / source
-- with its exercise count, sortable.  Owner: "can it show all the books it
-- uses as sources and how many exercises per book so its sortable by source
-- num of exercises?"
BEGIN;
INSERT INTO message_templates (category, label, kind, tier, body, sort_order, client_side, is_public)
SELECT 'Exercises', v.label, 'exercises', v.tier, v.body, v.so, true, false
  FROM (VALUES
  ('Exercises — exercises view pill', 'view_exercises', '📋 Exercises', 30),
  ('Exercises — sources view pill', 'view_sources', '📚 Sources', 31),
  ('Exercises — sources filter all', 'sfilter_all', 'All ({n})', 32),
  ('Exercises — sources filter read', 'sfilter_read', 'Read ({n})', 33),
  ('Exercises — sources filter not read', 'sfilter_unread', 'Not read yet ({n})', 34),
  ('Exercises — sources totals', 'src_totals', '{sources} sources · {read} read for exercises · {exercises} exercises', 35),
  ('Exercises — column pages', 'col_pages', 'Pages', 36),
  ('Exercises — column exercises', 'col_exercises', 'Exercises', 37),
  ('Exercises — not read yet', 'not_read', 'not read yet', 38)
  ) AS v(label, tier, body, so)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = 'exercises' AND tier = v.tier);
INSERT INTO schema_migrations (filename) VALUES ('2201-exercises-sources-view.sql') ON CONFLICT DO NOTHING;
COMMIT;
