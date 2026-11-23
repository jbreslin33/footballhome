-- 🏟 Erie Avenue turf proposal: a ladder from the cheapest package up to a
-- Deluxe package (James 11/23 "so cheapest 1s proposal is inside the poles,
-- roll up install ourselves" + "then expand from there" + "to a delux
-- package"). One price per package, each step adding to the one before:
--   1 Barebones   roll-up, inside the poles (5,180 sq ft), laid by us   $28,490
--   2 Installed   the same, laid by a contractor (+ $2.00 a sq ft)      $38,850
--   3 Full court  roll-up over the whole slab (5,890 sq ft), contractor $44,175
--   4 Enclosed    package 3 + ball netting $7,500 + fence $14,036       $65,711
--   5 Deluxe      permanent turf (+ infill $5,890) + kickboards $11,500
--                 + pole padding $2,000 + goals $4,500                  $89,601
-- Unit prices unchanged (mig 1677). Pole padding and goals take the middle
-- of their earlier ranges ($1,000–$3,000, $3,000–$6,000).

BEGIN;

UPDATE proposals SET
  summary = 'From James Breslin: high-quality turf on a shock pad on the 76ers court at Lighthouse Sports Complex. Five packages, Barebones $28,490 to Deluxe $89,601.'
WHERE code = 'erie-avenue-turf';

UPDATE proposal_sections s SET body = replace(s.body,
  'Five packages. Barebones is roll-up turf inside the poles, delivered and laid by us: about **$28,500**. Laid by a contractor over the whole slab it is about **$44,000** with roll-up turf or **$50,000** with permanent turf. With netting, fence and kickboards it is about **$77,000** or **$83,000**.',
  'Five packages, each building on the one before: from Barebones at **$28,490** (roll-up turf inside the poles, laid by us) up to Deluxe at **$89,601** (permanent turf over the whole slab, laid by a contractor, with netting, fence, kickboards, pole padding and goals).')
FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'erie-avenue-turf' AND s.sort_order = 1;

UPDATE proposal_sections s SET body = $b$|Package|What you get|Cost
|1 Barebones|Roll-up turf and shock pad inside the poles, delivered; we lay it ourselves|$28,490
|2 Installed|Package 1, laid by a contractor|$38,850
|3 Full court|Roll-up turf over the whole slab, cut around the poles, laid by a contractor|$44,175
|4 Enclosed|Package 3 plus ball netting and a chain-link fence|$65,711
|5 Deluxe|Permanent turf over the whole slab, netting, fence, kickboards, pole padding, goals|$89,601
**Roll-up turf:** non-infill soccer turf over a loose shock pad. It rolls up, so the court can go back to basketball.
**Permanent turf:** infilled soccer turf on a 10–15 mm shock pad. The best surface; it stays down.
**Inside the poles** is about 29.2 × 16.48 m = 5,180 sq ft. **The whole slab** is 31.04 × 17.63 m = 5,890 sq ft.
**Package 1: Barebones, $28,490**
The cheapest way to do it. Roll-up turf, laid only inside the poles so nothing is cut around them. The turf and shock pad are bought and delivered. We do all the work ourselves: lift and store the tiles, clean the slab, lay the pad, roll out and seam the turf, mark the lines. Freight is not in the price.
|Item|Quantity × unit price|Cost
|Roll-up turf|5,180 sq ft × $4.00|$20,720
|Shock pad|5,180 sq ft × $1.50|$7,770
|**Package 1 total**||**$28,490**
**Package 2: Installed, $38,850**
Package 1, but a turf contractor lays it: pad down, turf seamed, lines marked. We still lift and store the tiles and clean the slab.
|Item|Quantity × unit price|Cost
|Roll-up turf|5,180 sq ft × $4.00|$20,720
|Shock pad|5,180 sq ft × $1.50|$7,770
|Contractor install|5,180 sq ft × $2.00|$10,360
|**Package 2 total**||**$38,850**
**Package 3: Full court, $44,175**
The turf goes edge to edge over the whole slab, cut around each light pole and hoop pole. That adds 710 sq ft of run-off outside the lines. Laid by a contractor.
|Item|Quantity × unit price|Cost
|Roll-up turf|5,890 sq ft × $4.00|$23,560
|Shock pad|5,890 sq ft × $1.50|$8,835
|Contractor install|5,890 sq ft × $2.00|$11,780
|**Package 3 total**||**$44,175**
**Package 4: Enclosed, $65,711**
Package 3, plus taller ball netting behind each goal and a chain-link fence around the whole slab.
|Item|Quantity × unit price|Cost
|Roll-up turf|5,890 sq ft × $4.00|$23,560
|Shock pad|5,890 sq ft × $1.50|$8,835
|Contractor install|5,890 sq ft × $2.00|$11,780
|Ball netting|both ends, estimate|$7,500
|Chain-link fence, installed|319 ft × $44|$14,036
|**Package 4 total**||**$65,711**
**Package 5: Deluxe, $89,601**
The best of everything: permanent infilled turf over the whole slab, netting, fence, kickboards along both long sides, padding on every light pole and hoop pole, and two portable goals. The court stays a soccer pitch.
|Item|Quantity × unit price|Cost
|Permanent turf|5,890 sq ft × $4.00|$23,560
|Shock pad|5,890 sq ft × $1.50|$8,835
|Infill|5,890 sq ft × $1.00|$5,890
|Contractor install|5,890 sq ft × $2.00|$11,780
|Ball netting|both ends, estimate|$7,500
|Chain-link fence, installed|319 ft × $44|$14,036
|Kickboards|both long sides, estimate|$11,500
|Pole padding|light poles and hoop poles, estimate|$2,000
|Portable goals + nets|one pair, estimate|$4,500
|**Package 5 total**||**$89,601**
Deluxe with roll-up turf instead, so the court can still go back to basketball: $83,711 (no infill).
**About the prices.** Unit prices are from published figures, not quotes, with no contingency and no freight: [Texas Tuff](https://texas-tuff.com/blog/artificial-turf-football-field-cost/) (turf $2.50–$4, pad $0.75–$1.50, labour $0.65–$1.40 a sq ft), [Mighty Grass](https://www.mightygrass.com/indoor-soccer-turf-cost-guide/) ($7.50–$15 and $8.50–$18 a sq ft installed), [Ergeon](https://www.ergeon.com/blog/post/chain-link-fence-costs) (fence $32–$71 a foot). Infill, netting, kickboards, pole padding and goals are estimates.
**Not in any package:** benches, and taking the hoops out for soccer ($2,000–$6,000, estimate).$b$
FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'erie-avenue-turf' AND s.sort_order = 4;

UPDATE proposal_sections s SET body = $b$- **Package:** 1 Barebones, 2 Installed, 3 Full court, 4 Enclosed or 5 Deluxe?$b$
FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'erie-avenue-turf' AND s.sort_order = 10;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM proposal_sections s JOIN proposals p ON p.id = s.proposal_id
                  WHERE p.code = 'erie-avenue-turf' AND s.sort_order = 1 AND s.body LIKE '%up to Deluxe at **$89,601**%') THEN
    RAISE EXCEPTION 'turf proposal: summary not replaced';
  END IF;
END $$;

COMMIT;
