-- 1506 (2026-11-18) — The game kinds are their own screens now: MensGameScreen
-- (game-men) and YouthGameScreen (game-youth) extend the base game
-- (game-center) — owner 11/18 "each extends game and adds or hides".  The
-- menu pages that claim game-center (📅 Calendar, 📋 Event Center) claim
-- them too, so the top bar lights the same pill on a game of any kind.
UPDATE menu_pages
   SET screens = screens || ARRAY['game-men', 'game-youth']
 WHERE 'game-center' = ANY (screens)
   AND NOT ('game-men' = ANY (screens));
