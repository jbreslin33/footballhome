-- 🏟 New proposal: turf pitches on the FIELD area at Erie Avenue, separate
-- from the mini pitch on the 76ers court (James 11/23 "do full and medium
-- but as separate proposal docs … full is exact normal premier league size
-- then actually do 9v9 and 7v7 and 5v5 sizes. i guess they could all be on
-- same doc but separate from the sixers one because that one already has
-- lights etc" + "full would be the final boss proposal lol" + "with seating
-- etc"). One proposal, four sizes, packages building on each other:
-- 1 Pitch (ground works + turf), 2 Fenced (+ fence, netting, goals),
-- 3 Fenced and lit, 4 Stadium (Full only: + bleachers, shelters, scoreboard).
-- Sizes: Full 105 × 68 m; 9v9 80 × 50 yd; 7v7 60 × 40 yd; 5v5 40 × 30 yd;
-- turf area = pitch + 3 yd run-off on every side.
-- Per sq ft: ground works $5.00, turf $4.00, pad $1.50, infill $1.00,
-- install $2.00 (mid-range, as the mini pitch). Fence $44 a foot.
-- Package totals (1 / 2 / 3 / 4):
--   5v5: $201,150 / $231,798 / $291,798
--   7v7: $368,820 / $408,388 / $508,388
--   9v9: $585,090 / $636,078 / $786,078
--   Full: $1,179,765 / $1,252,373 / $1,528,373 / $1,628,373

BEGIN;

INSERT INTO proposals (code, icon, title, summary, status_code, as_of, sort_order)
VALUES ('field-turf-pitches', '🏟', 'Turf Field Pitches', $s$From James Breslin. Turf pitches on the field area at Erie Avenue: 5v5, 7v7, 9v9 and Full (Premier League size), $201,150 to $1,628,373.$s$, 'draft', '2026-11-23', 4);

INSERT INTO proposal_sections (proposal_id, sort_order, heading, body)
SELECT p.id, v.ord, v.heading, v.body
FROM proposals p, (VALUES
  (1, 'Summary', $b$From James Breslin. To Edwin Desamour, Executive Director, Julian Makarechi, Deputy Director, and Anita Lyndaker, Grant Writer, at Lighthouse.
This is the field pitch proposal: synthetic turf pitches on the field area at Lighthouse Sports Complex, Erie Avenue. It is separate from the mini pitch proposal, which sits on the 76ers court where the slab and lights already exist.
Four sizes, 5v5, 7v7, 9v9 and Full (Premier League size), each in packages that build on the one before: from **$201,150** (5v5, pitch only) up to **$1,628,373** (Full, fenced and lit, with seating). Prices are estimates from published figures, not quotes.$b$),
  (2, 'The sizes', $b$The pitches go on the field area at Lighthouse Sports Complex, Erie Avenue, on grass. There is no slab and there are no lights there, so the ground works and the lights are part of the price.
|Pitch|Format|Pitch size (m)|Pitch size (yd)|Turf area with run-off
|5v5|5v5|36.58 × 27.43|40 × 30 yd|14,900 sq ft
|7v7|7v7|54.86 × 36.58|60 × 40 yd|27,320 sq ft
|9v9|9v9|73.15 × 45.72|80 × 50 yd|43,340 sq ft
|Full|11v11|105 × 68|115 × 74 yd|87,390 sq ft
Full is Premier League size, 105 × 68 m. The 9v9, 7v7 and 5v5 sizes are the standard small-sided pitch sizes. Every turf area includes a 3 yd run-off on all four sides.$b$),
  (3, 'Scope of work', $b$- Dig out the grass, grade the ground and put in drainage.
- Lay and compact a stone base.
- Lay the shock pad, the turf and the infill; mark the lines (contractor).
- Packages 2–4 add the fence, netting, goals, lights and seating.$b$),
  (4, 'Packages and costs', $b$Four pitch sizes, each in packages that build on the one before. Full with every package is the top of the ladder.
|Pitch|1 Pitch|2 Fenced|3 Fenced and lit|4 Stadium
|5v5 (5v5)|$201,150|$231,798|$291,798|Full only
|7v7 (7v7)|$368,820|$408,388|$508,388|Full only
|9v9 (9v9)|$585,090|$636,078|$786,078|Full only
|Full (11v11)|$1,179,765|$1,252,373|$1,528,373|$1,628,373
**Package 1, Pitch:** the ground dug, graded and drained, a stone base, then infilled soccer turf on a shock pad, laid by a contractor, with lines.
**Package 2, Fenced:** package 1 plus a chain-link fence around the turf, ball netting behind both goals, and goals.
**Package 3, Fenced and lit:** package 2 plus lights.
**Package 4, Stadium (Full only):** package 3 plus bleachers for 500, two team shelters and a scoreboard.
**Package 1 by turf grade**
|Pitch|Low-end turf|Mid-range turf|High-end turf
|5v5|$167,625|$201,150|$253,300
|7v7|$307,350|$368,820|$464,440
|9v9|$487,575|$585,090|$736,780
|Full|$983,138|$1,179,765|$1,485,630
The package prices use mid-range turf. Per sq ft, turf and shock pad: low-end $2.50 and $0.75, mid-range $4.00 and $1.50, high-end $6.00 and $3.00.
**5v5 pitch: 5v5, 36.58 × 27.43 m (40 × 30 yd)**
Turf area with a 3 yd run-off on every side: 42.1 × 32.9 m = 14,900 sq ft. Fence line: 492 ft.
|Item|Quantity × unit price|Cost
|Dig, grade, stone base and drainage|14,900 sq ft × $5.00|$74,500
|Turf|14,900 sq ft × $4.00|$59,600
|Shock pad|14,900 sq ft × $1.50|$22,350
|Infill|14,900 sq ft × $1.00|$14,900
|Contractor install|14,900 sq ft × $2.00|$29,800
|**Package 1 total: Pitch**||**$201,150**
|Chain-link fence, installed|492 ft × $44|$21,648
|Ball netting behind the goals|both ends, estimate|$7,500
|Goals + nets|one pair, estimate|$1,500
|**Package 2 total: Fenced**||**$231,798**
|Lights: poles, LED fixtures, wiring|lump sum|$60,000
|**Package 3 total: Fenced and lit**||**$291,798**
**7v7 pitch: 7v7, 54.86 × 36.58 m (60 × 40 yd)**
Turf area with a 3 yd run-off on every side: 60.4 × 42.1 m = 27,320 sq ft. Fence line: 672 ft.
|Item|Quantity × unit price|Cost
|Dig, grade, stone base and drainage|27,320 sq ft × $5.00|$136,600
|Turf|27,320 sq ft × $4.00|$109,280
|Shock pad|27,320 sq ft × $1.50|$40,980
|Infill|27,320 sq ft × $1.00|$27,320
|Contractor install|27,320 sq ft × $2.00|$54,640
|**Package 1 total: Pitch**||**$368,820**
|Chain-link fence, installed|672 ft × $44|$29,568
|Ball netting behind the goals|both ends, estimate|$7,500
|Goals + nets|one pair, estimate|$2,500
|**Package 2 total: Fenced**||**$408,388**
|Lights: poles, LED fixtures, wiring|lump sum|$100,000
|**Package 3 total: Fenced and lit**||**$508,388**
**9v9 pitch: 9v9, 73.15 × 45.72 m (80 × 50 yd)**
Turf area with a 3 yd run-off on every side: 78.6 × 51.2 m = 43,340 sq ft. Fence line: 852 ft.
|Item|Quantity × unit price|Cost
|Dig, grade, stone base and drainage|43,340 sq ft × $5.00|$216,700
|Turf|43,340 sq ft × $4.00|$173,360
|Shock pad|43,340 sq ft × $1.50|$65,010
|Infill|43,340 sq ft × $1.00|$43,340
|Contractor install|43,340 sq ft × $2.00|$86,680
|**Package 1 total: Pitch**||**$585,090**
|Chain-link fence, installed|852 ft × $44|$37,488
|Ball netting behind the goals|both ends, estimate|$10,000
|Goals + nets|one pair, estimate|$3,500
|**Package 2 total: Fenced**||**$636,078**
|Lights: poles, LED fixtures, wiring|lump sum|$150,000
|**Package 3 total: Fenced and lit**||**$786,078**
**Full pitch: 11v11, 105 × 68 m (115 × 74 yd)**
Turf area with a 3 yd run-off on every side: 110.5 × 73.5 m = 87,390 sq ft. Fence line: 1,207 ft.
|Item|Quantity × unit price|Cost
|Dig, grade, stone base and drainage|87,390 sq ft × $5.00|$436,950
|Turf|87,390 sq ft × $4.00|$349,560
|Shock pad|87,390 sq ft × $1.50|$131,085
|Infill|87,390 sq ft × $1.00|$87,390
|Contractor install|87,390 sq ft × $2.00|$174,780
|**Package 1 total: Pitch**||**$1,179,765**
|Chain-link fence, installed|1,207 ft × $44|$53,108
|Ball netting behind the goals|both ends, estimate|$15,000
|Goals + nets|one pair, estimate|$4,500
|**Package 2 total: Fenced**||**$1,252,373**
|Lights: poles, LED fixtures, wiring|lump sum|$276,000
|**Package 3 total: Fenced and lit**||**$1,528,373**
|Bleachers|500 seats × $150, estimate|$75,000
|Team shelters|two, estimate|$10,000
|Scoreboard|estimate|$15,000
|**Package 4 total: Stadium**||**$1,628,373**
**About the prices.** Typical costs from published figures, not quotes, with no contingency. Turf, pad and install as in the mini pitch proposal ([Texas Tuff](https://texas-tuff.com/blog/artificial-turf-football-field-cost/)). Ground works at $5.00 a sq ft: published guides put grading, drainage and base at 35–50% of a turf field. Fence $44 a foot ([Ergeon](https://www.ergeon.com/blog/post/chain-link-fence-costs)). Full-pitch lights are the middle of the published $208,616–$343,976 for a soccer field in the Northeast ([Sports Venue Calculator](https://sportsvenuecalculator.com/knowledge/led-sports-lighting/led-soccer-field-lighting-cost-guide/)); lights for the smaller pitches are scaled down from that and are estimates, as are netting, goals, bleachers, shelters and the scoreboard.$b$),
  (5, 'Upkeep', $b$Turf lasts about 8–10 years. The base and the shock pad stay; the turf and infill are replaced.
|Pitch|New turf, infill and install ($7.00 a sq ft)
|5v5|$104,300
|7v7|$191,240
|9v9|$303,380
|Full|$611,730$b$),
  (6, 'Decisions', $b$- **Size:** 5v5, 7v7, 9v9 or Full?
- **Package:** 1 Pitch, 2 Fenced, 3 Fenced and lit, or 4 Stadium (Full only)?
- **Turf grade:** low-end, mid-range or high-end?
- **Where on the field** it goes.$b$)
) AS v(ord, heading, body)
WHERE p.code = 'field-turf-pitches';

COMMIT;
