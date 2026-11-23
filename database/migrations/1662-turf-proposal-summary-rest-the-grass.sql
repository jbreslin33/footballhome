-- 🏟 Erie Avenue turf proposal: the summary's benefit line (James 11/23 "take
-- out the ages etc. and neigboohord. just put allows for resting of grass
-- field and extended training in late fall, winter and early spring").
BEGIN;
UPDATE proposal_sections s SET body = replace(s.body,
  'It gives year-round small-sided soccer to the youth teams (U8–U12), free open play for neighbourhood kids, and futsal-style training for the men''s and women''s teams, who all now share grass that closes in wet weather and winter.',
  'It allows the grass field to rest and extends training into late fall, winter and early spring.')
FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'erie-avenue-turf' AND s.sort_order = 1;
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM proposal_sections s JOIN proposals p ON p.id = s.proposal_id
                  WHERE p.code = 'erie-avenue-turf' AND s.sort_order = 1
                    AND s.body LIKE '%It allows the grass field to rest%' AND s.body NOT LIKE '%U8–U12%') THEN
    RAISE EXCEPTION 'turf proposal: summary line not replaced';
  END IF;
END $$;
COMMIT;
