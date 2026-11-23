-- 🏟 Erie Avenue turf proposal: package 1 is turf only (James 11/23 "turf
-- only lol", after "why are you adding goals to 1st package"). Pole padding
-- ($1,000–$3,000) leaves the packages too and is listed under Not included.
-- What stays in every package besides the turf and pad is the cost of doing
-- the job: design, permit, mobilisation ($4,000–$6,000). Every price drops
-- by $1,100–$3,300 from mig 1672.

BEGIN;

UPDATE proposals SET
  summary = 'From James Breslin: high-quality turf on a shock pad on the 76ers court at Lighthouse Sports Complex. Four packages, $53,000–$175,700.'
WHERE code = 'erie-avenue-turf';

UPDATE proposal_sections s SET body = replace(s.body,
  'Four packages, from **$54,100–$126,500** (turf only) to **$79,600–$179,000** (turf, netting, fence and kickboards).',
  'Four packages, from **$53,000–$123,200** (turf only) to **$78,500–$175,700** (turf, netting, fence and kickboards).')
FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'erie-avenue-turf' AND s.sort_order = 1;

UPDATE proposal_sections s SET body = replace(s.body, 'All of them stay and get padding.', 'All of them stay.')
FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'erie-avenue-turf' AND s.sort_order = 2;

UPDATE proposal_sections s SET body = replace(s.body, E'- Pad each light pole and hoop pole.\n', '')
FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'erie-avenue-turf' AND s.sort_order = 3;

UPDATE proposal_sections s SET body = $b$|Package|What you get|With roll-up turf|With permanent turf
|1 Turf only|Turf on a shock pad, installed, with lines|$53,000–$103,800|$59,500–$123,200
|2 Turf + netting|Package 1 plus ball netting behind the goals|$58,500–$114,800|$65,000–$134,200
|3 Turf + netting + fence|Package 2 plus a chain-link fence around the slab|$69,700–$139,800|$76,200–$159,200
|4 Everything|Package 3 plus kickboards along the long sides|$78,500–$156,300|$85,000–$175,700
Prices cover the whole slab (layout A) and include a 10% contingency. Layout B is about $6,000–$14,000 less.
**Roll-up turf:** non-infill soccer turf over a loose shock pad. It rolls up, so the court can go back to basketball.
**Permanent turf:** infilled soccer turf on a 10–15 mm shock pad. The best surface; it stays down.
**Where the numbers come from**
|Turf|Per sq ft|Whole slab (5,890 sq ft)|Inside the poles (about 5,180 sq ft)
|Roll-up|$7.50–$15 ($6–$12 turf + $1.50–$3 pad, [Mighty Grass](https://www.mightygrass.com/indoor-soccer-turf-cost-guide/))|$44,180–$88,350|$38,850–$77,700
|Permanent|$8.50–$18 ($7–$15 turf + $1.50–$3 pad, [Mighty Grass](https://www.mightygrass.com/indoor-soccer-turf-cost-guide/))|$50,070–$106,020|$44,030–$93,240

|In every package|Basis|Low|High
|Lift and store the tiles|volunteers|$0|$0
|Design, permit, mobilisation|lump sum|$4,000|$6,000

|Added by packages 2–4|Basis|Low|High
|Ball netting|estimate|$5,000|$10,000
|Fence around the slab|319 ft at $32–$71 a foot installed ([Ergeon](https://www.ergeon.com/blog/post/chain-link-fence-costs))|$10,200|$22,700
|Kickboards|estimate|$8,000|$15,000
Not included: padding on the light and hoop poles ($1,000–$3,000, estimate), goals ($3,000–$6,000 for a portable pair), benches, and taking the hoops out for soccer ($2,000–$6,000, estimate).$b$
FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'erie-avenue-turf' AND s.sort_order = 4;

DO $$
DECLARE n int;
BEGIN
  SELECT count(*) INTO n FROM proposal_sections s JOIN proposals p ON p.id = s.proposal_id
   WHERE p.code = 'erie-avenue-turf' AND (
        (s.sort_order = 1 AND s.body LIKE '%$53,000–$123,200%')
     OR (s.sort_order = 2 AND s.body NOT LIKE '%get padding%')
     OR (s.sort_order = 3 AND s.body NOT LIKE '%Pad each%'));
  IF n <> 3 THEN RAISE EXCEPTION 'turf proposal: % of 3 replaced sections updated', n; END IF;
END $$;

COMMIT;
