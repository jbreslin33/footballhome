-- 🏟 Erie Avenue turf proposal: high-quality turf only, priced as packages
-- (James 11/23 "can a proposal like this have mutliple op;tions? with the
-- price there? like barebones would be high quality turf wiith shock of
-- course but that is it. no fence no net. we only want high quality").
--
-- The two cheap roll-out turfs (old options 1–2) are gone. What is left is
-- the two contractor-laid turfs on a shock pad: roll-up (non-infill) and
-- permanent (infilled, the best). Barebones = that turf + pad, pole padding,
-- lines, two portable goals. Packages step up from it: + netting, + fence
-- and netting, full (+ kickboards). Per-sq-ft prices and shared lines are
-- unchanged (mig 1612/1651); package add-ons carry the same 10% contingency:
-- netting $5,000–$10,000 → +$5,500–$11,000; + fence $10,200–$22,700 →
-- +$16,700–$36,000; + kickboards $8,000–$15,000 → +$25,500–$52,500.

BEGIN;

UPDATE proposals SET
  summary = 'High-quality turf on a shock pad on the 76ers court at Lighthouse Sports Complex: barebones $51,500–$133,100; netting, fence and kickboards priced as steps up. Lights already up.',
  as_of = '2026-11-23'
WHERE code = 'erie-avenue-turf';

UPDATE proposal_sections s SET body = $b$Lighthouse asks for **$51,500–$133,100** for the barebones job: high-quality synthetic turf on a shock pad on the 76ers court at Lighthouse Sports Complex, 101 East Erie Avenue, and nothing else. Netting, a fence and kickboards are priced as steps up from there, to about $185,600 with everything. The court's tiles lift off and are kept in storage on site. Under them is a flat concrete slab, **31.04 × 17.63 m (102 × 58 ft)**, so there is no excavation, paving or drainage work, and the lights are already up.
The light poles and hoop poles stand inside the slab and stay where they are, padded. There are two layouts: turf the whole slab and cut it around the poles, or turf only inside the poles. Either way the lines sit a yard inside the poles. With the roll-up turf the court works both ways: roll up the turf and lay the tiles back for basketball. It gives year-round small-sided soccer to the youth teams (U8–U12), free open play for neighbourhood kids, and futsal-style training for the men's and women's teams, who all now share grass that closes in wet weather and winter.$b$
FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'erie-avenue-turf' AND s.sort_order = 1;

UPDATE proposal_sections s SET body = $b$Lift the tiles, lay high-quality turf on a shock pad over the flat concrete, pad the poles. Pick a layout (see The site), a turf and a package (see Budget).
- **Tiles up and stored.** Lift the court tiles and keep them in storage on site.
- **Clean the slab.** Sweep and wash the concrete; check that water drains off.
- **Turf and shock pad.** Contractor-laid soccer turf on a shock pad, either roll-up or permanent. Layout A: the whole slab, 31.04 × 17.63 m, cut around each pole. Layout B: inside the poles, about 29.2 × 16.48 m.
- **Pole padding.** Padding around each light pole and hoop pole.
- **Lines and goals.** Lines a yard inside the poles (about 27.4 × 14.65 m); two portable 4 × 2 m (12 × 6 ft) goals that move off for basketball.
That is the barebones job: no fence, no netting.
**Back to basketball** (roll-up turf only): roll up the turf and lay the tiles back. The hoops never left. Reverse it for soccer; the rolled turf goes in storage on site.
Steps up from barebones, each priced in Budget:
- **Netting.** Taller ball netting behind the goals.
- **Fence.** Chain-link fence around the slab, about 97 m (319 ft).
- **Kickboards.** Low boards along the long sides.
Priced on their own, outside the packages: benches, and taking the two hoops out for soccer.$b$
FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'erie-avenue-turf' AND s.sort_order = 3;

UPDATE proposal_sections s SET body = $b$Every package uses high-quality soccer turf on a shock pad, laid by a contractor. Barebones is that and nothing else: no fence, no netting. Prices are published per-square-foot figures, not quotes; bids replace them before any application.
|Turf|Rolls up?|What it is|Per sq ft|Turf, layout A (5,890 sq ft)|Turf, layout B (about 5,180 sq ft)
|Roll-up|Yes, heavy|Non-infill soccer turf over a loose shock pad|$7.50–$15 ($6–$12 turf + $1.50–$3 pad, [Mighty Grass](https://www.mightygrass.com/indoor-soccer-turf-cost-guide/))|$44,180–$88,350|$38,850–$77,700
|Permanent|No|The best: infilled soccer turf on a 10–15 mm shock pad, organic infill; stays down for good|$8.50–$18 ($7–$15 turf + $1.50–$3 pad, [Mighty Grass](https://www.mightygrass.com/indoor-soccer-turf-cost-guide/))|$50,070–$106,020|$44,030–$93,240

|Barebones also includes|Basis|Low|High
|Lift and store the tiles|volunteers (in-kind match)|$0|$0
|Light pole and hoop pole padding|lump sum, estimate|$1,000|$3,000
|Two portable goals + nets|pair|$3,000|$6,000
|Design, permit, mobilisation|lump sum|$4,000|$6,000
|**Shared total**||**$8,000**|**$15,000**

|Barebones total, with 10% contingency|Layout A, whole slab|Layout B, inside the poles
|Roll-up turf|~$57,400–$113,700|~$51,500–$102,000
|Permanent turf (best)|~$63,900–$133,100|~$57,200–$119,100

|Package|What it adds|Adds to the barebones total
|Barebones|Turf, shock pad, pole padding, lines, two portable goals|nothing
|+ Netting|Taller ball netting behind the goals|+$5,500–$11,000
|+ Fence and netting|Chain-link fence around the slab (319 ft), and the netting|+$16,700–$36,000
|Full|Fence, netting, and kickboards along the long sides|+$25,500–$52,500
Example: permanent turf on the whole slab with fence and netting is about $80,600–$169,100.
The package add-ons include the 10% contingency. Behind them: netting $5,000–$10,000 and kickboards $8,000–$15,000 (estimates), fence $10,200–$22,700 (319 ft at $32–$71 a foot installed, [Ergeon](https://www.ergeon.com/blog/post/chain-link-fence-costs)). Not in any package: benches (price when bid) and taking the hoops out for soccer ($2,000–$6,000, estimate).
Turf lasts about 8–10 years, so the plan sets aside about $5,000 a year for replacement.$b$
FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'erie-avenue-turf' AND s.sort_order = 4;

UPDATE proposal_sections s SET body = replace(replace(replace(replace(replace(s.body,
  'Size the ask to the option picked.', 'Size the ask to the package picked.'),
  'so it fits options 3 and 4 ($51,500–$133,100). The roll-up options 1 and 2 ($17,300–$47,700) suit sponsors and smaller grants.',
  'so it fits every package here ($51,500 barebones to about $185,600 with everything). Sponsors supply the match.'),
  'Strong for options 3–4: nonprofits eligible', 'Strong: nonprofits eligible'),
  'Good for options 1–2, and the match for 3–4', 'Good for the match'),
  'Approach with a picked option and its price', 'Approach with a picked package and its price')
FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'erie-avenue-turf' AND s.sort_order = 6;

UPDATE proposal_sections s SET body = replace(replace(replace(replace(s.body,
  'pick a layout and a turf option;', 'pick a layout, a turf and a package;'),
  'prices for the chosen option.', 'bids for the chosen package.'),
  'DCNR application window (options 3–4).', 'DCNR application window.'),
  ' Options 1–2 can go down as soon as the money is raised.', '')
FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'erie-avenue-turf' AND s.sort_order = 9;

UPDATE proposal_sections s SET body = $b$- Which layout: the whole slab cut around the poles, or inside the poles?
- Which turf: roll-up (court goes back to basketball) or permanent (the best)?
- Which package: barebones, or with netting, fence, kickboards?
- Do the hoops stay up during soccer, or come out?
- Who applies: The Light House (owns the land) or the club (needs a 25-year lease).
- Does the 2019 Sixers court deal allow covering it?
- Is turf over a court, and roll-up turf, eligible for DCNR? (Turf itself is: Chew Playground, 2026.)$b$
FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'erie-avenue-turf' AND s.sort_order = 10;

DO $$
DECLARE n int;
BEGIN
  SELECT count(*) INTO n FROM proposal_sections s JOIN proposals p ON p.id = s.proposal_id
   WHERE p.code = 'erie-avenue-turf' AND s.sort_order IN (6, 9)
     AND (s.body ~ '[Oo]ptions? [1-4]' OR s.body LIKE '%option picked%' OR s.body LIKE '%picked option%' OR s.body LIKE '%turf option%' OR s.body LIKE '%chosen option%');
  IF n <> 0 THEN RAISE EXCEPTION 'turf proposal: % sections still talk about numbered options', n; END IF;
END $$;

COMMIT;
