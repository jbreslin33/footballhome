-- 🏟 Erie Avenue turf proposal: the real slab, two layouts, fence + netting
-- priced, storage settled (James 11/23 "its both addresses you can use parcel
-- address. add in a fence and netting. we have storage on site. the concrete
-- undernate is 17.63 by 31.04 meters. right now there are light poles inside
-- that on sides. about less then a yard in and basket ball poles about a yard
-- in … we could turf around them like cut out the turf around them or turf
-- from them in. maybe have both optons").
--
-- Slab 31.04 × 17.63 m = 5,890 sq ft. Layout A = whole slab, turf cut around
-- the poles. Layout B = inside the poles: 16.48 m between the light poles
-- (James 11/20) × about 29.2 m (31.04 less a yard at each hoop pole) = about
-- 5,180 sq ft. Lines a yard inside the poles either way: about 27.4 × 14.65 m.
-- The hoops now stay up (turf goes around or inside their poles), so "take
-- out the hoops" leaves the shared costs ($10,000–$21,000 → $8,000–$15,000)
-- and becomes add-alternate A5. Per-sq-ft prices unchanged (mig 1612/1648);
-- totals = turf + shared + 10% contingency. Fence = slab perimeter 319 ft at a
-- published $32–$71 a foot installed (Ergeon, 2026). "Turf out to the fence"
-- add-alternate dropped: the slab is the pitch.

BEGIN;

UPDATE proposals SET
  summary = 'Turf on the 76ers court at Lighthouse Sports Complex: two layouts, four turf options, $17,000–$133,000; roll-up options convert back to basketball. Lights already up.',
  as_of = '2026-11-23'
WHERE code = 'erie-avenue-turf';

UPDATE proposal_sections s SET body = $b$Lighthouse asks for **$17,000–$133,000**, depending on the layout and turf picked, to put a synthetic turf mini-pitch on the 76ers court at Lighthouse Sports Complex, 101 East Erie Avenue. The court's tiles lift off and are kept in storage on site. Under them is a flat concrete slab, **31.04 × 17.63 m (102 × 58 ft)**, so there is no excavation, paving or drainage work, and the lights are already up.
The light poles and hoop poles stand inside the slab and stay where they are, padded. There are two layouts: turf the whole slab and cut it around the poles, or turf only inside the poles. Either way the lines sit a yard inside the poles. With roll-up turf the court works both ways: roll up the turf and lay the tiles back for basketball. It gives year-round small-sided soccer to the youth teams (U8–U12), free open play for neighbourhood kids, and futsal-style training for the men's and women's teams, who all now share grass that closes in wet weather and winter.$b$
FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'erie-avenue-turf' AND s.sort_order = 1;

UPDATE proposal_sections s SET body = $b$The concrete slab under the court tiles is **31.04 × 17.63 m (102 × 58 ft)**. It sits at the west end of Lighthouse Field, inside its own fence (40.0083, -75.1263).
**Poles.** The side light poles stand inside the slab, less than a yard in from each long edge, 16.48 m apart across the court. The basketball hoop poles stand about a yard in from each end. All of them stay and get padding.
|Layout|Turf (m)|Turf (ft)|Turf area|How
|A Whole slab, cut around the poles|31.04 × 17.63|102 × 58|5,890 sq ft|Turf edge to edge, with a cut-out at each pole
|B Inside the poles|about 29.2 × 16.48|96 × 54|about 5,180 sq ft|Turf starts at the poles; no cut-outs

|Either layout|Size (m)|Size (ft)|Area
|Playing lines, a yard (0.91 m) inside the poles|about 27.4 × 14.65|90 × 48|about 4,320 sq ft
|Painted basketball lines today|28.6 × 15.2|94 × 50|4,700 sq ft
The playing area is the same in both. Layout A adds about 710 sq ft of turf, all of it run-off outside the lines. Layout B costs less, and with no cut-outs to line up it rolls up and re-lays faster. Layout B's length is approximate until the hoop poles are measured.
**Surface.** The court is tiles laid on flat concrete. The tiles lift off and are kept in storage on site, not thrown away, so basketball can come back.
**Lights.** The court already has lights; nothing here pays for lighting.
**Land.** The court is on The Light House's own parcel, 101 E Erie Ave (OPA 777705000), owned since 1943 and tax-exempt, about 14.8 acres. It is not City parkland.
**76ers.** The Sixers Youth Foundation lists the court as renovated in 2019 with The Lighthouse as partner. No terms are published.$b$
FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'erie-avenue-turf' AND s.sort_order = 2;

UPDATE proposal_sections s SET body = $b$Lift the tiles, lay turf on the flat concrete, pad the poles. Pick a layout (see The site) and one of four turfs (see Budget); the first three turfs roll up, so the court can go back to basketball.
- **Tiles up and stored.** Lift the court tiles and keep them in storage on site.
- **Clean the slab.** Sweep and wash the concrete; check that water drains off.
- **Turf.** Layout A: the whole slab, 31.04 × 17.63 m, cut around each pole. Layout B: inside the poles, about 29.2 × 16.48 m.
- **Pole padding.** Padding around each light pole and hoop pole.
- **Lines and goals.** Lines a yard inside the poles (about 27.4 × 14.65 m); two portable 4 × 2 m (12 × 6 ft) goals that move off for basketball.
**Back to basketball** (roll-up options only): roll up the turf and lay the tiles back. The hoops never left. Reverse it for soccer; the rolled turf goes in storage on site.
Add-alternates, priced separately so a funder can pick one up:
- **A1 Fence.** Chain-link fence around the slab, about 97 m (319 ft).
- **A2 Ball netting.** Taller netting behind the goals.
- **A3 Kickboards.** Low boards along the long sides.
- **A4 Benches.**
- **A5 Hoops out for soccer.** Take the two hoops out so the ends are clear; they go back up for basketball.$b$
FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'erie-avenue-turf' AND s.sort_order = 3;

UPDATE proposal_sections s SET body = $b$Four turf options, cheapest first, on either layout: A is 5,890 sq ft (whole slab), B about 5,180 sq ft (inside the poles). The turf is the only line that changes. Prices are published per-square-foot figures, not quotes; bids replace them before any application.
|Turf option|Rolls up?|What it is|Per sq ft|Turf, layout A|Turf, layout B
|1 Used foam-backed turf|Yes|Used turf with a foam back and velcro seams; volunteers lay it|$1.50 + freight ([Arena Warehouse](https://www.arenawarehouse.com/post/foam-backed-turf))|$8,840|$7,770
|2 New padded roll-out turf, outdoor-rated|Yes|New 5 mm foam-backed sports turf sold for indoor or outdoor use, UV-stabilised; volunteers lay it|$4.20–$4.81 (Practice Sports [Triple Play](https://practicesports.com/product/triple-play-48-oz-artificial-turf/), [SportScape IV](https://practicesports.com/product/sportscape-iv-sports-field-turf/))|$24,740–$28,330|$21,760–$24,920
|3 Non-infill turf + shock pad, installed|Yes, heavy|Contractor lays non-infill soccer turf over a loose shock pad|$7.50–$15 ($6–$12 turf + $1.50–$3 pad, [Mighty Grass](https://www.mightygrass.com/indoor-soccer-turf-cost-guide/))|$44,180–$88,350|$38,850–$77,700
|4 Infilled turf + athletic shock pad, installed|No|The best: infilled soccer turf on a 10–15 mm shock pad, organic infill; stays down for good|$8.50–$18 ($7–$15 turf + $1.50–$3 pad, [Mighty Grass](https://www.mightygrass.com/indoor-soccer-turf-cost-guide/))|$50,070–$106,020|$44,030–$93,240
Option 2 is priced on turf its seller lists for indoor or outdoor use. The cheaper indoor rolls ($3.09–$3.99 a sq ft, [ATX Turf](https://atxturf.com/product/5mm-padded-nylon-turf/), [Turf Factory Direct](https://turffactorydirect.com/product/tfd-sportmax-5mm/)) have no drainage holes, so they are out. The sellers of options 1 and 2 don't say whether the backing drains: ask before buying, because foam-backed turf with no holes holds water on a slab.

|Every option also needs|Basis|Low|High
|Lift and store the tiles|volunteers (in-kind match)|$0|$0
|Light pole and hoop pole padding|lump sum, estimate|$1,000|$3,000
|Two portable goals + nets|pair|$3,000|$6,000
|Design, permit, mobilisation|lump sum|$4,000|$6,000
|**Shared total**||**$8,000**|**$15,000**

|Total with 10% contingency|Layout A, whole slab|Layout B, inside the poles
|1 Used foam-backed|~$18,500–$26,200|~$17,300–$25,000
|2 New padded roll-out, outdoor-rated|~$36,000–$47,700|~$32,700–$43,900
|3 Non-infill + shock pad|~$57,400–$113,700|~$51,500–$102,000
|4 Infilled + shock pad (best)|~$63,900–$133,100|~$57,200–$119,100
Add-alternates: A1 fence around the slab $10,200–$22,700 (319 ft at $32–$71 a foot installed, [Ergeon](https://www.ergeon.com/blog/post/chain-link-fence-costs)), A2 ball netting $5,000–$10,000, A3 kickboards $8,000–$15,000, A4 benches (price when bid), A5 hoops out for soccer $2,000–$6,000 (estimate).
Turf lasts about 8–10 years, so the plan sets aside about $5,000 a year for replacement.$b$
FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'erie-avenue-turf' AND s.sort_order = 4;

UPDATE proposal_sections s SET body = replace(replace(s.body,
  '($56,500–$132,200)', '($51,500–$133,100)'), '($20,100–$52,300)', '($17,300–$47,700)')
FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'erie-avenue-turf' AND s.sort_order = 6;

UPDATE proposal_sections s SET body = replace(s.body, 'pick a turf option;', 'pick a layout and a turf option;')
FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'erie-avenue-turf' AND s.sort_order = 9;

UPDATE proposal_sections s SET body = $b$- Which layout: the whole slab cut around the poles, or inside the poles?
- Which turf option: roll-up (court goes back to basketball) or permanent?
- Do the hoops stay up during soccer, or come out (A5)?
- Do the option 1 and 2 turfs drain? Ask Arena Warehouse and Practice Sports.
- Who applies: The Light House (owns the land) or the club (needs a 25-year lease).
- Does the 2019 Sixers court deal allow covering it?
- Is turf over a court, and roll-up turf, eligible for DCNR? (Turf itself is: Chew Playground, 2026.)$b$
FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'erie-avenue-turf' AND s.sort_order = 10;

DO $$
DECLARE n int;
BEGIN
  SELECT count(*) INTO n FROM proposal_sections s JOIN proposals p ON p.id = s.proposal_id
   WHERE p.code = 'erie-avenue-turf' AND (
        (s.sort_order = 6 AND s.body LIKE '%($51,500–$133,100)%' AND s.body LIKE '%($17,300–$47,700)%')
     OR (s.sort_order = 9 AND s.body LIKE '%pick a layout and a turf option;%'));
  IF n <> 2 THEN RAISE EXCEPTION 'turf proposal: % of 2 replaced sections updated', n; END IF;
END $$;

COMMIT;
