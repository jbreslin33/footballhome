-- 897 (2026-10-30) — #cash-flow: show only one club or league, every line by month.
--
-- Owner: "it should let me click to open total and break down for any league or
-- club", "so i can check if missing anything real easy. it should break it down
-- by month", "like show only apsl or show only liga 1".
--
-- A scope is a club or a league under it.  Calendar work and referee fees know
-- their league from the event; an invoice line with no event is read off its
-- description by cash_flow_line_rules, and whatever no rule claims is club-wide.

CREATE TABLE IF NOT EXISTS cash_flow_scopes (
    code         TEXT PRIMARY KEY,
    label        TEXT NOT NULL,
    parent       TEXT REFERENCES cash_flow_scopes(code),
    category     TEXT,
    leagues      TEXT[] NOT NULL DEFAULT '{}',
    section_code TEXT,
    sort_order   INT NOT NULL
);
COMMENT ON TABLE cash_flow_scopes IS 'mig 897: the clubs and leagues #cash-flow can show on their own. category and leagues match fh_events.';

INSERT INTO cash_flow_scopes (code, label, parent, category, leagues, section_code, sort_order) VALUES
    ('mens',       'Men''s',       NULL,     'mens',   '{}',                           'M',  10),
    ('apsl',       'APSL',         'mens',   NULL,     '{APSL}',                       NULL, 11),
    ('liga1',      'Liga 1',       'mens',   NULL,     '{CASA,"Liga 1","LIGA 1"}',     NULL, 12),
    ('womens',     'Women''s',     NULL,     'womens', '{}',                           'W',  20),
    ('tri_county', 'Tri County',   'womens', NULL,     '{"Tri County",TCWSL}',         NULL, 21),
    ('boys',       'Boys',         NULL,     'boys',   '{}',                           'B',  30),
    ('ppr',        'Parks & Rec',  'boys',   NULL,     '{PPR}',                        NULL, 31),
    ('girls',      'Girls',        NULL,     'girls',  '{}',                           'G',  40),
    ('club',       'Club-wide',    NULL,     NULL,     '{}',                           NULL, 50)
ON CONFLICT (code) DO NOTHING;

CREATE TABLE IF NOT EXISTS cash_flow_line_rules (
    pattern    TEXT PRIMARY KEY,
    scope      TEXT NOT NULL REFERENCES cash_flow_scopes(code),
    sort_order INT NOT NULL
);
COMMENT ON TABLE cash_flow_line_rules IS 'mig 897: which scope an invoice line with no event belongs to, by its description. First match wins; no match is club-wide.';

INSERT INTO cash_flow_line_rules (pattern, scope, sort_order) VALUES
    ('APSL',                  'apsl',       1),
    ('Liga\s*1|CASA',         'liga1',      2),
    ('Tri.?County|Women',     'tri_county', 3),
    ('Youth|\mu(8|10|12)\M',  'ppr',        4)
ON CONFLICT (pattern) DO NOTHING;

CREATE OR REPLACE FUNCTION cash_flow_scope(p_category TEXT, p_league TEXT) RETURNS TEXT AS $$
    SELECT COALESCE(
        (SELECT code FROM cash_flow_scopes WHERE p_league = ANY (leagues) ORDER BY sort_order LIMIT 1),
        (SELECT code FROM cash_flow_scopes WHERE category = p_category ORDER BY sort_order LIMIT 1),
        'club')
$$ LANGUAGE sql STABLE;

CREATE OR REPLACE FUNCTION cash_flow_line_scope(p_description TEXT) RETURNS TEXT AS $$
    SELECT COALESCE(
        (SELECT scope FROM cash_flow_line_rules WHERE p_description ~* pattern ORDER BY sort_order LIMIT 1),
        'club')
$$ LANGUAGE sql STABLE;

ALTER TABLE cash_flow_planned ADD COLUMN IF NOT EXISTS scope TEXT REFERENCES cash_flow_scopes(code);
UPDATE cash_flow_planned SET scope = CASE
    WHEN label ~ '^(APSL|Reserves)' THEN 'apsl'
    WHEN label ~ '^Liga 1'          THEN 'liga1'
    WHEN label ~ '^Youth'           THEN 'ppr'
    ELSE 'club' END
 WHERE scope IS NULL;

-- James's spring games were one row each month: split so each league shows its own.
DELETE FROM cash_flow_planned WHERE label IN ('James coach pay, 4 APSL and 4 Liga 1 games', 'James coach pay, 2 APSL and 2 Liga 1 games');
INSERT INTO cash_flow_planned (ym, label, amount, scope)
SELECT v.ym, v.label, v.amount, v.scope
  FROM (VALUES ('2027-04', 'James coach pay, 4 APSL games',   240.00, 'apsl'),
               ('2027-04', 'James coach pay, 4 Liga 1 games', 196.00, 'liga1'),
               ('2027-05', 'James coach pay, 2 APSL games',   120.00, 'apsl'),
               ('2027-05', 'James coach pay, 2 Liga 1 games',  98.00, 'liga1')) AS v(ym, label, amount, scope)
 WHERE NOT EXISTS (SELECT 1 FROM cash_flow_planned p WHERE p.ym = v.ym AND p.label = v.label);
ALTER TABLE cash_flow_planned ALTER COLUMN scope SET NOT NULL;

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Finances', l, 'cash_flow', t, NULL, b, o, true, true, false
  FROM (VALUES
    ('pill_all',        'Scope pill',                     'All', 32),
    ('line_coach',      'A coach pay line ({name})',      '{name} coach pay', 33),
    ('line_ref',        'A referee line ({name})',        'Referees, {name}', 34),
    ('line_dues_ahead', 'Projected dues line ({name})',   '{name} dues, projected', 35),
    ('tap_month',       'Month table note',               'Tap a month to see every line.', 36),
    ('show_lines',      'Button',                         'Show every line', 37),
    ('hide_lines',      'Button',                         'Hide the lines', 38),
    ('no_lines',        'An empty month',                 'Nothing this month.', 39),
    ('shared_in',       'Note on a league ({league}, {club})', '{league} has no money in of its own: dues come in on {club}.', 40)
  ) AS v(t, l, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'cash_flow' AND m.tier = v.t);
