-- 🏟 Erie Avenue turf proposal: goals are not in the packages (James 11/23
-- "why are you adding goals to 1st package"; barebones = "high quality turf
-- wiith shock of course but that is it"). The pair of portable goals
-- ($3,000–$6,000) leaves every package and is listed under Not included.
-- Every package price drops by that plus its 10% contingency
-- ($3,300–$6,600): in-every-package lines are now $5,000–$9,000.

BEGIN;

UPDATE proposals SET
  summary = 'From James Breslin: high-quality turf on a shock pad on the 76ers court at Lighthouse Sports Complex. Four packages, $54,100–$179,000.'
WHERE code = 'erie-avenue-turf';

UPDATE proposal_sections s SET body = replace(s.body,
  'Four packages, from **$57,400–$133,100** (turf only) to **$82,900–$185,600** (turf, netting, fence and kickboards).',
  'Four packages, from **$54,100–$126,500** (turf only) to **$79,600–$179,000** (turf, netting, fence and kickboards).')
FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'erie-avenue-turf' AND s.sort_order = 1;

UPDATE proposal_sections s SET body = replace(s.body,
  '- Mark lines a yard inside the poles; two portable 4 × 2 m goals.', '- Mark lines a yard inside the poles.')
FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'erie-avenue-turf' AND s.sort_order = 3;

UPDATE proposal_sections s SET body = $b$|Package|What you get|With roll-up turf|With permanent turf
|1 Barebones|Turf on a shock pad, pole padding, lines|$54,100–$107,100|$60,600–$126,500
|2 Barebones + netting|Package 1 plus ball netting behind the goals|$59,600–$118,100|$66,100–$137,500
|3 Barebones + netting + fence|Package 2 plus a chain-link fence around the slab|$70,800–$143,100|$77,300–$162,500
|4 Everything|Package 3 plus kickboards along the long sides|$79,600–$159,600|$86,100–$179,000
Prices cover the whole slab (layout A) and include a 10% contingency. Layout B is about $6,000–$14,000 less.
**Roll-up turf:** non-infill soccer turf over a loose shock pad. It rolls up, so the court can go back to basketball.
**Permanent turf:** infilled soccer turf on a 10–15 mm shock pad. The best surface; it stays down.
**Where the numbers come from**
|Turf|Per sq ft|Whole slab (5,890 sq ft)|Inside the poles (about 5,180 sq ft)
|Roll-up|$7.50–$15 ($6–$12 turf + $1.50–$3 pad, [Mighty Grass](https://www.mightygrass.com/indoor-soccer-turf-cost-guide/))|$44,180–$88,350|$38,850–$77,700
|Permanent|$8.50–$18 ($7–$15 turf + $1.50–$3 pad, [Mighty Grass](https://www.mightygrass.com/indoor-soccer-turf-cost-guide/))|$50,070–$106,020|$44,030–$93,240

|In every package|Basis|Low|High
|Lift and store the tiles|volunteers|$0|$0
|Light pole and hoop pole padding|estimate|$1,000|$3,000
|Design, permit, mobilisation|lump sum|$4,000|$6,000

|Added by packages 2–4|Basis|Low|High
|Ball netting|estimate|$5,000|$10,000
|Fence around the slab|319 ft at $32–$71 a foot installed ([Ergeon](https://www.ergeon.com/blog/post/chain-link-fence-costs))|$10,200|$22,700
|Kickboards|estimate|$8,000|$15,000
Not included: goals ($3,000–$6,000 for a portable pair), benches, and taking the hoops out for soccer ($2,000–$6,000, estimate).$b$
FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'erie-avenue-turf' AND s.sort_order = 4;

DO $$
DECLARE n int;
BEGIN
  SELECT count(*) INTO n FROM proposal_sections s JOIN proposals p ON p.id = s.proposal_id
   WHERE p.code = 'erie-avenue-turf' AND (
        (s.sort_order = 1 AND s.body LIKE '%$54,100–$126,500%')
     OR (s.sort_order = 3 AND s.body NOT LIKE '%portable%'));
  IF n <> 2 THEN RAISE EXCEPTION 'turf proposal: % of 2 replaced sections updated', n; END IF;
END $$;

COMMIT;
