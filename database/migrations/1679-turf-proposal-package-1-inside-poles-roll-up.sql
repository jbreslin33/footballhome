-- 🏟 Erie Avenue turf proposal: package 1 is the cheapest way to do it (James
-- 11/23 "so cheapest 1s proposal is inside the poles, roll up install
-- ourselves"). Package 1 = roll-up turf, inside the poles only (layout B,
-- about 5,180 sq ft), delivered, laid by us: turf 5,180 × $4.00 = $20,720 +
-- shock pad 5,180 × $1.50 = $7,770 = $28,490. Packages 2–5 are unchanged
-- (whole slab, roll-up or permanent).

BEGIN;

UPDATE proposals SET
  summary = 'From James Breslin: high-quality turf on a shock pad on the 76ers court at Lighthouse Sports Complex. Five packages, $28,490–$83,101.'
WHERE code = 'erie-avenue-turf';

UPDATE proposal_sections s SET body = replace(s.body,
  'Five packages. Barebones, turf delivered and laid by us, is about **$32,000** with roll-up turf or **$38,000** with permanent turf. Laid by a contractor it is about **$44,000** or **$50,000**.',
  'Five packages. Barebones is roll-up turf inside the poles, delivered and laid by us: about **$28,500**. Laid by a contractor over the whole slab it is about **$44,000** with roll-up turf or **$50,000** with permanent turf.')
FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'erie-avenue-turf' AND s.sort_order = 1;

UPDATE proposal_sections s SET body = replace(replace(replace(replace(s.body,
  '|1 Barebones|Turf and shock pad delivered; we lay it ourselves|$32,395|$38,285',
  '|1 Barebones|Roll-up turf and shock pad, inside the poles only, delivered; we lay it ourselves|$28,490|roll-up only'),
  'All quantities are for the whole slab, 31.04 × 17.63 m = 5,890 sq ft (layout A).',
  'Package 1 covers the area inside the poles, about 29.2 × 16.48 m = 5,180 sq ft (layout B). Packages 2–5 cover the whole slab, 31.04 × 17.63 m = 5,890 sq ft (layout A).'),
  $a$The turf and shock pad are bought and delivered. We do all the work ourselves: lift and store the tiles, clean the slab, lay the pad, roll out and seam the turf, cut it around the poles, mark the lines. Freight is not in the price.
|Item|Quantity × unit price|Roll-up turf|Permanent turf
|Turf|5,890 sq ft × $4.00|$23,560|$23,560
|Shock pad|5,890 sq ft × $1.50|$8,835|$8,835
|Infill|5,890 sq ft × $1.00|not needed|$5,890
|**Package 1 total**||**$32,395**|**$38,285**$a$,
  $b$The cheapest way to do it: roll-up turf, laid only inside the poles so nothing is cut around them. The turf and shock pad are bought and delivered. We do all the work ourselves: lift and store the tiles, clean the slab, lay the pad, roll out and seam the turf, mark the lines. Freight is not in the price.
|Item|Quantity × unit price|Cost
|Roll-up turf|5,180 sq ft × $4.00|$20,720
|Shock pad|5,180 sq ft × $1.50|$7,770
|**Package 1 total**||**$28,490**$b$),
  '**Layout B instead.** Turf only inside the poles is 5,180 sq ft, 710 sq ft less. That takes $3,905 off package 1 with roll-up turf ($4,615 with permanent) and $5,325 off packages 2–5 ($6,035 with permanent).',
  '**Packages 2–5 inside the poles instead.** That is 710 sq ft less turf: $5,325 off with roll-up turf, $6,035 off with permanent.')
FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'erie-avenue-turf' AND s.sort_order = 4;

UPDATE proposal_sections s SET body = $b$- **Package:** 1, 2, 3, 4 or 5?
- **Turf** (packages 2–5): roll-up or permanent?
- **Layout** (packages 2–5): whole slab or inside the poles?$b$
FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'erie-avenue-turf' AND s.sort_order = 10;

DO $$
DECLARE n int;
BEGIN
  SELECT count(*) INTO n FROM proposal_sections s JOIN proposals p ON p.id = s.proposal_id
   WHERE p.code = 'erie-avenue-turf' AND (
        (s.sort_order = 1 AND s.body LIKE '%about **$28,500**%')
     OR (s.sort_order = 4 AND s.body LIKE '%|$28,490|roll-up only%' AND s.body LIKE '%**Package 1 total**||**$28,490**%'
         AND s.body LIKE '%Package 1 covers the area inside the poles%' AND s.body LIKE '%**Packages 2–5 inside the poles instead.**%'
         AND s.body NOT LIKE '%$32,395%'));
  IF n <> 2 THEN RAISE EXCEPTION 'turf proposal: % of 2 replaced sections updated', n; END IF;
END $$;

COMMIT;
