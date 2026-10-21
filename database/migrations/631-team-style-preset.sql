-- 631: Teams wear their identity (game/CONCEPTS.md "THE CLUB PRESET").
--
-- A demo team may name a style preset (mig 630): the daemon overlays that
-- preset onto the team's ratings at boot and after every band change, so
-- Lighthouse XI actually BOOTS playing the club's game model instead of
-- waiting for an admin to tap it on.

ALTER TABLE game_demo_teams ADD COLUMN style_preset TEXT
    REFERENCES game_style_presets(name);

UPDATE game_demo_teams SET style_preset = 'Lighthouse'
    WHERE name = 'Lighthouse XI';
