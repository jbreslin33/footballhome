-- 1287 (2026-11-11) — #apsl-pyramid map: the dashed border goes to the water too.
--
-- Owner 2026-11-11: "the line closer to del needs to goto water right? also
-- check that we check for that on all current and proposed".  Both borders —
-- the coloured one (drive × traffic factor, kind 'travel') and the dashed
-- straight-drive one (kind 'plain', mig 1255) — are carried out to sea by
-- scripts/pyramid-sea-borders.py, for both plans; the script lists every
-- border end that still stops short of the water.

ALTER TABLE pyramid_proposal_sea_borders ADD COLUMN IF NOT EXISTS kind text NOT NULL DEFAULT 'travel';
DO $$ BEGIN
    ALTER TABLE pyramid_proposal_sea_borders
        ADD CONSTRAINT pyramid_proposal_sea_borders_kind_check CHECK (kind IN ('travel', 'plain'));
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
COMMENT ON COLUMN pyramid_proposal_sea_borders.kind IS
    'mig 1287: which border this carries out to sea — travel = the coloured border, plain = the dashed straight-drive one (pyramid_proposal_borders.kind).';
