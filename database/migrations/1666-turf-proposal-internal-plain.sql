-- 🏟 Erie Avenue turf proposal: a short internal proposal with clear packages
-- and costs (James 11/23 "stop editorizlizng they know how to write grants.
-- this is for internal use to the director and grant writers at lighthous" +
-- "from me" + "so this needs to be clear digestable proposal" + "with clear
-- packages and costs"). The grant advice goes: Need and beneficiaries,
-- Funding sources, Grant requirements (DCNR) and Schedule are deleted (their
-- text stays in migs 1612–1665). Budget is one packages table, each package
-- priced complete (the mig 1664 figures), with the cost basis under it.
-- Supersedes mig 1665's base-bid/alternates wording and section names.

BEGIN;

UPDATE proposals SET
  summary = 'From James Breslin: high-quality turf on a shock pad on the 76ers court at Lighthouse Sports Complex. Four packages, $57,400–$185,600.'
WHERE code = 'erie-avenue-turf';

DELETE FROM proposal_sections s USING proposals p
 WHERE p.id = s.proposal_id AND p.code = 'erie-avenue-turf' AND s.sort_order IN (5, 6, 7, 9);

UPDATE proposal_sections s SET heading = 'Summary', body = $b$From James Breslin, for the director and grant writers at Lighthouse.
Put high-quality synthetic turf on a shock pad on the 76ers court at Lighthouse Sports Complex, 101 East Erie Avenue. It allows the grass field to rest and extends training into late fall, winter and early spring.
Four packages, from **$57,400–$133,100** (turf only) to **$82,900–$185,600** (turf, netting, fence and kickboards). Prices are estimates from published figures, not quotes.
The court's tiles lift off and are kept in storage on site. Under them is a flat concrete slab. The lights are already up.$b$
FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'erie-avenue-turf' AND s.sort_order = 1;

UPDATE proposal_sections s SET heading = 'The site', body = $b$The concrete slab under the court tiles is **31.04 × 17.63 m (102 × 58 ft)**, at the west end of Lighthouse Field, inside its own fence.
**Poles.** The side light poles stand inside the slab, less than a yard in from each long edge, 16.48 m apart across the court. The basketball hoop poles stand about a yard in from each end. All of them stay and get padding.
|Layout|Turf (m)|Turf (ft)|Turf area
|A Whole slab, turf cut around the poles|31.04 × 17.63|102 × 58|5,890 sq ft
|B Inside the poles, no cut-outs|about 29.2 × 16.48|96 × 54|about 5,180 sq ft
Either way the lines sit a yard inside the poles: about 27.4 × 14.65 m (90 × 48 ft).
**Tiles.** They lift off, are stored on site, and can go back down for basketball.
**Lights.** Already there.
**Land.** The Light House's own parcel, 101 E Erie Ave (OPA 777705000).$b$
FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'erie-avenue-turf' AND s.sort_order = 2;

UPDATE proposal_sections s SET heading = 'Scope of work', body = $b$- Lift the court tiles and store them on site.
- Clean the slab.
- Lay soccer turf on a shock pad (contractor).
- Pad each light pole and hoop pole.
- Mark lines a yard inside the poles; two portable 4 × 2 m goals.
The hoops stay up. With the roll-up turf the court goes back to basketball: roll up the turf and lay the tiles back.$b$
FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'erie-avenue-turf' AND s.sort_order = 3;

UPDATE proposal_sections s SET heading = 'Packages and costs', body = $b$|Package|What you get|With roll-up turf|With permanent turf
|1 Barebones|Turf on a shock pad, pole padding, lines, two portable goals|$57,400–$113,700|$63,900–$133,100
|2 Barebones + netting|Package 1 plus ball netting behind the goals|$62,900–$124,700|$69,400–$144,100
|3 Barebones + netting + fence|Package 2 plus a chain-link fence around the slab|$74,100–$149,700|$80,600–$169,100
|4 Everything|Package 3 plus kickboards along the long sides|$82,900–$166,200|$89,400–$185,600
Prices cover the whole slab (layout A) and include a 10% contingency. Layout B is about $6,000–$14,000 less.
**Roll-up turf:** non-infill soccer turf over a loose shock pad. It rolls up, so the court can go back to basketball.
**Permanent turf:** infilled soccer turf on a 10–15 mm shock pad. The best surface; it stays down.
**Where the numbers come from**
|Turf|Per sq ft|Whole slab (5,890 sq ft)|Inside the poles (about 5,180 sq ft)
|Roll-up|$7.50–$15 ($6–$12 turf + $1.50–$3 pad, [Mighty Grass](https://www.mightygrass.com/indoor-soccer-turf-cost-guide/))|$44,180–$88,350|$38,850–$77,700
|Permanent|$8.50–$18 ($7–$15 turf + $1.50–$3 pad, [Mighty Grass](https://www.mightygrass.com/indoor-soccer-turf-cost-guide/))|$50,070–$106,020|$44,030–$93,240

|In every package|Basis|Low|High
|Lift and store the tiles|volunteers|$0|$0
|Light pole and hoop pole padding|estimate|$1,000|$3,000
|Two portable goals + nets|pair|$3,000|$6,000
|Design, permit, mobilisation|lump sum|$4,000|$6,000

|Added by packages 2–4|Basis|Low|High
|Ball netting|estimate|$5,000|$10,000
|Fence around the slab|319 ft at $32–$71 a foot installed ([Ergeon](https://www.ergeon.com/blog/post/chain-link-fence-costs))|$10,200|$22,700
|Kickboards|estimate|$8,000|$15,000
Not included: benches, and taking the hoops out for soccer ($2,000–$6,000, estimate).$b$
FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'erie-avenue-turf' AND s.sort_order = 4;

UPDATE proposal_sections s SET heading = 'Upkeep', body = $b$About **$7,000 a year**, including a replacement fund (turf lasts 8–10 years).
|Task|How often|Who|Yearly cost
|Blow off leaves, check edges and goal anchors|Weekly|Volunteers|$0
|Brush and top up infill|Monthly in season|Volunteers, hired brush|$500
|Deep clean and seam check|Yearly|Turf contractor|$1,500
|Turf replacement fund|Yearly|Club budget|$5,000$b$
FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'erie-avenue-turf' AND s.sort_order = 8;

UPDATE proposal_sections s SET heading = 'Decisions', body = $b$- **Package:** 1, 2, 3 or 4?
- **Turf:** roll-up or permanent?
- **Layout:** whole slab (A) or inside the poles (B)?$b$
FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'erie-avenue-turf' AND s.sort_order = 10;

DO $$
DECLARE n int;
BEGIN
  SELECT count(*) INTO n FROM proposal_sections s JOIN proposals p ON p.id = s.proposal_id WHERE p.code = 'erie-avenue-turf';
  IF n <> 6 THEN RAISE EXCEPTION 'turf proposal: % sections, expected 6', n; END IF;
END $$;

COMMIT;
