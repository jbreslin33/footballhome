-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Migration 068: Normalize schedule_generations.status to FK lookup
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--
-- Before: schedule_generations.status VARCHAR with CHECK constraint
-- After:  schedule_generations.status_id INT REFERENCES schedule_statuses(id)
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

BEGIN;

CREATE TABLE IF NOT EXISTS schedule_statuses (
    id          SERIAL PRIMARY KEY,
    name        VARCHAR(20) UNIQUE NOT NULL,
    description TEXT,
    is_terminal BOOLEAN NOT NULL DEFAULT FALSE,
    sort_order  INTEGER NOT NULL DEFAULT 0
);

INSERT INTO schedule_statuses (name, description, is_terminal, sort_order) VALUES
    ('pending',     'Queued, not yet started',  FALSE, 10),
    ('in_progress', 'Currently generating',     FALSE, 20),
    ('completed',   'Finished successfully',    TRUE,  30),
    ('failed',      'Finished with an error',   TRUE,  40)
ON CONFLICT (name) DO NOTHING;

ALTER TABLE schedule_generations
    ADD COLUMN IF NOT EXISTS status_id INTEGER REFERENCES schedule_statuses(id);

UPDATE schedule_generations sg
SET    status_id = ss.id
FROM   schedule_statuses ss
WHERE  sg.status = ss.name
  AND  sg.status_id IS NULL;

ALTER TABLE schedule_generations
    DROP CONSTRAINT IF EXISTS schedule_generations_status_check;
ALTER TABLE schedule_generations
    DROP COLUMN IF EXISTS status;

COMMIT;
