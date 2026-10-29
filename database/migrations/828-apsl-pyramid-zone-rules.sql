-- 828 (2026-10-29) — #apsl: default promotion / relegation spots for every
-- table, overridable per table.
--
-- Owner 2026-10-29: "assume 12th place team goes down (if no 12th then no
-- relegation for that spot) 11th place play playoff so list it as
-- relegation playoff. they would play a club from feeder. for promotion of
-- feeders up, if only 1 feeder then list first place team as 'auto
-- promotion' and 2nd place through 5th as promotion playoffs. if 2 feeder
-- leagues to a conference then 1st place should say 'auto promotion
-- playoffs' … that should be default for all divisions conferences etc.
-- but then those that differ we can edit over time."
--
-- pyramid_zone_rules: a row with no table (source_id NULL) is a DEFAULT for
-- every table; a row naming a table is that table's OVERRIDE — any override
-- row for a direction (up / down) replaces the defaults for that direction
-- on that table, and an override with no kind means "none that way".
--   down  defaults apply to every table;
--   up    defaults apply to a table with a promoting link up, chosen by how
--         many feeders share its upper level (a conference, or a table).
--         A feeder = a league's table, its groups counted once (ADASL
--         Division 1 Group A + B = one feeder into Terminus; Cosmo Division 2
--         A + B = one feeder into Division 1).  "2 feeder leagues" is read as
--         2 or more (Delaware River has 4, Metropolitan 3).
-- A spot past the end of a table doesn't exist (no 12th → no relegation);
-- a range is cut at the last place (2nd–5th of a 4-team table = 2nd–4th).
--
-- pyramid_zones_effective = rule zones + the source's own marks for
-- whatever the rules don't decide (APSL's playoff places, Cosmo's internal
-- playoff).  A source mark in a direction the rules decide for that table,
-- or on a place a rule zone covers, gives way.  pyramid_zone_moves and the
-- page read the effective zones.

INSERT INTO pyramid_zone_kinds (code, label, moves, color, sort_order) VALUES
    ('auto_promotion',         'Auto promotion',         'up', '#15803d', 15),
    ('auto_promotion_playoff', 'Auto promotion playoff', 'up', '#4ade80', 25)
ON CONFLICT (code) DO NOTHING;

CREATE TABLE IF NOT EXISTS pyramid_zone_rules (
    id          serial PRIMARY KEY,
    -- NULL + NULL = default for every table; set = this table's override.
    source_id   integer REFERENCES pyramid_sources(id) ON DELETE CASCADE,
    division    text,
    direction   text NOT NULL CHECK (direction IN ('up', 'down')),
    min_feeders integer,
    max_feeders integer,
    kind        text REFERENCES pyramid_zone_kinds(code),
    from_pos    integer,
    to_pos      integer,
    note        text,
    CHECK ((source_id IS NULL) = (division IS NULL)),
    -- Only an override may say "none" (no kind, no places).
    CHECK ((kind IS NULL AND from_pos IS NULL AND to_pos IS NULL AND source_id IS NOT NULL)
        OR (kind IS NOT NULL AND from_pos >= 1 AND to_pos >= from_pos))
);

INSERT INTO pyramid_zone_rules (direction, min_feeders, max_feeders, kind, from_pos, to_pos, note)
SELECT v.dir, v.mn, v.mx, v.kind, v.f, v.t, v.note
  FROM (VALUES
    ('down', NULL::int, NULL::int, 'relegation',             12, 12, '12th goes down'),
    ('down', NULL,      NULL,      'relegation_playoff',     11, 11, '11th plays a feeder club'),
    ('up',   1,         1,         'auto_promotion',          1,  1, 'one feeder: champion goes up'),
    ('up',   1,         1,         'promotion_playoff',       2,  5, 'one feeder: 2nd–5th play off'),
    ('up',   2,         NULL,      'auto_promotion_playoff',  1,  1, 'two or more feeders: champions play off')
  ) AS v(dir, mn, mx, kind, f, t, note)
 WHERE NOT EXISTS (SELECT 1 FROM pyramid_zone_rules r WHERE r.source_id IS NULL);

CREATE OR REPLACE VIEW pyramid_zones_effective AS
WITH div AS (
    SELECT d.id, d.source_id, d.name,
           regexp_replace(d.name, '\s*-\s*Group\s+\S+$', '') AS unit,
           (SELECT count(*)::int FROM pyramid_teams t WHERE t.division_id = d.id AND t.removed_at IS NULL) AS n
      FROM pyramid_divisions d
     WHERE d.removed_at IS NULL),
-- Feeders sharing each upper level: distinct (league source, table less
-- its group) linked into it.
upper_feeders AS (
    SELECT l.id AS link_id,
           (SELECT count(DISTINCT (l2.lower_source_id, regexp_replace(l2.lower_division, '\s*-\s*Group\s+\S+$', '')))
              FROM pyramid_links l2
             WHERE l2.promotes
               AND ((l.upper_competition_id IS NOT NULL AND l2.upper_competition_id = l.upper_competition_id)
                 OR (l.upper_source_id IS NOT NULL AND l2.upper_source_id = l.upper_source_id
                     AND l2.upper_division = l.upper_division))) AS feeders
      FROM pyramid_links l
     WHERE l.promotes),
up AS (
    SELECT div.id AS division_id, max(uf.feeders) AS feeders
      FROM div
      JOIN pyramid_links l ON l.promotes AND l.lower_source_id = div.source_id AND l.lower_division = div.name
      JOIN upper_feeders uf ON uf.link_id = l.id
     GROUP BY div.id),
overridden AS (
    SELECT DISTINCT div.id AS division_id, r.direction
      FROM div JOIN pyramid_zone_rules r ON r.source_id = div.source_id AND r.division = div.name),
