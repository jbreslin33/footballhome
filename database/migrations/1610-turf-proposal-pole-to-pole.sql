-- 🏟 Erie Avenue turf proposal: real size, Google Maps estimates out (James
-- 11/20 "take out google stuff. the turf would be from 16.48 m, 31.06 if it
-- went right up to the side light poles and we took out the basketball hoops
-- and moved them and then were able to go full width. we would put padding
-- around the light poles and draw lines a yard in from them so there is a
-- little buffer").
-- Turf 31.06 × 16.48 m = 511.9 m² = 5,510 sq ft (was 5,750 from satellite).
-- Lines a yard (0.91 m) inside the poles each side: 31.06 × 14.65 m.
-- Budget re-run on 5,510 sq ft + two new lines (move hoops, pole padding).

UPDATE proposals SET
  summary = 'Turf pole to pole over the 76ers court at Lighthouse Sports Complex. $64,000–$120,000 base; PA DCNR round Jan 11 – Apr 30, 2027.',
  as_of = '2026-11-20'
WHERE code = 'erie-avenue-turf';

UPDATE proposal_sections s SET body = $b$Lighthouse asks for about **$64,000–$120,000** to lay a synthetic turf mini-pitch over the existing 76ers basketball court at Lighthouse Sports Complex, 101 East Erie Avenue. The asphalt is already there, so there is no excavation, paving or drainage work: a low-risk build a funder can see finished in one season.
The turf runs **31.06 × 16.48 m (102 × 54 ft)**, the full width out to the side light poles, with the basketball hoops taken out and moved. The poles are padded and the lines sit a yard inside them, so the playing area is 31.06 × 14.65 m (102 × 48 ft). It gives year-round small-sided soccer to the youth teams (U8–U12), free open play for neighbourhood kids, and futsal-style training for the men's and women's teams, who all now share grass that closes in wet weather and winter.$b$
FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'erie-avenue-turf' AND s.sort_order = 1;

UPDATE proposal_sections s SET body = $b$The turf covers the court out to the side light poles: **31.06 × 16.48 m (102 × 54 ft)**, no new paving. It sits at the west end of Lighthouse Field, inside its own fence (40.0083, -75.1263).
|Feature|Size (m)|Size (ft)|Area
|Turf, pole to pole (hoops taken out and moved)|31.06 × 16.48|102 × 54|5,510 sq ft
|Playing lines, a yard (0.91 m) inside the poles|31.06 × 14.65|102 × 48|4,900 sq ft
|Painted basketball lines today|28.6 × 15.2|94 × 50|4,700 sq ft
**Light poles.** The side light poles stay. Each gets padding, and the touchlines are drawn a yard in from them as a buffer.
**Land.** The court is on The Light House's own parcel, 101 E Erie Ave (OPA 777705000), owned since 1943 and tax-exempt, about 14.8 acres. It is not City parkland.
**76ers.** The Sixers Youth Foundation lists the court as renovated in 2019 with The Lighthouse as partner. No terms are published.$b$
FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'erie-avenue-turf' AND s.sort_order = 2;

UPDATE proposal_sections s SET body = $b$A turf-over-court system: clean and patch the asphalt, lay a drainable shock pad, then turf and infill on top. The court stays underneath, so it can be undone.
- **Hoops out.** Take out the two basketball hoops and reset them elsewhere, so the turf can go full width.
- **Prep the court.** Pressure-wash, fill cracks, grind lifted edges, check that water drains off.
- **Shock pad.** 15–25 mm drainable foam or rubber pad over the asphalt.
- **Turf.** Short-pile soccer/futsal turf (30–40 mm) with non-rubber infill (sand or cork), 31.06 × 16.48 m out to the light poles.
- **Pole padding.** Padding around each side light pole.
- **Edges.** Aluminium or timber edge strip around the turf.
- **Lines and goals.** Small-sided lines tufted in a yard inside the poles (31.06 × 14.65 m); two 4 × 2 m (12 × 6 ft) anchored goals.
- **Ball containment.** Taller netting behind the goals.
Add-alternates, priced separately so a funder can pick one up:
- **A1 Turf out to the fence.** Stone base over the grass beyond the poles, then turf.
- **A2 LED lights.** Two to four poles for evening play.
- **A3 Kickboards.** Low boards along the long sides.
- **A4 Storage box and benches.**$b$
FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'erie-avenue-turf' AND s.sort_order = 3;

UPDATE proposal_sections s SET body = $b$Base pitch about **$64,000–$120,000** on 5,510 sq ft. Planning figures from published per-square-foot ranges, not quotes; two contractor bids replace them before any application.
|Line|Basis|Low|High
|Take out and reset two hoops|lump sum|$2,000|$6,000
|Court prep (wash, crack fill, grind)|lump sum|$3,000|$8,000
|Drainable shock pad|5,510 sq ft × $2–$4|$11,020|$22,040
|Turf + non-rubber infill, installed|5,510 sq ft × $5–$8|$27,550|$44,080
|Light pole padding|lump sum|$1,000|$3,000
|Edge strip|~95 m perimeter|$2,000|$4,000
|Two goals + nets, anchored|pair|$3,000|$6,000
|End ball netting|two ends|$5,000|$10,000
|Design, permit, mobilisation|lump sum|$4,000|$6,000
|Contingency|10%|$5,860|$10,910
|**Base total**||**~$64,000**|**~$120,000**

|Add-alternate|Basis|Low|High
|A1 Turf out to the fence|area beyond the poles × $18–$30/sq ft|to measure|to measure
|A2 LED lights|2–4 poles|$60,000|$120,000
|A3 Kickboards|long sides|$8,000|$15,000
|A4 Storage box + benches|lump sum|$3,000|$6,000
Turf lasts about 8–10 years, so the plan sets aside about $5,000 a year for replacement.$b$
FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'erie-avenue-turf' AND s.sort_order = 4;

UPDATE proposal_sections s
SET body = replace(replace(body, 'base + lights ($123,000–$233,000)', 'base + lights ($124,000–$240,000)'),
                   'Weak for turf: hard-court only, 4,000–8,000 sq ft (ours 5,750)', 'Weak for turf: hard-court only, 4,000–8,000 sq ft (ours 5,510)')
FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'erie-avenue-turf' AND s.sort_order = 6;

UPDATE proposal_sections s
SET body = replace(body, 'talk to the Sixers Youth Foundation; tape-measure; two contractor bids.', 'talk to the Sixers Youth Foundation (moving the hoops); two contractor bids.')
FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'erie-avenue-turf' AND s.sort_order = 9;

UPDATE proposal_sections s
SET body = replace(replace(body, '- Does the 2019 Sixers court deal limit covering it?', '- Does the 2019 Sixers court deal allow covering it and moving the hoops?'),
                   '- Tape measure, crack and drainage check, two contractor bids.', '- Crack and drainage check, two contractor bids.')
FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'erie-avenue-turf' AND s.sort_order = 10;
