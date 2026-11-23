-- 🏟 Erie Avenue turf proposal: barebones = turf delivered, we install it
-- (James 11/23 "why are you adding stuff to barebones. we can install
-- ourselves for barebones and have it deliverd. but then 2nd package would
-- have install by contractor"). Five packages now: 1 turf and pad delivered,
-- laid by us; 2 the same laid by a contractor; 3 + netting; 4 + fence;
-- 5 + kickboards. Nothing else is added: the design/permit/mobilisation line
-- and the 10% contingency are gone from every price.
-- Per sq ft: materials $5.50 roll-up / $6.50 permanent (turf + pad),
-- contractor install $2.00 → $7.50 / $8.50 installed, as in mig 1675.
-- Whole slab 5,890 sq ft, nearest $1,000:
--   roll-up   32,395 / 44,175 / 51,675 / 65,675 / 77,175
--   permanent 38,285 / 50,065 / 57,565 / 71,565 / 83,065

BEGIN;

UPDATE proposals SET
  summary = 'From James Breslin: high-quality turf on a shock pad on the 76ers court at Lighthouse Sports Complex. Five packages, $32,000–$83,000.'
WHERE code = 'erie-avenue-turf';

UPDATE proposal_sections s SET body = replace(s.body,
  'Four packages. Turf only is about **$54,000** with roll-up turf or **$61,000** with permanent turf. With netting, fence and kickboards it is about **$90,000** or **$97,000**.',
  'Five packages. Barebones, turf delivered and laid by us, is about **$32,000** with roll-up turf or **$38,000** with permanent turf. Laid by a contractor it is about **$44,000** or **$50,000**. With netting, fence and kickboards it is about **$77,000** or **$83,000**.')
FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'erie-avenue-turf' AND s.sort_order = 1;

UPDATE proposal_sections s SET body = replace(s.body,
  '- Lay soccer turf on a shock pad (contractor).',
  '- Lay soccer turf on a shock pad: ourselves in package 1, a contractor in packages 2–5.')
FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'erie-avenue-turf' AND s.sort_order = 3;

UPDATE proposal_sections s SET body = $b$|Package|What you get|With roll-up turf|With permanent turf
|1 Barebones|Turf and shock pad delivered; we lay it ourselves|$32,000|$38,000
|2 Installed|Turf and shock pad laid by a contractor|$44,000|$50,000
|3 Installed + netting|Package 2 plus ball netting behind the goals|$52,000|$58,000
|4 Installed + netting + fence|Package 3 plus a chain-link fence around the slab|$66,000|$72,000
|5 Everything|Package 4 plus kickboards along the long sides|$77,000|$83,000
Prices cover the whole slab (layout A). Layout B is about $4,000–$6,000 less. Package 1 does not include freight.
These are estimates from published prices, not quotes, with no contingency added.
**Roll-up turf:** non-infill soccer turf over a loose shock pad. It rolls up, so the court can go back to basketball.
**Permanent turf:** infilled soccer turf on a 10–15 mm shock pad. The best surface; it stays down.
**Where the numbers come from**
|Turf|Turf and pad, per sq ft|Contractor install, per sq ft|Whole slab (5,890 sq ft), delivered|Whole slab, installed
|Roll-up|$5.50|$2.00|$32,400|$44,180
|Permanent|$6.50|$2.00|$38,290|$50,070
Published figures: [Mighty Grass](https://www.mightygrass.com/indoor-soccer-turf-cost-guide/) $7.50–$15 and $8.50–$18 installed; [Texas Tuff](https://texas-tuff.com/blog/artificial-turf-football-field-cost/) carpet $2.50–$4, pad $0.75–$1.50, labour $0.65–$1.40.

|Line|In|Basis|Cost
|Ball netting|packages 3–5|estimate|$7,500
|Fence around the slab|packages 4–5|319 ft at $44 a foot installed (published range $32–$71, [Ergeon](https://www.ergeon.com/blog/post/chain-link-fence-costs))|$14,000
|Kickboards|package 5|estimate|$11,500
Not included: padding on the light and hoop poles ($1,000–$3,000, estimate), goals ($3,000–$6,000 for a portable pair), benches, and taking the hoops out for soccer ($2,000–$6,000, estimate).$b$
FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'erie-avenue-turf' AND s.sort_order = 4;

UPDATE proposal_sections s SET body = replace(s.body, '- **Package:** 1, 2, 3 or 4?', '- **Package:** 1, 2, 3, 4 or 5?')
FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'erie-avenue-turf' AND s.sort_order = 10;

DO $$
DECLARE n int;
BEGIN
  SELECT count(*) INTO n FROM proposal_sections s JOIN proposals p ON p.id = s.proposal_id
   WHERE p.code = 'erie-avenue-turf' AND (
        (s.sort_order = 1  AND s.body LIKE '%Five packages.%')
     OR (s.sort_order = 3  AND s.body LIKE '%ourselves in package 1%')
     OR (s.sort_order = 10 AND s.body LIKE '%1, 2, 3, 4 or 5?%'));
  IF n <> 3 THEN RAISE EXCEPTION 'turf proposal: % of 3 replaced sections updated', n; END IF;
END $$;

COMMIT;
