-- 🏟 Erie Avenue turf proposal: the standard capital-proposal form (James
-- 11/23 "it needs to be standardized for a proposal"). "Packages" was this
-- proposal's own wording. The standard is a BASE BID plus ALTERNATES, each
-- alternate priced on its own (add or deduct), and the standard section
-- names. Same figures as mig 1664; each alternate now carries its own 10%
-- contingency: netting $5,000–$10,000 → +$5,500–$11,000; fence
-- $10,200–$22,700 → +$11,200–$25,000; kickboards $8,000–$15,000 →
-- +$8,800–$16,500 (sum +$25,500–$52,500, as before). Layout B becomes the
-- deduct alternate: −$5,900–$11,700 roll-up, −$6,700–$14,000 permanent.

BEGIN;

UPDATE proposals SET
  summary = 'High-quality turf on a shock pad on the 76ers court at Lighthouse Sports Complex. Base bid $57,400–$133,100; netting, fence and kickboards are add alternates. Lights already up.'
WHERE code = 'erie-avenue-turf';

-- Standard section names.
UPDATE proposal_sections s SET heading = v.new
FROM proposals p, (VALUES
  (1, 'Executive summary'), (2, 'Project site'), (5, 'Need and beneficiaries'),
  (6, 'Funding sources'), (7, 'Grant requirements (DCNR)'),
  (8, 'Operations and maintenance'), (9, 'Schedule'), (10, 'Decisions requested')
) AS v(ord, new)
WHERE p.id = s.proposal_id AND p.code = 'erie-avenue-turf' AND s.sort_order = v.ord;

UPDATE proposal_sections s SET body = replace(s.body,
  'in four priced packages: from barebones, turf and nothing else (**$57,400–$133,100**), to full, with fence, netting and kickboards (**$82,900–$185,600**).',
  'at a base bid of **$57,400–$133,100**: turf and nothing else. Netting, a fence and kickboards are add alternates, each priced separately; with all three the total is $82,900–$185,600.')
FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'erie-avenue-turf' AND s.sort_order = 1;

UPDATE proposal_sections s SET body = $b$**Base bid.** Lift the tiles, lay high-quality turf on a shock pad over the flat concrete, pad the poles. No fence, no netting.
- **Tiles up and stored.** Lift the court tiles and keep them in storage on site.
- **Clean the slab.** Sweep and wash the concrete; check that water drains off.
- **Turf and shock pad.** Contractor-laid soccer turf on a shock pad, either roll-up or permanent, over the whole slab (31.04 × 17.63 m), cut around each pole.
- **Pole padding.** Padding around each light pole and hoop pole.
- **Lines and goals.** Lines a yard inside the poles (about 27.4 × 14.65 m); two portable 4 × 2 m (12 × 6 ft) goals that move off for basketball.
**Alternates**, each priced separately in Budget:
- **Add alternate 1: Netting.** Taller ball netting behind the goals.
- **Add alternate 2: Fence.** Chain-link fence around the slab, about 97 m (319 ft).
- **Add alternate 3: Kickboards.** Low boards along the long sides.
- **Deduct alternate 4: Turf inside the poles only.** Layout B, about 29.2 × 16.48 m, no cut-outs.
**Back to basketball** (roll-up turf only): roll up the turf and lay the tiles back. The hoops never left. Reverse it for soccer; the rolled turf goes in storage on site.
Not priced here: benches, and taking the two hoops out for soccer.$b$
FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'erie-avenue-turf' AND s.sort_order = 3;

