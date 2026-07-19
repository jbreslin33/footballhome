-- Add a structured opponent field for Google Calendar classified matches.
-- The classifier fills this from the `Opponent:` DSL tag.

ALTER TABLE fh_events
    ADD COLUMN IF NOT EXISTS opponent TEXT;
