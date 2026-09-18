-- 375: The uniform follows the section — men, women, youth.
--
-- Why (owner, 2026-09-18): "yes all men same" / "all youth same too" / "all
-- women same". Migration 374 hung the uniform set on each team and gave every
-- non-men's team a set of its own. The real rule is per section, so it moves
-- to club_sections.uniform_set_id; teams.uniform_set_id stays only as an
-- override for a team that one day wears something different (NULL = wear the
-- section's). A new team therefore lands in the right number pool on its own.
--
-- Boys and Girls are both 'Youth'. No youth or women's numbers exist yet, so
-- the per-team sets from 374 are empty and are simply removed.

BEGIN;

ALTER TABLE club_sections
    ADD COLUMN IF NOT EXISTS uniform_set_id integer REFERENCES uniform_sets(id) ON DELETE SET NULL;

INSERT INTO uniform_sets (name) VALUES ('Mens'), ('Womens'), ('Youth')
ON CONFLICT (name) DO NOTHING;

UPDATE club_sections cs SET uniform_set_id = us.id
  FROM uniform_sets us
 WHERE us.name = CASE cs.code WHEN 'M' THEN 'Mens' WHEN 'W' THEN 'Womens'
                              WHEN 'B' THEN 'Youth' WHEN 'G' THEN 'Youth' END;

-- Teams fall back to their section.
UPDATE teams SET uniform_set_id = NULL WHERE uniform_set_id IS NOT NULL;

-- The per-team sets are now unreferenced; drop the ones holding no numbers.
DELETE FROM uniform_sets us
 WHERE us.name NOT IN ('Mens', 'Womens', 'Youth')
   AND NOT EXISTS (SELECT 1 FROM person_uniform_numbers n WHERE n.uniform_set_id = us.id);

COMMENT ON COLUMN club_sections.uniform_set_id IS
    'The uniform this section''s teams wear. teams.uniform_set_id overrides it for one team; NULL there means this.';

-- One place for "which uniform does this team wear".
CREATE OR REPLACE FUNCTION team_uniform_set_id(p_team_id integer) RETURNS integer
LANGUAGE sql STABLE AS $$
    SELECT COALESCE(t.uniform_set_id, cs.uniform_set_id)
      FROM teams t LEFT JOIN club_sections cs ON cs.id = t.club_section_id
     WHERE t.id = p_team_id
$$;

COMMIT;
