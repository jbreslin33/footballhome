-- 🏟 Erie Avenue turf proposal: what each package saves because the slab and
-- the lights are already there (James 11/23 "also show the amount of savings
-- on each proposal and what it would would have costs if we needed to level
-- and cement the ground and put up lights etc"). New section 5, "Savings",
-- between Packages and costs and Upkeep.
-- From-scratch extras, middle of published ranges: clear/grade/level
-- $10,000 ($5,000–$15,000); reinforced 4-inch concrete slab $6 a sq ft
-- ($4–$7.50) = $31,080 on 5,180 sq ft (packages 1–2) or $35,340 on 5,890
-- sq ft (packages 3–5); court lighting $60,000 ($17,700–$155,240).
-- Saved: $101,080 (packages 1–2), $105,340 (packages 3–5).

BEGIN;

INSERT INTO proposal_sections (proposal_id, sort_order, heading, body)
SELECT p.id, 5, 'Savings', $b$The court already has a flat concrete slab and lights. A pitch built on open ground would need the ground levelled, a slab poured and lights put up first. Every package saves that: about **$100,000**.
|Package|Cost|Same pitch built from scratch|Saved
|1 Barebones|$28,490|$129,570|$101,080
|2 Installed|$38,850|$139,930|$101,080
|3 Full court|$44,175|$149,515|$105,340
|4 Enclosed|$65,711|$171,051|$105,340
|5 Deluxe|$89,601|$194,941|$105,340

|What building from scratch adds|Quantity × unit price|Packages 1–2 (5,180 sq ft)|Packages 3–5 (5,890 sq ft)
|Clear, grade and level the ground|lump sum (published $5,000–$15,000)|$10,000|$10,000
|Reinforced 4-inch concrete slab|area × $6 a sq ft (published $4–$7.50, [LatestCost](https://latestcost.com/concrete-tennis-court-cost-installation-prices/))|$31,080|$35,340
|Lights: poles, LED fixtures, wiring|lump sum (published $17,700–$155,240 for a basketball court, [Sports Venue Calculator](https://sportsvenuecalculator.com/knowledge/led-sports-lighting/basketball-court-lighting/))|$60,000|$60,000
|**Saved**||**$101,080**|**$105,340**
These are estimates from published figures, not quotes. The lighting figure is the least certain.$b$
FROM proposals p WHERE p.code = 'erie-avenue-turf'
  AND NOT EXISTS (SELECT 1 FROM proposal_sections s WHERE s.proposal_id = p.id AND s.sort_order = 5);

UPDATE proposal_sections s SET body = replace(s.body,
  'The court''s tiles lift off and are kept in storage on site. Under them is a flat concrete slab. The lights are already up.',
  'The court''s tiles lift off and are kept in storage on site. Under them is a flat concrete slab, and the lights are already up, which saves about $100,000 against building the same pitch from scratch.')
FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'erie-avenue-turf' AND s.sort_order = 1;

DO $$
DECLARE n int;
BEGIN
  SELECT count(*) INTO n FROM proposal_sections s JOIN proposals p ON p.id = s.proposal_id
   WHERE p.code = 'erie-avenue-turf' AND (
        (s.sort_order = 5 AND s.heading = 'Savings')
     OR (s.sort_order = 1 AND s.body LIKE '%saves about $100,000%'));
  IF n <> 2 THEN RAISE EXCEPTION 'turf proposal: savings not added (% of 2)', n; END IF;
END $$;

COMMIT;
