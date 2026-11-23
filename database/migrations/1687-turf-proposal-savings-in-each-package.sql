-- 🏟 Erie Avenue turf proposal: the savings sit in each package (James 11/23
-- "why not put savings in each proposal?"). The overview table gains
-- "Built from scratch" and "Saved" columns, every package block ends with
-- its from-scratch cost and saving, and the from-scratch cost table moves to
-- the end of Packages and costs. The separate Savings section (mig 1681) is
-- deleted. Figures unchanged (mig 1683/1685).

BEGIN;

UPDATE proposal_sections s SET body =
  replace(replace(replace(replace(replace(replace(
  replace(replace(replace(replace(replace(replace(replace(replace(s.body,
  '|Package|What you get|Cost', '|Package|What you get|Cost|Built from scratch|Saved'),
  'we lay it ourselves|$28,490', 'we lay it ourselves|$28,490|$133,830|$105,340'),
  'Package 1, laid by a contractor|$38,850', 'Package 1, laid by a contractor|$38,850|$144,190|$105,340'),
  'laid by a contractor|$44,175', 'laid by a contractor|$44,175|$149,515|$105,340'),
  'regular chain-link fence|$65,711', 'regular chain-link fence|$65,711|$171,051|$105,340'),
  'to practise off|$77,211', 'to practise off|$77,211|$182,551|$105,340'),
  'pole padding and goals|$89,601', 'pole padding and goals|$89,601|$194,941|$105,340'),
  '**Inside the poles** is about', E'Built from scratch = the same pitch on open ground, with the foundation dug, a slab poured and lights put up. We already have the slab and the lights.\n**Inside the poles** is about'),
  '|**Package 1 total**||**$28,490**', E'|**Package 1 total**||**$28,490**\nBuilt from scratch: $133,830. Saved: **$105,340**.'),
  '|**Package 2 total**||**$38,850**', E'|**Package 2 total**||**$38,850**\nBuilt from scratch: $144,190. Saved: **$105,340**.'),
  '|**Package 3 total**||**$44,175**', E'|**Package 3 total**||**$44,175**\nBuilt from scratch: $149,515. Saved: **$105,340**.'),
  '|**Package 4 total**||**$65,711**', E'|**Package 4 total**||**$65,711**\nBuilt from scratch: $171,051. Saved: **$105,340**.'),
  '|**Package 5 total**||**$77,211**', E'|**Package 5 total**||**$77,211**\nBuilt from scratch: $182,551. Saved: **$105,340**.'),
  '|**Package 6 total**||**$89,601**', E'|**Package 6 total**||**$89,601**\nBuilt from scratch: $194,941. Saved: **$105,340**.')
FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'erie-avenue-turf' AND s.sort_order = 4;

UPDATE proposal_sections s SET body = replace(s.body,
  '**About the prices.**',
  $b$**What building from scratch adds, for our space**
|Work|Typical cost|Cost
|Dig the foundation, grade and level the ground|lump sum (typically $5,000–$15,000)|$10,000
|Lay a reinforced 4-inch concrete slab|5,890 sq ft × $6 (typically $4–$7.50, [LatestCost](https://latestcost.com/concrete-tennis-court-cost-installation-prices/))|$35,340
|Put up lights: poles, LED fixtures, wiring|lump sum (typically $17,700–$155,240 for a court, [Sports Venue Calculator](https://sportsvenuecalculator.com/knowledge/led-sports-lighting/basketball-court-lighting/))|$60,000
|**Saved on every package**||**$105,340**
**About the prices.**$b$)
FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'erie-avenue-turf' AND s.sort_order = 4;

DELETE FROM proposal_sections s USING proposals p
 WHERE p.id = s.proposal_id AND p.code = 'erie-avenue-turf' AND s.sort_order = 5 AND s.heading = 'Savings';

DO $$
DECLARE b text; n int;
BEGIN
  SELECT s.body INTO b FROM proposal_sections s JOIN proposals p ON p.id = s.proposal_id
   WHERE p.code = 'erie-avenue-turf' AND s.sort_order = 4;
  n := (length(b) - length(replace(b, 'Saved: **$105,340**.', ''))) / length('Saved: **$105,340**.');
  IF n <> 6 THEN RAISE EXCEPTION 'turf proposal: % of 6 package blocks carry the saving', n; END IF;
  n := (length(b) - length(replace(b, '|$105,340', ''))) / length('|$105,340');
  IF n <> 6 THEN RAISE EXCEPTION 'turf proposal: % of 6 overview rows carry the saving', n; END IF;
  IF b NOT LIKE '%**Saved on every package**||**$105,340**%' OR b NOT LIKE '%|Cost|Built from scratch|Saved%' THEN
    RAISE EXCEPTION 'turf proposal: from-scratch table or header missing';
  END IF;
  IF EXISTS (SELECT 1 FROM proposal_sections s JOIN proposals p ON p.id = s.proposal_id
              WHERE p.code = 'erie-avenue-turf' AND s.heading = 'Savings') THEN
    RAISE EXCEPTION 'turf proposal: Savings section still there';
  END IF;
END $$;

COMMIT;
