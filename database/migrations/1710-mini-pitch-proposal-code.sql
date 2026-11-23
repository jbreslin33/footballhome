-- 🏟 The mini pitch proposal's link says mini pitch (James 11/23 "it still is
-- named …#proposals/erie-avenue-turf it sould be mini pitch right?").
-- proposals.code erie-avenue-turf → turf-mini-pitch, so the page is
-- #proposals/turf-mini-pitch (beside #proposals/field-turf-pitches). Nothing
-- in the code refers to the old value; sections hang off the id.
BEGIN;
UPDATE proposals SET code = 'turf-mini-pitch' WHERE code = 'erie-avenue-turf';
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM proposals WHERE code = 'turf-mini-pitch' AND title = 'Turf Mini Pitch') THEN
    RAISE EXCEPTION 'mini pitch: code not renamed';
  END IF;
END $$;
COMMIT;
