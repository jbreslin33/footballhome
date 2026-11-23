-- 🏟 Erie Avenue turf proposal: each package spelled out with its own cost
-- table (James 11/23 "show more detaisl on each proposal and the cost").
-- Packages and costs = the overview table, then one block per package: what
-- it is, who does the work, every item with quantity × unit price, and the
-- total for roll-up and permanent turf. Same figures as mig 1677.

BEGIN;

UPDATE proposal_sections s SET body = $b$|Package|What you get|With roll-up turf|With permanent turf
|1 Barebones|Turf and shock pad delivered; we lay it ourselves|$32,395|$38,285
|2 Installed|Turf and shock pad laid by a contractor|$44,175|$50,065
|3 Installed + netting|Package 2 plus ball netting behind the goals|$51,675|$57,565
|4 Installed + netting + fence|Package 3 plus a chain-link fence around the slab|$65,711|$71,601
|5 Everything|Package 4 plus kickboards along the long sides|$77,211|$83,101
**Roll-up turf:** non-infill soccer turf over a loose shock pad. It rolls up, so the court can go back to basketball.
**Permanent turf:** infilled soccer turf on a 10–15 mm shock pad. The best surface; it stays down.
All quantities are for the whole slab, 31.04 × 17.63 m = 5,890 sq ft (layout A).
**Package 1: Barebones**
The turf and shock pad are bought and delivered. We do all the work ourselves: lift and store the tiles, clean the slab, lay the pad, roll out and seam the turf, cut it around the poles, mark the lines. Freight is not in the price.
|Item|Quantity × unit price|Roll-up turf|Permanent turf
|Turf|5,890 sq ft × $4.00|$23,560|$23,560
|Shock pad|5,890 sq ft × $1.50|$8,835|$8,835
|Infill|5,890 sq ft × $1.00|not needed|$5,890
|**Package 1 total**||**$32,395**|**$38,285**
**Package 2: Installed**
The same turf and shock pad, laid by a turf contractor: pad down, turf seamed, cut around the poles, infill spread (permanent turf), lines marked. We still lift and store the tiles and clean the slab.
|Item|Quantity × unit price|Roll-up turf|Permanent turf
|Turf|5,890 sq ft × $4.00|$23,560|$23,560
|Shock pad|5,890 sq ft × $1.50|$8,835|$8,835
|Infill|5,890 sq ft × $1.00|not needed|$5,890
|Contractor install|5,890 sq ft × $2.00|$11,780|$11,780
|**Package 2 total**||**$44,175**|**$50,065**
**Package 3: Installed + netting**
Package 2, plus taller ball netting behind each goal to keep balls on the court.
|Item|Quantity × unit price|Roll-up turf|Permanent turf
|Turf|5,890 sq ft × $4.00|$23,560|$23,560
|Shock pad|5,890 sq ft × $1.50|$8,835|$8,835
|Infill|5,890 sq ft × $1.00|not needed|$5,890
|Contractor install|5,890 sq ft × $2.00|$11,780|$11,780
|Ball netting|both ends, estimate|$7,500|$7,500
|**Package 3 total**||**$51,675**|**$57,565**
**Package 4: Installed + netting + fence**
Package 3, plus a chain-link fence around the whole slab.
|Item|Quantity × unit price|Roll-up turf|Permanent turf
|Turf|5,890 sq ft × $4.00|$23,560|$23,560
|Shock pad|5,890 sq ft × $1.50|$8,835|$8,835
|Infill|5,890 sq ft × $1.00|not needed|$5,890
|Contractor install|5,890 sq ft × $2.00|$11,780|$11,780
|Ball netting|both ends, estimate|$7,500|$7,500
|Chain-link fence, installed|319 ft × $44|$14,036|$14,036
|**Package 4 total**||**$65,711**|**$71,601**
**Package 5: Everything**
Package 4, plus low kickboards along both long sides, so the ball stays in play off the boards.
|Item|Quantity × unit price|Roll-up turf|Permanent turf
|Turf|5,890 sq ft × $4.00|$23,560|$23,560
|Shock pad|5,890 sq ft × $1.50|$8,835|$8,835
|Infill|5,890 sq ft × $1.00|not needed|$5,890
|Contractor install|5,890 sq ft × $2.00|$11,780|$11,780
|Ball netting|both ends, estimate|$7,500|$7,500
|Chain-link fence, installed|319 ft × $44|$14,036|$14,036
|Kickboards|both long sides, estimate|$11,500|$11,500
|**Package 5 total**||**$77,211**|**$83,101**
**Layout B instead.** Turf only inside the poles is 5,180 sq ft, 710 sq ft less. That takes $3,905 off package 1 with roll-up turf ($4,615 with permanent) and $5,325 off packages 2–5 ($6,035 with permanent).
**About the prices.** Unit prices are from published figures, not quotes, with no contingency and no freight: [Texas Tuff](https://texas-tuff.com/blog/artificial-turf-football-field-cost/) (turf $2.50–$4, pad $0.75–$1.50, labour $0.65–$1.40 a sq ft), [Mighty Grass](https://www.mightygrass.com/indoor-soccer-turf-cost-guide/) ($7.50–$15 and $8.50–$18 a sq ft installed), [Ergeon](https://www.ergeon.com/blog/post/chain-link-fence-costs) (fence $32–$71 a foot). Infill, netting and kickboards are estimates.
**Not in any package:** padding on the light and hoop poles ($1,000–$3,000, estimate), goals ($3,000–$6,000 for a portable pair), benches, and taking the hoops out for soccer ($2,000–$6,000, estimate).$b$
FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'erie-avenue-turf' AND s.sort_order = 4;

COMMIT;
