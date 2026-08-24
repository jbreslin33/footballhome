-- 298 — Makes the league crest a DB lookup instead of a hardcoded regex
-- table in the frontend.
--
-- Why (2026-08-24, owner: "we already should have them in db", then
-- "its just casa, tri county and apsl" and "we also need Philadelphia
-- Parks & Rec league"). Migration 297 gave us fh_events.league, the
-- free-text `League:` tag ops types on the calendar event, and
-- leagueCrest.js turned that tag into a crest image with a regex table
-- shipped in JavaScript. But the crest was already normalized data:
-- organizations.logo_url has held /images/leagues/apsl.png (org 1) and
-- casa.png (org 2) since the schema was seeded. The JS table was a
-- second, drifting copy of a column we already had.
--
-- Two of the club's four leagues had no row at all, which is why they
-- could only ever have lived in that JS table:
--   * Tri County Women's Soccer League — the women's side's league
--     (owner: "Tri COunty is tcwsl" — one league, two spellings).
--   * Philadelphia Parks & Recreation — the youth sides' city rec league.
--
-- The join from tag to org is an alias table, mirroring
-- gcal_opponent_aliases exactly (same free-text-gcal-tag-to-FK problem,
-- same LOWER(BTRIM(...)) match in EventController). The tag is typed by
-- hand, so no name column will ever match it directly: the CASA league
-- rows are named "CASA Select" and "CASA Traditional" while ops types
-- "Liga 1". Aliases mean a spelling ops invents next season is one
-- INSERT rather than a frontend deploy.

-- ── The two missing leagues ───────────────────────────────────────────
-- logo_url points at artwork already in the repo (frontend/images/
-- leagues/). Parks & Rec has two files; the square badge is the one that
-- reads at crest size — the other is a horizontal wordmark lockup that
-- would shrink to nothing inside the pitch's center circle.
INSERT INTO organizations (name, short_name, logo_url, description)
VALUES
  ('Tri County Women''s Soccer League', 'TCWSL',
   '/images/leagues/tcwsl.png',
   'Women''s league — Lighthouse Women''s Club plays here.'),
  ('Philadelphia Parks & Recreation', 'PPR',
   '/images/leagues/phila-parks-rec.jpg',
   'City rec league — Lighthouse youth sides play here.')
ON CONFLICT (name) DO UPDATE
  SET logo_url   = EXCLUDED.logo_url,
      short_name = EXCLUDED.short_name;

-- sex_restriction_id 2 = women, unambiguous from the league's own name.
-- Parks & Rec is deliberately left NULL rather than guessed: it is a
-- city-wide rec program spanning ages and sexes, and nothing in this
-- migration needs the answer.
INSERT INTO leagues (organization_id, name, sex_restriction_id)
SELECT o.id, o.name, 2
FROM organizations o
WHERE o.name = 'Tri County Women''s Soccer League'
ON CONFLICT (organization_id, name) DO NOTHING;

INSERT INTO leagues (organization_id, name)
SELECT o.id, o.name
FROM organizations o
WHERE o.name = 'Philadelphia Parks & Recreation'
ON CONFLICT (organization_id, name) DO NOTHING;

-- ── Tag → organization ────────────────────────────────────────────────
-- organization_id, not league_id: the crest belongs to the organization
-- (one CASA crest covers both CASA Select and CASA Traditional), and
-- organizations.logo_url is the column already carrying the artwork.
CREATE TABLE IF NOT EXISTS gcal_league_aliases (
    alias           TEXT    PRIMARY KEY,
    organization_id INTEGER NOT NULL REFERENCES organizations(id),
    notes           TEXT
);

COMMENT ON TABLE gcal_league_aliases IS
  'Maps the free-text `League:` gcal tag (fh_events.league) to the organization whose logo_url is the league crest. Matched case- and whitespace-insensitively; see EventController.cpp. Mirrors gcal_opponent_aliases.';

-- Seeded with every spelling the club uses today. The two live tags in
-- fh_events right now are exactly "APSL" and "Liga 1".
INSERT INTO gcal_league_aliases (alias, organization_id, notes)
SELECT v.alias, o.id, v.notes
FROM (VALUES
    ('APSL',                             'American Premier Soccer League', 'live tag on match 9255'),
    ('APSL Delaware River',              'American Premier Soccer League', 'owner''s preferred long form'),
    ('Delaware River',                   'American Premier Soccer League', NULL),
    ('American Premier Soccer League',   'American Premier Soccer League', NULL),

    ('CASA',                             'CASA Soccer Leagues',            NULL),
    ('Liga 1',                           'CASA Soccer Leagues',            'live tag on match 9253'),
    ('Liga 2',                           'CASA Soccer Leagues',            NULL),
    ('CASA Select',                      'CASA Soccer Leagues',            NULL),
    ('CASA Select Liga 1',               'CASA Soccer Leagues',            NULL),
    ('CASA Select Liga 2',               'CASA Soccer Leagues',            NULL),
    ('CASA Traditional',                 'CASA Soccer Leagues',            NULL),

    ('TCWSL',                            'Tri County Women''s Soccer League', NULL),
    ('Tri County',                       'Tri County Women''s Soccer League', 'owner: "Tri COunty is tcwsl"'),
    ('Tri-County',                       'Tri County Women''s Soccer League', NULL),
    ('Tri County WSL',                   'Tri County Women''s Soccer League', NULL),
    ('Tri County Women''s Soccer League','Tri County Women''s Soccer League', NULL),

    ('PPR',                              'Philadelphia Parks & Recreation', 'the mark on the crest itself'),
    ('Parks & Rec',                      'Philadelphia Parks & Recreation', NULL),
    ('Parks and Rec',                    'Philadelphia Parks & Recreation', NULL),
    ('Philadelphia Parks & Rec',         'Philadelphia Parks & Recreation', NULL),
    ('Philadelphia Parks & Recreation',  'Philadelphia Parks & Recreation', NULL),
    ('Phila Parks & Rec',                'Philadelphia Parks & Recreation', NULL)
) AS v(alias, org_name, notes)
JOIN organizations o ON o.name = v.org_name
ON CONFLICT (alias) DO UPDATE
  SET organization_id = EXCLUDED.organization_id,
      notes           = EXCLUDED.notes;
