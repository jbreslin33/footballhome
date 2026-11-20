-- 🏟 Erie Avenue turf proposal: four turf options cheapest → best, roll-up
-- conversion, lights already up, fence/netting = add-on (James 11/20 "we
-- already have lights. we don't need fence that wold be add on. we can remove
-- the tiles and save them. if the turf is roll up then we can have both on
-- assumbly including putting back the basketball hoops. we want multiple
-- optons for turf quality right? from cheapest to the very best" + "when
-- tiles are removed its flat concrete under it").
-- Turf area 5,510 sq ft (mig 1610). Prices = published per-sq-ft figures
-- (linked in the Budget section), not quotes. Totals = turf + shared lines
-- ($10,000–$21,000) + 10% contingency.

UPDATE proposals SET
  summary = 'Turf on the 76ers court at Lighthouse Sports Complex: four turf options, $20,000–$132,000; roll-up options convert back to basketball. Lights already up.',
  as_of = '2026-11-20'
WHERE code = 'erie-avenue-turf';

UPDATE proposal_sections s SET body = $b$Lighthouse asks for **$20,000–$132,000**, depending on the turf picked, to put a synthetic turf mini-pitch on the 76ers court at Lighthouse Sports Complex, 101 East Erie Avenue. The court's tiles lift off and are saved. Under them is flat concrete, so there is no excavation, paving or drainage work, and the lights are already up.
The turf runs **31.06 × 16.48 m (102 × 54 ft)** out to the side light poles, with the basketball hoops taken out. The poles are padded and the lines sit a yard inside them: a 31.06 × 14.65 m (102 × 48 ft) playing area. With roll-up turf the court works both ways: roll up the turf, lay the tiles back and put the hoops up for basketball. It gives year-round small-sided soccer to the youth teams (U8–U12), free open play for neighbourhood kids, and futsal-style training for the men's and women's teams, who all now share grass that closes in wet weather and winter.$b$
FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'erie-avenue-turf' AND s.sort_order = 1;

UPDATE proposal_sections s SET body = $b$The turf covers the court out to the side light poles: **31.06 × 16.48 m (102 × 54 ft)**. It sits at the west end of Lighthouse Field, inside its own fence (40.0083, -75.1263).
|Feature|Size (m)|Size (ft)|Area
|Turf, pole to pole (hoops taken out)|31.06 × 16.48|102 × 54|5,510 sq ft
|Playing lines, a yard (0.91 m) inside the poles|31.06 × 14.65|102 × 48|4,900 sq ft
|Painted basketball lines today|28.6 × 15.2|94 × 50|4,700 sq ft
**Surface.** The court is tiles laid on flat concrete. The tiles lift off and are stored, not thrown away, so basketball can come back.
**Lights.** The court already has lights; nothing here pays for lighting.
**Light poles.** The side light poles stay. Each gets padding, and the touchlines are drawn a yard in from them as a buffer.
**Land.** The court is on The Light House's own parcel, 101 E Erie Ave (OPA 777705000), owned since 1943 and tax-exempt, about 14.8 acres. It is not City parkland.
**76ers.** The Sixers Youth Foundation lists the court as renovated in 2019 with The Lighthouse as partner. No terms are published.$b$
FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'erie-avenue-turf' AND s.sort_order = 2;

UPDATE proposal_sections s SET body = $b$Lift the tiles, lay turf on the flat concrete, pad the poles. The turf is one of four options (see Budget); the first three roll up, so the court can go back to basketball.
- **Tiles up and stored.** Lift the court tiles and keep them for re-use.
- **Hoops out.** Take out the two hoops; they go back up whenever the court goes back to basketball.
- **Clean the slab.** Sweep and wash the concrete; check that water drains off.
- **Turf.** The option picked, 31.06 × 16.48 m out to the light poles.
- **Pole padding.** Padding around each side light pole.
- **Lines and goals.** Lines a yard inside the light poles (31.06 × 14.65 m); two portable 4 × 2 m (12 × 6 ft) goals that move off for basketball.
**Back to basketball** (roll-up options only): roll up the turf, lay the tiles back, put the hoops up. Reverse it for soccer.
Add-alternates, priced separately so a funder can pick one up:
- **A1 Turf out to the fence.** Stone base over the ground beyond the light poles, then turf.
- **A2 Ball netting.** Taller netting behind the goals.
- **A3 Kickboards.** Low boards along the long sides.
- **A4 Storage box and benches.** Somewhere to keep the rolled turf or the tiles.$b$
FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'erie-avenue-turf' AND s.sort_order = 3;

UPDATE proposal_sections s SET body = $b$Four turf options on 5,510 sq ft, cheapest first; the turf is the only line that changes. Prices are published per-square-foot figures, not quotes; bids replace them before any application.
|Turf option|Rolls up?|What it is|Per sq ft|Turf, 5,510 sq ft
|1 Used foam-backed turf|Yes|Used turf with a foam back and velcro seams; volunteers lay it|$1.50 + freight ([Arena Warehouse](https://www.arenawarehouse.com/post/foam-backed-turf))|$8,270
|2 New padded roll-out turf|Yes|New 5 mm foam-backed sports turf; volunteers lay it|$3.09–$4.85 ([ATX Turf](https://atxturf.com/product/5mm-padded-nylon-turf/), [Turf Factory Direct](https://turffactorydirect.com/product/tfd-sportmax-5mm/), [Practice Sports](https://practicesports.com/product-category/baseball-softball/turf/turf-by-the-foot/))|$17,030–$26,720
|3 Non-infill turf + shock pad, installed|Yes, heavy|Contractor lays non-infill soccer turf over a loose shock pad|$7.50–$15 ($6–$12 turf + $1.50–$3 pad, [Mighty Grass](https://www.mightygrass.com/indoor-soccer-turf-cost-guide/))|$41,330–$82,650
|4 Infilled turf + athletic shock pad, installed|No|The best: infilled soccer turf on a 10–15 mm shock pad, organic infill; stays down for good|$8.50–$18 ($7–$15 turf + $1.50–$3 pad, [Mighty Grass](https://www.mightygrass.com/indoor-soccer-turf-cost-guide/))|$46,840–$99,180
Options 1 and 2 are sold as indoor turf. Outdoors they need a UV-stable, perforated (draining) version, which may cost more: ask each seller.

|Every option also needs|Basis|Low|High
|Lift and store the tiles|volunteers (in-kind match)|$0|$0
|Take out the hoops (back up when switching)|lump sum, estimate|$2,000|$6,000
|Light pole padding|lump sum, estimate|$1,000|$3,000
|Two portable goals + nets|pair|$3,000|$6,000
|Design, permit, mobilisation|lump sum|$4,000|$6,000
|**Shared total**||**$10,000**|**$21,000**

|Total with 10% contingency|Low|High
|1 Used foam-backed|~$20,100|~$32,200
|2 New padded roll-out|~$29,700|~$52,500
|3 Non-infill + shock pad|~$56,500|~$114,000
|4 Infilled + shock pad (best)|~$62,500|~$132,200
Add-alternates: A1 turf out to the fence (price when bid), A2 ball netting $5,000–$10,000, A3 kickboards $8,000–$15,000, A4 storage box + benches $3,000–$6,000.
Turf lasts about 8–10 years, so the plan sets aside about $5,000 a year for replacement.$b$
FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'erie-avenue-turf' AND s.sort_order = 4;

UPDATE proposal_sections s SET body = $b$Size the ask to the option picked. The lights are already up, so nothing here needs lighting money. PA DCNR's Park Rehabilitation and Development grant (round **Jan 11 – Apr 30, 2027**) typically awards $100,000–$250,000 with a dollar-for-dollar match, so it fits options 3 and 4 ($56,500–$132,200). The roll-up options 1 and 2 ($20,100–$52,500) suit sponsors and smaller grants.
|Source|Funds|Fit|Next step
|[PA DCNR C2P2 Park Rehab & Development](https://www.pa.gov/services/dcnr/apply-for-dcnr-park-rehabilitation-and-development-grants)|Public parks and recreation facilities|Strong for options 3–4: nonprofits eligible; must be open to the public|Call the DCNR Regional Advisor first
|[U.S. Soccer Foundation](https://ussoccerfoundation.org/programs/safe-places-to-play/)|Mini-pitches, ~$150,000 each (2026)|Weak for turf: hard-court only, 4,000–8,000 sq ft (ours 5,510). Strong for a hard-court pitch|info@ussoccerfoundation.org; "Suggest a Location" form
|[Sixers Youth Foundation](https://sixersyouthfoundation.org/renovated-courts-and-play-spaces/)|Court renovations; did this court in 2019|Partner, not a grant: they don't take unsolicited proposals. A roll-up option keeps their court|info@sixersyouthfoundation.org, 215-952-7000
|Philadelphia Soccer 2026 / City Rebuild|Mini-pitches ($2M legacy; Rebuild $3.5M for 15)|Legacy money probably spent; Rebuild worth asking|Ask both whether money is left
|Corporate sponsors|Naming and signage|Good for options 1–2, and the match for 3–4|Approach with a picked option and its price
**Match.** DCNR's match can be cash or in-kind: in-house services, donated services, equipment use, volunteer labour (Grant Manual p.17). Volunteer hours count at the PA Independent Sector Volunteer Rate; meeting and admin time doesn't.$b$
FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'erie-avenue-turf' AND s.sort_order = 6;

UPDATE proposal_sections s SET body = $b$- **Dec 2026:** pick a turf option; decide the applicant (The Light House or the club); talk to the Sixers Youth Foundation (roll-up turf, hoops); prices for the chosen option.
- **Jan 2027:** call the DCNR Regional Advisor (turf? which fund?); collect letters of support and match commitments.
- **Jan 11 – Apr 30, 2027:** DCNR application window (options 3–4).
- **Fall 2027:** awards; line up sponsors for the match.
- **2028:** lift the tiles and lay the turf in days on the existing slab, then open. Options 1–2 can go down as soon as the money is raised.$b$
FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'erie-avenue-turf' AND s.sort_order = 9;

UPDATE proposal_sections s SET body = $b$- Which turf option: roll-up (court goes back to basketball) or permanent?
- Outdoor-rated versions and prices for options 1 and 2.
- Where the stored tiles, and the rolled turf off-season, are kept.
- Who applies: The Light House (owns the land) or the club (needs a 25-year lease).
- Does the 2019 Sixers court deal allow covering it?
- Is turf over a court eligible for DCNR?$b$
FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'erie-avenue-turf' AND s.sort_order = 10;
