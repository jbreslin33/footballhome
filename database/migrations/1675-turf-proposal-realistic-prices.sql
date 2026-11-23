-- 🏟 Erie Avenue turf proposal: realistic prices (James 11/23 "turf only 104k
-- lol?" + "that seems a lot"). Mig 1674 took the TOP of one cost guide's
-- range ($15 / $18 a sq ft) and overshot. Other published figures for sports
-- turf laid on an existing base put carpet + labour + shock pad at about
-- $4–$7 (Texas Tuff: carpet $2.50–$4, labour $0.65–$1.40, pad $0.75–$1.50)
-- and the pad alone at $1.50–$3.50 (Artificial Turf Guide). The proposal now
-- uses $7.50 (roll-up) and $8.50 (permanent) a sq ft with pad, installed —
-- the low end of the Mighty Grass guide, above the Texas Tuff figures.
-- Other lines take a middle figure: design/permit/mobilisation $5,000,
-- netting $7,500, fence 319 ft × $44 (Ergeon's typical job) = $14,000,
-- kickboards $11,500. Package = (turf + $5,000 + extras) × 1.10, nearest
-- $1,000:  roll-up 54,093 / 62,343 / 77,743 / 90,393
--          permanent 60,572 / 68,822 / 84,222 / 96,872

BEGIN;

UPDATE proposals SET
  summary = 'From James Breslin: high-quality turf on a shock pad on the 76ers court at Lighthouse Sports Complex. Four packages, $54,000–$97,000.'
WHERE code = 'erie-avenue-turf';

UPDATE proposal_sections s SET body = replace(s.body,
  'Turf only is **$104,000** with roll-up turf or **$123,000** with permanent turf. With netting, fence and kickboards it is **$156,000** or **$176,000**.',
  'Turf only is about **$54,000** with roll-up turf or **$61,000** with permanent turf. With netting, fence and kickboards it is about **$90,000** or **$97,000**.')
FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'erie-avenue-turf' AND s.sort_order = 1;

UPDATE proposal_sections s SET body = $b$|Package|What you get|With roll-up turf|With permanent turf
|1 Turf only|Turf on a shock pad, installed, with lines|$54,000|$61,000
|2 Turf + netting|Package 1 plus ball netting behind the goals|$62,000|$69,000
|3 Turf + netting + fence|Package 2 plus a chain-link fence around the slab|$78,000|$84,000
|4 Everything|Package 3 plus kickboards along the long sides|$90,000|$97,000
Prices cover the whole slab (layout A) and include a 10% contingency. Layout B is about $6,000–$7,000 less.
These are budget estimates from published prices, not quotes. Published prices for this kind of turf vary a lot; a contractor quote settles it.
**Roll-up turf:** non-infill soccer turf over a loose shock pad. It rolls up, so the court can go back to basketball.
**Permanent turf:** infilled soccer turf on a 10–15 mm shock pad. The best surface; it stays down.
**Where the numbers come from**
|Turf|Per sq ft, with pad, installed|Whole slab (5,890 sq ft)|Inside the poles (about 5,180 sq ft)
|Roll-up|$7.50|$44,180|$38,850
|Permanent|$8.50|$50,070|$44,030
Published figures: [Mighty Grass](https://www.mightygrass.com/indoor-soccer-turf-cost-guide/) $7.50–$15 and $8.50–$18; [Texas Tuff](https://texas-tuff.com/blog/artificial-turf-football-field-cost/) about $4–$7 for carpet, labour and pad on a finished base.

|Line|In|Basis|Cost
|Lift and store the tiles|every package|volunteers|$0
|Design, permit, mobilisation|every package|lump sum, estimate|$5,000
|Ball netting|packages 2–4|estimate|$7,500
|Fence around the slab|packages 3–4|319 ft at $44 a foot installed (published range $32–$71, [Ergeon](https://www.ergeon.com/blog/post/chain-link-fence-costs))|$14,000
|Kickboards|package 4|estimate|$11,500
Not included: padding on the light and hoop poles ($1,000–$3,000, estimate), goals ($3,000–$6,000 for a portable pair), benches, and taking the hoops out for soccer ($2,000–$6,000, estimate).$b$
FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'erie-avenue-turf' AND s.sort_order = 4;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM proposal_sections s JOIN proposals p ON p.id = s.proposal_id
                  WHERE p.code = 'erie-avenue-turf' AND s.sort_order = 1 AND s.body LIKE '%about **$54,000**%') THEN
    RAISE EXCEPTION 'turf proposal: summary prices not replaced';
  END IF;
END $$;

COMMIT;
