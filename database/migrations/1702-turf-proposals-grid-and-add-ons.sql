-- 🏟 Both turf proposals: one GRID plus a plain priced list of ADD-ONS,
-- instead of laddered packages (James 11/23 "i think we need to simplify the
-- add ons. they should be listed as simply add ons under each one and
-- priced. i tihnk we don't need multi proposals i think we need like a
-- grid"). Unit prices unchanged (migs 1691, 1693–1694).
-- Mini pitch grid: where the turf goes × who lays it (rows) by turf grade
-- (columns), $16,835–$64,790; adds the whole-slab-laid-by-us row; add-ons
-- netting, fence, kickboards, pole padding, goals, paint, benches; saving
-- shown as a % grid.
-- Field pitches grid: size (rows) by turf grade (columns), $167,625–$1,485,630;
-- add-ons per size: fence, netting, goals, lights; Full only: Division III
-- seating, shelters, scoreboard.

BEGIN;

UPDATE proposals SET summary = 'From James Breslin. Mini pitch: roll-up turf on a shock pad on the 76ers court at Lighthouse Sports Complex. $16,835–$64,790 by area, install and turf grade, plus add-ons.'
WHERE code = 'erie-avenue-turf';
UPDATE proposals SET summary = 'From James Breslin. Turf pitches on the field area at Erie Avenue: 5v5, 7v7, 9v9 and Full (Premier League size), $167,625–$1,485,630 by size and turf grade, plus add-ons.'
WHERE code = 'field-turf-pitches';

UPDATE proposal_sections s SET body = replace(s.body,
  'Six packages, each building on the one before, each priced with low-end, mid-range and high-end turf: from **$16,835** (Barebones, low-end turf inside the poles, laid by us) up to **$104,326** (Deluxe, high-end turf over the whole slab, laid by a contractor, with netting, fence, kickboards, pole padding and goals). Prices are estimates from published figures, not quotes.',
  'The turf and shock pad cost **$16,835** (low-end turf inside the poles, laid by us) to **$64,790** (high-end turf over the whole slab, laid by a contractor). Netting, a fence, kickboards, pole padding and goals are add-ons, each priced on its own. Prices are estimates from published figures, not quotes.')
FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'erie-avenue-turf' AND s.sort_order = 1;

UPDATE proposal_sections s SET body = replace(s.body,
  '- Lay soccer turf on a shock pad: ourselves in package 1, a contractor in packages 2–6.',
  '- Lay soccer turf on a shock pad: ourselves or a contractor.')
FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'erie-avenue-turf' AND s.sort_order = 3;

UPDATE proposal_sections s SET heading = 'Costs', body = $b$Pick one box in the grid, then any add-ons.
|Turf and shock pad|Low-end turf|Mid-range turf|High-end turf
|Inside the poles, we lay it|$16,835|$28,490|$46,620
|Inside the poles, contractor lays it|$27,195|$38,850|$56,980
|Whole slab, we lay it|$19,142|$32,395|$53,010
|Whole slab, contractor lays it|$30,922|$44,175|$64,790
**Inside the poles** is about 29.2 × 16.48 m = 5,180 sq ft, with nothing cut around the poles. **The whole slab** is 31.04 × 17.63 m = 5,890 sq ft, cut around each pole.
**We lay it:** the turf and shock pad are delivered and we do the work. Freight is not in the price. **Contractor lays it:** a turf contractor lays the pad, seams the turf and marks the lines.
All of it is roll-up turf: non-infill soccer turf over a loose shock pad.
**Add-ons**
|Add-on|What it is|Cost
|Ball netting|Taller netting behind both goals|$7,500
|Fence|Regular chain-link fence around the slab, 319 ft at $44 a foot|$14,036
|Kickboards|Low boards along both long sides, for players to practise off|$11,500
|Pole padding|Padding on every light pole and hoop pole|$2,000
|Goals|One portable pair with nets|$4,500
|Paint the slab for basketball|Basketball lines on the concrete, so no tiles are needed|price when bid
|Benches||price when bid
**How the grid is priced**
|Per sq ft|Low-end|Mid-range|High-end
|Turf|$2.50|$4.00|$6.00
|Shock pad|$0.75|$1.50|$3.00
|Contractor install|$2.00|$2.00|$2.00
**Saved against building from scratch.** The slab and the lights are already there. Building the same pitch on open ground would add $105,340, whichever box is picked. The grid below shows that saving as a share of the from-scratch cost.
|Saved|Low-end turf|Mid-range turf|High-end turf
|Inside the poles, we lay it|86%|79%|69%
|Inside the poles, contractor lays it|79%|73%|65%
|Whole slab, we lay it|85%|76%|67%
|Whole slab, contractor lays it|77%|70%|62%

|What building from scratch adds, for our space|Typical cost|Cost
|Dig the foundation, grade and level the ground|lump sum (typically $5,000–$15,000)|$10,000
|Lay a reinforced 4-inch concrete slab|5,890 sq ft × $6 (typically $4–$7.50, [LatestCost](https://latestcost.com/concrete-tennis-court-cost-installation-prices/))|$35,340
|Put up lights: poles, LED fixtures, wiring|lump sum (typically $17,700–$155,240 for a court, [Sports Venue Calculator](https://sportsvenuecalculator.com/knowledge/led-sports-lighting/basketball-court-lighting/))|$60,000
|**Saved**||**$105,340**
**About the prices.** Unit prices are from published figures, not quotes, with no contingency and no freight. Low-end and mid-range turf and pad are the bottom and top of one published range ([Texas Tuff](https://texas-tuff.com/blog/artificial-turf-football-field-cost/)); high-end is non-infill soccer turf and a thick shock pad ([Mighty Grass](https://www.mightygrass.com/indoor-soccer-turf-cost-guide/)). The fence is $44 a foot ([Ergeon](https://www.ergeon.com/blog/post/chain-link-fence-costs), published range $32–$71). Netting, kickboards, pole padding and goals are estimates.$b$
FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'erie-avenue-turf' AND s.sort_order = 4;

UPDATE proposal_sections s SET body = $b$- **Area:** inside the poles or the whole slab?
- **Who lays it:** us or a contractor?
- **Turf grade:** low-end, mid-range or high-end?
- **Add-ons:** which of netting, fence, kickboards, pole padding, goals?
- **Basketball:** keep the tiles to lay back, or paint the slab so no tiles are needed?$b$
FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'erie-avenue-turf' AND s.sort_order = 10;

UPDATE proposal_sections s SET body = replace(s.body,
  'Four sizes, 5v5, 7v7, 9v9 and Full (Premier League size), each in packages that build on the one before: from **$201,150** (5v5, pitch only) up to **$1,703,373** (Full, fenced and lit, with Division III seating for 1,000 and room to expand to Division I). Prices are estimates from published figures, not quotes.',
  'Four sizes, 5v5, 7v7, 9v9 and Full (Premier League size), each priced with low-end, mid-range and high-end turf: from **$167,625** (5v5, low-end) to **$1,485,630** (Full, high-end). A fence, netting, goals and lights are add-ons, each priced on its own, and so is Division III seating for the Full pitch. Prices are estimates from published figures, not quotes.')
FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'field-turf-pitches' AND s.sort_order = 1;

UPDATE proposal_sections s SET body = replace(s.body,
  '- Packages 2–4 add the fence, netting, goals, lights and seating.',
  '- Add-ons: fence, netting, goals, lights, seating.')
FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'field-turf-pitches' AND s.sort_order = 3;

UPDATE proposal_sections s SET heading = 'Costs', body = $b$Pick a size and a turf grade from the grid, then any add-ons.
|Pitch, ground works and turf|Low-end turf|Mid-range turf|High-end turf
|5v5, 14,900 sq ft|$167,625|$201,150|$253,300
|7v7, 27,320 sq ft|$307,350|$368,820|$464,440
|9v9, 43,340 sq ft|$487,575|$585,090|$736,780
|Full (11v11), 87,390 sq ft|$983,138|$1,179,765|$1,485,630
Every box is the whole pitch: the ground dug, graded and drained, a stone base, then infilled soccer turf on a shock pad, laid by a contractor, with lines.
**Add-ons**
|Add-on|5v5|7v7|9v9|Full
|Chain-link fence around the turf, $44 a foot|$21,648|$29,568|$37,488|$53,108
|Ball netting behind both goals|$7,500|$7,500|$10,000|$15,000
|Goals, one pair with nets|$1,500|$2,500|$3,500|$4,500
|Lights: poles, LED fixtures, wiring|$60,000|$100,000|$150,000|$276,000
|Seating, 1,000 seats (Division III)|Full only|Full only|Full only|$150,000
|Two team shelters|Full only|Full only|Full only|$10,000
|Scoreboard|Full only|Full only|Full only|$15,000
**Seating.** 1,000 seats is the U.S. Soccer Pro League Standards minimum for Division III. It is laid out with room left around the pitch to expand to the Division I standard of 15,000 seats.
**How the grid is priced**
|Per sq ft|Low-end|Mid-range|High-end
|Dig, grade, stone base and drainage|$5.00|$5.00|$5.00
|Turf|$2.50|$4.00|$6.00
|Shock pad|$0.75|$1.50|$3.00
|Infill|$1.00|$1.00|$1.00
|Contractor install|$2.00|$2.00|$2.00
|**Total per sq ft**|**$11.25**|**$13.50**|**$17.00**
Fence lengths: 5v5 492 ft, 7v7 672 ft, 9v9 852 ft, Full 1,207 ft.
**About the prices.** Typical costs from published figures, not quotes, with no contingency. Turf, pad and install as in the mini pitch proposal ([Texas Tuff](https://texas-tuff.com/blog/artificial-turf-football-field-cost/)). Ground works at $5.00 a sq ft: published guides put grading, drainage and base at 35–50% of a turf field. Fence $44 a foot ([Ergeon](https://www.ergeon.com/blog/post/chain-link-fence-costs)). Full-pitch lights are the middle of the published $208,616–$343,976 for a soccer field in the Northeast ([Sports Venue Calculator](https://sportsvenuecalculator.com/knowledge/led-sports-lighting/led-soccer-field-lighting-cost-guide/)); lights for the smaller pitches are scaled down from that and are estimates, as are netting, goals, seating, shelters and the scoreboard.$b$
FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'field-turf-pitches' AND s.sort_order = 4;

UPDATE proposal_sections s SET body = $b$- **Size:** 5v5, 7v7, 9v9 or Full?
- **Turf grade:** low-end, mid-range or high-end?
- **Add-ons:** which of fence, netting, goals, lights, and seating for the Full pitch?
- **Where on the field** it goes.$b$
FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'field-turf-pitches' AND s.sort_order = 6;

DO $$
DECLARE n int;
BEGIN
  SELECT count(*) INTO n FROM proposal_sections s JOIN proposals p ON p.id = s.proposal_id
   WHERE p.code IN ('erie-avenue-turf', 'field-turf-pitches') AND s.body ~* 'package';
  IF n <> 0 THEN RAISE EXCEPTION 'turf proposals: % sections still say package', n; END IF;
END $$;

COMMIT;
