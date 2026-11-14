-- 1360 (2026-11-13) — 🎯 At capacity on the Budget page (#finances).
--
-- Owner: "we need to hit capicity for all teams. 70 for men. for youth 12 for
-- each age up to u12 then 16 for u13 to u14 then 18 for u15 u 16" + "how
-- much per month and show each cat of age team" + boys and girls together
-- ("Together").  Adult capacity stays the roster spots of a section's
-- dues-carrying teams (teams.max_roster × dues_rank: Men 35 + 35 = 70, Women
-- 35).  Youth capacity is per US Club Soccer age (fh_youth_us_age, mig 1044),
-- boys and girls together — one row per age here.  The page counts active
-- league-program members (never pickup) against it, × the section's monthly
-- dues, against the Year plan's cost ÷ 12.
BEGIN;

CREATE TABLE IF NOT EXISTS youth_age_capacities (
    club_id   integer NOT NULL REFERENCES clubs(id),
    us_age    integer NOT NULL CHECK (us_age BETWEEN 3 AND 19),
    capacity  integer NOT NULL CHECK (capacity >= 0),
    note      text,
    PRIMARY KEY (club_id, us_age)
);
COMMENT ON TABLE youth_age_capacities IS
  'Youth members wanted per US Club Soccer age (fh_youth_us_age), boys and girls together — the Budget page''s At capacity pill (mig 1360)';

INSERT INTO youth_age_capacities (club_id, us_age, capacity, note)
SELECT 134, a, CASE WHEN a <= 12 THEN 12 WHEN a <= 14 THEN 16 ELSE 18 END, 'owner 2026-11-13'
  FROM generate_series(6, 16) a
ON CONFLICT (club_id, us_age) DO NOTHING;

INSERT INTO message_templates (category, label, kind, tier, body, is_active, sort_order, client_side, is_public)
SELECT 'Finances', v.label, 'finances', v.tier, v.body, true, v.ord, true, false
  FROM (VALUES
    ('Finances — pill: At capacity', 'pill_capacity', '🎯 At capacity', 110),
    ('Finances — At capacity title', 'capacity_title', '🎯 At capacity — what full teams bring in', 111),
    ('Finances — At capacity note', 'capacity_note', 'Active league members today (never pickup) against the members each team wants, × monthly dues. Youth by US Club Soccer age, boys and girls together. "Now" counts paying members only; "at capacity" assumes every spot pays.', 112),
    ('Finances — At capacity columns', 'capacity_columns', 'Team|Members|Capacity|Open|$/mo now|$/mo at capacity', 113),
    ('Finances — At capacity youth group ({from}, {to}, {cap})', 'capacity_youth_group', 'Youth U{from}–U{to} · {cap} per age', 114),
    ('Finances — At capacity youth age ({age})', 'capacity_age', 'U{age}', 115),
    ('Finances — At capacity youth total', 'capacity_youth_total', 'Youth total', 116),
    ('Finances — At capacity: section the club covers', 'capacity_club_covers', 'club covers dues — not counted', 117),
    ('Finances — At capacity total row', 'capacity_total', 'Whole club', 118),
    ('Finances — At capacity need row ({year})', 'capacity_need', 'The {year} plan needs ({total} a year ÷ 12)', 119),
    ('Finances — At capacity gap now', 'capacity_gap_now', 'Short now', 120),
    ('Finances — At capacity spare when full', 'capacity_spare', 'Spare at capacity', 121),
    ('Finances — At capacity short when full', 'capacity_short', 'Still short at capacity', 122)
  ) AS v(label, tier, body, ord)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates t WHERE t.kind = 'finances' AND t.tier = v.tier);

COMMIT;
