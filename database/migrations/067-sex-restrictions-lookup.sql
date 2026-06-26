-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Migration 067: Normalize leagues.sex_restriction string enum to FK lookup
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--
-- Before: leagues.sex_restriction VARCHAR with CHECK constraint
-- After:  leagues.sex_restriction_id INT REFERENCES sex_restrictions(id)
--
-- Single source of truth for valid values; new values are an INSERT, not
-- an ALTER TABLE.
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

BEGIN;

CREATE TABLE IF NOT EXISTS sex_restrictions (
    id          SERIAL PRIMARY KEY,
    name        VARCHAR(20) UNIQUE NOT NULL,
    description TEXT,
    sort_order  INTEGER NOT NULL DEFAULT 0
);

INSERT INTO sex_restrictions (name, description, sort_order) VALUES
    ('men',   'Men only',                              10),
    ('women', 'Women only',                            20),
    ('coed',  'Coed (both sexes on same team)',        30),
    ('mixed', 'Mixed (separate teams, same league)',   40),
    ('open',  'Open / no sex restriction',             50)
ON CONFLICT (name) DO NOTHING;

-- Add FK column
ALTER TABLE leagues ADD COLUMN IF NOT EXISTS sex_restriction_id INTEGER
    REFERENCES sex_restrictions(id);

-- Backfill from existing text column
UPDATE leagues l
SET    sex_restriction_id = sr.id
FROM   sex_restrictions sr
WHERE  l.sex_restriction = sr.name
  AND  l.sex_restriction_id IS NULL;

-- Drop old CHECK constraint and column
ALTER TABLE leagues DROP CONSTRAINT IF EXISTS leagues_sex_restriction_check;
ALTER TABLE leagues DROP COLUMN  IF EXISTS sex_restriction;

COMMIT;
