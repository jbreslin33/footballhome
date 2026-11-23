-- 🏟 Erie Avenue turf proposal: one price per package (James 11/23 "if we
-- are only doing high quality how is range so large lol 57k to 113k lol").
-- The ranges were the whole published spread ($6–$12 turf + $1.50–$3 pad a
-- sq ft, roll-up; $7–$15 + $1.50–$3, permanent), which runs from basic to
-- high quality. High quality only = the top of that spread: $15 and $18 a
-- sq ft. The other lines take their top figure too. Each package =
-- (turf + $6,000 design/permit/mobilisation + its extras) × 1.10
-- contingency, rounded to the nearest $1,000:
--   roll-up   103,785 / 114,785 / 139,755 / 156,255
--   permanent 123,222 / 134,222 / 159,192 / 175,692

BEGIN;

UPDATE proposals SET
  summary = 'From James Breslin: high-quality turf on a shock pad on the 76ers court at Lighthouse Sports Complex. Four packages, $104,000–$176,000.'
WHERE code = 'erie-avenue-turf';

UPDATE proposal_sections s SET body = replace(s.body,
  'Four packages, from **$53,000–$123,200** (turf only) to **$78,500–$175,700** (turf, netting, fence and kickboards). Prices are estimates from published figures, not quotes.',
  'Four packages. Turf only is **$104,000** with roll-up turf or **$123,000** with permanent turf. With netting, fence and kickboards it is **$156,000** or **$176,000**. Prices are estimates from published figures, not quotes.')
FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'erie-avenue-turf' AND s.sort_order = 1;

UPDATE proposal_sections s SET body = $b$|Package|What you get|With roll-up turf|With permanent turf
|1 Turf only|Turf on a shock pad, installed, with lines|$104,000|$123,000
|2 Turf + netting|Package 1 plus ball netting behind the goals|$115,000|$134,000
|3 Turf + netting + fence|Package 2 plus a chain-link fence around the slab|$140,000|$159,000
|4 Everything|Package 3 plus kickboards along the long sides|$156,000|$176,000
Prices cover the whole slab (layout A) and include a 10% contingency. Layout B is about $12,000–$14,000 less.
These are budget figures: the top of the published price range, because this is high-quality turf only. Contractor quotes replace them.
**Roll-up turf:** non-infill soccer turf over a loose shock pad. It rolls up, so the court can go back to basketball.
**Permanent turf:** infilled soccer turf on a 10–15 mm shock pad. The best surface; it stays down.
**Where the numbers come from**
|Turf|Per sq ft|Whole slab (5,890 sq ft)|Inside the poles (about 5,180 sq ft)
|Roll-up|$15 ($12 turf + $3 pad; published range $7.50–$15, [Mighty Grass](https://www.mightygrass.com/indoor-soccer-turf-cost-guide/))|$88,350|$77,700
|Permanent|$18 ($15 turf + $3 pad; published range $8.50–$18, [Mighty Grass](https://www.mightygrass.com/indoor-soccer-turf-cost-guide/))|$106,020|$93,240

|Line|In|Basis|Cost
|Lift and store the tiles|every package|volunteers|$0
|Design, permit, mobilisation|every package|lump sum|$6,000
|Ball netting|packages 2–4|estimate|$10,000
|Fence around the slab|packages 3–4|319 ft at $71 a foot installed (published range $32–$71, [Ergeon](https://www.ergeon.com/blog/post/chain-link-fence-costs))|$22,700
|Kickboards|package 4|estimate|$15,000
Not included: padding on the light and hoop poles (up to $3,000, estimate), goals (up to $6,000 for a portable pair), benches, and taking the hoops out for soccer (up to $6,000, estimate).$b$
FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'erie-avenue-turf' AND s.sort_order = 4;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM proposal_sections s JOIN proposals p ON p.id = s.proposal_id
                  WHERE p.code = 'erie-avenue-turf' AND s.sort_order = 1 AND s.body LIKE '%Turf only is **$104,000**%') THEN
    RAISE EXCEPTION 'turf proposal: summary prices not replaced';
  END IF;
END $$;

COMMIT;
