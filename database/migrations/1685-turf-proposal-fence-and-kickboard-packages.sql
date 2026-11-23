-- 🏟 Erie Avenue turf proposal: a regular fence package and a fence-with-
-- kickboards package (James 11/23 "i think we need a regular fence option
-- and one wiht kick boards for players to practice off of right?"). Six
-- packages now: 4 Fenced (netting + regular chain-link fence, $65,711, was
-- "Enclosed"), new 5 Fenced with kickboards (+ $11,500 = $77,211), 6 Deluxe
-- ($89,601, was 5). Figures unchanged.

BEGIN;

UPDATE proposals SET
  summary = 'From James Breslin: high-quality turf on a shock pad on the 76ers court at Lighthouse Sports Complex. Six packages, Barebones $28,490 to Deluxe $89,601.'
WHERE code = 'erie-avenue-turf';

UPDATE proposal_sections s SET body = replace(s.body, 'Five packages, each building on the one before', 'Six packages, each building on the one before')
FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'erie-avenue-turf' AND s.sort_order = 1;

UPDATE proposal_sections s SET body = replace(s.body, 'a contractor in packages 2–5.', 'a contractor in packages 2–6.')
FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'erie-avenue-turf' AND s.sort_order = 3;

UPDATE proposal_sections s SET body = replace(replace(replace(replace(s.body,
  $a$|4 Enclosed|Package 3 plus ball netting and a chain-link fence|$65,711
|5 Deluxe|Permanent turf over the whole slab, netting, fence, kickboards, pole padding, goals|$89,601$a$,
  $b$|4 Fenced|Package 3 plus ball netting and a regular chain-link fence|$65,711
|5 Fenced with kickboards|Package 4 plus kickboards along the fence, for players to practise off|$77,211
|6 Deluxe|Package 5 with permanent turf, plus pole padding and goals|$89,601$b$),
  $a$**Package 4: Enclosed, $65,711**
Package 3, plus taller ball netting behind each goal and a chain-link fence around the whole slab.$a$,
  $b$**Package 4: Fenced, $65,711**
Package 3, plus taller ball netting behind each goal and a regular chain-link fence around the whole slab, so the ball stays in.$b$),
  $a$**Package 5: Deluxe, $89,601**
The best of everything: permanent infilled turf over the whole slab, netting, fence, kickboards along both long sides, padding on every light pole and hoop pole, and two portable goals. The court stays a soccer pitch.$a$,
  $b$**Package 5: Fenced with kickboards, $77,211**
Package 4, plus low kickboards at the foot of the fence along both long sides. Players pass and shoot off the boards in training, and the ball stays in play.
|Item|Quantity × unit price|Cost
|Roll-up turf|5,890 sq ft × $4.00|$23,560
|Shock pad|5,890 sq ft × $1.50|$8,835
|Contractor install|5,890 sq ft × $2.00|$11,780
|Ball netting|both ends, estimate|$7,500
|Chain-link fence, installed|319 ft × $44|$14,036
|Kickboards|both long sides, estimate|$11,500
|**Package 5 total**||**$77,211**
**Package 6: Deluxe, $89,601**
Package 5 with the best turf, permanent infilled turf, plus padding on every light pole and hoop pole and two portable goals. The court stays a soccer pitch.$b$),
  '|**Package 5 total**||**$89,601**', '|**Package 6 total**||**$89,601**')
FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'erie-avenue-turf' AND s.sort_order = 4;

UPDATE proposal_sections s SET body = replace(s.body,
  $a$|4 Enclosed|$65,711|$171,051|$105,340
|5 Deluxe|$89,601|$194,941|$105,340$a$,
  $b$|4 Fenced|$65,711|$171,051|$105,340
|5 Fenced with kickboards|$77,211|$182,551|$105,340
|6 Deluxe|$89,601|$194,941|$105,340$b$)
FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'erie-avenue-turf' AND s.sort_order = 5;

UPDATE proposal_sections s SET body = $b$- **Package:** 1 Barebones, 2 Installed, 3 Full court, 4 Fenced, 5 Fenced with kickboards or 6 Deluxe?$b$
FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'erie-avenue-turf' AND s.sort_order = 10;

DO $$
DECLARE n int;
BEGIN
  SELECT count(*) INTO n FROM proposal_sections s JOIN proposals p ON p.id = s.proposal_id
   WHERE p.code = 'erie-avenue-turf' AND (
        (s.sort_order = 1 AND s.body LIKE '%Six packages%')
     OR (s.sort_order = 3 AND s.body LIKE '%packages 2–6.%')
     OR (s.sort_order = 4 AND s.body LIKE '%|5 Fenced with kickboards|%' AND s.body LIKE '%**Package 5: Fenced with kickboards, $77,211**%'
         AND s.body LIKE '%**Package 6: Deluxe, $89,601**%' AND s.body LIKE '%|**Package 6 total**||**$89,601**%'
         AND s.body LIKE '%**Package 4: Fenced, $65,711**%' AND s.body NOT LIKE '%Enclosed%')
     OR (s.sort_order = 5 AND s.body LIKE '%|5 Fenced with kickboards|$77,211|$182,551|$105,340%'));
  IF n <> 4 THEN RAISE EXCEPTION 'turf proposal: % of 4 sections updated', n; END IF;
END $$;

COMMIT;
