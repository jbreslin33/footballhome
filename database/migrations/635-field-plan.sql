-- 635 (2026-10-22) — the pitch planner's layout in the DB.
-- James: "yes of course db lol" — the game page's 📐 planner (pitch-
-- planner.js: the 11v11, the 7v7 and named practice boxes dragged around
-- the real site) kept its layout in one browser's localStorage, so a phone
-- or another computer started from scratch and a closed tab lost unsaved
-- moves. One shared layout per facility now lives here, served by
-- /api/field-plan (FieldPlanController): 'current' = where things sit now
-- (every move saves), 'default' = what ↺ DEFAULT snaps back to; plus the
-- named spots (💾 SAVE). Positions are site metres (x east, z south from
-- LIGHTHOUSE_SITE.origin), sizes in yards, as the planner draws them.

CREATE TABLE IF NOT EXISTS field_plan_layouts (
    id           SERIAL PRIMARY KEY,
    facility_id  INT NOT NULL REFERENCES facilities(id) ON DELETE CASCADE,
    kind         TEXT NOT NULL CHECK (kind IN ('current', 'default')),
    updated_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_by   INT REFERENCES users(id) ON DELETE SET NULL,
    UNIQUE (facility_id, kind)
);
COMMENT ON TABLE field_plan_layouts IS 'Pitch planner layouts per facility (mig 635): current = live positions, default = what ↺ DEFAULT restores.';

CREATE TABLE IF NOT EXISTS field_plan_items (
    layout_id  INT NOT NULL REFERENCES field_plan_layouts(id) ON DELETE CASCADE,
    item_key   TEXT NOT NULL,          -- '11v11', '7v7', or a practice box's id
    kind       TEXT NOT NULL CHECK (kind IN ('pitch', 'practice_box')),
    name       TEXT,                   -- a practice box's name (Monday, Tuesday…)
    length_yd  NUMERIC(5,1) NOT NULL CHECK (length_yd > 0),
    width_yd   NUMERIC(5,1) NOT NULL CHECK (width_yd > 0),
    x_m        NUMERIC(8,2) NOT NULL,
    z_m        NUMERIC(8,2) NOT NULL,
    rot_deg    NUMERIC(5,1) NOT NULL,
    PRIMARY KEY (layout_id, item_key),
    CHECK (kind = 'pitch' OR name IS NOT NULL)
);
COMMENT ON TABLE field_plan_items IS 'One pitch or practice box in a field_plan_layouts row (mig 635), site metres + yards.';

CREATE TABLE IF NOT EXISTS field_plan_spots (
    id           SERIAL PRIMARY KEY,
    facility_id  INT NOT NULL REFERENCES facilities(id) ON DELETE CASCADE,
    pitch_key    TEXT NOT NULL,        -- which pitch it is a spot for ('11v11', '7v7')
    name         TEXT NOT NULL,
    length_yd    NUMERIC(5,1) NOT NULL CHECK (length_yd > 0),
    width_yd     NUMERIC(5,1) NOT NULL CHECK (width_yd > 0),
    x_m          NUMERIC(8,2) NOT NULL,
    z_m          NUMERIC(8,2) NOT NULL,
    rot_deg      NUMERIC(5,1) NOT NULL,
    created_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
    created_by   INT REFERENCES users(id) ON DELETE SET NULL
);
COMMENT ON TABLE field_plan_spots IS 'Named pitch positions saved from the planner (mig 635).';
