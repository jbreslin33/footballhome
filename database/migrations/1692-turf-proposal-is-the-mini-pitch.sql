-- 🏟 The turf proposal is the MINI PITCH proposal (James 11/23 "this needs to
-- be the mini pitch proposal because we will have a medium and full pitch
-- proposal"). Title and summary say so. The code stays erie-avenue-turf so
-- the #proposals/erie-avenue-turf link keeps working; the medium and full
-- pitch proposals get their own rows when they are written.
BEGIN;
UPDATE proposals SET
  title = 'Turf Mini Pitch',
  summary = replace(summary, 'From James Breslin: roll-up turf', 'From James Breslin. Mini pitch: roll-up turf')
WHERE code = 'erie-avenue-turf';
UPDATE proposal_sections s SET body = replace(s.body,
  'Put roll-up synthetic turf on a shock pad on the 76ers court at Lighthouse Sports Complex, 101 East Erie Avenue.',
  'This is the mini pitch proposal: roll-up synthetic turf on a shock pad on the 76ers court at Lighthouse Sports Complex, 101 East Erie Avenue.')
FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'erie-avenue-turf' AND s.sort_order = 1;
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM proposals WHERE code = 'erie-avenue-turf' AND title = 'Turf Mini Pitch' AND summary LIKE '%Mini pitch:%')
     OR NOT EXISTS (SELECT 1 FROM proposal_sections s JOIN proposals p ON p.id = s.proposal_id
                     WHERE p.code = 'erie-avenue-turf' AND s.sort_order = 1 AND s.body LIKE '%This is the mini pitch proposal:%') THEN
    RAISE EXCEPTION 'turf proposal: mini pitch naming not applied';
  END IF;
END $$;
COMMIT;
