-- Roster statuses are scoped per league (owner 2026-09-07: "it needs to
-- come from db not hard code ... lets do per league").
--
-- The status dropdown on #teams was a hardcoded 12-option list in
-- roster-screen-base.js, the same on every board.  That let youth
-- paperwork steps (Needs Docs / Has Docs) land on APSL men and ITC
-- steps show up for U8s.  The pipeline a player walks is a fact about
-- the league the team is registered in, so:
--
--   1. league_roster_statuses — which statuses each league uses.  The
--      dropdown for a column is this list for the column's league.
--   2. Presentation moves onto roster_statuses (colour + whether the
--      status counts toward the "✓ N on roster" tally) so the frontend
--      has nothing left to hardcode.
--   3. Teams point at their real leagues.  Every youth team and the
--      women's team sat in the "Lighthouse Internal" catch-all division;
--      travel plays Philadelphia Parks & Recreation and Tri County
--      Women plays the Tri County Women's Soccer League.  Intramural
--      stays internal.  A team's league is division → season → league,
--      the chain the rest of the schema already uses.
--
-- A status a player already carries that his league doesn't list is
-- left alone (the dropdown still shows it); the two APSL men marked
-- with docs steps stay flagged for the coach to correct.
--
-- Season names are an assumption: "Fall 2026" for both new seasons.
BEGIN;

-- ── 1. Presentation + tally flag on the lookup ─────────────────────────
ALTER TABLE roster_statuses
    ADD COLUMN IF NOT EXISTS color_bg            VARCHAR(7),
    ADD COLUMN IF NOT EXISTS color_fg            VARCHAR(7),
    ADD COLUMN IF NOT EXISTS color_border        VARCHAR(7),
    ADD COLUMN IF NOT EXISTS counts_as_on_roster BOOLEAN NOT NULL DEFAULT false;

COMMENT ON COLUMN roster_statuses.color_bg IS
    'Card dropdown colour; NULL = neutral slate. Mirrors the 2026-09-05 palette that used to live in roster-screen-base.js';
COMMENT ON COLUMN roster_statuses.counts_as_on_roster IS
    'Counts toward the column''s "✓ N on roster" tally: on the official roster and available to play (show_in_official_roster minus Suspended)';

UPDATE roster_statuses SET color_bg='#16a34a', color_fg='#ffffff', color_border='#16a34a' WHERE code='on_roster';
UPDATE roster_statuses SET color_bg='#059669', color_fg='#ffffff', color_border='#34d399' WHERE code='has_docs';
UPDATE roster_statuses SET color_bg='#be123c', color_fg='#ffffff', color_border='#fb7185' WHERE code='needs_docs';
UPDATE roster_statuses SET color_bg='#f97316', color_fg='#431407', color_border='#f97316' WHERE code='possible_drop';
UPDATE roster_statuses SET color_bg='#eab308', color_fg='#422006', color_border='#eab308' WHERE code IN ('awaiting_approval', 'awaiting_transfer');
UPDATE roster_statuses SET counts_as_on_roster = (code IN ('on_roster', 'possible_drop'));

-- ── 2. Which statuses each league uses ─────────────────────────────────
CREATE TABLE IF NOT EXISTS league_roster_statuses (
    league_id        INTEGER NOT NULL REFERENCES leagues(id)         ON DELETE CASCADE,
    roster_status_id INTEGER NOT NULL REFERENCES roster_statuses(id) ON DELETE CASCADE,
    PRIMARY KEY (league_id, roster_status_id)
);
COMMENT ON TABLE league_roster_statuses IS
    'Roster-status pipeline per league. The #teams status dropdown for a column lists the statuses of the column''s league (teams.division_id → seasons → leagues).';

-- Adult leagues: the ITC / transfer pipeline.
INSERT INTO league_roster_statuses (league_id, roster_status_id)
SELECT l.id, rs.id
  FROM leagues l
 CROSS JOIN roster_statuses rs
 WHERE l.name IN ('American Premier Soccer League', 'CASA Select', 'CASA Traditional',
                  'Cosmopolitan Soccer League', 'EPSA Open State Cup',
                  'Tri County Women''s Soccer League')
   AND rs.code IN ('not_on_roster', 'needs_itc', 'submitted_itc', 'needs_transfer',
                   'awaiting_transfer', 'awaiting_roster_spot', 'awaiting_approval',
                   'on_roster', 'possible_drop', 'suspended')
ON CONFLICT DO NOTHING;

-- Youth travel: birth certificate + headshot instead of ITC / transfer.
INSERT INTO league_roster_statuses (league_id, roster_status_id)
SELECT l.id, rs.id
  FROM leagues l
 CROSS JOIN roster_statuses rs
 WHERE l.name = 'Philadelphia Parks & Recreation'
   AND rs.code IN ('not_on_roster', 'needs_docs', 'has_docs', 'awaiting_roster_spot',
                   'awaiting_approval', 'on_roster', 'possible_drop', 'suspended')
ON CONFLICT DO NOTHING;

-- Intramural (Lighthouse Internal): no league roster to submit to.  The
-- docs steps live here because that is where the coach chases paperwork
-- before a child moves up; the status travels with him to travel.
INSERT INTO league_roster_statuses (league_id, roster_status_id)
SELECT l.id, rs.id
  FROM leagues l
 CROSS JOIN roster_statuses rs
 WHERE l.name = 'Lighthouse Internal'
   AND rs.code IN ('needs_docs', 'has_docs')
ON CONFLICT DO NOTHING;

-- ── 3. Travel + women's teams point at their real leagues ──────────────
-- Philadelphia Parks & Recreation → Fall 2026 → Youth Travel → Travel
WITH s AS (
    INSERT INTO seasons (league_id, name, start_date, is_active)
    SELECT id, 'Fall 2026', DATE '2026-09-01', true FROM leagues WHERE name = 'Philadelphia Parks & Recreation'
    ON CONFLICT (league_id, name) DO UPDATE SET is_active = true
    RETURNING id
), c AS (
    INSERT INTO conferences (season_id, name, abbreviation)
    SELECT id, 'Youth Travel', 'YT' FROM s
    RETURNING id, season_id
)
INSERT INTO divisions (season_id, conference_id, name)
SELECT season_id, id, 'Travel' FROM c;

UPDATE teams t
   SET division_id = d.id
  FROM divisions d
  JOIN seasons s ON s.id = d.season_id
  JOIN leagues l ON l.id = s.league_id
 WHERE l.name = 'Philadelphia Parks & Recreation'
   AND s.name = 'Fall 2026' AND d.name = 'Travel'
   AND t.id IN (912, 913, 914);   -- U8 / U10 / U12 Travel

-- Tri County Women's Soccer League → Fall 2026 → Tri County → Tri County
WITH s AS (
    INSERT INTO seasons (league_id, name, start_date, is_active)
    SELECT id, 'Fall 2026', DATE '2026-09-01', true FROM leagues WHERE name = 'Tri County Women''s Soccer League'
    ON CONFLICT (league_id, name) DO UPDATE SET is_active = true
    RETURNING id
), c AS (
    INSERT INTO conferences (season_id, name, abbreviation)
    SELECT id, 'Tri County', 'TC' FROM s
    RETURNING id, season_id
)
INSERT INTO divisions (season_id, conference_id, name)
SELECT season_id, id, 'Tri County' FROM c;

UPDATE teams t
   SET division_id = d.id
  FROM divisions d
  JOIN seasons s ON s.id = d.season_id
  JOIN leagues l ON l.id = s.league_id
 WHERE l.name = 'Tri County Women''s Soccer League'
   AND s.name = 'Fall 2026' AND d.name = 'Tri County'
   AND t.id = 901;                 -- Tri County Women

-- ── Guard ──────────────────────────────────────────────────────────────
DO $$
DECLARE bad TEXT; n INT;
BEGIN
    -- Every board column resolves to a league that has a status list.
    SELECT string_agg(t.name, ', ') INTO bad
      FROM teams t
      LEFT JOIN divisions d ON d.id = t.division_id
      LEFT JOIN seasons   s ON s.id = d.season_id
     WHERE t.is_active AND t.board_sort_order IS NOT NULL
       AND t.gender_category IN ('mens', 'womens', 'boys', 'girls')
       AND NOT EXISTS (SELECT 1 FROM league_roster_statuses lrs WHERE lrs.league_id = s.league_id);
    IF bad IS NOT NULL THEN
        RAISE EXCEPTION 'Board columns with no league status list: %', bad;
    END IF;

    -- The four re-parented teams landed where they should.
    SELECT count(*) INTO n
      FROM teams t JOIN divisions d ON d.id = t.division_id
      JOIN seasons s ON s.id = d.season_id JOIN leagues l ON l.id = s.league_id
     WHERE (t.id IN (912, 913, 914) AND l.name = 'Philadelphia Parks & Recreation')
        OR (t.id = 901               AND l.name = 'Tri County Women''s Soccer League')
        OR (t.id = 120               AND l.name = 'CASA Select')
        OR (t.id = 35                AND l.name = 'American Premier Soccer League');
    IF n <> 6 THEN
        RAISE EXCEPTION 'Expected 6 teams on their real leagues, found %', n;
    END IF;

    -- Every status still used on a live row exists in at least one league.
    SELECT string_agg(DISTINCT rs.code, ', ') INTO bad
      FROM roster_statuses rs
     WHERE rs.is_active
       AND NOT EXISTS (SELECT 1 FROM league_roster_statuses lrs WHERE lrs.roster_status_id = rs.id);
    IF bad IS NOT NULL THEN
        RAISE EXCEPTION 'Active statuses used by no league: %', bad;
    END IF;
END $$;

COMMIT;
