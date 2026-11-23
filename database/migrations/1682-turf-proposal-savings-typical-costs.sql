-- 🏟 Erie Avenue turf proposal: the Savings section states typical costs,
-- plainly (James 11/23 "just use it from typical light costs and typical
-- cement laying and foundation digging and leveling etc"). Same figures as
-- mig 1681; the rows are named for the work and the hedging line is gone.
BEGIN;
UPDATE proposal_sections s SET body = replace(replace(replace(replace(replace(s.body,
  '|What building from scratch adds|Quantity × unit price|', '|What building from scratch adds|Typical cost|'),
  '|Clear, grade and level the ground|lump sum (published $5,000–$15,000)|', '|Dig the foundation, grade and level the ground|lump sum (typically $5,000–$15,000)|'),
  '|Reinforced 4-inch concrete slab|area × $6 a sq ft (published $4–$7.50, ', '|Lay a reinforced 4-inch concrete slab|$6 a sq ft (typically $4–$7.50, '),
  '|Lights: poles, LED fixtures, wiring|lump sum (published $17,700–$155,240 for a basketball court, ', '|Put up lights: poles, LED fixtures, wiring|lump sum (typically $17,700–$155,240 for a court, '),
  E'\nThese are estimates from published figures, not quotes. The lighting figure is the least certain.', E'\nTypical costs from published figures, not quotes.')
FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'erie-avenue-turf' AND s.sort_order = 5;
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM proposal_sections s JOIN proposals p ON p.id = s.proposal_id
                  WHERE p.code = 'erie-avenue-turf' AND s.sort_order = 5
                    AND s.body LIKE '%Dig the foundation, grade and level%' AND s.body LIKE '%Lay a reinforced 4-inch%'
                    AND s.body LIKE '%Put up lights:%' AND s.body LIKE '%Typical costs from published figures, not quotes.'
                    AND s.body NOT LIKE '%least certain%') THEN
    RAISE EXCEPTION 'turf proposal: savings wording not replaced';
  END IF;
END $$;
COMMIT;