applied AS (
    -- this table's own rows
    SELECT div.id AS division_id, div.n, r.id AS rule_id, r.direction, r.kind, r.from_pos, r.to_pos, 'override'::text AS origin
      FROM div
      JOIN pyramid_zone_rules r ON r.source_id = div.source_id AND r.division = div.name
      LEFT JOIN up ON up.division_id = div.id
     WHERE r.min_feeders IS NULL OR coalesce(up.feeders, 0) >= r.min_feeders
    UNION ALL
    -- defaults, where the table has no override that way
    SELECT div.id, div.n, r.id, r.direction, r.kind, r.from_pos, r.to_pos, 'default'
      FROM div
      JOIN pyramid_zone_rules r ON r.source_id IS NULL
      LEFT JOIN up ON up.division_id = div.id
     WHERE NOT EXISTS (SELECT 1 FROM overridden o WHERE o.division_id = div.id AND o.direction = r.direction)
       AND (r.direction = 'down'
            OR (up.division_id IS NOT NULL
                AND up.feeders >= coalesce(r.min_feeders, 0)
                AND up.feeders <= coalesce(r.max_feeders, up.feeders)))),
rule_zones AS (
    SELECT a.division_id, a.kind, a.from_pos, least(a.to_pos, a.n) AS to_pos, a.origin
      FROM applied a
     WHERE a.kind IS NOT NULL AND a.n >= a.from_pos),
-- The directions the rules decide for each table (even when its size
-- leaves no rule spot — "no 12th then no relegation").
decided AS (SELECT DISTINCT division_id, direction FROM applied)
SELECT rz.division_id, rz.kind, rz.from_pos, rz.to_pos, k.label, rz.origin
  FROM rule_zones rz JOIN pyramid_zone_kinds k ON k.code = rz.kind
UNION ALL
SELECT z.division_id, z.kind, z.from_pos, z.to_pos, z.label, 'source'
  FROM pyramid_division_zones z
  JOIN pyramid_zone_kinds k ON k.code = z.kind
  JOIN div ON div.id = z.division_id
 WHERE NOT EXISTS (SELECT 1 FROM decided x WHERE x.division_id = z.division_id AND x.direction = k.moves)
   AND NOT EXISTS (SELECT 1 FROM rule_zones rz
                    WHERE rz.division_id = z.division_id
                      AND rz.from_pos <= z.to_pos AND rz.to_pos >= z.from_pos);

-- Moves follow the effective zones.
CREATE OR REPLACE VIEW pyramid_zone_moves AS
    SELECT z.division_id, z.kind, z.from_pos, z.to_pos, l.id AS link_id, 'up'::text AS direction,
           l.upper_competition_id AS to_competition_id, ud.id AS to_division_id
      FROM pyramid_zones_effective z
      JOIN pyramid_zone_kinds k ON k.code = z.kind AND k.moves = 'up'
      JOIN pyramid_divisions d ON d.id = z.division_id AND d.removed_at IS NULL
      JOIN pyramid_links l ON l.promotes AND l.lower_source_id = d.source_id AND l.lower_division = d.name
      LEFT JOIN pyramid_divisions ud ON ud.removed_at IS NULL
                                    AND ud.source_id = l.upper_source_id AND ud.name = l.upper_division
     WHERE l.upper_competition_id IS NOT NULL OR ud.id IS NOT NULL
    UNION ALL
    SELECT z.division_id, z.kind, z.from_pos, z.to_pos, l.id, 'down',
           NULL::integer, ld.id
      FROM pyramid_zones_effective z
      JOIN pyramid_zone_kinds k ON k.code = z.kind AND k.moves = 'down'
      JOIN pyramid_divisions d ON d.id = z.division_id AND d.removed_at IS NULL
      JOIN pyramid_links l ON l.relegates
                          AND ((l.upper_source_id = d.source_id AND l.upper_division = d.name)
                               OR l.upper_competition_id = d.competition_id)
      JOIN pyramid_divisions ld ON ld.removed_at IS NULL
                               AND ld.source_id = l.lower_source_id AND ld.name = l.lower_division;

-- ── Copy: the ✏️ override editor on #apsl ──────────────────────────────
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'APSL pyramid', l, 'apsl_pyramid', t, NULL, b, o, true, true, false
  FROM (VALUES
    ('edit_title',   'APSL pyramid — editor title',          'Promotion & relegation · {table}', 60),
    ('edit_up',      'APSL pyramid — editor: up section',    '▲ Going up', 61),
    ('edit_down',    'APSL pyramid — editor: down section',  '▼ Going down', 62),
    ('mode_default', 'APSL pyramid — editor: default',       'Default rules', 63),
    ('mode_none',    'APSL pyramid — editor: none',          'None', 64),
    ('mode_custom',  'APSL pyramid — editor: this table',    'This table''s own', 65),
    ('defaults_are', 'APSL pyramid — editor: defaults give', 'Defaults give: {zones}', 66),
    ('defaults_none','APSL pyramid — editor: defaults none', 'Defaults give nothing here', 67),
    ('add_zone',     'APSL pyramid — editor: add zone',      '+ zone', 68),
    ('place_from',   'APSL pyramid — editor: from place',    'from', 69),
    ('place_to',     'APSL pyramid — editor: to place',      'to', 70),
    ('save',         'APSL pyramid — editor: save',          'Save', 71),
    ('cancel',       'APSL pyramid — editor: cancel',        'Cancel', 72),
    ('edit_hint',    'APSL pyramid — ✏️ tooltip',            'Edit this table''s promotion / relegation', 73)
  ) AS v(t, l, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'apsl_pyramid' AND m.tier = v.t);
