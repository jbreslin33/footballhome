-- 🏟 Erie Avenue turf proposal: every item's cost laid out (James 11/23 "also
-- lay out the exact cost of each item in the proposals"). Packages and costs
-- = the packages table (now exact sums, not rounded) + one item table:
-- quantity × unit price = cost, and which packages include it. Same unit
-- prices as mig 1676, with turf + pad split out: turf $4.00, shock pad
-- $1.50, infill $1.00 (permanent turf only), contractor install $2.00 a
-- sq ft on 5,890 sq ft; netting $7,500; fence 319 ft × $44 = $14,036;
-- kickboards $11,500.
--   roll-up   32,395 / 44,175 / 51,675 / 65,711 / 77,211
--   permanent 38,285 / 50,065 / 57,565 / 71,601 / 83,101

BEGIN;

UPDATE proposal_sections s SET body = $b$|Package|What you get|With roll-up turf|With permanent turf
|1 Barebones|Turf and shock pad delivered; we lay it ourselves|$32,395|$38,285
|2 Installed|Turf and shock pad laid by a contractor|$44,175|$50,065
|3 Installed + netting|Package 2 plus ball netting behind the goals|$51,675|$57,565
|4 Installed + netting + fence|Package 3 plus a chain-link fence around the slab|$65,711|$71,601
|5 Everything|Package 4 plus kickboards along the long sides|$77,211|$83,101
**Roll-up turf:** non-infill soccer turf over a loose shock pad. It rolls up, so the court can go back to basketball.
**Permanent turf:** infilled soccer turf on a 10–15 mm shock pad. The best surface; it stays down.
**Cost of each item**
|Item|Quantity|Unit price|Cost|In packages
|Turf|5,890 sq ft|$4.00 a sq ft|$23,560|1–5
|Shock pad|5,890 sq ft|$1.50 a sq ft|$8,835|1–5
|Infill (permanent turf only)|5,890 sq ft|$1.00 a sq ft|$5,890|1–5
|Contractor install|5,890 sq ft|$2.00 a sq ft|$11,780|2–5
|Ball netting behind the goals|both ends|estimate|$7,500|3–5
|Chain-link fence around the slab|319 ft|$44 a foot, installed|$14,036|4–5
|Kickboards along the long sides|both sides|estimate|$11,500|5
Quantities are for the whole slab (layout A). Layout B is 5,180 sq ft: $3,905 less for package 1 with roll-up turf, up to $6,035 less for an installed package with permanent turf.
Unit prices are from published figures, not quotes, with no contingency and no freight: [Texas Tuff](https://texas-tuff.com/blog/artificial-turf-football-field-cost/) (turf $2.50–$4, pad $0.75–$1.50, labour $0.65–$1.40 a sq ft), [Mighty Grass](https://www.mightygrass.com/indoor-soccer-turf-cost-guide/) ($7.50–$15 and $8.50–$18 a sq ft installed), [Ergeon](https://www.ergeon.com/blog/post/chain-link-fence-costs) (fence $32–$71 a foot). Infill, netting and kickboards are estimates.
Not included: padding on the light and hoop poles ($1,000–$3,000, estimate), goals ($3,000–$6,000 for a portable pair), benches, and taking the hoops out for soccer ($2,000–$6,000, estimate).$b$
FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'erie-avenue-turf' AND s.sort_order = 4;

COMMIT;
