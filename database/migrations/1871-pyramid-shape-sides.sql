-- 1871 (2026-11-24) — 🗻 Spin the pyramid: six sides, each family of leagues on a side of its own,
-- and the UPSL back on.  Owner: "can the pyramind have 5 sides lol" · "put upsl on the blank side"
-- · "put usl championship on the usl league one adn usl2 side" · "make six sides and put mls stuff
-- by itself and our pyramind apsl by itself with casa etc".
-- side 0 is the face the page opens on.  NULL = the next free side.  A league that feeds another
-- (feeds_league_id) is drawn inside its upper league's side and needs none.
ALTER TABLE pro_leagues ADD COLUMN IF NOT EXISTS pyramid_side smallint CHECK (pyramid_side >= 0);
ALTER TABLE pyramid_competitions ADD COLUMN IF NOT EXISTS pyramid_side smallint CHECK (pyramid_side >= 0);
COMMENT ON COLUMN pro_leagues.pyramid_side IS 'Side of the 3D pyramid (#apsl-pyramid) this league stands on; 0 = the face. NULL = next free side.';
COMMENT ON COLUMN pyramid_competitions.pyramid_side IS 'Side of the 3D pyramid a root pyramid (the APSL) stands on; 0 = the face.';

UPDATE pyramid_competitions SET pyramid_side = 0 WHERE slug = 'apsl' AND parent_id IS NULL;   -- our pyramid, with CASA etc., by itself on the face
UPDATE pro_leagues SET pyramid_side = 1 WHERE name IN ('FIFA Club World Cup', 'Concacaf Champions Cup', 'MLS', 'MLS NEXT Pro');   -- the MLS column
UPDATE pro_leagues SET pyramid_side = 2 WHERE name IN ('USL Championship', 'USL League One', 'USL League Two');                  -- the USL column
UPDATE pro_leagues SET pyramid_side = 3 WHERE name = 'United Premier Soccer League';
UPDATE pro_leagues SET pyramid_side = 4 WHERE name = 'National Premier Soccer League';
UPDATE pro_leagues SET pyramid_side = 5 WHERE name = 'The League for Clubs';

-- the UPSL comes back (switched off by mig 1858), now on a side of its own
UPDATE pro_leagues SET is_active = true WHERE name IN ('United Premier Soccer League', 'UPSL Division 1') AND NOT is_active;
