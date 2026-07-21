-- 232-sim-concept-positioning.sql
-- Adds positioning concepts for future M4 behavior work while keeping M3 compatible.

BEGIN;

INSERT INTO sim_concept_registry (id, key, category, description)
VALUES
    (7, 'return_to_base', 'positioning', 'Concept for positioning behaviors that ask a defender to recover to base after a recovery action.')
ON CONFLICT (id) DO NOTHING;

INSERT INTO sim_concept_registry (id, key, category, description)
VALUES
    (8, 'stay_in_zone', 'positioning', 'Concept for positioning behaviors that keep a defender inside an assigned zone or shape.')
ON CONFLICT (id) DO NOTHING;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM sim_concept_registry WHERE id = 7 AND key = 'return_to_base'
    ) THEN
        RAISE EXCEPTION 'Expected sim_concept_registry row for return_to_base (id=7)';
    END IF;
    IF NOT EXISTS (
        SELECT 1 FROM sim_concept_registry WHERE id = 8 AND key = 'stay_in_zone'
    ) THEN
        RAISE EXCEPTION 'Expected sim_concept_registry row for stay_in_zone (id=8)';
    END IF;
END $$;

COMMIT;
