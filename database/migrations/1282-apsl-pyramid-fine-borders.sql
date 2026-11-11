-- 1282 (2026-11-11) — #apsl-pyramid map: borders traced from drive times at
-- many points, not county edges.
--
-- Owner 2026-11-11: Bulldogs SC (Geick Park, Matawan edge of Monmouth
-- County) is a Metropolitan club by drive time from its ground (Times Square
-- 1 h 06 ×1.25 = 1 h 23 vs Philly 1 h 34) yet sat on the Delaware River side
-- — the whole of Monmouth went by one point near Freehold — "then your
-- current border is off" / "you need to check the x,y of these borders from
-- city centers at multiple points lol".
--
-- scripts/pyramid-fine-borders.py lays a grid of points (≈3 km current plan,
-- ≈11 km proposed) over every county that touches another conference, asks
-- OSRM for the drive from each point to the competing cities (cached here),
-- gives each point to the shortest drive × traffic factor (and, for the
-- second line, without traffic), and traces the line between points of
-- different conferences (smoothed).  Those lines replace the county-edge
-- borders between two conferences; edges facing open ground stay.
-- Pipeline: pyramid-county-drive.py → refresh → pyramid-fine-borders.py →
-- pyramid-sea-borders.py → pyramid-drive-times.py.

CREATE TABLE IF NOT EXISTS pyramid_grid_drive_times (
    from_lat   numeric(9,4) NOT NULL,
    from_lon   numeric(9,4) NOT NULL,
    to_lat     numeric(9,4) NOT NULL,
    to_lon     numeric(9,4) NOT NULL,
    minutes    numeric NOT NULL,
    fetched_at timestamptz NOT NULL DEFAULT now(),
    PRIMARY KEY (from_lat, from_lon, to_lat, to_lon)
);
COMMENT ON TABLE pyramid_grid_drive_times IS
    'mig 1282: road minutes (OSRM, no traffic) from a border grid point to a conference city — scripts/pyramid-fine-borders.py.';

ALTER TABLE pyramid_proposal_borders ADD COLUMN IF NOT EXISTS fine boolean NOT NULL DEFAULT false;
COMMENT ON COLUMN pyramid_proposal_borders.fine IS
    'mig 1282: traced from grid drive times (scripts/pyramid-fine-borders.py) rather than county edges.';
