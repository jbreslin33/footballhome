-- 851 (2026-10-29) — game: the kits — Lighthouse all royal blue, the Ukies all
-- yellow (mig 639 columns; the TEAMS frame paints them).
--
-- James 10/29: "also put lh all in royal blue and put ukies in all yeloow".
-- Trim = the shirt number's colour, so it contrasts: white on the royal
-- blue; the Ukrainian flag's blue on the yellow. Keepers keep their own kits.

BEGIN;

UPDATE game_demo_teams SET kit_shirt = '#4169e1', kit_shorts = '#4169e1', kit_socks = '#4169e1', kit_trim = '#ffffff'
 WHERE name = 'Lighthouse APSL';
UPDATE game_demo_teams SET kit_shirt = '#ffd500', kit_shorts = '#ffd500', kit_socks = '#ffd500', kit_trim = '#005bbb'
 WHERE name = 'Ukrainian Nationals';

COMMIT;
