-- 🏟 Erie Avenue turf proposal: one packages table, barebones is package 1
-- (James 11/23 "it looks very confusing. if so barebones should just be one
-- of the packages"). Budget now opens with four packages, each priced
-- complete for the two turfs; the per-sq-ft build-up moves underneath.
-- Package prices are layout A (whole slab) + 10% contingency, same figures as
-- mig 1654: barebones + $5,500–$11,000 netting, + $16,700–$36,000 fence and
-- netting, + $25,500–$52,500 full. Layout B is one line: about $6,000–$14,000
-- less (A − B barebones: roll-up $5,900–$11,700, permanent $6,700–$14,000).

BEGIN;

UPDATE proposals SET
  summary = 'High-quality turf on a shock pad on the 76ers court at Lighthouse Sports Complex, in four priced packages: barebones $57,400–$133,100, full $82,900–$185,600. Lights already up.'
WHERE code = 'erie-avenue-turf';

UPDATE proposal_sections s SET body = replace(s.body,
  'Lighthouse asks for **$51,500–$133,100** for the barebones job: high-quality synthetic turf on a shock pad on the 76ers court at Lighthouse Sports Complex, 101 East Erie Avenue, and nothing else. Netting, a fence and kickboards are priced as steps up from there, to about $185,600 with everything.',
  'Lighthouse proposes high-quality synthetic turf on a shock pad on the 76ers court at Lighthouse Sports Complex, 101 East Erie Avenue, in four priced packages: from barebones, turf and nothing else (**$57,400–$133,100**), to full, with fence, netting and kickboards (**$82,900–$185,600**).')
FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'erie-avenue-turf' AND s.sort_order = 1;

UPDATE proposal_sections s SET body = replace(s.body,
  'Steps up from barebones, each priced in Budget:', 'Packages 2–4 add, in turn:')
FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'erie-avenue-turf' AND s.sort_order = 3;

UPDATE proposal_sections s SET body = $b$Four packages, each priced complete. Package 1 is barebones: high-quality turf on a shock pad and nothing else.
|Package|What you get|With roll-up turf|With permanent turf (best)
|1 Barebones|Turf on a shock pad, pole padding, lines, two portable goals|$57,400–$113,700|$63,900–$133,100
|2 Netting|Package 1 plus taller ball netting behind the goals|$62,900–$124,700|$69,400–$144,100
|3 Fence and netting|Package 2 plus a chain-link fence around the slab|$74,100–$149,700|$80,600–$169,100
|4 Full|Package 3 plus kickboards along the long sides|$82,900–$166,200|$89,400–$185,600
Prices are for turf on the whole slab (layout A) and include a 10% contingency. Turf only inside the poles (layout B) takes about $6,000–$14,000 off any package. They are built from published figures, not quotes; bids replace them before any application.
**How the prices are built**
|Turf|Rolls up?|What it is|Per sq ft|Turf, layout A (5,890 sq ft)|Turf, layout B (about 5,180 sq ft)
|Roll-up|Yes, heavy|Non-infill soccer turf over a loose shock pad|$7.50–$15 ($6–$12 turf + $1.50–$3 pad, [Mighty Grass](https://www.mightygrass.com/indoor-soccer-turf-cost-guide/))|$44,180–$88,350|$38,850–$77,700
|Permanent|No|The best: infilled soccer turf on a 10–15 mm shock pad, organic infill; stays down for good|$8.50–$18 ($7–$15 turf + $1.50–$3 pad, [Mighty Grass](https://www.mightygrass.com/indoor-soccer-turf-cost-guide/))|$50,070–$106,020|$44,030–$93,240

|Every package also includes|Basis|Low|High
|Lift and store the tiles|volunteers (in-kind match)|$0|$0
|Light pole and hoop pole padding|lump sum, estimate|$1,000|$3,000
|Two portable goals + nets|pair|$3,000|$6,000
|Design, permit, mobilisation|lump sum|$4,000|$6,000
|**Total**||**$8,000**|**$15,000**

|Added by packages 2–4|Basis|Low|High
|Ball netting (package 2)|estimate|$5,000|$10,000
|Fence around the slab (package 3)|319 ft at $32–$71 a foot installed ([Ergeon](https://www.ergeon.com/blog/post/chain-link-fence-costs))|$10,200|$22,700
|Kickboards (package 4)|estimate|$8,000|$15,000
Not in any package: benches (price when bid) and taking the hoops out for soccer ($2,000–$6,000, estimate).
Turf lasts about 8–10 years, so the plan sets aside about $5,000 a year for replacement.$b$
FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'erie-avenue-turf' AND s.sort_order = 4;

UPDATE proposal_sections s SET body = replace(s.body, '($51,500 barebones to about $185,600 with everything)', '($57,400 barebones to $185,600 full)')
FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'erie-avenue-turf' AND s.sort_order = 6;

UPDATE proposal_sections s SET body = replace(s.body,
  '- **Package:** barebones, or with netting, fence, kickboards?',
  '- **Package:** 1 barebones, 2 netting, 3 fence and netting, or 4 full?')
FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'erie-avenue-turf' AND s.sort_order = 10;

DO $$
DECLARE n int;
BEGIN
  SELECT count(*) INTO n FROM proposal_sections s JOIN proposals p ON p.id = s.proposal_id
   WHERE p.code = 'erie-avenue-turf' AND (
        (s.sort_order = 1  AND s.body LIKE '%four priced packages%')
     OR (s.sort_order = 3  AND s.body LIKE '%Packages 2–4 add, in turn:%')
     OR (s.sort_order = 6  AND s.body LIKE '%($57,400 barebones to $185,600 full)%')
     OR (s.sort_order = 10 AND s.body LIKE '%1 barebones, 2 netting%'));
  IF n <> 4 THEN RAISE EXCEPTION 'turf proposal: % of 4 replaced sections updated', n; END IF;
END $$;

COMMIT;
