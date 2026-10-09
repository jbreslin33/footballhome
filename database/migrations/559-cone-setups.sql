-- 559 (2026-10-09) — cone setups: a choice of field layout per practice.
-- Owner: "can we have for each practice a choice of setup of cones. right
-- now we can use default setup. pitch is currently 110 by 74 yards. we
-- will use 1/2 pitch at bottom. cone setup is 4, 20 by 30 yard rectangles
-- in corners. the 30 yards would run across … place cones every 5 yards.
-- this will end up with an empty t shaped portion or + shaped portion in
-- between the 4 pitches … this is the 1st config of field and we would
-- use it for all sessions kids and men."
--
-- cone_setups      one layout: the pitch it is cut from, the part used
--                  (area: depth × width in yards, anchored bottom), the
--                  cone spacing; is_default is what every practice gets
--                  until a coach picks another.
-- cone_setup_areas the rectangles inside that area, in yards from the
--                  area's top-left (x across, y down), with a label.
--                  Cones are placed every cone_spacing_yd along each
--                  rectangle's edges when the page draws it — nothing per
--                  cone is stored.
-- fh_events.cone_setup_id  the practice's choice; NULL = the default.
CREATE TABLE IF NOT EXISTS cone_setups (
    id               SERIAL PRIMARY KEY,
    code             TEXT NOT NULL UNIQUE,
    name             TEXT NOT NULL,
    description      TEXT NOT NULL DEFAULT '',
    pitch_length_yd  NUMERIC(5,1) NOT NULL DEFAULT 110,
    pitch_width_yd   NUMERIC(5,1) NOT NULL DEFAULT 74,
    area_length_yd   NUMERIC(5,1) NOT NULL,          -- depth of the part used (goal line → up)
    area_width_yd    NUMERIC(5,1) NOT NULL,          -- across
    area_anchor      TEXT NOT NULL DEFAULT 'bottom' CHECK (area_anchor IN ('bottom', 'top', 'full')),
    cone_spacing_yd  NUMERIC(4,1) NOT NULL DEFAULT 5,
    is_default       BOOLEAN NOT NULL DEFAULT false,
    is_active        BOOLEAN NOT NULL DEFAULT true,
    sort_order       INTEGER NOT NULL DEFAULT 0,
    created_at       TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at       TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE UNIQUE INDEX IF NOT EXISTS cone_setups_one_default ON cone_setups ((true)) WHERE is_default;
COMMENT ON TABLE cone_setups IS 'mig 559: a field cone layout a practice can pick; one row is the default for every practice.';
CREATE TABLE IF NOT EXISTS cone_setup_areas (
    id             SERIAL PRIMARY KEY,
    cone_setup_id  INTEGER NOT NULL REFERENCES cone_setups(id) ON DELETE CASCADE,
    label          TEXT NOT NULL DEFAULT '',
    x_yd           NUMERIC(5,1) NOT NULL,   -- from the area's left edge, across
    y_yd           NUMERIC(5,1) NOT NULL,   -- from the area's top edge, down
    w_yd           NUMERIC(5,1) NOT NULL,   -- across
    h_yd           NUMERIC(5,1) NOT NULL,   -- down
    sort_order     INTEGER NOT NULL DEFAULT 0
);
COMMENT ON TABLE cone_setup_areas IS 'mig 559: the rectangles of a cone setup, in yards inside its area; cones go every cone_spacing_yd along the edges.';
ALTER TABLE fh_events ADD COLUMN IF NOT EXISTS cone_setup_id INTEGER REFERENCES cone_setups(id) ON DELETE SET NULL;
COMMENT ON COLUMN fh_events.cone_setup_id IS 'mig 559: the practice''s cone setup; NULL = the default setup.';

-- The first configuration: the bottom half of the 110 × 74 pitch (55 deep
-- × 74 across), four 20-deep × 30-across boxes in the corners, cones every
-- 5 yards; the 14-yard channel across the middle and the 15-yard channel
-- down it make the empty + between them.
INSERT INTO cone_setups (code, name, description, pitch_length_yd, pitch_width_yd, area_length_yd, area_width_yd, area_anchor, cone_spacing_yd, is_default, sort_order)
SELECT 'four_corners_20x30', 'Four corner boxes 20 × 30',
       'Bottom half of the pitch. Four 20-deep × 30-across boxes in the corners, cones every 5 yards; the + between them is open.',
       110, 74, 55, 74, 'bottom', 5, true, 10
 WHERE NOT EXISTS (SELECT 1 FROM cone_setups WHERE code = 'four_corners_20x30');
INSERT INTO cone_setup_areas (cone_setup_id, label, x_yd, y_yd, w_yd, h_yd, sort_order)
SELECT s.id, v.label, v.x, v.y, 30, 20, v.o
  FROM cone_setups s, (VALUES ('Top left', 0, 0, 1), ('Top right', 44, 0, 2), ('Bottom left', 0, 35, 3), ('Bottom right', 44, 35, 4)) AS v(label, x, y, o)
 WHERE s.code = 'four_corners_20x30'
   AND NOT EXISTS (SELECT 1 FROM cone_setup_areas a WHERE a.cone_setup_id = s.id);

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Cone setups', l, 'cone_setup', t, NULL, b, o, true, true, false
  FROM (VALUES
    ('pill',        'Event page pill',                                   '🔶 Cones', 910),
    ('choose',      'Label over the setup picker',                       'Cone setup for this practice', 911),
    ('default_tag', 'Tag on the default setup',                          'default', 912),
    ('summary',     'Line under the drawing ({cones} {boxes} {spacing} {area})', '{cones} cones · {boxes} boxes · every {spacing} yd · {area}', 913),
    ('area_bottom', 'Area word — bottom half ({length} {width})',        'bottom {length} × {width} yd of the pitch', 914),
    ('area_top',    'Area word — top half ({length} {width})',           'top {length} × {width} yd of the pitch', 915),
    ('area_full',   'Area word — whole pitch ({length} {width})',        'whole pitch, {length} × {width} yd', 916),
    ('using_default','Note when the practice has no choice of its own',  'Using the default setup. Pick another below to change it for this practice only.', 917)
  ) AS v(t, l, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'cone_setup' AND m.tier = v.t);
