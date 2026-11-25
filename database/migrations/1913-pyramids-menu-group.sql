-- 🗻 Pyramids: its own group in the top menu, beside 🏆 Leagues, with a pill per
-- pyramid — All · MLS · USL · APSL · NPSL · UPSL · LfC (James 11/25 "we need to
-- organize the 'leagues' menu. we need pyramids sub menu. then in the pyraminds sub
-- menu we need choice of all, apsl, usl mls, etc. and each needs a link to share
-- publicly" / "or make a pyramids pill at same level as leagues").
--
-- A group, not a third menu row: the pyramids are public display pages; 🏆 Leagues
-- stays the admin work tools (CASA, opponents, cup rosters …).
-- Each page code pyramid-<league> opens #apsl-pyramid/<league> (MainMenu.open), the
-- same address anyone can open signed out; <league> = the rail label in lower case
-- (message_templates apsl_pyramid shape_side_<n>), 'all' = every league on, whole
-- pyramid.  The page's 🔗 Copy link copies the league in view.  A new pyramid = a row.
-- The APSL hub page stops claiming the apsl-pyramid screen so the 🗻 group is lit there.

BEGIN;

UPDATE menu_groups SET sort_order = sort_order + 1 WHERE sort_order >= 7;
INSERT INTO menu_groups (code, label, icon, sort_order) VALUES ('pyramids', 'Pyramids', '🗻', 7)
ON CONFLICT (code) DO NOTHING;

INSERT INTO menu_pages (code, group_code, label, icon, audience, sort_order, screens) VALUES
  ('pyramid-all',  'pyramids', 'All',  '🗻', 'everyone', 1, '{apsl-pyramid}'),
  ('pyramid-mls',  'pyramids', 'MLS',  '🔺', 'everyone', 2, '{}'),
  ('pyramid-usl',  'pyramids', 'USL',  '🔺', 'everyone', 3, '{}'),
  ('pyramid-apsl', 'pyramids', 'APSL', '🔺', 'everyone', 4, '{}'),
  ('pyramid-npsl', 'pyramids', 'NPSL', '🔺', 'everyone', 5, '{}'),
  ('pyramid-upsl', 'pyramids', 'UPSL', '🔺', 'everyone', 6, '{}'),
  ('pyramid-lfc',  'pyramids', 'LfC',  '🔺', 'everyone', 7, '{}')
ON CONFLICT (code) DO NOTHING;

UPDATE menu_pages SET screens = array_remove(screens, 'apsl-pyramid') WHERE code = 'apsl';

COMMIT;
