-- 2197 (2026-11-27): 🏋️ #exercises — the exercise catalog page (Football menu).
-- Owner: "we may need to modernize the section for exercises to the way the
-- other fh stuff is formatted" · "football menu right?" · "we just need a
-- pure exercise pill right?".  Reads the mig 2191 catalog.  Sits next to the
-- old "Days & Exercises", which retires when practices and game warm-ups
-- link to this catalog.  Wording: message_templates kind 'exercises'.
BEGIN;

INSERT INTO menu_pages (code, group_code, label, icon, audience, sort_order, screens, new_tab, download, is_active)
VALUES ('exercises', 'football', 'Exercises', '🏋️', 'coach', 3, '{exercises}', false, false, true)
ON CONFLICT (code) DO NOTHING;

INSERT INTO message_templates (category, label, kind, tier, body, sort_order, client_side, is_public)
SELECT 'Exercises', v.label, 'exercises', v.tier, v.body, v.so, true, false
  FROM (VALUES
  ('Exercises — title', 'title', '🏋️ Exercises', 1),
  ('Exercises — intro', 'intro', 'Every exercise from the coaching books and our own sessions, in our words. Pick a category, a source or search; tap one for the full set-up.', 2),
  ('Exercises — none', 'none', 'No exercises catalogued yet.', 3),
  ('Exercises — all pill', 'all', 'All', 4),
  ('Exercises — all sources', 'all_sources', 'All sources ({n})', 5),
  ('Exercises — search', 'search', 'Search name, coach, players…', 6),
  ('Exercises — totals', 'totals', '{shown} of {total} exercises · {sources} sources', 7),
  ('Exercises — column exercise', 'col_exercise', 'Exercise', 8),
  ('Exercises — column category', 'col_category', 'Category', 9),
  ('Exercises — column players', 'col_players', 'Players', 10),
  ('Exercises — column area', 'col_area', 'Area', 11),
  ('Exercises — column source', 'col_source', 'Source', 12),
  ('Exercises — page', 'page', 'p.{p}', 13),
  ('Exercises — more rows', 'more', '{n} more — narrow it with a category, source or search', 14),
  ('Exercises — back', 'back', '← All exercises', 15),
  ('Exercises — pages', 'pages', 'pages', 16),
  ('Exercises — minutes', 'minutes', '{n} min', 17),
  ('Exercises — goals chip', 'chip_goals', '🥅 Goals', 18),
  ('Exercises — keepers chip', 'chip_keepers', '🧤 Keepers', 19),
  ('Exercises — directional chip', 'chip_directional', '➡️ Directional', 20),
  ('Exercises — what it trains', 'lbl_objective', 'What it trains', 21),
  ('Exercises — set-up', 'lbl_setup', 'Set-up', 22),
  ('Exercises — how it runs', 'lbl_procedure', 'How it runs', 23),
  ('Exercises — rules', 'lbl_rules', 'Rules', 24),
  ('Exercises — progressions', 'lbl_progressions', 'Progressions', 25),
  ('Exercises — coaching points', 'lbl_coaching_points', 'Coaching points', 26),
  ('Exercises — page viewer prev', 'prev', '‹ Prev', 27),
  ('Exercises — page viewer next', 'next', 'Next ›', 28),
  ('Exercises — page viewer close', 'close', 'Close', 29)
  ) AS v(label, tier, body, so)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = 'exercises');

INSERT INTO schema_migrations (filename) VALUES ('2197-exercises-page.sql') ON CONFLICT DO NOTHING;
COMMIT;
