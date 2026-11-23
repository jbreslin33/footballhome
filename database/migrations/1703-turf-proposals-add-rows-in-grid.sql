-- 🏟 Turf proposals: the add-ons are rows of the grid (James 11/23 "low end
-- turf, med, high as cols then under the options" + "like add fence, add net
-- etc" + "add goals etc"). Mini pitch: one grid, turf grades as columns, the
-- four turf options first, then "Add …" rows with their price; the separate
-- add-ons table is gone. Field pitches: the add-on rows are named "Add …".
-- Prices unchanged (mig 1702).

BEGIN;

UPDATE proposal_sections s SET body = replace(replace(s.body,
  $a$|Whole slab, contractor lays it|$30,922|$44,175|$64,790$a$,
  $b$|Whole slab, contractor lays it|$30,922|$44,175|$64,790
|**Add netting:** taller ball netting behind both goals|+$7,500|+$7,500|+$7,500
|**Add fence:** regular chain-link fence around the slab, 319 ft|+$14,036|+$14,036|+$14,036
|**Add kickboards:** low boards along both long sides, to practise off|+$11,500|+$11,500|+$11,500
|**Add pole padding:** every light pole and hoop pole|+$2,000|+$2,000|+$2,000
|**Add goals:** one portable pair with nets|+$4,500|+$4,500|+$4,500
|**Add basketball lines:** paint the slab, so no tiles are needed|price when bid|price when bid|price when bid
|**Add benches**|price when bid|price when bid|price when bid$b$),
  $a$**Add-ons**
|Add-on|What it is|Cost
|Ball netting|Taller netting behind both goals|$7,500
|Fence|Regular chain-link fence around the slab, 319 ft at $44 a foot|$14,036
|Kickboards|Low boards along both long sides, for players to practise off|$11,500
|Pole padding|Padding on every light pole and hoop pole|$2,000
|Goals|One portable pair with nets|$4,500
|Paint the slab for basketball|Basketball lines on the concrete, so no tiles are needed|price when bid
|Benches||price when bid
$a$, '')
FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'erie-avenue-turf' AND s.sort_order = 4;

UPDATE proposal_sections s SET body = replace(s.body,
  'Pick one box in the grid, then any add-ons.',
  'Pick one of the first four rows and a turf grade, then add any of the rows under them.')
FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'erie-avenue-turf' AND s.sort_order = 4;

UPDATE proposal_sections s SET body = replace(replace(replace(replace(replace(replace(replace(replace(s.body,
  '|Add-on|5v5|7v7|9v9|Full', '|Add|5v5|7v7|9v9|Full'),
  '|Chain-link fence around the turf, $44 a foot|', '|**Add fence:** chain-link around the turf, $44 a foot|'),
  '|Ball netting behind both goals|', '|**Add netting:** behind both goals|'),
  '|Goals, one pair with nets|', '|**Add goals:** one pair with nets|'),
  '|Lights: poles, LED fixtures, wiring|$60,000', '|**Add lights:** poles, LED fixtures, wiring|$60,000'),
  '|Seating, 1,000 seats (Division III)|', '|**Add seating:** 1,000 seats (Division III)|'),
  '|Two team shelters|', '|**Add team shelters:** two|'),
  '|Scoreboard|Full only', '|**Add scoreboard**|Full only')
FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'field-turf-pitches' AND s.sort_order = 4;

DO $$
DECLARE a text; b text;
BEGIN
  SELECT s.body INTO a FROM proposal_sections s JOIN proposals p ON p.id = s.proposal_id WHERE p.code = 'erie-avenue-turf' AND s.sort_order = 4;
  SELECT s.body INTO b FROM proposal_sections s JOIN proposals p ON p.id = s.proposal_id WHERE p.code = 'field-turf-pitches' AND s.sort_order = 4;
  IF a NOT LIKE '%|**Add goals:** one portable pair with nets|+$4,500|+$4,500|+$4,500%' OR a LIKE '%|Add-on|What it is|Cost%'
     OR a NOT LIKE '%Pick one of the first four rows%' THEN
    RAISE EXCEPTION 'mini pitch: add rows not merged into the grid';
  END IF;
  IF (length(b) - length(replace(b, '|**Add ', ''))) / length('|**Add ') <> 7 THEN
    RAISE EXCEPTION 'field pitches: add rows not renamed';
  END IF;
END $$;

COMMIT;
