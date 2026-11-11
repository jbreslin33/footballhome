-- 1252 (2026-11-11) — #apsl-pyramid proposal map: borders run out to sea.
--
-- Owner 2026-11-11: "the lines for del and metro conf needs to go to ocean
-- right lol?".  Border lines come from shared county edges, so a border
-- stops where its counties meet water (Delaware River / Metropolitan ended
-- at the Arthur Kill: Union County and Staten Island share no edge).
--
-- pyramid_proposal_sea_borders: each such loose end carried on over the
-- water, midway between the two regions' SHORES (equal distance to their
-- counties' edges) and never over land — Delaware River / Metropolitan runs
-- down the Arthur Kill, east through Raritan Bay and out past Sandy Hook —
-- until it meets the far shore's loose end of the same pair (a bay
-- crossing), a third region, or ~90 km.  Ends on the Canadian / Mexican
-- land border are left alone.  The walk needs exact point-to-shore
-- distances, too slow in SQL, so scripts/pyramid-sea-borders.py writes this
-- table; rerun it after fh_pyramid_proposal_refresh().  GET
-- /api/pyramid/proposal sends these rows with the land borders.
--
-- (An earlier draft of this migration tried the walk in plpgsql; drop what
-- it left behind on databases where it ran.)

DROP FUNCTION IF EXISTS fh_pyramid_proposal_extend();
DROP FUNCTION IF EXISTS fh_pyramid_on_land(float8, float8);

CREATE TABLE IF NOT EXISTS pyramid_proposal_sea_borders (
    id          serial PRIMARY KEY,
    region_a    text NOT NULL,     -- 'c<conference id>' / 'p<proposed id>', as pyramid_proposal_borders
    region_b    text NOT NULL,
    line        jsonb NOT NULL,    -- [[lat, lon], …]
    a_left      boolean NOT NULL,  -- region_a on the left of the line's direction
    computed_at timestamptz NOT NULL DEFAULT now()
);
COMMENT ON TABLE pyramid_proposal_sea_borders IS
    'mig 1252: proposal borders carried out over water (scripts/pyramid-sea-borders.py, rerun after fh_pyramid_proposal_refresh()).';
