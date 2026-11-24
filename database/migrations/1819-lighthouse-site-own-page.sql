-- 1819 (2026-11-24): 🏟️ Lighthouse Field — the 3D site and the pitch planner on their own page.
--
-- Owner 11/24: "game needs to get rid of old lh stuff and controls. it should be minimal
-- options in the game its a sim right and should just play" · (move or delete?) "own page".
--
-- The Lighthouse site model and the drag-and-drop pitch planner were the 📐 DESIGN mode
-- inside game.html.  They are /lighthouse-site.html now (frontend/js/game/site-client.js):
-- no match, no socket.  game.html plays on a plain pitch and no longer loads the site data.
-- The 🦺 Practice / 🎪 Barn / 🐂 Rodeo modes were placeholders that only showed a "coming"
-- note; they are gone with the mode bar.
--
-- A menu row under ⚙️ Club, admins, beside the other club tools.
INSERT INTO menu_pages (code, group_code, label, icon, audience, sort_order, screens, href, new_tab, download)
VALUES ('lighthouse-site', 'club', 'Field Planner', '🏟️', 'admin', 8, '{}', '/lighthouse-site.html', false, false)
ON CONFLICT (code) DO NOTHING;
