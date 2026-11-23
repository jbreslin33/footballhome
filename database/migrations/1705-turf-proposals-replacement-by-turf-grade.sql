-- 🏟 Turf proposals: the replacement cost depends on the turf grade (James
-- 11/23 "turf replacement fund would depend on level of turf right?").
-- Mini pitch Upkeep: the flat $5,000-a-year fund (left from the first draft)
-- becomes a grid, new turf of the same grade over 10 years: area × $2.50 /
-- $4.00 / $6.00 ÷ 10. "Brush and top up infill" → "Brush the turf": roll-up
-- turf has no infill. Field pitches Upkeep: replacement by grade, area ×
-- (turf + $1.00 infill + $2.00 install).
BEGIN;
UPDATE proposal_sections s SET body = $b$Upkeep is about **$2,000 a year**, plus a turf replacement fund that depends on the turf grade.
|Task|How often|Who|Yearly cost
|Blow off leaves, check edges and seams|Weekly|Volunteers|$0
|Brush the turf|Monthly in season|Volunteers, hired brush|$500
|Deep clean and seam check|Yearly|Turf contractor|$1,500

|Turf replacement fund, a year|Low-end turf|Mid-range turf|High-end turf
|Inside the poles|$1,295|$2,072|$3,108
|Whole slab|$1,472|$2,356|$3,534
The fund is the price of new turf of the same grade, spread over 10 years. Turf lasts about 8–10 years; the shock pad stays.$b$
FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'erie-avenue-turf' AND s.sort_order = 8;
UPDATE proposal_sections s SET body = $b$Turf lasts about 8–10 years. The base and the shock pad stay; the turf and infill are replaced. What that costs depends on the turf grade.
|New turf, infill and install|Low-end turf|Mid-range turf|High-end turf
|5v5|$81,950|$104,300|$134,100
|7v7|$150,260|$191,240|$245,880
|9v9|$238,370|$303,380|$390,060
|Full|$480,645|$611,730|$786,510
Per sq ft: turf $2.50, $4.00 or $6.00, plus infill $1.00 and install $2.00.$b$
FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'field-turf-pitches' AND s.sort_order = 5;
COMMIT;
