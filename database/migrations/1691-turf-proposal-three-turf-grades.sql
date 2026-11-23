-- 🏟 Erie Avenue turf proposal: roll-up turf only, in three grades (James
-- 11/23 "ok since we are using roll up turf lets give a low end turf with
-- shock, medieum and high end. this will mean 3x the proposals"). Permanent
-- turf is gone; Deluxe is package 5 plus pole padding and goals. Every
-- package is priced three ways, turf + shock pad per sq ft:
--   low-end $2.50 + $0.75, mid-range $4.00 + $1.50 (the figures used until
--   now), high-end $6.00 + $3.00.
-- Other unit prices unchanged (install $2.00, netting $7,500, fence $14,036,
-- kickboards $11,500, padding $2,000, goals $4,500; saved $105,340).
-- Totals (low / mid / high):
--   1 Barebones: $16,835 / $28,490 / $46,620
--   2 Installed: $27,195 / $38,850 / $56,980
--   3 Full court: $30,923 / $44,175 / $64,790
--   4 Fenced: $52,459 / $65,711 / $86,326
--   5 Fenced with kickboards: $63,959 / $77,211 / $97,826
--   6 Deluxe: $70,459 / $83,711 / $104,326

BEGIN;

UPDATE proposals SET
  summary = 'From James Breslin: roll-up turf on a shock pad on the 76ers court at Lighthouse Sports Complex. Six packages in three turf grades, $16,835–$104,326.'
WHERE code = 'erie-avenue-turf';

UPDATE proposal_sections s SET body = $b$From James Breslin. To Edwin Desamour, Executive Director, Julian Makarechi, Deputy Director, and Anita Lyndaker, Grant Writer, at Lighthouse.
Put roll-up synthetic turf on a shock pad on the 76ers court at Lighthouse Sports Complex, 101 East Erie Avenue. It allows the grass field to rest and extends training into late fall, winter and early spring.
Six packages, each building on the one before, each priced with low-end, mid-range and high-end turf: from **$16,835** (Barebones, low-end turf inside the poles, laid by us) up to **$104,326** (Deluxe, high-end turf over the whole slab, laid by a contractor, with netting, fence, kickboards, pole padding and goals). Prices are estimates from published figures, not quotes.
The court's tiles lift off and are kept in storage on site. Under them is a flat concrete slab, and the lights are already up, which saves about $105,000 against building the same pitch from scratch.$b$
FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'erie-avenue-turf' AND s.sort_order = 1;

UPDATE proposal_sections s SET body = replace(s.body,
  'The hoops stay up. With the roll-up turf the court goes back to basketball: roll up the turf and lay the tiles back.',
  'The hoops stay up. The turf rolls up, so the court goes back to basketball: roll up the turf and lay the tiles back.')
FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'erie-avenue-turf' AND s.sort_order = 3;

UPDATE proposal_sections s SET body = $b$Six packages, each building on the one before, and each priced with three grades of roll-up turf on a shock pad.
|Package|What you get|Low-end turf|Mid-range turf|High-end turf
|1 Barebones|Roll-up turf and shock pad inside the poles, delivered; we lay it ourselves|$16,835|$28,490|$46,620
|2 Installed|Package 1, laid by a contractor|$27,195|$38,850|$56,980
|3 Full court|Roll-up turf over the whole slab, cut around the poles, laid by a contractor|$30,923|$44,175|$64,790
|4 Fenced|Package 3 plus ball netting and a regular chain-link fence|$52,459|$65,711|$86,326
|5 Fenced with kickboards|Package 4 plus kickboards along the fence, for players to practise off|$63,959|$77,211|$97,826
|6 Deluxe|Package 5 plus pole padding and goals|$70,459|$83,711|$104,326
All of it is roll-up turf: non-infill soccer turf over a loose shock pad. It rolls up, so the court can go back to basketball.
**Turf grades**
|Grade|Turf, per sq ft|Shock pad, per sq ft|Basis
|Low-end|$2.50|$0.75|Bottom of the published range for sports turf and pad ([Texas Tuff](https://texas-tuff.com/blog/artificial-turf-football-field-cost/))
|Mid-range|$4.00|$1.50|Top of that range
|High-end|$6.00|$3.00|Non-infill soccer turf and a thick shock pad ([Mighty Grass](https://www.mightygrass.com/indoor-soccer-turf-cost-guide/))
**Inside the poles** is about 29.2 × 16.48 m = 5,180 sq ft. **The whole slab** is 31.04 × 17.63 m = 5,890 sq ft.
Built from scratch = the same pitch on open ground, with the foundation dug, a slab poured and lights put up. We already have the slab and the lights, which saves $105,340 on every package.
**Package 1: Barebones**
The cheapest way to do it. Roll-up turf, laid only inside the poles so nothing is cut around them. The turf and shock pad are bought and delivered. We do all the work ourselves: lift and store the tiles, clean the slab, lay the pad, roll out and seam the turf, mark the lines. Freight is not in the price.
|Item|Quantity|Low-end|Mid-range|High-end
|Roll-up turf|5,180 sq ft × $2.50 / $4.00 / $6.00|$12,950|$20,720|$31,080
|Shock pad|5,180 sq ft × $0.75 / $1.50 / $3.00|$3,885|$7,770|$15,540
|**Package 1 total**||**$16,835**|**$28,490**|**$46,620**
|Built from scratch||$122,175|$133,830|$151,960
|Saved||$105,340 (86%)|$105,340 (79%)|$105,340 (69%)
**Package 2: Installed**
Package 1, but a turf contractor lays it: pad down, turf seamed, lines marked. We still lift and store the tiles and clean the slab.
|Item|Quantity|Low-end|Mid-range|High-end
|Roll-up turf|5,180 sq ft × $2.50 / $4.00 / $6.00|$12,950|$20,720|$31,080
|Shock pad|5,180 sq ft × $0.75 / $1.50 / $3.00|$3,885|$7,770|$15,540
|Contractor install|5,180 sq ft × $2.00|$10,360|$10,360|$10,360
|**Package 2 total**||**$27,195**|**$38,850**|**$56,980**
|Built from scratch||$132,535|$144,190|$162,320
|Saved||$105,340 (79%)|$105,340 (73%)|$105,340 (65%)
**Package 3: Full court**
The turf goes edge to edge over the whole slab, cut around each light pole and hoop pole. That adds 710 sq ft of run-off outside the lines. Laid by a contractor.
|Item|Quantity|Low-end|Mid-range|High-end
|Roll-up turf|5,890 sq ft × $2.50 / $4.00 / $6.00|$14,725|$23,560|$35,340
|Shock pad|5,890 sq ft × $0.75 / $1.50 / $3.00|$4,418|$8,835|$17,670
|Contractor install|5,890 sq ft × $2.00|$11,780|$11,780|$11,780
|**Package 3 total**||**$30,923**|**$44,175**|**$64,790**
|Built from scratch||$136,263|$149,515|$170,130
|Saved||$105,340 (77%)|$105,340 (70%)|$105,340 (62%)
**Package 4: Fenced**
Package 3, plus taller ball netting behind each goal and a regular chain-link fence around the whole slab, so the ball stays in.
|Item|Quantity|Low-end|Mid-range|High-end
|Roll-up turf|5,890 sq ft × $2.50 / $4.00 / $6.00|$14,725|$23,560|$35,340
|Shock pad|5,890 sq ft × $0.75 / $1.50 / $3.00|$4,418|$8,835|$17,670
|Contractor install|5,890 sq ft × $2.00|$11,780|$11,780|$11,780
|Ball netting|both ends, estimate|$7,500|$7,500|$7,500
|Chain-link fence, installed|319 ft × $44|$14,036|$14,036|$14,036
|**Package 4 total**||**$52,459**|**$65,711**|**$86,326**
|Built from scratch||$157,799|$171,051|$191,666
|Saved||$105,340 (67%)|$105,340 (62%)|$105,340 (55%)
**Package 5: Fenced with kickboards**
Package 4, plus low kickboards at the foot of the fence along both long sides. Players pass and shoot off the boards in training, and the ball stays in play.
|Item|Quantity|Low-end|Mid-range|High-end
|Roll-up turf|5,890 sq ft × $2.50 / $4.00 / $6.00|$14,725|$23,560|$35,340
|Shock pad|5,890 sq ft × $0.75 / $1.50 / $3.00|$4,418|$8,835|$17,670
|Contractor install|5,890 sq ft × $2.00|$11,780|$11,780|$11,780
|Ball netting|both ends, estimate|$7,500|$7,500|$7,500
|Chain-link fence, installed|319 ft × $44|$14,036|$14,036|$14,036
|Kickboards|both long sides, estimate|$11,500|$11,500|$11,500
|**Package 5 total**||**$63,959**|**$77,211**|**$97,826**
|Built from scratch||$169,299|$182,551|$203,166
|Saved||$105,340 (62%)|$105,340 (58%)|$105,340 (52%)
**Package 6: Deluxe**
Everything: package 5, plus padding on every light pole and hoop pole and two portable goals.
|Item|Quantity|Low-end|Mid-range|High-end
|Roll-up turf|5,890 sq ft × $2.50 / $4.00 / $6.00|$14,725|$23,560|$35,340
|Shock pad|5,890 sq ft × $0.75 / $1.50 / $3.00|$4,418|$8,835|$17,670
|Contractor install|5,890 sq ft × $2.00|$11,780|$11,780|$11,780
|Ball netting|both ends, estimate|$7,500|$7,500|$7,500
|Chain-link fence, installed|319 ft × $44|$14,036|$14,036|$14,036
|Kickboards|both long sides, estimate|$11,500|$11,500|$11,500
|Pole padding|light poles and hoop poles, estimate|$2,000|$2,000|$2,000
|Portable goals + nets|one pair, estimate|$4,500|$4,500|$4,500
|**Package 6 total**||**$70,459**|**$83,711**|**$104,326**
|Built from scratch||$175,799|$189,051|$209,666
|Saved||$105,340 (60%)|$105,340 (56%)|$105,340 (50%)
**What building from scratch adds, for our space**
|Work|Typical cost|Cost
|Dig the foundation, grade and level the ground|lump sum (typically $5,000–$15,000)|$10,000
|Lay a reinforced 4-inch concrete slab|5,890 sq ft × $6 (typically $4–$7.50, [LatestCost](https://latestcost.com/concrete-tennis-court-cost-installation-prices/))|$35,340
|Put up lights: poles, LED fixtures, wiring|lump sum (typically $17,700–$155,240 for a court, [Sports Venue Calculator](https://sportsvenuecalculator.com/knowledge/led-sports-lighting/basketball-court-lighting/))|$60,000
|**Saved on every package**||**$105,340**
**About the prices.** Unit prices are from published figures, not quotes, with no contingency and no freight. Contractor install is $2.00 a sq ft; the fence is $44 a foot ([Ergeon](https://www.ergeon.com/blog/post/chain-link-fence-costs), published range $32–$71). Netting, kickboards, pole padding and goals are estimates.
**Not in any package:** benches, and taking the hoops out for soccer ($2,000–$6,000, estimate).$b$
FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'erie-avenue-turf' AND s.sort_order = 4;

UPDATE proposal_sections s SET body = $b$- **Package:** 1 Barebones, 2 Installed, 3 Full court, 4 Fenced, 5 Fenced with kickboards or 6 Deluxe?
- **Turf grade:** low-end, mid-range or high-end?$b$
FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'erie-avenue-turf' AND s.sort_order = 10;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM proposal_sections s JOIN proposals p ON p.id = s.proposal_id
                  WHERE p.code = 'erie-avenue-turf' AND s.sort_order = 3 AND s.body LIKE '%The turf rolls up, so the court%') THEN
    RAISE EXCEPTION 'turf proposal: scope line not replaced';
  END IF;
END $$;

COMMIT;
