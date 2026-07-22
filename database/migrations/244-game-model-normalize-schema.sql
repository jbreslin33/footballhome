-- 244-game-model-normalize-schema.sql (2026-07-22)
-- Normalizes the game-model schema to match the actual U.S. Soccer U17+
-- source document structure (docs/game-model/us-soccer-full-extraction.md),
-- fixing issues identified during review:
--
--   1. club_game_model_phases and club_game_model_action_catalogs FK'd
--      directly to clubs(id), bypassing club_game_model — a club's model
--      is the real owner, not the club row itself.
--   2. club_game_model_principles used a self-referencing adjacency list
--      with a `level` string column (main/sub/sub_sub/sub_sub_sub) even
--      though main principles and sub-principles are different shapes of
--      data (main: phase_id + short description; sub: parent + long
--      definition) and the source document never nests past 2 levels.
--      Split into two concrete tables instead. If a future club's source
--      document genuinely has a 3rd level, add
--      club_game_model_sub_sub_principles the same way — additive, no
--      changes to the tables below.
--   3. club_game_model_phase_definitions duplicated the phase's "Game
--      Idea" text that already lives in club_game_model_phases.description
--      (confirmed unused by any application code — dead weight).
--   4. club_game_model_principle_definitions was a 1:many table but every
--      principle only ever has exactly one definition in the source
--      document — collapsed into a single `definition` column.
--
-- No new content data is written here — this migration only moves
-- existing (already-verbatim, per migration 243) data into the corrected
-- shape. club_game_model_action_catalogs/categories/items were already
-- correctly normalized and are unchanged apart from the club_id fix.

BEGIN;

-- ---------------------------------------------------------------------
-- 1. club_game_model_phases: own via club_game_model_id, not club_id.
-- ---------------------------------------------------------------------
ALTER TABLE club_game_model_phases ADD COLUMN club_game_model_id bigint;

UPDATE club_game_model_phases p
SET club_game_model_id = gm.id
FROM club_game_model gm
WHERE gm.club_id = p.club_id;

ALTER TABLE club_game_model_phases ALTER COLUMN club_game_model_id SET NOT NULL;
ALTER TABLE club_game_model_phases
    ADD CONSTRAINT club_game_model_phases_club_game_model_id_fkey
    FOREIGN KEY (club_game_model_id) REFERENCES club_game_model(id) ON DELETE CASCADE;

ALTER TABLE club_game_model_phases DROP CONSTRAINT club_game_model_phases_club_id_slug_key;
ALTER TABLE club_game_model_phases
    ADD CONSTRAINT club_game_model_phases_model_slug_key UNIQUE (club_game_model_id, slug);

DROP INDEX IF EXISTS idx_club_game_model_phases_club_id;
CREATE INDEX idx_club_game_model_phases_model_id
    ON club_game_model_phases (club_game_model_id, sort_order, id);

ALTER TABLE club_game_model_phases DROP COLUMN club_id;

-- ---------------------------------------------------------------------
-- 2. Principles: split main principles / sub-principles into two tables.
-- ---------------------------------------------------------------------
CREATE TABLE club_game_model_sub_principles (
    id bigserial PRIMARY KEY,
    principle_id bigint NOT NULL REFERENCES club_game_model_principles(id) ON DELETE CASCADE,
    slug text NOT NULL,
    title text NOT NULL,
    definition text,
    sort_order integer NOT NULL DEFAULT 0,
    is_active boolean NOT NULL DEFAULT true,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    UNIQUE (principle_id, slug)
);

CREATE INDEX idx_club_game_model_sub_principles_principle_id
    ON club_game_model_sub_principles (principle_id, sort_order, id);

-- Move existing sub-level rows (parent_principle_id IS NOT NULL) into the
-- new table, carrying over their single definition blob.
INSERT INTO club_game_model_sub_principles
    (principle_id, slug, title, definition, sort_order, is_active, created_at, updated_at)
SELECT
    pr.parent_principle_id,
    pr.slug,
    pr.title,
    (SELECT pd.definition FROM club_game_model_principle_definitions pd
        WHERE pd.principle_id = pr.id ORDER BY pd.sort_order, pd.id LIMIT 1),
    pr.sort_order,
    pr.is_active,
    pr.created_at,
    pr.updated_at
FROM club_game_model_principles pr
WHERE pr.parent_principle_id IS NOT NULL;

DELETE FROM club_game_model_principle_definitions
WHERE principle_id IN (SELECT id FROM club_game_model_principles WHERE parent_principle_id IS NOT NULL);
DELETE FROM club_game_model_principles WHERE parent_principle_id IS NOT NULL;

-- club_game_model_principles now holds only main (root) principles.
DROP INDEX IF EXISTS idx_club_game_model_principles_parent_principle_id;
ALTER TABLE club_game_model_principles DROP CONSTRAINT club_game_model_principles_level_check;
ALTER TABLE club_game_model_principles DROP CONSTRAINT club_game_model_principles_parent_principle_id_fkey;
ALTER TABLE club_game_model_principles DROP COLUMN level;
ALTER TABLE club_game_model_principles DROP COLUMN parent_principle_id;

DROP TABLE club_game_model_principle_definitions;
DROP TABLE club_game_model_phase_definitions;

-- ---------------------------------------------------------------------
-- 3. club_game_model_action_catalogs: own via club_game_model_id.
-- ---------------------------------------------------------------------
ALTER TABLE club_game_model_action_catalogs ADD COLUMN club_game_model_id bigint;

UPDATE club_game_model_action_catalogs ac
SET club_game_model_id = gm.id
FROM club_game_model gm
WHERE gm.club_id = ac.club_id;

ALTER TABLE club_game_model_action_catalogs ALTER COLUMN club_game_model_id SET NOT NULL;
ALTER TABLE club_game_model_action_catalogs
    ADD CONSTRAINT club_game_model_action_catalogs_club_game_model_id_fkey
    FOREIGN KEY (club_game_model_id) REFERENCES club_game_model(id) ON DELETE CASCADE;

ALTER TABLE club_game_model_action_catalogs DROP CONSTRAINT club_game_model_action_catalogs_club_id_slug_key;
ALTER TABLE club_game_model_action_catalogs
    ADD CONSTRAINT club_game_model_action_catalogs_model_slug_key UNIQUE (club_game_model_id, slug);

ALTER TABLE club_game_model_action_catalogs DROP COLUMN club_id;

COMMIT;
