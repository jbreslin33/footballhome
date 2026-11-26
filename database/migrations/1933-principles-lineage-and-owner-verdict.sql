-- 1933 (2026-11-26): get it all in, decide by popularity — or the owner overrides.
-- Owner 11/26: "i think get it all in and we can decide based on popularity or we can over ride".
--   game_play_principles.owner_verdict  adopt | reject | NULL (= popularity decides); owner_note says why
--   game_source_lineage                 who learned from whom (source → the source it draws on)
--   game_principle_popularity           now also: schools (lineage roots) that name it, and the decision

ALTER TABLE game_play_principles ADD COLUMN IF NOT EXISTS owner_verdict text CHECK (owner_verdict IN ('adopt', 'reject'));
ALTER TABLE game_play_principles ADD COLUMN IF NOT EXISTS owner_note text NOT NULL DEFAULT '';

CREATE TABLE IF NOT EXISTS game_source_lineage (
    source_id    integer NOT NULL REFERENCES game_sources(id) ON DELETE CASCADE,
    draws_on_id  integer NOT NULL REFERENCES game_sources(id) ON DELETE CASCADE,
    note         text NOT NULL DEFAULT '',
    verified     boolean NOT NULL DEFAULT false,
    PRIMARY KEY (source_id, draws_on_id),
    CHECK (source_id <> draws_on_id)
);

-- The two schools found 11/26. English: Wade's FA guide. Iberian: Bayer (Teodorescu before him, not in hand yet).
INSERT INTO game_source_lineage (source_id, draws_on_id, note)
SELECT s.id, d.id, v.note
  FROM (VALUES
    ('ussf-d-licence', 'wade-fa-guide-1967', 'the same ten plus immediate chase'),
    ('ussf-curriculum', 'wade-fa-guide-1967', 'English school, loosened into coaching topics'),
    ('united-soccer-coaches', 'wade-fa-guide-1967', 'Wade''s five attacking'),
    ('fa-england', 'wade-fa-guide-1967', 'the FA''s own; England DNA adds moments on top'),
    ('jfa', 'wade-fa-guide-1967', 'JFA correction notice: Wade 1968, 4 + 4 until 2022, then England''s 5 + 5'),
    ('queiroz-1983', 'bayer', 'general / operational / fundamental — Bayer''s three levels'),
    ('castelo-1996', 'queiroz-1983', 'Portuguese school'),
    ('costa-2009', 'queiroz-1983', 'cites Queiroz 1983 and Castelo for the fundamental principles'),
    ('costa-2009', 'castelo-1996', ''),
    ('es-fundamental', 'bayer', 'Spanish school: Bayer''s levels, contención … unidad'),
    ('es-fundamental', 'costa-2009', 'the same ten as Costa'),
    ('rfef', 'bayer', 'superiority first — Bayer''s general principle'),
    ('barca-seirulo', 'bayer', 'superiority, split into four kinds'),
    ('barca-masia', 'barca-seirulo', 'the club''s academy'),
    ('figc', 'wade-fa-guide-1967', 'unverified guess: Coverciano''s smarcamento / marcamento / pressing read like the English ten')
  ) AS v(src, on_src, note)
  JOIN game_sources s ON s.code = v.src
  JOIN game_sources d ON d.code = v.on_src
ON CONFLICT DO NOTHING;

-- A source's school = the root(s) it reaches by following draws_on (a source with nothing above it is its own root).
CREATE OR REPLACE VIEW game_source_schools AS
WITH RECURSIVE up(source_id, ancestor_id) AS (
    SELECT id, id FROM game_sources
    UNION
    SELECT u.source_id, l.draws_on_id FROM up u JOIN game_source_lineage l ON l.source_id = u.ancestor_id
)
SELECT u.source_id, u.ancestor_id AS school_id, s.code AS school
  FROM up u JOIN game_sources s ON s.id = u.ancestor_id
 WHERE NOT EXISTS (SELECT 1 FROM game_source_lineage l WHERE l.source_id = u.ancestor_id);

DROP VIEW IF EXISTS game_principle_popularity;
CREATE VIEW game_principle_popularity AS
WITH hits AS (
    SELECT l.principle_id, t.source_id, l.relation FROM game_common_principle_links l JOIN game_source_principles t ON t.id = l.term_id
    UNION ALL
    SELECT p.parent_id, t.source_id, l.relation
      FROM game_common_principle_links l JOIN game_source_principles t ON t.id = l.term_id
      JOIN game_play_principles p ON p.id = l.principle_id WHERE p.parent_id IS NOT NULL
)
SELECT p.id, p.code, p.title, p.level, p.side,
       count(DISTINCT h.source_id) FILTER (WHERE h.relation IN ('same', 'part_of')) AS sources,
       count(DISTINCT h.source_id) FILTER (WHERE h.relation = 'overlaps') AS overlap_sources,
       count(DISTINCT sc.school_id) FILTER (WHERE h.relation IN ('same', 'part_of')) AS schools,
       string_agg(DISTINCT sc.school, ', ') FILTER (WHERE h.relation IN ('same', 'part_of')) AS school_codes,
       string_agg(DISTINCT s.code, ', ') AS source_codes,
       p.owner_verdict, p.owner_note,
       CASE WHEN p.owner_verdict IS NOT NULL THEN p.owner_verdict || ' (owner)' ELSE 'popularity' END AS decided_by
  FROM game_play_principles p
  LEFT JOIN hits h ON h.principle_id = p.id
  LEFT JOIN game_sources s ON s.id = h.source_id
  LEFT JOIN game_source_schools sc ON sc.source_id = h.source_id
 GROUP BY p.id;
