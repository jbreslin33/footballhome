-- 680 (2026-10-24) — named whole-layout saves for the pitch planner.
-- James: "we need to be able to save whole page as a name. not individual
-- fields. whole save and it goes as a version in db. it only needs the
-- pitches and x,z and dimensions ... a db table for save then a pitches
-- table that fk to the save ... so even if we change the lh complex it
-- holds". One field_plan_saves row per 💾 SAVE (a name; the same name
-- saved again is a new version), its pitches and practice boxes copied into
-- field_plan_save_items. A save never reads the live layout or the site
-- model again: positions are site metres (x east, z south from
-- LIGHTHOUSE_SITE.origin), sizes in yards, frozen at save time.
-- Supersedes the per-pitch field_plan_spots (mig 635) in the UI; that
-- table is left as it is.

CREATE TABLE IF NOT EXISTS field_plan_saves (
    id           SERIAL PRIMARY KEY,
    facility_id  INT NOT NULL REFERENCES facilities(id) ON DELETE CASCADE,
    name         TEXT NOT NULL CHECK (length(btrim(name)) BETWEEN 1 AND 80),
    created_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
    created_by   INT REFERENCES users(id) ON DELETE SET NULL
);
CREATE INDEX IF NOT EXISTS field_plan_saves_facility_idx ON field_plan_saves (facility_id, created_at DESC);
COMMENT ON TABLE field_plan_saves IS 'A named, versioned snapshot of the whole pitch-planner layout (mig 680); items in field_plan_save_items.';

CREATE TABLE IF NOT EXISTS field_plan_save_items (
    save_id    INT NOT NULL REFERENCES field_plan_saves(id) ON DELETE CASCADE,
    item_key   TEXT NOT NULL,          -- '11v11', '7v7', or a practice box's id
    kind       TEXT NOT NULL CHECK (kind IN ('pitch', 'practice_box')),
    name       TEXT,                   -- a practice box's name
    length_yd  NUMERIC(5,1) NOT NULL CHECK (length_yd > 0),
    width_yd   NUMERIC(5,1) NOT NULL CHECK (width_yd > 0),
    x_m        NUMERIC(8,2) NOT NULL,
    z_m        NUMERIC(8,2) NOT NULL,
    rot_deg    NUMERIC(5,1) NOT NULL,
    PRIMARY KEY (save_id, item_key),
    CHECK (kind = 'pitch' OR name IS NOT NULL)
);
COMMENT ON TABLE field_plan_save_items IS 'One pitch or practice box in a field_plan_saves snapshot (mig 680), site metres + yards.';
