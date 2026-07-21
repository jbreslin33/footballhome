-- 237-game-model-principles-hierarchy.sql (2026-07-20)
-- Store hierarchy directly in the principles table via parent_principle_id.

BEGIN;

ALTER TABLE club_game_model_principles
    ADD COLUMN IF NOT EXISTS parent_principle_id bigint REFERENCES club_game_model_principles(id) ON DELETE SET NULL;

CREATE INDEX IF NOT EXISTS idx_club_game_model_principles_parent_principle_id
    ON club_game_model_principles (parent_principle_id, phase_id, sort_order, id);

WITH ranked AS (
    SELECT
        id,
        phase_id,
        level,
        sort_order,
        row_number() OVER (
            PARTITION BY phase_id
            ORDER BY sort_order, id
        ) AS ordinal
    FROM club_game_model_principles
)
UPDATE club_game_model_principles cp
SET parent_principle_id = parent.id
FROM (
    SELECT
        child.id,
        parent.id AS parent_id
    FROM ranked child
    LEFT JOIN ranked parent
      ON parent.phase_id = child.phase_id
     AND parent.ordinal = child.ordinal - 1
    WHERE child.level = 'sub'
       OR child.level = 'sub_sub'
       OR child.level = 'sub_sub_sub'
) parent
WHERE cp.id = parent.id
  AND cp.parent_principle_id IS NULL;

WITH ranked AS (
    SELECT
        id,
        phase_id,
        level,
        sort_order,
        row_number() OVER (
            PARTITION BY phase_id
            ORDER BY sort_order, id
        ) AS ordinal
    FROM club_game_model_principles
)
UPDATE club_game_model_principles cp
SET parent_principle_id = (
    SELECT parent.id
    FROM ranked parent
    WHERE parent.phase_id = cp.phase_id
      AND parent.ordinal < (
          SELECT child.ordinal
          FROM ranked child
          WHERE child.id = cp.id
      )
      AND (
          (cp.level = 'sub' AND parent.level = 'main')
          OR (cp.level = 'sub_sub' AND parent.level = 'sub')
          OR (cp.level = 'sub_sub_sub' AND parent.level = 'sub_sub')
      )
    ORDER BY parent.ordinal DESC
    LIMIT 1
)
WHERE cp.level IN ('sub', 'sub_sub', 'sub_sub_sub')
  AND cp.parent_principle_id IS NULL;

COMMIT;
