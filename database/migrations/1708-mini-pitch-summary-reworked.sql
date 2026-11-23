-- 🏟 Turf Mini Pitch: the summary reworked (James 11/23 "work on summary the
-- rest and extend section should also containt he reversible basketball
-- court with painted basketball court so no tile or tile storgage otpoins").
-- What it does, as three points together: rests the grass and extends
-- training; the court stays a basketball court (turf down November to March,
-- rolled away in good weather); with the slab painted for basketball, no
-- tiles to lay, keep up or store. Then what it costs. Same facts and figures.
BEGIN;
UPDATE proposal_sections s SET body = $b$From James Breslin. To Edwin Desamour, Executive Director, Julian Makarechi, Deputy Director, and Anita Lyndaker, Grant Writer, at Lighthouse.
This is the mini pitch proposal: roll-up synthetic turf on a shock pad on the 76ers court at Lighthouse Sports Complex, 101 East Erie Avenue.
**What it does**
- **Rests the grass field and extends training** into late fall, winter and early spring.
- **Keeps the basketball court.** Basketball is generally not played outside from November to March, but soccer is. The turf goes down for those months. In good weather the grounds crew rolls it up and the court is used for basketball again. The hoops stay up throughout.
- **No tiles needed.** If the concrete slab is painted for basketball, the court is ready as soon as the turf is rolled up: no tiles to lay back, keep up or store. The other way is to keep today's tiles, store them on site and lay them back each time.
**What it costs**
The turf and shock pad cost **$16,835** (low-end turf inside the poles, laid by us) to **$64,790** (high-end turf over the whole slab, laid by a contractor). Netting, a fence, kickboards, pole padding and goals are add-ons, each priced on its own. Prices are estimates from published figures, not quotes.
The flat concrete slab and the lights are already there, which saves about $105,000 against building the same pitch from scratch.$b$
FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'erie-avenue-turf' AND s.sort_order = 1;
COMMIT;
