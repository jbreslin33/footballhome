-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Migration 230: sim_pattern_registry seed for pattern_being_beaten_1v1
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--
-- Slice 33.3: adds the first M3 recognition pattern at stable id=1.
--
-- Runtime meaning:
--   RecognitionSystem may surface this pattern to a nearby non-owner when
--   the current ball carrier sharply changes direction within the recent
--   five-tick window. Defender behavior tuning can consume the resulting
--   AwarenessView::recognized_patterns entry in later Slice 33 work.
--
-- Idempotent: ON CONFLICT (key) DO NOTHING makes reruns safe.
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

BEGIN;

INSERT INTO sim_pattern_registry (id, key, category, description) VALUES
    (1, 'pattern_being_beaten_1v1', 'defensive_read',
     'Defensive recognition pattern: a nearby non-owner sees the ball carrier sharply change direction in a 1v1 beat attempt')
ON CONFLICT (key) DO NOTHING;

-- Same guarded setval as other registry migrations.
DO $$
DECLARE
    seq_name TEXT;
BEGIN
    seq_name := pg_get_serial_sequence('sim_pattern_registry', 'id');
    IF seq_name IS NOT NULL THEN
        PERFORM setval(seq_name,
                       GREATEST((SELECT MAX(id) FROM sim_pattern_registry), 1));
    END IF;
END $$;

-- Self-audit for the new pattern ID.
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM sim_pattern_registry
                   WHERE key = 'pattern_being_beaten_1v1' AND id = 1) THEN
        RAISE EXCEPTION 'migration 230 post-check failed: pattern_being_beaten_1v1 is not at id=1';
    END IF;
END $$;

COMMIT;

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- End of migration 230.
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
