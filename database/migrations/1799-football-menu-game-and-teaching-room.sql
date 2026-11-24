-- 1799 (2026-11-24): ⚽ Football menu — the game, the teaching room, and no more Tactical hub.
--
-- Owner 11/24: "we need to organize the game and the teaching tool in the menus" ·
-- "are they football menu items?" · "the 'tactical' page should say football right?
-- … it should be more like other screens it still has old buttons".
--
-- #tactical was the last tile hub: six big buttons, each opening a screen.  Every other
-- group's pages are pills on the top bar (mig 1244 / 1429).  So the hub goes and its six
-- doors become ⚽ Football's own pills, with the 🎓 Teaching Room (teach.html, mig 1789)
-- and the 🎮 Game (was under ⚙️ Club) beside them:
--
--   🧠 Game Model · 📋 Practice Plans · 🗓️ Days & Exercises · 📐 Tactical Board ·
--   🧲 Live Board · 🎓 Teaching Room · 📊 Reports · 🎮 Game
--
-- Days and Exercises were two tiles into the same screen (#game-model-admin, which
-- reaches both from its overview): one pill.  Audiences as before — the Game stays
-- admin-only, the rest are the coaches' pages.

DELETE FROM menu_pages WHERE code = 'tactical';

INSERT INTO menu_pages (code, group_code, label, icon, audience, sort_order, screens, href, new_tab, download)
VALUES ('game-model',       'football', 'Game Model',       '🧠', 'coach', 1, '{game-model}',       NULL, false, false),
       ('practice-plan',    'football', 'Practice Plans',   '📋', 'coach', 2, '{practice-plan}',    NULL, false, false),
       ('game-model-admin', 'football', 'Days & Exercises', '🗓️', 'coach', 3, '{game-model-admin}', NULL, false, false),
       ('tactical-board',   'football', 'Tactical Board',   '📐', 'coach', 4, '{tactical-board}',   NULL, false, false),
       ('tactical-live',    'football', 'Live Board',       '🧲', 'coach', 5, '{tactical-live}',    NULL, false, false),
       ('teach',            'football', 'Teaching Room',    '🎓', 'coach', 6, '{}', '/teach.html',  false, false)
ON CONFLICT (code) DO NOTHING;

UPDATE menu_pages SET sort_order = 7 WHERE code = 'reports' AND group_code = 'football';
UPDATE menu_pages SET group_code = 'football', sort_order = 8 WHERE code = 'game';

-- The teaching room opened from the menu has no plan in its link: it lists the plans
-- (GET /api/tactic-plans/list) and the two-engine-sides room.  Its words:
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
SELECT 'Game Center', v.l, 'teach', v.t, NULL, v.b, v.o, true, true
  FROM (VALUES
    ('Teaching room — the plan list heading', 'pick_title', 'Pick a plan to watch', 1287),
    ('Teaching room — status while picking', 'pick_status', 'Which plan? Ours press, they build out from their goal kick.', 1288),
    ('Teaching room — one plan in the list ({us} / {them} = formations, {block} = block height, {steps} = steps drawn)', 'pick_row', '{us} v {them} · {block} · {steps} steps', 1289),
    ('Teaching room — the two-engine-sides room in the list', 'pick_pl', '🎮 Two Premier League sides, nothing told to either', 1290),
    ('Teaching room — no plans yet', 'pick_none', 'No plans yet. Draw one on a game''s 🎯 Tactics board.', 1291),
    ('Teaching room — back to the plan list', 'pick_back', '☰ Plans', 1292)
  ) AS v(l, t, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'teach' AND m.tier = v.t);
UPDATE message_templates SET body = 'Pick a plan below, or open one from a game''s 🎯 Tactics board.'
 WHERE kind = 'teach' AND tier = 'no_plan' AND body = 'Open this from a plan on the 🎯 Tactics board.';