UPDATE proposal_sections s SET body = $b$A base bid plus alternates. Each alternate is priced on its own and added to, or taken off, the base bid.
|Item|What it is|With roll-up turf|With permanent turf (best)
|**Base bid**|Turf on a shock pad over the whole slab, pole padding, lines, two portable goals|**$57,400–$113,700**|**$63,900–$133,100**
|Add alternate 1: Netting|Taller ball netting behind the goals|+$5,500–$11,000|+$5,500–$11,000
|Add alternate 2: Fence|Chain-link fence around the slab, 319 ft|+$11,200–$25,000|+$11,200–$25,000
|Add alternate 3: Kickboards|Low boards along the long sides|+$8,800–$16,500|+$8,800–$16,500
|Deduct alternate 4: Turf inside the poles only|Layout B instead of the whole slab|−$5,900–$11,700|−$6,700–$14,000
|**Base bid + all add alternates**||**$82,900–$166,200**|**$89,400–$185,600**
Every figure includes a 10% contingency. They are built from published prices, not quotes; contractor bids replace them before any application.
**Cost basis**
|Turf|Rolls up?|What it is|Per sq ft|Turf, whole slab (5,890 sq ft)|Turf, inside the poles (about 5,180 sq ft)
|Roll-up|Yes, heavy|Non-infill soccer turf over a loose shock pad|$7.50–$15 ($6–$12 turf + $1.50–$3 pad, [Mighty Grass](https://www.mightygrass.com/indoor-soccer-turf-cost-guide/))|$44,180–$88,350|$38,850–$77,700
|Permanent|No|The best: infilled soccer turf on a 10–15 mm shock pad, organic infill; stays down for good|$8.50–$18 ($7–$15 turf + $1.50–$3 pad, [Mighty Grass](https://www.mightygrass.com/indoor-soccer-turf-cost-guide/))|$50,070–$106,020|$44,030–$93,240

|Also in the base bid|Basis|Low|High
|Lift and store the tiles|volunteers (in-kind match)|$0|$0
|Light pole and hoop pole padding|lump sum, estimate|$1,000|$3,000
|Two portable goals + nets|pair|$3,000|$6,000
|Design, permit, mobilisation|lump sum|$4,000|$6,000
|**Total**||**$8,000**|**$15,000**

|Alternates, before contingency|Basis|Low|High
|1 Netting|estimate|$5,000|$10,000
|2 Fence|319 ft at $32–$71 a foot installed ([Ergeon](https://www.ergeon.com/blog/post/chain-link-fence-costs))|$10,200|$22,700
|3 Kickboards|estimate|$8,000|$15,000
Not priced here: benches, and taking the hoops out for soccer ($2,000–$6,000, estimate).
Turf lasts about 8–10 years, so the plan sets aside about $5,000 a year for replacement.$b$
FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'erie-avenue-turf' AND s.sort_order = 4;

UPDATE proposal_sections s SET body = replace(replace(replace(s.body,
  'Size the ask to the package picked.', 'Size the ask to the base bid plus the alternates picked.'),
  'so it fits every package here ($57,400 barebones to $185,600 full).', 'so it fits the base bid with any of the alternates ($57,400 to $185,600).'),
  'Approach with a picked package and its price', 'Approach with the base bid and the alternates picked')
FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'erie-avenue-turf' AND s.sort_order = 6;

UPDATE proposal_sections s SET body = replace(replace(s.body,
  'pick a layout, a turf and a package;', 'pick the turf and the alternates;'),
  'bids for the chosen package.', 'contractor bids.')
FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'erie-avenue-turf' AND s.sort_order = 9;

UPDATE proposal_sections s SET body = $b$- **Turf:** roll-up (court goes back to basketball) or permanent (the best)?
- **Alternates:** which of netting (1), fence (2), kickboards (3) to add; take the deduct for turf inside the poles only (4)?
- **Hoops:** stay up during soccer, or come out?
- **Applicant:** The Light House (owns the land) or the club (needs a 25-year lease)?
Then one question for the DCNR Regional Advisor: is turf over a court, and roll-up turf, eligible? (Turf itself is: Chew Playground, 2026.)$b$
FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'erie-avenue-turf' AND s.sort_order = 10;

DO $$
DECLARE n int;
BEGIN
  SELECT count(*) INTO n FROM proposal_sections s JOIN proposals p ON p.id = s.proposal_id
   WHERE p.code = 'erie-avenue-turf' AND (s.body ILIKE '%package%' OR s.body ILIKE '%barebones%');
  IF n <> 0 THEN RAISE EXCEPTION 'turf proposal: % sections still say package/barebones', n; END IF;
END $$;

COMMIT;
