-- 🏟 Erie Avenue turf proposal: savings figured for the space we have (James
-- 11/23 "for the space we have"). What is already there is the whole slab,
-- 31.04 × 17.63 m = 5,890 sq ft, and its lights, whichever package is
-- picked. So one saving for every package: $10,000 + 5,890 × $6 + $60,000 =
-- $105,340 (mig 1681 had sized the slab down to 5,180 sq ft for packages 1–2).
BEGIN;
UPDATE proposal_sections s SET body = $b$The court already has a flat concrete slab, 31.04 × 17.63 m (5,890 sq ft), and lights. A pitch built on open ground would need the foundation dug, the ground levelled, that slab poured and lights put up first. Every package saves that: **$105,340**.
|Package|Cost|Same pitch built from scratch|Saved
|1 Barebones|$28,490|$133,830|$105,340
|2 Installed|$38,850|$144,190|$105,340
|3 Full court|$44,175|$149,515|$105,340
|4 Enclosed|$65,711|$171,051|$105,340
|5 Deluxe|$89,601|$194,941|$105,340

|What building from scratch adds, for our space|Typical cost|Cost
|Dig the foundation, grade and level the ground|lump sum (typically $5,000–$15,000)|$10,000
|Lay a reinforced 4-inch concrete slab|5,890 sq ft × $6 (typically $4–$7.50, [LatestCost](https://latestcost.com/concrete-tennis-court-cost-installation-prices/))|$35,340
|Put up lights: poles, LED fixtures, wiring|lump sum (typically $17,700–$155,240 for a court, [Sports Venue Calculator](https://sportsvenuecalculator.com/knowledge/led-sports-lighting/basketball-court-lighting/))|$60,000
|**Saved**||**$105,340**
Typical costs from published figures, not quotes.$b$
FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'erie-avenue-turf' AND s.sort_order = 5;
UPDATE proposal_sections s SET body = replace(s.body, 'which saves about $100,000 against', 'which saves about $105,000 against')
FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'erie-avenue-turf' AND s.sort_order = 1;
COMMIT;
